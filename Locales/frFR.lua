-------------------------------------------------------------------------------
-- Locales/frFR.lua  –  Français
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "frFR")
if not L then return end

-- Onglets
L["Bar"]                                                                                                                          = "Barre"
L["Button Overlays"]                                                                                                              = "Superposition des boutons"
L["Dispel"]                                                                                                                       = "Dissipation"

-- Général
L["General"]                                                                                                                      = "Général"
L["Show player bar"]                                                                                                              = "Afficher la barre du joueur"
L["Only in party"]                                                                                                                = "Seulement en groupe"
L["Show the player bar only when you are in a group"]                                                                             =
"Affiche la barre du joueur seulement lorsque vous êtes dans un groupe"
L["Always show name labels"]                                                                                                      = "Toujours afficher les étiquettes de nom"
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]                                 =
"Affiche le nom de l'unité même quand les barres sont verrouillées.\nLes étiquettes sont toujours affichées quand déverrouillées."
L["Always show empty buttons"]                                                                                                    = "Toujours afficher les boutons vides"
L["Keep empty slots visible at all times, not only while dragging spells."]                                                       =
"Garde les emplacements vides visibles en permanence, pas seulement lors du déplacement de sorts."
L["Drag-off modifier"]                                                                                                            = "Modificateur de retrait"
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."]                              =
"Touche modificatrice requise pour retirer un sort d'un bouton.\nDéposer des sorts sur les boutons fonctionne toujours."
L["Shift"]                                                                                                                        = "Maj"
L["Ctrl"]                                                                                                                         = "Ctrl"
L["Alt"]                                                                                                                          = "Alt"
L["Any"]                                                                                                                          = "N'importe laquelle"

-- Disposition des boutons
L["Button Layout"]                                                                                                                = "Disposition des boutons"
L["Button size"]                                                                                                                  = "Taille des boutons"
L["Width and height of each button (pixels)"]                                                                                     = "Largeur et hauteur de chaque bouton (pixels)"
L["Button spacing"]                                                                                                               = "Espacement des boutons"
L["Gap between buttons (pixels)"]                                                                                                 = "Espace entre les boutons (pixels)"
L["Shared buttons"]                                                                                                               = "Boutons partagés"
L["Number of shared buttons (same spell/item on all bars)"]                                                                       =
"Nombre de boutons partagés (même sort/objet sur toutes les barres)"
L["Individual buttons"]                                                                                                           = "Boutons individuels"
L["Number of per-member individual buttons"]                                                                                      = "Nombre de boutons individuels par membre"
L["Gap shared/individual"]                                                                                                        = "Écart partagé/individuel"
L["Space between the shared and individual button sections (pixels)"]                                                             =
"Espace entre les sections de boutons partagés et individuels (pixels)"

-- Positionnement des barres
L["Bar Positioning"]                                                                                                              = "Positionnement des barres"
L["Lock bars"]                                                                                                                    = "Verrouiller les barres"
L["Prevent bars from being moved by dragging"]                                                                                    = "Empêche le déplacement des barres par glissement"
L["Mode"]                                                                                                                         = "Mode"
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                                                       =
"Libre : faites glisser chaque barre individuellement.\nAncrée : toutes les barres se déplacent en groupe."
L["Free"]                                                                                                                         = "Libre"
L["Anchored"]                                                                                                                     = "Ancrée"
L["Direction"]                                                                                                                    = "Direction"
L["Vertical"]                                                                                                                     = "Vertical"
L["Horizontal"]                                                                                                                   = "Horizontal"
L["Gap between bars"]                                                                                                             = "Écart entre les barres"
L["Pixels between bars in anchored mode"]                                                                                         = "Pixels entre les barres en mode ancré"
L["Reset positions"]                                                                                                              = "Réinitialiser les positions"
L["ShadowedUnitFrames: anchor each bar next to a SUF party frame."]                                                               =
"ShadowedUnitFrames : Ancrez chaque barre à côté d'un cadre de groupe SUF."
L["ShadowedUnitFrames"]                                                                                                           = "ShadowedUnitFrames"

-- Ancrage ShadowedUnitFrames
L["ShadowedUnitFrames Anchor"]                                                                                                    = "Ancrage ShadowedUnitFrames"
L["Bar anchor point"]                                                                                                             = "Point d'ancrage de la barre"
L["Which point of the SUB bar to anchor from"]                                                                                    = "Quel point de la barre SUB utiliser pour l'ancrage"
L["SUF anchor point"]                                                                                                             = "Point d'ancrage du cadre SUF"
L["Which point of the SUF frame to attach to"]                                                                                    = "Quel point du cadre SUF pour l'attachement"
L["Horizontal offset from the SUF anchor point (pixels)"]                                                                         =
"Décalage horizontal par rapport au point d'ancrage SUF (pixels)"
L["Vertical offset from the SUF anchor point (pixels)"]                                                                           = "Décalage vertical par rapport au point d'ancrage SUF (pixels)"

