-- Integrations/Masque.lua
-- Masque integration: button skinning, options block
-------------------------------------------------------------------------------

local _, SUB_NS = ...
local SUB       = LibStub("AceAddon-3.0"):GetAddon("SupportUnitButtons")

local AceCfgD   = LibStub("AceConfigDialog-3.0")
local Masque    = LibStub("Masque", true)

-- Public Integration Methods
-------------------------------------------------------------------------------

-- Creates the Masque group for all SUB buttons (once in OnInitialize).
function SUB:InitializeMasque()
    if Masque then
        self.masqueGroup = Masque:Group("SupportUnitButtons", "Buttons")
    end
end

-- Registers a button in the Masque group if Masque is loaded.
function SUB:RegisterMasqueButton(btn)
    if self.masqueGroup then
        self.masqueGroup:AddButton(btn)
    end
end

-- Returns the AceConfig block for the Masque skin options.
function SUB:GetMasqueOptionsGroup()
    local L = LibStub("AceLocale-3.0"):GetLocale("SupportUnitButtons")
    return {
        name   = L["Masque"],
        type   = "group",
        inline = true,
        order  = 4,
        args   = {
            openMasque = {
                name     = L["Open Masque Options"],
                desc     = function()
                    if Masque then
                        return L["Open the Masque skin options for SupportUnitButtons."]
                    else
                        return L["Masque is required to skin the buttons.\nInstall Masque to enable this feature."]
                    end
                end,
                type     = "execute",
                order    = 1,
                disabled = function() return not Masque end,
                func     = function()
                    -- Trigger Masque's lazy options load if it has not happened yet.
                    local ldr = _G["MSQ_LDR_FRAME"]
                    if ldr then
                        local fn = ldr:GetScript("OnShow")
                        if fn then fn() end
                    end
                    AceCfgD:Open("Masque")
                    AceCfgD:SelectGroup("Masque", "Skins",
                        "SupportUnitButtons",
                        "SupportUnitButtons_Buttons")
                end,
            },
        },
    }
end
