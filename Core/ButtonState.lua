-- Core/ButtonState.lua
-- Button state management, roster visibility, event glue (bag/power)
-------------------------------------------------------------------------------

local _, SUB_NS      = ...
local SUB            = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local CE             = LibStub("C_Everywhere")

local UNITS          = SUB_NS.UNITS
local UNIT_INDEX     = SUB_NS.UNIT_INDEX
local MAX_SHARED     = SUB_NS.MAX_SHARED
local MAX_INDIVIDUAL = SUB_NS.MAX_INDIVIDUAL

-- Iterator Helper
-------------------------------------------------------------------------------

-- Calls fn(btn) for each button (shared + individual) on every active bar.
local function ForEachButton(bars, fn)
    for _, unit in ipairs(UNITS) do
        local bd = bars[unit]
        if bd then
            for _, btn in ipairs(bd.sharedButtons) do fn(btn) end
            for _, btn in ipairs(bd.individualButtons) do fn(btn) end
        end
    end
end

-- Updates the native LAB count for a single spell button.
-- Skipped when the custom overlay already covers it or the button has no action.
local function RefreshNativeLABCount(btn)
    if btn._state_type ~= "spell" or btn.SUB_reagentCountHidden then return end
    if btn.Count and btn:HasAction() then
        btn.Count:SetText(btn:GetDisplayCount())
    end
end

-------------------------------------------------------------------------------
-- Overlay-Clearing
-------------------------------------------------------------------------------

local function ClearTextFrame(fs)
    if fs then fs:SetText("") end
end

local function ClearButtonOverlays(self, btn)
    btn:SetAttribute("SUB_macro", nil)
    ClearTextFrame(btn.SUB_rankText)
    ClearTextFrame(btn.SUB_reagentCountText)
    self:RestoreNativeCount(btn)
    ClearTextFrame(btn.SUB_castCountText)
    ClearTextFrame(btn.SUB_buffStatusText)
end

-- Clears all text overlays and metadata when a button slot becomes empty.
local function ClearButtonState(self, btn)
    ClearButtonOverlays(self, btn)
    self:UpdateDispelHighlight(btn)
    self:UpdateRezHighlight(btn)
end

-------------------------------------------------------------------------------
-- Macro-Attribute
-------------------------------------------------------------------------------

-- Builds unit-targeted macro text for a spell or item.
-- Returns nil if spell/item info is not yet in the client cache.
local function BuildSpellMacroText(unit, action)
    local info = CE.Spell.GetSpellInfo(action)
    if not info or not info.name then return nil end
    return "/cast [@" .. unit .. "] " .. info.name
end

-- Builds a unit-targeted /use macro for an item action string (item:ID).
local function BuildItemMacroText(unit, action)
    local id = action and tonumber(action:match("item:(%d+)"))
    if not id then return nil end
    local name = CE.Item.GetItemInfo(id)
    if not name then return nil end
    return "/use [@" .. unit .. "] " .. name
end

local MACRO_BUILDERS = {
    spell = BuildSpellMacroText,
    item  = BuildItemMacroText,
}

local function BuildMacroText(unit, btnType, action)
    local builder = MACRO_BUILDERS[btnType]
    if not builder then return nil end
    return builder(unit, action)
end

-- Sets the unit-targeted macro attribute for spell/item buttons, or clears it.
-- The PreClick/PostClick wrap script swaps to this macro for execution,
-- then restores the original type so LAB shows icon/cooldown/tooltip correctly.
local function ApplyMacroAttribute(btn, unit, btnType, action)
    if unit and (btnType == "spell" or btnType == "item") then
        btn:SetAttribute("SUB_macro", BuildMacroText(unit, btnType, action))
    else
        btn:SetAttribute("SUB_macro", nil)
    end
end

-- Save / Restore Button State
-------------------------------------------------------------------------------

-- Returns true if the drop operation would empty the button.
local function IsEmptyButtonState(btnType, action)
    return not btnType or btnType == "empty" or not action
end

-- Returns true if a slot currently stores a non-empty action.
local function SlotHasAssignedAction(slot)
    return slot and slot.btnType and slot.btnType ~= "empty"
end

