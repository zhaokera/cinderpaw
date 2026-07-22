# QA Evidence: Old Factory Service Sluice Tailrace Ambush Production Combat Relay Handoff

**Story**: Player Abilities Story229

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story118 real-movement activation, real shared-hitbox lethal combat,
live death readability and the visible but unactivated Story119 relay handoff.
Relay activation, autosave and death/respawn are excluded.

## Test Evidence

- `reports/report_2378/report_1/results.xml`: characterization GREEN `1/1`;
  existing production code already met the new contract, so no artificial RED
  was manufactured.
- The old Story118 smoke then failed on one stale immediate-hide assertion,
  identifying a test-contract mismatch rather than a production regression.
- `reports/report_2379/report_1/results.xml`: final five-suite related GREEN
  `7/7`; zero errors, failures, flaky, skipped or orphaned tests.
- Full suite was intentionally not run.

## Smoke Evidence

`tests/smoke/old_factory_service_sluice_tailrace_ambush_smoke.gd` now uses real
movement and attack input, checks live death plus the Story119 waiting handoff,
runs 180 additional frames, exits `0`, and prints
`story118_production_smoke=passed frames=180`.

## MCP Runtime Evidence

Session `cinderpaw@198e`; accepted run `r187717447-28`, token `28`.

- Session metadata reported Godot `4.7-stable`, plugin `3.0.4` and server
  `3.0.4`; forced disk reload of the Factory scene succeeded.
- Run start reported `current_run_errors=[]`. Waiting diagnostics showed
  Story118 available/inactive/hidden, entity `2143`, the registered SpriteFrames
  path and six animations with three frames each.
- Real MCP `move_right` advanced Cinderpaw x `12608.0 -> 12699.662`, activating
  Story118 with the Coil Rat visible, targeted, processing and physics-enabled.
- A deterministic nonlethal setup changed HP `24 -> 12`. Real MCP `attack`
  then produced target `2143`, hitbox `cat_claw_light`, attack type `light`,
  applied damage `12` and HP `0` through the normal player hit path.
- Lethal diagnostics recorded active false, cleared true, target/physics false,
  processing/visibility true, animation `death` frame `2` and route label
  `Repair Tailrace Relay` during the live death window.
- Story119 diagnostics recorded available/visible/monitoring true, activated
  false, empty last-savepoint payload and the exact relay spawn/savepoint ids.
- All driven inputs were false at acceptance. Current game log contained only
  helper registration; editor delta after baseline cursor `2` was empty.
  Playback stopped with editor readiness `ready`.
- Retained pre-run rows referred to a prior Story213 screenshot import and were
  not emitted by run `28`. That evidence was moved to the shorter valid path
  `reports/visual/cinderpaw-mcp-story213-cooling-duct-20260722.png` and its
  references were updated.

## Visual Evidence

- Active encounter: non-empty RGB `1278x718`, SHA-256
  `acfb0955411a6eff732ffe78dd9d00171c7f0c97dad13dd499f5d742bde3413c`,
  `reports/visual/cinderpaw-mcp-story229-tailrace-coil-active-20260722.png`.
- Relay handoff: non-empty RGB `1278x718`, SHA-256
  `d513956c5cf8b700fae3dd6864ce44b15c5a904ce8f5dafa4579c7b9b9c91ae1`,
  `reports/visual/cinderpaw-mcp-story229-tailrace-relay-handoff-20260722.png`.

The first capture shows Cinderpaw and the frame-animated Coil Rat in the
authored tailrace pocket with `Clear Tailrace Coil Rat`. The second shows the
authored relay and `Repair Tailrace Relay` handoff with no placeholder blocks.

## Asset Review

Existing imported image-generated Factory, Cinderpaw, Coil Rat and Relay art
fully cover this slice. No image generation or asset-manifest change was
required.

## QA Result

Accepted. Story118 now has production movement/combat/live-death coverage and
hands the player cleanly to an unactivated Story119 relay.
