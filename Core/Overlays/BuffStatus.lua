-- Core/Overlays/BuffStatus.lua
-- Text overlay: buff status (remaining duration / inactive indicator)
--
-- Shows the remaining buff duration in the button corner when the button's
-- spell is active as a buff on the target. Shows "-" when the buff is inactive.
-- Updated via UNIT_AURA events and a one-second ticker.
-------------------------------------------------------------------------------

local _, SUB_NS     = ...
local SUB           = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local CE            = LibStub("C_Everywhere")
local LSM           = LibStub("LibSharedMedia-3.0")

local UNITS         = SUB_NS.UNITS

local CORNER_OFFSET = {
    TOPLEFT     = { -3, 1 },
    TOPRIGHT    = { 3, 1 },
    BOTTOMLEFT  = { -3, -1 },
    BOTTOMRIGHT = { 3, -1 },
    TOP         = { 0, 1 },
    BOTTOM      = { 0, -1 },
    LEFT        = { -3, 0 },
    RIGHT       = { 3, 0 },
}

-- Returns the spell name for a spell-type button, or nil.
local function GetButtonSpellName(btn)
    if btn._state_type ~= "spell" then return nil end
    local action = btn._state_action
    if not action then return nil end
    local info = CE.Spell.GetSpellInfo(action)
    return info and info.name
end

-- Spell names that have been seen at least once as a player buff.
-- Filled at runtime; only then do we show "-" when the buff is inactive.
local knownBuffSpells = {}

-- Wires knownBuffSpells to the persistent global DB table.
-- Must be called from OnInitialize after self.db is set.
function SUB:InitBuffSpells()
    knownBuffSpells = self.db.global.buffSpells
end

-- Scans helpful auras on `unit` for a player-cast buff with `spellName`.
local function ScanPlayerBuff(unit, spellName)
    for i = 1, 40 do
        local name, _, _, _, duration, expirationTime, source = CE.Unit.UnitAura(unit, i, "HELPFUL")
        if not name then break end
        if name == spellName and source == "player" then
            knownBuffSpells[spellName] = true
            return expirationTime, duration
        end
    end
end

-- Returns (expirationTime, duration) of `spellName` on `unit`, or nil.
local function FindPlayerBuffOnUnit(unit, spellName)
    if not unit or not CE.Unit.UnitExists(unit) then return nil end
    return ScanPlayerBuff(unit, spellName)
end

local BUFF_TIME_FORMATS = {
    { min = 3600, div = 3600, suffix = "h" },
    { min = 60,   div = 60,   suffix = "m" },
    { min = 0,    div = 1,    suffix = "s" },
}

-- Formats a positive remaining buff duration as h/m/s.
local function FormatPositiveBuffTime(remaining)
    for _, fmt in ipairs(BUFF_TIME_FORMATS) do
        if remaining >= fmt.min then
            return math.ceil(remaining / fmt.div) .. fmt.suffix
        end
    end
    return "0"
end

-- Formats any duration with a guard against non-positive values.
local function FormatBuffTime(remaining)
    if remaining <= 0 then return "0" end
    return FormatPositiveBuffTime(remaining)
end

-- Applies corner, offsets, and font settings for the buff status text.
local function ConfigureBuffStatusTextLayout(fs, btn, db)
    local corner   = db.buffStatusCorner or "BOTTOMLEFT"
    local off      = CORNER_OFFSET[corner] or CORNER_OFFSET.BOTTOMLEFT
    local flags    = (db.buffStatusOutline and db.buffStatusOutline ~= "NONE") and db.buffStatusOutline or ""
    local fontPath = LSM:Fetch("font", db.buffStatusFont or "Friz Quadrata TT")
    fs:ClearAllPoints()
    fs:SetPoint(corner, btn, corner, off[1] + (db.buffStatusOffsetX or 0), off[2] + (db.buffStatusOffsetY or 0))
    fs:SetFont(fontPath, db.buffStatusFontSize or 9, flags)
end

-- Sets color and text for the buff status display.
local function SetBuffStatusDisplay(fs, color, text)
    fs:SetTextColor(color.r, color.g, color.b, color.a)
    fs:SetText(text)
end

-- Shows active buff status: '~' for timeless buffs or remaining duration.
local function ShowActiveBuffStatus(btn, fs, db, expirationTime, duration)
    btn.SUB_buffExpiry = expirationTime
    if duration == 0 then
        local c = db.buffStatusColor or { r = 1, g = 1, b = 0, a = 1 }
        SetBuffStatusDisplay(fs, c, "~")
        return
    end

    local remaining = math.max(0, expirationTime - GetTime())
    local threshold = db.buffStatusLowThreshold or 60
    local c = (remaining < threshold)
        and (db.buffStatusLowColor or { r = 1, g = 0, b = 0, a = 1 })
        or (db.buffStatusColor or { r = 1, g = 1, b = 0, a = 1 })
    SetBuffStatusDisplay(fs, c, FormatBuffTime(remaining))
end

-- Shows '-' when the spell is known as a buff but currently inactive.
local function ShowInactiveKnownBuffStatus(btn, fs, db)
    btn.SUB_buffExpiry = nil
    local c = db.buffStatusColor or { r = 1, g = 1, b = 0, a = 1 }
    SetBuffStatusDisplay(fs, c, "-")
end

-- Clears the text when the spell is not known as a buff spell.
local function ShowUnknownBuffStatus(btn, fs)
    btn.SUB_buffExpiry = nil
    fs:SetText("")
end

-- Selects which buff status representation is shown for the current spell.
local function UpdateBuffStatusDisplayForSpell(btn, fs, db, spellName)
    local expirationTime, duration = FindPlayerBuffOnUnit(btn.SUB_unit, spellName)
    if expirationTime then
        ShowActiveBuffStatus(btn, fs, db, expirationTime, duration)
        return
    end
    if knownBuffSpells[spellName] then
        ShowInactiveKnownBuffStatus(btn, fs, db)
        return
    end
    ShowUnknownBuffStatus(btn, fs)
end

-- Returns the spell name for the buff status display, or nil if
-- the feature is disabled, the button is empty, or no name can be resolved.
local function GetBuffSpellForButton(btn, db)
    if not db or not db.showBuffStatus then return nil end
    local btnType = btn._state_type
    if not btnType or btnType == "empty" then return nil end
    return GetButtonSpellName(btn)
end

-- Updates the buff status text overlay on `btn`.
function SUB:UpdateButtonBuffStatus(btn)
    local fs = btn.SUB_buffStatusText
    if not fs then return end
    local db = self.db and self.db.profile
    local spellName = GetBuffSpellForButton(btn, db)
    if not spellName then
        fs:SetText("")
        return
    end
    ConfigureBuffStatusTextLayout(fs, btn, db)
    UpdateBuffStatusDisplayForSpell(btn, fs, db, spellName)
end

-- Updates buff status indicators for all unit bars.
function SUB:UpdateAllBuffStatuses()
    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if bd then
            for _, btn in ipairs(bd.sharedButtons) do
                self:UpdateButtonBuffStatus(btn)
            end
            for _, btn in ipairs(bd.individualButtons) do
                self:UpdateButtonBuffStatus(btn)
            end
        end
    end
end

-- Updates buff status indicators for one unit bar.
function SUB:UpdateBuffStatusesForUnit(unit)
    local bd = self.bars[unit]
    if not bd then return end
    for _, btn in ipairs(bd.sharedButtons) do
        self:UpdateButtonBuffStatus(btn)
    end
    for _, btn in ipairs(bd.individualButtons) do
        self:UpdateButtonBuffStatus(btn)
    end
end
