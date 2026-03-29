-------------------------------------------------------------------------------
-- Locales/deDE.lua  –  Deutsch
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "deDE")
if not L then return end

-- Tab-Namen
L["Bar"]                                                                                                                          = "Leiste"
L["Button Overlays"]                                                                                                              = "Button-Overlays"
L["Dispel"]                                                                                                                       = "Entzauberung"

-- Allgemein
L["General"]                                                                                                                      = "Allgemein"
L["Show player bar"]                                                                                                              = "Spielerleiste anzeigen"
L["Only in party"]                                                                                                                = "Nur in Gruppe"
L["Show the player bar only when you are in a group"]                                                                             = "Zeigt die Spielerleiste nur wenn du in einer Gruppe bist"
L["Always show name labels"]                                                                                                      = "Namensbezeichnungen immer anzeigen"
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]                                 =
"Zeigt den Einheitsnamen auch wenn die Leisten gesperrt sind.\nBezeichnungen werden immer angezeigt wenn entsperrt."
L["Always show empty buttons"]                                                                                                    = "Leere Buttons immer anzeigen"
L["Keep empty slots visible at all times, not only while dragging spells."]                                                       =
"Leere Plätze dauerhaft anzeigen, nicht nur beim Ziehen von Zaubern."
L["Drag-off modifier"]                                                                                                            = "Ablegen-Modifikator"
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."]                              =
"Taste die gehalten werden muss um einen Zauber von einem Button zu entfernen.\nZauber auf Buttons ablegen funktioniert immer."
L["Shift"]                                                                                                                        = "Shift"
L["Ctrl"]                                                                                                                         = "Strg"
L["Alt"]                                                                                                                          = "Alt"
L["Any"]                                                                                                                          = "Beliebige"

-- Button-Layout
L["Button Layout"]                                                                                                                = "Button-Layout"
L["Button size"]                                                                                                                  = "Button-Größe"
L["Width and height of each button (pixels)"]                                                                                     = "Breite und Höhe jedes Buttons (Pixel)"
L["Button spacing"]                                                                                                               = "Button-Abstand"
L["Gap between buttons (pixels)"]                                                                                                 = "Abstand zwischen Buttons (Pixel)"
L["Shared buttons"]                                                                                                               = "Gemeinsame Buttons"
L["Number of shared buttons (same spell/item on all bars)"]                                                                       =
"Anzahl gemeinsamer Buttons (gleicher Zauber/Gegenstand auf allen Leisten)"
L["Individual buttons"]                                                                                                           = "Individuelle Buttons"
L["Number of per-member individual buttons"]                                                                                      = "Anzahl individueller Buttons pro Mitglied"
L["Gap shared/individual"]                                                                                                        = "Abstand Geteilt/Individuell"
L["Space between the shared and individual button sections (pixels)"]                                                             =
"Abstand zwischen den geteilten und individuellen Button-Bereichen (Pixel)"

-- Leistenpositionierung
L["Bar Positioning"]                                                                                                              = "Leistenpositionierung"
L["Lock bars"]                                                                                                                    = "Leisten sperren"
L["Prevent bars from being moved by dragging"]                                                                                    = "Verhindert das Verschieben der Leisten per Drag"
L["Mode"]                                                                                                                         = "Modus"
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                                                       =
"Frei: Jede Leiste einzeln ziehen.\nVerankert: Alle Leisten bewegen sich als Gruppe."
L["ShadowedUnitFrames: anchor each bar next to a SUF party frame."]                                                               =
"ShadowedUnitFrames: Jede Leiste an einen SUF-Partyrahmen anhängen."
L["Free"]                                                                                                                         = "Frei"
L["Anchored"]                                                                                                                     = "Verankert"
L["ShadowedUnitFrames"]                                                                                                           = "ShadowedUnitFrames"
L["Direction"]                                                                                                                    = "Richtung"
L["Vertical"]                                                                                                                     = "Vertikal"
L["Horizontal"]                                                                                                                   = "Horizontal"
L["Gap between bars"]                                                                                                             = "Abstand zwischen Leisten"
L["Pixels between bars in anchored mode"]                                                                                         = "Pixel zwischen Leisten im verankerten Modus"
L["Reset positions"]                                                                                                              = "Positionen zurücksetzen"

