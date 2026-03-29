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
SUB.dispelActiveUnits   = {}    -- unit → true when a dispellable debuff is currently active
SUB.dispelAlertPreview  = false -- runtime-only; simulates debuff state for options preview

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

-- Maps debuff type names to their per-type color key in the DB profile.
local DEBUFF_COLOR_KEY  = {
    Magic   = "dispelAlertColorMagic",
    Curse   = "dispelAlertColorCurse",
    Poison  = "dispelAlertColorPoison",
    Disease = "dispelAlertColorDisease",
}

-- Returns the color table to use for a dispel alert, respecting the
-- per-debuff-type color setting when enabled.
local function GetDispelColor(db, debuffType)
    if db.dispelAlertTypeColorsEnabled and debuffType then
        local key = DEBUFF_COLOR_KEY[debuffType]
        if key then return db[key] or db.dispelAlertColor end
    end
    return db.dispelAlertColor
end

-- Spell-name → { DebuffType = true }.  Built after spells load so every rank
-- of a multi-rank Classic spell matches automatically (they share a name).
local dispelNameTypes = {}

-- Rebuilds the spell-name dispel map from the static spell-ID mapping table.
local function BuildDispelNameTypes()
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

-- Resolves `action` (spell ID or name string) to its dispel-type table, or nil.
-- Tries a direct ID lookup first; falls back to the name map for multi-rank
-- Classic spells where only the base rank ID may be in DISPEL_ID_TYPES.
local function GetDispelTypesByAction(action)
    local id = tonumber(action)
    if id and DISPEL_ID_TYPES[id] then return DISPEL_ID_TYPES[id] end
    local info = CE.Spell.GetSpellInfo(id or action)
    return info and dispelNameTypes[info.name]
end

-- Returns the dispel-type table for the spell on `btn`, or nil.
-- Guards against non-spell buttons and missing actions before delegating.
local function GetButtonDispelTypes(btn)
    if btn._state_type ~= "spell" then return nil end
    local action = btn._state_action
    if not action then return nil end
    return GetDispelTypesByAction(action)
end

