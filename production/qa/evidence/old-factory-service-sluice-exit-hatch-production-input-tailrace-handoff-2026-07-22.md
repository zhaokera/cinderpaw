# QA Evidence: Old Factory Service Sluice Exit Hatch Production Input Tailrace Handoff

**Story**: Player Abilities Story227

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story116 stale/no-input protection, one fresh production Hatch open,
readable retraction, once-only feedback, and a visible but inactive Story117
handoff. Story117 real activation and traversal are intentionally excluded.

## TDD Evidence

- `reports/report_2368/report_1/results.xml`: canonical RED, `1` test, zero
  errors and six expected assertions for the router, door pose/z and tailrace
  movement guard.
- `reports/report_2369/report_1/results.xml`: focused GREEN `1/1`.
- `reports/report_2370/report_1/results.xml`: initial six-suite related GREEN
  `9/9`.
- `reports/report_2371/report_1/results.xml`: final six-suite related GREEN
  `9/9` after enforcing GDD world-prompt hiding; zero
  failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

## Smoke Evidence

`reports/old_factory_service_sluice_exit_hatch_production_input_tailrace_handoff_smoke.log`
completed `180` fixed-FPS Factory frames, exited `0`, and ends with
`story227_smoke=passed frames=180`.

## MCP Runtime Evidence

Session `cinderpaw@198e`; accepted run `r182022878-24`, token `24`.

- Editor/plugin/server reported Godot `4.7-stable` and MCP `3.0.4`.
- Initial diagnostics showed Story116 visible/available/blocking at
  `(11680,392)` with `Open Service Exit`, zero VFX, and Story117 hidden.
- A real MCP `input_action(interact=true)` routed through Factory production
  `_process()` and opened Story116 once.
- Opened diagnostics showed collision and interaction monitoring disabled,
  diagnostic text `Service Exit Open`, hidden world prompt, route label
  `Service Sluice Exit Opened`, and unlock VFX spawn count `1`.
- Door Visual was local `(48,-136)`, rotation `6deg`, effective z `23`, below
  Cinderpaw z `26` and above the tailrace environment.
- Story117 became visible/available but stayed inactive, uncrossed and
  non-contact. No-input placement at x `12024` remained inactive.
- Final `move_left/move_right/attack/interact/dodge` state was false.
- Current-run game log contained only game-helper registration; editor logger
  delta after baseline cursor `2` was empty. Playback stopped at readiness
  `ready`.

## Visual Evidence

The non-empty RGB `1278x718` MCP game framebuffer showed Cinderpaw unobscured
below the retracted Hatch, the world prompt hidden, the route label visible,
and the existing tailrace duct/steam machinery readable in the same frame.

## Asset Review

Existing imported image-generated Hatch, VFX, Factory, Cinderpaw, tailrace duct
and four-frame steam assets fully cover this slice. No new image generation or
animation resource was needed.

## QA Result

Accepted. Story116 now consumes only a fresh production input edge, retracts
without covering Cinderpaw, and hands control to a visible Story117 that waits
for actual positive-x `move_right` traversal.
