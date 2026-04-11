-------------------------------------------------------------------------------
-- Core/Dispel.lua
-- Dispel alert system: colored borders on buttons whose spell can dispel an
-- active debuff from the bar target.
--
-- Four opaque border strips replace the semi-transparent IconAlertAnts sprite,
-- so the highlight is always clearly visible (regardless of button icon or
-- Masque skin).  Alternative: circular ring texture mode.
--
-- Spell→debuff-type mapping covers Classic, TBC, Wrath, Cata, and Retail.
-- Name-based lookup (built after SPELLS_CHANGED) handles all spell ranks in
-- Classic without needing to list every rank ID individually.
-------------------------------------------------------------------------------

local _, SUB_NS        = ...
local SUB              = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local CE               = LibStub("C_Everywhere")
local LSM              = LibStub("LibSharedMedia-3.0")

local UNITS            = SUB_NS.UNITS
local DISPEL_ID_TYPES  = SUB_NS.DISPEL_ID_TYPES

-- Maps debuff type names to their color key in the DB profile.
local DEBUFF_COLOR_KEY = {
    Magic   = "dispelAlertColorMagic",
    Curse   = "dispelAlertColorCurse",
    Poison  = "dispelAlertColorPoison",
    Disease = "dispelAlertColorDisease",
}

-- Returns the color table for a dispel alert.
-- Respects the per-debuff-type color setting when enabled.
local function GetDispelColor(db, debuffType)
    if db.dispelAlertTypeColorsEnabled and debuffType then
        local key = DEBUFF_COLOR_KEY[debuffType]
        if key then return db[key] or db.dispelAlertColor end
    end
    return db.dispelAlertColor
end

-- Spell name → { DebuffType = true }.  Built after SPELLS_CHANGED so that
-- all ranks of a multi-rank Classic spell are matched automatically.
local dispelNameTypes = {}

-- Builds the spell-name dispel map from the static spell-ID mapping table.
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

-- Resolves `action` (spell ID or name string) to its dispel type table, or nil.
-- Tries direct ID lookup first; falls back to the name map for multi-rank Classic spells.
local function GetDispelTypesByAction(action)
    local id = tonumber(action)
    if id and DISPEL_ID_TYPES[id] then return DISPEL_ID_TYPES[id] end
    local info = CE.Spell.GetSpellInfo(id or action)
    return info and dispelNameTypes[info.name]
end

-- Returns the dispel type table for the spell on `btn`, or nil.
local function GetButtonDispelTypes(btn)
    if btn._state_type ~= "spell" then return nil end
    local action = btn._state_action
    if not action then return nil end
    return GetDispelTypesByAction(action)
end

-- Returns the first dispel type from the map (for options preview).
local function GetPreviewDispelType(types)
    for t in pairs(types) do
        return t
    end
    return nil
end

-- Iterates up to 40 harmful auras on `unit` and returns the debuff type
-- of the first match whose type is present in `types`, or nil.
local function FindDispellableAura(unit, types)
    for i = 1, 40 do
        local name, _, _, debuffType = CE.Unit.UnitAura(unit, i, "HARMFUL")
        if not name then break end
        if debuffType and types[debuffType] then return debuffType end
    end
end

-- Returns the first dispellable debuff type on `unit`, or nil.
local function GetUnitDispelType(unit, types)
    if not unit or not CE.Unit.UnitExists(unit) then return nil end
    return FindDispellableAura(unit, types)
end

-- Anchors and layers the dispel overlay relative to the button with padding.
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

