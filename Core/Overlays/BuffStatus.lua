-------------------------------------------------------------------------------
-- Core/Overlays/BuffStatus.lua
-- Text-Overlay: Buff-Status (verbleibende Dauer / Inaktiv-Indikator)
--
-- Zeigt die verbleibende Buff-Dauer in der Button-Ecke wenn der Spell des
-- Buttons als Buff auf dem Target aktiv ist.  Zeigt "-" wenn der Buff inaktiv.
-- Wird via UNIT_AURA-Events und einen Sekunden-Ticker aktualisiert.
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

-- Gibt den Spell-Namen für einen spell-type Button zurück, oder nil.
local function GetButtonSpellName(btn)
    if btn._state_type ~= "spell" then return nil end
    local action = btn._state_action
    if not action then return nil end
    local info = CE.Spell.GetSpellInfo(action)
    return info and info.name
end

-- Spell-Namen die mindestens einmal als Player-Buff gesehen wurden.
-- Wird zur Laufzeit befüllt; erst dann zeigen wir "-" wenn der Buff inaktiv ist.
local knownBuffSpells = {}

-- Verdrahtet knownBuffSpells mit der persistenten global-DB-Tabelle.
-- Muss aus OnInitialize aufgerufen werden nachdem self.db gesetzt ist.
function SUB:InitBuffSpells()
    knownBuffSpells = self.db.global.buffSpells
end

-- Durchsucht hilfreiche Auren auf `unit` nach einem Player-Cast-Buff mit `spellName`.
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

-- Gibt (expirationTime, duration) von `spellName` auf `unit` zurück, oder nil.
local function FindPlayerBuffOnUnit(unit, spellName)
    if not unit or not CE.Unit.UnitExists(unit) then return nil end
    return ScanPlayerBuff(unit, spellName)
end

local BUFF_TIME_FORMATS = {
    { min = 3600, div = 3600, suffix = "h" },
    { min = 60,   div = 60,   suffix = "m" },
    { min = 0,    div = 1,    suffix = "s" },
}

-- Formatiert eine positive verbleibende Buff-Dauer in h/m/s.
local function FormatPositiveBuffTime(remaining)
    for _, fmt in ipairs(BUFF_TIME_FORMATS) do
        if remaining >= fmt.min then
            return math.ceil(remaining / fmt.div) .. fmt.suffix
        end
    end
    return "0"
end

-- Formatiert eine beliebige Dauer mit Guard gegen nicht-positive Werte.
local function FormatBuffTime(remaining)
    if remaining <= 0 then return "0" end
    return FormatPositiveBuffTime(remaining)
end

-- Wendet Ecke, Offsets und Font-Einstellungen für den Buff-Status-Text an.
local function ConfigureBuffStatusTextLayout(fs, btn, db)
    local corner   = db.buffStatusCorner or "BOTTOMLEFT"
    local off      = CORNER_OFFSET[corner] or CORNER_OFFSET.BOTTOMLEFT
    local flags    = (db.buffStatusOutline and db.buffStatusOutline ~= "NONE") and db.buffStatusOutline or ""
    local fontPath = LSM:Fetch("font", db.buffStatusFont or "Friz Quadrata TT")
    fs:ClearAllPoints()
    fs:SetPoint(corner, btn, corner, off[1] + (db.buffStatusOffsetX or 0), off[2] + (db.buffStatusOffsetY or 0))
    fs:SetFont(fontPath, db.buffStatusFontSize or 9, flags)
end

-- Setzt Farbe und Text für die Buff-Status-Ausgabe.
local function SetBuffStatusDisplay(fs, color, text)
    fs:SetTextColor(color.r, color.g, color.b, color.a)
    fs:SetText(text)
end

-- Zeigt aktiven Buff-Status: '~' für zeitlose Buffs oder verbleibende Dauer.
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

-- Zeigt '-' wenn der Spell als Buff bekannt ist aber aktuell inaktiv.
local function ShowInactiveKnownBuffStatus(btn, fs, db)
    btn.SUB_buffExpiry = nil
    local c = db.buffStatusColor or { r = 1, g = 1, b = 0, a = 1 }
    SetBuffStatusDisplay(fs, c, "-")
end

-- Löscht den Text wenn der Spell nicht als Buff-Spell bekannt ist.
local function ShowUnknownBuffStatus(btn, fs)
    btn.SUB_buffExpiry = nil
    fs:SetText("")
end

-- Wählt welche Buff-Status-Darstellung für den aktuellen Spell angezeigt wird.
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

-- Gibt den Spell-Namen für die Buff-Status-Anzeige zurück, oder nil wenn
-- die Funktion deaktiviert ist, der Button leer ist oder kein Name aufgelöst werden kann.
local function GetBuffSpellForButton(btn, db)
    if not db or not db.showBuffStatus then return nil end
    local btnType = btn._state_type
    if not btnType or btnType == "empty" then return nil end
    return GetButtonSpellName(btn)
end

-- Aktualisiert den Buff-Status-Text-Overlay auf `btn`.
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

-- Aktualisiert Buff-Status-Indikatoren für alle Unit-Bars.
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

-- Aktualisiert Buff-Status-Indikatoren für eine Unit-Bar.
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
