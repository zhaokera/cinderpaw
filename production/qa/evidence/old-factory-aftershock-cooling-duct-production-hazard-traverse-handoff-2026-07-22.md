# QA Evidence: Old Factory Aftershock Cooling Duct Production Hazard Traverse Handoff

**Story**: Player Abilities Story213

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify that the already-authored Story093 cooling duct runs its timed steam
cycle in the Factory production loop, applies active-window damage, persists
crossing, and does not activate Story094 in the same `_process` frame.

No scene, PNG, SpriteFrames, damage value, timing value or save schema changed.

## TDD Evidence

- `reports/report_2289/report_1/results.xml`: canonical RED, `1` case with `7`
  expected failures because production `_process(delta)` stayed in `grace`.
- `reports/report_2290/report_1/results.xml`: focused GREEN, `1/1`.
- `reports/report_2291/report_1/results.xml`: final bounded related, `6/6`
  across Story211, Story093, Story094 and Story213; zero
  failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

## Smoke Evidence

`reports/old_factory_aftershock_cooling_duct_production_hazard_traverse_handoff_smoke.log`
completed `180` fixed-FPS frames and exited `0`. The project log contained no
parse/script error, invalid call/access, missing resource or resource-load
error. Godot's existing ObjectDB/resource cleanup messages remained stdout-only.

## MCP Runtime Evidence

Final accepted session/run: `cinderpaw@1b14` / `r148345568-3`.

- Production observation: phases
  `[idle, grace, warning, active, safe]`; HP samples
  `[100, 100, 100, 100, 92]` prove one real `8`-damage overlap. At safe, player
  x was `3432.66` and hazard contact was disabled.
- Completion boundary: a real physics movement advanced player x
  `3919.5 -> 3920.17`; the following single production `_process(0)` left
  Story093 `crossed=true`, `active=false`, `phase=crossed`, and contact off.
- Same-frame handoff: Story094 was `visible=true`, `available=true`,
  `active=false`; Spark/Coil Rat remained hidden, without process/physics,
  target or collision activation.
- Inputs `move_right/interact/attack/dodge` were all false at acceptance.
- Game log contained only the game-helper info row; editor log was empty. The
  project stopped with editor readiness `ready`.

## Visual Evidence

Non-empty RGB PNG, `1278x718`, SHA-256
`29100d2cf2141f213aab1df0073cbfcb2c228214016f9aa6a9ca9bfb35d9770b`:

`reports/visual/cinderpaw-mcp-story213-cooling-duct-20260722.png`

The capture shows Cinderpaw clearly framed between the imported duct machinery,
the crossed route objective, no placeholder blocks, and no prematurely visible
Story094 enemies.

The PNG was losslessly re-encoded on 2026-07-22 after Godot 4.7 rejected a
later on-disk encoding. Pixel dimensions and rendered content are unchanged;
Godot 4.7 CLI import and the MCP filesystem scan completed after replacement.