-- Textes communs (Rang du sort + Nombre d'incantations)
L["Font"]                                                                                                                         = "Police"
L["Font size"]                                                                                                                    = "Taille de police"
L["Outline"]                                                                                                                      = "Contour"
L["None"]                                                                                                                         = "Aucun"
L["Thick outline"]                                                                                                                = "Contour épais"
L["Corner"]                                                                                                                       = "Coin"
L["Position"]                                                                                                                     = "Position"
L["Top left"]                                                                                                                     = "En haut à gauche"
L["Top"]                                                                                                                          = "Haut"
L["Top right"]                                                                                                                    = "En haut à droite"
L["Left"]                                                                                                                         = "Gauche"
L["Right"]                                                                                                                        = "Droite"
L["Bottom left"]                                                                                                                  = "En bas à gauche"
L["Bottom"]                                                                                                                       = "Bas"
L["Bottom right"]                                                                                                                 = "En bas à droite"
L["Offset X"]                                                                                                                     = "Décalage X"
L["Horizontal fine-tuning offset (added to the corner's base position)"]                                                          =
"Décalage de réglage fin horizontal (ajouté à la position de base du coin)"
L["Offset Y"]                                                                                                                     = "Décalage Y"
L["Vertical fine-tuning offset (added to the corner's base position)"]                                                            =
"Décalage de réglage fin vertical (ajouté à la position de base du coin)"
L["Color"]                                                                                                                        = "Couleur"
L["Colors"]                                                                                                                       = "Couleurs"
L["Spell Rank Color"]                                                                                                             = "Couleur du rang de sort"
L["Reagent Count Color"]                                                                                                          = "Couleur du nombre de réactifs"
L["Normal Color"]                                                                                                                 = "Couleur normale"
L["Enable"]                                                                                                                       = "Activer"

-- Rang du sort
L["Spell Rank"]                                                                                                                   = "Rang du sort"
L["Show spell rank"]                                                                                                              = "Afficher le rang du sort"
L["Display the spell rank number on each button"]                                                                                 = "Affiche le numéro de rang du sort sur chaque bouton"

-- Nombre d'incantations / d'objets
L["Cast Count / Item Count"]                                                                                                      = "Nombre d'incantations / d'objets"
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]                                  =
"Affiche combien de fois un sort peut être lancé avant d'être à court de mana,\nou le nombre total d'objets dans les sacs."
L["Spell Color"]                                                                                                                  = "Couleur des sorts"
L["Color of the cast count number for spells"]                                                                                    = "Couleur du nombre d'incantations pour les sorts"
L["Item Color"]                                                                                                                   = "Couleur des objets"
L["Color of the cast count number for items"]                                                                                     = "Couleur du nombre d'incantations pour les objets"

-- Tutoriel
L["Show Tutorial"]                                                                                                                = "Afficher le tutoriel"
L["Replay the introductory tutorial"]                                                                                             = "Rejouer le tutoriel d'introduction"
L["TUTORIAL_TITLE"]                                                                                                               = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                                                  =
"Support Unit Buttons ajoute une barre d'action pour chaque membre du groupe.\n\nFaites glisser des sorts ou des objets depuis votre livre de sorts ou vos sacs vers les boutons. Cliquer sur un bouton lance le sort – ou utilise l'objet – sur l'unité de cette barre. Par défaut, les barres de boutons sont déverrouillées et affichent des étiquettes de nom pour faciliter l'identification de quelle barre appartient à quelle unité. Une fois les barres configurées, vous pouvez les verrouiller pour masquer les étiquettes et éviter les repositionnements accidentels.\n\nVous disposez de deux types de Support Buttons :\n\n - Les boutons partagés (section gauche) contiennent le même sort ou objet pour tout le groupe.\n\n - Les boutons individuels (section droite) peuvent contenir un sort différent par joueur (spécifique au joueur) – idéal pour les soins ou les buffs spécifiques à une unité.\n\nLe nombre de boutons partagés et individuels peut être configuré dans les options.\nPour retirer un sort d'un bouton, maintenez la touche modificatrice (par défaut : Maj) tout en faisant glisser. Vous pouvez toujours déposer un nouveau sort/objet sur un bouton sans aucun modificateur."
L["TUTORIAL_P2"]                                                                                                                  =
"Un bouton d'unité affiche des informations supplémentaires sur le sort ou l'objet assigné :\n- Rang du sort (le cas échéant)\n- Nombre d'incantations avant d'être à court de mana (pour les sorts) ou quantité totale dans les sacs\n- Durée du buff dans le coin du bouton lorsque le sort est actif comme buff sur la cible — change de couleur sous le seuil configuré ; affiche \"-\" lorsque le buff a expiré\n- Un bord rouge si l'unité a actuellement un débuff pouvant être dissipé avec le sort assigné\n\nTous peuvent être activés ou désactivés dans les options."
L["TUTORIAL_P3"]                                                                                                                  =
"Tapez /sub ou /SupportUnitButtons pour ouvrir le panneau des Options à tout moment.\n\nVous pouvez également le trouver sous :\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                                                 = "Ouvrir les options"