-- ShadowedUnitFrames-Anker
L["ShadowedUnitFrames Anchor"]                                                                                                    = "ShadowedUnitFrames-Anker"
L["Bar anchor point"]                                                                                                             = "Ankerpunkt der Leiste"
L["Which point of the SUB bar to anchor from"]                                                                                    = "Ankerpunkt der SUB-Leiste"
L["SUF anchor point"]                                                                                                             = "Ankerpunkt des SUF-Rahmens"
L["Which point of the SUF frame to attach to"]                                                                                    = "Ankerpunkt des SUF-Rahmens der angehängt wird"
L["Horizontal offset from the SUF anchor point (pixels)"]                                                                         = "Horizontaler Abstand vom SUF-Ankerpunkt (Pixel)"
L["Vertical offset from the SUF anchor point (pixels)"]                                                                           = "Vertikaler Abstand vom SUF-Ankerpunkt (Pixel)"

-- Gemeinsame Texte (Zauberstufe + Wirken-Anzahl)
L["Font"]                                                                                                                         = "Schriftart"
L["Font size"]                                                                                                                    = "Schriftgröße"
L["Outline"]                                                                                                                      = "Kontur"
L["None"]                                                                                                                         = "Keine"
L["Thick outline"]                                                                                                                = "Dicke Kontur"
L["Corner"]                                                                                                                       = "Ecke"
L["Position"]                                                                                                                     = "Position"
L["Top left"]                                                                                                                     = "Oben links"
L["Top"]                                                                                                                          = "Oben"
L["Top right"]                                                                                                                    = "Oben rechts"
L["Left"]                                                                                                                         = "Links"
L["Right"]                                                                                                                        = "Rechts"
L["Bottom left"]                                                                                                                  = "Unten links"
L["Bottom"]                                                                                                                       = "Unten"
L["Bottom right"]                                                                                                                 = "Unten rechts"
L["Offset X"]                                                                                                                     = "Versatz X"
L["Horizontal fine-tuning offset (added to the corner's base position)"]                                                          =
"Horizontaler Feinabgleich (zum Eckversatz addiert)"
L["Offset Y"]                                                                                                                     = "Versatz Y"
L["Vertical fine-tuning offset (added to the corner's base position)"]                                                            =
"Vertikaler Feinabgleich (zum Eckversatz addiert)"
L["Color"]                                                                                                                        = "Farbe"
L["Colors"]                                                                                                                       = "Farben"
L["Spell Rank Color"]                                                                                                             = "Zauberrang-Farbe"
L["Reagent Count Color"]                                                                                                          = "Reagenzien-Farbe"
L["Normal Color"]                                                                                                                 = "Normalfarbe"
L["Enable"]                                                                                                                       = "Aktivieren"

-- Zauberstufe
L["Spell Rank"]                                                                                                                   = "Zauberstufe"
L["Show spell rank"]                                                                                                              = "Zauberstufe anzeigen"
L["Display the spell rank number on each button"]                                                                                 = "Zeigt die Zauberstufenzahl auf jedem Button"

-- Wirken-/Gegenstandsanzahl
L["Cast Count / Item Count"]                                                                                                      = "Wirken-/Gegenstandsanzahl"
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]                                  =
"Zeigt wie oft ein Zauber gewirkt werden kann bevor das Mana ausgeht,\noder die Gesamtanzahl des Gegenstands im Inventar."
L["Spell Color"]                                                                                                                  = "Zauberfarbe"
L["Color of the cast count number for spells"]                                                                                    = "Farbe der Wirken-Anzahl für Zauber"
L["Item Color"]                                                                                                                   = "Gegenstandsfarbe"
L["Color of the cast count number for items"]                                                                                     = "Farbe der Wirken-Anzahl für Gegenstände"

