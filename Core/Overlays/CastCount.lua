-- Core/Overlays/CastCount.lua
-- Text overlay: cast count (spell casts with current mana / item count)
-------------------------------------------------------------------------------

local _, SUB_NS     = ...
local SUB           = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local CE            = LibStub("C_Everywhere")
local LSM           = LibStub("LibSharedMedia-3.0")

local UNITS         = SUB_NS.UNITS

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

-- Scans `costTable` for a mana entry (type == 0) and returns the cost.
local function FindManaCostEntry(costTable)
    for _, entry in ipairs(costTable) do
        if entry.type == 0 then return entry.cost end
    end
end

-- Returns the mana cost of `spellId`, or nil if unavailable.
local function GetSpellManaCost(spellId)
    local getCost = CE.Spell.GetSpellPowerCost
    if not getCost then return nil end
    local costTable = getCost(spellId)
    if not costTable then return nil end
    return FindManaCostEntry(costTable)
end

-- Returns how many times the spell can be cast with current mana, or nil.
local function GetSpellCastCount(action)
    local id = tonumber(action)
    if not id then return nil end
    local manaCost = GetSpellManaCost(id)
    if not manaCost or manaCost <= 0 then return nil end
    local currentMana = UnitPower("player", 0) or UnitMana("player") or 0
    return math.floor(currentMana / manaCost)
end

-- Returns the item count in the bags, or nil.
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

-- Updates the cast count text (spell casts or item count) for a button.
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

-- Updates cast count labels on all bars.
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
