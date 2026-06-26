# QA Evidence: Old Factory Deep Route Unlock Feedback

Date: 2026-06-26
Story: `production/epics/player-abilities/story-012-old-factory-deep-route-unlock-feedback.md`

## Scope

Story012 adds a short player-visible unlock VFX to the existing Old Factory
deep-route endpoint. The endpoint still belongs to the single-room Old Factory
micro-slice: the second Rat Minion gates the endpoint, successful activation
clears the route once, duplicate activation fails, and state restoration does
not replay one-shot feedback.

Out of scope remains unchanged: no new Old Factory room, no Boss2, no hidden
boss, no savepoint/minimap work, no new enemy family, no full gate dissolve
system, and no SFX expansion.

## Asset Evidence

Runtime asset:

- `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`

Source assets:

- `assets/generated/source/factory_deep_route_unlock_spark_imagegen_20260626.png`
- `assets/generated/source/factory_deep_route_unlock_spark_alpha_20260626.png`

Generation prompt summary:

- Pixel-art transparent Old Factory route-unlock VFX for a 2D side-scroller.
- Amber cat-eye gold core, rusted switch burst silhouette, cool blue electric
  arcs, rust-orange flecks, bright readable spark rays, no UI, no text, no
  watermark.
- Generated on a flat green chroma-key background, alpha-matted with local
  chroma-key removal, cropped, and resized to a transparent 256x256 runtime PNG.

Import evidence:

- `godot --headless --path . --import --quit`
- Godot import refreshed the runtime VFX PNG plus source/alpha PNG import
  metadata and registered updated `FactoryDeepRouteEndpoint` /
  `OldFactoryEntranceScene` scripts.

Manifest evidence:

- `design/assets/asset-manifest.md` records
  `old_factory_deep_route_unlock_spark`.
- `design/assets/entity-inventory.md` records
  `Old Factory Deep Route Unlock Spark`.

## Automated Test Evidence

RED:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_deep_route_unlock_feedback_test.gd --ignoreHeadlessMode`
- Result: `reports/report_667/` failed as expected because
  `FactoryDeepRouteEndpoint` did not yet expose
  `get_unlock_vfx_texture_path()` / `get_unlock_vfx_snapshot()` or runtime VFX
  behavior.

GREEN focused:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_deep_route_unlock_feedback_test.gd --ignoreHeadlessMode`
- Result: `reports/report_668/` passed `5/5`.

Story010-011 regression:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd -a res://tests/unit/gameplay/old_factory_deep_guard_activation_pacing_test.gd --ignoreHeadlessMode`
- Result: `reports/report_669/` passed `8/8`.

Old Factory scene regression:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd -a res://tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd --ignoreHeadlessMode`
- Result: `reports/report_670/` passed `14/14`.

The related set is intentionally scoped to the files touched by this story:
Factory scene loading, Old Factory entrance combat, room-clear cache, steam
hazard, Story010 endpoint behavior, and Story011 deep-guard pacing.

Final submission regression:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_deep_route_unlock_feedback_test.gd -a res://tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd -a res://tests/unit/gameplay/old_factory_deep_guard_activation_pacing_test.gd -a res://tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd -a res://tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd --ignoreHeadlessMode`
- Result: `reports/report_671/` passed `27/27`.

## Headless Smoke Evidence

Commands:

- `godot --headless --path . --quit-after 2 res://scenes/factory_route_transition_shell.tscn > reports/old_factory_deep_route_unlock_feedback_factory_scene_smoke.log 2>&1`
- `godot --headless --path . --quit-after 2 > reports/old_factory_deep_route_unlock_feedback_main_scene_smoke.log 2>&1`

Result:

- Both commands exited `0`.
- Keyword scan found no script parse, invalid call, missing resource, or
  resource-load errors in either log.
- The main-scene smoke still reports the known cleanup-time
  `ObjectDB instances leaked` / `1 resources still in use` messages already
  present in earlier main-scene smoke logs; the Factory-scene smoke and MCP
  runtime logs are clean.

## Godot MCP Runtime Evidence

MCP connection:

- Active session: `cinderpaw@c1b2`
- Godot: `4.6.3-stable`
- Project path: `/Users/zhaok/Desktop/wxgame/cinderpaw/`
- Readiness before run: `ready`

Run mode:

- `project_run(mode="custom", scene="res://scenes/factory_route_transition_shell.tscn", autosave=false)`
- Custom-scene runtime was used because the editor tab still held a stale open
  copy of the factory scene. This avoided saving stale editor memory over the
  correct disk scene and verified the actual saved `.tscn` loaded by the game.

Runtime tree evidence:

- Root scene: `FactoryRouteTransitionShellScene`
- Nodes present in the running game:
  - `FactoryCachePlatform`
  - `Player`
  - `FactoryRatMinion`
  - `FactoryDeepGuardRatMinion`
  - `FactoryCombatCache`
  - `FactorySteamVentHazard`
  - `FactoryDeepRouteEndpoint`
  - `FactoryDeepRouteEndpoint/Visual`
  - `FactoryDeepRouteEndpoint/InteractionArea`

Runtime probe evidence:

- Entrance guard cleared through runtime API.
- Deep guard activation:
  - `guard_activated=true`
  - `deep_guard_defeated=true`
- Endpoint activation:
  - first activation: `activated=true`
  - duplicate activation: `duplicate_result=false`
  - `deep_route_cleared=true`
  - `endpoint_activated=true`
- Unlock VFX diagnostics:
  - `has_unlock_vfx_node=true`
  - `active_count=1`
  - `spawn_count=1`
  - `played=true`
  - `duration_sec=0.6`
  - `texture_path="res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png"`
  - `last_spawn.asset_source="image_generation"`
  - `last_spawn.vfx_role="deep_route_unlock"`

MCP logs:

- `logs_read(source="game")` returned only the game helper registration line.
- `logs_read(source="editor")` returned no errors.

Screenshot:

- `reports/visual/cinderpaw-mcp-old-factory-deep-route-unlock-feedback-20260626.png`
- The screenshot is 1280x720 and shows the Old Factory room with the generated
  blue/gold unlock spark visible on the activated deep-route endpoint.

## Verdict

PASS. Story012 replaces the endpoint's weak text/color-only payoff with a
generated texture-backed one-shot VFX, keeps route activation deterministic,
prevents duplicate/replayed feedback, preserves prior Old Factory behavior, and
has focused/related/headless/MCP evidence.
