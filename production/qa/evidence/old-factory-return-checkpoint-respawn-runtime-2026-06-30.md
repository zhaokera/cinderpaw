# QA Evidence: Old Factory Return Checkpoint Respawn Runtime

> **Story**: Player Abilities Story 044  
> **Engine**: Godot `4.7.stable.official.5b4e0cb0f`  
> **Date**: 2026-06-30

## Scope

Story044 verifies that the Story043 Factory return checkpoint is not just a
selected respawn record. Non-boss death after checkpoint activation now requests
a real SceneManager runtime scene change to `area_03_factory / return_checkpoint`,
and the loaded Factory scene places Cinderpaw at `FactoryReturnCheckpoint`.
Factory-owned production death-signal wiring is intentionally left for a follow
up slice because the current architecture keeps `GameFlowController` under
`MainScene`.

No new visual assets were generated. This story reuses the Story043
image-generated checkpoint asset and existing Cinderpaw/Factory route assets.

## Automated Verification

Focused TDD:

```text
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/old_factory_return_checkpoint_test.gd \
  --ignoreHeadlessMode
```

- RED: `reports/old_factory_return_checkpoint_runtime_swap_red.log`,
  `reports/report_960/`
  - The new runtime-root swap test failed because `GameFlowController` used only
    logical `change_scene()`, `SceneManager.is_loading()` was false, and the
    runtime root still contained Main.
- GREEN: `reports/old_factory_return_checkpoint_respawn_runtime_green.log`,
  `reports/report_965/`
  - Passed `6/6`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
  - Includes the review-added Factory-current-scene respawn case: the current
    Factory runtime scene saves activated checkpoint, return-patrol, and
    service-lift local state before reloading Factory to `return_checkpoint`.

Related regression:

```text
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/story_004_savepoint_respawn_selection_test.gd \
  -a res://tests/unit/gameplay/factory_route_runtime_roundtrip_test.gd \
  -a res://tests/unit/gameplay/old_factory_service_lift_scene_manager_exit_test.gd \
  -a res://tests/unit/gameplay/player_respawn_visual_feedback_test.gd \
  --ignoreHeadlessMode
```

- `reports/old_factory_return_checkpoint_respawn_related.log`,
  `reports/report_964/`
  - Passed `10/10`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.

Project boot:

```text
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --quit
```

- `reports/old_factory_return_checkpoint_respawn_project_boot.log` exited `0`.
- Keyword scan found no script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors.
- The log still contains the project's known Godot cleanup-time
  ObjectDB/resource warnings at process exit.

## Godot MCP Runtime Evidence

MCP session: `cinderpaw@6787`, Godot `4.7-stable (official)`.

MCP launched:

```text
project_run(mode="custom", scene="res://scenes/factory_route_transition_shell.tscn", autosave=false)
```

Runtime tree and logs:

- `FactoryRouteTransitionShellScene` loaded as current runtime scene.
- Runtime tree contained `Player`, `Player/Sprite` as `AnimatedSprite2D`,
  `FactoryReturnCheckpoint`, `FactoryReturnCheckpoint/Visual`,
  `FactoryReturnCheckpoint/PromptLabel`, and existing Factory enemy
  `AnimatedSprite2D` nodes.
- Game log contained only the Godot AI helper registration line.
- Editor log was empty after clearing a temporary eval syntax-warning created by
  the probe setup.

Return-checkpoint landing probe result:

```text
changed=true
configured=true
current_scene=area_03_factory
current_spawn=return_checkpoint
player_position=(704, 380)
checkpoint_position=(704, 380)
distance=0.0
route_label="Returned to Factory Savepoint"
checkpoint_visible=true
checkpoint_available=true
checkpoint_activated=true
```

Screenshot:

- `reports/visual/cinderpaw-mcp-old-factory-return-checkpoint-respawn-runtime-20260630.png`
- Saved from the running game viewport, `1278x718`, PNG, non-empty.

## Verdict

PASS. The Factory return checkpoint now drives the full non-boss respawn landing
runtime path: death selects the checkpoint, SceneManager performs the runtime
scene swap, the loaded Factory scene applies `return_checkpoint`, and MCP 4.7
confirms Cinderpaw visible at the checkpoint with clean runtime logs.
