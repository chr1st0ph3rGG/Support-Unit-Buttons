-------------------------------------------------------------------------------
-- DispelData.lua
-- spellID → { DebuffType = true, ... }
-------------------------------------------------------------------------------

local AddonName, SUB_NS = ...

SUB_NS.DISPEL_ID_TYPES = {
    -- Priest
    [527]    = { Magic = true },                                             -- Dispel Magic
    [32375]  = { Magic = true },                                             -- Mass Dispel
    [528]    = { Disease = true },                                           -- Cure Disease
    [552]    = { Disease = true },                                           -- Abolish Disease
    [213634] = { Disease = true },                                           -- Purify Disease (Cata+)
    [53598]  = { Magic = true, Disease = true },                             -- Purify (Cata+)
    -- Paladin
    [4987]   = { Poison = true, Disease = true, Magic = true },              -- Cleanse
    [1152]   = { Poison = true, Disease = true },                            -- Purify (TBC+)
    [213644] = { Poison = true, Disease = true },                            -- Cleanse Toxins (Cata+)
    -- Druid
    [2782]   = { Curse = true },                                             -- Remove Curse / Remove Corruption
    [88423]  = { Magic = true, Curse = true, Poison = true },                -- Nature's Cure (Cata+)
    [2893]   = { Poison = true },                                            -- Abolish Poison
    [8946]   = { Poison = true },                                            -- Cure Poison
    -- Mage
    [475]    = { Curse = true },                                             -- Remove Curse
    [412113] = { Curse = true, Magic = true },                               -- Greater Remove Curse (Cata+)
    -- Shaman
    [526]    = { Poison = true },                                            -- Cure Poison (Classic/TBC)
    [2870]   = { Disease = true },                                           -- Cure Disease (Classic/TBC)
    [8166]   = { Poison = true },                                            -- Poison Cleansing Totem (Classic)
    [8170]   = { Disease = true },                                           -- Disease Cleansing Totem (Classic)
    [51886]  = { Curse = true },                                             -- Cleanse Spirit (Wrath+)
    [77130]  = { Curse = true, Magic = true },                               -- Purify Spirit (Cata+)
    [383013] = { Poison = true },                                            -- Poison Cleansing Totem (Retail)
    -- Monk
    [115450] = { Magic = true, Disease = true, Poison = true },              -- Detox (Mistweaver)
    [218164] = { Disease = true, Poison = true },                            -- Detox (Brewmaster/Windwalker)
    [388874] = { Disease = true, Poison = true },                            -- Improved Detox (Mistweaver)
    -- Evoker
    [360823] = { Magic = true, Poison = true },                              -- Naturalize
    [365585] = { Poison = true },                                            -- Expunge
    [374251] = { Magic = true, Disease = true, Curse = true, Bleed = true }, -- Cauterizing Flame
    [378438] = { Magic = true },                                             -- Scouring Flame (PvP)
    -- Warlock pet: Devour Magic (all ranks)
    [19505]  = { Magic = true },
    [19731]  = { Magic = true },
    [19734]  = { Magic = true },
    [19736]  = { Magic = true },
    [27276]  = { Magic = true },
    [27277]  = { Magic = true },
    [48011]  = { Magic = true },
    [132411] = { Magic = true }, -- Singe Magic
    [89808]  = { Magic = true }, -- Singe
}
