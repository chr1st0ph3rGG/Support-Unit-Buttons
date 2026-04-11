-------------------------------------------------------------------------------
-- Core/Resurrection.lua
-- Resurrection-status alert: colored border on resurrection-capable buttons.
-------------------------------------------------------------------------------

local _, SUB_NS           = ...
local SUB                 = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local CE                  = LibStub("C_Everywhere")

local UNITS               = SUB_NS.UNITS
local REZ_ID_SPELLS       = SUB_NS.REZ_ID_SPELLS

-- spell name → true; built from REZ_ID_SPELLS for name-based fallback lookup.
local rezNameSpells       = {}
-- unit token → true while a rez cast targeting that unit is in flight.
local rezCastingUnits     = {}

-- Fixed states used when rezAlertPreview is active (Options preview mode).
local PREVIEW_STATES      = {
    player = "dead",
    party1 = "casting",
    party2 = "pending",
    party3 = "dead",
    party4 = "casting",
}

-- Maps rez state strings to their db profile color key.
local REZ_STATE_COLOR_KEY = {
    dead    = "rezAlertColorDead",
    casting = "rezAlertColorCasting",
    pending = "rezAlertColorPending",
}

-- Rebuilds rezNameSpells from REZ_ID_SPELLS. Call after spell data is available.
function SUB:BuildRezNameSpells()
    wipe(rezNameSpells)
    for id in pairs(REZ_ID_SPELLS) do
        local info = CE.Spell.GetSpellInfo(id)
        local name = info and info.name
        if name then
            rezNameSpells[name] = true
        end
    end
end

-- Returns true if action (spell id or name string) is a known resurrection spell.
local function IsResurrectionAction(action)
    local id = tonumber(action)
    if id and REZ_ID_SPELLS[id] then return true end
    local info = CE.Spell.GetSpellInfo(id or action)
    return info and rezNameSpells[info.name] and true or false
end

-- Returns true if btn is a spell button bound to a resurrection spell.
local function IsResurrectionButton(btn)
    if btn._state_type ~= "spell" then return false end
    local action = btn._state_action
    if not action then return false end
    return IsResurrectionAction(action)
end

-- Returns true if the unit has an incoming resurrection (safe even on classic where the API may be absent).
local function HasIncomingRez(unit)
    return UnitHasIncomingResurrection and UnitHasIncomingResurrection(unit) and true or false
end

-- Returns the unit token for the given GUID, or nil if not found in UNITS.
local function GetUnitFromGUID(guid)
    if not guid then return nil end
    for _, unit in ipairs(UNITS) do
        if UnitGUID(unit) == guid then
            return unit
        end
    end
end

-- Registers or unregisters combat log / unit-flag events based on rezAlert setting.
function SUB:UpdateRezEventRegistrations()
    if self.db and self.db.profile.rezAlert then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogRez")
        self:RegisterEvent("UNIT_FLAGS", "OnUnitFlags")
    else
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:UnregisterEvent("UNIT_FLAGS")
    end
end

-- Returns "pending", "casting", "dead", or nil if unit is alive/invalid.
local function GetRezState(unit)
    if not CE.Unit.UnitExists(unit) or not UnitIsDeadOrGhost(unit) then return nil end
    return HasIncomingRez(unit) and "pending"
        or rezCastingUnits[unit] and "casting"
        or "dead"
end

-- Returns the rez state for the unit a button is assigned to, respecting preview mode.
local function GetButtonRezState(sub, btn)
    if sub.rezAlertPreview then
        return PREVIEW_STATES[btn.SUB_unit] or "dead"
    end
    return GetRezState(btn.SUB_unit)
end

-- Sizes and anchors the overlay frame around btn with the given padding.
local function PositionRezOverlay(btn, ov, pad)
    local baseLevel = btn:GetFrameLevel()
    if btn.SUB_textOverlay then
        btn.SUB_textOverlay:SetFrameLevel(baseLevel + 10)
    end
    ov:SetFrameLevel(baseLevel + 8)
    ov:ClearAllPoints()
    ov:SetPoint("TOPLEFT", btn, "TOPLEFT", -pad, pad)
    ov:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", pad, -pad)
