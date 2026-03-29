# SupportUnitButtons

A World of Warcraft addon that adds a dedicated action bar for each party member, letting you cast spells or use items directly on any group member with a single click.

Compatible with **Classic**, **TBC Classic**, **Classic MoP**

---

## Features

- **Per-member action bars** — one bar per party member, with an optional player bar
- **Shared + individual sections** — configure up to 12 shared buttons and 6 per-member buttons per bar
- **Direct drag-and-drop setup** — drag spells or items straight onto buttons; dragging off can require a configurable modifier
- **Flexible positioning** — move bars freely, anchor them as a vertical or horizontal group, or anchor them next to ShadowedUnitFrames party frames
- **Button overlays** — optional overlays for spell rank, reagent count, cast count or item count, and buff status
- **Buff status tracking** — shows remaining buff time on active buffs, configurable low-time warning color, and `-` for known inactive buffs
- **Dispel alert** — pulsing border for dispellable debuffs with preview mode, square or circle shape, pulse tuning, optional per-debuff-type colors, and optional sound alert
- **Classic-safe range feedback** — spell buttons use Classic-compatible range checks so out-of-range units dim correctly
- **Replayable tutorial** — built-in onboarding tutorial can be replayed from the options panel
- **Masque support** — skin buttons with any Masque theme
- **Profiles** — full AceDB profile support
- **Localisation** — enUS, deDE, frFR, esES, itIT, koKR, ptBR, zhCN, zhTW

---

## Usage

Drag spells or items from your spellbook or bags onto any button. Clicking a button casts the spell — or uses the item — on that bar's unit.

To drag a spell **off** a button, hold the modifier key (default: **Shift**) while dragging. Dropping a new spell/item onto a button never requires a modifier.

On a fresh profile, the addon shows a short tutorial automatically. You can replay it at any time from the options.

---

## Commands

| Command | Description |
|---|---|
| `/sub` | Open the options panel |
| `/SupportUnitButtons` | Open the options panel |

The options panel is also accessible via **Interface → AddOns → SupportUnitButtons**.

---

## Options

### Bar tab
| Setting | Description |
|---|---|
| Show player bar | Include the player's own bar |
| Only in party | Show player bar only when in a group |
| Always show name labels | Keep unit labels visible when locked |
| Always show empty buttons | Keep empty slots visible at all times |
| Show Tutorial | Replay the introductory tutorial |
| Drag-off modifier | Modifier required to drag a spell off a button |
| Button size / spacing | Size and gap of buttons in pixels |
| Shared / individual button count | How many buttons of each type (max 12 shared, 6 individual) |
| Lock bars | Prevent accidental repositioning |
| Position mode | **Free**, **Anchored**, or **ShadowedUnitFrames** when SUF is installed |
| Anchored mode | Set group direction, gap, and reset positions |
| ShadowedUnitFrames anchor | Choose SUB anchor point, SUF anchor point, and X/Y offsets |
| Masque | Opens Masque skin options for the addon when Masque is installed |

### Button Overlays tab
- **Spell Rank** — toggle and style the rank label with font, size, outline, corner, offset, and color
- **Cast Count / Item Count** — toggle and style the OOM counter or bag item count with separate spell and item colors
- **Reagent Count** — toggle and style the reagent-based cast counter with font, size, outline, corner, offset, and color
- **Buff Status** — toggle and style the buff duration indicator with font, size, outline, position, offsets, normal color, low-time color, and threshold in seconds

### Dispel tab
- Enable or preview the dispel alert border
- Choose border shape, pulse speed, opacity range, width, and padding
- Use one shared color or separate colors for Magic, Curse, Poison, and Disease
- Enable or disable a sound alert and pick both sound and audio channel

### Profiles tab
- Standard AceDB profile management for per-character and shared setups

---

## Installation

1. Download and unzip into your `Interface/AddOns/` folder.
2. The folder must be named `SupportUnitButtons`.
3. Restart the game or reload the UI (`/reload`).

---

## Author

**chr1st0ph3rGG** — v1.0.0
