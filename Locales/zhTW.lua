-------------------------------------------------------------------------------
-- Locales/zhTW.lua  –  繁體中文
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "zhTW")
if not L then return end

-- 分頁
L["Bar"]                                                                                                                          = "列"
L["Spell"]                                                                                                                        = "法術"
L["Dispel"]                                                                                                                       = "驅散"

-- 一般
L["General"]                                                                                                                      = "一般"
L["Show player bar"]                                                                                                              = "顯示玩家列"
L["Only in party"]                                                                                                                = "僅在隊伍中"
L["Show the player bar only when you are in a group"]                                                                             = "僅在加入隊伍時顯示玩家列"
L["Always show name labels"]                                                                                                      = "始終顯示名稱標籤"
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]                                 =
"即使列被鎖定，也顯示單位名稱標籤。\n解鎖時始終顯示標籤。"
L["Always show empty buttons"]                                                                                                    = "始終顯示空按鈕"
L["Keep empty slots visible at all times, not only while dragging spells."]                                                       =
"始終顯示空欄位，而不僅是在拖曳法術時顯示。"
L["Drag-off modifier"]                                                                                                            = "拖離修飾鍵"
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."]                              =
"從按鈕拖離法術所需的修飾鍵。\n將法術放到按鈕上始終有效。"
L["Shift"]                                                                                                                        = "Shift"
L["Ctrl"]                                                                                                                         = "Ctrl"
L["Alt"]                                                                                                                          = "Alt"
L["Any"]                                                                                                                          = "任意"

-- 按鈕配置
L["Button Layout"]                                                                                                                = "按鈕配置"
L["Button size"]                                                                                                                  = "按鈕大小"
L["Width and height of each button (pixels)"]                                                                                     = "每個按鈕的寬度和高度（像素）"
L["Button spacing"]                                                                                                               = "按鈕間距"
L["Gap between buttons (pixels)"]                                                                                                 = "按鈕之間的間距（像素）"
L["Shared buttons"]                                                                                                               = "共享按鈕"
L["Number of shared buttons (same spell/item on all bars)"]                                                                       = "共享按鈕數量（所有列上相同的法術/物品）"
L["Individual buttons"]                                                                                                           = "個別按鈕"
L["Number of per-member individual buttons"]                                                                                      = "每個成員的個別按鈕數量"
L["Gap shared/individual"]                                                                                                        = "共享/個別間距"
L["Space between the shared and individual button sections (pixels)"]                                                             = "共享和個別按鈕區塊之間的間距（像素）"

-- 列位置
L["Bar Positioning"]                                                                                                              = "列位置"
L["Lock bars"]                                                                                                                    = "鎖定列"
L["Prevent bars from being moved by dragging"]                                                                                    = "防止通過拖動移動列"
L["Mode"]                                                                                                                         = "模式"
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                                                       = "自由：單獨拖動每列。\n錨定：所有列作為一個群組移動。"
L["Free"]                                                                                                                         = "自由"
L["Anchored"]                                                                                                                     = "錨定"
L["Direction"]                                                                                                                    = "方向"
L["Vertical"]                                                                                                                     = "垂直"
L["Horizontal"]                                                                                                                   = "水平"
L["Gap between bars"]                                                                                                             = "列之間的間距"
L["Pixels between bars in anchored mode"]                                                                                         = "錨定模式下列之間的像素"
L["Reset positions"]                                                                                                              = "重置位置"

