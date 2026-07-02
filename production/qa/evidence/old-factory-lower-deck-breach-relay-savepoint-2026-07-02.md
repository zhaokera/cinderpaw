# Old Factory Lower Deck Breach Relay Savepoint Evidence

## Scope

- Story:
  `production/epics/player-abilities/story-062-old-factory-lower-deck-breach-relay-savepoint.md`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Runtime script: `res://src/gameplay/old_factory_entrance_scene.gd`
- Test file:
  `res://tests/unit/gameplay/old_factory_lower_deck_breach_reward_route_test.gd`

## Implementation Evidence

- Added `FactoryLowerDeckBreachRelaySavepoint` using `SavepointRuntime`.
- Savepoint contract:
  `old_factory_lower_deck_breach_relay / area_03_factory /
  lower_deck_breach_relay`.
- Gate condition:
  `factory_lower_deck_breach_corridor_secured=true`.
- Activation flag:
  `factory_lower_deck_breach_relay_activated=true`.
- Route feedback:
  `Lower Deck Relay Secured` on activation and
  `Returned to Lower Deck Relay` after non-boss respawn.
- `FactoryServiceLift` remains optional with prompt `Call lift`.

## Asset Evidence

- Source:
  `assets/generated/source/old_factory_lower_deck_breach_relay_imagegen_20260702.png`
- Alpha source:
  `assets/generated/source/old_factory_lower_deck_breach_relay_alpha_20260702.png`
- Metadata:
  `assets/generated/source/old_factory_lower_deck_breach_relay_imagegen_20260702.json`
- Runtime:
  `assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`
- Runtime dimensions: `256x256`.
- Scene node:
  `FactoryLowerDeckBreachRelaySavepoint/Visual`.
- Runtime texture path confirmed by MCP:
  `res://assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`.

The relay is an environment savepoint prop, not a character; it does not trigger
the character `AnimatedSprite2D + SpriteFrames` frame-animation requirement.

## Automated Verification

- RED focused:
  `reports/report_1067/` failed `2/2` before Story062 diagnostics and relay
  activation behavior existed.
- Fresh focused GREEN:
  `reports/report_1071/` passed `2/2` with `0` errors, failures, skipped,
  flaky, and orphans.
- Fresh related GREEN:
  `reports/report_1072/` passed `15/15` across lower-deck deep bulkhead,
  breach corridor, breach relay, return checkpoint, and service-lift
  SceneManager exit suites with `0` errors, failures, skipped, flaky, and
  orphans.
- Headless smoke:
  `reports/old_factory_lower_deck_breach_relay_savepoint_smoke.log` exited
  `0`; script/parse/invalid-call/access/missing-resource/resource-load keyword
  scan returned no project errors. The log contains only known Godot
  cleanup-time ObjectDB/resource messages.

## MCP Runtime Verification

- Godot version: `4.7.stable.official.5b4e0cb0f`.
- Godot AI MCP: plugin/server `2.8.3`, session `cinderpaw@b83b`.
- MCP launch:
  `project_run(mode="custom", scene="res://scenes/factory_route_transition_shell.tscn", autosave=false)`
  returned helper live with no recent errors.
- Runtime probe:
  - Relay present: `true`
  - Relay visible after secured breach: `true`
  - Visual type: `Sprite2D`
  - Texture path:
    `res://assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`
  - Texture size: `256x256`
  - Before activation: available and visible, not activated
  - Activation result: `true`
  - Duplicate activation result: `false`
  - After activation: activated, available, interaction monitoring enabled
  - Route label: `Lower Deck Relay Secured`
  - Savepoint id: `old_factory_lower_deck_breach_relay`
  - Scene id: `area_03_factory`
  - Spawn point: `lower_deck_breach_relay`
  - Local relay flag: `true`
  - Breach corridor: secured, inactive, front/rear enemies invisible, hazard
    inactive
- MCP screenshot:
  `editor_screenshot(source="game")` captured a non-empty `960x539` game
  framebuffer during the relay runtime probe. The capture was available inline
  from MCP; no local screenshot artifact is committed for this run.

## Result

PASS. Story062 closes the post-breach lower-deck combat loop with a visible
relay savepoint and a verified non-boss respawn route while preserving the
optional service lift and existing lower-deck prerequisite chain.
