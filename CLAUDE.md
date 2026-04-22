# AGENTS.md — Hollow Grid

## Project

Godot 4.6 (Compatibility renderer) 2D game — Demineur Deckbuilder Roguelike.
Viewport: 480x270, scaled 3x to 1440x810, pixel-perfect (Nearest filter).

## GDScript type safety — CRITICAL

Godot is configured to **treat warnings as errors**. Every variable must have a resolvable type at parse time. This is the #1 source of build failures:

- **Dictionary access returns Variant**: always cast. `s["width"]` → `int(s["width"])`. Declare `var s: Dictionary = DICT[key]` not `var s :=`.
- **Array.pop_back() / pop_front() returns Variant**: declare explicit type, e.g. `var pos: Vector2i = stack.pop_back()`.
- **Nested arrays are Variant inside**: `var pattern: Array = arr[i]` then `var inner: int = (pattern[0] as Array).size()`.
- **Never use `:=` when the right-hand side is Variant** (dict access, Array methods, untyped function returns). Use explicit types instead.

## Architecture

```
autoloads/     → Godot singletons: EventBus, GameState, SaveSystem, PlaceholderSprites, PlaceholderAudio
features/grid/ → Core minesweeper: GridData, GridGenerator, GridSolver, GridCell, GridRenderer, GridActions, GridEffects
features/deck/ → (empty, Phase 2)
features/run/  → (empty, Phase 3)
assets/        → Placeholder sprites/audio generated in code (no PNG/WAV files needed)
scenes/        → main_menu/, run/game_scene.tscn
```

- `GridData` (RefCounted) = pure data model. `GridGenerator`/`GridSolver` = static utility classes.
- `GridActions` = game logic (input → data mutations → renderer updates). Wired to `GridRenderer` signals in `game_scene.gd`.
- `GridEffects` listens to `EventBus` for juice (screen shake, hit stop). Uses `PROCESS_MODE_ALWAYS` so it runs during pause.
- All placeholder assets are generated at runtime via `Image`/`AudioStreamWAV` in autoloads — no import files needed.

## Signal flow

Input → `GridRenderer` (cell clicked signals) → `GridActions` (mutates `GridData`, calls renderer updates) → `EventBus` (global signals) → `GridEffects` (juice).

## Development commands

Run/debug via Godot editor. No CLI build/test pipeline yet.

- `R` key = restart game, `Esc` = back to menu (handled in `game_scene.gd`).

## Key conventions

- No comments in code unless requested.
- Feature-based directory structure under `features/`.
- Use `EventBus` autoload for cross-system communication, not direct references.
- `GridData.CellState` enum for cell states.
- Cell size: 14x14px (constant `PlaceholderSprites.CELL_SIZE`).
- Three difficulty presets in `game_scene.gd`: Small(8x8,10), Medium(16x16,40), Large(24x16,70).
