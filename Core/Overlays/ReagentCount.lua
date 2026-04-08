-------------------------------------------------------------------------------
-- Core/Overlays/ReagentCount.lua
-- Text-Overlay: Reagent-Count (Cast-Anzahl für Reagenz-basierte Spells)
--
-- Ersetzt den nativen LAB-Count für betroffene Buttons, damit er in einer
-- frei konfigurierbaren Ecke platziert werden kann.
-------------------------------------------------------------------------------

local _, SUB_NS = ...
local SUB = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local LSM = LibStub("LibSharedMedia-3.0")

local UNITS = SUB_NS.UNITS

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

-- Stellt den nativen LAB-Count für einen Button wieder her.
function SUB:RestoreNativeCount(btn)
    if btn.SUB_reagentCountHidden and btn.Count then
        btn.Count:Show()
        btn.SUB_reagentCountHidden = nil
    end
end

-- Gibt die Cast-Anzahl für einen Reagenz-Spell zurück, oder nil wenn Overlay deaktiviert.
local function GetReagentDisplayCount(btn, btnType, action, db)
    if not db or not db.showReagentCount then return nil end
    if btnType ~= "spell" or not action then return nil end
    local count = btn.GetDisplayCount and btn:GetDisplayCount()
    return (count and count ~= 0) and count or nil
end

local function ApplyReagentCountStyle(fs, btn, db, count)
    -- Nativen LAB-Count verstecken und custom Overlay anzeigen.
    if btn.Count and not btn.SUB_reagentCountHidden then
        btn.Count:Hide()
        btn.SUB_reagentCountHidden = true
    end
    local corner = db.reagentCountCorner or "TOPRIGHT"
    local off    = CORNER_OFFSET[corner] or CORNER_OFFSET.TOPRIGHT
    fs:ClearAllPoints()
    fs:SetPoint(corner, btn, corner, off[1] + (db.reagentCountOffsetX or 0), off[2] + (db.reagentCountOffsetY or 0))
    local c        = db.reagentCountColor or { r = 1, g = 0.5, b = 0.0, a = 1 }
    local flags    = (db.reagentCountOutline and db.reagentCountOutline ~= "NONE") and db.reagentCountOutline or ""
    local fontPath = LSM:Fetch("font", db.reagentCountFont or "Friz Quadrata TT")
    fs:SetFont(fontPath, db.reagentCountFontSize or 9, flags)
    fs:SetTextColor(c.r or 1, c.g or 1, c.b or 1, c.a or 1)
    fs:SetText(tostring(count))
end

-- Aktualisiert das custom Reagent-Count-Overlay für einen Button.
function SUB:UpdateButtonReagentCount(btn, btnType, action)
    local fs = btn.SUB_reagentCountText
    if not fs then return end
    local db    = self.db and self.db.profile
    local count = GetReagentDisplayCount(btn, btnType, action, db)
    if not count then
        fs:SetText("")
        self:RestoreNativeCount(btn)
        return
    end
    ApplyReagentCountStyle(fs, btn, db, count)
end

-- Aktualisiert Reagent-Count-Overlays auf allen Bars.
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
