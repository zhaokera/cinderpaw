# Old Factory Lower Deck Shortcut Pursuer Evidence

Date: 2026-07-02
Engine: Godot `4.7.stable.official.5b4e0cb0f`
Story: `production/epics/player-abilities/story-057-old-factory-lower-deck-shortcut-pursuer.md`

## Scope

Story057 adds an optional ACT pressure beat after the Story056 lower-deck
shortcut payoff cache. Claiming the shortcut cache enables
`FactoryLowerDeckShortcutPursuerSparkRat`; crossing the activation boundary
spawns a reused Factory Spark Rat pursuer without blocking the service lift.

No new visual assets were generated. The story reuses:

- `res://src/gameplay/factory_spark_rat.tscn`
- `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`

## GdUnit Evidence

Focused RED:

```text
/Applications/Godot 2.app/Contents/MacOS/Godot --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/old_factory_lower_deck_shortcut_pursuer_test.gd \
  --ignoreHeadlessMode
```

- Result: exit `100`
- Report: `reports/report_1048/`
- Expected failure: Story057 public diagnostics/activation APIs were absent.

Focused GREEN:

```text
/Applications/Godot 2.app/Contents/MacOS/Godot --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/old_factory_lower_deck_shortcut_pursuer_test.gd \
  --ignoreHeadlessMode
```

- Result: exit `0`
- Report: `reports/report_1049/`
- Tests: `2/2` passed, `0` failures/errors/flaky/skipped/orphans.

Related regression:

```text
/Applications/Godot 2.app/Contents/MacOS/Godot --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/old_factory_lower_deck_shortcut_pursuer_test.gd \
  -a res://tests/unit/gameplay/old_factory_lower_deck_shortcut_reward_cache_test.gd \
  -a res://tests/unit/gameplay/old_factory_lower_deck_shortcut_seal_test.gd \
  -a res://tests/unit/gameplay/old_factory_lower_deck_exit_ambush_test.gd \
  -a res://tests/unit/gameplay/old_factory_lower_deck_skirmish_cache_test.gd \
  -a res://tests/unit/gameplay/old_factory_service_lift_scene_manager_exit_test.gd \
  -a res://tests/unit/gameplay/factory_route_runtime_roundtrip_test.gd \
  --ignoreHeadlessMode
```

- Result: exit `0`
- Report: `reports/report_1050/`
- Tests: `12/12` passed, `0` failures/errors/flaky/skipped/orphans.

## Headless Smoke

```text
/Applications/Godot 2.app/Contents/MacOS/Godot --headless --path . \
  --scene res://scenes/factory_route_transition_shell.tscn \
  --fixed-fps 60 --quit-after 180 \
  --log-file reports/old_factory_lower_deck_shortcut_pursuer_smoke.log
```

- Result: exit `0`
- Log: `reports/old_factory_lower_deck_shortcut_pursuer_smoke.log`
- Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
  `Invalid access`, missing-resource, `ERROR:`, `FATAL`, or `WARNING` entries in
  the saved log.

## Godot MCP Runtime

MCP session:

- Session: `cinderpaw@4400`
- Godot: `4.7-stable (official)`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Project run: custom scene, `autosave=false`

Runtime checks:

- Runtime tree contains
  `/FactoryRouteTransitionShellScene/FactoryLowerDeckShortcutPursuerSparkRat`
  as `CharacterBody2D` with child `Sprite` as `AnimatedSprite2D`.
- Before activation, pursuer diagnostics reported `available=true`,
  `active=false`, `enemy_visible=false`, `enemy_process_enabled=false`,
  `enemy_physics_enabled=false`, and no target.
- After setting prior lower-deck shortcut/cache state and moving Cinderpaw past
  activation x `1218.0`, `try_activate_factory_lower_deck_shortcut_pursuer`
  returned `true`.
- Active diagnostics reported `active=true`, `enemy_visible=true`,
  `enemy_has_target=true`, `enemy_process_enabled=true`,
  `enemy_physics_enabled=true`, entity id `2111`, and SpriteFrames path
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- Animation frame counts were `idle=3`, `run=3`, `attack_tell=3`, `attack=3`,
  `hurt=3`, and `death=3`.
- `get_factory_route_objective_diagnostics()` reported
  `objective_id=clear_shortcut_pursuer` and route label
  `Clear Shortcut Pursuer`.
- Moving Cinderpaw to `FactoryServiceLift` kept
  `get_factory_service_lift_diagnostics()` available with prompt `Call lift`.
- `apply_damage(2111, 999, {"source": &"mcp_shortcut_pursuer"})` moved the
  pursuer to defeated state; the follow-up no-await diagnostic reported
  `active=false`, `defeated=true`, `enemy_visible=false`, route objective
  `shortcut_pursuer_cleared`, and route label `Shortcut Pursuer Cleared`.
- MCP screenshot source `game` returned non-empty metadata `960x539`.
- `logs_read(source="game")` showed only the Godot AI helper registration line.
- `logs_read(source="editor")` returned no entries.

One MCP eval probe using `await get_tree().process_frame` timed out because
MCP eval await only progresses while the game window is focused. The same
defeat state was confirmed immediately afterwards with a no-await diagnostic,
and the focused GdUnit test covers the process-frame persistence path.

## Result

Story057 acceptance passed under the project baseline Godot 4.7.
