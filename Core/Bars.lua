-------------------------------------------------------------------------------
-- Core/Bars.lua
-- Bar- und Button-Erstellung, Secure-Script-Wrapping
-------------------------------------------------------------------------------

local _, SUB_NS      = ...
local SUB            = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local LAB            = LibStub("LibActionButton-1.0")
local CE             = LibStub("C_Everywhere")
local SpellRange     = LibStub("SpellRange-1.0")

local MAX_SHARED     = SUB_NS.MAX_SHARED
local MAX_INDIVIDUAL = SUB_NS.MAX_INDIVIDUAL
local UNIT_INDEX     = SUB_NS.UNIT_INDEX
local HANDLE_HEIGHT  = SUB_NS.HANDLE_HEIGHT
local UNITS          = SUB_NS.UNITS

-------------------------------------------------------------------------------
-- Secure Script Wrapping
--
-- In WoW Classic behandelt CastSpellByName(name, unit) jedes truthy zweite
-- Argument als Self-Cast-Flag. Deshalb behalten wir type="spell"/"item" für
-- korrektes LAB-Display, tauschen aber in PreClick kurz auf type="macro" mit
-- [@unit]-Conditional um, und stellen in PostClick wieder her.
-------------------------------------------------------------------------------

local function WrapButtonForUnitTarget(header, btn)
    header:WrapScript(btn, "PreClick", [[
        -- Ausführung blockieren wenn der Drag-Off-Modifier gehalten wird.
        local mod  = self:GetAttribute("SUB_dragModifier") or "SHIFT"
        local held = (mod == "SHIFT" and IsShiftKeyDown())
                  or (mod == "CTRL"  and IsControlKeyDown())
                  or (mod == "ALT"   and IsAltKeyDown())
                  or (mod == "ANY"   and (IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown()))
        if held then
            self:SetAttribute("SUB_blocked", self:GetAttribute("type"))
            self:SetAttribute("type", "empty")
            return
        end
        -- Unit-targeted Macro-Tausch.
        local macro = self:GetAttribute("SUB_macro")
        if macro then
            self:SetAttribute("SUB_savedtype", self:GetAttribute("type"))
            self:SetAttribute("type", "macro")
            self:SetAttribute("macrotext", macro)
        end
    ]])
    header:WrapScript(btn, "PostClick", [[
        local blocked = self:GetAttribute("SUB_blocked")
        if blocked then
            self:SetAttribute("type", blocked)
            self:SetAttribute("SUB_blocked", nil)
            return
        end
        local saved = self:GetAttribute("SUB_savedtype")
        if saved then
            self:SetAttribute("type", saved)
            self:SetAttribute("SUB_savedtype", nil)
        end
    ]])

    -- Drag-Off blockieren wenn der Modifier nicht gehalten wird, indem
    -- LABdisableDragNDrop vor LABs eigenem OnDragStart gesetzt wird.
    header:WrapScript(btn, "OnDragStart", [[
        local mod  = self:GetAttribute("SUB_dragModifier") or "SHIFT"
        local held = (mod == "SHIFT" and IsShiftKeyDown())
                  or (mod == "CTRL"  and IsControlKeyDown())
                  or (mod == "ALT"   and IsAltKeyDown())
                  or (mod == "ANY"   and (IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown()))
        if held then
            self:SetAttribute("LABdisableDragNDrop", nil)
        else
            return false  -- Drag blockieren ohne LABdisableDragNDrop (das auch OnReceiveDrag blockiert)
        end
    ]])

    -- LABs eingebautes Range-Coloring nutzt FindSpellBookSlotBySpellID, das in
    -- WoW Classic nicht existiert. IsUnitInRange auf der Instanz überschreiben,
    -- damit LABs Range-Timer die Classic-API (IsSpellInRange by Name) verwendet.
    btn.IsUnitInRange = function(self, unit)
        if self._state_type == "spell" and unit then
            if CE.Unit.UnitExists(unit) and not CE.Unit.UnitIsConnected(unit) then
                return 0 -- offline = außer Reichweite
            end
            local range = SpellRange.IsSpellInRange(self._state_action, unit)
            if range == nil and SpellRange.SpellHasRange(self._state_action) and CE.Unit.UnitExists(unit) then
                range = 0 -- zu weit für Messung = außer Reichweite
            end
            return range
        end
        return nil
    end
end

-------------------------------------------------------------------------------
-- Text-Overlay Attachment
--
-- Erzeugt einen Child-Frame als Host für Button-Text-Overlays.
-- Als Child-Frame mit höherem FrameLevel rendert er immer über Masques
-- HIGHLIGHT-Layer-Hover-Rahmen auf dem Parent-Button.
-------------------------------------------------------------------------------

local function GetOrCreateTextOverlay(btn)
    if btn.SUB_textOverlay then return btn.SUB_textOverlay end
    local ov = CreateFrame("Frame", nil, btn)
    ov:SetAllPoints(btn)
    ov:SetFrameLevel(btn:GetFrameLevel() + 10)
    btn.SUB_textOverlay = ov
    return ov
end

-- Fügt einen Rang-Text-FontString an einen Button an (Ecke wird bei Update gesetzt).
local function AttachRankText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_rankText = fs
end

-- Fügt einen Cast-Count-FontString an einen Button an.
local function AttachCastCountText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_castCountText = fs
end

