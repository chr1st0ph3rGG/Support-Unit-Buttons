-- Core/Overlays/SpellRank.lua
-- Text overlay: spell rank
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

-- Updates the spell rank text for a button.
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

-- Updates rank texts for all visible/assigned buttons.
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
