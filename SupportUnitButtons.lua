-------------------------------------------------------------------------------
-- SupportUnitButtons.lua
-------------------------------------------------------------------------------

local AddonName, SUB_NS = ...

local SUB               = LibStub("AceAddon-3.0"):NewAddon("SupportUnitButtons",
    "AceConsole-3.0",
    "AceEvent-3.0"
)

local LAB               = LibStub("LibActionButton-1.0")
local CE                = LibStub("C_Everywhere")
local SpellRange        = LibStub("SpellRange-1.0")
local AceDB             = LibStub("AceDB-3.0")
local AceCfg            = LibStub("AceConfig-3.0")
local AceCfgD           = LibStub("AceConfigDialog-3.0")
local AceDBOpt          = LibStub("AceDBOptions-3.0")
local Masque            = LibStub("Masque", true)
local LSM               = LibStub("LibSharedMedia-3.0")
local LibDispel         = LibStub("LibDispel-1.0", true)
local CT                = LibStub("CustomTutorials-2.1")

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local UNITS             = { "player", "party1", "party2", "party3", "party4" }
local UNIT_INDEX        = { player = 0, party1 = 1, party2 = 2, party3 = 3, party4 = 4 }
local MAX_SHARED        = 12
local MAX_INDIVIDUAL    = 6
local SEPARATOR_GAP     = 8  -- gap between shared and individual sections (px)
local HANDLE_HEIGHT     = 14 -- drag handle strip height (px)

local defaults          = SUB_NS.defaults

-------------------------------------------------------------------------------
-- Addon state
-------------------------------------------------------------------------------

SUB.bars                = {}
SUB.masqueGroup         = nil
SUB.syncing             = false
SUB.dispelActiveUnits   = {} -- unit → true when a dispellable debuff is currently active

-------------------------------------------------------------------------------
-- Dispel Alert
--
-- Draws a solid pulsing coloured border on buttons whose spell can dispel a
-- debuff the bar's unit currently has.  Four opaque edge strips replace the
-- semi-transparent IconAlertAnts sprite so the highlight is always clearly
-- visible regardless of the button icon or Masque skin underneath.
--
-- Spell → debuff-type mapping covers Classic, TBC, Wrath, Cata, and Retail.
-- A name-based lookup (built after SPELLS_CHANGED) handles all spell ranks in
-- Classic without needing every rank's ID listed.
-------------------------------------------------------------------------------

local DISPEL_ID_TYPES   = SUB_NS.DISPEL_ID_TYPES

-- Spell-name → { DebuffType = true }.  Built after spells load so every rank
-- of a multi-rank Classic spell matches automatically (they share a name).
local dispelNameTypes   = {}

local function BuildDispelNameTypes()
    for id, types in pairs(DISPEL_ID_TYPES) do
        local info = CE.Spell.GetSpellInfo(id)
        local name = info and info.name
        if name then
            if not dispelNameTypes[name] then
                local t = {}
                for k, v in pairs(types) do t[k] = v end
                dispelNameTypes[name] = t
            else
                for k, v in pairs(types) do dispelNameTypes[name][k] = v end
            end
        end
    end
end


-- Returns the dispel-type table for the spell on `btn`, or nil.
local function GetButtonDispelTypes(btn)
    if btn._state_type ~= "spell" then return nil end
    local action = btn._state_action
    if not action then return nil end
    local id = tonumber(action)
    -- 1) Direct ID hit (fastest, exact)
    if id and DISPEL_ID_TYPES[id] then return DISPEL_ID_TYPES[id] end
    -- 2) Name-based fallback: works for any rank of a multi-rank Classic spell
    local info = CE.Spell.GetSpellInfo(id or action)
    local name = info and info.name
    if name then return dispelNameTypes[name] end
    return nil
end

-- Returns (or lazily creates) the dispel-alert overlay for `btn`.
-- Uses four solid edge strips instead of the semi-transparent IconAlertAnts
-- sprite, so the border is always fully opaque and clearly visible.
-- A sine-wave alpha pulse provides the "attention" animation.
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

    ov._t = 0
    ov:SetScript("OnUpdate", function(self, elapsed)
        self._t = self._t + elapsed
        -- pulse between 60 % and 100 % opacity, ~0.8 s period
        self:SetAlpha(0.8 + 0.2 * math.sin(self._t * math.pi * 2.5))
    end)

    btn.SUB_dispelOverlay = ov
    return ov
end

