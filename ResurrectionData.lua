-------------------------------------------------------------------------------
-- ResurrectionData.lua
-- spellID → true for every spell that can resurrect a dead player.
-------------------------------------------------------------------------------

local AddonName, SUB_NS = ...

SUB_NS.REZ_ID_SPELLS = {
    -- Priest
    [2006]   = true,
    [2010]   = true,
    [10880]  = true,
    [10881]  = true,
    [25435]  = true,
    [27240]  = true,
    [48171]  = true,
    [212036] = true,
    -- Paladin
    [7328]   = true,
    [10322]  = true,
    [10324]  = true,
    [10325]  = true,
    [20772]  = true,
    [20773]  = true,
    [48949]  = true,
    [212056] = true,
    -- Shaman
    [2008]   = true,
    [20609]  = true,
    [20610]  = true,
    [20776]  = true,
    [20777]  = true,
    [25590]  = true,
    [49277]  = true,
    [212048] = true,
    -- Druid
    [20484]  = true,
    [20739]  = true,
    [20742]  = true,
    [20747]  = true,
    [20748]  = true,
    [26994]  = true,
    [48477]  = true,
    [212040] = true,
    -- Death Knight
    [61999]  = true,
    -- Monk
    [115178] = true,
}
