# SupportUnitButtons

A World of Warcraft addon that adds a dedicated action bar for each party member, letting you cast spells or use items directly on any group member with a single click.

Compatible with **Classic**, **TBC Classic**, **Classic MoP**

---

## Features

- **Per-member action bars** — one bar per party member (including yourself, optional)
    - **Shared buttons** — left section holds the same spell/item for all bars
    - **Individual buttons** — right section holds a different spell/item per member
- **Dispel alert** — pulsing coloured border on buttons whose spell can dispel a debuff the unit currently has, with optional sound
- **Cast count** — shows how many times a spell can be cast before going OOM, or item count in bags
- **Spell rank** — displays the rank number on Classic multi-rank spells
- **Anchored or free positioning** — stack bars vertically/horizontally as a group, or drag each bar individually
- **Masque support** — skin buttons with any Masque theme
- **Profiles** — full AceDB profile support (per-character, shared)
- **Localisation** — enUS, deDE, frFR, esES, itIT, koKR, ptBR, zhCN, zhTW

---

## Usage

Drag spells or items from your spellbook or bags onto any button. Clicking a button casts the spell — or uses the item — on that bar's unit.

To drag a spell **off** a button, hold the modifier key (default: **Shift**) while dragging. Dropping a new spell/item onto a button never requires a modifier.

---

## Commands

| Command | Description |
|---|---|
| `/sub` | Open the options panel |
| `/SupportUnitButtons` | Open the options panel (long form) |

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
| Drag-off modifier | Modifier required to drag a spell off a button |
| Button size / spacing | Size and gap of buttons in pixels |
| Shared / individual button count | How many buttons of each type (max 12 shared, 6 individual) |
| Lock bars | Prevent accidental repositioning |
| Position mode | **Anchored** (move as a group) or **Free** (drag individually) |

### Spell tab
- **Spell Rank** — toggle and style the rank label (font, size, colour, corner, offset)
- **Cast Count / Item Count** — toggle and style the OOM counter / item count (separate colours for spells and items)

### Dispel tab
- Enable/disable the dispel alert border
- Choose border colour
- Enable/disable a sound alert and pick the audio channel

---

## Installation

1. Download and unzip into your `Interface/AddOns/` folder.
2. The folder must be named `SupportUnitButtons`.
3. Restart the game or reload the UI (`/reload`).

---

## Author

**chr1st0ph3rGG** — v1.0.0