-- Show or hide the dispel-alert overlay for a single button.
function SUB:UpdateDispelHighlight(btn)
    if not self.db.profile.dispelAlert then
        if btn.SUB_dispelOverlay then btn.SUB_dispelOverlay:Hide() end
        return
    end
    local types = GetButtonDispelTypes(btn)
    if not types then
        if btn.SUB_dispelOverlay then btn.SUB_dispelOverlay:Hide() end
        return
    end
    local unit = btn.SUB_unit
    if not unit or not CE.Unit.UnitExists(unit) then
        if btn.SUB_dispelOverlay then btn.SUB_dispelOverlay:Hide() end
        return
    end
    -- Scan the unit's debuffs for a type this spell can dispel.
    local foundType
    for i = 1, 40 do
        local name, _, _, debuffType = CE.Unit.UnitAura(unit, i, "HARMFUL")
        if not name then break end
        if debuffType and types[debuffType] then
            foundType = debuffType
            break
        end
    end
    local ov = GetOrCreateDispelOverlay(btn)
    if foundType then
        -- Frame bounds: extend slightly beyond button so the border sits on the
        -- visual edge of Masque-skinned buttons (mirrors LibButtonGlow sizing).
        -- Frame-level refreshed every call to stay above Masque textures.
        local pad = math.max(2, math.floor(btn:GetWidth() * 0.10))
        ov:SetFrameLevel(btn:GetFrameLevel() + 7)
        ov:ClearAllPoints()
        ov:SetPoint("TOPLEFT", btn, "TOPLEFT", -pad, pad)
        ov:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", pad, -pad)

        -- Colour all four strips.
        local col = self.db.profile.dispelAlertColor
        local BW  = math.max(2, math.floor(btn:GetWidth() * 0.06)) -- border width
        for _, strip in ipairs({ ov.eT, ov.eB, ov.eL, ov.eR }) do
            strip:SetVertexColor(col.r, col.g, col.b, 1)
        end

        -- Top strip
        ov.eT:ClearAllPoints()
        ov.eT:SetPoint("TOPLEFT", ov, "TOPLEFT", 0, 0)
        ov.eT:SetPoint("TOPRIGHT", ov, "TOPRIGHT", 0, 0)
        ov.eT:SetHeight(BW)

        -- Bottom strip
        ov.eB:ClearAllPoints()
        ov.eB:SetPoint("BOTTOMLEFT", ov, "BOTTOMLEFT", 0, 0)
        ov.eB:SetPoint("BOTTOMRIGHT", ov, "BOTTOMRIGHT", 0, 0)
        ov.eB:SetHeight(BW)

        -- Left strip (inset by BW top/bottom to avoid corner overlap)
        ov.eL:ClearAllPoints()
        ov.eL:SetPoint("TOPLEFT", ov, "TOPLEFT", 0, -BW)
        ov.eL:SetPoint("BOTTOMLEFT", ov, "BOTTOMLEFT", 0, BW)
        ov.eL:SetWidth(BW)

        -- Right strip
        ov.eR:ClearAllPoints()
        ov.eR:SetPoint("TOPRIGHT", ov, "TOPRIGHT", 0, -BW)
        ov.eR:SetPoint("BOTTOMRIGHT", ov, "BOTTOMRIGHT", 0, BW)
        ov.eR:SetWidth(BW)

        ov:Show()
    else
        ov:Hide()
    end
end

-- Update all buttons on one bar.
-- Returns true if at least one button found a debuff that can be dispelled.
function SUB:UpdateDispelHighlightsForUnit(unit)
    local bd = self.bars[unit]
    if not bd then return end
    local anyActive = false
    for _, btn in ipairs(bd.sharedButtons) do
        self:UpdateDispelHighlight(btn)
        if btn.SUB_dispelOverlay and btn.SUB_dispelOverlay:IsShown() then
            anyActive = true
        end
    end
    for _, btn in ipairs(bd.individualButtons) do
        self:UpdateDispelHighlight(btn)
        if btn.SUB_dispelOverlay and btn.SUB_dispelOverlay:IsShown() then
            anyActive = true
        end
    end
    self.dispelActiveUnits[unit] = anyActive
    return anyActive
end

-- Update every button on every bar.
function SUB:UpdateAllDispelHighlights()
    for _, unit in ipairs(UNITS) do
        self:UpdateDispelHighlightsForUnit(unit)
    end
end

-- Called when a unit's auras change.
function SUB:OnUnitAura(_, unit)
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

-- Plays the warning sound if enabled and a sound is selected.
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

-- Called when the player's mana changes; refreshes all cast-count labels.
function SUB:OnPlayerPowerUpdate(_, unit, powerType)
    -- UNIT_POWER_UPDATE fires for every unit/power; only care about player mana.
    -- powerType is a number (0 = mana) in Retail/Cata+, or a string ("MANA") in Classic Era.
    -- UNIT_MANA (Classic) fires without powerType at all → powerType = nil, always passes.
    if unit and unit ~= "player" then return end
    if powerType and powerType ~= 0 and powerType ~= "MANA" then return end
    if not self.db.profile.showCastCount then return end
    self:UpdateAllCastCounts()
end

-- Called when bag contents change; refreshes item-count labels.
function SUB:OnBagUpdate()
    if not self.db.profile.showCastCount then return end
    self:UpdateAllCastCounts()
end

-------------------------------------------------------------------------------
-- Lifecycle
-------------------------------------------------------------------------------

function SUB:OnInitialize()
    self.db = AceDB:New("SupportUnitButtonsDB", defaults)
    -- Point knownBuffSpells to the persistent global table so that
    -- knowledge about buff spells accumulates across sessions.
    knownBuffSpells = self.db.global.buffSpells

    if Masque then
        self.masqueGroup = Masque:Group("SupportUnitButtons", "Buttons")
    end

    -- Tutorial: embed CustomTutorials into SUB and register 5 pages.
    -- The savedvariable/key pair tracks the highest page seen per profile
    -- so the popup only appears automatically on first login.
    local L = LibStub("AceLocale-3.0"):GetLocale("SupportUnitButtons")
    CT:Embed(self)
    self:RegisterTutorials({
        key           = "tutorialPage",
        savedvariable = self.db.profile,
        title         = L["TUTORIAL_TITLE"],
        onShow        = function(_, i)
            local frame = CT.frames[SUB]
            if not frame then return end
            if not frame.subOpenOptionsBtn then
                local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
                btn:SetSize(120, 22)
                btn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 6)
                btn:SetText(L["Open Options"])
                btn:SetScript("OnClick", function()
                    frame:Hide()
                    AceCfgD:Open("SupportUnitButtons")
                end)
                frame.subOpenOptionsBtn = btn
            end
            frame.subOpenOptionsBtn:SetShown(i == 3)
        end,
        [1]           = { title = L["TUTORIAL_TITLE"], text = L["TUTORIAL_P1"], image = "Interface\\AddOns\\SupportUnitButtons\\sub_tutorial_bars", imageW = 300, imageH = 77 },
        [2]           = { title = L["TUTORIAL_TITLE"], text = L["TUTORIAL_P2"], image = "Interface\\AddOns\\SupportUnitButtons\\sub_tutorial_button", imageW = 300, imageH = 200 },
        [3]           = { title = L["TUTORIAL_TITLE"], text = L["TUTORIAL_P3"] },
    })

    self:BuildOptionsTable()
    self:RegisterChatCommand("sub", "ChatCommand")
    self:RegisterChatCommand("SupportUnitButtons", "ChatCommand")

    LAB.RegisterCallback(self, "OnButtonContentsChanged", "OnButtonContentsChanged")

    -- Dispel system: prime name→types map (best-effort; completed in
    -- ApplyAllButtonStates once the full spell cache is loaded).
    BuildDispelNameTypes()
    -- Re-check highlights whenever LibDispel updates the player's dispel list
    -- (talent/spec changes, learning new spells, etc.).
    if LibDispel then
        local _orig = LibDispel.ListUpdated
        LibDispel.ListUpdated = function(ld)
            _orig(ld)
            SUB:UpdateAllDispelHighlights()
        end
    end
