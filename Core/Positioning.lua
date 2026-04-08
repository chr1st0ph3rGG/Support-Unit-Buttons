-- Core/Positioning.lua
-- Positioning methods for all unit bars
-------------------------------------------------------------------------------

local _, SUB_NS     = ...
local SUB           = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local UNITS         = SUB_NS.UNITS
local UNIT_INDEX    = SUB_NS.UNIT_INDEX
local HANDLE_HEIGHT = SUB_NS.HANDLE_HEIGHT

-- Positioning
-------------------------------------------------------------------------------

-- Returns how many visible bars appear before `unit` in UNITS order.
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

-- "anchored" mode: stack all visible bars from the saved anchor point.
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

-- Updates EnableMouse on all drag handles based on lock state and position mode.
-- In "suf" mode bars follow the SUF frames, so dragging is always disabled.
function SUB:UpdateAllHandleInteractivity()
    local db = self.db.profile
    local canDrag = not db.locked and db.positionMode ~= "suf"
    for _, unit in ipairs(UNITS) do
        local bd = self.bars[unit]
        if bd then
            bd.handle:EnableMouse(canDrag)
        end
    end
end

-- Positions a bar frame using saved coordinates or default stacking.
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

-- Restores a bar position from saved coordinates.
-- Skips "anchored"/"suf" mode (applied separately).
function SUB:RestoreBarPosition(unit)
    local db      = self.db.profile
    local barData = self.bars[unit]
    if not barData then return end
    if db.positionMode == "anchored" then return end
    if db.positionMode == "suf" then return end
    SetBarPosition(barData.frame, unit, db.bars[unit], db)
end

-- Resets all saved bar positions and reapplies the active mode.
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
