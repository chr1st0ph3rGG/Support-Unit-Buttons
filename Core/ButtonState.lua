-------------------------------------------------------------------------------
-- Core/ButtonState.lua
-- Button-State-Management, Roster-Sichtbarkeit, Event-Glue (Bag/Power)
-------------------------------------------------------------------------------

local _, SUB_NS = ...
local SUB = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local CE = LibStub("C_Everywhere")

local UNITS          = SUB_NS.UNITS
local UNIT_INDEX     = SUB_NS.UNIT_INDEX
local MAX_SHARED     = SUB_NS.MAX_SHARED
local MAX_INDIVIDUAL = SUB_NS.MAX_INDIVIDUAL

-------------------------------------------------------------------------------
-- Iterator-Hilfsfunktion
-------------------------------------------------------------------------------

-- Ruft fn(btn) für jeden Button (shared + individual) auf jeder aktiven Bar auf.
local function ForEachButton(bars, fn)
    for _, unit in ipairs(UNITS) do
        local bd = bars[unit]
        if bd then
            for _, btn in ipairs(bd.sharedButtons) do fn(btn) end
            for _, btn in ipairs(bd.individualButtons) do fn(btn) end
        end
    end
end

-- Aktualisiert den nativen LAB-Count für einen einzelnen Spell-Button.
-- Wird übersprungen wenn das custom Overlay es bereits abdeckt oder der Button keine Action hat.
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

-- Leert alle Text-Overlays und Metadaten wenn ein Button-Slot leer wird.
local function ClearButtonState(self, btn)
    ClearButtonOverlays(self, btn)
    self:UpdateDispelHighlight(btn)
end

-------------------------------------------------------------------------------
-- Macro-Attribute
-------------------------------------------------------------------------------

-- Baut Unit-targeted Macro-Text für einen Spell oder Item.
-- Gibt nil zurück wenn Spell/Item-Info noch nicht im Client-Cache ist.
local function BuildSpellMacroText(unit, action)
    local info = CE.Spell.GetSpellInfo(action)
    if not info or not info.name then return nil end
    return "/cast [@" .. unit .. "] " .. info.name
end

-- Baut einen Unit-targeted /use-Macro für einen Item-Action-String (item:ID).
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

-- Setzt das Unit-targeted Macro-Attribut für spell/item-Buttons, oder löscht es.
-- Das PreClick/PostClick-WrapScript tauscht für die Ausführung auf dieses Macro,
-- stellt danach den Original-Typ wieder her, damit LAB Icon/Cooldown/Tooltip korrekt zeigt.
local function ApplyMacroAttribute(btn, unit, btnType, action)
    if unit and (btnType == "spell" or btnType == "item") then
        btn:SetAttribute("SUB_macro", BuildMacroText(unit, btnType, action))
    else
        btn:SetAttribute("SUB_macro", nil)
    end
end

-------------------------------------------------------------------------------
-- Button-State speichern / wiederherstellen
-------------------------------------------------------------------------------

-- Gibt true zurück wenn der Drop-Vorgang den Button leeren würde.
local function IsEmptyButtonState(btnType, action)
    return not btnType or btnType == "empty" or not action
end

-- Gibt true zurück wenn ein Slot aktuell eine nicht-leere Action speichert.
local function SlotHasAssignedAction(slot)
    return slot and slot.btnType and slot.btnType ~= "empty"
end

-- Stellt vorherigen Inhalt wieder her wenn Drag-Off durch Modifier-Einstellungen blockiert.
local function RestoreIfDragOffBlocked(sub, btn, isEmpty, slot)
    if isEmpty and SlotHasAssignedAction(slot) and not sub:IsDragModifierHeld() then
        sub:RestoreButtonSilent(btn, slot.btnType, slot.action)
        return true
    end
    return false
end

-- Wendet Shared-Slot-Speicherung an und synchronisiert den Slot auf alle Units.
local function HandleSharedButtonChange(sub, btn, unit, index, btnType, action, isEmpty)
    local slot = sub.db.char.sharedSlots[index] or {}
    if RestoreIfDragOffBlocked(sub, btn, isEmpty, slot) then return end

    slot.btnType = btnType
    slot.action = action
    sub.db.char.sharedSlots[index] = slot
    sub:ApplyButtonState(btn, btnType, action)
    sub:SyncSharedSlot(unit, index, btnType, action)
end

-- Wendet Per-Charakter-Slot-Updates für Individual-Buttons an.
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

-- Gibt unit, section, index für `btn` zurück, oder nil wenn eines fehlt.
local function GetButtonContext(btn)
    local unit    = btn.SUB_unit
    local section = btn.SUB_section
    local index   = btn.SUB_index
    if not unit or not section or not index then return nil end
    return unit, section, index
end

