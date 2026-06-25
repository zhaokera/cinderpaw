# QA Evidence: Old Factory Steam Vent Hazard Route

Date: 2026-06-26
Story: `production/epics/player-abilities/story-009-old-factory-steam-vent-hazard-route.md`

## Scope

Story009 adds a small ACT-visible traversal hazard inside the existing Old
Factory entrance room: a generated steam vent prop mounted as an `Area2D`
contact hazard. Player contact applies deterministic steam damage through the
existing `PlayerController.apply_damage()` path, repeated contact is gated by a
1.0 second cooldown, and non-player targets are ignored.

Out of scope remains unchanged: no full deeper Old Factory layout, no Boss2, no
new enemy family, no new player ability, and no SceneManager or SaveSystem
schema rewrite.

## Asset Evidence

Runtime asset:

- `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`

Source assets:

- `assets/generated/source/old_factory_steam_vent_hazard_imagegen_20260626.png`
- `assets/generated/source/old_factory_steam_vent_hazard_alpha_20260626.png`

Generation prompt summary:

- Pixel-art 2D side-scroller Old Factory steam vent hazard prop.
- Rusted circular grate, cracked steel housing, signal-red warning glow, pale
  steam plume, cat-paw scratches, old-world steel and concrete.
- Cool blue factory rim light, restrained rust orange, no characters, no UI, no
  text, no watermark.
- Generated on a flat `#00ff00` chroma-key background, then alpha-matted with
  local chroma-key removal and cropped/resized to a transparent 256x256 runtime
  PNG.

Import evidence:

- `godot --headless --path . --import --quit`
- Godot import registered `FactorySteamVentHazard` and refreshed the new steam
  vent PNG import metadata.

Manifest evidence:

- `design/assets/asset-manifest.md` records `old_factory_steam_vent_hazard`.
- `design/assets/entity-inventory.md` records `Old Factory Steam Vent Hazard`.

## Automated Test Evidence

RED:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd --ignoreHeadlessMode`
- Result: `reports/report_652/` failed as expected because the registered
  factory scene had no generated steam vent PNG, no `FactorySteamVentHazard`,
  and no steam hazard runtime APIs.

GREEN focused:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd --ignoreHeadlessMode`
- Result: `reports/report_653/` passed `4/4`.

Related regression:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd -a res://tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd -a res://tests/unit/gameplay/rat_king_electric_leak_contact_damage_test.gd --ignoreHeadlessMode`
- Result: `reports/report_654/` passed `19/19`.
- Note: The process still reported existing cleanup-time ObjectDB/resource
  messages at exit; test cases and runtime logs were clean.

## Headless Smoke Evidence

Commands:

- `godot --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_steam_vent_hazard_factory_scene_smoke.log`
- `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_steam_vent_hazard_main_scene_smoke.log`

Result:

- Both commands exited `0`.
- Keyword scans found no script parse, invalid call, missing resource, or
  resource-load errors in the smoke logs.

## Godot MCP Runtime Evidence

Scene:

- `res://scenes/factory_route_transition_shell.tscn`
- Run mode: custom scene through MCP with `autosave=false` to avoid stale editor
  tab state.

Runtime tree evidence:

- Root scene: `FactoryRouteTransitionShellScene`
- Scene id: `area_03_factory`
- Nodes present:
  - `FactoryGateEntrySpawn`
  - `Player`
  - `FactoryRatMinion`
  - `FactoryCombatCache`
  - `FactoryCachePlatform`
  - `FactorySteamVentHazard`
  - `FactorySteamVentHazard/Visual`
  - `FactorySteamVentHazard/CollisionShape2D`

Runtime probe evidence:

- `FactorySteamVentHazard`:
  - `collision_layer=16`
  - `collision_mask=12`
  - `monitoring=true`
  - `monitorable=false`
  - texture path:
    `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Player contact:
  - HP sequence: `100 -> 92 -> 92 -> 84`
  - contacts: `[true,false,true]`
  - `last_hazard_damage.source="old_factory_steam_vent"`
  - `last_hazard_damage.damage_type="steam"`
  - `last_hazard_damage.damage=8`
- Enemy contact:
  - `enemy_contact=false`
  - enemy HP remained `24 -> 24`
- Character animation:
  - `Player/Sprite`: `AnimatedSprite2D`
  - `FactoryRatMinion/Sprite`: `AnimatedSprite2D`
  - Player `jump` frames: `3`
  - Rat Minion `idle/run/attack` frames: `3/3/3`

MCP logs:

- `logs_read(source="game")` returned only the game helper registration line.
- `logs_read(source="editor")` returned no errors.

Screenshot:

- `reports/visual/cinderpaw-mcp-old-factory-steam-vent-hazard-20260626.png`
- The screenshot is 1280x720 and shows the Old Factory backdrop, Cinderpaw,
  Factory Rat Minion, combat cache, and generated steam vent hazard.

## Verdict

PASS. Story009 satisfies the focused ACT-visible slice requirements: it adds a
non-placeholder generated hazard prop, real player contact damage with cooldown,
enemy ignore behavior, deterministic diagnostics, frame-animation rule coverage,
and Godot MCP runtime screenshot/log verification.
