-------------------------------------------------------------------------------
-- Integrations/ShadowedUnitFrames.lua
-- ShadowedUnitFrames-Integration: Frame-Lookup, Positionierung, Options-Block
-------------------------------------------------------------------------------

local _, SUB_NS     = ...
local SUB           = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local UNITS         = SUB_NS.UNITS
local UNIT_INDEX    = SUB_NS.UNIT_INDEX
local HANDLE_HEIGHT = SUB_NS.HANDLE_HEIGHT

-------------------------------------------------------------------------------
-- Frame-Lookup
--
-- Party-Frames leben in einem SecureGroupHeaderTemplate ohne vorhersehbare
-- globale Namen, daher wird SUFs eigene unitFrames-Map benutzt.
--
-- Sonderfall "player":
--   SUFs OnAttributeChanged speichert einen Frame in unitFrames nur dann,
--   wenn unitRealType == unitType.  Für das Party-Header-Kind mit unit="player"
--   gilt unitRealType="player" aber unitType="party" → das Kind landet NIE in
--   unitFrames["player"].  Daher scannen wir zuerst die Party-Header-Kinder
--   nach einem sichtbaren Kind mit unit="player", bevor wir auf den
--   SUFUnitplayer-Standalone zurückfallen.
-------------------------------------------------------------------------------

-- Gibt SUFs units-Table zurück, oder nil wenn SUF nicht verfügbar.
local function GetShadowUFUnits()
    local suf = _G["ShadowUF"]
    return suf and suf.Units or nil
end

-- Gibt den sichtbaren Player-Frame aus SUFs Party-Header zurück, oder nil.
local function GetSUFPartyPlayerFrame(units)
    local partyHeader = units.headerFrames and units.headerFrames["party"]
    if not partyHeader or not partyHeader:IsShown() then return nil end

    for _, child in ipairs({ partyHeader:GetChildren() }) do
        if child:GetAttribute("unit") == "player" and child:IsShown() then
            return child
        end
    end

    return nil
end

-- Gibt den sichtbaren Frame aus SUFs unitFrames-Map zurück, oder nil.
local function GetSUFUnitFrame(units, unit)
    local unitFrames = units.unitFrames
    if not unitFrames then return nil end

    local frame = unitFrames[unit]
    if frame and frame:IsShown() then return frame end

    return nil
end

-- Gibt den sichtbaren Standalone-SUF-Frame zurück, oder nil.
local function GetStandaloneSUFFrame(unit)
    local standalone = _G["SUFUnit" .. unit]
    if standalone and standalone:IsShown() then return standalone end

    return nil
end

-- Gibt den höchst-priorisierten SUF-Frame für `unit` zurück, oder nil.
local function GetPreferredSUFFrame(units, unit)
    if unit ~= "player" then return nil end
    return GetSUFPartyPlayerFrame(units)
end

-- Gibt den passenden sichtbaren SUF-Frame für `unit` zurück, oder nil.
local function GetSUFFrame(unit)
    local units = GetShadowUFUnits()
    if not units then return nil end

    return GetPreferredSUFFrame(units, unit)
        or GetSUFUnitFrame(units, unit)
        or GetStandaloneSUFFrame(unit)
end

-- Vertikaler Y-Offset in ApplySUFPositions, damit der Ankerpunkt auf die
-- Button-Leiste zeigt, nicht auf die darüber liegende Drag-Handle-Leiste.
-- TOP*  → Frame muss um HANDLE_HEIGHT nach oben verschoben werden
-- MID   → Frame muss um HANDLE_HEIGHT/2 nach oben verschoben werden
-- BOT*  → keine Anpassung nötig (Buttons enden am Frame-Boden)
local SUF_HANDLE_ADJUST = {
    TOPLEFT     = HANDLE_HEIGHT,
    TOP         = HANDLE_HEIGHT,
    TOPRIGHT    = HANDLE_HEIGHT,
    LEFT        = math.floor(HANDLE_HEIGHT / 2),
    RIGHT       = math.floor(HANDLE_HEIGHT / 2),
    BOTTOMLEFT  = 0,
    BOTTOM      = 0,
    BOTTOMRIGHT = 0,
}

-------------------------------------------------------------------------------
-- Öffentliche Integrations-Methoden
-------------------------------------------------------------------------------

-- Gibt true zurück wenn ShadowedUnitFrames geladen ist.
function SUB:IsSUFInstalled()
    local fn = (C_AddOns and C_AddOns.IsAddOnLoaded) or _G["IsAddOnLoaded"]
    return fn ~= nil and fn("ShadowedUnitFrames") == true
end

