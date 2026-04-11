-------------------------------------------------------------------------------
-- Locales/zhCN.lua  –  简体中文
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "zhCN")
if not L then return end

-- 选项卡
L["Bar"]                                                                                                                          = "条"
L["Button Overlays"]                                                                                                              = "按钮覆盖"
L["Dispel"]                                                                                                                       = "驱散"

-- 常规
L["General"]                                                                                                                      = "常规"
L["Show player bar"]                                                                                                              = "显示玩家条"
L["Only in party"]                                                                                                                = "仅在队伍中"
L["Show the player bar only when you are in a group"]                                                                             = "仅在您加入队伍时显示玩家条"
L["Always show name labels"]                                                                                                      = "始终显示名称标签"
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]                                 =
"即使条被锁定，也显示单位名称标签。\n解锁时始终显示标签。"
L["Always show empty buttons"]                                                                                                    = "始终显示空按钮"
L["Keep empty slots visible at all times, not only while dragging spells."]                                                       =
"始终显示空槽位，而不只是拖动法术时显示。"
L["Drag-off modifier"]                                                                                                            = "拖离修饰键"
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."]                              =
"从按钮拖离法术所需的修饰键。\n将法术放到按钮上始终有效。"
L["Shift"]                                                                                                                        = "Shift"
L["Ctrl"]                                                                                                                         = "Ctrl"
L["Alt"]                                                                                                                          = "Alt"
L["Any"]                                                                                                                          = "任意"

-- 按钮布局
L["Button Layout"]                                                                                                                = "按钮布局"
L["Button size"]                                                                                                                  = "按钮大小"
L["Width and height of each button (pixels)"]                                                                                     = "每个按钮的宽度和高度（像素）"
L["Button spacing"]                                                                                                               = "按钮间距"
L["Gap between buttons (pixels)"]                                                                                                 = "按钮之间的间距（像素）"
L["Shared buttons"]                                                                                                               = "共享按钮"
L["Number of shared buttons (same spell/item on all bars)"]                                                                       = "共享按钮数量（所有条上相同的法术/物品）"
L["Individual buttons"]                                                                                                           = "独立按钮"
L["Number of per-member individual buttons"]                                                                                      = "每个成员的独立按钮数量"
L["Gap shared/individual"]                                                                                                        = "共享/独立间距"
L["Space between the shared and individual button sections (pixels)"]                                                             = "共享和独立按钮部分之间的间距（像素）"

-- 条位置
L["Bar Positioning"]                                                                                                              = "条位置"
L["Lock bars"]                                                                                                                    = "锁定条"
L["Prevent bars from being moved by dragging"]                                                                                    = "防止通过拖动移动条"
L["Mode"]                                                                                                                         = "模式"
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                                                       = "自由：单独拖动每条。\n锚定：所有条作为一个组移动。"
L["Free"]                                                                                                                         = "自由"
L["Anchored"]                                                                                                                     = "锚定"
L["Direction"]                                                                                                                    = "方向"
L["Vertical"]                                                                                                                     = "垂直"
L["Horizontal"]                                                                                                                   = "水平"
L["Gap between bars"]                                                                                                             = "条之间的间距"
L["Pixels between bars in anchored mode"]                                                                                         = "锚定模式下条之间的像素"
L["Reset positions"]                                                                                                              = "重置位置"
L["ShadowedUnitFrames: anchor each bar next to a SUF party frame."]                                                               =
"ShadowedUnitFrames：将每条锚定到 SUF 小队框架旁边。"
L["ShadowedUnitFrames"]                                                                                                           = "ShadowedUnitFrames"

-- ShadowedUnitFrames 锚定
L["ShadowedUnitFrames Anchor"]                                                                                                    = "ShadowedUnitFrames 锚定"
L["Bar anchor point"]                                                                                                             = "条的锚定点"
L["Which point of the SUB bar to anchor from"]                                                                                    = "SUB 条哪个点用于锚定"
L["SUF anchor point"]                                                                                                             = "SUF 框架的锚定点"
L["Which point of the SUF frame to attach to"]                                                                                    = "SUF 框架哪个点用于附着"
L["Horizontal offset from the SUF anchor point (pixels)"]                                                                         = "从 SUF 锚定点的水平偏移（像素）"
L["Vertical offset from the SUF anchor point (pixels)"]                                                                           = "从 SUF 锚定点的垂直偏移（像素）"

-- 共同文本（法术等级 + 施法次数）
L["Font"]                                                                                                                         = "字体"
L["Font size"]                                                                                                                    = "字体大小"
L["Outline"]                                                                                                                      = "轮廓"
L["None"]                                                                                                                         = "无"
L["Thick outline"]                                                                                                                = "粗轮廓"
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
L["Horizontal fine-tuning offset (added to the corner's base position)"]                                                          = "水平微调偏移（添加到角落基础位置）"
L["Offset Y"]                                                                                                                     = "偏移 Y"
L["Vertical fine-tuning offset (added to the corner's base position)"]                                                            = "垂直微调偏移（添加到角落基础位置）"
L["Color"]                                                                                                                        = "颜色"
L["Colors"]                                                                                                                       = "颜色"
L["Spell Rank Color"]                                                                                                             = "法术等级颜色"
L["Reagent Count Color"]                                                                                                          = "材料数量颜色"
L["Normal Color"]                                                                                                                 = "常规颜色"
L["Enable"]                                                                                                                       = "启用"

