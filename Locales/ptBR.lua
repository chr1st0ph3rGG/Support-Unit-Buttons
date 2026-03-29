-------------------------------------------------------------------------------
-- Locales/ptBR.lua  –  Português (Brasil)
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "ptBR")
if not L then return end

-- Abas
L["Bar"]                                                                                                                          = "Barra"
L["Button Overlays"]                                                                                                              = "Sobreposições de botões"
L["Dispel"]                                                                                                                       = "Dissipar"

-- Geral
L["General"]                                                                                                                      = "Geral"
L["Show player bar"]                                                                                                              = "Mostrar barra do jogador"
L["Only in party"]                                                                                                                = "Somente em grupo"
L["Show the player bar only when you are in a group"]                                                                             = "Exibe a barra do jogador somente quando você está em um grupo"
L["Always show name labels"]                                                                                                      = "Sempre exibir rótulos de nome"
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]                                 =
"Exibe o rótulo de nome da unidade mesmo quando as barras estão bloqueadas.\nOs rótulos são sempre exibidos quando desbloqueados."
L["Always show empty buttons"]                                                                                                    = "Sempre mostrar botões vazios"
L["Keep empty slots visible at all times, not only while dragging spells."]                                                       =
"Mantém espaços vazios visíveis o tempo todo, não apenas ao arrastar magias."
L["Drag-off modifier"]                                                                                                            = "Modificador de remoção"
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."]                              =
"Tecla modificadora necessária para arrastar uma magia para FORA de um botão.\nSoltar magias nos botões sempre funciona."
L["Shift"]                                                                                                                        = "Shift"
L["Ctrl"]                                                                                                                         = "Ctrl"
L["Alt"]                                                                                                                          = "Alt"
L["Any"]                                                                                                                          = "Qualquer"

-- Layout de botões
L["Button Layout"]                                                                                                                = "Layout de botões"
L["Button size"]                                                                                                                  = "Tamanho do botão"
L["Width and height of each button (pixels)"]                                                                                     = "Largura e altura de cada botão (pixels)"
L["Button spacing"]                                                                                                               = "Espaçamento dos botões"
L["Gap between buttons (pixels)"]                                                                                                 = "Espaço entre os botões (pixels)"
L["Shared buttons"]                                                                                                               = "Botões compartilhados"
L["Number of shared buttons (same spell/item on all bars)"]                                                                       =
"Número de botões compartilhados (mesma magia/item em todas as barras)"
L["Individual buttons"]                                                                                                           = "Botões individuais"
L["Number of per-member individual buttons"]                                                                                      = "Número de botões individuais por membro"
L["Gap shared/individual"]                                                                                                        = "Espaço compartilhado/individual"
L["Space between the shared and individual button sections (pixels)"]                                                             =
"Espaço entre as seções de botões compartilhados e individuais (pixels)"

-- Posicionamento de barras
L["Bar Positioning"]                                                                                                              = "Posicionamento de barras"
L["Lock bars"]                                                                                                                    = "Travar barras"
L["Prevent bars from being moved by dragging"]                                                                                    = "Impede que as barras sejam movidas arrastando"
L["Mode"]                                                                                                                         = "Modo"
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                                                       =
"Livre: arraste cada barra individualmente.\nAncorado: todas as barras se movem como grupo."
L["Free"]                                                                                                                         = "Livre"
L["Anchored"]                                                                                                                     = "Ancorado"
L["Direction"]                                                                                                                    = "Direção"
L["Vertical"]                                                                                                                     = "Vertical"
L["Horizontal"]                                                                                                                   = "Horizontal"
L["Gap between bars"]                                                                                                             = "Espaço entre barras"
L["Pixels between bars in anchored mode"]                                                                                         = "Pixels entre barras no modo ancorado"
L["Reset positions"]                                                                                                              = "Redefinir posições"
L["ShadowedUnitFrames: anchor each bar next to a SUF party frame."]                                                               =
"ShadowedUnitFrames: Ancore cada barra ao lado de um quadro de grupo SUF."
L["ShadowedUnitFrames"]                                                                                                           = "ShadowedUnitFrames"

-- Ancoragem ShadowedUnitFrames
L["ShadowedUnitFrames Anchor"]                                                                                                    = "Ancoragem ShadowedUnitFrames"
L["Bar anchor point"]                                                                                                             = "Ponto de ancoragem da barra"
L["Which point of the SUB bar to anchor from"]                                                                                    = "Qual ponto da barra SUB usar para a ancoragem"
L["SUF anchor point"]                                                                                                             = "Ponto de ancoragem do quadro SUF"
L["Which point of the SUF frame to attach to"]                                                                                    = "Qual ponto do quadro SUF para o anexo"
L["Horizontal offset from the SUF anchor point (pixels)"]                                                                         =
"Deslocamento horizontal a partir do ponto de ancoragem SUF (pixels)"
L["Vertical offset from the SUF anchor point (pixels)"]                                                                           =
"Deslocamento vertical a partir do ponto de ancoragem SUF (pixels)"

