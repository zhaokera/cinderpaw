# QA Evidence: Old Factory Service Sluice Tailrace Relay Runoff Pincer Reward Cache Production Input Exit Hatch Handoff

**Story**: Player Abilities Story233

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify stale/no-input protection, one fresh production Story122 reward claim,
exact reward feedback and a visible, blocking, unopened Story123 handoff.
Opening Story123 and activating Story124 are excluded.

## TDD Evidence

- `reports/report_2396/results.xml`: canonical RED, one test and exactly one
  expected missing-router failure at the fresh claim assertion.
- `reports/report_2397/results.xml`: focused GREEN `1/1`.
- `reports/report_2398/results.xml`: final related GREEN, five suites and
  `7/7`; zero failures, errors, flaky, skipped or orphaned tests. Coverage
  includes Story233, Story232, the Story226 router analogue and Story122/123.
- Full-suite testing was intentionally not run.

## Smoke Evidence

`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke.gd`
uses production `Input.interact`, holds the claim edge in Story123 range,
checks Story124 remains locked and runs 180 frames. It exited `0` and printed
`story233_production_smoke=passed frames=180`; the captured log contains no
runtime errors.

## MCP Runtime Evidence

Session `cinderpaw@198e`; accepted run `r196920539-37`, token `37`.

- Session metadata reported Godot `4.7-stable`, plugin `3.0.4` and server
  `3.0.4`. Forced disk reload succeeded and launch reported
  `current_run_errors=[]`.
- `interact` was pressed while Story122 was locked, then Story232's terminal
  state was restored while it remained held. Story122 became visible,
  available and claimable at `(15460,410)` but remained unclaimed with empty
  reward and feedback.
- Releasing/rearming and remaining in range without input still left the cache
  unclaimed. One fresh MCP `input_action(interact=true)` then routed through
  production input and claimed it exactly once.
- Runtime diagnostics recorded the full cache id/source, exact `20` gears and
  `Tailrace Runoff Pincer Cache Claimed +20 Gears` feedback/route label.
- While that same input edge remained held, Cinderpaw was moved into Story123
  range. The hatch stayed visible, available, monitoring, monitorable,
  blocking and unopened with prompt `Open Tailrace Exit` and VFX spawn count
  `0`.
- Story124 remained hidden, unavailable, inactive and non-contacting. Local
  state recorded Story122 claimed and Story123 unopened.
- Final `move_left/move_right/attack/interact/dodge` states were false. The
  current game log contained only helper registration; editor delta after
  cursor `2` was empty; playback stopped at readiness `ready`.

## Runtime Hygiene

An initial diagnostic run was rejected after a temporary MCP
`game_eval` loop used mixed indentation and parked only the transient eval in
a parser break. Playback was stopped, the debug buffer was cleared and no
project file was changed by that eval. Accepted run `37` used indentation-free
evals and stayed live through screenshots and final log inspection.

Two retained image-import rows shown at launch predated accepted run `37`.
They were absent from `current_run_errors` and from the editor delta after the
run baseline, so they are not Story233 runtime errors.

## Visual Evidence

- Cache available: non-empty RGB `1278x718`, SHA-256
  `9792ce1a29075028ddaeab505d490800f5d80c5c2b800d900c5240b2dd96a4a0`,
  `reports/visual/cinderpaw-mcp-story233-pincer-cache-available-20260722.png`.
- Cache claimed / hatch waiting: non-empty RGB `1278x718`, SHA-256
  `900e9ef385c2988a0de693627134dbd3a5c13c9ebae713d1affac74923e71031`,
  `reports/visual/cinderpaw-mcp-story233-cache-claimed-exit-hatch-waiting-20260722.png`.

The captures show authored Factory art, animated Cinderpaw, the reward prompt
and the closed hatch. Cinderpaw remains visible beside the z `27` hatch; no
unlock spark, spillway or placeholder rectangle appears.

## Asset Review

Existing imported image-generated Factory, Cinderpaw, cache and hatch assets
fully cover the slice. No image generation or asset-manifest change was
required.

## QA Result

Accepted. Story122 now claims through the real production input path and hands
Story123 a visible closed state without stale, same-edge or held-input
consumption.
