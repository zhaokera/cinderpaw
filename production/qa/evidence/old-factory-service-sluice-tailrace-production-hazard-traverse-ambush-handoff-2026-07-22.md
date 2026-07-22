# QA Evidence: Old Factory Service Sluice Tailrace Production Hazard Traverse Ambush Handoff

**Story**: Player Abilities Story228

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story117 real-movement activation, full animated steam cadence, physical
damage, guarded real-movement crossing and a Story118 handoff that remains
inactive until a later positive-x production frame. Story118 combat is excluded.

## TDD Evidence

- `reports/report_2372/report_1/results.xml`: canonical RED, `1` test and four
  expected failures covering environment tiles and no-input completion/
  activation guards.
- `reports/report_2373/report_1/results.xml`: focused GREEN `1/1`.
- `reports/report_2374/report_1/results.xml` and
  `reports/report_2375/report_1/results.xml`: related diagnostic runs isolated a
  stale Story118 expectation that defeated enemies hide immediately.
- `reports/report_2376/report_1/results.xml`: corrected Story118 live-death
  contract GREEN `2/2`.
- `reports/report_2377/report_1/results.xml`: final five-suite related GREEN
  `7/7`; zero failure/error/skip.
- Full suite was intentionally not run.

## Smoke Evidence

`tests/smoke/old_factory_service_sluice_tailrace_production_hazard_traverse_ambush_handoff_smoke.gd`
completed `180` stationary handoff frames, exited `0`, and printed
`story228_smoke=passed frames=180`.

## MCP Runtime Evidence

Session `cinderpaw@198e`; accepted run `r184730101-26`, token `26`.

- Editor/plugin/server reported Godot `4.7-stable` and MCP `3.0.4`; the forced
  disk reload of `res://scenes/factory_route_transition_shell.tscn` succeeded.
- Run start reported `current_run_errors=[]`. Initial diagnostics confirmed
  Story117 available/inactive, Story118 unavailable/inactive, both tailrace
  tiles on the authored background, four-frame SteamAnimation and six
  three-frame Coil Rat animations.
- Real MCP `move_right` advanced x `12019.900 -> 12020.123` and activated
  Story117 in `grace` with objective `Cross Service Sluice Tailrace`.
- Runtime timing reached non-contact `warning`, active layer `16` / mask `12`,
  then non-contact `safe`; warning and active each retained four frames.
- After the normal hazard cooldown elapsed, the real vent `Area2D` overlap
  applied HP `100 -> 92`, damage `8`, type `steam`, and exact Story117 source.
- No-input x `12484` did not cross. Real `move_right` advanced x
  `12479.900 -> 12480.123`, persisted Story117 crossed and made Story118
  available while leaving it inactive, hidden and untargeted.
- No-input x `12624` plus three stationary frames did not activate Story118;
  all driven input actions were false after acceptance.
- Current-run game log contained only helper registration. Editor delta after
  baseline cursor `2` was empty. Retained pre-run rows referred to an older QA
  PNG and were not emitted by accepted run `26`.
- A preliminary eval probe was discarded after an isolated indentation compile
  error; the affected run was stopped. Accepted run `26` started clean and
  playback stopped at readiness `ready`.

## Visual Evidence

Three non-empty RGB `1278x718` MCP framebuffers showed the warning plume, active
plume and crossed waiting state. Cinderpaw, the authored tailrace background,
vent and objective text were visible; the Coil Rat remained hidden at handoff.

## Asset Review

Existing imported image-generated tailrace background, duct, steam animation,
Cinderpaw and Coil Rat art fully cover this slice. No image generation or asset
manifest change was required.

## QA Result

Accepted. Story117 is now a production movement and physical-hazard beat, while
Story118 remains safely staged for the next combat slice.
