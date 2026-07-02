# QA Evidence: Old Factory Lower Deck Shortcut Seal Combat Gate

Date: 2026-07-02
Story: `production/epics/player-abilities/story-055-old-factory-lower-deck-shortcut-seal-combat-gate.md`
Engine: Godot `4.7.stable.official.5b4e0cb0f`
MCP session: `cinderpaw@4400`, Godot MCP plugin/server `2.8.1`

## Scope

Story055 adds an optional lower-deck shortcut seal after Story054's lower-deck
exit ambush. After `factory_lower_deck_exit_ambush_defeated=true`, Cinderpaw can
trigger a reused animated Factory Spark Rat guard, defeat entity `2110`, and
open `FactoryLowerDeckShortcutSeal`. The shortcut does not block the already
available service lift.

## Asset Evidence

No new visual assets were generated for this story.

- Reused Factory Spark Rat SpriteFrames:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- Reused shortcut seal visual:
  `res://assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png`.
- Reused unlock VFX:
  `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`.
- Runtime frame contract observed through tests and MCP:
  `idle/run/attack_tell/attack/hurt/death=3`.

## Automated Verification

Focused RED:

```text
reports/report_1039/
Exit: 100
Expected failure: shortcut seal diagnostics and activation APIs did not exist.
```

Focused GREEN:

```text
reports/report_1043/
Story055: 2/2 passed
Errors: 0
Failures: 0
Flaky: 0
Skipped: 0
Orphans: 0
```

Related regression:

```text
reports/report_1044/
Suites:
- old_factory_lower_deck_shortcut_seal_test.gd
- old_factory_lower_deck_exit_ambush_test.gd
- old_factory_lower_deck_skirmish_cache_test.gd
- old_factory_checkpoint_overdrive_duo_test.gd
- old_factory_checkpoint_overdrive_reward_cache_test.gd
- old_factory_service_lift_scene_manager_exit_test.gd
- factory_route_runtime_roundtrip_test.gd

Result: 14/14 passed
Errors: 0
Failures: 0
Flaky: 0
Skipped: 0
Orphans: 0
```

Headless smoke:

```text
reports/old_factory_lower_deck_shortcut_seal_smoke.log
Scene: res://scenes/factory_route_transition_shell.tscn
Exit: 0
Keyword scan: no SCRIPT ERROR, Parse Error, Invalid call, Invalid access,
Resource file not found, Failed loading resource, ERROR, FATAL, or WARNING
entries in the log file.
```

The terminal still printed the known Godot cleanup-time ObjectDB/resource
messages at process exit; the smoke log did not contain project script/resource
errors.

## MCP Runtime Evidence

Steps:

1. Activated MCP session `cinderpaw@4400`.
2. Confirmed Godot `4.7-stable (official)`.
3. Cleared MCP game/editor logs.
4. Ran `res://scenes/factory_route_transition_shell.tscn` through MCP with
   `autosave=false`; `project_run` returned `recent_errors=[]`.
5. Set Old Factory local state to the post-Story054 contract:
   checkpoint overdrive duo cleared, lower-deck skirmish defeated, lower-deck
   cache claimed, lower-deck parry gate unlocked, and lower-deck exit ambush
   defeated.
6. Moved Cinderpaw past the shortcut activation boundary and activated the
   shortcut seal guard.
7. Applied fatal damage to entity `2110`, opened the shortcut seal, and read
   route objective, service lift, frame-count, collision, and persistence
   diagnostics.
8. Restarted the custom Factory run and captured a non-empty game screenshot of
   the active guard state.
9. Read current game/editor logs and stopped the running project.

Observed active shortcut guard:

- `FactoryLowerDeckShortcutSeal` present and visible.
- `FactoryLowerDeckShortcutSparkRat` present and visible.
- `active=true`.
- `guard_entity_id=2110`.
- `guard_has_target=true`.
- `guard_physics_enabled=true`.
- `guard_process_enabled=true`.
- SpriteFrames path:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- Frame counts:
  `idle=3`, `run=3`, `attack_tell=3`, `attack=3`, `hurt=3`, `death=3`.
- Route label: `Clear Shortcut Guard`.
- Service lift prompt: `Call lift`.

Observed after guard defeat and seal open:

- Fatal damage to entity `2110`: `damaged=true`.
- Guard defeated: `guard_defeated=true`.
- Seal unlockable before open: `seal_unlockable=true`.
- Open result: `opened=true`.
- Duplicate open rejected by state: covered by focused GdUnit.
- Final shortcut:
  - `unlocked=true`.
  - `collision_blocking=false`.
  - `factory_lower_deck_shortcut_activated=true`.
  - `factory_lower_deck_shortcut_guard_defeated=true`.
  - `factory_lower_deck_shortcut_unlocked=true`.
- Route objective:
  - `objective_id="lower_deck_shortcut_opened"`.
  - `route_label_text="Lower Deck Shortcut Opened"`.
- Story054 exit ambush state remained defeated:
  `factory_lower_deck_exit_ambush_defeated=true`.

Runtime restore evidence from focused GdUnit:

- Restored scene-local state keeps the shortcut open.
- Restored shortcut collision remains disabled.
- Restored guard is hidden/defeated.
- Restored Story054 exit ambush is inactive/hidden/defeated.

MCP log evidence:

- Final editor log read: `0` lines.
- Final game log read: one info line from `godot_ai game_helper` registration,
  no warning/error rows.

Screenshot evidence:

- MCP `editor_screenshot(source="game", max_resolution=960)` returned a
  non-empty PNG with metadata `width=960`, `height=539`, original
  `1278x718`.
- The screenshot shows Cinderpaw, the active shortcut guard, the shortcut seal,
  and route label `Clear Shortcut Guard`.

## Result

PASS. Story055 adds a player-visible optional combat shortcut loop after
Story054, preserves service-lift availability, keeps the Spark Rat frame
animation contract, persists scene-local state, and passes focused, related,
headless, and MCP 4.7 runtime verification.
