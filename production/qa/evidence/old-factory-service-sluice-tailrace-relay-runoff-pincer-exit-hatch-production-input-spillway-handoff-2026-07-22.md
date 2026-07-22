# QA Evidence: Old Factory Service Sluice Tailrace Relay Runoff Pincer Exit Hatch Production Input Spillway Handoff

**Story**: Player Abilities Story234

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story123 stale/no-input protection, one fresh production opening edge,
once-only VFX, opened pose and a visible but inactive Story124 handoff. Real
Story124 movement, hazard contact and crossing are excluded.

## TDD Evidence

- `reports/report_2399/results.xml`: canonical RED, one case with eight expected
  failures covering missing routing, hatch pose/z/prompt and spillway guards.
- `reports/report_2400/results.xml`: initial focused GREEN `1/1`.
- `reports/report_2401/results.xml`: initial related GREEN, five suites and
  `7/7`.
- `reports/report_2402/results.xml`: diagnostic RED, one failure proving
  Story123 read nonexistent VFX key `active` instead of `active_count`.
- `reports/report_2403/results.xml`: diagnostic focused GREEN `1/1`.
- `reports/report_2404/results.xml`: final related GREEN, five suites and
  `7/7`; zero failures, errors, flaky, skipped or orphaned tests. Coverage
  includes Story234, Story233, the Story227 router analogue and Story123/124.
- Full-suite testing was intentionally not run.

## Smoke Evidence

`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke.gd`
uses production `Input.interact` for stale, release/no-input, fresh and duplicate
edges; holds the open handoff for 180 frames; and checks no-input placement past
both Story124 thresholds. It exited `0` and printed
`story234_production_smoke=passed frames=180`. The tracked log contains no
runtime errors.

## MCP Runtime Evidence

Session `cinderpaw@198e`; accepted run `r198694429-38`, token `38`.

- Forced disk reload succeeded. Launch reported Godot `4.7-stable`, helper live
  and `current_run_errors=[]`.
- Story122 was restored claimed, Story123 closed and Story124 locked. A real
  `interact` press at x `15920` became stale; moving into the hatch radius while
  held left Story123 closed/blocking with VFX count `0`.
- Release/rearm and no-input placement at the hatch still left it closed. One
  fresh MCP `input_action(interact=true)` then opened it through production
  input exactly once.
- Open diagnostics reported unavailable, monitoring/monitorability off,
  collision disabled, world prompt hidden, `Tailrace Exit Open`, route label
  `Tailrace Runoff Exit Opened`, VFX active/played and spawn count `1`.
- The hatch root remained `(16080,392)`. Child pose was `(48,-136)`, `6deg`,
  child z `-4` and effective z `23`; spillway duct/vent were z `12/18` and
  Cinderpaw was z `26`.
- Story124 became visible/available but stayed inactive, uncrossed, idle and
  non-contacting while input was held. After release, no-input placement at
  x `16564` and x `17044` still left it waiting.
- A duplicate fresh hatch press left VFX spawn count at `1`. Final
  `move_left/move_right/attack/interact/dodge` states were false.
- Current-run game log contained only helper registration. Editor delta after
  cursor `2` was empty; playback stopped at readiness `ready`.

Two retained image-import rows shown at launch predated run `38`. They were
absent from `current_run_errors` and the post-baseline editor delta, so they are
not Story234 runtime errors.

## Visual Evidence

- Closed/ready: non-empty RGB `1278x718`, SHA-256
  `3fe2baf7473e58ffa1fecd914301b4a6eb7ed32369235aa6a0af43469d5ede08`,
  `reports/visual/cinderpaw-mcp-story234-tailrace-exit-hatch-ready-20260722.png`.
- Open/spillway waiting: non-empty RGB `1278x718`, SHA-256
  `92adf35cc1dae45190cd960d7cac9d97dd5b3d732c5b5956030cf1faa060e430`,
  `reports/visual/cinderpaw-mcp-story234-tailrace-exit-hatch-open-spillway-waiting-20260722.png`.

The captures show authored Factory art and animated Cinderpaw. The closed shot
shows the interaction prompt; the opened shot shows the lifted door below the
player layer, the one-shot spark and the revealed spillway without placeholder
rectangles or unreadable overlap.

## Asset Review

Existing imported image-generated deep-bulkhead, unlock-spark, spillway,
four-frame steam-vent and Cinderpaw assets fully cover the slice. No image
generation or import was required; Story123/234 reuse is recorded in the asset
manifest.

## QA Result

Accepted. Story123 now consumes exactly one fresh production input edge and
hands Story124 to the next ACT movement slice without stale input, duplicate
VFX, stationary activation or no-input threshold consumption.