-- Returns (or lazily creates) the dispel-alert overlay for `btn`.
-- Shape ("square"|"circle") and the alpha envelope (alphaMin → alphaMax) are
-- configurable.  "square" uses four coloured edge strips; "circle" uses a
-- pre-rendered ring texture (Textures/circle_ring.tga) for a true circle.
local function GetOrCreateDispelOverlay(btn)
    if btn.SUB_dispelOverlay then return btn.SUB_dispelOverlay end
    local ov = CreateFrame("Frame", nil, btn)
    ov:Hide()

    local function makeStrip()
        local t = ov:CreateTexture(nil, "OVERLAY")
        t:SetTexture([[Interface\Buttons\WHITE8X8]])
        return t
    end
    ov.eT = makeStrip() -- top edge
    ov.eB = makeStrip() -- bottom edge
    ov.eL = makeStrip() -- left edge
    ov.eR = makeStrip() -- right edge

    -- Circle mode: single pre-rendered ring texture (white ring on transparent
    -- background) coloured at runtime via SetVertexColor.  Gives a true circle
    -- instead of the rectangular-segment approximation.
    ov.eRing = ov:CreateTexture(nil, "OVERLAY")
    ov.eRing:SetTexture([[Interface\AddOns\SupportUnitButtons\Textures\circle_ring]])
    ov.eRing:SetAllPoints(ov)
    ov.eRing:Hide()

    -- Animate per-texture, not per-frame.  Frame:SetAlpha() composites the whole
    -- rectangular frame area (including empty/transparent regions) into an
    -- off-screen buffer and blends that rectangle onto the screen, producing a
    -- visible transparent rectangle over the button icon.
    ov._t = 0
    ov:SetScript("OnUpdate", function(self, elapsed)
        self._t        = self._t + elapsed
        local speed    = SUB.db and SUB.db.profile.dispelAlertPulseSpeed or 2.5
        local alphaMin = SUB.db and SUB.db.profile.dispelAlertAlphaMin or 0.0
        local alphaMax = SUB.db and SUB.db.profile.dispelAlertAlphaMax or 1.0
        -- Smooth cosine oscillation: phase goes 0 → 1 → 0 with no dead-time.
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

-- Hides the dispel overlay on a button when no alert should be shown.
local function HideDispelOverlay(btn)
    if btn.SUB_dispelOverlay then
        btn.SUB_dispelOverlay:Hide()
    end
end

-- Returns any dispel type from the map for options-preview rendering.
local function GetPreviewDispelType(types)
    for t in pairs(types) do
        return t
    end
    return nil
end

-- Iterates up to 40 harmful auras on `unit` and returns the debuff type of the
-- first one whose type is present in `types`, or nil if none matches.
local function FindDispellableAura(unit, types)
    for i = 1, 40 do
        local name, _, _, debuffType = CE.Unit.UnitAura(unit, i, "HARMFUL")
        if not name then break end
        if debuffType and types[debuffType] then return debuffType end
    end
end

-- Returns the first dispellable debuff type on `unit` given the spell's `types`
-- table, or nil if the unit doesn't exist or has no matching debuff.
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

-- Renders the circular alert style by showing only the ring texture.
local function ShowCircleOverlay(ov, col)
    ov.eT:Hide()
    ov.eB:Hide()
    ov.eL:Hide()
    ov.eR:Hide()
    ov.eRing:SetVertexColor(col.r, col.g, col.b, 1)
    ov.eRing:Show()
end

-- Renders the square alert style by sizing and showing the four edge strips.
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

-- Applies visual config (padding, color, shape, border width) and shows overlay.
local function ConfigureDispelOverlay(sub, btn, ov, foundType)
    -- dispelAlertPadding: positive = extends outside the button edge,
    -- negative = inset inside the button.
    local db = sub.db.profile
    local pad = db.dispelAlertPadding
    if pad == nil then pad = 3 end
    PositionDispelOverlay(btn, ov, pad)

    local col = GetDispelColor(db, foundType)
    local shape = db.dispelAlertShape or "square"
    local bwCfg = db.dispelAlertBorderWidth or 0
    local bw = bwCfg > 0 and bwCfg or math.max(2, math.floor(btn:GetWidth() * 0.06))

    -- Colour the square-mode strips up front; circle ring is coloured in its branch.
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

-- Show or hide the dispel-alert overlay for a single button.
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

-- Updates dispel highlights for all buttons in `buttons` and returns true if
-- any overlay is currently shown.
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

-- Refreshes dispel highlights for all buttons on `unit`'s bar and updates
-- dispelActiveUnits accordingly.  Returns true if any overlay is shown.
function SUB:UpdateDispelHighlightsForUnit(unit)
    local bd = self.bars[unit]
    if not bd then return end
    local a = UpdateButtonListAndCheckActive(self, bd.sharedButtons)
    local b = UpdateButtonListAndCheckActive(self, bd.individualButtons)
    self.dispelActiveUnits[unit] = a or b
    return a or b
end

-- Update every button on every bar.
function SUB:UpdateAllDispelHighlights()
    for _, unit in ipairs(UNITS) do
        self:UpdateDispelHighlightsForUnit(unit)
    end
end

-- Called when a unit's auras change.
function SUB:OnUnitAura(event, unit)
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
function SUB:OnPlayerPowerUpdate(event, unit, powerType)
    -- UNIT_POWER_UPDATE fires for every unit/power; only care about player mana.
    -- powerType is a number (0 = mana) in Retail/Cata+, or a string ("MANA") in Classic Era.
    -- UNIT_MANA (Classic) fires without powerType at all → powerType = nil, always passes.
    if unit and unit ~= "player" then return end
    if powerType and powerType ~= 0 and powerType ~= "MANA" then return end
    if not self.db.profile.showCastCount then return end
    self:UpdateAllCastCounts()
end

-- Calls fn(btn) for every button (shared + individual) on every active bar.
local function ForEachButton(bars, fn)
    for _, unit in ipairs(UNITS) do
        local bd = bars[unit]
        if bd then
            for _, btn in ipairs(bd.sharedButtons)    do fn(btn) end
            for _, btn in ipairs(bd.individualButtons) do fn(btn) end
        end
    end
end

-- Refreshes the native LAB count for a single spell button (skipped if the
-- custom overlay already covers it or the button has no action).
local function RefreshNativeLABCount(btn)
    if btn._state_type ~= "spell" or btn.SUB_reagentCountHidden then return end
    if btn.Count and btn:HasAction() then
        btn.Count:SetText(btn:GetDisplayCount())
    end
end

-- Called when bag contents change; refreshes reagent and item-count labels.
function SUB:OnBagUpdate()
    -- Custom reagent count overlay (hides native LAB count for covered buttons).
    self:UpdateAllReagentCounts()
    -- Refresh native LAB count for spell buttons not covered by the custom overlay.
    -- LAB does not listen to BAG_UPDATE for spell-type buttons.
    ForEachButton(self.bars, RefreshNativeLABCount)
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
        [1]           = { title = L["TUTORIAL_TITLE"], text = L["TUTORIAL_P1"], image = "Interface\\AddOns\\SupportUnitButtons\\Textures\\sub_tutorial_bars", imageW = 300, imageH = 77 },
        [2]           = { title = L["TUTORIAL_TITLE"], text = L["TUTORIAL_P2"], image = "Interface\\AddOns\\SupportUnitButtons\\Textures\\sub_tutorial_button", imageW = 300, imageH = 200 },
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

-- Registers runtime events and performs initial bar setup after login.
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

-- Opens the addon options panel from chat commands.
function SUB:ChatCommand()
    AceCfgD:Open("SupportUnitButtons")
end

-- Restarts and shows the tutorial from page one.
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
    TOP         = { 0, 1 },
    BOTTOM      = { 0, -1 },
    LEFT        = { -3, 0 },
    RIGHT       = { 3, 0 },
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

-- Attach a reagent-count FontString to a button (corner set dynamically on update).
local function AttachReagentCountText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_reagentCountText = fs
end

-- Attach a buff-status FontString to a button (corner set dynamically on update).
local function AttachBuffStatusText(btn)
    local fs = GetOrCreateTextOverlay(btn):CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fs:SetText("")
    btn.SUB_buffStatusText = fs
end

-- Searches `costTable` for a mana entry (type == 0) and returns its cost, or nil.
local function FindManaCostEntry(costTable)
    for _, entry in ipairs(costTable) do
        if entry.type == 0 then return entry.cost end
    end
end

-- Returns the mana cost of `spellId`, or nil if unavailable or non-mana.
local function GetSpellManaCost(spellId)
    local getCost = CE.Spell.GetSpellPowerCost
    if not getCost then return nil end
    local costTable = getCost(spellId)
    if not costTable then return nil end
    return FindManaCostEntry(costTable)
end

-- Returns how often the spell can be cast with current mana, or nil.
local function GetSpellCastCount(action)
    local id = tonumber(action)
    if not id then return nil end
    local manaCost = GetSpellManaCost(id)
    if not manaCost or manaCost <= 0 then return nil end
    local currentMana = UnitPower("player", 0) or UnitMana("player") or 0
    return math.floor(currentMana / manaCost)
end

-- Returns the item amount in bags for an item-action string, or nil.
local function GetItemCastCount(action)
    local id = action and tonumber(action:match("item:(%d+)"))
    if not id or not GetItemCount then return nil end
    return GetItemCount(id)
end

-- Dispatches cast-count lookup by action type (spell or item).
local function GetCastCountValue(btnType, action)
    if btnType == "spell" then return GetSpellCastCount(action) end
    if btnType == "item" then return GetItemCastCount(action) end
    return nil
end


-- Creates bars for all managed units.
function SUB:CreateAllBars()
    for _, unit in ipairs(UNITS) do
        self:CreateBar(unit)
    end
end

-- Creates one complete unit bar including secure header and all buttons.
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
        AttachReagentCountText(btn)
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
        AttachReagentCountText(btn)
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

-- Dispatch table for type-specific macro builders.
local MACRO_BUILDERS = {
    spell = BuildSpellMacroText,
    item = BuildItemMacroText,
}

-- Builds unit-targeted macro text for supported action types.
local function BuildMacroText(unit, btnType, action)
    local builder = MACRO_BUILDERS[btnType]
    if not builder then return nil end
    return builder(unit, action)
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

-- Repositions and resizes all buttons on one unit bar.
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

-- Re-applies layout sizing/positions to all bars.
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

-- Refreshes label visibility and text for every bar.
function SUB:UpdateAllLabelVisibility()
    for _, unit in ipairs(UNITS) do
        self:UpdateLabelVisibility(unit)
    end
end

-- Applies the show-empty-slots grid setting to all buttons.
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

-- Persists and applies the show-empty-slots option.
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

local DRAG_MODIFIER_CHECK = {
    ANY   = function() return CE.Input.IsShiftKeyDown() or CE.Input.IsControlKeyDown() or CE.Input.IsAltKeyDown() end,
    SHIFT = function() return CE.Input.IsShiftKeyDown() end,
    CTRL  = function() return CE.Input.IsControlKeyDown() end,
    ALT   = function() return CE.Input.IsAltKeyDown() end,
}

-- Returns true if the configured drag modifier key is currently held.
function SUB:IsDragModifierHeld()
    local check = DRAG_MODIFIER_CHECK[self.db.profile.dragOffModifier]
    return check and check() or false
end

-- Restore a button's previous content without triggering another callback loop.
function SUB:RestoreButtonSilent(btn, btnType, action)
    self.syncing = true
    self:ApplyButtonState(btn, btnType, action)
    self.syncing = false
    ClearCursor()
end

-- Returns true when the drop operation would clear the button.
local function IsEmptyButtonState(btnType, action)
    return not btnType or btnType == "empty" or not action
end

-- Returns true when a slot currently stores a non-empty action.
local function SlotHasAssignedAction(slot)
    return slot and slot.btnType and slot.btnType ~= "empty"
end

-- Restores previous content if drag-off is blocked by modifier settings.
local function RestoreIfDragOffBlocked(sub, btn, isEmpty, slot)
    if isEmpty and SlotHasAssignedAction(slot) and not sub:IsDragModifierHeld() then
        sub:RestoreButtonSilent(btn, slot.btnType, slot.action)
        return true
    end
    return false
end

-- Applies shared-slot storage update and synchronizes the slot to all units.
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

-- Handles LAB content-change callbacks and dispatches to the appropriate
-- section handler based on btn.SUB_section.
function SUB:OnButtonContentsChanged(event, btn, state, btnType, action)
    if self.syncing or tostring(state) ~= "0" then return end
    local unit, section, index = GetButtonContext(btn)
    if not unit then return end
    local handler = SECTION_HANDLER[section]
    if handler then
        handler(self, btn, unit, index, btnType, action, IsEmptyButtonState(btnType, action))
    end
end

-- Clears one shared button to an empty state.
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

-- Applies a shared-slot sync update to one target button.
function SUB:SyncSharedSlotButton(btn, isEmpty, btnType, action)
    if isEmpty then
        self:ClearSharedButton(btn)
    else
        self:ApplyButtonState(btn, btnType, action)
    end
end

-- Propagates shared slot changes from one unit to all other unit bars.
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

-- Updates spell-rank text for one button according to current options.
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

-- Refreshes rank text for every visible/assigned button.
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

-- Updates cast-count text (spell casts or item amount) for one button.
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

-- Refreshes cast-count labels on all bars.
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
-- Reagent Count
--
-- Shows how many times a reagent-based spell can be cast given current bag
-- contents.  Replaces the native LAB count for those buttons so it can be
-- placed in a freely configurable corner.
-------------------------------------------------------------------------------

local function RestoreNativeCount(btn)
    if btn.SUB_reagentCountHidden and btn.Count then
        btn.Count:Show()
        btn.SUB_reagentCountHidden = nil
    end
end

-- Returns the cast count for a reagent spell, or nil when the overlay is disabled.
local function GetReagentDisplayCount(btn, btnType, action, db)
    if not db or not db.showReagentCount then return nil end
    if btnType ~= "spell" or not action then return nil end
    local count = btn.GetDisplayCount and btn:GetDisplayCount()
    return (count and count ~= 0) and count or nil
end

local function ApplyReagentCountStyle(fs, btn, db, count)
    -- Hide native LAB count and show custom overlay.
    if btn.Count and not btn.SUB_reagentCountHidden then
        btn.Count:Hide()
        btn.SUB_reagentCountHidden = true
    end
    local corner   = db.reagentCountCorner or "TOPRIGHT"
    local off      = CORNER_OFFSET[corner] or CORNER_OFFSET.TOPRIGHT
    fs:ClearAllPoints()
    fs:SetPoint(corner, btn, corner, off[1] + (db.reagentCountOffsetX or 0), off[2] + (db.reagentCountOffsetY or 0))
    local c        = db.reagentCountColor or { r = 1, g = 0.5, b = 0.0, a = 1 }
    local flags    = (db.reagentCountOutline and db.reagentCountOutline ~= "NONE") and db.reagentCountOutline or ""
    local fontPath = LSM:Fetch("font", db.reagentCountFont or "Friz Quadrata TT")
    fs:SetFont(fontPath, db.reagentCountFontSize or 9, flags)
    fs:SetTextColor(c.r or 1, c.g or 1, c.b or 1, c.a or 1)
    fs:SetText(tostring(count))
end

-- Updates the custom reagent-count overlay for one button.
function SUB:UpdateButtonReagentCount(btn, btnType, action)
    local fs = btn.SUB_reagentCountText
    if not fs then return end
    local db    = self.db and self.db.profile
    local count = GetReagentDisplayCount(btn, btnType, action, db)
    if not count then
        fs:SetText("")
        RestoreNativeCount(btn)
        return
    end
    ApplyReagentCountStyle(fs, btn, db, count)
end

-- Refreshes reagent-count overlays on all bars.
function SUB:UpdateAllReagentCounts()
    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if bd then
            for _, btn in ipairs(bd.sharedButtons) do
                local t, a = btn:GetAction()
                self:UpdateButtonReagentCount(btn, t, a)
            end
            for _, btn in ipairs(bd.individualButtons) do
                local t, a = btn:GetAction()
                self:UpdateButtonReagentCount(btn, t, a)
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

-- Scans helpful auras on `unit` for a player-cast buff matching `spellName`.
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

-- Formats a positive remaining buff duration into h/m/s units.
local function FormatPositiveBuffTime(remaining)
    for _, fmt in ipairs(BUFF_TIME_FORMATS) do
        if remaining >= fmt.min then
            return math.ceil(remaining / fmt.div) .. fmt.suffix
        end
    end
    return "0"
end

-- Formats any remaining duration while guarding non-positive values.
local function FormatBuffTime(remaining)
    if remaining <= 0 then return "0" end
    return FormatPositiveBuffTime(remaining)
end

-- Applies corner, offsets and font settings for the buff-status text.
local function ConfigureBuffStatusTextLayout(fs, btn, db)
    local corner   = db.buffStatusCorner or "BOTTOMLEFT"
    local off      = CORNER_OFFSET[corner] or CORNER_OFFSET.BOTTOMLEFT
    local flags    = (db.buffStatusOutline and db.buffStatusOutline ~= "NONE") and db.buffStatusOutline or ""
    local fontPath = LSM:Fetch("font", db.buffStatusFont or "Friz Quadrata TT")
    fs:ClearAllPoints()
    fs:SetPoint(corner, btn, corner, off[1] + (db.buffStatusOffsetX or 0), off[2] + (db.buffStatusOffsetY or 0))
    fs:SetFont(fontPath, db.buffStatusFontSize or 9, flags)
end

-- Applies color and text in one place for buff-status output.
local function SetBuffStatusDisplay(fs, color, text)
    fs:SetTextColor(color.r, color.g, color.b, color.a)
    fs:SetText(text)
end

-- Displays active buff state: '~' for timeless buffs or remaining duration.
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

-- Displays '-' when this spell is known as a buff but currently inactive.
local function ShowInactiveKnownBuffStatus(btn, fs, db)
    -- Known buff spell, but currently not active on this unit.
    btn.SUB_buffExpiry = nil
    local c = db.buffStatusColor or { r = 1, g = 1, b = 0, a = 1 }
    SetBuffStatusDisplay(fs, c, "-")
end

-- Clears text when the spell is not known as a buff spell.
local function ShowUnknownBuffStatus(btn, fs)
    -- Not a buff spell (or never seen as a buff) -> show nothing.
    btn.SUB_buffExpiry = nil
    fs:SetText("")
end

-- Chooses which buff-status presentation to show for the current spell.
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

-- Updates one button's buff-status indicator text and color.
-- Returns the spell name to display buff status for, or nil if the feature is
-- disabled, the button is empty, or no spell name can be resolved.
local function GetBuffSpellForButton(btn, db)
    if not db or not db.showBuffStatus then return nil end
    local btnType = btn._state_type
    if not btnType or btnType == "empty" then return nil end
    return GetButtonSpellName(btn)
end

-- Refreshes the buff-status text overlay on `btn`.  Clears it when no
-- applicable spell is found; otherwise delegates to the display helpers.
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

-- Refreshes buff-status indicators for all unit bars.
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

-- Refreshes buff-status indicators for one unit bar.
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

local function ClearTextFrame(fs)
    if fs then fs:SetText("") end
end

local function ClearButtonOverlays(btn)
    btn:SetAttribute("SUB_macro", nil)
    ClearTextFrame(btn.SUB_rankText)
    ClearTextFrame(btn.SUB_reagentCountText)
    RestoreNativeCount(btn)
    ClearTextFrame(btn.SUB_castCountText)
    ClearTextFrame(btn.SUB_buffStatusText)
end

-- Clears all text overlays and metadata when a button slot becomes empty.
local function ClearButtonState(self, btn)
    ClearButtonOverlays(btn)
    self:UpdateDispelHighlight(btn)
end

-- Assigns the unit-targeted macro attribute for spell/item buttons, or clears it.
-- The PreClick/PostClick WrapScript swaps to this macro for execution, then
-- restores the original type so LAB keeps showing icon/cooldown/tooltip correctly.
local function ApplyMacroAttribute(btn, unit, btnType, action)
    if unit and (btnType == "spell" or btnType == "item") then
        btn:SetAttribute("SUB_macro", BuildMacroText(unit, btnType, action))
    else
        btn:SetAttribute("SUB_macro", nil)
    end
end

-- Updates all visual state and attributes for a button with a live action.
function SUB:ApplyButtonState(btn, btnType, action)
    if not btnType or btnType == "empty" or not action then
        ClearButtonState(self, btn)
        return
    end
    if CE.Combat.InCombatLockdown() then return end
    ApplyMacroAttribute(btn, btn.SUB_unit, btnType, action)
    -- Always use the native type so LAB can resolve icon, cooldown, tooltip.
    btn:SetState(nil, btnType, action)
    self:UpdateButtonRankText(btn, btnType, action)
    self:UpdateButtonReagentCount(btn, btnType, action)
    self:UpdateButtonCastCount(btn, btnType, action)
    self:UpdateDispelHighlight(btn)
    self:UpdateButtonBuffStatus(btn)
end

-- Restores one shared button from saved profile data.
function SUB:RestoreSharedButton(unit, btn, index)
    local slot = self.db.char.sharedSlots[index]
    if slot and slot.btnType then
        self:ApplyButtonState(btn, slot.btnType, slot.action)
    end
end

-- Clears one individual button to an empty state.
local function ClearIndividualButton(btn)
    if CE.Combat.InCombatLockdown() then return end
    btn:SetState(nil, "empty", nil)
    ClearButtonOverlays(btn)
end

-- Rebuilds individual buttons for one unit from per-character slot data.
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

-- Applies stored slot state to all shared buttons on `bd`.
local function ApplySharedSlots(self, bd, sharedSlots)
    for i = 1, MAX_SHARED do
        local slot = sharedSlots[i]
        if slot and slot.btnType then
            self:ApplyButtonState(bd.sharedButtons[i], slot.btnType, slot.action)
        end
    end
end

-- Reapplies all stored button states across every unit bar.
-- Also refreshes the dispel name map now that the full spell cache is available.
function SUB:ApplyAllButtonStates()
    if CE.Combat.InCombatLockdown() then return end
    BuildDispelNameTypes()
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
-- Visibility
-------------------------------------------------------------------------------

function SUB:ShouldShowPlayerBar()
    local db = self.db.profile
    if not db.showPlayer then return false end
    if db.showPlayerOnlyInParty then return CE.Party.IsInGroup() and true or false end
    return true
end

-- Applies deferred updates after leaving combat lockdown.
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
function SUB:OnUnitNameUpdate(event, unit)
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

-- Runs follow-up updates for bars that are currently visible.
local function RefreshVisibleBarState(sub, unit)
    sub:UpdateLabelVisibility(unit)
    if unit ~= "player" then
        sub:RefreshIndividualButtons(unit)
    end
end

-- Updates bar visibility and dependent state for current group roster.
-- Shows/hides `unit`'s bar and refreshes its state if visible.
local function UpdateBarVisibility(self, unit)
    local show = ShouldShowBarForUnit(self, unit)
    self.bars[unit].frame:SetShown(show)
    if show then RefreshVisibleBarState(self, unit) end
end

-- Refreshes bar visibility for all units.
-- Protected frames cannot call SetShown during combat lockdown, so updates
-- are deferred via rosterDirty until combat ends.
function SUB:OnRosterUpdate()
    if CE.Combat.InCombatLockdown() then
        self.rosterDirty = true
        return
    end
    for _, unit in ipairs(UNITS) do
        local barData = self.bars[unit]
        if not barData then break end
        UpdateBarVisibility(self, unit)
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

-- Restores one bar position from saved coordinates or default stack.
-- Positions `frame` from saved coordinates, or falls back to default stacking.
local function SetBarPosition(frame, unit, saved, db)
    frame:ClearAllPoints()
    if saved.x and saved.y then
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", saved.x, saved.y)
    else
        local uIdx = UNIT_INDEX[unit] or 0
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
            10, -100 - uIdx * (db.buttonSize + HANDLE_HEIGHT + 6))
    end
end

-- Restores `unit`'s bar to its saved position, or skips if anchored mode is active.
function SUB:RestoreBarPosition(unit)
    local db      = self.db.profile
    local barData = self.bars[unit]
    if not barData then return end
    if db.positionMode == "anchored" then return end
    SetBarPosition(barData.frame, unit, db.bars[unit], db)
end

-- Resets all saved bar positions and reapplies active positioning mode.
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
