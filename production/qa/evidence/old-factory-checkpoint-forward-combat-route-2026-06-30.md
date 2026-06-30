# QA Evidence: Old Factory Checkpoint-Forward Combat Route

> **Story**: Player Abilities Story 046
> **Engine**: Godot `4.7.stable.official.5b4e0cb0f`
> **Date**: 2026-06-30

## Scope

Story046 adds a checkpoint-forward Spark Rat patrol to the existing Old Factory
route. After the return checkpoint is activated, the patrol blocks the service
lift until defeated, then persists the route as open.

No new visual assets were generated. The story reuses the existing
`FactorySparkRat` `AnimatedSprite2D + SpriteFrames` asset set.

## Automated Verification

Focused TDD:

```text
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/old_factory_checkpoint_forward_combat_route_test.gd \
  --ignoreHeadlessMode
```

- RED: `reports/report_976/`
  - Failed because the checkpoint-forward patrol diagnostics/API did not exist.
- GREEN: `reports/report_981/`
  - Passed `4/4`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.

Related regression:

```text
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/old_factory_checkpoint_forward_combat_route_test.gd \
  -a res://tests/unit/gameplay/old_factory_return_checkpoint_test.gd \
  -a res://tests/unit/gameplay/old_factory_return_patrol_ambush_test.gd \
  -a res://tests/unit/gameplay/old_factory_service_lift_scene_manager_exit_test.gd \
  -a res://tests/unit/gameplay/factory_route_runtime_roundtrip_test.gd \
  -a res://tests/unit/gameplay/player_respawn_visual_feedback_test.gd \
  -a res://tests/unit/gameplay/story_004_savepoint_respawn_selection_test.gd \
  --ignoreHeadlessMode
```

- `reports/report_984/`
  - Passed `24/24`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
  - The log retained the project's known Godot cleanup-time
    ObjectDB/resource warnings at process exit.

Project boot:

```text
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . \
  res://scenes/factory_route_transition_shell.tscn --quit
```

- `reports/old_factory_checkpoint_forward_combat_factory_scene_smoke.log`
  exited `0`.
- Keyword scan found no script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors. The only matching final line was
  the known Godot cleanup-time resource warning.

## Godot MCP Runtime Evidence

MCP session: `cinderpaw@6787`, Godot `4.7-stable (official)`, Godot AI MCP
`2.8.1`.

MCP launched:

```text
project_run(mode="custom", scene="res://scenes/factory_route_transition_shell.tscn", autosave=false)
```

Runtime tree:

- `FactoryRouteTransitionShellScene` loaded as current runtime scene.
- Runtime tree contained `FactoryCheckpointForwardSparkRat` as
  `CharacterBody2D`.
- The patrol contained `Sprite` as `AnimatedSprite2D`, `HealthComponent`,
  `CollisionComponent/Hurtbox`, `CombatComponent`, and `StatusEffectComponent`.

Checkpoint-forward probe result:

```text
checkpoint_activated=true
forward_activated=true
active_entity_id=2104
active_visible=true
active_has_target=true
active_physics=true
active_process=true
frames_idle=3
frames_run=3
frames_attack_tell=3
frames_attack=3
frames_hurt=3
frames_death=3
blocked_lift_try=false
locked_lift_prompt="Clear forward patrol"
locked_lift_reason="forward_patrol_active"
damage_applied=true
cleared_active=false
cleared_visible=false
cleared_defeated=true
route_id="checkpoint_forward_route_opened"
route_label="Deeper Factory Route Opened"
route_complete=true
opened_lift_available=true
opened_lift_prompt="Call lift"
```

Logs and screenshot:

- Game log after clearing contained only the Godot AI helper registration line.
- Editor log after clearing was empty.
- Running game screenshot returned PNG metadata `960x539` from the game
  framebuffer, confirming non-empty capture.

## Verdict

PASS. The checkpoint-forward Spark Rat patrol is a visible animated combat
gate, locks the service lift while active, opens the route on defeat, persists
local state, and passes focused, related, headless, and MCP 4.7 verification.