end

-- Returns the existing overlay for btn, or creates and initialises a new one.
local function GetOrCreateRezOverlay(btn)
    if btn.SUB_rezOverlay then return btn.SUB_rezOverlay end

    local ov = CreateFrame("Frame", nil, btn)
    ov:Hide()

    local function makeStrip()
        local t = ov:CreateTexture(nil, "OVERLAY")
        t:SetTexture([[Interface\Buttons\WHITE8X8]])
        return t
    end

    ov.eT = makeStrip()
    ov.eB = makeStrip()
    ov.eL = makeStrip()
    ov.eR = makeStrip()

    ov.eRing = ov:CreateTexture(nil, "OVERLAY")
    ov.eRing:SetTexture([[Interface\AddOns\SupportUnitButtons\Textures\circle_ring]])
    ov.eRing:SetAllPoints(ov)
    ov.eRing:Hide()

    ov._t = 0
    ov:SetScript("OnUpdate", function(self, elapsed)
        self._t = self._t + elapsed
        local db = SUB.db and SUB.db.profile
        if not db then return end
        local speed = db.rezAlertPulseSpeed or 0.0
        local alphaMin = db.rezAlertAlphaMin or 1.0
        local alphaMax = db.rezAlertAlphaMax or 1.0
        local a
        if speed > 0 and alphaMin < alphaMax then
            local phase = (1 - math.cos(self._t * math.pi * speed)) / 2
            a = alphaMin + (alphaMax - alphaMin) * phase
        else
            a = alphaMax
        end
        self.eT:SetAlpha(a)
        self.eB:SetAlpha(a)
        self.eL:SetAlpha(a)
        self.eR:SetAlpha(a)
        self.eRing:SetAlpha(a)
    end)

    btn.SUB_rezOverlay = ov
    return ov
end

-- Hides the rez overlay on btn if one exists.
local function HideRezOverlay(btn)
    if btn.SUB_rezOverlay then
        btn.SUB_rezOverlay:Hide()
    end
end

-- Activates the ring texture, hides the four border strips.
local function ShowCircleRezOverlay(ov, col)
    ov.eT:Hide()
    ov.eB:Hide()
    ov.eL:Hide()
    ov.eR:Hide()
    ov.eRing:SetVertexColor(col.r, col.g, col.b, 1)
    ov.eRing:Show()
end

-- Activates the four border strips at width bw, hides the ring texture.
local function ShowSquareRezOverlay(ov, bw)
    ov.eRing:Hide()

    ov.eT:ClearAllPoints()
    ov.eT:SetPoint("TOPLEFT", ov, "TOPLEFT", 0, 0)
    ov.eT:SetPoint("TOPRIGHT", ov, "TOPRIGHT", 0, 0)
    ov.eT:SetHeight(bw)
    ov.eT:Show()

    ov.eB:ClearAllPoints()
    ov.eB:SetPoint("BOTTOMLEFT", ov, "BOTTOMLEFT", 0, 0)
    ov.eB:SetPoint("BOTTOMRIGHT", ov, "BOTTOMRIGHT", 0, 0)
    ov.eB:SetHeight(bw)
    ov.eB:Show()

    ov.eL:ClearAllPoints()
    ov.eL:SetPoint("TOPLEFT", ov, "TOPLEFT", 0, -bw)
    ov.eL:SetPoint("BOTTOMLEFT", ov, "BOTTOMLEFT", 0, bw)
    ov.eL:SetWidth(bw)
    ov.eL:Show()

    ov.eR:ClearAllPoints()
    ov.eR:SetPoint("TOPRIGHT", ov, "TOPRIGHT", 0, -bw)
    ov.eR:SetPoint("BOTTOMRIGHT", ov, "BOTTOMRIGHT", 0, bw)
    ov.eR:SetWidth(bw)
    ov.eR:Show()
end