-- 法术等级
L["Spell Rank"]                                                                                                                   = "法术等级"
L["Show spell rank"]                                                                                                              = "显示法术等级"
L["Display the spell rank number on each button"]                                                                                 = "在每个按钮上显示法术等级数字"

-- 施法次数 / 物品数量
L["Cast Count / Item Count"]                                                                                                      = "施法次数 / 物品数量"
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]                                  =
"显示法术在法力耗尽前可以施放多少次，\n或背包中的物品总数。"
L["Spell Color"]                                                                                                                  = "法术颜色"
L["Color of the cast count number for spells"]                                                                                    = "法术施法次数的颜色"
L["Item Color"]                                                                                                                   = "物品颜色"
L["Color of the cast count number for items"]                                                                                     = "物品施法次数的颜色"

-- 教程
L["Show Tutorial"]                                                                                                                = "显示教程"
L["Replay the introductory tutorial"]                                                                                             = "重播入门教程"
L["TUTORIAL_TITLE"]                                                                                                               = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                                                  =
"Support Unit Buttons 为每个队伍成员添加一个动作条。\n\n将法术或物品从你的法术书或背包拖到按钮上。点击按钮会对该条的单位施放法术或使用物品。默认情况下，按钮条处于解锁状态并显示名称标签，便于识别哪个条属于哪个单位。设置好条后，你可以锁定它们以隐藏标签并防止意外移动。\n\n你有两种类型的 Support Button：\n\n - 共享按钮（左侧区域）为整个队伍保存相同的法术或物品。\n\n - 独立按钮（右侧区域）可以为每个玩家保存不同的法术（按玩家设置）— 非常适合针对特定单位的治疗或增益。\n\n共享和独立按钮的数量可以在选项中配置。\n要将法术从按钮上拖离，拖动时按住修饰键（默认：Shift）。你可以随时将新法术/物品放到按钮上，无需任何修饰键。"
L["TUTORIAL_P2"]                                                                                                                  =
"单位按钮显示有关分配的法术或物品的额外信息：\n- 法术等级（如适用）\n- 法力耗尽前的施法次数（法术）或背包中物品总数\n- 当法术作为增益效果在目标上生效时，在按钮角落显示剩余持续时间 — 低于配置阈值时变色；增益消失后显示\"-\"\n- 如果单位当前有可以用分配法术驱散的减益效果，则显示红色边框\n\n所有这些都可以在选项中启用或禁用。"
L["TUTORIAL_P3"]                                                                                                                  =
"输入 /sub 或 /SupportUnitButtons 随时打开选项面板。\n\n你也可以在以下位置找到它：\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                                                 = "打开选项"

-- 驱散提醒
L["Dispel Alert"]                                                                                                                 = "驱散提醒"
L["Show a marching-ants border on buttons that can dispel a debuff the unit currently has."]                                      =
"在可以驱散单位当前所受减益效果的按钮上显示动态边框。"
L["Border Color"]                                                                                                                 = "边框颜色"
L["Show a pulsing border on buttons that can dispel a debuff the unit currently has."]                                            =
"在可以驱散单位当前减益效果的按钮上显示脉冲边框。"
L["Border Appearance"]                                                                                                            = "边框外观"
L["Shape"]                                                                                                                        = "形状"
L["Border shape. Use Circle for round Masque button skins."]                                                                      = "边框形状。圆形 Masque 按钮皮肤请使用圆形。"
L["Square"]                                                                                                                       = "方形"
L["Circle"]                                                                                                                       = "圆形"
L["Pulse Speed"]                                                                                                                  = "脉冲速度"
L["Controls how fast the border pulses."]                                                                                         = "控制边框脉冲速度。"
L["Alpha minimum"]                                                                                                                = "最小透明度"
L["Minimum opacity at the trough of the animation. 0 = fully fades out, above 0 = always visible."]                               =
"动画最低点时的透明度。0 = 完全淡出，大于 0 = 始终可见。"
L["Alpha maximum"]                                                                                                                = "最大透明度"
L["Maximum opacity at the peak of the animation."]                                                                                = "动画峰值时的最大透明度。"
L["Border Width"]                                                                                                                 = "边框宽度"
L["Border width in pixels. 0 = automatic (6 % of button size)."]                                                                  = "边框宽度（像素）。0 = 自动（按钮大小的 6%）。"
L["Border Padding"]                                                                                                               = "边框间距"
L["Distance from the button edge in pixels. Positive = extends outside the button, negative = inset inside the button."]          =
"与按钮边缘的距离（像素）。正数 = 向外扩展，负数 = 向内收缩。"
L["Debuff Color"]                                                                                                                 = "减益颜色"
L["Type Colors"]                                                                                                                  = "类型颜色"
L["Per debuff type"]                                                                                                              = "按减益类型"
L["Use a different color per debuff type (Magic, Curse, Poison, Disease)."]                                                       =
"按减益类型使用不同颜色（魔法、诅咒、毒药、疾病）。"
L["Magic"]                                                                                                                        = "魔法"
L["Curse"]                                                                                                                        = "诅咒"
L["Poison"]                                                                                                                       = "毒药"
L["Disease"]                                                                                                                      = "疾病"
L["Preview"]                                                                                                                      = "预览"
L["Simulate dispel alert"]                                                                                                        = "模拟驱散提醒"
L["Show the alert on all dispel buttons so you can adjust appearance outside of combat."]                                         =
"在所有驱散按钮上显示提醒，以便你在非战斗状态下调整外观。"
L["Periodic dispel resync"]                                                                                                       = "Periodic dispel resync"
L["Run a periodic full dispel check every second to recover from rare missed aura updates (prevents stuck blinking alerts)."]     =
"Run a periodic full dispel check every second to recover from rare missed aura updates (prevents stuck blinking alerts)."
L["Resync interval (sec)"]                                                                                                        = "Resync interval (sec)"
L["How often the periodic dispel resync runs."]                                                                                   = "How often the periodic dispel resync runs."
L["Sound"]                                                                                                                        = "声音"
L["Activate sound"]                                                                                                               = "启用声音"
L["Plays a sound when a party member gets a dispellable debuff."]                                                                 = "当队伍成员获得可驱散的减益效果时播放声音。"
L["Channel"]                                                                                                                      = "频道"
L["Audio Channel for Dispel Alert Sound"]                                                                                         = "驱散提醒声音的音频频道"

