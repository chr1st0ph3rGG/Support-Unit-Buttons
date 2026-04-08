-- Integrations/ShadowedUnitFrames.lua
-- ShadowedUnitFrames integration: frame lookup, positioning, options block
-------------------------------------------------------------------------------

local _, SUB_NS     = ...
local SUB           = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local UNITS         = SUB_NS.UNITS
local UNIT_INDEX    = SUB_NS.UNIT_INDEX
local HANDLE_HEIGHT = SUB_NS.HANDLE_HEIGHT

-- Frame Lookup
--
-- Party frames live in a SecureGroupHeaderTemplate without predictable
-- global names, so SUF's own unitFrames map is used.
--
-- Special case "player":
--   SUF's OnAttributeChanged stores a frame in unitFrames only when
--   unitRealType == unitType. For the party-header child with unit="player",
--   unitRealType="player" but unitType="party" → that child NEVER ends up in
--   unitFrames["player"]. Therefore we scan the party-header children first
--   for a visible child with unit="player" before falling back to the
--   standalone SUFUnitplayer frame.
-------------------------------------------------------------------------------

-- Returns SUF's units table, or nil if SUF is unavailable.
local function GetShadowUFUnits()
    local suf = _G["ShadowUF"]
    return suf and suf.Units or nil
end

-- Returns the visible player frame from SUF's party header, or nil.
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

-- Returns the visible frame from SUF's unitFrames map, or nil.
local function GetSUFUnitFrame(units, unit)
    local unitFrames = units.unitFrames
    if not unitFrames then return nil end

    local frame = unitFrames[unit]
    if frame and frame:IsShown() then return frame end

    return nil
end

-- Returns the visible standalone SUF frame, or nil.
local function GetStandaloneSUFFrame(unit)
    local standalone = _G["SUFUnit" .. unit]
    if standalone and standalone:IsShown() then return standalone end

    return nil
end

-- Returns the highest-priority SUF frame for `unit`, or nil.
local function GetPreferredSUFFrame(units, unit)
    if unit ~= "player" then return nil end
    return GetSUFPartyPlayerFrame(units)
end

-- Returns the matching visible SUF frame for `unit`, or nil.
local function GetSUFFrame(unit)
    local units = GetShadowUFUnits()
    if not units then return nil end

    return GetPreferredSUFFrame(units, unit)
        or GetSUFUnitFrame(units, unit)
        or GetStandaloneSUFFrame(unit)
end

-- Vertical Y offset in ApplySUFPositions so the anchor point targets the
-- button bar instead of the drag handle bar above it.
-- TOP*  → frame must be shifted up by HANDLE_HEIGHT
-- MID   → frame must be shifted up by HANDLE_HEIGHT/2
-- BOT*  → no adjustment needed (buttons end at the frame bottom)
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

-- Public Integration Methods
-------------------------------------------------------------------------------

-- Returns true if ShadowedUnitFrames is loaded.
function SUB:IsSUFInstalled()
    local fn = (C_AddOns and C_AddOns.IsAddOnLoaded) or _G["IsAddOnLoaded"]
    return fn ~= nil and fn("ShadowedUnitFrames") == true
end

-- "suf" mode: anchor each bar to the corresponding ShadowedUnitFrames party frame.
-- The Y offset is adjusted automatically so the anchor point targets the
-- button bar (not the drag handle bar above it).
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
                -- Fallback if no visible SUF frame is found: default stacking.
                local uIdx = UNIT_INDEX[unit] or 0
                bd.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
                    10, -100 - uIdx * (db.buttonSize + HANDLE_HEIGHT + 6))
            end
        end
    end
end

-- Schedules a deferred ApplySUFPositions call for the next frame tick.
-- Protects against stacked calls during rapid roster changes.
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

-- Returns the AceConfig block for the SUF anchor point options.
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
