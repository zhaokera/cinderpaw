# Old Factory Lower Deck Breach Corridor Ambush Evidence

Date: 2026-07-02
Engine: Godot `4.7.stable.official.5b4e0cb0f`
MCP session: `cinderpaw@4400`, Godot MCP runtime

## Story

`production/epics/player-abilities/story-061-old-factory-lower-deck-breach-corridor-ambush.md`

## Scope

Story061 adds the first playable beat beyond the Story060 deep bulkhead:
opening the bulkhead makes a post-bulkhead corridor background visible, then
Cinderpaw can trigger a front Spark Rat guard, a rear pincer ambusher, and a
breach steam hazard. Clearing both enemies secures the corridor without
replaying the lower-deck prerequisite chain.

## Asset Pipeline

New image-generated environment background:

- Source:
  `res://assets/generated/source/old_factory_lower_deck_post_bulkhead_backdrop_imagegen_20260702.png`
- Runtime texture:
  `res://assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`
- Metadata:
  `res://assets/generated/source/old_factory_lower_deck_post_bulkhead_backdrop_imagegen_20260702.json`

Prompt summary recorded in metadata: pixel-art Old Factory lower-deck chamber
beyond a heavy bulkhead door with rusted grated floor, ceiling pipes, damp
steam stains, steel-blue shadows, restrained rust-orange hazard panels, amber
cat-eye guide lights, no text, no UI, no characters, and a readable side-scroller
gameplay lane. The source was resized to a 1280x720 runtime PNG and imported
through Godot.

Runtime-visible enemy asset reuse:

- Enemy scene: `res://src/gameplay/factory_spark_rat.tscn`
- SpriteFrames:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`

Both breach enemies comply with the AGENTS.md frame-animation rule:
`AnimatedSprite2D + SpriteFrames`, with `idle`, `run`, `attack_tell`,
`attack`, `hurt`, and `death` all at `3` frames.

## Automated Tests

- RED focused:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_bulkhead_breach_ambush_test.gd --ignoreHeadlessMode`
  - Result: `reports/report_1064/`, exit `100`, failed as expected because
    Story061 diagnostics and activation APIs did not exist.

- Godot import:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . --editor --quit`
  - Result: generated `.import` sidecars for the post-bulkhead source and
    runtime PNG.

- GREEN focused:
  - Same focused GdUnit command.
  - Result: `reports/report_1065/`, exit `0`, `2/2` passed, `0` orphans.

- Related lower-deck regression:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_pressure_valve_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_steam_sluice_ambush_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_deep_bulkhead_gate_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_bulkhead_breach_ambush_test.gd -a res://tests/unit/gameplay/old_factory_service_lift_scene_manager_exit_test.gd --ignoreHeadlessMode`
  - Result: `reports/report_1066/`, exit `0`, `10/10` passed, `0` orphans.

- Headless smoke:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . res://scenes/factory_route_transition_shell.tscn --quit-after 2`
  - Result:
    `reports/old_factory_lower_deck_bulkhead_breach_ambush_smoke.log`, exit
    `0`. Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
    `Invalid get index`, missing-resource, or resource-load errors. The log
    retains the known Godot cleanup-time resource message.

## MCP Runtime Evidence

MCP launched `res://scenes/factory_route_transition_shell.tscn` with
`autosave=false`. Runtime probe set the complete Story054-060 lower-deck state,
including `factory_lower_deck_deep_bulkhead_opened=true`, then activated the
front ambush, activated the rear pincer, defeated both breach enemies, and read
diagnostics plus local state.

Observed front activation state:

- `front_ok=true`
- `active=true`
- `available=true`
- `front_visible=true`
- `front_has_target=true`
- `front_physics_enabled=true`
- `front_process_enabled=true`
- `front_entity_id=2115`
- `rear_visible=false`
- `hazard_active=true`
- `hazard_id=old_factory_lower_deck_breach_corridor`
- `post_bulkhead_background_visible=true`
- `post_bulkhead_background_texture_path=res://assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`
- Route objective: `clear_breach_corridor_ambush`
- Route label: `Clear Breach Corridor Ambush`

Observed pincer state:

- `rear_ok=true`
- `rear_activated=true`
- `rear_visible=true`
- `rear_has_target=true`
- `rear_physics_enabled=true`
- `rear_process_enabled=true`
- `rear_entity_id=2116`
- Route objective: `survive_breach_pincer`
- Route label: `Survive Breach Pincer`
- Service lift prompt: `Call lift`

Frame-animation contract:

- Front SpriteFrames:
  - `idle=3`
  - `run=3`
  - `attack_tell=3`
  - `attack=3`
  - `hurt=3`
  - `death=3`
- Rear SpriteFrames:
  - `idle=3`
  - `run=3`
  - `attack_tell=3`
  - `attack=3`
  - `hurt=3`
  - `death=3`

Observed secured state:

- `front_damage_ok=true`
- `rear_damage_ok=true`
- `active=false`
- `secured=true`
- `front_defeated=true`
- `rear_defeated=true`
- `front_visible=false`
- `rear_visible=false`
- `hazard_active=false`
- Route objective: `breach_corridor_secured`
- Route label: `Breach Corridor Secured`
- Persisted flags:
  - `factory_lower_deck_breach_corridor_activated=true`
  - `factory_lower_deck_breach_front_guard_defeated=true`
  - `factory_lower_deck_breach_rear_ambusher_activated=true`
  - `factory_lower_deck_breach_rear_ambusher_defeated=true`
  - `factory_lower_deck_breach_corridor_secured=true`

MCP log checks:

- Game log contained only the Godot AI helper registration line for the active
  run.
- Editor log returned no entries.
- Runtime scene tree included `PostBulkheadBackground`,
  `FactoryLowerDeckBreachSteamHazard`, and the Factory route scene root.
- Screenshot saved:
  `reports/visual/cinderpaw-mcp-old-factory-lower-deck-breach-corridor-ambush-20260702.png`
  at `1278x718`; screenshot is non-empty and shows the post-bulkhead corridor
  backdrop with `Breach Corridor Secured` route feedback.

## Notes

The visual slice still reuses the existing steam hazard texture and Factory
Spark Rat enemy family. New enemy families, authored steam SFX, minimap markers,
global quest state, and service-lift route changes remain out of scope.
