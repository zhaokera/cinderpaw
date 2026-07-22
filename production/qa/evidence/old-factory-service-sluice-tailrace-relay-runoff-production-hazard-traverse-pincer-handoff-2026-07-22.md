# QA Evidence: Old Factory Service Sluice Tailrace Relay Runoff Production Hazard Traverse Pincer Handoff

**Story**: Player Abilities Story231

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story120 real-movement activation and completion, four-frame steam
readability, exact physical contact damage, and a guarded Story121 waiting
handoff. Story121 combat and Story122 are excluded.

## TDD Evidence

- `reports/report_2384/report_1/results.xml`: canonical RED, `1` case with two
  expected failures for stationary Story120 completion and Story121 activation.
- `reports/report_2385/report_1/results.xml`: focused GREEN, `1/1`.
- `reports/report_2388/report_1/results.xml`: final bounded related GREEN,
  five suites and `7/7`; zero errors, failures, flaky, skipped or orphaned tests.
- The related set covered Story231, Story230, Story228 and Story120/121. Full
  suite was intentionally not run.

## Smoke Evidence

`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_smoke.gd` uses
real `move_right` activation and crossing, physical vent overlap, exact damage
source, stationary crossing protection and a 180-frame Story121 waiting-state
guard. It exited `0` and printed
`story120_production_smoke=passed frames=180`.

## MCP Runtime Evidence

Session `cinderpaw@198e`; accepted run `r192090587-32`, token `32`.

- Session metadata reported Godot `4.7-stable`, plugin `3.0.4` and server
  `3.0.4`. Forced disk reload succeeded and run start reported
  `current_run_errors=[]`.
- With all input released, Cinderpaw at x `13764`, four pixels beyond Story120
  activation, left the route available but `idle`. Real MCP `move_right` then
  advanced x `13754 -> 13775.667` and entered `grace`.
- Deterministic phase probes confirmed four-frame `warning`, four-frame
  `active`, then `safe`. Active contact used collision layer `16`, mask `12`.
- Real physics overlap at vent x `14040` changed HP `100 -> 92`, showed player
  animation `hurt`, and recorded damage `8`, type `steam` and exact source
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff`.
- With no input, x `14324` did not cross exit x `14320`. Real MCP
  `move_right` advanced x `14314 -> 14335.111`, persisted crossed state,
  disabled contact and displayed `Tailrace Relay Runoff Crossed`.
- Story121 became available but inactive with both enemies hidden,
  untargeted and non-processing. No-input x `14644`, plus held `move_right`
  with unchanged x, kept it inactive.
- All driven inputs were false at acceptance. Current game log contained only
  helper registration; editor delta after baseline cursor `2` was empty.
  Playback stopped with editor readiness `ready`. Retained image-import errors
  reported at run start were marked as predating this run and did not appear in
  current-run or editor-delta logs.

## Visual Evidence

- Warning: non-empty RGB `1278x718`, SHA-256
  `7f2943efdb9da58fd87c43ca4ff3379cb9237062d7b650955bd5ee77b98ce203`,
  `reports/visual/cinderpaw-mcp-story231-tailrace-relay-runoff-warning-20260722.png`.
- Active physical damage: non-empty RGB `1278x718`, SHA-256
  `966222182841935f8ad72fcfac31abefa9043f75758be454229330a1cd035357`,
  `reports/visual/cinderpaw-mcp-story231-tailrace-relay-runoff-active-damage-20260722.png`.
- Story121 waiting handoff: non-empty RGB `1278x718`, SHA-256
  `3d622566a4a8690917963f3420e14e775c35ecaf1c5bcb459acb77729903e36f`,
  `reports/visual/cinderpaw-mcp-story231-pincer-handoff-20260722.png`.

The captures show authored Factory art, animated Cinderpaw, readable steam and
route feedback; no placeholder blocks are present.

## Asset Review

Existing imported image-generated Factory, Cinderpaw, four-frame steam vent,
Spark Rat and Coil Rat assets fully cover the slice. No image generation or
asset-manifest change was required.

## QA Result

Accepted. Story120 now closes through production movement and physical damage,
while Story121 remains a deliberate next input beat.