end

function SUB:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnRosterUpdate")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnRosterUpdate")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd")
    -- Re-apply macros once the spell/item cache is populated after login.
    self:RegisterEvent("SPELLS_CHANGED", "ApplyAllButtonStates")
    -- Dispel alert: re-evaluate highlights whenever a unit's auras change.
    self:RegisterEvent("UNIT_AURA", "OnUnitAura")
    -- Cast-count: refresh when player's mana changes or bag contents change.
    -- UNIT_POWER_FREQUENT fires on every regen tick (Retail/Cata+).
    -- UNIT_POWER_UPDATE fires on cast/spend events.
    -- UNIT_MANA is the Classic Era equivalent (fires on every mana change incl. ticks).
    self:RegisterEvent("UNIT_POWER_FREQUENT", "OnPlayerPowerUpdate")
    self:RegisterEvent("UNIT_POWER_UPDATE", "OnPlayerPowerUpdate")
    self:RegisterEvent("UNIT_MANA", "OnPlayerPowerUpdate")  -- Classic Era fallback
    self:RegisterEvent("BAG_UPDATE", "OnBagUpdate")
    self:RegisterEvent("BAG_UPDATE_DELAYED", "OnBagUpdate") -- fires once after all slot-changes are done
    -- Retry individual-button restore once a party member's name is resolved.
    -- GROUP_ROSTER_UPDATE can fire before UnitName() is available, so we need
    -- this second pass to ensure the per-character assignment is applied.
    self:RegisterEvent("UNIT_NAME_UPDATE", "OnUnitNameUpdate")

    self:CreateAllBars()
    self:ApplyShowEmptyButtonsOption()
    self:OnRosterUpdate()

    -- Show tutorial automatically the first time (TriggerTutorial is a no-op
    -- once tutorialPage >= 5, so this only fires on a fresh profile).
    self:TriggerTutorial(5)

    -- Buff-Status Countdown-Ticker: aktualisiert verbleibende Zeit jede Sekunde.
    local buffTicker = CreateFrame("Frame")
    buffTicker._t    = 0
    buffTicker:SetScript("OnUpdate", function(ticker, elapsed)
        ticker._t = ticker._t + elapsed
        if ticker._t >= 1 then
            ticker._t = 0
            if SUB.db and SUB.db.profile and SUB.db.profile.showBuffStatus then
                SUB:UpdateAllBuffStatuses()
            end
        end
    end)
end

function SUB:ChatCommand()
    AceCfgD:Open("SupportUnitButtons")
end

function SUB:ShowTutorial()
    self:ResetTutorials()
    self:TriggerTutorial(5)
end

-------------------------------------------------------------------------------
-- Bar creation
-------------------------------------------------------------------------------

