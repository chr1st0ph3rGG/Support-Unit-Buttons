-------------------------------------------------------------------------------
-- Locales/koKR.lua  –  한국어
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("SupportUnitButtons", "koKR")
if not L then return end

-- 탭 이름
L["Bar"]                                                                                             = "바"
L["Spell"]                                                                                           = "주문"
L["Dispel"]                                                                                          = "해제"

-- 일반
L["General"]                                                                                         = "일반"
L["Show player bar"]                                                                                 = "플레이어 바 표시"
L["Only in party"]                                                                                   = "파티에서만"
L["Show the player bar only when you are in a group"]                                                = "그룹에 있을 때만 플레이어 바를 표시합니다"
L["Always show name labels"]                                                                         = "이름 레이블 항상 표시"
L["Show the unit name label even when bars are locked.\nLabels are always shown while unlocked."]    =
"바가 잠겨 있어도 유닛 이름 레이블을 표시합니다.\n잠금 해제 시 레이블은 항상 표시됩니다."
L["Always show empty buttons"]                                                                       = "빈 버튼 항상 표시"
L["Keep empty slots visible at all times, not only while dragging spells."]                          =
"주문을 드래그할 때뿐만 아니라 항상 빈 슬롯을 표시합니다."
L["Drag-off modifier"]                                                                               = "제거 수정자"
L["Modifier key required to drag a spell OFF a button.\nDropping spells onto buttons always works."] =
"버튼에서 주문을 드래그하여 제거하려면 필요한 수정자 키.\n버튼에 주문을 드롭하는 것은 항상 작동합니다."
L["Shift"]                                                                                           = "Shift"
L["Ctrl"]                                                                                            = "Ctrl"
L["Alt"]                                                                                             = "Alt"
L["Any"]                                                                                             = "모두"

-- 버튼 레이아웃
L["Button Layout"]                                                                                   = "버튼 레이아웃"
L["Button size"]                                                                                     = "버튼 크기"
L["Width and height of each button (pixels)"]                                                        = "각 버튼의 너비와 높이 (픽셀)"
L["Button spacing"]                                                                                  = "버튼 간격"
L["Gap between buttons (pixels)"]                                                                    = "버튼 사이의 간격 (픽셀)"
L["Shared buttons"]                                                                                  = "공유 버튼"
L["Number of shared buttons (same spell/item on all bars)"]                                          = "공유 버튼 수 (모든 바에 동일한 주문/아이템)"
L["Individual buttons"]                                                                              = "개별 버튼"
L["Number of per-member individual buttons"]                                                         = "멤버별 개별 버튼 수"
L["Gap shared/individual"]                                                                           = "공유/개별 간격"
L["Space between the shared and individual button sections (pixels)"]                                = "공유 및 개별 버튼 섹션 사이의 간격 (픽셀)"

-- 바 위치 설정
L["Bar Positioning"]                                                                                 = "바 위치 설정"
L["Lock bars"]                                                                                       = "바 잠금"
L["Prevent bars from being moved by dragging"]                                                       = "드래그로 바를 이동하지 못하도록 방지"
L["Mode"]                                                                                            = "모드"
L["Free: drag each bar individually.\nAnchored: all bars move as a group."]                          =
"자유: 각 바를 개별적으로 드래그합니다.\n고정: 모든 바가 그룹으로 이동합니다."
L["Free"]                                                                                            = "자유"
L["Anchored"]                                                                                        = "고정"
L["Direction"]                                                                                       = "방향"
L["Vertical"]                                                                                        = "수직"
L["Horizontal"]                                                                                      = "수평"
L["Gap between bars"]                                                                                = "바 사이 간격"
L["Pixels between bars in anchored mode"]                                                            = "고정 모드에서 바 사이의 픽셀"
L["Reset positions"]                                                                                 = "위치 초기화"

-- 공통 텍스트 (주문 등급 + 시전 횟수)
L["Font"]                                                                                            = "폰트"
L["Font size"]                                                                                       = "폰트 크기"
L["Outline"]                                                                                         = "윤곽선"
L["None"]                                                                                            = "없음"
L["Thick outline"]                                                                                   = "두꺼운 윤곽선"
L["Corner"]                                                                                          = "모서리"
L["Position"]                                                                                        = "위치"
L["Top left"]                                                                                        = "왼쪽 상단"
L["Top"]                                                                                             = "위"
L["Top right"]                                                                                       = "오른쪽 상단"
L["Left"]                                                                                            = "왼쪽"
L["Right"]                                                                                           = "오른쪽"
L["Bottom left"]                                                                                     = "왼쪽 하단"
L["Bottom"]                                                                                          = "아래"
L["Bottom right"]                                                                                    = "오른쪽 하단"
L["Offset X"]                                                                                        = "오프셋 X"
L["Horizontal fine-tuning offset (added to the corner's base position)"]                             = "수평 미세 조정 오프셋 (모서리 기본 위치에 추가됨)"
L["Offset Y"]                                                                                        = "오프셋 Y"
L["Vertical fine-tuning offset (added to the corner's base position)"]                               = "수직 미세 조정 오프셋 (모서리 기본 위치에 추가됨)"
L["Color"]                                                                                           = "색상"
L["Enable"]                                                                                          = "활성화"

