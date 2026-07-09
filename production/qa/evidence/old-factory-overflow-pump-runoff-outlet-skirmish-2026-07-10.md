# QA Evidence: Old Factory Overflow Pump Runoff Outlet Skirmish -- 2026-07-10

## Scope

Story111 adds a Spark Rat combat pocket after Story110 crosses the overflow
pump runoff outlet. The slice reuses the existing animated Factory Spark Rat
asset and validates that the visible enemy is a real multi-frame character, not
a placeholder block or single-frame sprite.

## Automated Evidence

- RED focused: `reports/report_1300/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`. Expected failure: Story111 diagnostics and activation
    APIs did not exist before implementation.
- GREEN focused: `reports/report_1309/`
  - Same command.
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1310/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `8/8` passed.

## Headless Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --quit-after 3 > reports/old_factory_overflow_pump_runoff_outlet_skirmish_smoke.log 2>&1`
- Result: exit `0`.
- Final log contains engine startup, DataManager domain loads, and MCP helper
  registration; no Story111 script, parse, invalid-call/access,
  missing-resource, or resource-load errors were emitted.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletSparkRat`.
  - Node type: `CharacterBody2D`.
  - Node script: `res://src/gameplay/factory_spark_rat.gd`.
  - Node position: `Vector2(9340, 482)`, initially `visible=false`.
  - Child `Sprite` type: `AnimatedSprite2D`.
  - Sprite script: `res://src/characters/factory_spark_rat.gd`.
  - SpriteFrames:
    `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
  - Right wall x `9580`, camera limit right `9600`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Runtime eval confirmed Story111 diagnostics and activation APIs exist.
  - Runtime activation from restored Story110 crossed state returned `true`.
  - Runtime diagnostics after activation:
    `active=true`, `spark_visible=true`, `spark_has_target=true`,
    `spark_process_enabled=true`, `spark_physics_enabled=true`,
    `spark_entity_id=2141`, `spark_family_id=factory_spark_rat`,
    `route_label_text=Clear Runoff Outlet Spark Rat`.
  - Runtime animation frame counts:
    `idle=3`, `run=3`, `attack_tell=3`, `attack=3`, `hurt=3`, `death=3`.
  - Runtime pacing: `opening_grace_frames=12`,
    `opening_grace_total_frames=12`, `attack_startup_frames=12`.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    response showing the target pocket and visible Spark Rat.

## MCP Notes

- MCP `project_run` continued to include retained historical parse rows under
  `recent_errors_may_predate_run=true`; they came from pre-green work and were
  not current-run failures. The current launch had `current_run_errors=[]`,
  helper live, successful runtime eval calls against the Story111 APIs, and a
  successful game screenshot.
- One transient MCP `game_eval` attempt used untyped temporary eval variables
  and hit the project warning-as-error policy. The game was stopped, MCP logs
  were cleared, the scene was relaunched, and the typed eval validation passed.

## Asset Pipeline

- No new visual asset was generated for Story111.
- The slice reuses the existing imported Factory Spark Rat frame animation.
- The reused character follows the frame-animation rule:
  `AnimatedSprite2D + SpriteFrames`, transparent PNG frame folders under
  `assets/characters/factory_spark_rat/<animation>/`, and at least `3` frames
  per visible gameplay animation checked by automated diagnostics.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Locked until Story110 outlet crossed | `report_1309` | PASS |
| Activation x 9280 starts skirmish | `report_1309`; MCP runtime eval | PASS |
| Spark Rat scene node exists and stays within route bounds | MCP static scene check | PASS |
| AnimatedSprite2D/SpriteFrames frame contract | `report_1309`; MCP runtime eval | PASS |
| Defeat persists and hides/disables enemy | `report_1309` | PASS |
| Restore backfills Story106-110 chain | `report_1309`; `report_1310` | PASS |
| Runtime scene loads and screenshot is non-empty | MCP run + screenshot | PASS |

## Verdict

PASS. Story111 adds a playable animated Spark Rat skirmish after the overflow
pump runoff outlet without adding placeholder blocks, single-frame characters,
or new art churn.