-- In WoW Classic, CastSpellByName(name, unit) treats ANY truthy second arg as
-- a self-cast flag (boolean), so SecureActionButtonTemplate's "unit" attribute
-- always casts on the player. We work around this by keeping type="spell"/"item"
-- for proper LAB display (icon, cooldown, tooltip), but in PreClick we briefly
-- swap to type="macro" with a [@unit] conditional, then restore in PostClick.
local function WrapButtonForUnitTarget(header, btn)
    header:WrapScript(btn, "PreClick", [[
        -- Block execution when the drag-off modifier is held.
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

    -- Block drag-off when the modifier is not held by toggling LAB's built-in
    -- LABdisableDragNDrop attribute before LAB's own OnDragStart handler runs.
    header:WrapScript(btn, "OnDragStart", [[
        local mod  = self:GetAttribute("SUB_dragModifier") or "SHIFT"
        local held = (mod == "SHIFT" and IsShiftKeyDown())
                  or (mod == "CTRL"  and IsControlKeyDown())
                  or (mod == "ALT"   and IsAltKeyDown())
                  or (mod == "ANY"   and (IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown()))
        if held then
            self:SetAttribute("LABdisableDragNDrop", nil)
        else
            return false  -- block drag without setting LABdisableDragNDrop (which also blocks OnReceiveDrag)
        end
    ]])

    -- LAB's built-in range coloring uses FindSpellBookSlotBySpellID which does not
    -- exist in WoW Classic. Override IsUnitInRange on the instance so LAB's range
    -- timer uses the Classic API (IsSpellInRange by name) instead.
    btn.IsUnitInRange = function(self, unit)
        if self._state_type == "spell" and unit then
            if CE.Unit.UnitExists(unit) and not CE.Unit.UnitIsConnected(unit) then
                return 0 -- offline = out of range
            end
            local range = SpellRange.IsSpellInRange(self._state_action, unit)
            if range == nil and SpellRange.SpellHasRange(self._state_action) and CE.Unit.UnitExists(unit) then
                range = 0 -- unit too far to measure = out of range
            end
            return range
        end
        return nil
    end
end

local CORNER_OFFSET = {
    TOPLEFT     = { -3, 1 },
    TOPRIGHT    = { 3, 1 },
    BOTTOMLEFT  = { -3, -1 },
    BOTTOMRIGHT = { 3, -1 },
}

-- Returns (or lazily creates) a child frame used to host button text overlays.
-- Because it is a child Frame with a higher FrameLevel it always renders above
-- Masque's HIGHLIGHT-layer hover border on the parent button.
local function GetOrCreateTextOverlay(btn)
    if btn.SUB_textOverlay then return btn.SUB_textOverlay end
    local ov = CreateFrame("Frame", nil, btn)
    ov:SetAllPoints(btn)
    ov:SetFrameLevel(btn:GetFrameLevel() + 10)
    btn.SUB_textOverlay = ov
    return ov
end

-- Attach a rank-text FontString to a button (corner set dynamically on update).
local function AttachRankText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_rankText = fs
end

-- Attach a cast-count FontString to a button (corner set dynamically on update).
local function AttachCastCountText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_castCountText = fs
end

-- Attach a buff-status FontString to a button (corner set dynamically on update).
local function AttachBuffStatusText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_buffStatusText = fs
end

-- Returns how many times the player can cast the spell before going OOM,
-- or the total item count in bags.  Returns nil when not applicable.
local function GetCastCountValue(btnType, action)
    if btnType == "spell" then
        local id = tonumber(action)
        if not id then return nil end
        -- GetSpellPowerCost returns a list of power-cost entries; entry.type == 0 is mana.
        local costTable = CE.Spell.GetSpellPowerCost and CE.Spell.GetSpellPowerCost(id)
        if not costTable then return nil end
        local manaCost
        for _, entry in ipairs(costTable) do
            if entry.type == 0 then
                manaCost = entry.cost
                break
            end
        end
        if not manaCost or manaCost <= 0 then return nil end
        local currentMana = UnitPower("player", 0) or UnitMana("player") or 0
        return math.floor(currentMana / manaCost)
    elseif btnType == "item" then
        local id = action and tonumber(action:match("item:(%d+)"))
        if not id then return nil end
        return GetItemCount and GetItemCount(id) or nil
    end
    return nil
end


function SUB:CreateAllBars()
    for _, unit in ipairs(UNITS) do
        self:CreateBar(unit)
    end
end

function SUB:CreateBar(unit)
    local db    = self.db.profile
    local uIdx  = UNIT_INDEX[unit]
    local fn    = "SupportUnitButtonsFrame_" .. unit

    ---------- outer moveable frame ----------
    local frame = CreateFrame("Frame", fn, UIParent)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)

    ---------- drag handle (sits at the top, above all buttons) ----------
    local handle = CreateFrame("Frame", fn .. "_Handle", frame)
    handle:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    handle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    handle:SetHeight(HANDLE_HEIGHT)
    handle:EnableMouse(not db.locked)
    handle:RegisterForDrag("LeftButton")

    local handleBg = handle:CreateTexture(nil, "BACKGROUND")
    handleBg:SetAllPoints()
    handleBg:SetColorTexture(0.15, 0.15, 0.6, 0.8)
    handleBg:SetShown(not db.locked)

    local label = handle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", handle, "LEFT", 4, 0)

    -- drag scripts are set after barData exists (need self-reference)
    handle:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    handle:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local ddb = self.db.profile
        local sc  = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
        -- x/y stored as TOPLEFT offset from UIParent TOPLEFT
        local fx  = frame:GetLeft() * sc
        local fy  = frame:GetTop() * sc - UIParent:GetHeight()

        if ddb.positionMode == "anchored" then
            -- Back-calculate the anchor (position of bar #0)
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

    ---------- secure header ----------
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

    ---------- buttons ----------
    local base = uIdx * (MAX_SHARED + MAX_INDIVIDUAL)

    local dragMod = self.db.profile.dragOffModifier

    for i = 1, MAX_SHARED do
        local btn = LAB:CreateButton(base + i, fn .. "_S" .. i, header, nil)
        btn:SetState(0, "empty", nil) -- initialise "type" attr so OnReceiveDrag works
        btn:SetAttribute("unit", unit)
        btn:SetAttribute("SUB_dragModifier", dragMod)
        btn.SUB_unit    = unit
        btn.SUB_section = "shared"
        btn.SUB_index   = i
        WrapButtonForUnitTarget(header, btn)
        AttachRankText(btn)
        AttachCastCountText(btn)
        AttachBuffStatusText(btn)
        if self.masqueGroup then self.masqueGroup:AddButton(btn) end
        barData.sharedButtons[i] = btn
        self:RestoreSharedButton(unit, btn, i)
    end

    for i = 1, MAX_INDIVIDUAL do
        local btn = LAB:CreateButton(base + MAX_SHARED + i, fn .. "_I" .. i, header, nil)
        btn:SetState(0, "empty", nil) -- initialise "type" attr so OnReceiveDrag works
        btn:SetAttribute("unit", unit)
        btn:SetAttribute("SUB_dragModifier", dragMod)
        btn.SUB_unit    = unit
        btn.SUB_section = "individual"
        btn.SUB_index   = i
        WrapButtonForUnitTarget(header, btn)
        AttachRankText(btn)
        AttachCastCountText(btn)
        AttachBuffStatusText(btn)
        if self.masqueGroup then self.masqueGroup:AddButton(btn) end
        barData.individualButtons[i] = btn
    end
    -- Restore via RefreshIndividualButtons so the clear+restore logic is shared.
    self:RefreshIndividualButtons(unit)

    self:UpdateBarLayout(unit)
    self:RestoreBarPosition(unit)
end

-------------------------------------------------------------------------------
-- Button helpers
-------------------------------------------------------------------------------

-- Resize the button frame. Keep NormalTexture (empty-slot border) at 1:1 so it does
-- not bleed into neighbouring buttons and cause apparent spacing shrinkage.
local function SizeButton(btn, size)
    btn:SetSize(size, size)
    local nt = btn:GetNormalTexture()
    if nt then
        nt:ClearAllPoints()
        nt:SetPoint("CENTER", btn, "CENTER", 0, 0)
        nt:SetSize(size, size)
    end
end

-- Build a unit-targeted macro string for a spell or item action.
-- Returns nil when the spell/item info is not yet available in the client cache.
local function BuildMacroText(unit, btnType, action)
    if btnType == "spell" then
        local info = CE.Spell.GetSpellInfo(action)
        if not info or not info.name then return nil end
        return "/cast [@" .. unit .. "] " .. info.name
    elseif btnType == "item" then
        -- action is stored as "item:12345"
        local id = action and tonumber(action:match("item:(%d+)"))
        if not id then return nil end
        local name = CE.Item.GetItemInfo(id)
        if not name then return nil end
        return "/use [@" .. unit .. "] " .. name
    end
    return nil
end

-------------------------------------------------------------------------------
-- Layout
-------------------------------------------------------------------------------

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

function SUB:UpdateBarLayout(unit)
    local db      = self.db.profile
    local barData = self.bars[unit]
    if not barData then return end

    local sz = db.buttonSize
    local sp = db.buttonSpacing
    local sN = db.sharedCount
    local iN = db.individualCount

    -- shared buttons
    for i = 1, MAX_SHARED do
        local btn = barData.sharedButtons[i]
        if btn then
            SizeButton(btn, sz)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", barData.frame, "TOPLEFT",
                (i - 1) * (sz + sp), -HANDLE_HEIGHT)
            btn:SetShown(i <= sN)
        end
    end

    -- individual buttons (with separator gap after shared section)
    -- sN shared buttons end at: (sN-1)*(sz+sp)+sz = sN*(sz+sp)-sp
    local sepX = (sN > 0) and (sN * (sz + sp) - sp + (db.separatorGap or SEPARATOR_GAP)) or 0
    for i = 1, MAX_INDIVIDUAL do
        local btn = barData.individualButtons[i]
        if btn then
            SizeButton(btn, sz)
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

function SUB:UpdateAllLayouts()
    for _, unit in ipairs(UNITS) do
        self:UpdateBarLayout(unit)
    end
    -- re-apply anchored positions since bar size may have changed
    if self.db.profile.positionMode == "anchored" then
        self:ApplyAnchoredPositions()
    end
end

-------------------------------------------------------------------------------
-- Label visibility
-- Labels show when: bar is unlocked (always) OR showLabels option is on
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

function SUB:UpdateAllLabelVisibility()
    for _, unit in ipairs(UNITS) do
        self:UpdateLabelVisibility(unit)
    end
end

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

function SUB:SetShowEmptyButtons(show)
    self.db.profile.showEmptyButtons = show and true or false
    self:ApplyShowEmptyButtonsOption()
end

-------------------------------------------------------------------------------
-- Button content save / restore
-------------------------------------------------------------------------------

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

function SUB:IsDragModifierHeld()
    local mod = self.db.profile.dragOffModifier
    if mod == "ANY" then return CE.Input.IsShiftKeyDown() or CE.Input.IsControlKeyDown() or CE.Input.IsAltKeyDown() end
    if mod == "SHIFT" then return CE.Input.IsShiftKeyDown() end
    if mod == "CTRL" then return CE.Input.IsControlKeyDown() end
    if mod == "ALT" then return CE.Input.IsAltKeyDown() end
    return false
end

-- Restore a button's previous content without triggering another callback loop.
function SUB:RestoreButtonSilent(btn, btnType, action)
    self.syncing = true
    self:ApplyButtonState(btn, btnType, action)
    self.syncing = false
    ClearCursor()
end

function SUB:OnButtonContentsChanged(event, btn, state, btnType, action)
    if self.syncing then return end
    local unit    = btn.SUB_unit
    local section = btn.SUB_section
    local index   = btn.SUB_index
    if not unit or not section or not index then return end
    if tostring(state) ~= "0" then return end

    local isEmpty = not btnType or btnType == "empty" or not action

    if section == "shared" then
        local slot = self.db.char.sharedSlots[index] or {}
        -- Block drag-off without the required modifier; silently restore the old content.
        if isEmpty and slot.btnType and slot.btnType ~= "empty" then
            if not self:IsDragModifierHeld() then
                self:RestoreButtonSilent(btn, slot.btnType, slot.action)
                return
            end
        end
        slot.btnType                    = btnType
        slot.action                     = action
        self.db.char.sharedSlots[index] = slot
        self:ApplyButtonState(btn, btnType, action)
        self:SyncSharedSlot(unit, index, btnType, action)
    elseif section == "individual" then
        local charName = CE.Unit.UnitName(unit)
        if charName and charName ~= "Unknown" then
            local slots = self.db.char.memberSlots[charName]
            local slot  = slots[index] or {}
            -- Block drag-off without the required modifier.
            if isEmpty and slot.btnType and slot.btnType ~= "empty" then
                if not self:IsDragModifierHeld() then
                    self:RestoreButtonSilent(btn, slot.btnType, slot.action)
                    return
                end
            end
            slot.btnType = btnType
            slot.action  = action
            slots[index] = slot
        end
        self:ApplyButtonState(btn, btnType, action)
    end
end

function SUB:SyncSharedSlot(sourceUnit, index, btnType, action)
    if self.syncing then return end
    self.syncing = true
    local isEmpty = not btnType or btnType == "empty" or not action
    for _, unit in ipairs(UNITS) do
        if unit ~= sourceUnit then
            local bd = self.bars[unit]
            if bd then
                local btn = bd.sharedButtons[index]
                if btn then
                    if isEmpty then
                        if not CE.Combat.InCombatLockdown() then
                            btn:SetState(nil, "empty", nil)
                            btn:SetAttribute("SUB_macro", nil)
                            if btn.SUB_rankText then btn.SUB_rankText:SetText("") end
                            if btn.SUB_castCountText then btn.SUB_castCountText:SetText("") end
                            if btn.SUB_buffStatusText then btn.SUB_buffStatusText:SetText("") end
                            self:UpdateDispelHighlight(btn)
                        end
                    else
                        self:ApplyButtonState(btn, btnType, action)
                    end
                end
            end
        end
    end
    self.syncing = false
end

function SUB:UpdateButtonRankText(btn, btnType, action)
    local fs = btn.SUB_rankText
    if not fs then return end
    local db = self.db and self.db.profile
    if not db or not db.showSpellRank or btnType ~= "spell" or not action then
        fs:SetText("")
        return
    end
    local rankText = CE.Spell.GetSpellSubtext(action)
    local num = rankText and rankText:match("%d+")
    if not num then
        fs:SetText("")
        return
    end
    local corner = db.spellRankCorner or "BOTTOMRIGHT"
    local off    = CORNER_OFFSET[corner] or CORNER_OFFSET.BOTTOMRIGHT
    fs:ClearAllPoints()
    fs:SetPoint(corner, btn, corner, off[1] + (db.spellRankOffsetX or 0), off[2] + (db.spellRankOffsetY or 0))
    local c        = db.spellRankColor or { r = 1, g = 1, b = 1, a = 1 }
    local flags    = (db.spellRankOutline and db.spellRankOutline ~= "NONE") and db.spellRankOutline or ""
    local fontPath = LSM:Fetch("font", db.spellRankFont or "Friz Quadrata TT")
    fs:SetFont(fontPath, db.spellRankFontSize or 9, flags)
    fs:SetTextColor(c.r or 1, c.g or 1, c.b or 1, c.a or 1)
    fs:SetText(num)
end

function SUB:UpdateAllRankTexts()
    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if bd then
            for _, btn in ipairs(bd.sharedButtons) do
                local t, a = btn:GetAction()
                self:UpdateButtonRankText(btn, t, a)
            end
            for _, btn in ipairs(bd.individualButtons) do
                local t, a = btn:GetAction()
                self:UpdateButtonRankText(btn, t, a)
            end
        end
    end
end

function SUB:UpdateButtonCastCount(btn, btnType, action)
    local fs = btn.SUB_castCountText
    if not fs then return end
    local db = self.db and self.db.profile
    if not db or not db.showCastCount or not btnType or btnType == "empty" or not action then
        fs:SetText("")
        return
    end
    local count = GetCastCountValue(btnType, action)
    if count == nil then
        fs:SetText("")
        return
    end
    local corner = db.castCountCorner or "TOPLEFT"
    local off    = CORNER_OFFSET[corner] or CORNER_OFFSET.TOPLEFT
    fs:ClearAllPoints()
    fs:SetPoint(corner, btn, corner, off[1] + (db.castCountOffsetX or 0), off[2] + (db.castCountOffsetY or 0))
    local c        = (btnType == "item")
        and (db.castCountItemColor or { r = 1, g = 0.8, b = 0.2, a = 1 })
        or (db.castCountSpellColor or { r = 0.4, g = 0.8, b = 1, a = 1 })
    local flags    = (db.castCountOutline and db.castCountOutline ~= "NONE") and db.castCountOutline or ""
    local fontPath = LSM:Fetch("font", db.castCountFont or "Friz Quadrata TT")
    fs:SetFont(fontPath, db.castCountFontSize or 9, flags)
    fs:SetTextColor(c.r or 1, c.g or 1, c.b or 1, c.a or 1)
    fs:SetText(tostring(count))
end

function SUB:UpdateAllCastCounts()
    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if bd then
            for _, btn in ipairs(bd.sharedButtons) do
                local t, a = btn:GetAction()
                self:UpdateButtonCastCount(btn, t, a)
            end
            for _, btn in ipairs(bd.individualButtons) do
                local t, a = btn:GetAction()
                self:UpdateButtonCastCount(btn, t, a)
            end
        end
    end
end

-------------------------------------------------------------------------------
-- Buff Status
--
-- Shows remaining buff duration in the button corner when the button's spell
-- is active as a buff on the target.  Shows "-" when the buff is not active.
-- Updated via UNIT_AURA events plus a per-second ticker.
-------------------------------------------------------------------------------

-- Returns the spell name for a spell-type button, or nil.
local function GetButtonSpellName(btn)
    if btn._state_type ~= "spell" then return nil end
    local action = btn._state_action
    if not action then return nil end
    local info = CE.Spell.GetSpellInfo(action)
    return info and info.name
end

-- Spell names that have been discovered at least once as a player buff.
-- Populated at runtime; only then do we show "-" when the buff is currently inactive.
local knownBuffSpells = {}

-- Searches a unit's buffs for a player-cast buff with the given spell name.
-- Returns (expirationTime, duration), or nil.
-- Marks the spell name as a known buff spell once found.
local function FindPlayerBuffOnUnit(unit, spellName)
    if not unit or not CE.Unit.UnitExists(unit) then return nil end
    for i = 1, 40 do
        local name, _, _, _, duration, expirationTime, source = CE.Unit.UnitAura(unit, i, "HELPFUL")
        if not name then break end
        if name == spellName and source == "player" then
            knownBuffSpells[spellName] = true
            return expirationTime, duration
        end
    end
    return nil
end

local function FormatBuffTime(remaining)
    if remaining <= 0 then return "0" end
    if remaining >= 3600 then
        return math.ceil(remaining / 3600) .. "h"
    elseif remaining >= 60 then
        return math.ceil(remaining / 60) .. "m"
    else
        return math.ceil(remaining) .. "s"
    end
end

function SUB:UpdateButtonBuffStatus(btn)
    local fs = btn.SUB_buffStatusText
    if not fs then return end
    local db = self.db and self.db.profile
    if not db or not db.showBuffStatus then
        fs:SetText("")
        return
    end
    local btnType = btn._state_type
    if not btnType or btnType == "empty" then
        fs:SetText("")
        return
    end
    local spellName = GetButtonSpellName(btn)
    if not spellName then
        fs:SetText("")
        return
    end
    -- Layout
    local corner   = db.buffStatusCorner or "BOTTOMLEFT"
    local off      = CORNER_OFFSET[corner] or CORNER_OFFSET.BOTTOMLEFT
    local flags    = (db.buffStatusOutline and db.buffStatusOutline ~= "NONE") and db.buffStatusOutline or ""
    local fontPath = LSM:Fetch("font", db.buffStatusFont or "Friz Quadrata TT")
    fs:ClearAllPoints()
    fs:SetPoint(corner, btn, corner, off[1] + (db.buffStatusOffsetX or 0), off[2] + (db.buffStatusOffsetY or 0))
    fs:SetFont(fontPath, db.buffStatusFontSize or 9, flags)

    local expirationTime, duration = FindPlayerBuffOnUnit(btn.SUB_unit, spellName)
    if expirationTime then
        btn.SUB_buffExpiry = expirationTime
        if duration == 0 then
            local c = db.buffStatusColor or { r = 1, g = 1, b = 0, a = 1 }
            fs:SetTextColor(c.r, c.g, c.b, c.a)
            fs:SetText("~")
        else
            local remaining = math.max(0, expirationTime - GetTime())
            local threshold = db.buffStatusLowThreshold or 60
            local c = (remaining < threshold)
                and (db.buffStatusLowColor or { r = 1, g = 0, b = 0, a = 1 })
                or (db.buffStatusColor or { r = 1, g = 1, b = 0, a = 1 })
            fs:SetTextColor(c.r, c.g, c.b, c.a)
            fs:SetText(FormatBuffTime(remaining))
        end
    elseif knownBuffSpells[spellName] then
        -- Known buff spell, but currently not active on this unit.
        btn.SUB_buffExpiry = nil
        local c = db.buffStatusColor or { r = 1, g = 1, b = 0, a = 1 }
        fs:SetTextColor(c.r, c.g, c.b, c.a)
        fs:SetText("-")
    else
        -- Not a buff spell (or never seen as a buff) → show nothing.
        btn.SUB_buffExpiry = nil
        fs:SetText("")
    end
end

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

function SUB:ApplyButtonState(btn, btnType, action)
    if not btnType or btnType == "empty" or not action then
        if btn.SUB_rankText then btn.SUB_rankText:SetText("") end
        if btn.SUB_castCountText then btn.SUB_castCountText:SetText("") end
        if btn.SUB_buffStatusText then btn.SUB_buffStatusText:SetText("") end
        btn:SetAttribute("SUB_macro", nil)
        self:UpdateDispelHighlight(btn) -- clear overlay when slot becomes empty
        return
    end
    if CE.Combat.InCombatLockdown() then return end

    local unit = btn.SUB_unit
    if unit and (btnType == "spell" or btnType == "item") then
        -- Store the unit-targeted macro on the button as an attribute.
        -- The PreClick/PostClick WrapScript will swap to this macro for execution,
        -- then restore the original type so LAB keeps showing icon/cooldown correctly.
        btn:SetAttribute("SUB_macro", BuildMacroText(unit, btnType, action))
    else
        btn:SetAttribute("SUB_macro", nil)
    end

    -- Always use the native type so LAB can resolve icon, cooldown, tooltip.
    btn:SetState(nil, btnType, action)
    self:UpdateButtonRankText(btn, btnType, action)
    self:UpdateButtonCastCount(btn, btnType, action)
    self:UpdateDispelHighlight(btn)
    self:UpdateButtonBuffStatus(btn)
end

function SUB:RestoreSharedButton(unit, btn, index)
    local slot = self.db.char.sharedSlots[index]
    if slot and slot.btnType then
        self:ApplyButtonState(btn, slot.btnType, slot.action)
    end
end

local function ClearIndividualButton(btn)
    if CE.Combat.InCombatLockdown() then return end
    btn:SetState(nil, "empty", nil)
    btn:SetAttribute("SUB_macro", nil)
    if btn.SUB_rankText then btn.SUB_rankText:SetText("") end
    if btn.SUB_castCountText then btn.SUB_castCountText:SetText("") end
    if btn.SUB_buffStatusText then btn.SUB_buffStatusText:SetText("") end
end

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
            self:UpdateDispelHighlight(btn)
        end
    end
    self.syncing = false
end

-- Called when SPELLS_CHANGED fires (cache populated after login).
-- Re-builds SUB_macro on every button so unit-targeting works correctly.
function SUB:ApplyAllButtonStates()
    if CE.Combat.InCombatLockdown() then return end
    -- Refresh the dispel name map now that the full spell cache is available.
    BuildDispelNameTypes()
    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if not bd then break end
        for i = 1, MAX_SHARED do
            local slot = self.db.char.sharedSlots[i]
            if slot and slot.btnType then
                self:ApplyButtonState(bd.sharedButtons[i], slot.btnType, slot.action)
            end
        end
        if unit ~= "player" then
            self:RefreshIndividualButtons(unit)
        end
    end
end

-------------------------------------------------------------------------------
-- Visibility
-------------------------------------------------------------------------------

function SUB:ShouldShowPlayerBar()
    local db = self.db.profile
    if not db.showPlayer then return false end
    if db.showPlayerOnlyInParty then return CE.Party.IsInGroup() and true or false end
    return true
end

function SUB:OnCombatEnd()
    if self.rosterDirty then
        self.rosterDirty = false
        self:OnRosterUpdate()
    end
    if self.emptyButtonsDirty then
        self.emptyButtonsDirty = false
        self:ApplyShowEmptyButtonsOption()
    end
end

-- Fired when a unit's name becomes available (may arrive after GROUP_ROSTER_UPDATE).
-- Refreshes the individual buttons for that party slot so the per-character
-- assignment is applied even if UnitName() returned nil on the first try.
function SUB:OnUnitNameUpdate(_, unit)
    if not unit or not UNIT_INDEX[unit] or unit == "player" then return end
    local barData = self.bars[unit]
    if not barData or not barData.frame:IsShown() then return end
    self:RefreshIndividualButtons(unit)
end

function SUB:OnRosterUpdate()
    -- Protected frames (those with secure children) cannot have SetShown called
    -- during combat lockdown. Defer the visibility update until combat ends.
    if CE.Combat.InCombatLockdown() then
        self.rosterDirty = true
        return
    end

    for _, unit in ipairs(UNITS) do
        local barData = self.bars[unit]
        if not barData then break end

        local show
        if unit == "player" then
            show = self:ShouldShowPlayerBar()
        else
            show = CE.Unit.UnitExists(unit) and true or false
        end

        barData.frame:SetShown(show)

        if show then
            self:UpdateLabelVisibility(unit)
            if unit ~= "player" then
                self:RefreshIndividualButtons(unit)
            end
        end
    end

    if self.db.profile.positionMode == "anchored" then
        self:ApplyAnchoredPositions()
    end
end

-------------------------------------------------------------------------------
-- Positioning
-------------------------------------------------------------------------------

-- Returns how many visible bars come before `unit` in UNITS order.
function SUB:GetVisiblePrecedingCount(unit)
    local count = 0
    for _, u in ipairs(UNITS) do
        if u == unit then break end
        local bd = self.bars[u]
        if bd and bd.frame:IsShown() then
            count = count + 1
        end
    end
    return count
end

-- "anchored" mode: stack all visible bars from the stored anchor point.
function SUB:ApplyAnchoredPositions()
    local db   = self.db.profile
    local gap  = db.anchorGap
    local isV  = (db.anchorDirection == "vertical")
    local barH = HANDLE_HEIGHT + db.buttonSize
    local barW = self:GetBarTotalWidth()
    local ax   = db.anchorX
    local ay   = db.anchorY
    local idx  = 0

    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if bd and bd.frame:IsShown() then
            bd.frame:ClearAllPoints()
            if isV then
                bd.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
                    ax, ay - idx * (barH + gap))
            else
                bd.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
                    ax + idx * (barW + gap), ay)
            end
            idx = idx + 1
        end
    end
