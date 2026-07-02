# QA Evidence: Old Factory Lower Deck Forward Conduit Ambush

Date: 2026-07-02
Engine: Godot 4.7-stable
MCP: Godot AI 2.8.3

## Story

`production/epics/player-abilities/story-067-old-factory-lower-deck-forward-conduit-ambush.md`

## Scope

Story067 adds the next playable ACT beat behind the Story066 relay-forward
hatch:

- `FactoryLowerDeckForwardConduitSparkRat`
- `FactoryLowerDeckForwardConduitSteamHazard`
- entity id `2118`
- hazard id `old_factory_lower_deck_forward_conduit`
- scene-local flags:
  - `factory_lower_deck_forward_conduit_activated`
  - `factory_lower_deck_forward_conduit_defeated`

No new visual or audio assets were generated. The story reuses imported
image-generated Factory Spark Rat SpriteFrames, Old Factory steam vent hazard
art, and the post-bulkhead lower-deck backdrop.

## Automated Tests

- RED focused: `reports/report_1093/`
  - Expected failure before Story067 APIs and diagnostics existed.
- Focused GREEN: `reports/report_1094/`
  - `2/2` passed.
- Related regression: `reports/report_1095/`
  - `26/26` passed across Story067, Story066 relay-forward reward hatch,
    Story065 post-relay trial, breach relay/reward route, lower-deck cache and
    gate regressions, steam sluice, pressure valve, deep bulkhead, and
    service-lift SceneManager exit suites.
- Story015 stale editor-row isolation: `reports/report_1096/`
  - `5/5` passed, confirming the visible editor Debugger rows for
    `old_factory_spark_rat_dodge_counter_readability_test.gd` are stale cache
    noise rather than a current CLI parse failure.

## Headless Smoke

Command wrote
`reports/old_factory_lower_deck_forward_conduit_ambush_smoke.log`.

Result:

- Exit code `0`.
- Keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors.
- Godot emitted only exit-time cleanup noise:
  `ERROR: 2 resources still in use at exit`.

## MCP Runtime Evidence

Godot MCP launched `res://scenes/factory_route_transition_shell.tscn` with
`autosave=false`.

Confirmed:

- `helper_live=true`, `game_capture_ready=true`.
- Runtime scene tree contains:
  - `FactoryLowerDeckForwardConduitSparkRat`
  - `FactoryLowerDeckForwardConduitSteamHazard`
- Initial hazard runtime properties:
  - script `res://src/feature/factory_steam_vent_hazard.gd`
  - `hazard_id=old_factory_lower_deck_forward_conduit`
  - `damage=8`
  - `contact_cooldown_sec=1.0`
  - hidden, `monitoring=false`, `monitorable=false`,
    `collision_layer=0`, `collision_mask=0`
- Active encounter probe after full Story061-066 state and crossing x
  `1272.0`:
  - `activated=true`
  - `present=true`, `available=true`, `active=true`, `defeated=false`
  - `entity_id=2118`
  - `sprite_frames_path=res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  - `animation_frame_counts`: `idle/run/attack_tell/attack/hurt/death=3`
  - `enemy_visible=true`, `enemy_has_target=true`,
    `enemy_physics_enabled=true`, `enemy_process_enabled=true`
  - `hazard_active=true`, `hazard_visible=true`,
    `hazard_id=old_factory_lower_deck_forward_conduit`,
    `hazard_damage=8`, `hazard_cooldown_sec=1.0`
  - route objective: `clear_forward_conduit_ambush`
  - route label: `Clear Forward Conduit Ambush`
  - service lift stayed optional and available with prompt `Call lift`
  - breach relay VFX/audio replay counts stayed `0`
- Defeat probe:
  - `damaged=true`
  - `active=false`, `defeated=true`, `available=false`
  - `enemy_visible=false`, `enemy_has_target=false`,
    `enemy_physics_enabled=false`, `enemy_process_enabled=false`
  - `hazard_active=false`, `hazard_visible=false`
  - route objective: `forward_conduit_secured`
  - route label: `Forward Conduit Secured`
  - local state persisted
    `factory_lower_deck_forward_conduit_activated=true` and
    `factory_lower_deck_forward_conduit_defeated=true`
  - Story061-066 route flags remained true in the runtime route diagnostics
- Runtime logs:
  - Game log contained only the Godot AI helper registration line.
  - Editor log still returned pre-existing Story015 `CombatComponent` Debugger
    rows; `reports/report_1096/` passed under CLI, so these rows are treated as
    stale editor cache noise.
- MCP screenshot:
  `editor_screenshot(source="game")` captured a non-empty runtime framebuffer
  with metadata `960x539`, original `1278x718`.

## Notes

PASS. Story067 adds a deeper lower-deck forward conduit ambush with a reused
animated Factory Spark Rat and steam hazard, preserves the optional service
lift, and leaves service-lift routing, SaveSystem schema, minimap, fast travel,
and broader room expansion out of scope.
