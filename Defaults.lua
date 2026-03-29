-------------------------------------------------------------------------------
-- Defaults.lua
-------------------------------------------------------------------------------

local AddonName, SUB_NS = ...

SUB_NS.defaults = {
    profile = {
        locked                       = false,
        buttonSize                   = 36,
        buttonSpacing                = 2,
        sharedCount                  = 6,
        individualCount              = 3,
        separatorGap                 = 8,
        showPlayer                   = true,
        showPlayerOnlyInParty        = false,
        showLabels                   = true,  -- show name labels while locked
        showEmptyButtons             = true,  -- keep empty slots visible permanently
        positionMode                 = "anchored", -- "free" | "anchored"
        anchorDirection              = "vertical", -- "vertical" | "horizontal"
        anchorGap                    = 4,     -- gap between bars in anchored mode (px)
        anchorX                      = 10,    -- TOPLEFT x offset from UIParent in anchored mode
        anchorY                      = -100,  -- TOPLEFT y offset from UIParent in anchored mode
        bars                         = {
            ["*"] = { x = nil, y = nil },
        },
        dragOffModifier              = "SHIFT", -- modifier required to drag a spell OFF a button
        showSpellRank                = true,
        spellRankFont                = "2002 Bold",
        spellRankFontSize            = 9,
        spellRankColor               = { r = 1, g = 1, b = 1, a = 1 },
        spellRankOutline             = "OUTLINE",
        spellRankCorner              = "BOTTOMRIGHT",
        spellRankOffsetX             = -1,
        spellRankOffsetY             = 1,
        showReagentCount             = true,  -- show custom reagent count overlay for reagent-based spells
        reagentCountFont             = "2002 Bold",
        reagentCountFontSize         = 9,
        reagentCountColor            = { r = 1, g = 0.5, b = 0.0, a = 1 }, -- orange
        reagentCountOutline          = "OUTLINE",
        reagentCountCorner           = "TOPRIGHT",
        reagentCountOffsetX          = -1,
        reagentCountOffsetY          = -1,
        showCastCount                = true, -- show casts-until-OOM (spells) or item count
        castCountFont                = "2002 Bold",
        castCountFontSize            = 9,
        castCountSpellColor          = { r = 0.016, g = 0.980, b = 0.969, a = 1 }, -- blau für ZSUBer (#04FAF7)
        castCountItemColor           = { r = 1, g = 0.8, b = 0.2, a = 1 },    -- gold für Items
        castCountOutline             = "OUTLINE",
        castCountCorner              = "TOPLEFT",
        castCountOffsetX             = 1,
        castCountOffsetY             = -1,
        dispelAlert                  = true,
        dispelAlertColor             = { r = 1.0, g = 0.0, b = 0.0 },
        dispelAlertAlphaMin          = 0.0,     -- minimum opacity at animation trough (0 = full pulse)
        dispelAlertAlphaMax          = 1.0,     -- maximum opacity at animation peak
        dispelAlertPulseSpeed        = 2.5,     -- animation frequency multiplier
        dispelAlertBorderWidth       = 0,       -- 0 = auto (6 % of button width), else manual px
        dispelAlertPadding           = 3,       -- outset from button edge in px (negative = inset)
        dispelAlertShape             = "square", -- "square" | "circle"
        dispelAlertTypeColorsEnabled = false,
        dispelAlertColorMagic        = { r = 0.20, g = 0.60, b = 1.00 },
        dispelAlertColorCurse        = { r = 0.60, g = 0.00, b = 1.00 },
        dispelAlertColorPoison       = { r = 0.00, g = 0.80, b = 0.20 },
        dispelAlertColorDisease      = { r = 0.80, g = 0.55, b = 0.10 },
        dispelAlertSoundEnabled      = false,
        dispelAlertSound             = nil, -- LSM sound name; nil = kein Sound
        dispelAlertSoundChannel      = "Master",
        showBuffStatus               = true,
        buffStatusCorner             = "BOTTOMLEFT",
        buffStatusFont               = "2002 Bold",
        buffStatusFontSize           = 9,
        buffStatusColor              = { r = 1.0, g = 1.0, b = 0.0, a = 1 }, -- gelb
        buffStatusLowColor           = { r = 1.0, g = 0.0, b = 0.0, a = 1 }, -- rot wenn unter Schwellwert
        buffStatusLowThreshold       = 60,                              -- Sekunden
        buffStatusOutline            = "OUTLINE",
        buffStatusOffsetX            = 1,
        buffStatusOffsetY            = 1,
        tutorialPage                 = 0, -- highest tutorial page the player has seen
    },
    char = {
        sharedSlots = {},
        memberSlots = { ["*"] = {} },
    },
    global = {
        buffSpells = {}, -- Zaubernamen die als Buff-Zauber bekannt sind (baut sich mit der Zeit auf)
    },
}
