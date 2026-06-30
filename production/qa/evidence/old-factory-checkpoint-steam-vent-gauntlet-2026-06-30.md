# QA Evidence: Old Factory Checkpoint Steam Vent Gauntlet

> **Story**: Player Abilities Story 047
> **Engine**: Godot `4.7.stable.official.5b4e0cb0f`
> **Date**: 2026-06-30

## Scope

Story047 adds a checkpoint-adjacent steam vent hazard to the existing Old
Factory route. The vent activates only after the checkpoint-forward Spark Rat
patrol is defeated, then becomes a visible contact-damage gauntlet on the
opened route.

No new visual assets were generated. The story reuses the existing
image-generated Old Factory steam vent texture.

## Automated Verification

- Focused RED: `reports/report_985/`
  - Failed because `FactoryCheckpointSteamVentHazard` did not exist yet.
- Focused GREEN: `reports/report_991/`
  - Passed `3/3`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
- Related regression: `reports/report_1002/`
  - Passed `21/21`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
- Validation cleanup regression: `reports/report_1005/`
  - Passed `40/40` across Story047 focused tests,
    `tests/unit/presentation/combat_presentation_test.gd`, and
    `tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd`.
  - This verifies the runtime-load cleanup for optional generated combat VFX
    textures and Rat King component scripts. Stdout retained only the known
    cleanup-time ObjectDB/resource messages.
- Project boot:
  - `reports/old_factory_checkpoint_steam_vent_gauntlet_smoke.log` exited `0`.
  - Keyword scan found no `ERROR`, `SCRIPT ERROR`, `Parse Error`, `FATAL`, or
    `WARNING` entries in the log file.
  - The command-line console still printed the project's known cleanup-time
    ObjectDB/resource messages after process exit.

## Godot MCP Runtime Evidence

MCP session used Godot `4.7-stable (official)`.

Runtime tree and default-state probe:

- Runtime tree contained
  `/FactoryRouteTransitionShellScene/FactoryCheckpointSteamVentHazard` as
  `Area2D`.
- The checkpoint vent was in group `factory_hazard`.
- Default properties:
  - `hazard_id="old_factory_checkpoint_steam_vent"`
  - `damage=8`
  - `contact_cooldown_sec=1.0`
  - `visible=false`
  - `monitoring=false`
  - `collision_layer=0`
  - `collision_mask=0`
- Child `Visual` was `Sprite2D` using
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Runtime player node `/FactoryRouteTransitionShellScene/Player/Sprite` was
  `AnimatedSprite2D` using
  `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`.

Activation probe:

- MCP called runtime `set_local_state()` with
  `factory_checkpoint_forward_patrol_defeated=true` and
  `factory_return_checkpoint_activated=true`.
- After state sync:
  - `visible=true`
  - `monitoring=true`
  - `collision_layer=16`
  - `collision_mask=12`
  - child `CollisionShape2D.disabled=false`

Screenshot:

- MCP game screenshot returned PNG metadata `640x359`, original framebuffer
  `1278x718`, confirming non-empty runtime capture.

MCP caveat:

- `project_run` returned retained editor parse-error rows marked
  `recent_errors_may_predate_run=true`. The running game instance was live,
  runtime node inspection succeeded, Godot-side file reads showed the current
  script and scene content, and Godot 4.7 CLI/GdUnit compiled and executed the
  same scene/tests successfully. The retained rows appear to be stale editor
  cache entries rather than current runtime failures.

## Verdict

PASS. The checkpoint steam vent gauntlet is scene-authored, hidden until the
checkpoint-forward patrol is defeated, activates with visible art and collision,
damages Cinderpaw with cooldown, preserves checkpoint respawn semantics, and
passes focused, related, headless, and MCP 4.7 runtime verification.