-- 共用文字（法術等級 + 施法次數）
L["Font"]                                                                                                                         = "字型"
L["Font size"]                                                                                                                    = "字型大小"
L["Outline"]                                                                                                                      = "外框"
L["None"]                                                                                                                         = "無"
L["Thick outline"]                                                                                                                = "粗外框"
L["Corner"]                                                                                                                       = "角落"
L["Position"]                                                                                                                     = "位置"
L["Top left"]                                                                                                                     = "左上"
L["Top"]                                                                                                                          = "上"
L["Top right"]                                                                                                                    = "右上"
L["Left"]                                                                                                                         = "左"
L["Right"]                                                                                                                        = "右"
L["Bottom left"]                                                                                                                  = "左下"
L["Bottom"]                                                                                                                       = "下"
L["Bottom right"]                                                                                                                 = "右下"
L["Offset X"]                                                                                                                     = "偏移 X"
L["Horizontal fine-tuning offset (added to the corner's base position)"]                                                          = "水平微調偏移（添加到角落基礎位置）"
L["Offset Y"]                                                                                                                     = "偏移 Y"
L["Vertical fine-tuning offset (added to the corner's base position)"]                                                            = "垂直微調偏移（添加到角落基礎位置）"
L["Color"]                                                                                                                        = "顏色"
L["Enable"]                                                                                                                       = "啟用"

-- 法術等級
L["Spell Rank"]                                                                                                                   = "法術等級"
L["Show spell rank"]                                                                                                              = "顯示法術等級"
L["Display the spell rank number on each button"]                                                                                 = "在每個按鈕上顯示法術等級數字"

-- 施法次數 / 物品數量
L["Cast Count / Item Count"]                                                                                                      = "施法次數 / 物品數量"
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]                                  =
"顯示法術在法力耗盡前可以施放多少次，\n或背包中的物品總數。"
L["Spell Color"]                                                                                                                  = "法術顏色"
L["Color of the cast count number for spells"]                                                                                    = "法術施法次數的顏色"
L["Item Color"]                                                                                                                   = "物品顏色"
L["Color of the cast count number for items"]                                                                                     = "物品施法次數的顏色"

-- 教學
L["Show Tutorial"]                                                                                                                = "顯示教學"
L["Replay the introductory tutorial"]                                                                                             = "重播入門教學"
L["TUTORIAL_TITLE"]                                                                                                               = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                                                  =
"Support Unit Buttons 為每個隊伍成員新增一條動作列。\n\n將法術或物品從你的法術書或背包拖到按鈕上。點擊按鈕會對該列的單位施放法術或使用物品。預設情況下，按鈕列處於解鎖狀態並顯示名稱標籤，便於識別哪條列屬於哪個單位。設定好列後，你可以鎖定它們以隱藏標籤並防止意外移動。\n\n你有兩種類型的 Support Button：\n\n - 共享按鈕（左側區域）為整個隊伍保存相同的法術或物品。\n\n - 個別按鈕（右側區域）可以為每個玩家保存不同的法術（按玩家設定）— 非常適合針對特定單位的治療或增益。\n\n共享和個別按鈕的數量可以在選項中設定。\n要將法術從按鈕上拖離，拖動時按住修飾鍵（預設：Shift）。你可以隨時將新法術/物品放到按鈕上，無需任何修飾鍵。"
L["TUTORIAL_P2"]                                                                                                                  =
"單位按鈕顯示有關分配的法術或物品的額外資訊：\n- 法術等級（如適用）\n- 法力耗盡前的施法次數（法術）或背包中物品總數\n- 當法術作為增益效果在目標上生效時，在按鈕角落顯示剩餘持續時間 — 低於設定閾值時變色；增益消失後顯示\"-\"\n- 如果單位當前有可以用分配法術驅散的減益效果，則顯示紅色邊框\n\n所有這些都可以在選項中啟用或停用。"
L["TUTORIAL_P3"]                                                                                                                  =
"輸入 /sub 或 /SupportUnitButtons 隨時開啟選項面板。\n\n你也可以在以下位置找到它：\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                                                 = "開啟選項"

