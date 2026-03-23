-------------------------------------------------------------------------------
-- Locales/esES.lua  –  Español (España / Latinoamérica)
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "esES")
if not L then return end

-- Pestañas
L["Bar"]                                                                                             = "Barra"
L["Spell"]                                                                                           = "Hechizo"
L["Dispel"]                                                                                          = "Disipar"

-- General
L["General"]                                                                                         = "General"
L["Show player bar"]                                                                                 = "Mostrar barra del jugador"
L["Only in party"]                                                                                   = "Solo en grupo"
L["Show the player bar only when you are in a group"]                                                = "Muestra la barra del jugador solo cuando estás en un grupo"
L["Always show name labels"]                                                                         = "Mostrar siempre etiquetas de nombre"
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]    =
"Muestra el nombre de la unidad incluso cuando las barras están bloqueadas.\nLas etiquetas siempre se muestran cuando están desbloqueadas."
L["Drag-off modifier"]                                                                               = "Modificador de extracción"
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."] =
"Tecla modificadora requerida para arrastrar un hechizo FUERA de un botón.\nSoltar hechizos en los botones siempre funciona."
L["Shift"]                                                                                           = "Mayús"
L["Ctrl"]                                                                                            = "Ctrl"
L["Alt"]                                                                                             = "Alt"
L["Any"]                                                                                             = "Cualquiera"

-- Diseño de botones
L["Button Layout"]                                                                                   = "Diseño de botones"
L["Button size"]                                                                                     = "Tamaño de botón"
L["Width and height of each button (pixels)"]                                                        = "Ancho y alto de cada botón (píxeles)"
L["Button spacing"]                                                                                  = "Espaciado de botones"
L["Gap between buttons (pixels)"]                                                                    = "Espacio entre botones (píxeles)"
L["Shared buttons"]                                                                                  = "Botones compartidos"
L["Number of shared buttons (same spell/item on all bars)"]                                          =
"Número de botones compartidos (mismo hechizo/objeto en todas las barras)"
L["Individual buttons"]                                                                              = "Botones individuales"
L["Number of per-member individual buttons"]                                                         = "Número de botones individuales por miembro"
L["Gap shared/individual"]                                                                           = "Espacio compartido/individual"
L["Space between the shared and individual button sections (pixels)"]                                =
"Espacio entre las secciones de botones compartidos e individuales (píxeles)"

-- Posicionamiento de barras
L["Bar Positioning"]                                                                                 = "Posicionamiento de barras"
L["Lock bars"]                                                                                       = "Bloquear barras"
L["Prevent bars from being moved by dragging"]                                                       = "Evita que las barras se muevan arrastrando"
L["Mode"]                                                                                            = "Modo"
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                          =
"Libre: arrastra cada barra individualmente.\nAnclado: todas las barras se mueven como grupo."
L["Free"]                                                                                            = "Libre"
L["Anchored"]                                                                                        = "Anclado"
L["Direction"]                                                                                       = "Dirección"
L["Vertical"]                                                                                        = "Vertical"
L["Horizontal"]                                                                                      = "Horizontal"
L["Gap between bars"]                                                                                = "Espacio entre barras"
L["Pixels between bars in anchored mode"]                                                            = "Píxeles entre barras en modo anclado"
L["Reset positions"]                                                                                 = "Restablecer posiciones"

-- Textos comunes (Rango del hechizo + Recuento de lanzamientos)
L["Font"]                                                                                            = "Fuente"
L["Font size"]                                                                                       = "Tamaño de fuente"
L["Outline"]                                                                                         = "Contorno"
L["None"]                                                                                            = "Ninguno"
L["Thick outline"]                                                                                   = "Contorno grueso"
L["Corner"]                                                                                          = "Esquina"
L["Top left"]                                                                                        = "Arriba a la izquierda"
L["Top right"]                                                                                       = "Arriba a la derecha"
L["Bottom left"]                                                                                     = "Abajo a la izquierda"
L["Bottom right"]                                                                                    = "Abajo a la derecha"
L["Offset X"]                                                                                        = "Desplazamiento X"
L["Horizontal fine-tuning offset (added to the corner's base position)"]                             =
"Desplazamiento de ajuste fino horizontal (añadido a la posición base de la esquina)"
L["Offset Y"]                                                                                        = "Desplazamiento Y"
L["Vertical fine-tuning offset (added to the corner's base position)"]                               =
"Desplazamiento de ajuste fino vertical (añadido a la posición base de la esquina)"
L["Color"]                                                                                           = "Color"
L["Enable"]                                                                                          = "Activar"

