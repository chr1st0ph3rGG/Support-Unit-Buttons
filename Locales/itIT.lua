-------------------------------------------------------------------------------
-- Locales/itIT.lua  –  Italiano
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "itIT")
if not L then return end

-- Schede
L["Bar"]                                                                                             = "Barra"
L["Spell"]                                                                                           = "Incantesimo"
L["Dispel"]                                                                                          = "Dissipazione"

-- Generale
L["General"]                                                                                         = "Generale"
L["Show player bar"]                                                                                 = "Mostra barra del giocatore"
L["Only in party"]                                                                                   = "Solo in gruppo"
L["Show the player bar only when you are in a group"]                                                = "Mostra la barra del giocatore solo quando sei in un gruppo"
L["Always show name labels"]                                                                         = "Mostra sempre le etichette dei nomi"
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]    =
"Mostra il nome dell'unità anche quando le barre sono bloccate.\nLe etichette sono sempre mostrate quando sbloccate."
L["Always show empty buttons"]                                                                       = "Mostra sempre i pulsanti vuoti"
L["Keep empty slots visible at all times, not only while dragging spells."]                          =
"Mantiene gli slot vuoti sempre visibili, non solo durante il trascinamento degli incantesimi."
L["Drag-off modifier"]                                                                               = "Modificatore di rimozione"
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."] =
"Tasto modificatore richiesto per trascinare un incantesimo via da un pulsante.\nDepositare incantesimi sui pulsanti funziona sempre."
L["Shift"]                                                                                           = "Shift"
L["Ctrl"]                                                                                            = "Ctrl"
L["Alt"]                                                                                             = "Alt"
L["Any"]                                                                                             = "Qualsiasi"

-- Layout pulsanti
L["Button Layout"]                                                                                   = "Layout pulsanti"
L["Button size"]                                                                                     = "Dimensione pulsante"
L["Width and height of each button (pixels)"]                                                        = "Larghezza e altezza di ogni pulsante (pixel)"
L["Button spacing"]                                                                                  = "Spaziatura pulsanti"
L["Gap between buttons (pixels)"]                                                                    = "Spazio tra i pulsanti (pixel)"
L["Shared buttons"]                                                                                  = "Pulsanti condivisi"
L["Number of shared buttons (same spell/item on all bars)"]                                          =
"Numero di pulsanti condivisi (stesso incantesimo/oggetto su tutte le barre)"
L["Individual buttons"]                                                                              = "Pulsanti individuali"
L["Number of per-member individual buttons"]                                                         = "Numero di pulsanti individuali per membro"
L["Gap shared/individual"]                                                                           = "Spazio condiviso/individuale"
L["Space between the shared and individual button sections (pixels)"]                                =
"Spazio tra le sezioni di pulsanti condivisi e individuali (pixel)"

-- Posizionamento barre
L["Bar Positioning"]                                                                                 = "Posizionamento barre"
L["Lock bars"]                                                                                       = "Blocca barre"
L["Prevent bars from being moved by dragging"]                                                       = "Impedisce lo spostamento delle barre tramite trascinamento"
L["Mode"]                                                                                            = "Modalità"
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                          =
"Libero: trascina ogni barra singolarmente.\nAncorato: tutte le barre si spostano come gruppo."
L["Free"]                                                                                            = "Libero"
L["Anchored"]                                                                                        = "Ancorato"
L["Direction"]                                                                                       = "Direzione"
L["Vertical"]                                                                                        = "Verticale"
L["Horizontal"]                                                                                      = "Orizzontale"
L["Gap between bars"]                                                                                = "Spazio tra le barre"
L["Pixels between bars in anchored mode"]                                                            = "Pixel tra le barre in modalità ancorata"
L["Reset positions"]                                                                                 = "Reimposta posizioni"

