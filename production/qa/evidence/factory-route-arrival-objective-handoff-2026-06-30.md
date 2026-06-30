# Factory Route Arrival Objective Handoff Evidence

Date: 2026-06-30
Story: `production/epics/player-abilities/story-034-factory-route-arrival-objective-handoff.md`

## Summary

Story034 adds a scene-local Factory Route objective chain to
`OldFactoryEntranceScene`. The target scene now shows `Clear Factory Entrance`
on arrival, advances through the existing entrance guard, deep guard, endpoint,
and Factory Spark Rat states, then reports `factory_route_cleared` with visible
`Factory Route Cleared` feedback.

No new visual assets were generated. This slice reuses existing image-generated
Old Factory environment, endpoint, VFX, and Factory Spark Rat
`AnimatedSprite2D + SpriteFrames` assets.

## Automated Evidence

- RED focused: `reports/report_883/` failed as expected because
  `get_factory_route_objective_diagnostics()` and
  `is_factory_route_objective_complete()` did not exist.
- GREEN focused: `reports/report_884/` passed `2/2`.
- Related regression: `reports/report_885/` passed `21/21` across Story034,
  Old Factory entrance combat, deep route micro-slice, deep route unlock
  feedback, Spark Rat pacing polish, and Boss2 victory route handoff.
- Headless Factory scene smoke:
  `reports/old_factory_route_objective_handoff_factory_scene_smoke.log` exited
  `0`; keyword scan found no script, parse, invalid-call, missing-resource, or
  resource-load errors. Godot reported only cleanup-time `resources still in use
  at exit`.

## MCP Runtime Evidence

MCP session: `cinderpaw@f8f3`
Godot: `4.6.3-stable`
Godot AI plugin/server: `2.8.1 / 2.8.1`
Scene: `res://scenes/factory_route_transition_shell.tscn`

Runtime probe confirmed:

- Initial objective: `clear_factory_entrance` / `Clear Factory Entrance`.
- After `FactoryRatMinion` defeat: `reach_deep_guard` / `Reach Deep Guard`.
- After `FactoryDeepGuardRatMinion` defeat:
  `open_deep_route_endpoint` / `Open Deep Route Endpoint`.
- After endpoint activation:
  `defeat_spark_rat_patrol` / `Defeat Spark Rat Patrol`.
- After Factory Spark Rat defeat:
  `factory_route_cleared` / `Factory Route Cleared`.
- `is_factory_route_objective_complete() == true`.
- `get_local_state().factory_route_objective_id == "factory_route_cleared"`.
- Player `AnimatedSprite2D + SpriteFrames`: `idle/run/jump` all have 3 frames.
- Factory Spark Rat `AnimatedSprite2D + SpriteFrames`:
  `idle/run/attack_tell/attack/hurt/death` all have 3 frames.
- Final game logs contained only the MCP helper registration line after cleanup.
- Editor logs were empty.
- Screenshot saved:
  `reports/visual/cinderpaw-mcp-old-factory-route-objective-handoff-20260630.png`.

## Acceptance Mapping

| Criterion | Evidence | Result |
|---|---|---|
| Arrival objective visible | Story034 focused test + MCP initial diagnostics | Covered |
| Entrance clear objective handoff | Story034 focused test + MCP progression | Covered |
| Deep guard and endpoint objective handoff | Story034 focused test + MCP progression | Covered |
| Spark Rat defeat completes route objective | Story034 focused test + MCP final diagnostics | Covered |
| Scene-local restore | Story034 restore test | Covered |
| Existing Old Factory/Story033 behavior preserved | Related regression `reports/report_885/` | Covered |
| MCP scene/log/screenshot/animation validation | MCP runtime evidence above | Covered |

## Notes

ADR-0018 is still marked `Proposed` in the architecture folder even though this
epic has long used it as governing implementation guidance. This is a project
documentation consistency issue, not a Story034 runtime blocker.
