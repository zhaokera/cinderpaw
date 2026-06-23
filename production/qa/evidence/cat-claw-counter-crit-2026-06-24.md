# Cat Claw Counter Crit Evidence — 2026-06-24

## Scope

- Story: `production/epics/weapon-styles/story-005-cat-claw-dodge-counter-crit-bonus.md`
- Requirement: `TR-weapon-005`
- Code paths:
  - `src/core/combat_component.gd`
  - `src/core/weapon_component.gd`
  - `src/foundation/damage_calculator.gd`
- Test path: `tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd`

## Automated Test Evidence

- RED: `reports/report_325/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd --ignoreHeadlessMode`
  - Result: expected failure before implementation; cat-claw hit did not inject `crit_window_bonus=3` or consume the counter window.
- GREEN: `reports/report_326/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd --ignoreHeadlessMode`
  - Result: 4/4 passing.
- Focused regression: `reports/report_327/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_001_weapon_config_catalog_test.gd -a res://tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd -a res://tests/unit/weapon/story_003_weapon_swap_state_machine_test.gd -a res://tests/unit/weapon/story_004_special_attack_gates_test.gd -a res://tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd -a res://tests/unit/combat/story_007_hit_confirmation_focus_damage_metadata_test.gd -a res://tests/unit/damage/story_003_special_modifiers_test.gd -a res://tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd --ignoreHeadlessMode`
  - Result: 37/37 passing.

## Runtime Evidence

- Headless startup:
  - Command: `godot --headless --path . --quit-after 1`
  - Result: exit code 0; DataManager loaded manifest, damage params, weapon configs, and tuning knobs.
- Godot MCP runtime:
  - Session: `cinderpaw@c4d7`
  - Godot: 4.6.3 stable
  - Main scene: `res://scenes/main.tscn`
  - Screenshot: `reports/visual/cinderpaw-mcp-cat-claw-counter-runtime-20260624.png`
  - `game_eval` result:
    - Cat Claw dodge opened `cat_window_opened=30`
    - qualifying light hit emitted `cat_bonus=3` and `cat_modifier=3`
    - counter window consumed after hit: `cat_window_after_hit=0`
    - Long Tail weapon sync succeeded: `combat_weapon_after_deserialize=long_tail`
    - Long Tail dodge did not open counter window: `long_tail_window_opened=0`
    - Long Tail hit emitted `long_tail_bonus=0` and `long_tail_modifier=0`

## Acceptance Criteria Mapping

- Cat Claw dodge completion opens a 0.5 second counter window: covered by `test_cat_claw_dodge_completion_opens_half_second_counter_window` and MCP runtime.
- Qualifying hit during that window calls combat crit-window bonus +3: covered by `test_qualifying_cat_claw_hit_injects_bonus_and_consumes_counter_window` and MCP runtime.
- Bonus is consumed by the next qualifying hit: covered by `test_qualifying_cat_claw_hit_injects_bonus_and_consumes_counter_window` and MCP runtime.
- Non-Cat-Claw weapons do not open the bonus: covered by `test_non_cat_claw_weapon_does_not_open_counter_bonus` and MCP runtime.

## Notes

- This story verifies the Core weapon/combat/damage path. The current playable main scene still uses the prototype `PlayerController` attack chain for direct enemy damage; full player attack wiring into Core Combat remains future gameplay integration work.