-- Tutorial
L["Show Tutorial"]                                                                                                                = "Tutorial anzeigen"
L["Replay the introductory tutorial"]                                                                                             = "Das Einführungs-Tutorial erneut anzeigen"
L["TUTORIAL_TITLE"]                                                                                                               = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                                                  =
"Support Unit Buttons fügt für jedes Gruppenmitglied eine Aktionsleiste hinzu.\n\nZiehe Zauber oder Gegenstände aus deinem Zauberbuch oder Taschen auf die Buttons. Ein Klick auf einen Button wirkt den Zauber – oder benutzt den Gegenstand – an der Einheit dieser Leiste. Standardmäßig sind die Button-Leisten entsperrt und zeigen Namensbezeichnungen, damit du leicht erkennen kannst, welche Leiste zu welcher Einheit gehört. Sobald du die Leisten eingerichtet hast, kannst du sie sperren, um die Bezeichnungen auszublenden und versehentliches Verschieben zu verhindern.\n\nDu hast zwei Arten von Support-Buttons:\n\n - Gemeinsame Buttons (linker Bereich) halten den gleichen Zauber oder Gegenstand für die gesamte Gruppe.\n\n - Individuelle Buttons (rechter Bereich) können für jeden Spieler einen anderen Zauber halten (spielerspezifisch) – ideal für einheitsspezifische Heilungen oder Buffs.\n\nDie Anzahl der gemeinsamen und individuellen Buttons kann in den Optionen eingestellt werden.\nUm einen Zauber von einem Button zu entfernen, halte die Modifikatortaste (Standard: Shift) während des Ziehens gedrückt. Du kannst jederzeit einen neuen Zauber/Gegenstand auf einen Button ablegen, ohne eine Modifikatortaste."
L["TUTORIAL_P2"]                                                                                                                  =
"Ein Einheiten-Button zeigt zusätzliche Informationen über den zugewiesenen Zauber oder Gegenstand:\n- Zauberstufe (falls zutreffend)\n- Wirkungen bis zum Mana-Ende (bei Zaubern) oder Gesamtanzahl des Gegenstands in den Taschen\n- Buff-Dauer in der Button-Ecke wenn der Zauber als Buff auf dem Ziel aktiv ist — wechselt die Farbe wenn unter dem konfigurierten Schwellwert; zeigt \"-\" wenn der Buff abgelaufen ist\n- Einen roten Rand, wenn die Einheit aktuell einen Debuff hat, der mit dem zugewiesenen Zauber entzaubert werden kann\n\nAlle diese können in den Optionen aktiviert oder deaktiviert werden."
L["TUTORIAL_P3"]                                                                                                                  =
"Gib /sub oder /SupportUnitButtons ein, um das Optionsfenster jederzeit zu öffnen.\n\nDu findest es auch unter:\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                                                 = "Optionen öffnen"