-- Alerte de dissipation
L["Dispel Alert"]                                                                                                                 = "Alerte de dissipation"
L["Show a pulsing border on buttons that can dispel a debuff the unit currently has."]                                            =
"Affiche une bordure pulsante sur les boutons pouvant dissiper un débuff actuel de l'unité."
L["Border Appearance"]                                                                                                            = "Apparence de la bordure"
L["Shape"]                                                                                                                        = "Forme"
L["Border shape. Use Circle for round Masque button skins."]                                                                      =
"Forme de la bordure. Utilisez Cercle pour les skins de boutons Masque ronds."
L["Square"]                                                                                                                       = "Carré"
L["Circle"]                                                                                                                       = "Cercle"
L["Pulse Speed"]                                                                                                                  = "Vitesse de pulsation"
L["Controls how fast the border pulses."]                                                                                         =
"Contrôle la vitesse de pulsation de la bordure."
L["Alpha minimum"]                                                                                                                = "Alpha minimum"
L["Minimum opacity at the trough of the animation. 0 = fully fades out, above 0 = always visible."]                               =
"Opacité minimale au creux de l'animation. 0 = disparaît complètement, au-dessus de 0 = toujours visible."
L["Alpha maximum"]                                                                                                                = "Alpha maximum"
L["Maximum opacity at the peak of the animation."]                                                                                =
"Opacité maximale au pic de l'animation."
L["Border Width"]                                                                                                                 = "Largeur de la bordure"
L["Border width in pixels. 0 = automatic (6 % of button size)."]                                                                  =
"Largeur de la bordure en pixels. 0 = automatique (6 % de la taille du bouton)."
L["Border Padding"]                                                                                                               = "Marge de la bordure"
L["Distance from the button edge in pixels. Positive = extends outside the button, negative = inset inside the button."]          =
"Distance du bord du bouton en pixels. Positif = déborde à l'extérieur du bouton, négatif = encadré à l'intérieur du bouton."
L["Debuff Color"]                                                                                                                 = "Couleur de débuff"
L["Type Colors"]                                                                                                                  = "Couleurs par type"
L["Per debuff type"]                                                                                                              = "Par type de débuff"
L["Use a different color per debuff type (Magic, Curse, Poison, Disease)."]                                                       =
"Utilise une couleur différente par type de débuff (Magie, Malédiction, Poison, Maladie)."
L["Magic"]                                                                                                                        = "Magie"
L["Curse"]                                                                                                                        = "Malédiction"
L["Poison"]                                                                                                                       = "Poison"
L["Disease"]                                                                                                                      = "Maladie"
L["Preview"]                                                                                                                      = "Aperçu"
L["Simulate dispel alert"]                                                                                                        = "Simuler l'alerte de dissipation"
L["Show the alert on all dispel buttons so you can adjust appearance outside of combat."]                                         =
"Affiche l'alerte sur tous les boutons de dissipation pour ajuster l'apparence hors combat."
L["Periodic dispel resync"]                                                                                                       = "Periodic dispel resync"
L["Run a periodic full dispel check every second to recover from rare missed aura updates (prevents stuck blinking alerts)."]     =
"Run a periodic full dispel check every second to recover from rare missed aura updates (prevents stuck blinking alerts)."
L["Resync interval (sec)"]                                                                                                        = "Resync interval (sec)"
L["How often the periodic dispel resync runs."]                                                                                   = "How often the periodic dispel resync runs."
L["Sound"]                                                                                                                        = "Son"
L["Activate sound"]                                                                                                               = "Activer le son"
L["Plays a sound when a party member gets a dispellable debuff."]                                                                 =
"Joue un son quand un membre du groupe reçoit un débuff dissipable."
L["Channel"]                                                                                                                      = "Canal"
L["Audio Channel for Dispel Alert Sound"]                                                                                         = "Canal audio pour le son d'alerte de dissipation"

-- Masque
L["Masque"]                                                                                                                       = "Masque"
L["Open Masque Options"]                                                                                                          = "Ouvrir les options Masque"
L["Open the Masque skin options for SupportUnitButtons."]                                                                         =
"Ouvre les options de skin Masque pour SupportUnitButtons."
L["Masque is required to skin the buttons.\nInstall Masque to enable this feature."]                                              =
"Masque est requis pour styliser les boutons.\nInstallez Masque pour activer cette fonctionnalité."

-- Nombre de réactifs
L["Reagent Count"]                                                                                                                = "Nombre de réactifs"
L["Show the reagent count on spell buttons that require reagents, replacing the default count display."]                          =
"Affiche le nombre de réactifs sur les boutons de sort qui nécessitent des réactifs, en remplaçant l'affichage du compte par défaut."

-- Statut du buff
L["Buff Status"]                                                                                                                  = "Statut du buff"
L["Show remaining buff duration in the button corner when the button's spell is active on the target, or \"-\" when not active."] =
"Affiche la durée restante du buff dans le coin du bouton lorsque le sort est actif sur la cible, ou \"-\" s'il n'est pas actif."
L["Low threshold (sec)"]                                                                                                          = "Seuil bas (sec)"
L["Switch to the low-time color when remaining duration drops below this value (seconds)."]                                       =
"Passe à la couleur de temps bas lorsque la durée restante tombe en dessous de cette valeur (secondes)."
L["Low-time color"]                                                                                                               = "Couleur temps bas"