-- Callback-Handler: delegiert an HandleButtonContentsChanged.
function SUB:OnButtonContentsChanged(event, btn, state, btnType, action)
    self:HandleButtonContentsChanged(btn, state, btnType, action)
end

-- Verteilt LAB-Content-Changes an den passenden Section-Handler.
function SUB:HandleButtonContentsChanged(btn, state, btnType, action)
    if self.syncing or tostring(state) ~= "0" then return end
    local unit, section, index = GetButtonContext(btn)
    if not unit then return end
    local handler = SECTION_HANDLER[section]
    if handler then
        handler(self, btn, unit, index, btnType, action, IsEmptyButtonState(btnType, action))
    end
end

-- Leert einen Shared-Button auf einen leeren Zustand.
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
end

-- Stellt den vorherigen Inhalt eines Buttons ohne Callback-Loop wieder her.
function SUB:RestoreButtonSilent(btn, btnType, action)
    self.syncing = true
    self:ApplyButtonState(btn, btnType, action)
    self.syncing = false
    ClearCursor()
end

-- Wendet einen Shared-Slot-Sync-Update auf einen Ziel-Button an.
function SUB:SyncSharedSlotButton(btn, isEmpty, btnType, action)
    if isEmpty then
        self:ClearSharedButton(btn)
    else
        self:ApplyButtonState(btn, btnType, action)
    end
end

-- Propagiert Shared-Slot-Änderungen von einer Unit auf alle anderen Unit-Bars.
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

-- Aktualisiert alle visuellen Zustände und Attribute für einen Button mit einer Live-Action.
function SUB:ApplyButtonState(btn, btnType, action)
    if not btnType or btnType == "empty" or not action then
        ClearButtonState(self, btn)
        return
    end
    if CE.Combat.InCombatLockdown() then return end
    ApplyMacroAttribute(btn, btn.SUB_unit, btnType, action)
    -- Immer den nativen Typ verwenden damit LAB Icon, Cooldown, Tooltip auflösen kann.
    btn:SetState(nil, btnType, action)
    self:UpdateButtonRankText(btn, btnType, action)
    self:UpdateButtonReagentCount(btn, btnType, action)
    self:UpdateButtonCastCount(btn, btnType, action)
    self:UpdateDispelHighlight(btn)
    self:UpdateButtonBuffStatus(btn)
end

-- Stellt einen Shared-Button aus gespeicherten Profil-Daten wieder her.
function SUB:RestoreSharedButton(unit, btn, index)
    local slot = self.db.char.sharedSlots[index]
    if slot and slot.btnType then
        self:ApplyButtonState(btn, slot.btnType, slot.action)
    end
end

-- Leert einen Individual-Button auf einen leeren Zustand.
local function ClearIndividualButton(btn)
    if CE.Combat.InCombatLockdown() then return end
    btn:SetState(nil, "empty", nil)
end

-- Baut Individual-Buttons für eine Unit aus Per-Charakter-Slot-Daten neu auf.
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

-- Wendet gespeicherte Slot-Zustände auf alle Shared-Buttons einer Bar an.
local function ApplySharedSlots(self, bd, sharedSlots)
    for i = 1, MAX_SHARED do
        local slot = sharedSlots[i]
        if slot and slot.btnType then
            self:ApplyButtonState(bd.sharedButtons[i], slot.btnType, slot.action)
        end
    end
end

-- Wendet alle gespeicherten Button-Zustände auf jede Unit-Bar neu an.
-- Aktualisiert auch die Dispel-Name-Map jetzt wo der vollständige Spell-Cache verfügbar ist.
function SUB:ApplyAllButtonStates()
    if CE.Combat.InCombatLockdown() then return end
    self:BuildDispelNameTypes()
    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if not bd then break end
        ApplySharedSlots(self, bd, self.db.char.sharedSlots)
        if unit ~= "player" then
            self:RefreshIndividualButtons(unit)
        end
    end
end

-------------------------------------------------------------------------------
-- Sichtbarkeit & Roster
-------------------------------------------------------------------------------

function SUB:ShouldShowPlayerBar()
    local db = self.db.profile
    if not db.showPlayer then return false end
    if db.showPlayerOnlyInParty then return CE.Party.IsInGroup() and true or false end
    return true
end

-- Event-Handler: delegiert an ApplyDeferredUpdates.
function SUB:OnCombatEnd()
    self:ApplyDeferredUpdates()
end

-- Wendet aufgeschobene Updates nach dem Ende des Kampf-Lockdowns an.
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

-- Event-Handler: delegiert an HandleUnitNameUpdate.
function SUB:OnUnitNameUpdate(event, unit)
    self:HandleUnitNameUpdate(unit)
end

-- Aktualisiert Individual-Buttons wenn der Name einer Unit aufgelöst wird.
function SUB:HandleUnitNameUpdate(unit)
    if not unit or not UNIT_INDEX[unit] or unit == "player" then return end
    local barData = self.bars[unit]
    if not barData or not barData.frame:IsShown() then return end
    self:RefreshIndividualButtons(unit)