-- Entzauberungs-Alarm
L["Dispel Alert"]                                                                                                                 = "Entzauberungs-Alarm"
L["Show a pulsing border on buttons that can dispel a debuff the unit currently has."]                                            =
"Zeigt einen pulsierenden Rand auf Buttons die einen aktuellen Debuff der Einheit entzaubern können."
L["Border Appearance"]                                                                                                            = "Randdarstellung"
L["Shape"]                                                                                                                        = "Form"
L["Border shape. Use Circle for round Masque button skins."]                                                                      =
"Randform. Kreis für runde Masque-Button-Skins verwenden."
L["Square"]                                                                                                                       = "Quadrat"
L["Circle"]                                                                                                                       = "Kreis"
L["Pulse Speed"]                                                                                                                  = "Pulsgeschwindigkeit"
L["Controls how fast the border pulses."]                                                                                         =
"Steuert wie schnell der Rand pulsiert."
L["Alpha minimum"]                                                                                                                = "Alpha-Minimum"
L["Minimum opacity at the trough of the animation. 0 = fully fades out, above 0 = always visible."]                               =
"Minimale Deckkraft am Tiefpunkt der Animation. 0 = blendet vollständig aus, über 0 = immer sichtbar."
L["Alpha maximum"]                                                                                                                = "Alpha-Maximum"
L["Maximum opacity at the peak of the animation."]                                                                                =
"Maximale Deckkraft am Höhepunkt der Animation."
L["Border Width"]                                                                                                                 = "Randbreite"
L["Border width in pixels. 0 = automatic (6 % of button size)."]                                                                  =
"Randbreite in Pixeln. 0 = automatisch (6 % der Button-Größe)."
L["Border Padding"]                                                                                                               = "Randabstand"
L["Distance from the button edge in pixels. Positive = extends outside the button, negative = inset inside the button."]          =
"Abstand zur Button-Kante in Pixeln. Positiv = außerhalb des Buttons, negativ = innerhalb des Buttons."
L["Debuff Color"]                                                                                                                 = "Debuff-Farbe"
L["Type Colors"]                                                                                                                  = "Typ-Farben"
L["Per debuff type"]                                                                                                              = "Pro Debuff-Typ"
L["Use a different color per debuff type (Magic, Curse, Poison, Disease)."]                                                       =
"Verwendet eine eigene Farbe pro Debuff-Typ (Magie, Fluch, Gift, Seuche)."
L["Magic"]                                                                                                                        = "Magie"
L["Curse"]                                                                                                                        = "Fluch"
L["Poison"]                                                                                                                       = "Gift"
L["Disease"]                                                                                                                      = "Seuche"
L["Preview"]                                                                                                                      = "Vorschau"
L["Simulate dispel alert"]                                                                                                        = "Entzauberungs-Alarm simulieren"
L["Show the alert on all dispel buttons so you can adjust appearance outside of combat."]                                         =
"Zeigt den Alarm auf allen Entzauberungs-Buttons damit die Darstellung außerhalb des Kampfes eingestellt werden kann."
L["Sound"]                                                                                                                        = "Sound"
L["Activate sound"]                                                                                                               = "Sound aktivieren"
L["Plays a sound when a party member gets a dispellable debuff."]                                                                 =
"Spielt einen Sound wenn ein Gruppenmitglied einen entzauberbaren Debuff erhält."
L["Channel"]                                                                                                                      = "Kanal"
L["Audio Channel for Dispel Alert Sound"]                                                                                         = "Audio-Kanal für den Entzauberungs-Alarm-Sound"

-- Masque
L["Masque"]                                                                                                                       = "Masque"
L["Open Masque Options"]                                                                                                          = "Masque-Optionen öffnen"
L["Open the Masque skin options for SupportUnitButtons."]                                                                         =
"Öffnet die Masque-Skin-Optionen für SupportUnitButtons."
L["Masque is required to skin the buttons.\nInstall Masque to enable this feature."]                                              =
"Masque wird benötigt um die Buttons zu stylen.\nInstalliere Masque um diese Funktion zu nutzen."

-- Reagenzien-Anzahl
L["Reagent Count"]                                                                                                                = "Reagenzien-Anzahl"
L["Show the reagent count on spell buttons that require reagents, replacing the default count display."]                          =
"Zeigt die Reagenzien-Anzahl auf Zauber-Buttons die Reagenzien benötigen und ersetzt dabei die Standard-Anzeige."

-- Buff-Status
L["Buff Status"]                                                                                                                  = "Buff-Status"
L["Show remaining buff duration in the button corner when the button's spell is active on the target, or \"-\" when not active."] =
"Zeigt die verbleibende Buff-Dauer in der Button-Ecke wenn der Zauber als Buff auf dem Ziel aktiv ist, oder \"-\" wenn nicht aktiv."
L["Low threshold (sec)"]                                                                                                          = "Niedrig-Schwellwert (Sek.)"
L["Switch to the low-time color when remaining duration drops below this value (seconds)."]                                       =
"Wechselt zur Niedrig-Zeit-Farbe wenn die verbleibende Dauer diesen Wert (Sekunden) unterschreitet."
L["Low-time color"]                                                                                                               = "Niedrig-Zeit-Farbe"