-- Restores previous contents when drag-off is blocked by modifier settings.
local function RestoreIfDragOffBlocked(sub, btn, isEmpty, slot)
    if isEmpty and SlotHasAssignedAction(slot) and not sub:IsDragModifierHeld() then
        sub:RestoreButtonSilent(btn, slot.btnType, slot.action)
        return true
    end
    return false
end

-- Applies shared-slot storage and syncs the slot to all units.
local function HandleSharedButtonChange(sub, btn, unit, index, btnType, action, isEmpty)
    local slot = sub.db.char.sharedSlots[index] or {}
    if RestoreIfDragOffBlocked(sub, btn, isEmpty, slot) then return end

    slot.btnType = btnType
    slot.action = action
    sub.db.char.sharedSlots[index] = slot
    sub:ApplyButtonState(btn, btnType, action)
    sub:SyncSharedSlot(unit, index, btnType, action)
end

-- Applies per-character slot updates for individual buttons.
local function HandleIndividualButtonChange(sub, btn, unit, index, btnType, action, isEmpty)
    local charName = CE.Unit.UnitName(unit)
    if charName and charName ~= "Unknown" then
        local slots = sub.db.char.memberSlots[charName]
        local slot = slots[index] or {}
        if RestoreIfDragOffBlocked(sub, btn, isEmpty, slot) then return end

        slot.btnType = btnType
        slot.action = action
        slots[index] = slot
    end

    sub:ApplyButtonState(btn, btnType, action)
end

local SECTION_HANDLER = {
    shared     = HandleSharedButtonChange,
    individual = HandleIndividualButtonChange,
}

-- Returns unit, section, index for `btn`, or nil if any is missing.
local function GetButtonContext(btn)
    local unit    = btn.SUB_unit
    local section = btn.SUB_section
    local index   = btn.SUB_index
    if not unit or not section or not index then return nil end
    return unit, section, index
end

-- Callback handler: delegates to HandleButtonContentsChanged.
function SUB:OnButtonContentsChanged(event, btn, state, btnType, action)
    self:HandleButtonContentsChanged(btn, state, btnType, action)
end

-- Dispatches LAB content changes to the matching section handler.
function SUB:HandleButtonContentsChanged(btn, state, btnType, action)
    if self.syncing or tostring(state) ~= "0" then return end
    local unit, section, index = GetButtonContext(btn)
    if not unit then return end
    local handler = SECTION_HANDLER[section]
    if handler then
        handler(self, btn, unit, index, btnType, action, IsEmptyButtonState(btnType, action))
    end
end

-- Clears a shared button to an empty state.
function SUB:ClearSharedButton(btn)
    if CE.Combat.InCombatLockdown() then return end
    btn:SetState(nil, "empty", nil)
    btn:SetAttribute("SUB_macro", nil)
    for _, field in ipairs({ "SUB_rankText", "SUB_reagentCountText", "SUB_castCountText", "SUB_buffStatusText" }) do
        if btn[field] then btn[field]:SetText("") end
    end
    if btn.SUB_reagentCountHidden and btn.Count then
        btn.Count:Show()
        btn.SUB_reagentCountHidden = nil
    end
    self:UpdateDispelHighlight(btn)
    self:UpdateRezHighlight(btn)
end

-- Restores the previous button contents without a callback loop.
function SUB:RestoreButtonSilent(btn, btnType, action)
    self.syncing = true
    self:ApplyButtonState(btn, btnType, action)
    self.syncing = false
    ClearCursor()
end

-- Applies a shared-slot sync update to a target button.
function SUB:SyncSharedSlotButton(btn, isEmpty, btnType, action)
    if isEmpty then
        self:ClearSharedButton(btn)
    else
        self:ApplyButtonState(btn, btnType, action)
    end
end

-- Propagates shared-slot changes from one unit to all other unit bars.
function SUB:SyncSharedSlot(sourceUnit, index, btnType, action)
    if self.syncing then return end
    self.syncing = true
    local isEmpty = not btnType or btnType == "empty" or not action
    for _, unit in ipairs(UNITS) do
        local bd = unit ~= sourceUnit and self.bars[unit]
        local btn = bd and bd.sharedButtons[index]
        if btn then
            self:SyncSharedSlotButton(btn, isEmpty, btnType, action)
        end
    end
    self.syncing = false
