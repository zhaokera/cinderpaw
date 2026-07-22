# QA Evidence: Old Factory Aftershock Condenser Valve Production Combat Savepoint Handoff

**Story**: Player Abilities Story214

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify that Story094 starts only from fresh production movement, stages a
readable Spark/Coil pincer, accepts real player attacks, preserves live death
presentation, clears once, and hands Story095 to contact-ready state without
same-frame savepoint consumption.

No new visual asset, combat move, damage value, SaveSystem schema or full
Factory replacement was introduced.

## TDD Evidence

- `reports/report_2292/results.xml`: canonical RED, `1` case with `6`
  expected failures covering stationary activation, pincer spacing and live
  death state.
- `reports/report_2297/results.xml`: final focused GREEN, `1/1`.
- `reports/report_2298/results.xml`: final bounded related, `6/6`
  across Story213, Story094, Story095 and Story214; zero
  failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

## Smoke Evidence

`reports/old_factory_aftershock_condenser_valve_production_combat_savepoint_handoff_smoke.log`
completed `180` fixed-FPS frames and exited `0`. The project log contained no
parse/script error, invalid call/access, missing resource or resource-load
error. Godot's existing ObjectDB/resource cleanup messages remained
stdout-only.

## MCP Runtime Evidence

Final accepted session/run: `cinderpaw@1b14` / `r149702722-5`.

- A stationary player at the activation threshold left Story094 inactive; real
  `move_right` advanced Cinderpaw to x `3941.67` and activated the encounter.
- Spark/Coil started around x `4062.4/3744`, visible, targeted and at the
  deterministic nonlethal setup of `12` HP.
- Two real `attack` inputs produced `cat_claw_light` hits and defeated entities
  `2136/2137`. Immediate samples showed `death` animation, visible/process on,
  and physics/target off.
- After the second death, Story094 was cleared with route label
  `Aftershock Condenser Landing Secured`. Story095 was visible, available and
  interaction-ready, but remained unactivated in the lethal frame.
- Inputs `move_right/move_left/interact/attack/dodge` were false at acceptance.
  Game log contained only the game-helper info row; editor log was empty. The
  project stopped with editor readiness `ready`.
- One discarded exploratory run sampled the first corpse after its authored
  hold/fade cleanup and caused an eval-only null access. Logs were cleared and
  the complete acceptance path was rerun cleanly as `r149702722-5`; no project
  source error was involved.

## Visual Evidence

Non-empty RGB PNG, `1278x718`, SHA-256
`7a5906d04274a1696ca7f4601fc8a3bb38082f7b27228820694361b59657a5b4`:

`reports/visual/cinderpaw-mcp-aftershock-condenser-valve-production-combat-savepoint-handoff-20260722.png`

The saved capture shows Cinderpaw at the secured condenser machinery with the
generated `Repair Condenser Relay` savepoint handoff and no placeholder blocks.
Immediate MCP diagnostics, rather than this post-cleanup capture, record both
live death states.
