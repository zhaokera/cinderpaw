# QA Evidence: Old Factory Service Sluice Tailrace Relay Runoff Pincer Exit Spillway Production Hazard Traverse Sluice Leech Handoff

**Story**: Player Abilities Story235

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify real Story124 movement activation, four-phase steam timing, one exact
physical hazard hit, guarded crossing and an unconsumed Story126 waiting state.
Story126 successful activation/combat and Story127 transition are excluded.

## TDD Evidence

- `reports/report_2405/results.xml`: canonical RED, one case with exactly two
  failures for no-input crossing and no-input Leech activation.
- `reports/report_2406/results.xml`: initial focused GREEN `1/1`.
- `reports/report_2407/results.xml`: related diagnostic run; new behavior
  passed, while two Story126 assertions still expected immediate enemy hiding.
- `reports/report_2408/results.xml`: standalone Story126 RED reproduced the two
  stale assertions independently of suite order.
- `reports/report_2409/results.xml`: Story126 focused GREEN `2/2` after matching
  the shared visible death-animation contract.
- `reports/report_2410/results.xml`: final related GREEN, five suites and `7/7`;
  zero errors, failures, flaky, skipped or orphaned tests. Coverage includes
  Story235, incoming Story234, Story124 direct APIs, Story125 visuals and
  Story126 gating/restore.
- Full-suite testing was intentionally not run.

## Smoke Evidence

`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.gd`
uses production `move_right`, the real vent overlap, exact `-8` HP/source,
no-input crossing protection and a 180-frame Story126 waiting hold. It exited
`0` and printed `story124_production_smoke=passed frames=180`. The tracked log
is
`reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.log`.

## MCP Runtime Evidence

Session `cinderpaw@198e`; accepted run `r200395661-39`, token `39`.

- Forced disk reload succeeded. Launch reported Godot `4.7-stable`, helper live
  and `current_run_errors=[]`.
- Ready state at x `16564` with no input remained available, inactive, idle and
  non-contacting. Existing safe/warning/active animations each reported four
  frames; Story126 was unavailable and hidden.
- Real MCP `input_action(move_right=true)` plus positive player displacement
  activated Story124 and entered grace with `Cross Tailrace Exit Spillway`.
- Production processing advanced warning, active and safe. Warning used
  layer/mask `0/0`; active used exact layer `16`, mask `12` and the active
  four-frame visual.
- Real Area2D/body physics overlap applied HP `100 -> 92`, damage `8`, type
  `steam`, exact Story124 source and Cinderpaw `hurt` animation.
- No-input placement at x `17044` remained uncrossed. Real positive-x movement
  from x `17034` crossed Story124, disabled contact and displayed
  `Tailrace Exit Spillway Crossed`.
- The crossing left Story126 available but inactive, hidden, untargeted,
  non-processing and non-physical. No-input x `17364` and held `move_right`
  without displacement both remained waiting.
- Final `move_left/move_right/jump/attack/interact` states were false. Current-
  run game log contained only helper registration; editor delta after cursor
  `2` was empty; playback stopped at readiness `ready`.

Two retained image-import rows shown at launch predated run `39`. They were
absent from `current_run_errors` and the post-baseline editor delta, so they are
not Story235 runtime errors.

## Visual Evidence

All captures are non-empty 8-bit RGB PNGs at `1278x718` from accepted run `39`.

- Ready, SHA-256
  `7b8846d430164528b0e7ead770de4ac1d52ddfd3b63f7796ff0116ecdb313144`:
  `reports/visual/cinderpaw-mcp-story235-tailrace-exit-spillway-ready-20260722.png`.
- Warning, SHA-256
  `b67dc137303ac988f56efe5ff7a022d3c116c07efcdfdc4e85ff0ca3a31a65d7`:
  `reports/visual/cinderpaw-mcp-story235-tailrace-exit-spillway-warning-20260722.png`.
- Active, SHA-256
  `491da4786e22129142d95aa9215d2ff727369b8745bf3d99d2daa91100808339`:
  `reports/visual/cinderpaw-mcp-story235-tailrace-exit-spillway-active-20260722.png`.
- Physical hit/hurt, SHA-256
  `528de6dd2427dc9cad15664f2f86693f1ac8c8d8a4baf2f49e7005946330d3f7`:
  `reports/visual/cinderpaw-mcp-story235-tailrace-exit-spillway-physical-hit-20260722.png`.
- Crossed/Leech waiting, SHA-256
  `c99db339712ba69615a2d683f3a7e51135d433e9d1f4e2c75fbe1c3781fdec23`:
  `reports/visual/cinderpaw-mcp-story235-tailrace-exit-spillway-crossed-leech-waiting-20260722.png`.

The frames show the dedicated Factory spillway, animated Cinderpaw, distinct
warning/active steam, readable hurt contact and a crossed route with no
premature Leech render. No placeholder rectangles, duplicate static vent or
incoherent z overlap are present.

## Asset Review

Story125 spillway art, Story033 four-frame steam, Cinderpaw's existing
`idle/run/hurt` frames and Story126 Sluice Leech frames fully cover the slice.
No image generation or import was needed; manifest reuse was updated. Technical
art review found the runtime z order readable: duct `12`, steam `19`, Leech
`20`, opened hatch `23`, Cinderpaw `26`.

## QA Result

Accepted. Story124 now closes as a real movement and physical-hazard beat and
hands Story126 forward in a deterministic waiting state without same-frame,
no-input or stationary held-input consumption.