end

-- Gibt zurück ob die Bar für `unit` aktuell sichtbar sein soll.
local function ShouldShowBarForUnit(sub, unit)
    if unit == "player" then
        return sub:ShouldShowPlayerBar()
    end
    return CE.Unit.UnitExists(unit) and true or false
end

-- Führt Folge-Updates für aktuell sichtbare Bars durch.
local function RefreshVisibleBarState(sub, unit)
    sub:UpdateLabelVisibility(unit)
    if unit ~= "player" then
        sub:RefreshIndividualButtons(unit)
    end
end

-- Aktualisiert Bar-Sichtbarkeit und abhängige Zustände für den aktuellen Roster.
local function UpdateBarVisibility(self, unit)
    local show = ShouldShowBarForUnit(self, unit)
    self.bars[unit].frame:SetShown(show)
    if show then RefreshVisibleBarState(self, unit) end
end

-- Gibt true zurück wenn Roster-Updates bis nach dem Kampf aufgeschoben werden müssen.
local function DeferRosterUpdateIfInCombat(self)
    if not CE.Combat.InCombatLockdown() then return false end
    self.rosterDirty = true
    return true
end

-- Aktualisiert Sichtbarkeit für jede verwaltete Bar die aktuell existiert.
local function UpdateAllBarVisibility(self)
    for _, unit in ipairs(UNITS) do
        local barData = self.bars[unit]
        if not barData then break end
        UpdateBarVisibility(self, unit)
    end
end

-- Wendet den Positions-Refresh an der für den aktuellen Roster-Modus nötig ist.
local function ApplyRosterPositionMode(self)
    local positionMode = self.db.profile.positionMode
    if positionMode == "anchored" then
        self:ApplyAnchoredPositions()
        return
    end
    if positionMode == "suf" then
        -- Auf nächsten Tick verschieben: SUFs eigener GROUP_ROSTER_UPDATE-Handler
        -- hat möglicherweise noch nicht ausgeführt (gleicher Event-Tick, Reihenfolge undefiniert).
        -- C_Timer.After(0) feuert nach allen Handlern des aktuellen Frames, daher sind
        -- SUF-Frames dann garantiert erstellt/sichtbar.
        self:ScheduleSUFPositions()
    end
end

-- Event-Handler: delegiert an ApplyRosterUpdate.
function SUB:OnRosterUpdate()
    self:ApplyRosterUpdate()
end

-- Aktualisiert Bar-Sichtbarkeit für alle Units.
-- Secure-Frames können SetShown nicht während des Kampf-Lockdowns aufrufen, daher
-- werden Updates via rosterDirty aufgeschoben bis der Kampf endet.
function SUB:ApplyRosterUpdate()
    if DeferRosterUpdateIfInCombat(self) then return end
    UpdateAllBarVisibility(self)
    ApplyRosterPositionMode(self)
end

-------------------------------------------------------------------------------
-- Event-Glue: Taschen / Mana
-------------------------------------------------------------------------------

-- Event-Handler: delegiert an HandlePlayerPowerUpdate.
function SUB:OnPlayerPowerUpdate(event, unit, powerType)
    self:HandlePlayerPowerUpdate(unit, powerType)
end

-- Aktualisiert Cast-Count-Labels wenn sich das Spieler-Mana ändert.
-- UNIT_POWER_UPDATE feuert für jede Unit/Power; nur Spieler-Mana interessiert.
-- powerType ist eine Zahl (0 = Mana) in Retail/Cata+, oder ein String ("MANA") in Classic Era.
-- UNIT_MANA (Classic) feuert ohne powerType → powerType = nil, passt immer.
function SUB:HandlePlayerPowerUpdate(unit, powerType)
    if unit and unit ~= "player" then return end
    if powerType and powerType ~= 0 and powerType ~= "MANA" then return end
    if not self.db.profile.showCastCount then return end
    self:UpdateAllCastCounts()
end

-- Event-Handler: delegiert an HandleBagUpdate.
function SUB:OnBagUpdate()
    self:HandleBagUpdate()
end

-- Aktualisiert Reagent- und Item-Count-Labels wenn sich der Tascheninhalt ändert.
function SUB:HandleBagUpdate()
    -- Custom Reagent-Count-Overlay (versteckt nativen LAB-Count für betroffene Buttons).
    self:UpdateAllReagentCounts()
    -- Nativen LAB-Count für Spell-Buttons ohne custom Overlay aktualisieren.
    -- LAB hört nicht auf BAG_UPDATE für spell-type Buttons.
    ForEachButton(self.bars, RefreshNativeLABCount)
    if not self.db.profile.showCastCount then return end
    self:UpdateAllCastCounts()
end
