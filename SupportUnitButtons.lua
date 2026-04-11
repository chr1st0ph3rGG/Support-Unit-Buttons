-- SupportUnitButtons.lua
-- Core: addon creation, shared constants, lifecycle (OnInitialize/OnEnable)
--
-- All functional systems live in Core/*.lua:
--   Core/Positioning.lua           - positioning methods
--   Core/Layout.lua                - bar layout, labels, lock/drag
--   Core/Bars.lua                  - bar and button creation
--   Core/Dispel.lua                - dispel alert system
--   Core/Overlays/*.lua            - rank/cast/reagent/buff text overlays
--   Core/ButtonState.lua           - button state, roster, bag/power events
-------------------------------------------------------------------------------

local AddonName, SUB_NS = ...

local SUB               = LibStub("AceAddon-3.0"):NewAddon("SupportUnitButtons",
    "AceConsole-3.0",
    "AceEvent-3.0"
)

local LAB               = LibStub("LibActionButton-1.0")
local CE                = LibStub("C_Everywhere")
local AceDB             = LibStub("AceDB-3.0")
local AceCfg            = LibStub("AceConfig-3.0")
local AceCfgD           = LibStub("AceConfigDialog-3.0")
local AceDBOpt          = LibStub("AceDBOptions-3.0")
local LSM               = LibStub("LibSharedMedia-3.0")
local LibDispel         = LibStub("LibDispel-1.0", true)
local CT                = LibStub("CustomTutorials-2.1")

-- Shared Constants (available in SUB_NS for all Core/*.lua modules)
-------------------------------------------------------------------------------

SUB_NS.UNITS            = { "player", "party1", "party2", "party3", "party4" }
SUB_NS.UNIT_INDEX       = { player = 0, party1 = 1, party2 = 2, party3 = 3, party4 = 4 }
SUB_NS.MAX_SHARED       = 12
SUB_NS.MAX_INDIVIDUAL   = 6
SUB_NS.SEPARATOR_GAP    = 8  -- gap between shared and individual sections (px)
SUB_NS.HANDLE_HEIGHT    = 14 -- drag handle height (px)

local defaults          = SUB_NS.defaults

-- Addon State
-------------------------------------------------------------------------------

SUB.bars                = {}
SUB.masqueGroup         = nil
SUB.syncing             = false
SUB.dispelActiveUnits   = {}    -- unit → true when a dispellable debuff is active
SUB.dispelAlertPreview  = false -- runtime only; simulates debuff state for options preview
SUB.rezAlertPreview     = false -- runtime only; simulates rez state for options preview
SUB.rosterDirty         = false
SUB.emptyButtonsDirty   = false
SUB.sufPosPending       = false

-------------------------------------------------------------------------------
-- Lifecycle
-------------------------------------------------------------------------------

function SUB:OnInitialize()
    self.db = AceDB:New("SupportUnitButtonsDB", defaults)

    -- Wire knownBuffSpells to the persistent global table so knowledge about
    -- buff spells is accumulated across sessions.
    self:InitBuffSpells()

    self:InitializeMasque()

    -- Tutorial: embed CustomTutorials into SUB and register 5 pages.
    -- The savedvariable/key pair tracks the highest page seen per profile,
    -- so the popup appears automatically only on first login.
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

    -- Dispel system: prefill the name→types map (best effort; completed in
    -- ApplyAllButtonStates once the full spell cache is loaded).
    self:BuildDispelNameTypes()
    -- Resurrection system: same pattern, populated after SPELLS_CHANGED.
    self:BuildRezNameSpells()
    -- Re-evaluate highlights when LibDispel updates the player's dispel list
    -- (talent/spec changes, learning new spells, etc.).
    if LibDispel then
        local _orig = LibDispel.ListUpdated
        LibDispel.ListUpdated = function(ld)
            _orig(ld)
            SUB:UpdateAllDispelHighlights()
        end
    end
end

-- Registers runtime events and performs the initial bar setup after login.
function SUB:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnRosterUpdate")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnRosterUpdate")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd")
    -- Reapply macros once the spell/item cache is populated after login.
    self:RegisterEvent("SPELLS_CHANGED", "ApplyAllButtonStates")
    -- Dispel alert: reevaluate highlights when a unit's auras change.
    self:RegisterEvent("UNIT_AURA", "OnUnitAura")
    -- Resurrection alert: only register heavy runtime events while enabled.
    self:UpdateRezEventRegistrations()
    -- Cast count: update when player mana or bag contents change.
    -- UNIT_POWER_FREQUENT fires on every regen tick (Retail/Cata+).
    -- UNIT_POWER_UPDATE fires on cast/spend.
    -- UNIT_MANA is the Classic Era equivalent (fires on every mana change including ticks).
    self:RegisterEvent("UNIT_POWER_FREQUENT", "OnPlayerPowerUpdate")
    self:RegisterEvent("UNIT_POWER_UPDATE", "OnPlayerPowerUpdate")
    self:RegisterEvent("UNIT_MANA", "OnPlayerPowerUpdate")  -- Classic Era fallback
    self:RegisterEvent("BAG_UPDATE", "OnBagUpdate")
    self:RegisterEvent("BAG_UPDATE_DELAYED", "OnBagUpdate") -- fires once after all slot changes
    -- Retry individual button restore once a party member's name resolves.
    -- GROUP_ROSTER_UPDATE can fire before UnitName(), so this provides a second pass.
    self:RegisterEvent("UNIT_NAME_UPDATE", "OnUnitNameUpdate")

    self:CreateAllBars()
    self:ApplyShowEmptyButtonsOption()
    self:ApplyRosterUpdate()

    -- Show the tutorial automatically the first time (TriggerTutorial is a no-op
    -- once tutorialPage >= 5, so it only fires on a fresh profile).
    self:TriggerTutorial(5)

    -- Periodic consistency ticker:
    -- - Buff status countdown updates at a fixed 1s cadence.
    -- - Dispel highlight reconciliation at a configurable cadence as a safety
    --   net if UNIT_AURA updates are delayed/missed.
    local buffTicker    = CreateFrame("Frame")
    buffTicker._buffT   = 0
    buffTicker._dispelT = 0
    buffTicker._rezT    = 0
    buffTicker:SetScript("OnUpdate", function(ticker, elapsed)
        local db = SUB.db and SUB.db.profile
        if not db then return end

        ticker._buffT = ticker._buffT + elapsed
        if ticker._buffT >= 1 then
            ticker._buffT = 0
            if db.showBuffStatus then
                SUB:UpdateAllBuffStatuses()
            end
        end

        if db.dispelAlert and db.dispelAlertResync ~= false and not SUB.dispelAlertPreview then
            ticker._dispelT = ticker._dispelT + elapsed
            local interval = db.dispelAlertResyncInterval or 1.0
            if interval < 0.1 then interval = 0.1 end
            if ticker._dispelT >= interval then
                ticker._dispelT = 0
                SUB:UpdateAllDispelHighlights()
            end
        else
            ticker._dispelT = 0
        end

        if db.rezAlert and db.rezAlertResync ~= false and not SUB.rezAlertPreview then
            ticker._rezT = ticker._rezT + elapsed
            local interval = db.rezAlertResyncInterval or 2.0
            if interval < 0.1 then interval = 0.1 end
            if ticker._rezT >= interval then
                ticker._rezT = 0
                SUB:ResyncRezHighlights()
            end
        else
            ticker._rezT = 0
        end
    end)
end

-- Opens the addon options panel via chat commands.
function SUB:ChatCommand()
    AceCfgD:Open("SupportUnitButtons")
end

-- Restarts the tutorial from page 1.
function SUB:ShowTutorial()
    self:ResetTutorials()
    self:TriggerTutorial(5)
end
