# ResourceBarText

Adds numeric text labels to your Personal Resource Display bars — the floating bars that appear beneath your character during combat.

## Bars

- **Health** — `85%`
- **Mana** — `85%`
- **Energy / Rage / Focus / Fury / Pain / Insanity / Maelstrom / Runic Power** — `85`

Mana is shown as a percentage because raw mana values can be in the millions and would not fit cleanly on the bar. All other resources show the raw integer value.

## Configuration

Open the settings panel with `/rbt` or via Interface → AddOns → ResourceBarText.

- **Enable/disable** HP text and resource text independently
- **Align** each label to the left, center, or right of its bar

## Notes

- Secondary resources (Combo Points, Holy Power, Runes, Soul Shards, etc.) are managed by Blizzard's own UI and are intentionally not modified.
- Labels automatically hide if you disable the Personal Resource Display in your Interface settings.
- Druid shapeshifting is handled — resource labels update correctly on form change.
- Specialization changes are handled — resource label updates to the correct power type on spec switch.
