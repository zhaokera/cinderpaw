# Old Factory Lower Deck Steam Sluice Ambush Evidence

Date: 2026-07-02
Engine: Godot `4.7.stable.official.5b4e0cb0f`
MCP session: `cinderpaw@4400`, Godot MCP plugin/server `2.8.1`

## Story

`production/epics/player-abilities/story-059-old-factory-lower-deck-steam-sluice-ambush.md`

## Scope

Story059 adds a pressure-valve follow-up combat beat in the Old Factory lower
deck. After `factory_lower_deck_pressure_valve_opened=true`, Cinderpaw can cross
the new steam sluice boundary to trigger an animated Factory Spark Rat and an
active steam hazard. Clearing entity `2113` closes the ambush and persists the
scene-local state.

## Asset Pipeline

No new visual assets were generated. This slice intentionally reuses existing
Godot-imported assets:

- Enemy: `res://src/gameplay/factory_spark_rat.tscn`
- SpriteFrames:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Steam hazard texture:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Steam hazard script:
  `res://src/feature/factory_steam_vent_hazard.gd`

The runtime-visible enemy remains compliant with the AGENTS.md frame-animation
rule: `AnimatedSprite2D + SpriteFrames`, with `idle`, `run`, `attack_tell`,
`attack`, `hurt`, and `death` all at `3` frames.

## Automated Tests

- RED focused:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_steam_sluice_ambush_test.gd --ignoreHeadlessMode`
  - Result: `reports/report_1055/`, exit `100`, failed as expected because
    Story059 diagnostics and activation APIs did not exist.

- GREEN focused:
  - Same command.
  - Result: `reports/report_1056/`, exit `0`, `2/2` passed, `0` orphans.

- Related lower-deck regression:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_pressure_valve_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_shortcut_pursuer_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_shortcut_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_shortcut_seal_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_exit_ambush_test.gd -a res://tests/unit/gameplay/old_factory_service_lift_scene_manager_exit_test.gd --ignoreHeadlessMode`
  - Result: `reports/report_1057/`, exit `0`, `11/11` passed, `0` orphans.

- Headless smoke:
  - Command:
    `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . --quit --log-file reports/old_factory_lower_deck_steam_sluice_smoke.log`
  - Result: exit `0`. Keyword scan found no `SCRIPT ERROR`, `Parse Error`,
    `Invalid call`, `Invalid get index`, missing/resource-load errors, or
    `ERROR:` entries. The log retains the known Godot cleanup-time
    ObjectDB/resource messages.

## MCP Runtime Evidence

MCP launched `res://scenes/factory_route_transition_shell.tscn` with
`autosave=false`. Runtime probe set the complete Story054-058 lower-deck state,
including `factory_lower_deck_pressure_valve_opened=true`, then activated and
cleared the Story059 ambush.

Observed activation state:

- `activated_ok=true`
- `entity_id=2113`
- `enemy_visible=true`
- `enemy_has_target=true`
- `enemy_physics_enabled=true`
- `enemy_process_enabled=true`
- `sprite_frames_path=res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Animation frame counts:
  - `idle=3`
  - `run=3`
  - `attack_tell=3`
  - `attack=3`
  - `hurt=3`
  - `death=3`
- `hazard_active=true`
- `hazard_id=old_factory_lower_deck_steam_sluice`
- `hazard_texture_path=res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Route objective: `clear_steam_sluice_ambush`
- Route label: `Clear Steam Sluice Ambush`
- Service lift prompt: `Call lift`

Observed clear state:

- `damage_ok=true`
- `active=false`
- `defeated=true`
- `enemy_visible=false`
- `hazard_active=false`
- Route objective: `steam_sluice_cleared`
- Route label: `Steam Sluice Cleared`
- Local state flags persisted:
  - `factory_lower_deck_steam_sluice_activated=true`
  - `factory_lower_deck_steam_sluice_defeated=true`
  - `factory_lower_deck_pressure_valve_opened=true`
  - `factory_lower_deck_pressure_guard_defeated=true`
  - `factory_lower_deck_shortcut_pursuer_defeated=true`

MCP log checks:

- Game log contained only the Godot AI helper registration line for the active
  run.
- Editor log returned no entries.
- Screenshot metadata: source `game`, PNG `960x539`; target scene was active
  with the 2113 Spark Rat and steam sluice hazard visible.

## Result

PASS. Story059 adds a visible, playable ACT combat beat after Story058 while
reusing compliant frame-animation and hazard assets, preserving the optional
service lift, and avoiding unrelated SaveSystem or global route changes.