-- Textos comuns (Nível da magia + Contagem de lançamentos)
L["Font"]                                                                                                                         = "Fonte"
L["Font size"]                                                                                                                    = "Tamanho da fonte"
L["Outline"]                                                                                                                      = "Contorno"
L["None"]                                                                                                                         = "Nenhum"
L["Thick outline"]                                                                                                                = "Contorno grosso"
L["Corner"]                                                                                                                       = "Canto"
L["Position"]                                                                                                                     = "Posição"
L["Top left"]                                                                                                                     = "Superior esquerdo"
L["Top"]                                                                                                                          = "Superior"
L["Top right"]                                                                                                                    = "Superior direito"
L["Left"]                                                                                                                         = "Esquerda"
L["Right"]                                                                                                                        = "Direita"
L["Bottom left"]                                                                                                                  = "Inferior esquerdo"
L["Bottom"]                                                                                                                       = "Inferior"
L["Bottom right"]                                                                                                                 = "Inferior direito"
L["Offset X"]                                                                                                                     = "Deslocamento X"
L["Horizontal fine-tuning offset (added to the corner's base position)"]                                                          =
"Deslocamento de ajuste fino horizontal (adicionado à posição base do canto)"
L["Offset Y"]                                                                                                                     = "Deslocamento Y"
L["Vertical fine-tuning offset (added to the corner's base position)"]                                                            =
"Deslocamento de ajuste fino vertical (adicionado à posição base do canto)"
L["Color"]                                                                                                                        = "Cor"
L["Colors"]                                                                                                                       = "Cores"
L["Spell Rank Color"]                                                                                                             = "Cor do nível de magia"
L["Reagent Count Color"]                                                                                                          = "Cor da contagem de reagentes"
L["Normal Color"]                                                                                                                 = "Cor normal"
L["Enable"]                                                                                                                       = "Ativar"

-- Nível da magia
L["Spell Rank"]                                                                                                                   = "Nível da magia"
L["Show spell rank"]                                                                                                              = "Mostrar nível da magia"
L["Display the spell rank number on each button"]                                                                                 = "Exibe o número de nível da magia em cada botão"

-- Contagem de lançamentos / itens
L["Cast Count / Item Count"]                                                                                                      = "Contagem de lançamentos / itens"
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]                                  =
"Exibe quantas vezes uma magia pode ser lançada antes de ficar sem mana,\nou a contagem total de itens nas bolsas."
L["Spell Color"]                                                                                                                  = "Cor da magia"
L["Color of the cast count number for spells"]                                                                                    = "Cor do número de lançamentos para magias"
L["Item Color"]                                                                                                                   = "Cor do item"
L["Color of the cast count number for items"]                                                                                     = "Cor do número de lançamentos para itens"

-- Tutorial
L["Show Tutorial"]                                                                                                                = "Mostrar tutorial"
L["Replay the introductory tutorial"]                                                                                             = "Repetir o tutorial introdutório"
L["TUTORIAL_TITLE"]                                                                                                               = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                                                  =
"Support Unit Buttons adiciona uma barra de ação para cada membro do grupo.\n\nArraste magias ou itens do seu livro de magias ou bolsas para os botões. Clicar em um botão lança a magia – ou usa o item – na unidade daquela barra. Por padrão, as barras de botões estão desbloqueadas e mostram rótulos de nome para facilitar a identificação de qual barra pertence a qual unidade. Após configurar as barras, você pode bloqueá-las para ocultar os rótulos e evitar reposicionamentos acidentais.\n\nVocê tem dois tipos de Support Buttons:\n\n - Botões compartilhados (seção esquerda) contêm a mesma magia ou item para todo o grupo.\n\n - Botões individuais (seção direita) podem conter uma magia diferente por jogador (específico do jogador) – ótimo para curas ou buffs específicos de unidade.\n\nO número de botões compartilhados e individuais pode ser configurado nas opções.\nPara arrastar uma magia para FORA de um botão, segure a tecla modificadora (padrão: Shift) enquanto arrasta. Você sempre pode soltar uma nova magia/item em um botão sem nenhum modificador."
L["TUTORIAL_P2"]                                                                                                                  =
"Um botão de unidade contém informações adicionais sobre a magia ou item atribuído:\n- Nível da magia (se aplicável)\n- Lançamentos até ficar sem mana (para magias) ou total de itens nas bolsas\n- Duração do buff no canto do botão quando a magia está ativa como buff no alvo — muda de cor abaixo do limite configurado; mostra \"-\" quando o buff expirou\n- Uma borda vermelha se a unidade tem atualmente um debuff que pode ser dissipado com a magia atribuída\n\nTodos esses podem ser ativados ou desativados nas opções."
L["TUTORIAL_P3"]                                                                                                                  =
"Digite /sub ou /SupportUnitButtons para abrir o painel de Opções a qualquer momento.\n\nVocê também pode encontrá-lo em:\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                                                 = "Abrir opções"