end

-- Updates all visual states and attributes for a button with a live action.
function SUB:ApplyButtonState(btn, btnType, action)
    if not btnType or btnType == "empty" or not action then
        ClearButtonState(self, btn)
        return
    end
    if CE.Combat.InCombatLockdown() then return end
    ApplyMacroAttribute(btn, btn.SUB_unit, btnType, action)
    -- Always use the native type so LAB can resolve icon, cooldown, and tooltip.
    btn:SetState(nil, btnType, action)
    self:UpdateButtonRankText(btn, btnType, action)
    self:UpdateButtonReagentCount(btn, btnType, action)
    self:UpdateButtonCastCount(btn, btnType, action)
    self:UpdateDispelHighlight(btn)
    self:UpdateRezHighlight(btn)
    self:UpdateButtonBuffStatus(btn)
end

-- Restores a shared button from saved profile data.
function SUB:RestoreSharedButton(unit, btn, index)
    local slot = self.db.char.sharedSlots[index]
    if slot and slot.btnType then
        self:ApplyButtonState(btn, slot.btnType, slot.action)
    end
end

-- Clears an individual button to an empty state.
local function ClearIndividualButton(btn)
    if CE.Combat.InCombatLockdown() then return end
    btn:SetState(nil, "empty", nil)
end

-- Rebuilds individual buttons for a unit from per-character slot data.
function SUB:RefreshIndividualButtons(unit)
    local barData = self.bars[unit]
    if not barData then return end

    local charName = CE.Unit.UnitName(unit)

    self.syncing = true
    for i = 1, MAX_INDIVIDUAL do
        local btn  = barData.individualButtons[i]
        local slot = charName and charName ~= "Unknown"
            and self.db.char.memberSlots[charName][i]
        if slot and slot.btnType and slot.btnType ~= "empty" and slot.action then
            self:ApplyButtonState(btn, slot.btnType, slot.action)
        else
            ClearIndividualButton(btn)
            ClearButtonOverlays(self, btn)
            self:UpdateDispelHighlight(btn)
        end
    end
    self.syncing = false
end

-- Applies saved slot states to all shared buttons on a bar.
local function ApplySharedSlots(self, bd, sharedSlots)
    for i = 1, MAX_SHARED do
        local slot = sharedSlots[i]
        if slot and slot.btnType then
            self:ApplyButtonState(bd.sharedButtons[i], slot.btnType, slot.action)
        end
    end
end

-- Reapplies all saved button states to every unit bar.
-- Also updates the dispel name map now that the full spell cache is available.
function SUB:ApplyAllButtonStates()
    if CE.Combat.InCombatLockdown() then return end
    self:BuildDispelNameTypes()
    self:BuildRezNameSpells()
    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if not bd then break end
        ApplySharedSlots(self, bd, self.db.char.sharedSlots)
        if unit ~= "player" then
            self:RefreshIndividualButtons(unit)
        end
    end
end

-- Visibility & Roster
-------------------------------------------------------------------------------

function SUB:ShouldShowPlayerBar()
    local db = self.db.profile
    if not db.showPlayer then return false end
    if db.showPlayerOnlyInParty then return CE.Party.IsInGroup() and true or false end
    return true
end

-- Event handler: delegates to ApplyDeferredUpdates.
function SUB:OnCombatEnd()
    self:ApplyDeferredUpdates()
end

-- Applies deferred updates after combat lockdown ends.
function SUB:ApplyDeferredUpdates()
    if self.rosterDirty then
        self.rosterDirty = false
        self:ApplyRosterUpdate()
    end
    if self.emptyButtonsDirty then
        self.emptyButtonsDirty = false
        self:ApplyShowEmptyButtonsOption()
    end
end

-- Event handler: delegates to HandleUnitNameUpdate.
function SUB:OnUnitNameUpdate(event, unit)
    self:HandleUnitNameUpdate(unit)
end

