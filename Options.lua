-------------------------------------------------------------------------------
-- Options.lua
-------------------------------------------------------------------------------

local SUB            = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local AceCfg         = LibStub("AceConfig-3.0")
local AceCfgD        = LibStub("AceConfigDialog-3.0")
local AceDBOpt       = LibStub("AceDBOptions-3.0")
local LSM            = LibStub("LibSharedMedia-3.0")
local L              = LibStub("AceLocale-3.0"):GetLocale("SupportUnitButtons")

local UNITS          = { "player", "party1", "party2", "party3", "party4" }
local MAX_SHARED     = 12
local MAX_INDIVIDUAL = 6

-------------------------------------------------------------------------------
-- Options
-------------------------------------------------------------------------------

function SUB:BuildOptionsTable()
    local options = {
        name        = "SupportUnitButtons",
        type        = "group",
        childGroups = "tab",
        args        = {

            ---------- Bar tab ----------
            settings = {
                name  = L["Bar"],
                type  = "group",
                order = 1,
                args  = {

                    ---------- General ----------
                    general = {
                        name   = L["General"],
                        type   = "group",
                        inline = true,
                        order  = 1,
                        args   = {
                            showPlayer = {
                                name  = L["Show player bar"],
                                type  = "toggle",
                                order = 2,
                                get   = function() return self.db.profile.showPlayer end,
                                set   = function(_, v)
                                    self.db.profile.showPlayer = v
                                    self:ApplyRosterUpdate()
                                end,
                            },
                            showPlayerOnlyInParty = {
                                name     = L["Only in party"],
                                desc     = L["Show the player bar only when you are in a group"],
                                type     = "toggle",
                                order    = 3,
                                disabled = function() return not self.db.profile.showPlayer end,
                                get      = function() return self.db.profile.showPlayerOnlyInParty end,
                                set      = function(_, v)
                                    self.db.profile.showPlayerOnlyInParty = v
                                    self:ApplyRosterUpdate()
                                end,
                            },
                            showLabels = {
                                name  = L["Always show name labels"],
                                desc  = L
                                    ["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."],
                                type  = "toggle",
                                order = 4,
                                get   = function() return self.db.profile.showLabels end,
                                set   = function(_, v)
                                    self.db.profile.showLabels = v
                                    self:UpdateAllLabelVisibility()
                                end,
                            },
                            showEmptyButtons = {
                                name  = L["Always show empty buttons"],
                                desc  = L["Keep empty slots visible at all times, not only while dragging spells."],
                                type  = "toggle",
                                order = 5,
                                get   = function() return self.db.profile.showEmptyButtons end,
                                set   = function(_, v) self:SetShowEmptyButtons(v) end,
                            },
                            showTutorial = {
                                name  = L["Show Tutorial"],
                                desc  = L["Replay the introductory tutorial"],
                                type  = "execute",
                                order = 1,
                                func  = function()
                                    ---@diagnostic disable-next-line: undefined-field
                                    self:ShowTutorial()
                                end,
                            },
                            dragOffModifier = {
                                name   = L["Drag-off modifier"],
                                desc   = L
                                    ["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."],
                                type   = "select",
                                order  = 6,
                                values = { SHIFT = L["Shift"], CTRL = L["Ctrl"], ALT = L["Alt"], ANY = L["Any"] },
                                get    = function() return self.db.profile.dragOffModifier end,
                                set    = function(_, v) self:SetDragModifier(v) end,
                            },
                        },
                    },

                    ---------- Button layout ----------
                    layout = {
                        name   = L["Button Layout"],
                        type   = "group",
                        inline = true,
                        order  = 2,
                        args   = {
                            buttonSize = {
                                name = L["Button size"],
                                desc = L["Width and height of each button (pixels)"],
                                type = "range",
                                min = 20,
                                max = 64,
                                step = 1,
                                order = 1,
                                get = function() return self.db.profile.buttonSize end,
                                set = function(_, v)
                                    self.db.profile.buttonSize = v
                                    self:UpdateAllLayouts()
                                end,
                            },
                            buttonSpacing = {
                                name = L["Button spacing"],
                                desc = L["Gap between buttons (pixels)"],
                                type = "range",
                                min = 0,
                                max = 20,
                                step = 1,
                                order = 2,
                                get = function() return self.db.profile.buttonSpacing end,
                                set = function(_, v)
                                    self.db.profile.buttonSpacing = v
                                    self:UpdateAllLayouts()
                                end,
                            },
                            sharedCount = {
                                name = L["Shared buttons"],
                                desc = L["Number of shared buttons (same spell/item on all bars)"],
                                type = "range",
                                min = 0,
                                max = MAX_SHARED,
                                step = 1,
                                order = 3,
                                get = function() return self.db.profile.sharedCount end,
                                set = function(_, v)
                                    self.db.profile.sharedCount = v
                                    self:UpdateAllLayouts()
                                end,
                            },
                            individualCount = {
                                name = L["Individual buttons"],
                                desc = L["Number of per-member individual buttons"],
                                type = "range",
                                min = 0,
                                max = MAX_INDIVIDUAL,
                                step = 1,
                                order = 4,
                                get = function() return self.db.profile.individualCount end,
                                set = function(_, v)
                                    self.db.profile.individualCount = v
                                    self:UpdateAllLayouts()
                                end,
                            },
                            separatorGap = {
                                name = L["Gap shared/individual"],
                                desc = L["Space between the shared and individual button sections (pixels)"],
                                type = "range",
                                min = 0,
                                max = 64,
                                step = 1,
                                order = 5,
                                get = function() return self.db.profile.separatorGap end,
                                set = function(_, v)
                                    self.db.profile.separatorGap = v
                                    self:UpdateAllLayouts()
                                end,
                            },
                        },
                    },

                    ---------- Bar Positioning ----------
                    positioning = {
                        name   = L["Bar Positioning"],
                        type   = "group",
                        inline = true,
                        order  = 3,
                        args   = {
                            locked = {
                                name  = L["Lock bars"],
                                desc  = L["Prevent bars from being moved by dragging"],
                                type  = "toggle",
                                order = 1,
                                get   = function() return self.db.profile.locked end,
                                set   = function(_, v) self:SetLocked(v) end,
                            },
                            positionMode = {
                                name   = L["Mode"],
                                desc   = function()
                                    local s = L
                                        ["Free: drag each bar individually.\nAnchored: all bars move as a group."]
                                    if self:IsSUFInstalled() then
                                        s = s ..
                                            "\n" .. L["ShadowedUnitFrames: anchor each bar next to a SUF party frame."]
                                    end
                                    return s
                                end,
                                type   = "select",
                                order  = 1,
                                values = function()
                                    local vals = { free = L["Free"], anchored = L["Anchored"] }
                                    if self:IsSUFInstalled() then
                                        vals.suf = L["ShadowedUnitFrames"]
                                    end
                                    return vals
                                end,
                                get    = function() return self.db.profile.positionMode end,
                                set    = function(_, v)
                                    self.db.profile.positionMode = v
                                    self:UpdateAllHandleInteractivity()
                                    if v == "anchored" then
                                        self:ApplyAnchoredPositions()
                                    elseif v == "suf" then
                                        self:ApplySUFPositions()
                                    else
                                        for _, unit in ipairs(UNITS) do
                                            self:RestoreBarPosition(unit)
                                        end
                                    end
                                end,
                            },
                            ---------- Free options ----------
                            freePositioning = {
                                name   = L["Free"],
                                type   = "group",
                                inline = true,
                                order  = 2,
                                hidden = function() return self.db.profile.positionMode ~= "free" end,
                                args   = {
                                    resetPos = {
                                        name  = L["Reset positions"],
                                        type  = "execute",
                                        order = 1,
                                        func  = function() self:ResetAllPositions() end,
                                    },
                                },
                            },

                            ---------- Anchored options ----------
                            anchorPositioning = {
                                name   = L["Anchored"],
                                type   = "group",
                                inline = true,
                                order  = 3,
                                hidden = function() return self.db.profile.positionMode ~= "anchored" end,
                                args   = {
                                    anchorDirection = {
                                        name   = L["Direction"],
                                        type   = "select",
                                        order  = 1,
                                        values = { vertical = L["Vertical"], horizontal = L["Horizontal"] },
                                        get    = function() return self.db.profile.anchorDirection end,
                                        set    = function(_, v)
                                            self.db.profile.anchorDirection = v
                                            self:ApplyAnchoredPositions()
                                        end,
                                    },
                                    anchorGap = {
                                        name  = L["Gap between bars"],
                                        desc  = L["Pixels between bars in anchored mode"],
                                        type  = "range",
                                        min   = 0,
                                        max   = 256,
                                        step  = 1,
                                        order = 2,
                                        get   = function() return self.db.profile.anchorGap end,
                                        set   = function(_, v)
                                            self.db.profile.anchorGap = v
                                            self:ApplyAnchoredPositions()
                                        end,
                                    },
                                    resetPos = {
                                        name  = L["Reset positions"],
                                        type  = "execute",
                                        order = 3,
                                        func  = function() self:ResetAllPositions() end,
                                    },
                                },
                            },

                            ---------- ShadowedUnitFrames anchor ----------
                            sufPositioning = self:GetSUFOptionsGroup(),

                        },
                    },

                    ---------- Masque ----------
                    masque = self:GetMasqueOptionsGroup(),

                }, -- close settings.args
            },     -- close settings

            ---------- Spell tab ----------
            spell = {
                name  = L["Button Overlays"],
                type  = "group",
                order = 2,
                args  = {
                    spellRank = {
                        name   = L["Spell Rank"],
                        type   = "group",
                        inline = true,
                        order  = 1,
                        args   = {
                            showSpellRank = {
                                name  = L["Show spell rank"],
                                desc  = L["Display the spell rank number on each button"],
                                type  = "toggle",
                                order = 1,
                                get   = function() return self.db.profile.showSpellRank end,
                                set   = function(_, v)
                                    self.db.profile.showSpellRank = v
                                    self:UpdateAllRankTexts()
                                end,
                            },
                            spellRankFont = {
                                name        = L["Font"],
                                type        = "select",
                                order       = 2,
                                disabled    = function() return not self.db.profile.showSpellRank end,
                                values      = LSM:List("font"),
                                itemControl = "DDI-Font",
                                get         = function()
                                    local fonts = LSM:List("font")
                                    local current = self.db.profile.spellRankFont
                                    for i, v in next, fonts do
                                        if v == current then return i end
                                    end
                                end,
                                set         = function(_, i)
                                    self.db.profile.spellRankFont = LSM:List("font")[i]
                                    self:UpdateAllRankTexts()
                                end,
                            },
                            spellRankFontSize = {
                                name     = L["Font size"],
                                type     = "range",
                                min      = 6,
                                max      = 20,
                                step     = 1,
                                order    = 3,
                                disabled = function() return not self.db.profile.showSpellRank end,
                                get      = function() return self.db.profile.spellRankFontSize end,
                                set      = function(_, v)
                                    self.db.profile.spellRankFontSize = v
                                    self:UpdateAllRankTexts()
                                end,
                            },
                            spellRankOutline = {
                                name     = L["Outline"],
                                type     = "select",
                                order    = 4,
                                disabled = function() return not self.db.profile.showSpellRank end,
                                values   = {
                                    NONE         = L["None"],
                                    OUTLINE      = L["Outline"],
                                    THICKOUTLINE = L["Thick outline"],
                                },
                                get      = function() return self.db.profile.spellRankOutline end,
                                set      = function(_, v)
                                    self.db.profile.spellRankOutline = v
                                    self:UpdateAllRankTexts()
                                end,
                            },
                            spellRankCorner = {
                                name     = L["Corner"],
                                type     = "select",
                                order    = 5,
                                disabled = function() return not self.db.profile.showSpellRank end,
                                values   = {
                                    TOPLEFT     = L["Top left"],
                                    TOPRIGHT    = L["Top right"],
                                    BOTTOMLEFT  = L["Bottom left"],
                                    BOTTOMRIGHT = L["Bottom right"],
                                },
                                get      = function() return self.db.profile.spellRankCorner end,
                                set      = function(_, v)
                                    self.db.profile.spellRankCorner = v
                                    self:UpdateAllRankTexts()
                                end,
                            },
                            spellRankOffsetX = {
                                name     = L["Offset X"],
                                desc     = L["Horizontal fine-tuning offset (added to the corner's base position)"],
                                type     = "range",
                                min      = -20,
                                max      = 20,
                                step     = 1,
                                order    = 6,
                                width    = "half",
                                disabled = function() return not self.db.profile.showSpellRank end,
                                get      = function() return self.db.profile.spellRankOffsetX end,
                                set      = function(_, v)
                                    self.db.profile.spellRankOffsetX = v
                                    self:UpdateAllRankTexts()
                                end,
                            },
                            spellRankOffsetY = {
                                name     = L["Offset Y"],
                                desc     = L["Vertical fine-tuning offset (added to the corner's base position)"],
                                type     = "range",
                                min      = -20,
                                max      = 20,
                                step     = 1,
                                order    = 7,
                                width    = "half",
                                disabled = function() return not self.db.profile.showSpellRank end,
                                get      = function() return self.db.profile.spellRankOffsetY end,
                                set      = function(_, v)
                                    self.db.profile.spellRankOffsetY = v
                                    self:UpdateAllRankTexts()
                                end,
                            },
                            spellRankColors = {
                                name     = L["Colors"],
                                type     = "group",
                                inline   = true,
                                order    = 9,
                                disabled = function() return not self.db.profile.showSpellRank end,
                                args     = {
                                    spellRankColor = {
                                        name     = L["Spell Rank Color"],
                                        type     = "color",
                                        hasAlpha = true,
                                        order    = 1,
                                        get      = function()
                                            local c = self.db.profile.spellRankColor
                                            return c.r, c.g, c.b, c.a
                                        end,
                                        set      = function(_, r, g, b, a)
                                            local c = self.db.profile.spellRankColor
                                            c.r, c.g, c.b, c.a = r, g, b, a
                                            self:UpdateAllRankTexts()
                                        end,
                                    },
                                },
                            },
                        },
                    },

                    castCount = {
                        name   = L["Cast Count / Item Count"],
                        type   = "group",
                        inline = true,
                        order  = 2,
                        args   = {
                            showCastCount = {
                                name  = L["Enable"],
                                desc  = L
                                    ["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."],
                                type  = "toggle",
                                order = 1,
                                get   = function() return self.db.profile.showCastCount end,
                                set   = function(_, v)
                                    self.db.profile.showCastCount = v
                                    self:UpdateAllCastCounts()
                                end,
                            },
                            castCountFont = {
                                name        = L["Font"],
                                type        = "select",
                                order       = 2,
                                disabled    = function() return not self.db.profile.showCastCount end,
                                values      = LSM:List("font"),
                                itemControl = "DDI-Font",
                                get         = function()
                                    local fonts   = LSM:List("font")
                                    local current = self.db.profile.castCountFont
                                    for i, v in next, fonts do
                                        if v == current then return i end
                                    end
                                end,
                                set         = function(_, i)
                                    self.db.profile.castCountFont = LSM:List("font")[i]
                                    self:UpdateAllCastCounts()
                                end,
                            },
                            castCountFontSize = {
                                name     = L["Font size"],
                                type     = "range",
                                min      = 6,
                                max      = 20,
                                step     = 1,
                                order    = 3,
                                disabled = function() return not self.db.profile.showCastCount end,
                                get      = function() return self.db.profile.castCountFontSize end,
                                set      = function(_, v)
                                    self.db.profile.castCountFontSize = v
                                    self:UpdateAllCastCounts()
                                end,
                            },
                            castCountOutline = {
                                name     = L["Outline"],
                                type     = "select",
                                order    = 4,
                                disabled = function() return not self.db.profile.showCastCount end,
                                values   = {
                                    NONE         = L["None"],
                                    OUTLINE      = L["Outline"],
                                    THICKOUTLINE = L["Thick outline"],
                                },
                                get      = function() return self.db.profile.castCountOutline end,
                                set      = function(_, v)
                                    self.db.profile.castCountOutline = v
                                    self:UpdateAllCastCounts()
                                end,
                            },
                            castCountCorner = {
                                name     = L["Corner"],
                                type     = "select",
                                order    = 5,
                                disabled = function() return not self.db.profile.showCastCount end,
                                values   = {
                                    TOPLEFT     = L["Top left"],
                                    TOPRIGHT    = L["Top right"],
                                    BOTTOMLEFT  = L["Bottom left"],
                                    BOTTOMRIGHT = L["Bottom right"],
                                },
                                get      = function() return self.db.profile.castCountCorner end,
                                set      = function(_, v)
                                    self.db.profile.castCountCorner = v
                                    self:UpdateAllCastCounts()
                                end,
                            },
                            castCountOffsetX = {
                                name     = L["Offset X"],
                                type     = "range",
                                min      = -20,
                                max      = 20,
                                step     = 1,
                                order    = 6,
                                width    = "half",
                                disabled = function() return not self.db.profile.showCastCount end,
                                get      = function() return self.db.profile.castCountOffsetX end,
                                set      = function(_, v)
                                    self.db.profile.castCountOffsetX = v
                                    self:UpdateAllCastCounts()
                                end,
                            },
                            castCountOffsetY = {
                                name     = L["Offset Y"],
                                type     = "range",
                                min      = -20,
                                max      = 20,
                                step     = 1,
                                order    = 7,
                                width    = "half",
                                disabled = function() return not self.db.profile.showCastCount end,
                                get      = function() return self.db.profile.castCountOffsetY end,
                                set      = function(_, v)
                                    self.db.profile.castCountOffsetY = v
                                    self:UpdateAllCastCounts()
                                end,
                            },
                            castCountColors = {
                                name     = L["Colors"],
                                type     = "group",
                                inline   = true,
                                order    = 10,
                                disabled = function() return not self.db.profile.showCastCount end,
                                args     = {
                                    castCountSpellColor = {
                                        name     = L["Spell Color"],
                                        desc     = L["Color of the cast count number for spells"],
                                        type     = "color",
                                        hasAlpha = true,
                                        order    = 1,
                                        get      = function()
                                            local c = self.db.profile.castCountSpellColor
                                            return c.r, c.g, c.b, c.a
                                        end,
                                        set      = function(_, r, g, b, a)
                                            local c = self.db.profile.castCountSpellColor
                                            c.r, c.g, c.b, c.a = r, g, b, a
                                            self:UpdateAllCastCounts()
                                        end,
                                    },
                                    castCountItemColor = {
                                        name     = L["Item Color"],
                                        desc     = L["Color of the cast count number for items"],
                                        type     = "color",
                                        hasAlpha = true,
                                        order    = 2,
                                        get      = function()
                                            local c = self.db.profile.castCountItemColor
                                            return c.r, c.g, c.b, c.a
                                        end,
                                        set      = function(_, r, g, b, a)
                                            local c = self.db.profile.castCountItemColor
                                            c.r, c.g, c.b, c.a = r, g, b, a
                                            self:UpdateAllCastCounts()
                                        end,
                                    },
                                },
                            },
                        },
                    },

                    reagentCount = {
                        name   = L["Reagent Count"],
                        type   = "group",
                        inline = true,
                        order  = 3,
                        args   = {
                            showReagentCount = {
                                name  = L["Enable"],
                                desc  = L
                                    ["Show the reagent count on spell buttons that require reagents, replacing the default count display."],
                                type  = "toggle",
                                order = 1,
                                get   = function() return self.db.profile.showReagentCount end,
                                set   = function(_, v)
                                    self.db.profile.showReagentCount = v
                                    self:UpdateAllReagentCounts()
                                end,
                            },
                            reagentCountFont = {
                                name        = L["Font"],
                                type        = "select",
                                order       = 2,
                                disabled    = function() return not self.db.profile.showReagentCount end,
                                values      = LSM:List("font"),
                                itemControl = "DDI-Font",
                                get         = function()
                                    local fonts   = LSM:List("font")
                                    local current = self.db.profile.reagentCountFont
                                    for i, v in next, fonts do
                                        if v == current then return i end
                                    end
                                end,
                                set         = function(_, i)
                                    self.db.profile.reagentCountFont = LSM:List("font")[i]
                                    self:UpdateAllReagentCounts()
                                end,
                            },
                            reagentCountFontSize = {
                                name     = L["Font size"],
                                type     = "range",
                                min      = 6,
                                max      = 20,
                                step     = 1,
                                order    = 3,
                                disabled = function() return not self.db.profile.showReagentCount end,
                                get      = function() return self.db.profile.reagentCountFontSize end,
                                set      = function(_, v)
                                    self.db.profile.reagentCountFontSize = v
                                    self:UpdateAllReagentCounts()
                                end,
                            },
                            reagentCountOutline = {
                                name     = L["Outline"],
                                type     = "select",
                                order    = 4,
                                disabled = function() return not self.db.profile.showReagentCount end,
                                values   = {
                                    NONE         = L["None"],
                                    OUTLINE      = L["Outline"],
                                    THICKOUTLINE = L["Thick outline"],
                                },
                                get      = function() return self.db.profile.reagentCountOutline end,
                                set      = function(_, v)
                                    self.db.profile.reagentCountOutline = v
                                    self:UpdateAllReagentCounts()
                                end,
                            },
                            reagentCountCorner = {
                                name     = L["Corner"],
                                type     = "select",
                                order    = 5,
                                disabled = function() return not self.db.profile.showReagentCount end,
                                values   = {
                                    TOPLEFT     = L["Top left"],
                                    TOPRIGHT    = L["Top right"],
                                    BOTTOMLEFT  = L["Bottom left"],
                                    BOTTOMRIGHT = L["Bottom right"],
                                },
                                get      = function() return self.db.profile.reagentCountCorner end,
                                set      = function(_, v)
                                    self.db.profile.reagentCountCorner = v
                                    self:UpdateAllReagentCounts()
                                end,
                            },
                            reagentCountOffsetX = {
                                name     = L["Offset X"],
                                type     = "range",
                                min      = -20,
                                max      = 20,
                                step     = 1,
                                order    = 6,
                                width    = "half",
                                disabled = function() return not self.db.profile.showReagentCount end,
                                get      = function() return self.db.profile.reagentCountOffsetX end,
                                set      = function(_, v)
                                    self.db.profile.reagentCountOffsetX = v
                                    self:UpdateAllReagentCounts()
                                end,
                            },
                            reagentCountOffsetY = {
                                name     = L["Offset Y"],
                                type     = "range",
                                min      = -20,
                                max      = 20,
                                step     = 1,
                                order    = 7,
                                width    = "half",
                                disabled = function() return not self.db.profile.showReagentCount end,
                                get      = function() return self.db.profile.reagentCountOffsetY end,
                                set      = function(_, v)
                                    self.db.profile.reagentCountOffsetY = v
                                    self:UpdateAllReagentCounts()
                                end,
                            },
                            reagentCountColors = {
                                name     = L["Colors"],
                                type     = "group",
                                inline   = true,
                                order    = 9,
                                disabled = function() return not self.db.profile.showReagentCount end,
                                args     = {
                                    reagentCountColor = {
                                        name     = L["Reagent Count Color"],
                                        type     = "color",
                                        hasAlpha = true,
                                        order    = 1,
                                        get      = function()
                                            local c = self.db.profile.reagentCountColor
                                            return c.r, c.g, c.b, c.a
                                        end,
                                        set      = function(_, r, g, b, a)
                                            local c = self.db.profile.reagentCountColor
                                            c.r, c.g, c.b, c.a = r, g, b, a
                                            self:UpdateAllReagentCounts()
                                        end,
                                    },
                                },
                            },
                        },
                    },

                    buffStatus = {
                        name   = L["Buff Status"],
                        type   = "group",
                        inline = true,
                        order  = 4,
                        args   = {
                            showBuffStatus = {
                                name  = L["Enable"],
                                desc  = L
                                    ["Show remaining buff duration in the button corner when the button's spell is active on the target, or \"-\" when not active."],
                                type  = "toggle",
                                order = 1,
                                get   = function() return self.db.profile.showBuffStatus end,
                                set   = function(_, v)
                                    self.db.profile.showBuffStatus = v
                                    self:UpdateAllBuffStatuses()
                                end,
                            },
                            buffStatusFont = {
                                name        = L["Font"],
                                type        = "select",
                                order       = 2,
                                disabled    = function() return not self.db.profile.showBuffStatus end,
                                values      = LSM:List("font"),
                                itemControl = "DDI-Font",
                                get         = function()
                                    local fonts   = LSM:List("font")
                                    local current = self.db.profile.buffStatusFont
                                    for i, v in next, fonts do
                                        if v == current then return i end
                                    end
                                end,
                                set         = function(_, i)
                                    self.db.profile.buffStatusFont = LSM:List("font")[i]
                                    self:UpdateAllBuffStatuses()
                                end,
                            },
                            buffStatusFontSize = {
                                name     = L["Font size"],
                                type     = "range",
                                min      = 6,
                                max      = 20,
                                step     = 1,
                                order    = 3,
                                disabled = function() return not self.db.profile.showBuffStatus end,
                                get      = function() return self.db.profile.buffStatusFontSize end,
                                set      = function(_, v)
                                    self.db.profile.buffStatusFontSize = v
                                    self:UpdateAllBuffStatuses()
                                end,
                            },
                            buffStatusOutline = {
                                name     = L["Outline"],
                                type     = "select",
                                order    = 4,
                                disabled = function() return not self.db.profile.showBuffStatus end,
                                values   = {
                                    NONE         = L["None"],
                                    OUTLINE      = L["Outline"],
                                    THICKOUTLINE = L["Thick outline"],
                                },
                                get      = function() return self.db.profile.buffStatusOutline end,
                                set      = function(_, v)
                                    self.db.profile.buffStatusOutline = v
                                    self:UpdateAllBuffStatuses()
                                end,
                            },
                            buffStatusCorner = {
                                name     = L["Position"],
                                type     = "select",
                                order    = 5,
                                disabled = function() return not self.db.profile.showBuffStatus end,
                                values   = {
                                    TOPLEFT     = L["Top left"],
                                    TOP         = L["Top"],
                                    TOPRIGHT    = L["Top right"],
                                    LEFT        = L["Left"],
                                    RIGHT       = L["Right"],
                                    BOTTOMLEFT  = L["Bottom left"],
                                    BOTTOM      = L["Bottom"],
                                    BOTTOMRIGHT = L["Bottom right"],
                                },
                                get      = function() return self.db.profile.buffStatusCorner end,
                                set      = function(_, v)
                                    self.db.profile.buffStatusCorner = v
                                    self:UpdateAllBuffStatuses()
                                end,
                            },
                            buffStatusOffsetX = {
                                name     = L["Offset X"],
                                type     = "range",
                                min      = -20,
                                max      = 20,
                                step     = 1,
                                order    = 6,
                                width    = "half",
                                disabled = function() return not self.db.profile.showBuffStatus end,
                                get      = function() return self.db.profile.buffStatusOffsetX end,
                                set      = function(_, v)
                                    self.db.profile.buffStatusOffsetX = v
                                    self:UpdateAllBuffStatuses()
                                end,
                            },
                            buffStatusOffsetY = {
                                name     = L["Offset Y"],
                                type     = "range",
                                min      = -20,
                                max      = 20,
                                step     = 1,
                                order    = 7,
                                width    = "half",
                                disabled = function() return not self.db.profile.showBuffStatus end,
                                get      = function() return self.db.profile.buffStatusOffsetY end,
                                set      = function(_, v)
                                    self.db.profile.buffStatusOffsetY = v
                                    self:UpdateAllBuffStatuses()
                                end,
                            },
                            buffStatusLowThreshold = {
                                name     = L["Low threshold (sec)"],
                                desc     = L
                                    ["Switch to the low-time color when remaining duration drops below this value (seconds)."],
                                type     = "range",
                                min      = 0,
                                max      = 600,
                                step     = 5,
                                order    = 9,
                                disabled = function() return not self.db.profile.showBuffStatus end,
                                get      = function() return self.db.profile.buffStatusLowThreshold end,
                                set      = function(_, v)
                                    self.db.profile.buffStatusLowThreshold = v
                                    self:UpdateAllBuffStatuses()
                                end,
                            },
                            buffStatusColors = {
                                name     = L["Colors"],
                                type     = "group",
                                inline   = true,
                                order    = 10,
                                disabled = function() return not self.db.profile.showBuffStatus end,
                                args     = {
                                    buffStatusColor = {
                                        name     = L["Normal Color"],
                                        type     = "color",
                                        hasAlpha = true,
                                        order    = 1,
                                        get      = function()
                                            local c = self.db.profile.buffStatusColor
                                            return c.r, c.g, c.b, c.a
                                        end,
                                        set      = function(_, r, g, b, a)
                                            local c = self.db.profile.buffStatusColor
                                            c.r, c.g, c.b, c.a = r, g, b, a
                                            self:UpdateAllBuffStatuses()
                                        end,
                                    },
                                    buffStatusLowColor = {
                                        name     = L["Low-time color"],
                                        type     = "color",
                                        hasAlpha = true,
                                        order    = 2,
                                        get      = function()
                                            local c = self.db.profile.buffStatusLowColor
                                            return c.r, c.g, c.b, c.a
                                        end,
                                        set      = function(_, r, g, b, a)
                                            local c = self.db.profile.buffStatusLowColor
                                            c.r, c.g, c.b, c.a = r, g, b, a
                                            self:UpdateAllBuffStatuses()
                                        end,
                                    },
                                },
                            },
                        },
                    },
                },
            },

            ---------- Dispel tab ----------
            dispel = {
                name  = L["Dispel"],
                type  = "group",
                order = 3,
                args  = {
                    dispelAlertGroup = {
                        name   = L["Dispel Alert"],
                        type   = "group",
                        inline = true,
                        order  = 1,
                        args   = {
                            enable = {
                                name  = L["Enable"],
                                desc  = L
                                    ["Show a pulsing border on buttons that can dispel a debuff the unit currently has."],
                                type  = "toggle",
                                order = 1,
                                get   = function() return self.db.profile.dispelAlert end,
                                set   = function(_, v)
                                    self.db.profile.dispelAlert = v
                                    self:UpdateAllDispelHighlights()
                                end,
                            },
                            preview = {
                                name     = L["Simulate dispel alert"],
                                desc     = L
                                    ["Show the alert on all dispel buttons so you can adjust appearance outside of combat."],
                                type     = "toggle",
                                order    = 2,
                                disabled = function() return not self.db.profile.dispelAlert end,
                                get      = function() return SUB.dispelAlertPreview end,
                                set      = function(_, v)
                                    SUB.dispelAlertPreview = v
                                    SUB:UpdateAllDispelHighlights()
                                end,
                            },
                            periodicResync = {
                                name     = L["Periodic dispel resync"],
                                desc     = L
                                    ["Run a periodic full dispel check every second to recover from rare missed aura updates (prevents stuck blinking alerts)."],
                                type     = "toggle",
                                order    = 3,
                                disabled = function() return not self.db.profile.dispelAlert end,
                                get      = function() return self.db.profile.dispelAlertResync ~= false end,
                                set      = function(_, v)
                                    self.db.profile.dispelAlertResync = v
                                    if v then
                                        self:UpdateAllDispelHighlights()
                                    end
                                end,
                            },
                            periodicResyncInterval = {
                                name     = L["Resync interval (sec)"],
                                desc     = L["How often the periodic dispel resync runs."],
                                type     = "range",
                                order    = 4,
                                min      = 0.2,
                                max      = 5.0,
                                step     = 0.1,
                                disabled = function()
                                    return not self.db.profile.dispelAlert or self.db.profile.dispelAlertResync == false
                                end,
                                get      = function()
                                    return self.db.profile.dispelAlertResyncInterval or 1.0
                                end,
                                set      = function(_, v)
                                    self.db.profile.dispelAlertResyncInterval = v
                                end,
                            },
                        },
                    },
                    dispelColorGroup = {
                        name     = L["Border Appearance"],
                        type     = "group",
                        inline   = true,
                        order    = 2,
                        disabled = function() return not self.db.profile.dispelAlert end,
                        args     = {
                            shape = {
                                name   = L["Shape"],
                                desc   = L["Border shape. Use Circle for round Masque button skins."],
                                type   = "select",
                                order  = 1,
                                values = {
                                    square = L["Square"],
                                    circle = L["Circle"],
                                },
                                get    = function()
                                    return self.db.profile.dispelAlertShape or "square"
                                end,
                                set    = function(_, v)
                                    self.db.profile.dispelAlertShape = v
                                    self:UpdateAllDispelHighlights()
                                end,
                            },
                            pulseSpeed = {
                                name  = L["Pulse Speed"],
                                desc  = L["Controls how fast the border pulses."],
                                type  = "range",
                                order = 3,
                                min   = 0.5,
                                max   = 5.0,
                                step  = 0.1,
                                get   = function()
                                    return self.db.profile.dispelAlertPulseSpeed or 2.5
                                end,
                                set   = function(_, v)
                                    self.db.profile.dispelAlertPulseSpeed = v
                                end,
                            },
                            alphaMin = {
                                name  = L["Alpha minimum"],
                                desc  = L
                                    ["Minimum opacity at the trough of the animation. 0 = fully fades out, above 0 = always visible."],
                                type  = "range",
                                order = 4,
                                min   = 0.0,
                                max   = 1.0,
                                step  = 0.05,
                                get   = function()
                                    return self.db.profile.dispelAlertAlphaMin or 0.0
                                end,
                                set   = function(_, v)
                                    self.db.profile.dispelAlertAlphaMin = v
                                end,
                            },
                            alphaMax = {
                                name  = L["Alpha maximum"],
                                desc  = L["Maximum opacity at the peak of the animation."],
                                type  = "range",
                                order = 5,
                                min   = 0.0,
                                max   = 1.0,
                                step  = 0.05,
                                get   = function()
                                    return self.db.profile.dispelAlertAlphaMax or 1.0
                                end,
                                set   = function(_, v)
                                    self.db.profile.dispelAlertAlphaMax = v
                                end,
                            },
                            borderWidth = {
                                name  = L["Border Width"],
                                desc  = L["Border width in pixels. 0 = automatic (6 % of button size)."],
                                type  = "range",
                                order = 6,
                                min   = 0,
                                max   = 12,
                                step  = 1,
                                get   = function()
                                    return self.db.profile.dispelAlertBorderWidth or 0
                                end,
                                set   = function(_, v)
                                    self.db.profile.dispelAlertBorderWidth = v
                                    self:UpdateAllDispelHighlights()
                                end,
                            },
                            borderPadding = {
                                name  = L["Border Padding"],
                                desc  = L
                                    ["Distance from the button edge in pixels. Positive = extends outside the button, negative = inset inside the button."],
                                type  = "range",
                                order = 7,
                                min   = -8,
                                max   = 10,
                                step  = 1,
                                get   = function()
                                    local v = self.db.profile.dispelAlertPadding
                                    return v ~= nil and v or 3
                                end,
                                set   = function(_, v)
                                    self.db.profile.dispelAlertPadding = v
                                    self:UpdateAllDispelHighlights()
                                end,
                            },
                            perDebuffType = {
                                name  = L["Per debuff type"],
                                desc  = L["Use a different color per debuff type (Magic, Curse, Poison, Disease)."],
                                type  = "toggle",
                                order = 8,
                                get   = function() return self.db.profile.dispelAlertTypeColorsEnabled end,
                                set   = function(_, v)
                                    self.db.profile.dispelAlertTypeColorsEnabled = v
                                    self:UpdateAllDispelHighlights()
                                end,
                            },
                            singleColor = {
                                name   = L["Colors"],
                                type   = "group",
                                inline = true,
                                order  = 9,
                                hidden = function() return self.db.profile.dispelAlertTypeColorsEnabled end,
                                args   = {
                                    color = {
                                        name  = L["Debuff Color"],
                                        type  = "color",
                                        order = 1,
                                        get   = function()
                                            local c = self.db.profile.dispelAlertColor
                                            return c.r, c.g, c.b
                                        end,
                                        set   = function(_, r, g, b)
                                            local c = self.db.profile.dispelAlertColor
                                            c.r, c.g, c.b = r, g, b
                                            self:UpdateAllDispelHighlights()
                                        end,
                                    },
                                },
                            },
                            typeColors = {
                                name   = L["Colors"],
                                type   = "group",
                                inline = true,
                                order  = 9,
                                hidden = function() return not self.db.profile.dispelAlertTypeColorsEnabled end,
                                args   = {
                                    colorMagic = {
                                        name  = L["Magic"],
                                        type  = "color",
                                        order = 1,
                                        get   = function()
                                            local c = self.db.profile.dispelAlertColorMagic
                                            return c.r, c.g, c.b
                                        end,
                                        set   = function(_, r, g, b)
                                            local c = self.db.profile.dispelAlertColorMagic
                                            c.r, c.g, c.b = r, g, b
                                            self:UpdateAllDispelHighlights()
                                        end,
                                    },
                                    colorCurse = {
                                        name  = L["Curse"],
                                        type  = "color",
                                        order = 2,
                                        get   = function()
                                            local c = self.db.profile.dispelAlertColorCurse
                                            return c.r, c.g, c.b
                                        end,
                                        set   = function(_, r, g, b)
                                            local c = self.db.profile.dispelAlertColorCurse
                                            c.r, c.g, c.b = r, g, b
                                            self:UpdateAllDispelHighlights()
                                        end,
                                    },
                                    colorPoison = {
                                        name  = L["Poison"],
                                        type  = "color",
                                        order = 3,
                                        get   = function()
                                            local c = self.db.profile.dispelAlertColorPoison
                                            return c.r, c.g, c.b
                                        end,
                                        set   = function(_, r, g, b)
                                            local c = self.db.profile.dispelAlertColorPoison
                                            c.r, c.g, c.b = r, g, b
                                            self:UpdateAllDispelHighlights()
                                        end,
                                    },
                                    colorDisease = {
                                        name  = L["Disease"],
                                        type  = "color",
                                        order = 4,
                                        get   = function()
                                            local c = self.db.profile.dispelAlertColorDisease
                                            return c.r, c.g, c.b
                                        end,
                                        set   = function(_, r, g, b)
                                            local c = self.db.profile.dispelAlertColorDisease
                                            c.r, c.g, c.b = r, g, b
                                            self:UpdateAllDispelHighlights()
                                        end,
                                    },
                                },
                            },
                        },
                    },
                    dispelSoundGroup = {
                        name     = L["Sound"],
                        type     = "group",
                        inline   = true,
                        order    = 5,
                        disabled = function() return not self.db.profile.dispelAlert end,
                        args     = {
                            dispelAlertSoundEnabled = {
                                name  = L["Activate sound"],
                                desc  = L["Plays a sound when a party member gets a dispellable debuff."],
                                type  = "toggle",
                                order = 1,
                                get   = function() return self.db.profile.dispelAlertSoundEnabled end,
                                set   = function(_, v)
                                    self.db.profile.dispelAlertSoundEnabled = v
                                end,
                            },
                            dispelAlertSound = {
                                name        = L["Sound"],
                                type        = "select",
                                order       = 2,
                                disabled    = function()
                                    return not self.db.profile.dispelAlert
                                        or not self.db.profile.dispelAlertSoundEnabled
                                end,
                                values      = LSM:List("sound"),
                                itemControl = "DDI-Sound",
                                get         = function()
                                    local sounds = LSM:List("sound")
                                    local current = self.db.profile.dispelAlertSound
                                    if not current then return nil end
                                    for i, v in next, sounds do
                                        if v == current then return i end
                                    end
                                end,
                                set         = function(_, i)
                                    self.db.profile.dispelAlertSound = LSM:List("sound")[i]
                                end,
                            },
                            dispelAlertSoundChannel = {
                                name     = L["Channel"],
                                desc     = L["Audio Channel for Dispel Alert Sound"],
                                type     = "select",
                                order    = 3,
                                disabled = function()
                                    return not self.db.profile.dispelAlert
                                        or not self.db.profile.dispelAlertSoundEnabled
                                end,
                                values   = {
                                    Master   = "Master",
                                    SFX      = "SFX",
                                    Music    = "Music",
                                    Ambience = "Ambience",
                                    Dialog   = "Dialog",
                                },
                                get      = function() return self.db.profile.dispelAlertSoundChannel end,
                                set      = function(_, v)
                                    self.db.profile.dispelAlertSoundChannel = v
                                end,
                            },
                        },
                    },
                },
            },

            ---------- Resurrection tab ----------
            resurrection = {
                name  = L["Resurrection"],
                type  = "group",
                order = 4,
                args  = {
                    rezAlertGroup = {
                        name   = L["Resurrection Alert"],
                        type   = "group",
                        inline = true,
                        order  = 1,
                        args   = {
                            enable = {
                                name  = L["Enable"],
                                desc  = L
                                    ["Show a colored border on resurrection buttons depending on the target's resurrection status."],
                                type  = "toggle",
                                order = 1,
                                get   = function() return self.db.profile.rezAlert end,
                                set   = function(_, v)
                                    self.db.profile.rezAlert = v
                                    self:UpdateRezEventRegistrations()
                                    self:UpdateAllRezHighlights()
                                end,
                            },
                            preview = {
                                name     = L["Simulate resurrection alert"],
                                desc     = L
                                    ["Show all three border colors across the bars so you can adjust their appearance outside of combat."],
                                type     = "toggle",
                                order    = 2,
                                disabled = function() return not self.db.profile.rezAlert end,
                                get      = function() return SUB.rezAlertPreview end,
                                set      = function(_, v)
                                    SUB.rezAlertPreview = v
                                    SUB:UpdateAllRezHighlights()
                                end,
                            },
                            periodicResync = {
                                name     = L["Periodic resync"],
                                desc     = L
                                    ["Run a periodic full check to recover from missed death or resurrection events."],
                                type     = "toggle",
                                order    = 3,
                                disabled = function() return not self.db.profile.rezAlert end,
                                get      = function() return self.db.profile.rezAlertResync ~= false end,
                                set      = function(_, v)
                                    self.db.profile.rezAlertResync = v
                                    if v then self:UpdateAllRezHighlights() end
                                end,
                            },
                            periodicResyncInterval = {
                                name     = L["Resync interval (sec)"],
                                desc     = L["How often the periodic resurrection resync runs."],
                                type     = "range",
                                order    = 4,
                                min      = 0.2,
                                max      = 5.0,
                                step     = 0.1,
                                disabled = function()
                                    return not self.db.profile.rezAlert
                                        or self.db.profile.rezAlertResync == false
                                end,
                                get      = function()
                                    return self.db.profile.rezAlertResyncInterval or 2.0
                                end,
                                set      = function(_, v)
                                    self.db.profile.rezAlertResyncInterval = v
                                end,
                            },
                        },
                    },
                    rezAppearanceGroup = {
                        name     = L["Border Appearance"],
                        type     = "group",
                        inline   = true,
                        order    = 2,
                        disabled = function() return not self.db.profile.rezAlert end,
                        args     = {
                            shape = {
                                name   = L["Shape"],
                                desc   = L["Border shape. Use Circle for round Masque button skins."],
                                type   = "select",
                                order  = 1,
                                values = {
                                    square = L["Square"],
                                    circle = L["Circle"],
                                },
                                get    = function()
                                    return self.db.profile.rezAlertShape or "square"
                                end,
                                set    = function(_, v)
                                    self.db.profile.rezAlertShape = v
                                    self:UpdateAllRezHighlights()
                                end,
                            },
                            pulseSpeed = {
                                name  = L["Pulse Speed"],
                                desc  = L["Controls how fast the border pulses. Set to 0 for a fully static border."],
                                type  = "range",
                                order = 2,
                                min   = 0.0,
                                max   = 5.0,
                                step  = 0.1,
                                get   = function()
                                    return self.db.profile.rezAlertPulseSpeed or 0.0
                                end,
                                set   = function(_, v)
                                    self.db.profile.rezAlertPulseSpeed = v
                                end,
                            },
                            alphaMin = {
                                name  = L["Alpha minimum"],
                                desc  = L
                                    ["Minimum opacity at the trough of the animation. 0 = fully fades out, above 0 = always visible."],
                                type  = "range",
                                order = 3,
                                min   = 0.0,
                                max   = 1.0,
                                step  = 0.05,
                                get   = function()
                                    return self.db.profile.rezAlertAlphaMin or 1.0
                                end,
                                set   = function(_, v)
                                    self.db.profile.rezAlertAlphaMin = v
                                end,
                            },
                            alphaMax = {
                                name  = L["Alpha maximum"],
                                desc  = L["Maximum opacity at the peak of the animation."],
                                type  = "range",
                                order = 4,
                                min   = 0.0,
                                max   = 1.0,
                                step  = 0.05,
                                get   = function()
                                    return self.db.profile.rezAlertAlphaMax or 1.0
                                end,
                                set   = function(_, v)
                                    self.db.profile.rezAlertAlphaMax = v
                                end,
                            },
                            borderWidth = {
                                name  = L["Border Width"],
                                desc  = L["Border width in pixels. 0 = automatic (6 % of button size)."],
                                type  = "range",
                                order = 5,
                                min   = 0,
                                max   = 12,
                                step  = 1,
                                get   = function()
                                    return self.db.profile.rezAlertBorderWidth or 0
                                end,
                                set   = function(_, v)
                                    self.db.profile.rezAlertBorderWidth = v
                                    self:UpdateAllRezHighlights()
                                end,
                            },
                            borderPadding = {
                                name  = L["Border Padding"],
                                desc  = L
                                    ["Distance from the button edge in pixels. Positive = extends outside the button, negative = inset inside the button."],
                                type  = "range",
                                order = 6,
                                min   = -8,
                                max   = 10,
                                step  = 1,
                                get   = function()
                                    local v = self.db.profile.rezAlertPadding
                                    return v ~= nil and v or 3
                                end,
                                set   = function(_, v)
                                    self.db.profile.rezAlertPadding = v
                                    self:UpdateAllRezHighlights()
                                end,
                            },
                        },
                    },
                    rezColorsGroup = {
                        name     = L["State Colors"],
                        type     = "group",
                        inline   = true,
                        order    = 3,
                        disabled = function() return not self.db.profile.rezAlert end,
                        args     = {
                            colorDead = {
                                name  = L["Dead (no incoming rez)"],
                                desc  = L["Border color when the unit is dead with no resurrection in progress."],
                                type  = "color",
                                order = 1,
                                get   = function()
                                    local c = self.db.profile.rezAlertColorDead
                                    return c.r, c.g, c.b
                                end,
                                set   = function(_, r, g, b)
                                    local c = self.db.profile.rezAlertColorDead
                                    c.r, c.g, c.b = r, g, b
                                    self:UpdateAllRezHighlights()
                                end,
                            },
                            colorCasting = {
                                name  = L["Casting resurrection"],
                                desc  = L["Border color while a resurrection spell is being cast on the unit."],
                                type  = "color",
                                order = 2,
                                get   = function()
                                    local c = self.db.profile.rezAlertColorCasting
                                    return c.r, c.g, c.b
                                end,
                                set   = function(_, r, g, b)
                                    local c = self.db.profile.rezAlertColorCasting
                                    c.r, c.g, c.b = r, g, b
                                    self:UpdateAllRezHighlights()
                                end,
                            },
                            colorPending = {
                                name  = L["Resurrection pending"],
                                desc  = L
                                    ["Border color when the resurrection has been cast and the unit has not yet accepted it."],
                                type  = "color",
                                order = 3,
                                get   = function()
                                    local c = self.db.profile.rezAlertColorPending
                                    return c.r, c.g, c.b
                                end,
                                set   = function(_, r, g, b)
                                    local c = self.db.profile.rezAlertColorPending
                                    c.r, c.g, c.b = r, g, b
                                    self:UpdateAllRezHighlights()
                                end,
                            },
                        },
                    },
                },
            },

            ---------- Profiles ----------
            profiles = AceDBOpt:GetOptionsTable(self.db),
        }, -- close options.args
    }

    options.args.profiles.order = 5

    AceCfg:RegisterOptionsTable("SupportUnitButtons", options)
    AceCfgD:AddToBlizOptions("SupportUnitButtons", "SupportUnitButtons")
end