end

function SUB:RestoreBarPosition(unit)
    local db      = self.db.profile
    local barData = self.bars[unit]
    if not barData then return end

    if db.positionMode == "anchored" then
        -- will be handled by ApplyAnchoredPositions after all bars are created
        return
    end

    local saved = db.bars[unit]
    barData.frame:ClearAllPoints()

    if saved.x and saved.y then
        barData.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", saved.x, saved.y)
    else
        -- default stacking
        local uIdx = UNIT_INDEX[unit] or 0
        barData.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
            10, -100 - uIdx * (db.buttonSize + HANDLE_HEIGHT + 6))
    end
end

function SUB:ResetAllPositions()
    local db = self.db.profile
    for _, unit in ipairs(UNITS) do
        db.bars[unit].x = nil
        db.bars[unit].y = nil
    end
    db.anchorX = 10
    db.anchorY = -100
    if db.positionMode == "anchored" then
        self:ApplyAnchoredPositions()
    else
        for _, unit in ipairs(UNITS) do
            self:RestoreBarPosition(unit)
        end
    end
end

-------------------------------------------------------------------------------
-- Lock / Unlock
-------------------------------------------------------------------------------

function SUB:SetLocked(locked)
    self.db.profile.locked = locked
    for _, unit in ipairs(UNITS) do
        local barData = self.bars[unit]
        if barData then
            barData.handle:EnableMouse(not locked)
            barData.handleBg:SetShown(not locked)
            self:UpdateLabelVisibility(unit)
        end
    end
end