-- Updates individual buttons when a unit's name resolves.
function SUB:HandleUnitNameUpdate(unit)
    if not unit or not UNIT_INDEX[unit] or unit == "player" then return end
    local barData = self.bars[unit]
    if not barData or not barData.frame:IsShown() then return end
    self:RefreshIndividualButtons(unit)
end

-- Returns whether the bar for `unit` should currently be visible.
local function ShouldShowBarForUnit(sub, unit)
    if unit == "player" then
        return sub:ShouldShowPlayerBar()
    end
    return CE.Unit.UnitExists(unit) and true or false
end

-- Performs follow-up updates for currently visible bars.
local function RefreshVisibleBarState(sub, unit)
    sub:UpdateLabelVisibility(unit)
    if unit ~= "player" then
        sub:RefreshIndividualButtons(unit)
    end
end

-- Updates bar visibility and dependent state for the current roster.
local function UpdateBarVisibility(self, unit)
    local show = ShouldShowBarForUnit(self, unit)
    self.bars[unit].frame:SetShown(show)
    if show then RefreshVisibleBarState(self, unit) end
end

-- Returns true if roster updates must be deferred until after combat.
local function DeferRosterUpdateIfInCombat(self)
    if not CE.Combat.InCombatLockdown() then return false end
    self.rosterDirty = true
    return true
end

-- Updates visibility for each managed bar that currently exists.
local function UpdateAllBarVisibility(self)
    for _, unit in ipairs(UNITS) do
        local barData = self.bars[unit]
        if not barData then break end
        UpdateBarVisibility(self, unit)
    end
end

-- Applies the position refresh required for the current roster mode.
local function ApplyRosterPositionMode(self)
    local positionMode = self.db.profile.positionMode
    if positionMode == "anchored" then
        self:ApplyAnchoredPositions()
        return
    end
    if positionMode == "suf" then
        -- Defer to the next tick: SUF's own GROUP_ROSTER_UPDATE handler may
        -- not have run yet (same event tick, undefined ordering).
        -- C_Timer.After(0) fires after all handlers of the current frame, so
        -- SUF frames are guaranteed to be created/visible by then.
        self:ScheduleSUFPositions()
        return
    end
end

-- Event handler: delegates to ApplyRosterUpdate.
function SUB:OnRosterUpdate()
    self:ApplyRosterUpdate()
end

-- Updates bar visibility for all units.
-- Secure frames cannot call SetShown during combat lockdown, so updates are
-- deferred via rosterDirty until combat ends.
function SUB:ApplyRosterUpdate()
    if DeferRosterUpdateIfInCombat(self) then return end
    UpdateAllBarVisibility(self)
    ApplyRosterPositionMode(self)
end

-- Event Glue: Bags / Mana
-------------------------------------------------------------------------------

-- Event handler: delegates to HandlePlayerPowerUpdate.
function SUB:OnPlayerPowerUpdate(event, unit, powerType)
    self:HandlePlayerPowerUpdate(unit, powerType)
end

-- Updates cast-count labels when the player's mana changes.
-- UNIT_POWER_UPDATE fires for every unit/power; only player mana matters.
-- powerType is a number (0 = mana) in Retail/Cata+, or a string ("MANA") in Classic Era.
-- UNIT_MANA (Classic) fires without powerType → powerType = nil, which always matches.
function SUB:HandlePlayerPowerUpdate(unit, powerType)
    if unit and unit ~= "player" then return end
    if powerType and powerType ~= 0 and powerType ~= "MANA" then return end
    if not self.db.profile.showCastCount then return end
    self:UpdateAllCastCounts()
end

-- Event handler: delegates to HandleBagUpdate.
function SUB:OnBagUpdate()
    self:HandleBagUpdate()
end

-- Updates reagent and item count labels when bag contents change.
function SUB:HandleBagUpdate()
    -- Custom reagent count overlay (hides native LAB count for affected buttons).
    self:UpdateAllReagentCounts()
    -- Update native LAB count for spell buttons without the custom overlay.
    -- LAB does not listen to BAG_UPDATE for spell-type buttons.
    ForEachButton(self.bars, RefreshNativeLABCount)
    if not self.db.profile.showCastCount then return end
    self:UpdateAllCastCounts()
end
