-------------------------------------------------------------------------------
-- Locales/zhTW.lua  –  繁體中文
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "zhTW")
if not L then return end

-- 分頁
L["Bar"]                                                                                             = "列"
L["Spell"]                                                                                           = "法術"
L["Dispel"]                                                                                          = "驅散"

-- 一般
L["General"]                                                                                         = "一般"
L["Show player bar"]                                                                                 = "顯示玩家列"
L["Only in party"]                                                                                   = "僅在隊伍中"
L["Show the player bar only when you are in a group"]                                                = "僅在加入隊伍時顯示玩家列"
L["Always show name labels"]                                                                         = "始終顯示名稱標籤"
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]    =
"即使列被鎖定，也顯示單位名稱標籤。\n解鎖時始終顯示標籤。"
L["Drag-off modifier"]                                                                               = "拖離修飾鍵"
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."] =
"從按鈕拖離法術所需的修飾鍵。\n將法術放到按鈕上始終有效。"
L["Shift"]                                                                                           = "Shift"
L["Ctrl"]                                                                                            = "Ctrl"
L["Alt"]                                                                                             = "Alt"
L["Any"]                                                                                             = "任意"

-- 按鈕配置
L["Button Layout"]                                                                                   = "按鈕配置"
L["Button size"]                                                                                     = "按鈕大小"
L["Width and height of each button (pixels)"]                                                        = "每個按鈕的寬度和高度（像素）"
L["Button spacing"]                                                                                  = "按鈕間距"
L["Gap between buttons (pixels)"]                                                                    = "按鈕之間的間距（像素）"
L["Shared buttons"]                                                                                  = "共享按鈕"
L["Number of shared buttons (same spell/item on all bars)"]                                          = "共享按鈕數量（所有列上相同的法術/物品）"
L["Individual buttons"]                                                                              = "個別按鈕"
L["Number of per-member individual buttons"]                                                         = "每個成員的個別按鈕數量"
L["Gap shared/individual"]                                                                           = "共享/個別間距"
L["Space between the shared and individual button sections (pixels)"]                                = "共享和個別按鈕區塊之間的間距（像素）"

-- 列位置
L["Bar Positioning"]                                                                                 = "列位置"
L["Lock bars"]                                                                                       = "鎖定列"
L["Prevent bars from being moved by dragging"]                                                       = "防止通過拖動移動列"
L["Mode"]                                                                                            = "模式"
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                          = "自由：單獨拖動每列。\n錨定：所有列作為一個群組移動。"
L["Free"]                                                                                            = "自由"
L["Anchored"]                                                                                        = "錨定"
L["Direction"]                                                                                       = "方向"
L["Vertical"]                                                                                        = "垂直"
L["Horizontal"]                                                                                      = "水平"
L["Gap between bars"]                                                                                = "列之間的間距"
L["Pixels between bars in anchored mode"]                                                            = "錨定模式下列之間的像素"
L["Reset positions"]                                                                                 = "重置位置"

-- 共用文字（法術等級 + 施法次數）
L["Font"]                                                                                            = "字型"
L["Font size"]                                                                                       = "字型大小"
L["Outline"]                                                                                         = "外框"
L["None"]                                                                                            = "無"
L["Thick outline"]                                                                                   = "粗外框"
L["Corner"]                                                                                          = "角落"
L["Top left"]                                                                                        = "左上"
L["Top right"]                                                                                       = "右上"
L["Bottom left"]                                                                                     = "左下"
L["Bottom right"]                                                                                    = "右下"
L["Offset X"]                                                                                        = "偏移 X"
L["Horizontal fine-tuning offset (added to the corner's base position)"]                             = "水平微調偏移（添加到角落基礎位置）"
L["Offset Y"]                                                                                        = "偏移 Y"
L["Vertical fine-tuning offset (added to the corner's base position)"]                               = "垂直微調偏移（添加到角落基礎位置）"
L["Color"]                                                                                           = "顏色"
L["Enable"]                                                                                          = "啟用"

-- 法術等級
L["Spell Rank"]                                                                                      = "法術等級"
L["Show spell rank"]                                                                                 = "顯示法術等級"
L["Display the spell rank number on each button"]                                                    = "在每個按鈕上顯示法術等級數字"

-- 施法次數 / 物品數量
L["Cast Count / Item Count"]                                                                         = "施法次數 / 物品數量"
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]     =
"顯示法術在法力耗盡前可以施放多少次，\n或背包中的物品總數。"
L["Spell Color"]                                                                                     = "法術顏色"
L["Color of the cast count number for spells"]                                                       = "法術施法次數的顏色"
L["Item Color"]                                                                                      = "物品顏色"
L["Color of the cast count number for items"]                                                        = "物品施法次數的顏色"

-- 教學
L["Show Tutorial"]                                                                                   = "顯示教學"
L["Replay the introductory tutorial"]                                                                = "重播入門教學"
L["TUTORIAL_TITLE"]                                                                                  = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                     =
"Support Unit Buttons 為每個隊伍成員新增一條動作列。\n\n將法術或物品從你的法術書或背包拖到按鈕上。點擊按鈕會對該列的單位施放法術或使用物品。預設情況下，按鈕列處於解鎖狀態並顯示名稱標籤，便於識別哪條列屬於哪個單位。設定好列後，你可以鎖定它們以隱藏標籤並防止意外移動。\n\n你有兩種類型的 Support Button：\n\n - 共享按鈕（左側區域）為整個隊伍保存相同的法術或物品。\n\n - 個別按鈕（右側區域）可以為每個玩家保存不同的法術（按玩家設定）— 非常適合針對特定單位的治療或增益。\n\n共享和個別按鈕的數量可以在選項中設定。\n要將法術從按鈕上拖離，拖動時按住修飾鍵（預設：Shift）。你可以隨時將新法術/物品放到按鈕上，無需任何修飾鍵。"
L["TUTORIAL_P2"]                                                                                     =
"單位按鈕顯示有關分配的法術或物品的額外資訊：\n- 法術等級（如適用）\n- 法力耗盡前的施法次數（法術）或背包中物品總數\n- 如果單位當前有可以用分配法術驅散的減益效果，則顯示紅色邊框。\n\n這些可以在選項中啟用或停用。"
L["TUTORIAL_P3"]                                                                                     =
"輸入 /sub 或 /SupportUnitButtons 隨時開啟選項面板。\n\n你也可以在以下位置找到它：\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                    = "開啟選項"

-- 驅散提醒
L["Dispel Alert"]                                                                                    = "驅散提醒"
L["Show a marching-ants border on buttons that can dispel a debuff the unit currently has."]         =
"在可以驅散單位當前所受減益效果的按鈕上顯示動態邊框。"
L["Border Color"]                                                                                    = "邊框顏色"
L["Sound"]                                                                                           = "音效"
L["Activate sound"]                                                                                  = "啟用音效"
L["Plays a sound when a party member gets a dispellable debuff."]                                    = "當隊伍成員獲得可驅散的減益效果時播放音效。"
L["Channel"]                                                                                         = "頻道"
L["Audio Channel for Dispel Alert Sound"]                                                            = "驅散提醒音效的音訊頻道"
