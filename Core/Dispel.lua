-------------------------------------------------------------------------------
-- Core/Dispel.lua
-- Dispel-Alert-System: farbige Rahmen auf Buttons deren Spell einen aktiven
-- Debuff des Bar-Targets dispellen kann.
--
-- Vier opake Rand-Streifen ersetzen den semi-transparenten IconAlertAnts-Sprite,
-- damit der Highlight immer klar sichtbar ist (unabhängig vom Button-Icon oder
-- Masque-Skin).  Alternativ: kreisförmiger Ring-Texture-Modus.
--
-- Spell→Debuff-Typ-Mapping deckt Classic, TBC, Wrath, Cata und Retail ab.
-- Name-basiertes Lookup (erstellt nach SPELLS_CHANGED) behandelt alle Spellränge
-- in Classic ohne jeden Rang-ID einzeln auflisten zu müssen.
-------------------------------------------------------------------------------

local _, SUB_NS = ...
local SUB = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local CE  = LibStub("C_Everywhere")
local LSM = LibStub("LibSharedMedia-3.0")

local UNITS          = SUB_NS.UNITS
local DISPEL_ID_TYPES = SUB_NS.DISPEL_ID_TYPES

-- Mappt Debuff-Typ-Namen auf ihren Farb-Key im DB-Profil.
local DEBUFF_COLOR_KEY = {
    Magic   = "dispelAlertColorMagic",
    Curse   = "dispelAlertColorCurse",
    Poison  = "dispelAlertColorPoison",
    Disease = "dispelAlertColorDisease",
}

-- Gibt die Farb-Table für einen Dispel-Alert zurück.
-- Respektiert die Per-Debuff-Typ-Farbeinstellung wenn aktiviert.
local function GetDispelColor(db, debuffType)
    if db.dispelAlertTypeColorsEnabled and debuffType then
        local key = DEBUFF_COLOR_KEY[debuffType]
        if key then return db[key] or db.dispelAlertColor end
    end
    return db.dispelAlertColor
end

-- Spell-Name → { DebuffType = true }.  Wird nach SPELLS_CHANGED aufgebaut,
-- damit alle Ränge eines Multi-Rang-Classic-Spells automatisch matchen.
local dispelNameTypes = {}

-- Baut die Spell-Name-Dispel-Map aus der statischen Spell-ID-Mapping-Tabelle.
function SUB:BuildDispelNameTypes()
    for id, types in pairs(DISPEL_ID_TYPES) do
        local info = CE.Spell.GetSpellInfo(id)
        local name = info and info.name
        if name then
            local t = dispelNameTypes[name] or {}
            for k, v in pairs(types) do t[k] = v end
            dispelNameTypes[name] = t
        end
    end
end

-- Löst `action` (Spell-ID oder Name-String) auf seine Dispel-Typ-Table auf, oder nil.
-- Versucht zuerst direktes ID-Lookup; fällt auf Name-Map zurück für Multi-Rang-Classic-Spells.
local function GetDispelTypesByAction(action)
    local id = tonumber(action)
    if id and DISPEL_ID_TYPES[id] then return DISPEL_ID_TYPES[id] end
    local info = CE.Spell.GetSpellInfo(id or action)
    return info and dispelNameTypes[info.name]
end

-- Gibt die Dispel-Typ-Table für den Spell auf `btn` zurück, oder nil.
local function GetButtonDispelTypes(btn)
    if btn._state_type ~= "spell" then return nil end
    local action = btn._state_action
    if not action then return nil end
    return GetDispelTypesByAction(action)
end

-- Gibt den ersten Dispel-Typ aus der Map zurück (für Options-Preview).
local function GetPreviewDispelType(types)
    for t in pairs(types) do
        return t
    end
    return nil
end

-- Iteriert bis zu 40 schädliche Auren auf `unit` und gibt den Debuff-Typ
-- des ersten Treffers zurück dessen Typ in `types` vorhanden ist, oder nil.
local function FindDispellableAura(unit, types)
    for i = 1, 40 do
        local name, _, _, debuffType = CE.Unit.UnitAura(unit, i, "HARMFUL")
        if not name then break end
        if debuffType and types[debuffType] then return debuffType end
    end
end

