# QA Evidence: Old Factory Deep Route Micro-Slice

Date: 2026-06-26
Story: `production/epics/player-abilities/story-010-old-factory-deep-route-micro-slice.md`

## Scope

Story010 extends the existing Old Factory entrance room with a second Rat Minion
guard and a generated deep-route endpoint switch. The endpoint starts locked,
unlocks when the second guard is defeated, activates once for a nearby player,
and persists route progress through `OldFactoryEntranceScene` local scene state.

Out of scope remains unchanged: no full Old Factory multi-room layout, no Boss2,
no new enemy family, no new player ability, and no SceneManager or SaveSystem
schema rewrite.

## Asset Evidence

Runtime asset:

- `res://assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png`

Source assets:

- `assets/generated/source/factory_deep_route_endpoint_imagegen_20260626.png`
- `assets/generated/source/factory_deep_route_endpoint_alpha_20260626.png`

Generation prompt summary:

- Pixel-art 2D side-scroller Old Factory deep-route endpoint switch prop.
- Rusted checkpoint pedestal, cat-paw mechanical switch, amber cat-eye indicator,
  hazard stripe base, cool blue rim light, subtle electric spark details, no UI,
  no text, no watermark.
- Generated on a flat `#00ff00` chroma-key background, then alpha-matted with
  local chroma-key removal and cropped/resized to a transparent 256x256 runtime
  PNG.

Import evidence:

- `godot --headless --path . --import --quit`
- Godot import registered `FactoryDeepRouteEndpoint` and refreshed the endpoint
  source, alpha source, and runtime PNG import metadata.

Manifest evidence:

- `design/assets/asset-manifest.md` records `old_factory_deep_route_endpoint`.
- `design/assets/entity-inventory.md` records `Old Factory Deep Route Endpoint`.

## Automated Test Evidence

RED:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd --ignoreHeadlessMode`
- Result: `reports/report_655/` failed as expected because the registered
  factory scene had no generated endpoint PNG, no `FactoryDeepRouteEndpoint`
  node, and no deep-route runtime APIs.

RED refinement:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd --ignoreHeadlessMode`
- Result: `reports/report_656/` failed on missing Godot import metadata for the
  new endpoint PNG before the import pass.

GREEN focused:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd --ignoreHeadlessMode`
- Result: `reports/report_657/` passed `4/4`.

Related regression:

- `old_factory_entrance_combat_slice_runtime_test.gd`: `reports/report_658/`
  passed `4/4`.
- `old_factory_entrance_room_clear_runtime_test.gd`: `reports/report_659/`
  passed `3/3`.
- `old_factory_steam_vent_hazard_runtime_test.gd`: `reports/report_660/`
  passed `4/4`.

The related set stays intentionally small to avoid full-suite churn while still
covering all prior Old Factory content touched by this story.

## Headless Smoke Evidence

Commands:

- `godot --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_deep_route_micro_slice_factory_scene_smoke.log`
- `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_deep_route_micro_slice_main_scene_smoke.log`

Result:

- Both commands exited `0`.
- Keyword scans found no script parse, invalid call, missing resource, or
  resource-load errors in the smoke logs.
- The Factory scene smoke still reported existing cleanup-time ObjectDB/resource
  messages at process exit; gameplay runtime logs and test results were clean.

## Godot MCP Runtime Evidence

Scene:

- `res://scenes/factory_route_transition_shell.tscn`
- Run mode: custom scene through MCP with `autosave=false` to avoid stale editor
  tab state.

Runtime tree evidence:

- Root scene: `FactoryRouteTransitionShellScene`
- Scene id: `area_03_factory`
- Nodes present:
  - `Player`
  - `FactoryRatMinion`
  - `FactoryDeepGuardRatMinion`
  - `FactoryCombatCache`
  - `FactorySteamVentHazard`
  - `FactoryDeepRouteEndpoint`
  - `FactoryDeepRouteEndpoint/Visual`
  - `FactoryDeepRouteEndpoint/InteractionArea`

Runtime probe evidence:

- Initial deep-route diagnostics:
  - `deep_guard_present=true`
  - `deep_guard_entity_id=2101`
  - `deep_guard_defeated=false`
  - `deep_route_cleared=false`
  - `endpoint_available=false`
  - `endpoint_activated=false`
  - `endpoint_texture_path="res://assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png"`
- Interaction:
  - endpoint activation before guard defeat: `false`
  - endpoint activation after guard defeat: `true`
  - duplicate endpoint activation: `false`
- Local scene state:
  - `factory_deep_guard_defeated=true`
  - `factory_deep_route_cleared=true`
- Character animation:
  - `Player/Sprite`: `AnimatedSprite2D`
  - Player `idle/run/jump` frames: `3/3/3`
  - `FactoryDeepGuardRatMinion/Sprite`: `AnimatedSprite2D`
  - Deep guard `idle/run/attack/hurt/death` frames: `3/3/3/3/3`

MCP logs:

- `logs_read(source="game")` returned only the game helper registration line.
- `logs_read(source="editor")` returned no errors.

Screenshot:

- `reports/visual/cinderpaw-mcp-old-factory-deep-route-micro-slice-20260626.png`
- The screenshot is 1280x720 and shows the Old Factory backdrop, Cinderpaw,
  generated steam vent hazard, combat cache, and generated deep-route endpoint.

## Verdict

PASS. Story010 adds a small but visible ACT route objective to the Old Factory:
a second animated Rat guard gates a generated endpoint switch, route completion
is deterministic and scene-local, prior room content remains valid, and Godot MCP
runtime screenshot/log verification is clean.
