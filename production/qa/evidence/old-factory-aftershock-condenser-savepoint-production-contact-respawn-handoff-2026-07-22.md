# QA Evidence: Old Factory Aftershock Condenser Savepoint Production Contact Respawn Handoff

**Story**: Player Abilities Story215

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify that Story095 is consumed by real movement into its production contact,
persists exactly one savepoint snapshot, drives the live player death/respawn
path, and reveals Story096 without silently starting its hazard traversal.

No new visual/audio asset, SaveSystem schema, player ability contract or full
Factory replacement was introduced.

## TDD Evidence

- `reports/report_2300/results.xml`: refined initial RED, `1` case with
  expected failures for stale prompt/control timing; the run also exposed
  synchronous scene mutation during a physics contact callback.
- `reports/report_2303/results.xml`: boundary RED proving a no-input outlet
  threshold teleport could incorrectly start Story096.
- `reports/report_2305/results.xml`: pending-transition RED proving an old
  current spawn could overwrite the requested condenser savepoint respawn.
- `reports/report_2306/results.xml`: final focused GREEN, `1/1`.
- `reports/report_2307/results.xml`: final bounded related GREEN, `6/6` across
  Story214, Story095, Story096 and Story215; zero
  failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

## Smoke Evidence

`reports/old_factory_aftershock_condenser_savepoint_production_contact_respawn_handoff_smoke.log`
completed `180` fixed-FPS frames and exited `0`. The project log contained no
parse/script error, invalid call/access, missing resource or resource-load
error. Godot's existing ObjectDB/resource cleanup messages remained
stdout-only.

## MCP Runtime Evidence

Final accepted session/run: `cinderpaw@1b14` / `r151899297-9`.

- The initial player position was outside the relay overlap. Real
  `move_right` advanced Cinderpaw `70.00195px` into `body_entered` and activated
  the savepoint exactly once without `interact`.
- Activation hid `Repair Condenser Relay`, disabled contact/collision, stored
  scene `area_03_factory` and spawn
  `lower_deck_forward_pressure_aftershock_condenser_savepoint`, and spawned one
  existing unlock burst.
- Real lethal `apply_damage` entered `death` / `dying`. After the authored
  death hold, the player was at distance `0` from the relay with `50/100` HP,
  `revive`, respawn flash, locked control and route label
  `Returned to Aftershock Condenser Savepoint`.
- The flow subsequently reached `playing` with control unlocked. Story096
  remained visible/available but `idle`, inactive, uncrossed and without hazard
  contact through activation and respawn.
- Inputs `move_right/move_left/interact/attack/dodge` were false at acceptance.
  Game log contained only the game-helper info row; editor log was empty. The
  project stopped with editor readiness `ready`.

## Visual Evidence

Non-empty RGB PNG, `1278x718`, SHA-256
`e82fbeafdad2bc2c39abb8daa8cedea387c60e0628e348d6291b0db4bfa74310`:

`reports/visual/cinderpaw-mcp-aftershock-condenser-savepoint-production-contact-respawn-handoff-20260722.png`

The capture shows Cinderpaw at the secured generated condenser relay, the
revealed outlet machinery and route feedback, with the stale repair prompt
removed and no placeholder blocks. Immediate MCP diagnostics record the
short-lived activation VFX and revive states.
