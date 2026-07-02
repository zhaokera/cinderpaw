# Old Factory Lower Deck Breach Relay Activation Feedback Evidence

## Scope

- Story:
  `production/epics/player-abilities/story-063-old-factory-lower-deck-breach-relay-activation-feedback.md`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Runtime scripts:
  - `res://src/feature/savepoint_runtime.gd`
  - `res://src/gameplay/old_factory_entrance_scene.gd`
- Test file:
  `res://tests/unit/gameplay/old_factory_lower_deck_breach_relay_feedback_test.gd`

## Implementation Evidence

- `SavepointRuntime` now supports optional activation feedback through
  `activation_vfx_texture` and `activation_vfx_duration_sec`.
- `FactoryLowerDeckBreachRelaySavepoint` assigns the generated factory unlock
  spark texture:
  `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`.
- Fresh activation spawns one short-lived `Sprite2D` named `ActivationVfx`.
- Diagnostics expose texture path, active count, duration, elapsed time, played
  flag, spawn count, and last-spawn metadata.
- Last-spawn metadata records:
  - `asset_source="image_generation"`
  - `vfx_role="savepoint_activation"`
  - `savepoint_id="old_factory_lower_deck_breach_relay"`
  - the generated VFX texture path
- Duplicate activation returns `false` and leaves spawn count at `1`.
- Restored activated relay state does not replay the activation VFX.

## Asset Evidence

No new asset was generated. Story063 reuses the existing Story012
image-generated VFX:

- Runtime:
  `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
- Source:
  `assets/generated/source/factory_deep_route_unlock_spark_imagegen_20260626.png`
- Alpha source:
  `assets/generated/source/factory_deep_route_unlock_spark_alpha_20260626.png`
- Scene node:
  `FactoryLowerDeckBreachRelaySavepoint/ActivationVfx` at runtime.

The relay and VFX are environment/savepoint feedback, not character animation;
this story does not trigger the character `AnimatedSprite2D + SpriteFrames`
rule.

## Automated Verification

- RED focused:
  `reports/report_1073/` failed `3` Story063 tests before
  `SavepointRuntime` exposed activation VFX texture/snapshot APIs.
- Fresh focused GREEN:
  `reports/report_1076/` passed `3/3` with `0` errors, failures, skipped,
  flaky, and orphans.
- Fresh related GREEN:
  `reports/report_1077/` passed `17/17` across relay activation feedback,
  breach relay savepoint, deep-route unlock feedback, and return-checkpoint
  suites with `0` errors, failures, skipped, flaky, and orphans.
- MCP Debugger stale-row cleanup:
  `reports/report_1079/` passed Story015 dodge-counter readability `5/5` after
  removing global-class type annotations that the editor Debugger had retained
  as stale `CombatComponent` parse rows. The runtime story probe and game log
  remained clean.
- Headless smoke:
  `reports/old_factory_lower_deck_breach_relay_feedback_smoke.log` exited `0`;
  script/parse/invalid-call/access/missing-resource/resource-load keyword scan
  returned no project errors. The log contains only known Godot cleanup-time
  ObjectDB/resource messages.

## MCP Runtime Verification

- Godot version: `4.7.stable.official.5b4e0cb0f`.
- Godot AI MCP: plugin/server `2.8.3`, session `cinderpaw@b83b`.
- MCP launch:
  `project_run(mode="custom", scene="res://scenes/factory_route_transition_shell.tscn", autosave=false)`
  returned helper live with no recent errors.
- Runtime probe:
  - Relay present and visible after secured breach: `true`
  - Activation feedback texture:
    `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
  - Activation result: `true`
  - Duplicate activation result: `false`
  - VFX active count after activation: `1`
  - VFX spawn count after activation: `1`
  - VFX played flag after activation: `true`
  - Last-spawn metadata: `asset_source=image_generation`,
    `vfx_role=savepoint_activation`,
    `savepoint_id=old_factory_lower_deck_breach_relay`
  - VFX active count after deterministic expiry: `0`
  - Route label after activation: `Lower Deck Relay Secured`
  - Savepoint id: `old_factory_lower_deck_breach_relay`
  - Scene id: `area_03_factory`
  - Spawn point: `lower_deck_breach_relay`
  - Service lift prompt: `Call lift`
- Runtime logs:
  Game logs contained only the MCP helper registration line after the probe.
  The editor Debugger still displayed pre-existing stale Story015
  `CombatComponent` rows with old line mappings; the current Story015 test
  passed `5/5` in `reports/report_1079/`, and `src/core/combat_component.gd`
  passed Godot `--check-only`.
- MCP screenshot:
  `editor_screenshot(source="game")` captured a non-empty game framebuffer
  during the relay feedback runtime probe. The capture was available inline
  from MCP; no local screenshot artifact is committed for this run.

## Result

PASS. Story063 adds visible one-shot repair feedback to the lower-deck breach
relay while preserving the Story062 savepoint/respawn contract and reusing an
existing image-generated Factory VFX asset.
