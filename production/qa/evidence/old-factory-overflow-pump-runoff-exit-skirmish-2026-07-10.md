# QA Evidence: Old Factory Overflow Pump Runoff Exit Skirmish -- 2026-07-10

## Scope

Story108 extends the Old Factory route after Story107 crosses the overflow pump
runoff duct. The slice adds a new runoff-exit Coil Rat skirmish using the
existing multi-frame Factory Coil Rat animation set and extends the playable
route to the next combat pocket.

## Automated Evidence

- RED focused: `reports/report_1289/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`. Expected failure: Story108 activation API,
    diagnostics, scene node, state persistence, and animation-contract checks
    failed before implementation.
- GREEN focused: `reports/report_1291/`
  - Same command.
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1292/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_route_floor_platform_visual_pass_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `11/11` passed.

## Headless Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --quit-after 3 > reports/old_factory_overflow_pump_runoff_exit_skirmish_smoke.log 2>&1`
- Result: exit `0`.
- Keyword scan found no Story108 `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
  `Invalid access`, missing-resource, or resource-load errors.
- Godot still reports known shutdown ObjectDB/resource cleanup noise in the log;
  no Story108 script or resource path appears in that shutdown cleanup noise.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Session: `cinderpaw@1014`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitCoilRat`.
  - Target node path:
    `/FactoryRouteTransitionShellScene/FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitCoilRat`.
  - Target node starts hidden at `position=Vector2(7908, 482)`, `z_index=20`,
    and uses script `res://src/gameplay/factory_coil_rat.gd`.
  - `RightWall.position.x == 8300`.
  - `Player/Camera2D.limit_right == 8320`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Runtime tree contained the target Coil Rat and child `Sprite`.
  - Runtime `Sprite` type is `AnimatedSprite2D`, current animation `idle`.
  - Runtime `Sprite.sprite_frames` is
    `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`.
  - Runtime far-right floor tile `FactoryRouteFloorVisual35` loaded texture
    `res://assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`.
  - Current game log contains only `[godot_ai game_helper] registered mcp capture`.
  - `logs_read(source="editor", since_cursor=9)` returned no current-run editor
    errors.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    response.

## MCP Notes

- `project_run` still returned retained historical Old Factory parse rows under
  `recent_errors_may_predate_run=true`; the current launch had
  `current_run_errors=[]`, helper live, clean current game log, and an empty
  editor logger read from the current-run cursor.
- The available MCP runtime inspection surface did not expose arbitrary
  GDScript eval in `game_manage`. Story108 activation/defeat/persistence
  behavior is therefore covered by focused GdUnit, while MCP covers scene
  reload, runtime tree, animation node/resource binding, route bounds, logs, and
  screenshot.

## Asset Pipeline

- No new visual asset was generated for Story108.
- The Coil Rat reuses the existing imported image-generated Factory Coil Rat
  SpriteFrames resource and transparent PNG frame folders.
- The route extension reuses the existing imported image-generated floor tile
  PNG.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Locked until runoff duct crossed | `report_1291` | PASS |
| Activation at x `7800` shows Coil Rat and sets target | `report_1291` | PASS |
| Route extends to x `8320` camera/right wall bounds | `report_1291`; MCP properties | PASS |
| Coil Rat uses AnimatedSprite2D + SpriteFrames | `report_1291`; MCP runtime node info | PASS |
| Required animations have at least 3 frames | `report_1291` | PASS |
| Pacing begins in `opening_grace` with 10 frames | `report_1291` | PASS |
| Defeat persists cleared state and backfills upstream chain | `report_1291`; `report_1292` | PASS |
| Runtime scene loads with target nodes and logs clean | MCP scene/runtime tree, logs, screenshot | PASS |

## Verdict

PASS. Story108 converts the Story107 runoff duct handoff into a visible,
multi-frame Coil Rat ACT skirmish and extends the route using imported
image-generated assets instead of placeholder blocks.
