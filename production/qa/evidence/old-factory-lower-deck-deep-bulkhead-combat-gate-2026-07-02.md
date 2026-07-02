# Old Factory Lower Deck Deep Bulkhead Combat Gate Evidence

Date: 2026-07-02
Engine: Godot `4.7.stable.official.5b4e0cb0f`
MCP session: `cinderpaw@4400`, Godot MCP runtime

## Story

`production/epics/player-abilities/story-060-old-factory-lower-deck-deep-bulkhead-combat-gate.md`

## Scope

Story060 adds a deeper lower-deck combat gate after the steam sluice ambush.
After `factory_lower_deck_steam_sluice_defeated=true`, Cinderpaw can cross the
new deep bulkhead boundary to reveal an animated Factory Spark Rat guard and a
closed bulkhead door. Defeating entity `2114` unlocks the door prompt; opening
the door disables the local collision blocker and persists the opened state.

## Asset Pipeline

New image-generated environment prop:

- Source:
  `res://assets/generated/source/old_factory_lower_deck_deep_bulkhead_imagegen_20260702.png`
- Alpha-matted source:
  `res://assets/generated/source/old_factory_lower_deck_deep_bulkhead_alpha_20260702.png`
- Runtime texture:
  `res://assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- Metadata:
  `res://assets/generated/source/old_factory_lower_deck_deep_bulkhead_imagegen_20260702.json`

The prompt summary recorded in metadata: pixel-art Old Factory lower-deck deep
bulkhead door, rusted heavy steel plates, cat-paw scratches, amber cat-eye lock
core, cyan factory rim light, hazard-striping, and clean side-scroller
silhouette. The source was chroma-keyed, alpha-matted, resized to 256x256, and
imported through Godot.

Runtime-visible guard asset reuse:

- Enemy: `res://src/gameplay/factory_spark_rat.tscn`
- SpriteFrames:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`

The guard remains compliant with the AGENTS.md frame-animation rule:
`AnimatedSprite2D + SpriteFrames`, with `idle`, `run`, `attack_tell`, `attack`,
`hurt`, and `death` all at `3` frames.

## Automated Tests

- RED focused:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_deep_bulkhead_gate_test.gd --ignoreHeadlessMode`
  - Result: `reports/report_1058/`, exit `100`, failed as expected because
    Story060 diagnostics, activation, and open APIs did not exist.

- Godot import:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . --editor --quit`
  - Result: generated `.import` sidecars for the deep bulkhead source,
    alpha source, and runtime PNG.

- GREEN focused:
  - Same focused GdUnit command.
  - Result: `reports/report_1060/`, exit `0`, `2/2` passed, `0` orphans.

- Related lower-deck regression:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_deep_bulkhead_gate_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_steam_sluice_ambush_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_pressure_valve_test.gd -a res://tests/unit/gameplay/old_factory_service_lift_scene_manager_exit_test.gd --ignoreHeadlessMode`
  - Result: `reports/report_1062/`, exit `0`, `8/8` passed, `0` orphans.

- Headless smoke:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . res://scenes/factory_route_transition_shell.tscn --quit-after 2`
  - Result: `reports/old_factory_lower_deck_deep_bulkhead_smoke.log`, exit
    `0`. Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
    `Invalid get index`, missing-resource, or resource-load errors. The log
    retains the known Godot cleanup-time ObjectDB/resource messages.

## MCP Runtime Evidence

MCP launched `res://scenes/factory_route_transition_shell.tscn` with
`autosave=false`. Runtime probe set the complete Story054-059 lower-deck state,
including `factory_lower_deck_steam_sluice_defeated=true`, then activated,
defeated, and opened the Story060 deep bulkhead gate.

Observed activation state:

- `guard_active=true`
- `guard_visible=true`
- `guard_has_target=true`
- `guard_physics_enabled=true`
- `guard_process_enabled=true`
- `guard_entity_id=2114`
- `sprite_frames_path=res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Animation frame counts:
  - `idle=3`
  - `run=3`
  - `attack_tell=3`
  - `attack=3`
  - `hurt=3`
  - `death=3`
- `bulkhead_visible=true`
- `bulkhead_collision_blocking=true`
- `bulkhead_texture_path=res://assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- Route objective: `clear_deep_bulkhead_guard`
- Route label: `Clear Deep Bulkhead Guard`
- Service lift prompt: `Call lift`

Observed defeat/open state:

- `damage_ok=true`
- `guard_active=false`
- `guard_defeated=true`
- `guard_visible=false`
- `bulkhead_available=true`
- `bulkhead_prompt_text=Open bulkhead`
- Route label after defeat: `Open Deep Bulkhead`
- `open_ok=true`
- `bulkhead_opened=true`
- `bulkhead_available=false`
- `bulkhead_collision_blocking=false`
- Route objective after open: `deep_bulkhead_opened`
- Route label after open: `Deep Bulkhead Opened`
- Local state flags persisted:
  - `factory_lower_deck_deep_bulkhead_guard_activated=true`
  - `factory_lower_deck_deep_bulkhead_guard_defeated=true`
  - `factory_lower_deck_deep_bulkhead_opened=true`
  - `factory_lower_deck_steam_sluice_defeated=true`

MCP log checks:

- Game log contained only the Godot AI helper registration line for the active
  run.
- Editor log returned no entries.
- Screenshot metadata: source `game`, PNG `960x539`; target scene was active
  with the 2114 Spark Rat guard and deep bulkhead door visible.
- Final pre-commit MCP check relaunched
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false` on
  Godot `4.7-stable (official)`, reported `helper_live=true`,
  `recent_errors=[]`, confirmed runtime nodes
  `FactoryLowerDeckDeepBulkheadSparkRat` and `FactoryLowerDeckDeepBulkhead`,
  read the guard sprite as `AnimatedSprite2D` with the Factory Spark Rat
  `SpriteFrames` resource, read the bulkhead visual texture from the generated
  runtime PNG, captured a non-empty game screenshot `640x359`, and stopped the
  running project cleanly.

## Result

PASS. Story060 adds a visible playable lower-deck combat gate, replaces the new
door prop with image-generated art, preserves the optional service lift, and
keeps the route state scene-local without SaveSystem or global quest changes.