-- Rango del hechizo
L["Spell Rank"]                                                                                      = "Rango del hechizo"
L["Show spell rank"]                                                                                 = "Mostrar rango del hechizo"
L["Display the spell rank number on each button"]                                                    = "Muestra el número de rango del hechizo en cada botón"

-- Recuento de lanzamientos / objetos
L["Cast Count / Item Count"]                                                                         = "Recuento de lanzamientos / objetos"
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]     =
"Muestra cuántas veces se puede lanzar un hechizo antes de quedarse sin maná,\no el recuento total de objetos en las bolsas."
L["Spell Color"]                                                                                     = "Color del hechizo"
L["Color of the cast count number for spells"]                                                       = "Color del número de lanzamientos para hechizos"
L["Item Color"]                                                                                      = "Color del objeto"
L["Color of the cast count number for items"]                                                        = "Color del número de lanzamientos para objetos"

-- Tutorial
L["Show Tutorial"]                                                                                   = "Mostrar tutorial"
L["Replay the introductory tutorial"]                                                                = "Repetir el tutorial introductorio"
L["TUTORIAL_TITLE"]                                                                                  = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                     =
"Support Unit Buttons añade una barra de acción para cada miembro del grupo.\n\nArrastra hechizos u objetos desde tu libro de hechizos o bolsas hasta los botones. Al hacer clic en un botón se lanza el hechizo – o se usa el objeto – en la unidad de esa barra. Por defecto, las barras de botones están desbloqueadas y muestran etiquetas de nombre para facilitar identificar qué barra pertenece a qué unidad. Una vez configuradas las barras, puedes bloquearlas para ocultar las etiquetas y evitar reposicionamientos accidentales.\n\nTienes dos tipos de Support Buttons:\n\n - Botones compartidos (sección izquierda) contienen el mismo hechizo u objeto para todo el grupo.\n\n - Botones individuales (sección derecha) pueden contener un hechizo diferente por jugador (específico del jugador) – ideal para curaciones o mejoras específicas de unidad.\n\nEl número de botones compartidos e individuales se puede configurar en las opciones.\nPara arrastrar un hechizo FUERA de un botón, mantén la tecla modificadora (por defecto: Mayús) mientras arrastras. Siempre puedes soltar un nuevo hechizo/objeto en un botón sin ningún modificador."
L["TUTORIAL_P2"]                                                                                     =
"Un botón de unidad contiene información adicional sobre el hechizo u objeto asignado:\n- Rango del hechizo (si aplica)\n- Lanzamientos hasta quedarse sin maná (para hechizos) o total de objetos en las bolsas\n- Duración del buff en la esquina del botón cuando el hechizo está activo como buff en el objetivo — cambia de color bajo el umbral configurado; muestra \"-\" cuando el buff ha expirado\n- Un borde rojo si la unidad tiene actualmente un debuff que puede ser disipado con el hechizo asignado\n\nTodos estos se pueden activar o desactivar en las opciones."
L["TUTORIAL_P3"]                                                                                     =
"Escribe /sub o /SupportUnitButtons para abrir el panel de Opciones en cualquier momento.\n\nTambién lo puedes encontrar en:\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                    = "Abrir opciones"

-- Alerta de disipación
L["Dispel Alert"]                                                                                    = "Alerta de disipación"
L["Show a marching-ants border on buttons that can dispel a debuff the unit currently has."]         =
"Muestra un borde animado en los botones que pueden disipar un debuff actual de la unidad."
L["Border Color"]                                                                                    = "Color del borde"
L["Sound"]                                                                                           = "Sonido"
L["Activate sound"]                                                                                  = "Activar sonido"
L["Plays a sound when a party member gets a dispellable debuff."]                                    =
"Reproduce un sonido cuando un miembro del grupo recibe un debuff disipable."
L["Channel"]                                                                                         = "Canal"
L["Audio Channel for Dispel Alert Sound"]                                                            = "Canal de audio para el sonido de alerta de disipación"

-- Estado del buff
L["Buff Status"]                                                                                     = "Estado del buff"
L["Show remaining buff duration in the button corner when the button's spell is active on the target, or \"-\" when not active."] =
"Muestra la duración restante del buff en la esquina del botón cuando el hechizo está activo en el objetivo, o \"-\" si no está activo."
L["Low threshold (sec)"]                                                                             = "Umbral bajo (seg)"
L["Switch to the low-time color when remaining duration drops below this value (seconds)."]          =
"Cambia al color de tiempo bajo cuando la duración restante cae por debajo de este valor (segundos)."
L["Low-time color"]                                                                                  = "Color tiempo bajo"