-- Gibt den ersten dispelbaren Debuff-Typ auf `unit` zurück, oder nil.
local function GetUnitDispelType(unit, types)
    if not unit or not CE.Unit.UnitExists(unit) then return nil end
    return FindDispellableAura(unit, types)
end

-- Ankert und layert das Dispel-Overlay relativ zum Button mit Padding.
local function PositionDispelOverlay(btn, ov, pad)
    local baseLevel = btn:GetFrameLevel()
    if btn.SUB_textOverlay then
        btn.SUB_textOverlay:SetFrameLevel(baseLevel + 10)
    end
    ov:SetFrameLevel(baseLevel + 7)
    ov:ClearAllPoints()
    ov:SetPoint("TOPLEFT", btn, "TOPLEFT", -pad, pad)
    ov:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", pad, -pad)
end

-- Gibt das Dispel-Alert-Overlay für `btn` zurück (lazy erstellt).
local function GetOrCreateDispelOverlay(btn)
    if btn.SUB_dispelOverlay then return btn.SUB_dispelOverlay end
    local ov = CreateFrame("Frame", nil, btn)
    ov:Hide()

    local function makeStrip()
        local t = ov:CreateTexture(nil, "OVERLAY")
        t:SetTexture([[Interface\Buttons\WHITE8X8]])
        return t
    end
    ov.eT = makeStrip() -- oben
    ov.eB = makeStrip() -- unten
    ov.eL = makeStrip() -- links
    ov.eR = makeStrip() -- rechts

    -- Kreis-Modus: einzelne vorgerenderte Ring-Texture (weißer Ring auf transparentem
    -- Hintergrund), bei Runtime via SetVertexColor eingefärbt.
    ov.eRing = ov:CreateTexture(nil, "OVERLAY")
    ov.eRing:SetTexture([[Interface\AddOns\SupportUnitButtons\Textures\circle_ring]])
    ov.eRing:SetAllPoints(ov)
    ov.eRing:Hide()

    -- Animation pro Texture, nicht pro Frame. Frame:SetAlpha() würde den gesamten
    -- rechteckigen Frame-Bereich (inkl. leere Bereiche) in einen Offscreen-Buffer
    -- compositen → sichtbares transparentes Rechteck über dem Button-Icon.
    ov._t = 0
    ov:SetScript("OnUpdate", function(self, elapsed)
        self._t        = self._t + elapsed
        local speed    = SUB.db and SUB.db.profile.dispelAlertPulseSpeed or 2.5
        local alphaMin = SUB.db and SUB.db.profile.dispelAlertAlphaMin or 0.0
        local alphaMax = SUB.db and SUB.db.profile.dispelAlertAlphaMax or 1.0
        -- Glatte Kosinus-Oszillation: Phase läuft 0 → 1 → 0 ohne Totzeit.
        local phase    = (1 - math.cos(self._t * math.pi * speed)) / 2
        local a        = alphaMin + (alphaMax - alphaMin) * phase
        self.eT:SetAlpha(a)
        self.eB:SetAlpha(a)
        self.eL:SetAlpha(a)
        self.eR:SetAlpha(a)
        self.eRing:SetAlpha(a)
    end)

    btn.SUB_dispelOverlay = ov
    return ov
end

-- Versteckt das Dispel-Overlay auf einem Button.
local function HideDispelOverlay(btn)
    if btn.SUB_dispelOverlay then
        btn.SUB_dispelOverlay:Hide()
    end
end

-- Rendert den kreisförmigen Alert-Stil (nur Ring-Texture).
local function ShowCircleOverlay(ov, col)
    ov.eT:Hide()
    ov.eB:Hide()
    ov.eL:Hide()
    ov.eR:Hide()
    ov.eRing:SetVertexColor(col.r, col.g, col.b, 1)
    ov.eRing:Show()
end

-- Rendert den quadratischen Alert-Stil (vier Rand-Streifen).
local function ShowSquareOverlay(ov, bw)
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