-- "suf"-Modus: jede Bar an den entsprechenden ShadowedUnitFrames-Party-Frame ankern.
-- Der Y-Offset wird automatisch angepasst, damit der Ankerpunkt auf die
-- Button-Leiste zeigt (nicht auf die Drag-Handle-Leiste darüber).
function SUB:ApplySUFPositions()
    local db       = self.db.profile
    local selfPt   = db.sufAnchorSelf or "LEFT"
    local targetPt = db.sufAnchorTarget or "RIGHT"
    local offX     = db.sufOffsetX or 0
    local offY     = db.sufOffsetY or 0
    local yAdj     = SUF_HANDLE_ADJUST[selfPt] or 0

    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if bd and bd.frame:IsShown() then
            local sufFrame = GetSUFFrame(unit)
            bd.frame:ClearAllPoints()
            if sufFrame then
                bd.frame:SetPoint(selfPt, sufFrame, targetPt, offX, offY + yAdj)
            else
                -- Fallback wenn kein sichtbarer SUF-Frame gefunden: Standard-Stapeln.
                local uIdx = UNIT_INDEX[unit] or 0
                bd.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
                    10, -100 - uIdx * (db.buttonSize + HANDLE_HEIGHT + 6))
            end
        end
    end
end

-- Plant einen aufgeschobenen ApplySUFPositions-Aufruf für den nächsten Frame-Tick.
-- Schützt vor gestapelten Aufrufen bei schnellen Roster-Änderungen.
function SUB:ScheduleSUFPositions()
    if self.sufPosPending then return end
    self.sufPosPending = true
    C_Timer.After(0, function()
        self.sufPosPending = false
        if self.db and self.db.profile and self.db.profile.positionMode == "suf" then
            self:ApplySUFPositions()
        end
    end)
end

-- Gibt den AceConfig-Block für die SUF-Ankerpunkt-Optionen zurück.
function SUB:GetSUFOptionsGroup()
    local L = LibStub("AceLocale-3.0"):GetLocale("SupportUnitButtons")
    return {
        name   = L["ShadowedUnitFrames Anchor"],
        type   = "group",
        inline = true,
        order  = 4,
        hidden = function() return not self:IsSUFInstalled() or self.db.profile.positionMode ~= "suf" end,
        args   = {
            sufAnchorSelf = {
                name   = L["Bar anchor point"],
                desc   = L["Which point of the SUB bar to anchor from"],
                type   = "select",
                order  = 1,
                values = {
                    TOPLEFT     = L["Top left"],
                    TOP         = L["Top"],
                    TOPRIGHT    = L["Top right"],
                    LEFT        = L["Left"],
                    RIGHT       = L["Right"],
                    BOTTOMLEFT  = L["Bottom left"],
                    BOTTOM      = L["Bottom"],
                    BOTTOMRIGHT = L["Bottom right"],
                },
                get    = function() return self.db.profile.sufAnchorSelf or "LEFT" end,
                set    = function(_, v)
                    self.db.profile.sufAnchorSelf = v
                    self:ApplySUFPositions()
                end,
            },
            sufAnchorTarget = {
                name   = L["SUF anchor point"],
                desc   = L["Which point of the SUF frame to attach to"],
                type   = "select",
                order  = 2,
                values = {
                    TOPLEFT     = L["Top left"],
                    TOP         = L["Top"],
                    TOPRIGHT    = L["Top right"],
                    LEFT        = L["Left"],
                    RIGHT       = L["Right"],
                    BOTTOMLEFT  = L["Bottom left"],
                    BOTTOM      = L["Bottom"],
                    BOTTOMRIGHT = L["Bottom right"],
                },
                get    = function() return self.db.profile.sufAnchorTarget or "RIGHT" end,
                set    = function(_, v)
                    self.db.profile.sufAnchorTarget = v
                    self:ApplySUFPositions()
                end,
            },
            sufOffsetX = {
                name  = L["Offset X"],
                desc  = L["Horizontal offset from the SUF anchor point (pixels)"],
                type  = "range",
                order = 3,
                width = "half",
                min   = -500,
                max   = 500,
                step  = 1,
                get   = function() return self.db.profile.sufOffsetX or 0 end,
                set   = function(_, v)
                    self.db.profile.sufOffsetX = v
                    self:ApplySUFPositions()
                end,
            },
            sufOffsetY = {
                name  = L["Offset Y"],
                desc  = L["Vertical offset from the SUF anchor point (pixels)"],
                type  = "range",
                order = 4,
                width = "half",
                min   = -500,
                max   = 500,
                step  = 1,
                get   = function() return self.db.profile.sufOffsetY or 0 end,
                set   = function(_, v)
                    self.db.profile.sufOffsetY = v
                    self:ApplySUFPositions()
                end,
            },
        },
    }
end
