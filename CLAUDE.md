# Claude Instructions

## Principles

- **DRY** — Don't Repeat Yourself. Reuse existing code, avoid duplication.
  - Magic strings (e.g. CVar names) must be declared as named constants — never inlined at call sites.
  - Repeated boolean expressions must be wrapped in a dedicated predicate function (e.g. `IsPersonalResourceEnabled()`).
- **KISS** — Keep It Simple, Stupid. Prefer the simplest solution that works.
- **SRP** — Single Responsibility Principle. Each function and frame does one thing only.
  - Function names must be specific and self-describing. Vague names like `EnableTracking`/`DisableTracking` are not acceptable — name exactly what the function does (e.g. `RegisterTrackingEvents`/`UnregisterTrackingEvents`).
  - Side effects (e.g. print statements) must not be mixed into unrelated functions. Extract them into a dedicated function (e.g. `NotifyPersonalResourceDisabled()`).
- **Separation of Concerns** — keep unrelated logic apart; don't mix setup, events, and updates in the same block.
- No single-line `if/then/end` blocks — always expand to multiple lines.

## Reference Resources

Always consult these before implementing WoW API usage:
- https://warcraft.wiki.gg/ — primary WoW wiki, API docs
- https://wowpedia.fandom.com/wiki/World_of_Warcraft_API — API reference
- https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns — Blizzard's own UI source, use to find real usage examples (e.g. how `UnitHealthPercent` is actually called)

## Lua / WoW Addon Structure

- Use separate frames per concern (e.g. one for init events, one for HP tracking, one for resource tracking). No mega-frames handling unrelated events together.
- Each frame owns only the events it directly needs.
- Shared logic lives in plain local functions that frames call into — no duplication across handlers.
- Never manipulate anchor points at runtime (`SetPoint`/`ClearAllPoints`). WoW UI taint makes values returned by layout APIs (e.g. `GetPoint()`) unsafe to compare in addon code. Instead, use separate `FontString` labels with fixed positions and `Show()`/`Hide()` them as needed.