-- 주문 등급
L["Spell Rank"]                                                                                      = "주문 등급"
L["Show spell rank"]                                                                                 = "주문 등급 표시"
L["Display the spell rank number on each button"]                                                    = "각 버튼에 주문 등급 번호를 표시합니다"

-- 시전 횟수 / 아이템 수
L["Cast Count / Item Count"]                                                                         = "시전 횟수 / 아이템 수"
L["Show how many times a spell can be cast before going OOM,\nor the total item count in bags."]     =
"마나가 소진되기 전에 주문을 몇 번 시전할 수 있는지 또는\n가방의 총 아이템 수를 표시합니다."
L["Spell Color"]                                                                                     = "주문 색상"
L["Color of the cast count number for spells"]                                                       = "주문에 대한 시전 횟수 색상"
L["Item Color"]                                                                                      = "아이템 색상"
L["Color of the cast count number for items"]                                                        = "아이템에 대한 시전 횟수 색상"

-- 튜토리얼
L["Show Tutorial"]                                                                                   = "튜토리얼 표시"
L["Replay the introductory tutorial"]                                                                = "도입 튜토리얼 다시 보기"
L["TUTORIAL_TITLE"]                                                                                  = "Support Unit Buttons"
L["TUTORIAL_P1"]                                                                                     =
"Support Unit Buttons는 각 파티 멤버를 위한 액션 바를 추가합니다.\n\n주문책이나 가방에서 주문 또는 아이템을 버튼으로 드래그하세요. 버튼을 클릭하면 해당 바의 유닛에게 주문을 시전하거나 아이템을 사용합니다. 기본적으로 버튼 바는 잠금 해제 상태이며 이름 레이블을 표시하여 어느 바가 어느 유닛에 속하는지 쉽게 식별할 수 있습니다. 바를 설정한 후 잠금을 설정하여 레이블을 숨기고 실수로 위치를 바꾸는 것을 방지할 수 있습니다.\n\nSupport Button에는 두 가지 유형이 있습니다:\n\n - 공유 버튼 (왼쪽 섹션): 전체 그룹에 동일한 주문이나 아이템을 보유합니다.\n\n - 개별 버튼 (오른쪽 섹션): 플레이어별로 다른 주문을 보유할 수 있습니다 (플레이어별 설정) – 유닛/플레이어별 힐이나 버프에 적합합니다.\n\n공유 및 개별 버튼의 수는 옵션에서 설정할 수 있습니다.\n버튼에서 주문을 제거하려면 드래그하는 동안 수정자 키 (기본값: Shift)를 누르세요. 수정자 없이도 언제든지 버튼에 새 주문/아이템을 드롭할 수 있습니다."
L["TUTORIAL_P2"]                                                                                     =
"유닛 버튼에는 할당된 주문이나 아이템에 대한 추가 정보가 표시됩니다:\n- 주문 등급 (해당하는 경우)\n- 마나가 소진될 때까지의 시전 횟수 (주문의 경우) 또는 가방의 총 아이템 수\n- 주문이 대상에게 버프로 활성화되어 있을 때 버튼 모서리에 남은 버프 지속 시간 — 설정된 임계값 아래로 떨어지면 색상이 변경되며, 버프가 만료되면 \"-\"를 표시\n- 할당된 주문으로 해제할 수 있는 디버프가 유닛에게 있을 경우 빨간색 테두리\n\n이 설정들은 모두 옵션에서 활성화하거나 비활성화할 수 있습니다."
L["TUTORIAL_P3"]                                                                                     =
"/sub 또는 /SupportUnitButtons를 입력하면 언제든지 옵션 패널을 열 수 있습니다.\n\n다음 경로에서도 찾을 수 있습니다:\n\n Interface > AddOns > SupportUnitButtons."
L["Open Options"]                                                                                    = "옵션 열기"

