# Old Factory Lower Deck Post-Relay Combat Feedback Evidence

## Scope

- Story:
  `production/epics/player-abilities/story-065-old-factory-lower-deck-post-relay-combat-feedback.md`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Runtime script:
  `res://src/gameplay/old_factory_entrance_scene.gd`
- Test file:
  `res://tests/unit/gameplay/old_factory_lower_deck_post_relay_combat_feedback_test.gd`

## Implementation Evidence

- `FactoryLowerDeckPostRelaySparkRat` is mounted in the Factory scene and bound
  to entity id `2117`.
- `FactoryLowerDeckPostRelaySteamHazard` is mounted as an inactive `Area2D`
  until the trial activates.
- `try_activate_factory_lower_deck_post_relay_trial(...)` requires the
  lower-deck breach relay to be repaired and provider x position `>= 1232.0`.
- Active diagnostics report enemy target assignment, process/physics enablement,
  `AnimatedSprite2D + SpriteFrames` path, six animation frame counts, hazard
  damage/cooldown/id, and route state.
- Defeat through the Factory damage path disables both the enemy and hazard,
  persists activation/defeat flags, and updates the route label to
  `Relay Forward Secured`.

## Asset Evidence

No new asset was generated. Story065 reuses existing image-generated assets:

- Factory Spark Rat SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Steam vent hazard prop:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Post-bulkhead backdrop:
  `assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`

New usage is recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED focused:
  `reports/report_1084/` failed as expected before
  `get_factory_lower_deck_post_relay_trial_diagnostics()` and
  `try_activate_factory_lower_deck_post_relay_trial()` existed.
- Focused GREEN:
  `reports/report_1086/` passed Story065 `2/2` with `0` errors, failures,
  skipped, flaky, and orphans.
- Related GREEN:
  `reports/report_1088/` passed Story065, breach relay feedback, breach reward
  route, breach corridor ambush, and service-lift SceneManager exit suites
  `12/12` with `0` errors, failures, skipped, flaky, and orphans.
- Headless smoke:
  `reports/old_factory_lower_deck_post_relay_combat_feedback_smoke.log` exited
  `0`; script/parse/invalid-call/access/missing-resource/resource-load keyword
  scan returned no project errors.

## MCP Runtime Verification

- Godot version: `4.7-stable (official)`.
- Godot AI MCP: plugin/server `2.8.3`.
- Active trial probe:
  - `activated=true`
  - `present=true`, `available=true`, `active=true`, `defeated=false`
  - `entity_id=2117`
  - `sprite_frames_path=res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  - `animation_frame_counts`: `idle/run/attack_tell/attack/hurt/death=3`
  - `enemy_visible=true`, `enemy_has_target=true`,
    `enemy_physics_enabled=true`, `enemy_process_enabled=true`
  - `hazard_active=true`, `hazard_visible=true`,
    `hazard_id=old_factory_lower_deck_post_relay_trial`,
    `hazard_damage=8`, `hazard_cooldown_sec=1.0`
  - route objective: `clear_post_relay_trial`
  - route label: `Clear Relay Forward Trial`
  - service lift remained available with prompt `Call lift`
- Defeat probe:
  - `damaged=true`
  - `active=false`, `defeated=true`, `available=false`
  - `enemy_visible=false`, `enemy_has_target=false`,
    `enemy_physics_enabled=false`, `enemy_process_enabled=false`
  - `hazard_active=false`, `hazard_visible=false`
  - route objective: `post_relay_trial_secured`
  - route label: `Relay Forward Secured`
  - local state persisted
    `factory_lower_deck_post_relay_trial_activated=true` and
    `factory_lower_deck_post_relay_trial_defeated=true`
- Runtime logs:
  - Game log after the probe contained only the MCP helper registration line.
  - Editor log still returned pre-existing Story015 `CombatComponent` Debugger
    rows; `reports/report_1083/` and the current source confirm that referenced
    test passes under CLI, so the rows are treated as stale editor cache noise.
- MCP screenshot:
  `editor_screenshot(source="game")` captured a non-empty `960x539` runtime
  framebuffer for the relay-forward state. The capture was available inline from
  MCP; no local screenshot artifact is committed for this run.

## Result

PASS. Story065 adds a post-relay combat pressure beat with a reused animated
Factory Spark Rat and steam hazard, while preserving lower-deck relay behavior
and the optional service lift.
