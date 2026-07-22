# QA Evidence: Old Factory Service Sluice Tailrace Relay Runoff Pincer Production Combat Reward Cache Handoff

**Story**: Player Abilities Story232

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify real movement activation, physical dual-enemy combat, sequential live
death cleanup, render order and an unclaimed Story122 cache handoff protected
from held pre-clear interaction. Fresh cache claim routing is excluded.

## TDD Evidence

- `reports/report_2390/results.xml`: canonical visual RED, one case and two
  expected enemy/cache z-order failures.
- `reports/report_2391/results.xml`: initial focused GREEN, `1/1`.
- `reports/report_2393/results.xml`: MCP-discovered regression RED reproducing
  the invalid typed reference after Spark Rat had freed and Coil Rat died.
- `reports/report_2394/results.xml`: fixed focused GREEN, `1/1`.
- `reports/report_2395/results.xml`: final related GREEN, five suites and
  `7/7`; zero errors, failures, flaky, skipped or orphaned tests.
- The related set covered Story232, Story231, Story225 and Story121/122. Full
  suite was intentionally not run.

## Smoke Evidence

`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_smoke.gd`
uses real movement and attack input, validates exact shared-hit metadata,
observes `death` frames `0/1/2` for both enemies, holds stale interaction
through the clear and runs 180 frames. It exited `0` and printed
`story121_production_smoke=passed frames=180`.

## MCP Runtime Evidence

Session `cinderpaw@198e`; accepted run `r194847761-35`, token `35`.

- Session metadata reported Godot `4.7-stable`, plugin `3.0.4` and server
  `3.0.4`. Forced disk reload succeeded and run start reported
  `current_run_errors=[]`.
- Real `move_right` activated Story121. Runtime diagnostics confirmed Spark
  Rat/Coil Rat HP `24`, six required animations at three frames each and z
  order cache `22` < enemies `24` < Cinderpaw `26`.
- Two real right-facing light attacks changed Spark Rat `24 -> 12 -> 0`; exact
  metadata recorded attacker `1`, target `2144`, weapon `cat_claw`, hitbox
  `cat_claw_light`, damage `12` and applied true.
- After Spark Rat's death animation completed, its node was confirmed absent.
  Two real left-facing light attacks then changed Coil Rat `24 -> 12 -> 0`
  with the same metadata contract and target `2145`; the prior MCP runtime
  typed-reference break did not recur.
- Coil Rat was observed visible in `death` frame `0` with target/physics
  disabled while the cache became visible, available and claimable. The
  180-frame smoke provides deterministic frames `0/1/2` coverage.
- `interact` was held before the final lethal hit and through cache reveal.
  The cache stayed unclaimed with prompt `+20 Gears`, empty reward/feedback
  and Cinderpaw in reward range. After death cleanup it remained available,
  visible, claimable and unclaimed.
- Current game log contained only helper registration. Editor delta after
  baseline cursor `2` was empty; all driven inputs were released and playback
  stopped with readiness `ready`. Retained image-import errors reported at run
  start were marked as predating the accepted run and did not appear in
  current-run or editor-delta logs.

## Runtime Defect Closed

MCP run token `34` exposed a production-only failure: after Spark Rat freed,
Coil Rat's lethal hit passed the stale Spark Rat Object into
`_sync_lower_deck_forward_pressure_coil_pincer_enemy_state(enemy: Node2D)`.
The helper now accepts `Variant`, resolves `_get_valid_node2d`, and returns
before touching invalid objects. `report_2393` reproduces the failure and
`report_2394/2395` verify the fix.

## Visual Evidence

- Active pincer: non-empty RGB `1278x718`, SHA-256
  `6ef2dffa7d585679cc7172f0ec803d55313b44ced95812356a0a9192d4739e42`,
  `reports/visual/cinderpaw-mcp-story232-tailrace-runoff-pincer-active-20260722.png`.
- Coil death/cache reveal: non-empty RGB `1278x718`, SHA-256
  `56ef02064f77c748f614de58045b98c14869204c13f270e23b489e82ac7755c0`,
  `reports/visual/cinderpaw-mcp-story232-tailrace-runoff-pincer-coil-death-cache-handoff-20260722.png`.
- Unclaimed cache handoff: non-empty RGB `1278x718`, SHA-256
  `5e8f9e7dfad93e283604b940a57409e098e765479f4dd43b772bb9d9526b3e83`,
  `reports/visual/cinderpaw-mcp-story232-tailrace-runoff-pincer-cache-unclaimed-20260722.png`.

The captures show authored Factory art, animated Cinderpaw and enemy sprites,
the death impact, reward prompt and cache. No placeholder blocks are present.

## Asset Review

Existing imported image-generated Factory, Cinderpaw, Spark Rat, Coil Rat and
cache assets fully cover the slice. No image generation or asset-manifest
change was required.

## QA Result

Accepted. Story121 now closes through production movement and shared physical
combat, survives sequential enemy despawn timing, and hands Story122 an
available but deliberately unclaimed cache.
