# QA Evidence: Old Factory Overflow Pump Runoff Outlet Service Sluice Skirmish -- 2026-07-10

## Scope

Story114 adds a service-sluice follow-up combat pocket after Story113: a reused
Factory Spark Rat, route bounds extension, ground-coverage hardening, objective
feedback, and save-state backfill.

## Automated Evidence

- RED focused: `reports/report_1330/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_test.gd --ignoreHeadlessMode -rd res://reports/report_1330`
  - Result: exit `100`. Expected failure: Story114 diagnostics/API/scene node
    did not exist before implementation.
- Initial GREEN focused: `reports/report_1331/`
  - Result: exit `0`, `2/2` passed before MCP uncovered the far-right ground
    collision gap.
- Initial related regression: `reports/report_1332/`
  - Result: exit `0`, `12/12` passed across Story109-114 before the
    ground-coverage diagnostic was added.
- Parse cleanup RED: `reports/report_1333/`
  - Result: exit `100`. Expected transient failure while fixing a duplicate
    local variable in the new ground-coverage diagnostic.
- Final GREEN focused: `reports/report_1334/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_test.gd --ignoreHeadlessMode -rd res://reports/report_1334`
  - Result: exit `0`, `2/2` passed.
- Final related regression: `reports/report_1335/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports/report_1335`
  - Result: exit `0`, `12/12` passed.

## Headless Smoke

- Direct scene smoke:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . res://scenes/factory_route_transition_shell.tscn --quit-after 3 > reports/old_factory_overflow_pump_runoff_outlet_service_sluice_skirmish_smoke.log 2>&1`
  exited `0`.
- The log contains Godot shutdown cleanup noise:
  `ObjectDB instances were leaked at exit` and
  `resources still in use at exit`. No Story114 script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load failure was emitted before
  shutdown.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceSparkRat`.
  - Node type: `CharacterBody2D`.
  - Script: `res://src/gameplay/factory_spark_rat.gd`.
  - Position: `Vector2(11120, 482)`.
  - Initial state: `visible=false`.
  - Right wall x: `11500`.
  - Camera limit right: `11520`.
  - Background width: `11520`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Runtime ready diagnostics reported `available=true`, Spark Rat hidden, no
    processing/physics, and route label `Runoff Outlet Service Sluice Crossed`.
  - Runtime activation at/after x `10920` returned `true`.
  - Active diagnostics reported Spark Rat visible, target assigned, process and
    physics enabled, entity id `2142`, family `factory_spark_rat`, position
    `Vector2(11120, 482)`, opening grace `12`, ground width `17000`,
    ground right edge x `11700`, and route label
    `Clear Service Sluice Spark Rat`.
  - SpriteFrames path:
    `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
  - Animation frame counts: `idle=3`, `run=3`, `attack_tell=3`, `attack=3`,
    `hurt=3`, `death=3`.
  - Runtime defeat via `apply_damage(2142, 999, ...)` returned `true`, hid and
    disabled the enemy, kept the enemy at the supported route height, persisted
    activated/defeated/cleared flags, backfilled service-sluice crossed state,
    and advanced route label to `Service Sluice Spark Rat Cleared`.
- Logs:
  - Current game run id `r259159222-54` had only the MCP helper registration
    info line and no errors.
  - `logs_read(source="editor", since_cursor=9)` returned no rows after final
    Story114 runtime validation.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    response showing Cinderpaw, the service sluice landing, the steam vent, and
    the active Spark Rat. This validates a visible frame-animated enemy, not a
    placeholder square.

## Asset Pipeline

No new visual or audio assets were generated. Story114 reuses the imported
image-generated Factory Spark Rat frame-animation package:

- SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Runtime frame folders:
  `assets/characters/factory_spark_rat/idle/`,
  `assets/characters/factory_spark_rat/run/`,
  `assets/characters/factory_spark_rat/attack_tell/`,
  `assets/characters/factory_spark_rat/attack/`,
  `assets/characters/factory_spark_rat/hurt/`,
  `assets/characters/factory_spark_rat/death/`

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Locked until service sluice crossed | `report_1334` | PASS |
| Spark Rat node exists, hidden/inactive before activation | `report_1334`; MCP static/runtime checks | PASS |
| Activation x 10920 enables entity 2142 and route label | `report_1334`; MCP runtime eval | PASS |
| SpriteFrames path and 3-frame animation counts | `report_1334`; MCP runtime eval | PASS |
| Right wall/camera/background/ground support through new pocket | `report_1334`; MCP static/runtime checks | PASS |
| Defeat persists activated/defeated/cleared state | `report_1334`; MCP runtime eval | PASS |
| Restore backfills Story106-113 route chain | `report_1334`; `report_1335` | PASS |
| Runtime scene loads, logs clean, screenshot non-empty | Headless smoke; MCP run + screenshot | PASS |

## Verdict

PASS. Story114 adds a playable service sluice Spark Rat skirmish with real
`AnimatedSprite2D + SpriteFrames` character animation, extends route collision
support for the new combat pocket, and passes focused, related, headless, and
MCP runtime validation.
