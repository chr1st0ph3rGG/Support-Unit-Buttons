-------------------------------------------------------------------------------
-- SupportUnitButtons.lua
-- Core: Addon-Erstellung, geteilte Konstanten, Lifecycle (OnInitialize/OnEnable)
--
-- Alle funktionalen Systeme leben in Core/*.lua:
--   Core/Positioning.lua  – SUF-Integration, Positions-Methoden
--   Core/Layout.lua       – Bar-Layout, Labels, Lock/Drag
--   Core/Bars.lua         – Bar- und Button-Erstellung
--   Core/Dispel.lua       – Dispel-Alert-System
--   Core/Overlays.lua     – Rang/Cast/Reagent/Buff-Text-Overlays
--   Core/ButtonState.lua  – Button-State, Roster, Bag/Power-Events
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

-------------------------------------------------------------------------------
-- Geteilte Konstanten (in SUB_NS für alle Core/*.lua-Module verfügbar)
-------------------------------------------------------------------------------

SUB_NS.UNITS            = { "player", "party1", "party2", "party3", "party4" }
SUB_NS.UNIT_INDEX       = { player = 0, party1 = 1, party2 = 2, party3 = 3, party4 = 4 }
SUB_NS.MAX_SHARED       = 12
SUB_NS.MAX_INDIVIDUAL   = 6
SUB_NS.SEPARATOR_GAP    = 8 -- Abstand zwischen Shared- und Individual-Sektion (px)
SUB_NS.HANDLE_HEIGHT    = 14 -- Drag-Handle-Höhe (px)

local defaults          = SUB_NS.defaults

-------------------------------------------------------------------------------
-- Addon-Zustand
-------------------------------------------------------------------------------

SUB.bars                = {}
SUB.masqueGroup         = nil
SUB.syncing             = false
SUB.dispelActiveUnits   = {}    -- unit → true wenn ein dispelbarer Debuff aktiv ist
SUB.dispelAlertPreview  = false -- nur zur Laufzeit; simuliert Debuff-Zustand für Options-Preview
SUB.rosterDirty         = false
SUB.emptyButtonsDirty   = false
SUB.sufPosPending       = false

-------------------------------------------------------------------------------
-- Lifecycle
-------------------------------------------------------------------------------

function SUB:OnInitialize()
    self.db = AceDB:New("SupportUnitButtonsDB", defaults)

    -- knownBuffSpells mit der persistenten global-Tabelle verdrahten, damit
    -- Wissen über Buff-Spells sitzungsübergreifend angesammelt wird.
    self:InitBuffSpells()

    self:InitializeMasque()

    -- Tutorial: CustomTutorials in SUB einbetten und 5 Seiten registrieren.
    -- Das savedvariable/key-Paar verfolgt die höchste gesehene Seite pro Profil,
    -- damit das Popup automatisch nur beim ersten Login erscheint.
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

    -- Dispel-System: Name→Typen-Map vorab befüllen (best-effort; wird in
    -- ApplyAllButtonStates vervollständigt sobald der vollständige Spell-Cache geladen ist).
    self:BuildDispelNameTypes()
    -- Highlights neu prüfen wenn LibDispel die Dispel-Liste des Spielers aktualisiert
    -- (Talent/Spec-Änderungen, neue Spells lernen, etc.).
    if LibDispel then
        local _orig = LibDispel.ListUpdated
        LibDispel.ListUpdated = function(ld)
            _orig(ld)
            SUB:UpdateAllDispelHighlights()
        end
    end
end

-- Registriert Laufzeit-Events und führt das initiale Bar-Setup nach dem Login durch.
function SUB:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnRosterUpdate")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnRosterUpdate")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd")
    -- Macros neu anwenden sobald der Spell/Item-Cache nach dem Login befüllt ist.
    self:RegisterEvent("SPELLS_CHANGED", "ApplyAllButtonStates")
    -- Dispel-Alert: Highlights neu auswerten wenn sich Auren einer Unit ändern.
    self:RegisterEvent("UNIT_AURA", "OnUnitAura")
    -- Cast-Count: aktualisieren wenn sich Spieler-Mana oder Tascheninhalt ändert.
    -- UNIT_POWER_FREQUENT feuert bei jedem Regen-Tick (Retail/Cata+).
    -- UNIT_POWER_UPDATE feuert bei Cast/Verbrauch.
    -- UNIT_MANA ist das Classic-Era-Äquivalent (feuert bei jeder Mana-Änderung inkl. Ticks).
    self:RegisterEvent("UNIT_POWER_FREQUENT", "OnPlayerPowerUpdate")
    self:RegisterEvent("UNIT_POWER_UPDATE", "OnPlayerPowerUpdate")
    self:RegisterEvent("UNIT_MANA", "OnPlayerPowerUpdate")  -- Classic Era Fallback
    self:RegisterEvent("BAG_UPDATE", "OnBagUpdate")
    self:RegisterEvent("BAG_UPDATE_DELAYED", "OnBagUpdate") -- feuert einmal nach allen Slot-Änderungen
    -- Individual-Button-Restore wiederholen sobald der Name eines Party-Mitglieds aufgelöst wird.
    -- GROUP_ROSTER_UPDATE kann vor UnitName() feuern, daher dieser zweite Durchlauf.
    self:RegisterEvent("UNIT_NAME_UPDATE", "OnUnitNameUpdate")

    self:CreateAllBars()
    self:ApplyShowEmptyButtonsOption()
    self:ApplyRosterUpdate()

    -- Tutorial automatisch beim ersten Mal anzeigen (TriggerTutorial ist ein No-Op
    -- sobald tutorialPage >= 5, feuert also nur bei einem frischen Profil).
    self:TriggerTutorial(5)

    -- Buff-Status-Countdown-Ticker: aktualisiert verbleibende Zeit jede Sekunde.
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

-- Öffnet das Addon-Options-Panel über Chat-Commands.
function SUB:ChatCommand()
    AceCfgD:Open("SupportUnitButtons")
end

-- Startet das Tutorial von Seite 1 neu.
function SUB:ShowTutorial()
    self:ResetTutorials()
    self:TriggerTutorial(5)
end
