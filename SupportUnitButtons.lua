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

    -- Buff status countdown ticker: updates remaining time every second.
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

-- Opens the addon options panel via chat commands.
function SUB:ChatCommand()
    AceCfgD:Open("SupportUnitButtons")
end

-- Restarts the tutorial from page 1.
function SUB:ShowTutorial()
    self:ResetTutorials()
    self:TriggerTutorial(5)
end
