# Claude Instructions

## Principles

- **DRY** — Don't Repeat Yourself. Reuse existing code, avoid duplication.
  - Magic strings (e.g. CVar names) must be declared as named constants — never inlined at call sites.
  - Repeated boolean expressions must be wrapped in a dedicated predicate function (e.g. `IsPersonalResourceEnabled()`).
- **KISS** — Keep It Simple, Stupid. Prefer the simplest solution that works.
- **SRP** — Single Responsibility Principle. Each function and frame does one thing only.
  - Function names must be specific and self-describing. Vague names like `EnableTracking`/`DisableTracking` are not acceptable — name exactly what the function does (e.g. `RegisterHPTracking`/`UnregisterHPTracking`).
  - Side effects (e.g. print statements) must not be mixed into unrelated functions. Extract them into a dedicated function (e.g. `NotifyPersonalResourceDisabled()`).
- **Separation of Concerns** — keep unrelated logic apart; don't mix setup, events, and updates in the same block.
- No single-line `if/then/end` blocks — always expand to multiple lines.

## Reference Resources

Always consult these before implementing WoW API usage:
- https://warcraft.wiki.gg/ — primary WoW wiki, API docs
- https://wowpedia.fandom.com/wiki/World_of_Warcraft_API — API reference
- https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns — Blizzard's own UI source, use to find real usage examples (e.g. how `UnitHealthPercent` is actually called)

## Namespace

- `RBT` is the addon namespace, injected via `local _, RBT = ...` at the top of each file.
- `RBT.Core` holds all public API — bars, labels, and functions called from other modules (e.g. Options.lua).
- `RBT.DB` holds database/settings access. Aliased locally as `local DB = RBT.DB`.
- `RBT.Options` holds the options panel registration.
- Internal implementation details stay `local` — only promote to `RBT.Core` if another module needs it.

## File Structure

- `DB.lua` — saved variables, defaults, getters/setters
- `Options.lua` — settings panel registration, calls into `RBT.Core.*`
- `ResourceBarText.lua` — all runtime logic: labels, frames, tracking, state

## Module Design: ResourceBarText.lua Section Order

Sections must appear in this order:

```
-- Constants
-- Shared predicate        (IsPersonalResourceEnabled — referenced by both HP and Resource)
-- Shared utilities        (CreateBarLabel, PositionLabelPair, Refresh*LabelPosition)
-- HP                      (all HP concerns, top to bottom)
-- Resource                (all Resource concerns, top to bottom)
-- Initialization          (initFrame, specFrame)
-- CVar tracking           (NotifyPersonalResourceDisabled, cvarFrame)
```

Within each domain block (HP / Resource), functions appear in this order:
`Prepare*` → `Update*` → frame → `Register*` / `Unregister*` → `Show*` / `Hide*` → `RBT.Core.Refresh*State`

## Frame Design

- Use separate frames per concern. No frame handles unrelated events.
- `initFrame` — `PLAYER_ENTERING_WORLD` only. Runs DB init, options registration, label creation, and initial state refresh.
- `specFrame` — `PLAYER_SPECIALIZATION_CHANGED` only. Calls `RefreshResourceLabelState` (spec affects resource power type, not HP).
- `hpFrame` — `UNIT_HEALTH` only (registered/unregistered dynamically).
- `resourceFrame` — `UNIT_POWER_UPDATE`, `UNIT_POWER_FREQUENT`, and optionally `UPDATE_SHAPESHIFT_FORM` for Druids (registered/unregistered dynamically).
- `cvarFrame` — `CVAR_UPDATE` only. Fires notification and refreshes both label states on personal resource toggle.

## Naming Conventions

- Public API: `Refresh<Domain><Concern>` — e.g. `RefreshHPLabelState`, `RefreshHPLabelPosition`, `RefreshResourceLabelState`, `RefreshResourceLabelPosition`.
- Function names use singular to describe the concept, not the number of underlying objects — e.g. `ShowHPLabel`, `HideHPLabel`, not `ShowHPLabels`.
- Predicates: `Is*` — e.g. `IsPersonalResourceEnabled`.
- Notification side-effects: `Notify*` — e.g. `NotifyPersonalResourceDisabled`.

## Lua / WoW Addon Structure

- Use separate frames per concern (e.g. one for init events, one for HP tracking, one for resource tracking). No mega-frames handling unrelated events together.
- Each frame owns only the events it directly needs.
- Shared logic lives in plain local functions that frames call into — no duplication across handlers.
- Never manipulate anchor points at runtime (`SetPoint`/`ClearAllPoints`) inside frequent event handlers (UNIT_HEALTH, UNIT_POWER_UPDATE, etc.). `SetPoint`/`ClearAllPoints` is acceptable in options callbacks (user-triggered, once).

## Label Display Conventions

- A "label" in this addon is conceptually a pair: a value `FontString` and a percent-symbol `FontString`. They are always shown and hidden together.
- `Update*` functions are pure text updates — they must never call `:Show()` or `:Hide()`.
- `Show*` calls the corresponding `Update*` internally so labels are never shown with stale values, then shows both members of the pair.
- `Hide*` hides both members of the pair.
- For resource labels, `Update*` sets the pct label text to `"%"` or `""` based on power type — visibility is still owned by `Show*`/`Hide*`.
- `Refresh*LabelPosition` is the public API for repositioning a label pair. Internal positioning logic lives in the local `PositionLabelPair` utility.