-- Testi comuni (Rango incantesimo + Conteggio lanci)
L["Font"]                                                                                            = "Carattere"
L["Font size"]                                                                                       = "Dimensione carattere"
L["Outline"]                                                                                         = "Contorno"
L["None"]                                                                                            = "Nessuno"
L["Thick outline"]                                                                                   = "Contorno spesso"
L["Corner"]                                                                                          = "Angolo"
L["Position"]                                                                                        = "Posizione"
L["Top left"]                                                                                        = "In alto a sinistra"
L["Top"]                                                                                             = "Alto"
L["Top right"]                                                                                       = "In alto a destra"
L["Left"]                                                                                            = "Sinistra"
L["Right"]                                                                                           = "Destra"
L["Bottom left"]                                                                                     = "In basso a sinistra"
L["Bottom"]                                                                                          = "Basso"
L["Bottom right"]                                                                                    = "In basso a destra"
L["Offset X"]                                                                                        = "Offset X"
L["Horizontal fine-tuning offset (added to the corner's base position)"]                             =
"Offset di regolazione orizzontale (aggiunto alla posizione base dell'angolo)"
L["Offset Y"]                                                                                        = "Offset Y"
L["Vertical fine-tuning offset (added to the corner's base position)"]                               =
"Offset di regolazione verticale (aggiunto alla posizione base dell'angolo)"
L["Color"]                                                                                           = "Colore"
L["Enable"]                                                                                          = "Abilita"

-- Rango incantesimo
L["Spell Rank"]                                                                                      = "Rango incantesimo"
L["Show spell rank"]                                                                                 = "Mostra rango incantesimo"
L["Display the spell rank number on each button"]                                                    = "Mostra il numero di rango dell'incantesimo su ogni pulsante"

-- Conteggio lanci / oggetti
L["Cast Count / Item Count"]                                                                         = "Conteggio lanci / oggetti"
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]     =
"Mostra quante volte un incantesimo può essere lanciato prima di esaurire il mana,\no il conteggio totale degli oggetti nelle borse."
L["Spell Color"]                                                                                     = "Colore incantesimo"
L["Color of the cast count number for spells"]                                                       = "Colore del numero di lanci per gli incantesimi"
L["Item Color"]                                                                                      = "Colore oggetto"
L["Color of the cast count number for items"]                                                        = "Colore del numero di lanci per gli oggetti"

-- Tutorial
L["Show Tutorial"]                                                                                   = "Mostra tutorial"
L["Replay the introductory tutorial"]                                                                = "Riproduci il tutorial introduttivo"
L["TUTORIAL_TITLE"]                                                                                  = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                     =
"Support Unit Buttons aggiunge una barra azioni per ogni membro del gruppo.\n\nTrascinare incantesimi o oggetti dal libro degli incantesimi o dalle borse sui pulsanti. Fare clic su un pulsante lancia l'incantesimo – o usa l'oggetto – sull'unità di quella barra. Per impostazione predefinita, le barre dei pulsanti sono sbloccate e mostrano etichette dei nomi per identificare facilmente quale barra appartiene a quale unità. Una volta configurate le barre, è possibile bloccarle per nascondere le etichette e prevenire riposizionamenti accidentali.\n\nHai due tipi di Support Button:\n\n - I pulsanti condivisi (sezione sinistra) contengono lo stesso incantesimo o oggetto per l'intero gruppo.\n\n - I pulsanti individuali (sezione destra) possono contenere un incantesimo diverso per ogni giocatore (specifico per giocatore) – ottimo per cure o buff specifici per unità.\n\nIl numero di pulsanti condivisi e individuali può essere configurato nelle opzioni.\nPer trascinare un incantesimo FUORI da un pulsante, tieni premuto il tasto modificatore (predefinito: Shift) durante il trascinamento. Puoi sempre rilasciare un nuovo incantesimo/oggetto su un pulsante senza alcun modificatore."
L["TUTORIAL_P2"]                                                                                     =
"Un pulsante unità contiene informazioni aggiuntive sull'incantesimo o oggetto assegnato:\n- Rango incantesimo (se applicabile)\n- Lanci fino all'esaurimento del mana (per incantesimi) o totale oggetti nelle borse\n- Durata del buff nell'angolo del pulsante quando l'incantesimo è attivo come buff sul bersaglio — cambia colore sotto la soglia configurata; mostra \"-\" quando il buff è scaduto\n- Un bordo rosso se l'unità ha attualmente un debuff che può essere dissipato con l'incantesimo assegnato\n\nTutti questi possono essere abilitati o disabilitati nelle opzioni."
L["TUTORIAL_P3"]                                                                                     =
"Digita /sub o /SupportUnitButtons per aprire il pannello Opzioni in qualsiasi momento.\n\nPuoi trovarlo anche in:\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                    = "Apri opzioni"

