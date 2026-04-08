-------------------------------------------------------------------------------
-- Core/Bars.lua
-- Bar and button creation, secure script wrapping
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
-- In WoW Classic, CastSpellByName(name, unit) treats any truthy second
-- argument as a self-cast flag. Therefore we keep type="spell"/"item" for
-- correct LAB display, but swap to type="macro" with a [@unit] conditional
-- in PreClick and restore it in PostClick.
-------------------------------------------------------------------------------

local function WrapButtonForUnitTarget(header, btn)
    header:WrapScript(btn, "PreClick", [[
        -- Block execution if the drag-off modifier is held.
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
        -- Unit-targeted macro swap.
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

    -- Block drag-off when the modifier is not held by setting
    -- LABdisableDragNDrop before LAB's own OnDragStart.
    header:WrapScript(btn, "OnDragStart", [[
        local mod  = self:GetAttribute("SUB_dragModifier") or "SHIFT"
        local held = (mod == "SHIFT" and IsShiftKeyDown())
                  or (mod == "CTRL"  and IsControlKeyDown())
                  or (mod == "ALT"   and IsAltKeyDown())
                  or (mod == "ANY"   and (IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown()))
        if held then
            self:SetAttribute("LABdisableDragNDrop", nil)
        else
            return false  -- block drag without LABdisableDragNDrop (which would also block OnReceiveDrag)
        end
    ]])

    -- LAB's built-in range coloring uses FindSpellBookSlotBySpellID, which does
    -- not exist in WoW Classic. Override IsUnitInRange on the instance so LAB's
    -- range timer uses the Classic API (IsSpellInRange by name).
    -- Pass the spell name instead of the ID: avoids the error-prone
    -- LibSpellRange spellbook slot lookup that can return nil in Classic.
    -- nil from IsSpellInRange means "spell cannot target this unit type"
    -- (e.g. self-only spells on party members) → no range coloring (no fallback to 0).
    btn.IsUnitInRange = function(self, unit)
        if self._state_type == "spell" and unit then
            if CE.Unit.UnitExists(unit) and not CE.Unit.UnitIsConnected(unit) then
                return 0 -- offline = out of range
            end
            local info = CE.Spell.GetSpellInfo(self._state_action)
            local name = info and info.name
            return name and SpellRange.IsSpellInRange(name, unit)
        end
        return nil
    end
end

-------------------------------------------------------------------------------
-- Text-Overlay Attachment
--
-- Creates a child frame as host for button text overlays.
-- As a child frame with a higher FrameLevel it always renders above Masque's
-- HIGHLIGHT-layer hover border on the parent button.
-------------------------------------------------------------------------------

local function GetOrCreateTextOverlay(btn)
    if btn.SUB_textOverlay then return btn.SUB_textOverlay end
    local ov = CreateFrame("Frame", nil, btn)
    ov:SetAllPoints(btn)
    ov:SetFrameLevel(btn:GetFrameLevel() + 10)
    btn.SUB_textOverlay = ov
    return ov
end

-- Attaches a rank text FontString to a button (corner is set on update).
local function AttachRankText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_rankText = fs
end

-- Attaches a cast count FontString to a button.
local function AttachCastCountText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_castCountText = fs
end

-- Attaches a reagent count FontString to a button.
local function AttachReagentCountText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_reagentCountText = fs
end

-- Attaches a buff status FontString to a button.
local function AttachBuffStatusText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_buffStatusText = fs
end

-------------------------------------------------------------------------------
-- Bar Creation
-------------------------------------------------------------------------------

-- Creates bars for all managed units.
function SUB:CreateAllBars()
    for _, unit in ipairs(UNITS) do
        self:CreateBar(unit)
    end
end

-- Creates a complete unit bar with secure header and all buttons.
function SUB:CreateBar(unit)
    local db    = self.db.profile
    local uIdx  = UNIT_INDEX[unit]
    local fn    = "SupportUnitButtonsFrame_" .. unit

    ---------- outer movable frame ----------
    local frame = CreateFrame("Frame", fn, UIParent)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)

    ---------- Drag Handle (sits above all buttons) ----------
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

    -- Drag scripts are set after barData creation (need self-reference)
    handle:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    handle:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local ddb = self.db.profile

        -- SUF mode: snap back to SUF anchor (bars are not freely movable).
        if ddb.positionMode == "suf" then
            self:ApplySUFPositions()
            return
        end

        local sc = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
        -- x/y stored as TOPLEFT offset from UIParent TOPLEFT
        local fx = frame:GetLeft() * sc
        local fy = frame:GetTop() * sc - UIParent:GetHeight()

        if ddb.positionMode == "anchored" then
            -- Back-calculate anchor (position of Bar #0)
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
        btn:SetState(0, "empty", nil) -- initialise "type" attribute so OnReceiveDrag works
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
    -- Restore via RefreshIndividualButtons so the clear+restore logic is shared.
    self:RefreshIndividualButtons(unit)

    self:UpdateBarLayout(unit)
    self:RestoreBarPosition(unit)
end
