# QA Evidence: Old Factory Runtime Death Integration

> **Story**: Player Abilities Story 045  
> **Engine**: Godot `4.7.stable.official.5b4e0cb0f`  
> **Date**: 2026-06-30

## Scope

Story045 verifies that Old Factory production runtime owns player death wiring:
the Factory scene connects `Player.player_died` into a local
`GameFlowController`, selects the activated return checkpoint, and revives
Cinderpaw at that checkpoint after the normal death delay.

No new visual assets were generated. The story reuses existing Cinderpaw,
Factory enemy, Factory route, and Story043 image-generated checkpoint assets.

## Automated Verification

Focused TDD:

```text
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/old_factory_return_checkpoint_test.gd \
  --ignoreHeadlessMode
```

- RED: `reports/old_factory_runtime_death_integration_red.log`,
  `reports/report_968/`
  - The new production wiring test failed because
    `OldFactoryEntranceScene.advance_factory_respawn_flow()` did not exist and
    the Factory scene did not yet own a runtime respawn flow.
- GREEN: `reports/old_factory_runtime_death_integration_green.log`,
  `reports/report_974/`
  - Passed `7/7`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
  - Covered both the existing `change_scene()` fallback fake and the production
    `request_scene_change()` path used by the Factory-owned flow.

Related regression:

```text
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/old_factory_return_checkpoint_test.gd \
  -a res://tests/unit/gameplay/story_004_savepoint_respawn_selection_test.gd \
  -a res://tests/unit/gameplay/player_respawn_visual_feedback_test.gd \
  -a res://tests/unit/gameplay/factory_route_runtime_roundtrip_test.gd \
  -a res://tests/unit/gameplay/old_factory_service_lift_scene_manager_exit_test.gd \
  --ignoreHeadlessMode
```

- `reports/old_factory_runtime_death_integration_related.log`,
  `reports/report_975/`
  - Passed `17/17`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.

Factory scene smoke:

```text
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . \
  --scene res://scenes/factory_route_transition_shell.tscn \
  --fixed-fps 60 --quit-after 180 \
  --log-file reports/old_factory_runtime_death_integration_factory_scene_smoke.log
```

- Exit code `0`.
- Keyword scan across focused, related, and smoke logs found no script, parse,
  invalid-call, invalid-access, missing-resource, or resource-load errors.
- The stdout copy contains only the known Godot cleanup-time
  ObjectDB/resource warnings at process exit.

## Godot MCP Runtime Evidence

MCP session: `cinderpaw@6787`, Godot `4.7-stable (official)`.

MCP launched:

```text
project_run(mode="custom", scene="res://scenes/factory_route_transition_shell.tscn", autosave=false)
```

Runtime tree:

- `FactoryRouteTransitionShellScene` loaded as the running scene.
- Runtime tree contained `Player`, `Player/Sprite` as `AnimatedSprite2D`,
  `FactoryReturnCheckpoint`, Factory enemy `AnimatedSprite2D` nodes, and the
  dynamically created `FactoryGameFlowController`.

Runtime death probe:

```text
checkpoint_activated=true
flow.present=true
flow.state=revived
flow.control_locked=true
flow.invincibility_remaining=2.0
flow.last_selected_respawn_point.scene_id=area_03_factory
flow.last_selected_respawn_point.spawn_point=return_checkpoint
player_hp=50
player_max_hp=100
respawn_visual_active=true
player_position=(704, 380)
checkpoint_position=(704, 380)
distance_to_checkpoint=0.0
route_label_text="Returned to Factory Savepoint"
```

Logs and screenshot:

- Game log contained only the Godot AI helper registration line.
- Editor log was empty after clearing pre-probe entries.
- MCP game screenshot returned PNG metadata `960x539`, confirming a non-empty
  running game framebuffer.

## Verdict

PASS. The Old Factory scene now owns production death-signal integration:
player death enters the Factory `GameFlowController`, selects the active return
checkpoint, revives Cinderpaw at the checkpoint with 50% HP and revive visual
feedback, and remains green under focused, related, headless, and MCP 4.7
verification.
