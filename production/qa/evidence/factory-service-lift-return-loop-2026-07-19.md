# Factory Service-Lift Return Loop Evidence

## Scope

- Story: `production/epics/scene-management/story-025-factory-service-lift-return-loop.md`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Runtime script: `res://src/gameplay/old_factory_entrance_scene.gd`
- Engine: Godot 4.7 stable
- Godot AI MCP: 3.0.2

## Automated Evidence

| Gate | Result | Evidence |
|------|--------|----------|
| Initial Story RED | Expected failure `2/2` | `reports/report_2018/report_1/results.xml`: return-loop production input absent |
| Initial focused GREEN | Pass `2/2` | `reports/report_2019/report_1/results.xml` |
| Related contract isolation | Expected failures `9` | `reports/report_2020/report_1/results.xml`: stale objective and diagnostic assumptions |
| Real serialized-state RED | Expected failures `9` | `reports/report_2021/report_1/results.xml`: explicit false latch suppressed Return Patrol |
| Headless contact scheduling probe | State fix passed; fixture contact failed | `reports/report_2022/report_1/results.xml` |
| Final focused GREEN | Pass `2/2` | `reports/report_2023/report_1/results.xml` |
| Final related regression | Pass `27/27` | `reports/report_2024/report_1/results.xml` |

The final related run covered the Story025 real-input loop, Story024 service
lift handoff, Return Patrol persistence, return reward cache, contact checkpoint
and checkpoint-forward patrol. It reported zero errors, failures, flaky cases,
skips or orphan nodes. No full suite was run.

The focused headless test emits the checkpoint's production
`InteractionArea.body_entered` signal directly because a teleported physics body
does not deterministically generate a fresh overlap in the headless fixture.
The final MCP run separately verifies real movement contact in the live engine.

## MCP Runtime Acceptance

Final run `r349643989-115` launched
`res://scenes/factory_route_transition_shell.tscn` through Godot MCP.

Reentry and combat probe:

- The seeded state matched the real service-lift snapshot, including
  `factory_return_patrol_activated=false`, unresolved patrol defeat and the
  `main/scrap_roost` exit contract.
- Restore selected objective `clear_return_patrol` and spawned entity `2103`
  with target, physics, combat collision and six three-frame animations.
- MCP used the production `attack` action for the defeating hit. The patrol
  node was removed, the reward cache became available and the repair station
  became visible.

Reward and checkpoint probe:

- MCP moved the Player to the cache and pressed the production `interact`
  action. The cache recorded one reward payload with exactly `15` Gears and the
  service lift recorded no exit request.
- MCP moved left into the repair station. Its production `Area2D` contact
  activated `old_factory_return_checkpoint` for
  `area_03_factory/return_checkpoint` and selected
  `advance_from_return_checkpoint`.
- MCP then held `move_right`; crossing `x=900` automatically activated entity
  `2104`. Forward Patrol was visible, targeted the Player, processed physics
  and exposed at least three frames for every authored animation.

Presentation and log gate:

- The `1278x718` game framebuffer was non-empty and showed the generated
  Factory environment, Player, repaired station and active Forward Patrol.
- Game log contained one MCP helper registration info line and no warning or
  error. Editor log contained zero entries.
- MCP stopped the project cleanly after acceptance.

## Asset Decision

No new visual asset was generated. The slice reuses the existing
image-generated service lift, return cache, repair station and Factory
environment plus the existing Player and Spark Rat
`AnimatedSprite2D + SpriteFrames` assets.