-- Wendet visuelle Konfiguration (Padding, Farbe, Form, Rahmenstärke) an und zeigt Overlay.
local function ConfigureDispelOverlay(sub, btn, ov, foundType)
    -- dispelAlertPadding: positiv = erweitert über den Button-Rand hinaus,
    -- negativ = nach innen versetzt.
    local db = sub.db.profile
    local pad = db.dispelAlertPadding
    if pad == nil then pad = 3 end
    PositionDispelOverlay(btn, ov, pad)

    local col = GetDispelColor(db, foundType)
    local shape = db.dispelAlertShape or "square"
    local bwCfg = db.dispelAlertBorderWidth or 0
    local bw = bwCfg > 0 and bwCfg or math.max(2, math.floor(btn:GetWidth() * 0.06))

    -- Quadrat-Modus Streifen einfärben; Ring-Modus wird in seinem Zweig eingefärbt.
    for _, s in ipairs({ ov.eT, ov.eB, ov.eL, ov.eR }) do
        s:SetVertexColor(col.r, col.g, col.b, 1)
    end

    if shape == "circle" then
        ShowCircleOverlay(ov, col)
    else
        ShowSquareOverlay(ov, bw)
    end

    ov:Show()
end

-- Löst den passenden Dispel-Typ für diesen Button im Preview- oder Live-Modus auf.
local function ResolveButtonDispelType(sub, btn, types)
    if sub.dispelAlertPreview then
        return GetPreviewDispelType(types)
    end
    return GetUnitDispelType(btn.SUB_unit, types)
end

-- Zeigt oder versteckt das Dispel-Alert-Overlay für einen einzelnen Button.
function SUB:UpdateDispelHighlight(btn)
    if not self.db.profile.dispelAlert then
        HideDispelOverlay(btn)
        return
    end

    local types = GetButtonDispelTypes(btn)
    if not types then
        HideDispelOverlay(btn)
        return
    end

    local foundType = ResolveButtonDispelType(self, btn, types)
    if not foundType then
        HideDispelOverlay(btn)
        return
    end

    local ov = GetOrCreateDispelOverlay(btn)
    ConfigureDispelOverlay(self, btn, ov, foundType)
end

-- Aktualisiert Dispel-Highlights für alle Buttons in `buttons` und gibt true zurück
-- wenn irgendein Overlay aktuell angezeigt wird.
local function UpdateButtonListAndCheckActive(self, buttons)
    local anyActive = false
    for _, btn in ipairs(buttons) do
        self:UpdateDispelHighlight(btn)
        if btn.SUB_dispelOverlay and btn.SUB_dispelOverlay:IsShown() then
            anyActive = true
        end
    end
    return anyActive
end

-- Aktualisiert Dispel-Highlights für alle Buttons der Bar von `unit` und
-- aktualisiert dispelActiveUnits entsprechend.
function SUB:UpdateDispelHighlightsForUnit(unit)
    local bd = self.bars[unit]
    if not bd then return end
    local a = UpdateButtonListAndCheckActive(self, bd.sharedButtons)
    local b = UpdateButtonListAndCheckActive(self, bd.individualButtons)
    self.dispelActiveUnits[unit] = a or b
    return a or b
end

-- Aktualisiert alle Buttons auf allen Bars.
function SUB:UpdateAllDispelHighlights()
    for _, unit in ipairs(UNITS) do
        self:UpdateDispelHighlightsForUnit(unit)
    end
end

-- Event-Handler: delegiert an HandleUnitAura.
function SUB:OnUnitAura(event, unit)
    self:HandleUnitAura(unit)
end

-- Aktualisiert Dispel-Highlights und Buff-Status wenn sich Auren einer Unit ändern.
function SUB:HandleUnitAura(unit)
    if self.db.profile.dispelAlert then
        local wasActive = self.dispelActiveUnits[unit]
        self:UpdateDispelHighlightsForUnit(unit)
        if self.dispelActiveUnits[unit] and not wasActive then
            self:PlayDispelAlertSound()
        end
    end
    if self.db.profile.showBuffStatus then
        self:UpdateBuffStatusesForUnit(unit)
    end
end

-- Spielt den Warn-Sound wenn aktiviert und ein Sound ausgewählt ist.
function SUB:PlayDispelAlertSound()
    local db = self.db.profile
    if not db.dispelAlertSoundEnabled then return end
    local soundName = db.dispelAlertSound
    if not soundName then return end
    local soundFile = LSM:Fetch("sound", soundName)
    if soundFile then
        PlaySoundFile(soundFile, db.dispelAlertSoundChannel or "Master")
    end
end
