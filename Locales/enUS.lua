-------------------------------------------------------------------------------
-- Locales/enUS.lua  –  English (default / fallback)
-------------------------------------------------------------------------------
-- Keys ARE the English strings, so this file only needs to register the
-- locale as the default.  AceLocale falls back to the key itself for any
-- string not found in the active locale, which means enUS never needs
-- explicit entries.
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "enUS", true)
if not L then return end

-- Tab names
L["Bar"]                                                                                             = true
L["Spell"]                                                                                           = true
L["Dispel"]                                                                                          = true

-- General
L["General"]                                                                                         = true
L["Show player bar"]                                                                                 = true
L["Only in party"]                                                                                   = true
L["Show the player bar only when you are in a group"]                                                = true
L["Always show name labels"]                                                                         = true
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]    = true
L["Always show empty buttons"]                                                                       = true
L["Keep empty slots visible at all times, not only while dragging spells."]                          = true
L["Drag-off modifier"]                                                                               = true
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."] = true
L["Shift"]                                                                                           = true
L["Ctrl"]                                                                                            = true
L["Alt"]                                                                                             = true
L["Any"]                                                                                             = true

-- Button Layout
L["Button Layout"]                                                                                   = true
L["Button size"]                                                                                     = true
L["Width and height of each button (pixels)"]                                                        = true
L["Button spacing"]                                                                                  = true
L["Gap between buttons (pixels)"]                                                                    = true
L["Shared buttons"]                                                                                  = true
L["Number of shared buttons (same spell/item on all bars)"]                                          = true
L["Individual buttons"]                                                                              = true
L["Number of per-member individual buttons"]                                                         = true
L["Gap shared/individual"]                                                                           = true
L["Space between the shared and individual button sections (pixels)"]                                = true

-- Bar Positioning
L["Bar Positioning"]                                                                                 = true
L["Lock bars"]                                                                                       = true
L["Prevent bars from being moved by dragging"]                                                       = true
L["Mode"]                                                                                            = true
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                          = true
L["Free"]                                                                                            = true
L["Anchored"]                                                                                        = true
L["Direction"]                                                                                       = true
L["Vertical"]                                                                                        = true
L["Horizontal"]                                                                                      = true
L["Gap between bars"]                                                                                = true
L["Pixels between bars in anchored mode"]                                                            = true
L["Reset positions"]                                                                                 = true

-- Shared text (Spell Rank + Cast Count)
L["Font"]                                                                                            = true
L["Font size"]                                                                                       = true
L["Outline"]                                                                                         = true
L["None"]                                                                                            = true
L["Thick outline"]                                                                                   = true
L["Corner"]                                                                                          = true
L["Position"]                                                                                        = true
L["Top left"]                                                                                        = true
L["Top"]                                                                                             = true
L["Top right"]                                                                                       = true
L["Left"]                                                                                            = true
L["Right"]                                                                                           = true
L["Bottom left"]                                                                                     = true
L["Bottom"]                                                                                          = true
L["Bottom right"]                                                                                    = true
L["Offset X"]                                                                                        = true
L["Horizontal fine-tuning offset (added to the corner's base position)"]                             = true
L["Offset Y"]                                                                                        = true
L["Vertical fine-tuning offset (added to the corner's base position)"]                               = true
L["Color"]                                                                                           = true
L["Enable"]                                                                                          = true

-- Spell Rank
L["Spell Rank"]                                                                                      = true
L["Show spell rank"]                                                                                 = true
L["Display the spell rank number on each button"]                                                    = true

-- Cast Count / Item Count
L["Cast Count / Item Count"]                                                                         = true
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]     = true
L["Spell Color"]                                                                                     = true
L["Color of the cast count number for spells"]                                                       = true
L["Item Color"]                                                                                      = true
L["Color of the cast count number for items"]                                                        = true

