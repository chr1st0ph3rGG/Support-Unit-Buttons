-------------------------------------------------------------------------------
-- Locales/zhCN.lua  –  简体中文
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "zhCN")
if not L then return end

-- 选项卡
L["Bar"]                                                                                             = "条"
L["Spell"]                                                                                           = "法术"
L["Dispel"]                                                                                          = "驱散"

-- 常规
L["General"]                                                                                         = "常规"
L["Show player bar"]                                                                                 = "显示玩家条"
L["Only in party"]                                                                                   = "仅在队伍中"
L["Show the player bar only when you are in a group"]                                                = "仅在您加入队伍时显示玩家条"
L["Always show name labels"]                                                                         = "始终显示名称标签"
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]    =
"即使条被锁定，也显示单位名称标签。\n解锁时始终显示标签。"
L["Drag-off modifier"]                                                                               = "拖离修饰键"
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."] =
"从按钮拖离法术所需的修饰键。\n将法术放到按钮上始终有效。"
L["Shift"]                                                                                           = "Shift"
L["Ctrl"]                                                                                            = "Ctrl"
L["Alt"]                                                                                             = "Alt"
L["Any"]                                                                                             = "任意"

-- 按钮布局
L["Button Layout"]                                                                                   = "按钮布局"
L["Button size"]                                                                                     = "按钮大小"
L["Width and height of each button (pixels)"]                                                        = "每个按钮的宽度和高度（像素）"
L["Button spacing"]                                                                                  = "按钮间距"
L["Gap between buttons (pixels)"]                                                                    = "按钮之间的间距（像素）"
L["Shared buttons"]                                                                                  = "共享按钮"
L["Number of shared buttons (same spell/item on all bars)"]                                          = "共享按钮数量（所有条上相同的法术/物品）"
L["Individual buttons"]                                                                              = "独立按钮"
L["Number of per-member individual buttons"]                                                         = "每个成员的独立按钮数量"
L["Gap shared/individual"]                                                                           = "共享/独立间距"
L["Space between the shared and individual button sections (pixels)"]                                = "共享和独立按钮部分之间的间距（像素）"

-- 条位置
L["Bar Positioning"]                                                                                 = "条位置"
L["Lock bars"]                                                                                       = "锁定条"
L["Prevent bars from being moved by dragging"]                                                       = "防止通过拖动移动条"
L["Mode"]                                                                                            = "模式"
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                          = "自由：单独拖动每条。\n锚定：所有条作为一个组移动。"
L["Free"]                                                                                            = "自由"
L["Anchored"]                                                                                        = "锚定"
L["Direction"]                                                                                       = "方向"
L["Vertical"]                                                                                        = "垂直"
L["Horizontal"]                                                                                      = "水平"
L["Gap between bars"]                                                                                = "条之间的间距"
L["Pixels between bars in anchored mode"]                                                            = "锚定模式下条之间的像素"
L["Reset positions"]                                                                                 = "重置位置"

-- 共同文本（法术等级 + 施法次数）
L["Font"]                                                                                            = "字体"
L["Font size"]                                                                                       = "字体大小"
L["Outline"]                                                                                         = "轮廓"
L["None"]                                                                                            = "无"
L["Thick outline"]                                                                                   = "粗轮廓"
L["Corner"]                                                                                          = "角落"
L["Top left"]                                                                                        = "左上"
L["Top right"]                                                                                       = "右上"
L["Bottom left"]                                                                                     = "左下"
L["Bottom right"]                                                                                    = "右下"
L["Offset X"]                                                                                        = "偏移 X"
L["Horizontal fine-tuning offset (added to the corner's base position)"]                             = "水平微调偏移（添加到角落基础位置）"
L["Offset Y"]                                                                                        = "偏移 Y"
L["Vertical fine-tuning offset (added to the corner's base position)"]                               = "垂直微调偏移（添加到角落基础位置）"
L["Color"]                                                                                           = "颜色"
L["Enable"]                                                                                          = "启用"

-- 法术等级
L["Spell Rank"]                                                                                      = "法术等级"
L["Show spell rank"]                                                                                 = "显示法术等级"
L["Display the spell rank number on each button"]                                                    = "在每个按钮上显示法术等级数字"

-- 施法次数 / 物品数量
L["Cast Count / Item Count"]                                                                         = "施法次数 / 物品数量"
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]     =
"显示法术在法力耗尽前可以施放多少次，\n或背包中的物品总数。"
L["Spell Color"]                                                                                     = "法术颜色"
L["Color of the cast count number for spells"]                                                       = "法术施法次数的颜色"
L["Item Color"]                                                                                      = "物品颜色"
L["Color of the cast count number for items"]                                                        = "物品施法次数的颜色"

-- 教程
L["Show Tutorial"]                                                                                   = "显示教程"
L["Replay the introductory tutorial"]                                                                = "重播入门教程"
L["TUTORIAL_TITLE"]                                                                                  = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                     =
"Support Unit Buttons 为每个队伍成员添加一个动作条。\n\n将法术或物品从你的法术书或背包拖到按钮上。点击按钮会对该条的单位施放法术或使用物品。默认情况下，按钮条处于解锁状态并显示名称标签，便于识别哪个条属于哪个单位。设置好条后，你可以锁定它们以隐藏标签并防止意外移动。\n\n你有两种类型的 Support Button：\n\n - 共享按钮（左侧区域）为整个队伍保存相同的法术或物品。\n\n - 独立按钮（右侧区域）可以为每个玩家保存不同的法术（按玩家设置）— 非常适合针对特定单位的治疗或增益。\n\n共享和独立按钮的数量可以在选项中配置。\n要将法术从按钮上拖离，拖动时按住修饰键（默认：Shift）。你可以随时将新法术/物品放到按钮上，无需任何修饰键。"
L["TUTORIAL_P2"]                                                                                     =
"单位按钮显示有关分配的法术或物品的额外信息：\n- 法术等级（如适用）\n- 法力耗尽前的施法次数（法术）或背包中物品总数\n- 如果单位当前有可以用分配法术驱散的减益效果，则显示红色边框。\n\n这些可以在选项中启用或禁用。"
L["TUTORIAL_P3"]                                                                                     =
"输入 /sub 或 /SupportUnitButtons 随时打开选项面板。\n\n你也可以在以下位置找到它：\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                    = "打开选项"

-- 驱散提醒
L["Dispel Alert"]                                                                                    = "驱散提醒"
L["Show a marching-ants border on buttons that can dispel a debuff the unit currently has."]         =
"在可以驱散单位当前所受减益效果的按钮上显示动态边框。"
L["Border Color"]                                                                                    = "边框颜色"
L["Sound"]                                                                                           = "声音"
L["Activate sound"]                                                                                  = "启用声音"
L["Plays a sound when a party member gets a dispellable debuff."]                                    = "当队伍成员获得可驱散的减益效果时播放声音。"
L["Channel"]                                                                                         = "频道"
L["Audio Channel for Dispel Alert Sound"]                                                            = "驱散提醒声音的音频频道"