-- 驅散提醒
L["Dispel Alert"]                                                                                                                 = "驅散提醒"
L["Show a marching-ants border on buttons that can dispel a debuff the unit currently has."]                                      =
"在可以驅散單位當前所受減益效果的按鈕上顯示動態邊框。"
L["Border Color"]                                                                                                                 = "邊框顏色"
L["Show a pulsing border on buttons that can dispel a debuff the unit currently has."]                                            =
"在可以驅散單位當前減益效果的按鈕上顯示脈衝邊框。"
L["Border Appearance"]                                                                                                            = "邊框外觀"
L["Shape"]                                                                                                                        = "形狀"
L["Border shape. Use Circle for round Masque button skins."]                                                                      = "邊框形狀。圓形 Masque 按鈕外觀請使用圓形。"
L["Square"]                                                                                                                       = "方形"
L["Circle"]                                                                                                                       = "圓形"
L["Pulse Speed"]                                                                                                                  = "脈衝速度"
L["Controls how fast the border pulses."]                                                                                         = "控制邊框脈衝的速度。"
L["Alpha minimum"]                                                                                                                = "最小透明度"
L["Minimum opacity at the trough of the animation. 0 = fully fades out, above 0 = always visible."]                               =
"動畫低點時的最小透明度。0 = 完全淡出，大於 0 = 始終可見。"
L["Alpha maximum"]                                                                                                                = "最大透明度"
L["Maximum opacity at the peak of the animation."]                                                                                = "動畫峰值時的最大透明度。"
L["Border Width"]                                                                                                                 = "邊框寬度"
L["Border width in pixels. 0 = automatic (6 % of button size)."]                                                                  = "邊框寬度（像素）。0 = 自動（按鈕大小的 6%）。"
L["Border Padding"]                                                                                                               = "邊框間距"
L["Distance from the button edge in pixels. Positive = extends outside the button, negative = inset inside the button."]          =
"與按鈕邊緣的距離（像素）。正值 = 向外延伸，負值 = 向內縮進。"
L["Type Colors"]                                                                                                                  = "類型顏色"
L["Per debuff type"]                                                                                                              = "依減益類型"
L["Use a different color per debuff type (Magic, Curse, Poison, Disease)."]                                                       =
"依減益類型使用不同顏色（魔法、詛咒、毒藥、疾病）。"
L["Magic"]                                                                                                                        = "魔法"
L["Curse"]                                                                                                                        = "詛咒"
L["Poison"]                                                                                                                       = "毒藥"
L["Disease"]                                                                                                                      = "疾病"
L["Preview"]                                                                                                                      = "預覽"
L["Simulate dispel alert"]                                                                                                        = "模擬驅散提醒"
L["Show the alert on all dispel buttons so you can adjust appearance outside of combat."]                                         =
"在所有驅散按鈕上顯示提醒，讓你可在非戰鬥狀態調整外觀。"
L["Sound"]                                                                                                                        = "音效"
L["Activate sound"]                                                                                                               = "啟用音效"
L["Plays a sound when a party member gets a dispellable debuff."]                                                                 = "當隊伍成員獲得可驅散的減益效果時播放音效。"
L["Channel"]                                                                                                                      = "頻道"
L["Audio Channel for Dispel Alert Sound"]                                                                                         = "驅散提醒音效的音訊頻道"

-- Masque
L["Masque"]                                                                                                                       = "Masque"
L["Open Masque Options"]                                                                                                          = "開啟 Masque 選項"
L["Open the Masque skin options for SupportUnitButtons."]                                                                         = "開啟 SupportUnitButtons 的 Masque 外觀選項。"
L["Masque is required to skin the buttons.\nInstall Masque to enable this feature."]                                              =
"需要 Masque 才能套用按鈕外觀。\n安裝 Masque 以啟用此功能。"

-- 材料數量
L["Reagent Count"]                                                                                   = "材料數量"
L["Show the reagent count on spell buttons that require reagents, replacing the default count display."] =
"在需要材料的法術按鈕上顯示材料數量，取代預設的數量顯示。"

-- 增益狀態
L["Buff Status"]                                                                                                                  = "增益狀態"
L["Show remaining buff duration in the button corner when the button's spell is active on the target, or \"-\" when not active."] =
"當法術作為增益效果在目標上生效時，在按鈕角落顯示剩餘持續時間，若未生效則顯示\"-\"。"
L["Low threshold (sec)"]                                                                                                          = "低閾值（秒）"
L["Switch to the low-time color when remaining duration drops below this value (seconds)."]                                       =
"當剩餘時間低於此值（秒）時切換至低時間顏色。"
L["Low-time color"]                                                                                                               = "低時間顏色"
