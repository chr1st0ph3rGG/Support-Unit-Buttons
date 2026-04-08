-- Core/Layout.lua
-- Bar layout, label visibility, lock/drag modifier
-------------------------------------------------------------------------------

local _, SUB_NS      = ...
local SUB            = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local CE             = LibStub("C_Everywhere")

local UNITS          = SUB_NS.UNITS
local MAX_SHARED     = SUB_NS.MAX_SHARED
local MAX_INDIVIDUAL = SUB_NS.MAX_INDIVIDUAL
local SEPARATOR_GAP  = SUB_NS.SEPARATOR_GAP
local HANDLE_HEIGHT  = SUB_NS.HANDLE_HEIGHT

-- Button Size
-------------------------------------------------------------------------------

-- Sets the size of a button. NormalTexture (empty slot frame) is kept at 1:1
-- so it does not overlap adjacent buttons.
function SUB:SizeButton(btn, size)
    btn:SetSize(size, size)
    local nt = btn:GetNormalTexture()
    if nt then
        nt:ClearAllPoints()
        nt:SetPoint("CENTER", btn, "CENTER", 0, 0)
        nt:SetSize(size, size)
    end
end

-------------------------------------------------------------------------------
-- Layout
-------------------------------------------------------------------------------

-- Computes the total width of a bar from the button settings.
function SUB:GetBarTotalWidth()
    local db = self.db.profile
    local sz = db.buttonSize
    local sp = db.buttonSpacing
    local sN = db.sharedCount
    local iN = db.individualCount
    local w  = 0
    if sN > 0 then w = sN * (sz + sp) - sp end
    if iN > 0 then
        if w > 0 then w = w + (db.separatorGap or SEPARATOR_GAP) end
        w = w + iN * (sz + sp) - sp
    end
    return math.max(w, sz)
end

-- Repositions and scales all buttons on a unit bar.
function SUB:UpdateBarLayout(unit)
    local db      = self.db.profile
    local barData = self.bars[unit]
    if not barData then return end

    local sz = db.buttonSize
    local sp = db.buttonSpacing
    local sN = db.sharedCount
    local iN = db.individualCount

    -- Shared Buttons
    for i = 1, MAX_SHARED do
        local btn = barData.sharedButtons[i]
        if btn then
            self:SizeButton(btn, sz)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", barData.frame, "TOPLEFT",
                (i - 1) * (sz + sp), -HANDLE_HEIGHT)
            btn:SetShown(i <= sN)
        end
    end

    -- Individual buttons (with separator spacing after the shared section)
    -- sN shared buttons end at: (sN-1)*(sz+sp)+sz = sN*(sz+sp)-sp
    local sepX = (sN > 0) and (sN * (sz + sp) - sp + (db.separatorGap or SEPARATOR_GAP)) or 0
    for i = 1, MAX_INDIVIDUAL do
        local btn = barData.individualButtons[i]
        if btn then
            self:SizeButton(btn, sz)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", barData.frame, "TOPLEFT",
                sepX + (i - 1) * (sz + sp), -HANDLE_HEIGHT)
            btn:SetShown(i <= iN)
        end
    end

    local totalW = self:GetBarTotalWidth()
    barData.frame:SetSize(totalW, HANDLE_HEIGHT + sz)
    self:UpdateLabelVisibility(unit)
end

-- Reapplies layout sizes and positions to all bars.
function SUB:UpdateAllLayouts()
    for _, unit in ipairs(UNITS) do
        self:UpdateBarLayout(unit)
    end
    -- Reapply positions when the bar size changes.
    if self.db.profile.positionMode == "anchored" then
        self:ApplyAnchoredPositions()
    elseif self.db.profile.positionMode == "suf" then
        self:ApplySUFPositions()
    end
end

-------------------------------------------------------------------------------
-- Label Visibility
-- Labels are shown when: bar unlocked (always) OR showLabels option enabled
-------------------------------------------------------------------------------

function SUB:UpdateLabelVisibility(unit)
    local barData = self.bars[unit]
    if not barData then return end
    local db   = self.db.profile
    local show = (not db.locked) or db.showLabels
    barData.label:SetShown(show)
    if show then
        barData.label:SetText(CE.Unit.UnitName(unit) or unit)
    end
end

-- Updates label visibility and text for all bars.
function SUB:UpdateAllLabelVisibility()
    for _, unit in ipairs(UNITS) do
        self:UpdateLabelVisibility(unit)
    end
end

-- Empty Buttons
-------------------------------------------------------------------------------

-- Applies the "show empty slots" setting to all buttons.
function SUB:ApplyShowEmptyButtonsOption()
    if CE.Combat.InCombatLockdown() then
        self.emptyButtonsDirty = true
        return
    end

    local showEmpty = self.db and self.db.profile and self.db.profile.showEmptyButtons
    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if bd then
            for _, btn in ipairs(bd.sharedButtons) do
                local cfg = btn.config or {}
                cfg.showGrid = showEmpty and true or false
                btn:UpdateConfig(cfg)
            end
            for _, btn in ipairs(bd.individualButtons) do
                local cfg = btn.config or {}
                cfg.showGrid = showEmpty and true or false
                btn:UpdateConfig(cfg)
            end
        end
    end
end

-- Stores and applies the "show empty slots" option.
function SUB:SetShowEmptyButtons(show)
    self.db.profile.showEmptyButtons = show and true or false
    self:ApplyShowEmptyButtonsOption()
end

-- Drag Modifier
-------------------------------------------------------------------------------

local DRAG_MODIFIER_CHECK = {
    ANY   = function() return CE.Input.IsShiftKeyDown() or CE.Input.IsControlKeyDown() or CE.Input.IsAltKeyDown() end,
    SHIFT = function() return CE.Input.IsShiftKeyDown() end,
    CTRL  = function() return CE.Input.IsControlKeyDown() end,
    ALT   = function() return CE.Input.IsAltKeyDown() end,
}

-- Sets the modifier key for drag-off on all buttons.
function SUB:SetDragModifier(mod)
    self.db.profile.dragOffModifier = mod
    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if bd then
            for _, btn in ipairs(bd.sharedButtons) do
                btn:SetAttribute("SUB_dragModifier", mod)
            end
            for _, btn in ipairs(bd.individualButtons) do
                btn:SetAttribute("SUB_dragModifier", mod)
            end
        end
    end
end

-- Returns true if the configured drag modifier is currently held.
function SUB:IsDragModifierHeld()
    local check = DRAG_MODIFIER_CHECK[self.db.profile.dragOffModifier]
    return check and check() or false
end

-------------------------------------------------------------------------------
-- Lock / Unlock
-------------------------------------------------------------------------------

function SUB:SetLocked(locked)
    self.db.profile.locked = locked
    local canDrag = not locked and self.db.profile.positionMode ~= "suf"
    for _, unit in ipairs(UNITS) do
        local barData = self.bars[unit]
        if barData then
            barData.handle:EnableMouse(canDrag)
            barData.handleBg:SetShown(not locked)
            self:UpdateLabelVisibility(unit)
        end
    end
end