-- Returns the dispel alert overlay for `btn` (lazily created).
local function GetOrCreateDispelOverlay(btn)
    if btn.SUB_dispelOverlay then return btn.SUB_dispelOverlay end
    local ov = CreateFrame("Frame", nil, btn)
    ov:Hide()

    local function makeStrip()
        local t = ov:CreateTexture(nil, "OVERLAY")
        t:SetTexture([[Interface\Buttons\WHITE8X8]])
        return t
    end
    ov.eT = makeStrip() -- top
    ov.eB = makeStrip() -- bottom
    ov.eL = makeStrip() -- left
    ov.eR = makeStrip() -- right

    -- Circle mode: single pre-rendered ring texture (white ring on transparent
    -- background), colored at runtime via SetVertexColor.
    ov.eRing = ov:CreateTexture(nil, "OVERLAY")
    ov.eRing:SetTexture([[Interface\AddOns\SupportUnitButtons\Textures\circle_ring]])
    ov.eRing:SetAllPoints(ov)
    ov.eRing:Hide()

    -- Animation per texture, not per frame. Frame:SetAlpha() would composite the
    -- entire rectangular frame area (including empty regions) into an offscreen
    -- buffer → visible transparent rectangle over the button icon.
    ov._t = 0
    ov:SetScript("OnUpdate", function(self, elapsed)
        self._t        = self._t + elapsed
        local speed    = SUB.db and SUB.db.profile.dispelAlertPulseSpeed or 2.5
        local alphaMin = SUB.db and SUB.db.profile.dispelAlertAlphaMin or 0.0
        local alphaMax = SUB.db and SUB.db.profile.dispelAlertAlphaMax or 1.0
        -- Smooth cosine oscillation: phase runs 0 → 1 → 0 without dead time.
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

-- Hides the dispel overlay on a button.
local function HideDispelOverlay(btn)
    if btn.SUB_dispelOverlay then
        btn.SUB_dispelOverlay:Hide()
    end
end

-- Renders the circular alert style (ring texture only).
local function ShowCircleOverlay(ov, col)
    ov.eT:Hide()
    ov.eB:Hide()
    ov.eL:Hide()
    ov.eR:Hide()
    ov.eRing:SetVertexColor(col.r, col.g, col.b, 1)
    ov.eRing:Show()
end

-- Renders the square alert style (four border strips).
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

-- Applies visual configuration (padding, color, shape, border width) and shows overlay.
local function ConfigureDispelOverlay(sub, btn, ov, foundType)
    -- dispelAlertPadding: positive = extends beyond button edge,
    -- negative = inset inward.
    local db = sub.db.profile
    local pad = db.dispelAlertPadding
    if pad == nil then pad = 3 end
    PositionDispelOverlay(btn, ov, pad)

    local col = GetDispelColor(db, foundType)
    local shape = db.dispelAlertShape or "square"
    local bwCfg = db.dispelAlertBorderWidth or 0
    local bw = bwCfg > 0 and bwCfg or math.max(2, math.floor(btn:GetWidth() * 0.06))

    -- Color square-mode strips; ring mode is colored in its own branch.
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

-- Resolves the matching dispel type for this button in preview or live mode.
local function ResolveButtonDispelType(sub, btn, types)
    if sub.dispelAlertPreview then
        return GetPreviewDispelType(types)
    end
    return GetUnitDispelType(btn.SUB_unit, types)
end

-- Shows or hides the dispel alert overlay for a single button.
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

-- Updates dispel highlights for all buttons in `buttons` and returns true
-- if any overlay is currently shown.
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

-- Updates dispel highlights for all buttons on `unit`'s bar and
-- updates dispelActiveUnits accordingly.
function SUB:UpdateDispelHighlightsForUnit(unit)
    local bd = self.bars[unit]
    if not bd then return end
    local a = UpdateButtonListAndCheckActive(self, bd.sharedButtons)
    local b = UpdateButtonListAndCheckActive(self, bd.individualButtons)
    self.dispelActiveUnits[unit] = a or b
    return a or b
end

-- Updates all buttons on all bars.
function SUB:UpdateAllDispelHighlights()
    for _, unit in ipairs(UNITS) do
        self:UpdateDispelHighlightsForUnit(unit)
    end
end

-- Event handler: delegates to HandleUnitAura.
function SUB:OnUnitAura(event, unit)
    self:HandleUnitAura(unit)
end

-- Updates dispel highlights and buff status when a unit's auras change.
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
    if self.db.profile.rezAlert then
        self:UpdateRezOnUnitAura(unit)
    end
end

-- Plays the alert sound if enabled and a sound is selected.
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