-- Alerta de dissipar
L["Dispel Alert"]                                                                                                                 = "Alerta de dissipar"
L["Show a marching-ants border on buttons that can dispel a debuff the unit currently has."]                                      =
"Exibe uma borda animada nos botões que podem dissipar um debuff atual da unidade."
L["Border Color"]                                                                                                                 = "Cor da borda"
L["Show a pulsing border on buttons that can dispel a debuff the unit currently has."]                                            =
"Exibe uma borda pulsante nos botões que podem dissipar um debuff que a unidade possui no momento."
L["Border Appearance"]                                                                                                            = "Aparência da borda"
L["Shape"]                                                                                                                        = "Forma"
L["Border shape. Use Circle for round Masque button skins."]                                                                      =
"Formato da borda. Use Círculo para skins de botão Masque redondas."
L["Square"]                                                                                                                       = "Quadrado"
L["Circle"]                                                                                                                       = "Círculo"
L["Pulse Speed"]                                                                                                                  = "Velocidade do pulso"
L["Controls how fast the border pulses."]                                                                                         = "Controla quão rápido a borda pulsa."
L["Alpha minimum"]                                                                                                                = "Alfa mínimo"
L["Minimum opacity at the trough of the animation. 0 = fully fades out, above 0 = always visible."]                               =
"Opacidade mínima no ponto mais baixo da animação. 0 = desaparece totalmente, acima de 0 = sempre visível."
L["Alpha maximum"]                                                                                                                = "Alfa máximo"
L["Maximum opacity at the peak of the animation."]                                                                                = "Opacidade máxima no pico da animação."
L["Border Width"]                                                                                                                 = "Largura da borda"
L["Border width in pixels. 0 = automatic (6 % of button size)."]                                                                  =
"Largura da borda em pixels. 0 = automático (6 % do tamanho do botão)."
L["Border Padding"]                                                                                                               = "Espaçamento da borda"
L["Distance from the button edge in pixels. Positive = extends outside the button, negative = inset inside the button."]          =
"Distância da borda do botão em pixels. Positivo = estende para fora do botão, negativo = recua para dentro do botão."
L["Debuff Color"]                                                                                                                 = "Cor de debuff"
L["Type Colors"]                                                                                                                  = "Cores por tipo"
L["Per debuff type"]                                                                                                              = "Por tipo de debuff"
L["Use a different color per debuff type (Magic, Curse, Poison, Disease)."]                                                       =
"Usa uma cor diferente para cada tipo de debuff (Magia, Maldição, Veneno, Doença)."
L["Magic"]                                                                                                                        = "Magia"
L["Curse"]                                                                                                                        = "Maldição"
L["Poison"]                                                                                                                       = "Veneno"
L["Disease"]                                                                                                                      = "Doença"
L["Preview"]                                                                                                                      = "Pré-visualização"
L["Simulate dispel alert"]                                                                                                        = "Simular alerta de dissipar"
L["Show the alert on all dispel buttons so you can adjust appearance outside of combat."]                                         =
"Exibe o alerta em todos os botões de dissipar para ajustar a aparência fora de combate."
L["Sound"]                                                                                                                        = "Som"
L["Activate sound"]                                                                                                               = "Ativar som"
L["Plays a sound when a party member gets a dispellable debuff."]                                                                 =
"Reproduz um som quando um membro do grupo recebe um debuff dissipável."
L["Channel"]                                                                                                                      = "Canal"
L["Audio Channel for Dispel Alert Sound"]                                                                                         = "Canal de áudio para o som de alerta de dissipar"

-- Masque
L["Masque"]                                                                                                                       = "Masque"
L["Open Masque Options"]                                                                                                          = "Abrir opções do Masque"
L["Open the Masque skin options for SupportUnitButtons."]                                                                         =
"Abre as opções de skin do Masque para SupportUnitButtons."
L["Masque is required to skin the buttons.\nInstall Masque to enable this feature."]                                              =
"Masque é necessário para aplicar skins nos botões.\nInstale o Masque para habilitar este recurso."

-- Contagem de reagentes
L["Reagent Count"]                                                                                                                = "Contagem de reagentes"
L["Show the reagent count on spell buttons that require reagents, replacing the default count display."]                          =
"Exibe a contagem de reagentes nos botões de magia que requerem reagentes, substituindo a exibição de contagem padrão."

-- Status do buff
L["Buff Status"]                                                                                                                  = "Status do buff"
L["Show remaining buff duration in the button corner when the button's spell is active on the target, or \"-\" when not active."] =
"Exibe a duração restante do buff no canto do botão quando a magia está ativa no alvo, ou \"-\" se não estiver ativa."
L["Low threshold (sec)"]                                                                                                          = "Limite baixo (seg)"
L["Switch to the low-time color when remaining duration drops below this value (seconds)."]                                       =
"Muda para a cor de tempo baixo quando a duração restante cai abaixo deste valor (segundos)."
L["Low-time color"]                                                                                                               = "Cor tempo baixo"