-- Avviso dissipazione
L["Dispel Alert"]                                                                                    = "Avviso dissipazione"
L["Show a pulsing border on buttons that can dispel a debuff the unit currently has."]               =
"Mostra un bordo pulsante sui pulsanti che possono dissipare un debuff attuale dell'unità."
L["Border Appearance"]                                                                               = "Aspetto del bordo"
L["Shape"]                                                                                           = "Forma"
L["Border shape. Use Circle for round Masque button skins."]                                         =
"Forma del bordo. Usa Cerchio per skin di pulsanti Masque rotondi."
L["Square"]                                                                                          = "Quadrato"
L["Circle"]                                                                                          = "Cerchio"
L["Pulse Speed"]                                                                                     = "Velocità pulsazione"
L["Controls how fast the border pulses."]                                                            =
"Controlla la velocità di pulsazione del bordo."
L["Alpha minimum"]                                                                                   = "Alpha minimo"
L["Minimum opacity at the trough of the animation. 0 = fully fades out, above 0 = always visible."] =
"Opacità minima al punto più basso dell'animazione. 0 = svanisce completamente, sopra 0 = sempre visibile."
L["Alpha maximum"]                                                                                   = "Alpha massimo"
L["Maximum opacity at the peak of the animation."]                                                   =
"Opacità massima al picco dell'animazione."
L["Border Width"]                                                                                    = "Spessore bordo"
L["Border width in pixels. 0 = automatic (6 % of button size)."]                                    =
"Spessore del bordo in pixel. 0 = automatico (6 % della dimensione del pulsante)."
L["Border Padding"]                                                                                  = "Spaziatura bordo"
L["Distance from the button edge in pixels. Positive = extends outside the button, negative = inset inside the button."] =
"Distanza dal bordo del pulsante in pixel. Positivo = si estende fuori dal pulsante, negativo = incassato dentro il pulsante."
L["Type Colors"]                                                                                     = "Colori per tipo"
L["Per debuff type"]                                                                                 = "Per tipo di debuff"
L["Use a different color per debuff type (Magic, Curse, Poison, Disease)."]                          =
"Usa un colore diverso per tipo di debuff (Magia, Maledizione, Veleno, Malattia)."
L["Magic"]                                                                                           = "Magia"
L["Curse"]                                                                                           = "Maledizione"
L["Poison"]                                                                                          = "Veleno"
L["Disease"]                                                                                         = "Malattia"
L["Preview"]                                                                                         = "Anteprima"
L["Simulate dispel alert"]                                                                           = "Simula avviso dissipazione"
L["Show the alert on all dispel buttons so you can adjust appearance outside of combat."]            =
"Mostra l'avviso su tutti i pulsanti di dissipazione per regolare l'aspetto fuori dal combattimento."
L["Sound"]                                                                                           = "Suono"
L["Activate sound"]                                                                                  = "Attiva suono"
L["Plays a sound when a party member gets a dispellable debuff."]                                    =
"Riproduce un suono quando un membro del gruppo riceve un debuff dissipabile."
L["Channel"]                                                                                         = "Canale"
L["Audio Channel for Dispel Alert Sound"]                                                            = "Canale audio per il suono di avviso dissipazione"

-- Masque
L["Masque"]                                                                                          = "Masque"
L["Open Masque Options"]                                                                             = "Apri opzioni Masque"
L["Open the Masque skin options for SupportUnitButtons."]                                            =
"Apre le opzioni skin Masque per SupportUnitButtons."
L["Masque is required to skin the buttons.\nInstall Masque to enable this feature."]                 =
"Masque è necessario per applicare skin ai pulsanti.\nInstalla Masque per abilitare questa funzione."

-- Stato del buff
L["Buff Status"]                                                                                     = "Stato del buff"
L["Show remaining buff duration in the button corner when the button's spell is active on the target, or \"-\" when not active."] =
"Mostra la durata rimanente del buff nell'angolo del pulsante quando l'incantesimo è attivo sul bersaglio, o \"-\" se non è attivo."
L["Low threshold (sec)"]                                                                             = "Soglia bassa (sec)"
L["Switch to the low-time color when remaining duration drops below this value (seconds)."]          =
"Passa al colore tempo basso quando la durata rimanente scende sotto questo valore (secondi)."
L["Low-time color"]                                                                                  = "Colore tempo basso"