-- Tutorial
L["Show Tutorial"]                                                                                   = true
L["Replay the introductory tutorial"]                                                                = true
L["TUTORIAL_TITLE"]                                                                                  = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                     =
"Support Unit Buttons adds an action bar for each party member.\n\nDrag spells or items from your spellbook or bags onto the buttons. Clicking a button casts the spell – or uses the item – on that bar's unit. By default, the button bars are unlocked and show name labels to make it easy to identify which bar belongs to which unit. Once you have set up the bars, you can lock them to hide the labels and prevent accidental repositioning. \n\n You have two types of Support Buttons: \n\n - Shared buttons (left section) hold the same spell or item for the entire group.\n\n - Individual buttons (right section) can hold a different spell per player (it's player-specific) – great for unit/player-specific heals or buffs. \n\nThe number of shared and individual buttons can be configured in the options.\nTo drag a spell OFF a button, hold the modifier key (default: Shift) while dragging. You can always drop a new spell/item onto a button without any modifier."
L["TUTORIAL_P2"]                                                                                     =
"A unit button holds additional information about the spell or item assigned to it:\n- Spell rank (if applicable)\n- Casts until out of mana (for spells) or total item count in bags\n- Buff duration in the button corner when your spell is active as a buff on the target — changes colour when under the configured threshold; shows \"-\" when the buff has run out\n- A red border if the unit currently has a debuff that can be dispelled with the assigned spell\n\nAll of these can be enabled or disabled in the options."
L["TUTORIAL_P3"]                                                                                     =
"Type /sub or /SupportUnitButtons to open the Options panel at any time.\n\nYou can also find it under:\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                    = true

-- Dispel
L["Dispel Alert"]                                                                                    = true
L["Show a pulsing border on buttons that can dispel a debuff the unit currently has."]               = true
L["Border Appearance"]                                                                               = true
L["Shape"]                                                                                           = true
L["Border shape. Use Circle for round Masque button skins."]                                         = true
L["Square"]                                                                                          = true
L["Circle"]                                                                                          = true
L["Pulse Speed"]                                                                                     = true
L["Controls how fast the border pulses."]                                                            = true
L["Alpha minimum"]                                                                                   = true
L["Minimum opacity at the trough of the animation. 0 = fully fades out, above 0 = always visible."] = true
L["Alpha maximum"]                                                                                   = true
L["Maximum opacity at the peak of the animation."]                                                   = true
L["Border Width"]                                                                                    = true
L["Border width in pixels. 0 = automatic (6 % of button size)."]                                    = true
L["Border Padding"]                                                                                  = true
L["Distance from the button edge in pixels. Positive = extends outside the button, negative = inset inside the button."] = true
L["Type Colors"]                                                                                     = true
L["Per debuff type"]                                                                                 = true
L["Use a different color per debuff type (Magic, Curse, Poison, Disease)."]                          = true
L["Magic"]                                                                                           = true
L["Curse"]                                                                                           = true
L["Poison"]                                                                                          = true
L["Disease"]                                                                                         = true
L["Preview"]                                                                                         = true
L["Simulate dispel alert"]                                                                           = true
L["Show the alert on all dispel buttons so you can adjust appearance outside of combat."]            = true
L["Sound"]                                                                                           = true
L["Activate sound"]                                                                                  = true
L["Plays a sound when a party member gets a dispellable debuff."]                                    = true
L["Channel"]                                                                                         = true
L["Audio Channel for Dispel Alert Sound"]                                                            = true

-- Masque
L["Masque"]                                                                                          = true
L["Open Masque Options"]                                                                             = true
L["Open the Masque skin options for SupportUnitButtons."]                                            = true
L["Masque is required to skin the buttons.\nInstall Masque to enable this feature."]                 = true

-- Reagent Count
L["Reagent Count"]                                                                                   = true
L["Show the reagent count on spell buttons that require reagents, replacing the default count display."] = true

-- Buff Status
L["Buff Status"]                                                                                     = true
L["Show remaining buff duration in the button corner when the button's spell is active on the target, or \"-\" when not active."] = true
L["Low threshold (sec)"]                                                                             = true
L["Switch to the low-time color when remaining duration drops below this value (seconds)."]          = true
L["Low-time color"]                                                                                  = true