-- 해제 경고
L["Dispel Alert"]                                                                                    = "해제 경고"
L["Show a pulsing border on buttons that can dispel a debuff the unit currently has."]               =
"유닛이 현재 가진 디버프를 해제할 수 있는 버튼에 맥동 테두리를 표시합니다."
L["Border Appearance"]                                                                               = "테두리 모양"
L["Shape"]                                                                                           = "형태"
L["Border shape. Use Circle for round Masque button skins."]                                         =
"테두리 형태. 둥근 Masque 버튼 스킨에는 원형을 사용하세요."
L["Square"]                                                                                          = "사각형"
L["Circle"]                                                                                          = "원형"
L["Pulse Speed"]                                                                                     = "맥동 속도"
L["Controls how fast the border pulses."]                                                            =
"테두리의 맥동 속도를 조절합니다."
L["Alpha minimum"]                                                                                   = "알파 최솟값"
L["Minimum opacity at the trough of the animation. 0 = fully fades out, above 0 = always visible."] =
"애니메이션 최저점의 최소 불투명도. 0 = 완전히 사라짐, 0 초과 = 항상 표시."
L["Alpha maximum"]                                                                                   = "알파 최댓값"
L["Maximum opacity at the peak of the animation."]                                                   =
"애니메이션 최고점의 최대 불투명도."
L["Border Width"]                                                                                    = "테두리 너비"
L["Border width in pixels. 0 = automatic (6 % of button size)."]                                    =
"테두리 너비(픽셀). 0 = 자동(버튼 크기의 6%)."
L["Border Padding"]                                                                                  = "테두리 여백"
L["Distance from the button edge in pixels. Positive = extends outside the button, negative = inset inside the button."] =
"버튼 가장자리와의 거리(픽셀). 양수 = 버튼 밖으로 확장, 음수 = 버튼 안쪽으로 들어감."
L["Type Colors"]                                                                                     = "유형 색상"
L["Per debuff type"]                                                                                 = "디버프 유형별"
L["Use a different color per debuff type (Magic, Curse, Poison, Disease)."]                          =
"디버프 유형별 다른 색상 사용(마법, 저주, 독, 질병)."
L["Magic"]                                                                                           = "마법"
L["Curse"]                                                                                           = "저주"
L["Poison"]                                                                                          = "독"
L["Disease"]                                                                                         = "질병"
L["Preview"]                                                                                         = "미리보기"
L["Simulate dispel alert"]                                                                           = "해제 경고 시뮬레이션"
L["Show the alert on all dispel buttons so you can adjust appearance outside of combat."]            =
"전투 외부에서 외관을 조정할 수 있도록 모든 해제 버튼에 경고를 표시합니다."
L["Sound"]                                                                                           = "사운드"
L["Activate sound"]                                                                                  = "사운드 활성화"
L["Plays a sound when a party member gets a dispellable debuff."]                                    = "파티 멤버가 해제 가능한 디버프를 받을 때 사운드를 재생합니다."
L["Channel"]                                                                                         = "채널"
L["Audio Channel for Dispel Alert Sound"]                                                            = "해제 경고 사운드의 오디오 채널"

-- Masque
L["Masque"]                                                                                          = "Masque"
L["Open Masque Options"]                                                                             = "Masque 옵션 열기"
L["Open the Masque skin options for SupportUnitButtons."]                                            =
"SupportUnitButtons의 Masque 스킨 옵션을 엽니다."
L["Masque is required to skin the buttons.\nInstall Masque to enable this feature."]                 =
"버튼에 스킨을 적용하려면 Masque가 필요합니다.\nMasque를 설치하여 이 기능을 활성화하세요."

-- 재료 개수
L["Reagent Count"]                                                                                   = "재료 개수"
L["Show the reagent count on spell buttons that require reagents, replacing the default count display."] =
"재료가 필요한 주문 버튼에 재료 개수를 표시하여 기본 개수 표시를 대체합니다."

-- 버프 상태
L["Buff Status"]                                                                                     = "버프 상태"
L["Show remaining buff duration in the button corner when the button's spell is active on the target, or \"-\" when not active."] =
"버프가 대상에게 활성화되어 있을 때 버튼 모서리에 남은 버프 지속 시간을 표시하고, 활성화되어 있지 않으면 \"-\"를 표시합니다."
L["Low threshold (sec)"]                                                                             = "낮은 임계값 (초)"
L["Switch to the low-time color when remaining duration drops below this value (seconds)."]          =
"남은 시간이 이 값(초) 아래로 떨어지면 낮은 시간 색상으로 전환합니다."
L["Low-time color"]                                                                                  = "낮은 시간 색상"
