# QA Evidence: Old Factory Service Sluice Reward Cache Production Input Exit Hatch Handoff

**Story**: Player Abilities Story226

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story115 stale/no-input protection, one fresh production reward claim,
exact reward feedback and a visible, blocking, unopened Story116 handoff. The
Hatch opening and Story117 activation are intentionally excluded.

## TDD Evidence

- `reports/report_2364/results.xml`: canonical RED, `1` test, zero errors and
  exactly one expected missing-router failure.
- `reports/report_2365/results.xml`: initial focused GREEN `1/1`.
- `reports/report_2366/results.xml`: six related suites, `9/9`, zero
  failure/error/flaky/skip/orphan. Coverage includes Story225, the Story223
  production-reward analogue, Story115/116 baselines and shared interaction.
- `reports/report_2367/results.xml`: strengthened final focused `1/1`, including
  four held Hatch frames and locked Story117 assertions.
- Full suite was intentionally not run.

## Smoke Evidence

`reports/old_factory_service_sluice_reward_cache_production_input_exit_hatch_handoff_smoke.log`
completed `180` fixed-FPS Factory frames, exited `0`, and ends with
`story226_smoke=passed frames=180`.

## MCP Runtime Evidence

Session `cinderpaw@198e`; accepted run `r179796549-23`, token `23`.

- Editor/plugin/server reported Godot `4.7-stable` and MCP `3.0.4`.
- Initial diagnostics showed Story115 visible/available/claimable/unclaimed at
  `(11360,410)`, prompt `+20 Gears`, with empty reward/feedback; Story116 was
  hidden, unavailable and unopened.
- A real MCP `input_action(interact=true)` routed through Factory production
  `_process()` and produced exact cache id/source, `20` gears and
  `Service Sluice Cache Claimed +20 Gears`.
- Story116 became visible/available/monitoring/monitorable/blocking at
  `(11680,392)` with `Open Service Exit`, remained unopened with zero unlock
  VFX, and stayed unopened through four held frames in range.
- Story117 remained unavailable, inactive and hidden in the automated test.
- Final `move_left/move_right/attack/interact/dodge` state was false.
- Current-run game log contained only game-helper registration; editor logger
  delta after baseline cursor `2` was empty. Playback stopped at readiness
  `ready`.

## Visual Evidence

Non-empty RGB `1278x718` MCP game framebuffer responses showed:

- Cinderpaw beside the authored claimable cache with `+20 Gears` and objective
  `Service Sluice Spark Rat Cleared`.
- Cinderpaw beside the authored closed service-exit Hatch with prompt
  `Open Service Exit` and immediate claim feedback in the route objective.

No placeholder rectangle or single-frame character substitute was introduced.

## Runtime Hygiene

The first MCP launch surfaced two retained editor rows for a previously saved
Story213 QA PNG. Its pixels were intact but Godot rejected that encoding. The
file was losslessly re-encoded, Godot 4.7 CLI import and MCP filesystem scan
then succeeded at `reports/visual/cinderpaw-mcp-story213-cooling-duct-20260722.png`,
and its documentation SHA was updated to
`29100d2cf2141f213aab1df0073cbfcb2c228214016f9aa6a9ca9bfb35d9770b`.
Those retained UI rows predated accepted run 23; `current_run_errors` was empty
and no editor logger rows appeared after cursor `2`.

## Asset Review

Existing imported image-generated cache, Hatch, Cinderpaw and Factory assets
fully cover this slice. No new image generation or animation resource was
needed. The next Hatch-opening slice should add a visible retraction transform
and keep its door visual below Cinderpaw.

## QA Result

Accepted. Story115 is now claimable through actual production input, grants the
exact one-shot reward ledger, and hands off to a visible closed Story116
without stale, same-edge or held-input consumption.