-- Masque
L["Masque"]                                                                                                                       = "Masque"
L["Open Masque Options"]                                                                                                          = "打开 Masque 选项"
L["Open the Masque skin options for SupportUnitButtons."]                                                                         = "打开 SupportUnitButtons 的 Masque 皮肤选项。"
L["Masque is required to skin the buttons.\nInstall Masque to enable this feature."]                                              =
"需要 Masque 才能为按钮应用皮肤。\n安装 Masque 以启用此功能。"

-- 材料数量
L["Reagent Count"]                                                                                                                = "材料数量"
L["Show the reagent count on spell buttons that require reagents, replacing the default count display."]                          =
"在需要材料的法术按钮上显示材料数量，替换默认的数量显示。"

-- 增益状态
L["Buff Status"]                                                                                                                  = "增益状态"
L["Show remaining buff duration in the button corner when the button's spell is active on the target, or \"-\" when not active."] =
"当法术作为增益效果在目标上生效时，在按钮角落显示剩余持续时间，若未生效则显示\"-\"。"
L["Low threshold (sec)"]                                                                                                          = "低阈值（秒）"
L["Switch to the low-time color when remaining duration drops below this value (seconds)."]                                       =
"当剩余时间低于此值（秒）时切换到低时间颜色。"
L["Low-time color"]                                                                                                               = "低时间颜色"

-- Resurrection Alert
L["Resurrection"]                                                                                                                 = "复活"
L["Resurrection Alert"]                                                                                                           = "复活提醒"
L["Show a colored border on resurrection buttons depending on the target's resurrection status."]                                 =
"根据目标的复活状态，在复活按钮上显示彩色边框。"
L["Simulate resurrection alert"]                                                                                                  = "模拟复活提醒"
L["Show all three border colors across the bars so you can adjust their appearance outside of combat."]                           =
"在条上显示三种边框颜色，便于你在脱离战斗时调整外观。"
L["Periodic resync"]                                                                                                              = "周期性重同步"
L["Run a periodic full check to recover from missed death or resurrection events."]                                               =
"定期执行完整检查，以恢复遗漏的死亡或复活事件。"
L["How often the periodic resurrection resync runs."]                                                                             =
"周期性复活重同步的执行频率。"
L["Controls how fast the border pulses. Set to 0 for a fully static border."]                                                     =
"控制边框脉冲速度。设为 0 则边框完全静态。"
L["State Colors"]                                                                                                                 = "状态颜色"
L["Dead (no incoming rez)"]                                                                                                       = "死亡（无复活施加）"
L["Border color when the unit is dead with no resurrection in progress."]                                                         =
"当单位死亡且没有进行中的复活时的边框颜色。"
L["Casting resurrection"]                                                                                                         = "正在施放复活"
L["Border color while a resurrection spell is being cast on the unit."]                                                           =
"当复活法术正在对该单位施放时的边框颜色。"
L["Resurrection pending"]                                                                                                         = "复活待接受"
L["Border color when the resurrection has been cast and the unit has not yet accepted it."]                                       =
"当复活已施放但单位尚未接受时的边框颜色。"