-- Applies color, shape and border-width to ov according to db settings and rez state.
local function ConfigureRezOverlay(sub, btn, ov, state)
    local db = sub.db.profile
    local pad = db.rezAlertPadding
    if pad == nil then pad = 3 end
    PositionRezOverlay(btn, ov, pad)

    local colorKey = REZ_STATE_COLOR_KEY[state]
    local col = (colorKey and db[colorKey]) or db.rezAlertColorDead
    local shape = db.rezAlertShape or "square"
    local bwCfg = db.rezAlertBorderWidth or 0
    local bw = bwCfg > 0 and bwCfg or math.max(2, math.floor(btn:GetWidth() * 0.06))

    for _, s in ipairs({ ov.eT, ov.eB, ov.eL, ov.eR }) do
        s:SetVertexColor(col.r, col.g, col.b, 1)
    end

    if shape == "circle" then
        ShowCircleRezOverlay(ov, col)
    else
        ShowSquareRezOverlay(ov, bw)
    end

    ov:Show()
end

-- Shows or hides the rez overlay on a single button based on its unit's current rez state.
function SUB:UpdateRezHighlight(btn)
    local state = self.db.profile.rezAlert
        and IsResurrectionButton(btn)
        and GetButtonRezState(self, btn)
    if not state then
        HideRezOverlay(btn)
        return
    end

    local ov = GetOrCreateRezOverlay(btn)
    ConfigureRezOverlay(self, btn, ov, state)
end

-- Refreshes rez overlays on all buttons (shared + individual) for the given unit.
function SUB:UpdateRezHighlightsForUnit(unit)
    local bd = self.bars[unit]
    if not bd then return end
    for _, btn in ipairs(bd.sharedButtons) do
        self:UpdateRezHighlight(btn)
    end
    for _, btn in ipairs(bd.individualButtons) do
        self:UpdateRezHighlight(btn)
    end
end

-- Refreshes rez overlays for every tracked unit.
function SUB:UpdateAllRezHighlights()
    for _, unit in ipairs(UNITS) do
        self:UpdateRezHighlightsForUnit(unit)
    end
end

-- Called on UNIT_AURA; updates rez overlays when auras change (e.g. incoming rez aura added/removed).
function SUB:UpdateRezOnUnitAura(unit)
    if not self.db.profile.rezAlert then return end
    self:UpdateRezHighlightsForUnit(unit)
end

-- Core logic for UNIT_FLAGS: re-evaluates rez state when unit flags change (dead/ghost transitions).
function SUB:HandleUnitFlags(unit)
    if not self.db.profile.rezAlert then return end
    if not self.bars[unit] then return end
    self:UpdateRezHighlightsForUnit(unit)
end

-- Called on UNIT_FLAGS; delegates to HandleUnitFlags.
function SUB:OnUnitFlags(event, unit)
    self:HandleUnitFlags(unit)
end

-- Combat log sub-events that carry an active rez cast state change.
local REZ_COMBAT_LOG_EVENTS = {
    SPELL_CAST_START       = true,
    SPELL_CAST_SUCCESS     = true,
    SPELL_CAST_FAILED      = true,
    SPELL_CAST_INTERRUPTED = true,
}

-- Core logic for COMBAT_LOG_EVENT_UNFILTERED: tracks rez casts in rezCastingUnits.
function SUB:HandleCombatLogRez()
    if not self.db.profile.rezAlert then return end

    local _, subEvent, _, _, _, _, _, destGUID, _, _, _, spellID =
        CombatLogGetCurrentEventInfo()

    local unit = REZ_COMBAT_LOG_EVENTS[subEvent]
        and REZ_ID_SPELLS[spellID]
        and GetUnitFromGUID(destGUID)
    if not unit then return end

    rezCastingUnits[unit] = subEvent == "SPELL_CAST_START" or nil
    self:UpdateRezHighlightsForUnit(unit)
end

-- Called on COMBAT_LOG_EVENT_UNFILTERED; delegates to HandleCombatLogRez.
function SUB:OnCombatLogRez()
    self:HandleCombatLogRez()
end

-- Clears stale rezCastingUnits entries (unit alive again or gone) then refreshes all overlays.
function SUB:ResyncRezHighlights()
    for unit in pairs(rezCastingUnits) do
        if not CE.Unit.UnitExists(unit) or not UnitIsDeadOrGhost(unit) then
            rezCastingUnits[unit] = nil
        end
    end
    self:UpdateAllRezHighlights()
end
