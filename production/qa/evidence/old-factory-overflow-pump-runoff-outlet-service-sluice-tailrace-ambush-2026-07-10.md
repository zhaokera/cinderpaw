# QA Evidence: Old Factory Overflow Pump Runoff Outlet Service Sluice Tailrace Ambush -- 2026-07-10

## Scope

Story118 adds a short ACT combat pocket after Story117's service-sluice tailrace
traverse. The pocket extends route space, activates a reused frame-animated
Factory Coil Rat after the tailrace is crossed, persists clear state, and keeps
the Story106-117 runoff/service-sluice chain from replaying after restore.

## Automated Evidence

- RED focused: `reports/report_1347/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_test.gd --ignoreHeadlessMode`
  - Result: exit `100`. Expected failure: Story118 tailrace ambush diagnostics
    and activation API did not exist before implementation.
- GREEN focused: `reports/report_1348/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_test.gd --ignoreHeadlessMode`
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1349/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_traverse_test.gd --ignoreHeadlessMode`
  - Result: exit `0`, `12/12` passed.

## Headless Smoke

- Direct runtime smoke:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://tests/smoke/old_factory_service_sluice_tailrace_ambush_smoke.gd > reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_smoke.log 2>&1`
  exited `0`.
- The smoke log contains `service_sluice_tailrace_ambush_smoke=passed`.
- The log contains known Godot shutdown cleanup noise:
  `ObjectDB instances were leaked at exit` and
  `resources still in use at exit`. No Story118 script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load failure was emitted before
  shutdown.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Force-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceCoilRat`.
  - Node type: `CharacterBody2D`; script:
    `res://src/gameplay/factory_coil_rat.gd`; default `visible=false`;
    position `(12920, 482)`.
  - Child `Sprite` type: `AnimatedSprite2D`; script:
    `res://src/characters/factory_coil_rat.gd`; SpriteFrames:
    `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`.
- Running scene check:
  - `project_run.current_run_errors=[]`; helper live and session active.
  - Typed runtime eval reported ready state available and hidden after
    `tailrace_crossed=true`; activation `true`; active `true`; Coil Rat visible
    `true`; target bound `true`; entity id `2143`; family
    `factory_coil_rat`; route label `Clear Tailrace Coil Rat`.
  - SpriteFrames frame counts were `idle=3`, `run=3`, `attack_tell=3`,
    `attack=3`, `hurt=3`, `death=3`.
  - Bounds were right wall x `13200`, camera right `13220`, ground right edge x
    `13300`, and floor tile count `55`.
  - Defeat eval applied damage to entity `2143`, then reported active `false`,
    cleared `true`, Coil Rat visible `false`, physics disabled, route label
    `Tailrace Coil Rat Cleared`, and local activated/defeated/cleared flags
    `true`.
- Logs:
  - Current game run id `r265301023-60` had only the MCP helper registration
    info line and no errors.
  - `logs_read(source="editor", since_cursor=9)` returned no rows after final
    Story118 runtime validation.
  - `project_run` returned retained historical editor parse rows with
    `recent_errors_may_predate_run=true`; focused/related tests, smoke,
    current-run game log, typed runtime eval, and cursor-scoped editor log were
    clean.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    response showing Cinderpaw and the active Tailrace Coil Rat in the extended
    combat pocket.

## Asset Pipeline

No new visual or audio assets were generated. Story118 reuses the existing
image-generated/imported Factory Coil Rat frame-animation asset and the existing
route floor tile:

- `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- `assets/characters/factory_coil_rat/<animation>/`
- `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`