-- Fügt einen Reagent-Count-FontString an einen Button an.
local function AttachReagentCountText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_reagentCountText = fs
end

-- Fügt einen Buff-Status-FontString an einen Button an.
local function AttachBuffStatusText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_buffStatusText = fs
end

-------------------------------------------------------------------------------
-- Bar-Erstellung
-------------------------------------------------------------------------------

-- Erstellt Bars für alle verwalteten Units.
function SUB:CreateAllBars()
    for _, unit in ipairs(UNITS) do
        self:CreateBar(unit)
    end
end

-- Erstellt eine vollständige Unit-Bar mit Secure-Header und allen Buttons.
function SUB:CreateBar(unit)
    local db    = self.db.profile
    local uIdx  = UNIT_INDEX[unit]
    local fn    = "SupportUnitButtonsFrame_" .. unit

    ---------- äußerer beweglicher Frame ----------
    local frame = CreateFrame("Frame", fn, UIParent)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)

    ---------- Drag Handle (sitzt oben, über allen Buttons) ----------
    local handle = CreateFrame("Frame", fn .. "_Handle", frame)
    handle:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    handle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    handle:SetHeight(HANDLE_HEIGHT)
    handle:EnableMouse(not db.locked and db.positionMode ~= "suf")
    handle:RegisterForDrag("LeftButton")

    local handleBg = handle:CreateTexture(nil, "BACKGROUND")
    handleBg:SetAllPoints()
    handleBg:SetColorTexture(0.15, 0.15, 0.6, 0.8)
    handleBg:SetShown(not db.locked)

    local label = handle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", handle, "LEFT", 4, 0)

    -- Drag-Scripts werden nach barData-Erstellung gesetzt (brauchen Selbstreferenz)
    handle:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    handle:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local ddb = self.db.profile

        -- SUF-Modus: zurück zum SUF-Anker snappen (Bars sind nicht frei ziehbar).
        if ddb.positionMode == "suf" then
            self:ApplySUFPositions()
            return
        end

        local sc = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
        -- x/y gespeichert als TOPLEFT-Offset von UIParent TOPLEFT
        local fx = frame:GetLeft() * sc
        local fy = frame:GetTop() * sc - UIParent:GetHeight()

        if ddb.positionMode == "anchored" then
            -- Anker zurückrechnen (Position von Bar #0)
            local barH = HANDLE_HEIGHT + ddb.buttonSize
            local barW = self:GetBarTotalWidth()
            local gap  = ddb.anchorGap
            local pre  = self:GetVisiblePrecedingCount(unit)
            if ddb.anchorDirection == "vertical" then
                ddb.anchorX = fx
                ddb.anchorY = fy + pre * (barH + gap)
            else
                ddb.anchorX = fx - pre * (barW + gap)
                ddb.anchorY = fy
            end
            self:ApplyAnchoredPositions()
        else
            ddb.bars[unit].x = fx
            ddb.bars[unit].y = fy
        end
    end)

    ---------- Secure Header ----------
    local header = CreateFrame("Frame", fn .. "_Header", frame,
        "SecureHandlerStateTemplate")
    header:SetAllPoints(frame)
    header:SetAttribute("unit", unit)

    local barData = {
        frame             = frame,
        header            = header,
        handle            = handle,
        handleBg          = handleBg,
        label             = label,
        unit              = unit,
        sharedButtons     = {},
        individualButtons = {},
    }
    self.bars[unit] = barData

    ---------- Buttons ----------
    local base = uIdx * (MAX_SHARED + MAX_INDIVIDUAL)

    local dragMod = self.db.profile.dragOffModifier

    for i = 1, MAX_SHARED do
        local btn = LAB:CreateButton(base + i, fn .. "_S" .. i, header, nil)
        btn:SetState(0, "empty", nil) -- "type"-Attribut initialisieren damit OnReceiveDrag funktioniert
        btn:SetAttribute("unit", unit)
        btn:SetAttribute("SUB_dragModifier", dragMod)
        btn.SUB_unit    = unit
        btn.SUB_section = "shared"
        btn.SUB_index   = i
        WrapButtonForUnitTarget(header, btn)
        AttachRankText(btn)
        AttachReagentCountText(btn)
        AttachCastCountText(btn)
        AttachBuffStatusText(btn)
        self:RegisterMasqueButton(btn)
        barData.sharedButtons[i] = btn
        self:RestoreSharedButton(unit, btn, i)
    end

    for i = 1, MAX_INDIVIDUAL do
        local btn = LAB:CreateButton(base + MAX_SHARED + i, fn .. "_I" .. i, header, nil)
        btn:SetState(0, "empty", nil)
        btn:SetAttribute("unit", unit)
        btn:SetAttribute("SUB_dragModifier", dragMod)
        btn.SUB_unit    = unit
        btn.SUB_section = "individual"
        btn.SUB_index   = i
        WrapButtonForUnitTarget(header, btn)
        AttachRankText(btn)
        AttachReagentCountText(btn)
        AttachCastCountText(btn)
        AttachBuffStatusText(btn)
        self:RegisterMasqueButton(btn)
        barData.individualButtons[i] = btn
    end
    -- Restore via RefreshIndividualButtons damit die Clear+Restore-Logik geteilt wird.
    self:RefreshIndividualButtons(unit)

    self:UpdateBarLayout(unit)
    self:RestoreBarPosition(unit)
end
