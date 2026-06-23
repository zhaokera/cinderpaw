# Long Tail Multi-Target Evidence - 2026-06-24

## Scope

- Story: `production/epics/weapon-styles/story-006-long-tail-multi-target-range-contract.md`
- Requirement: `TR-weapon-001`
- Code paths:
  - `src/core/weapon_component.gd`
  - `src/core/collision_component.gd`
- Test path: `tests/unit/weapon/story_006_long_tail_multi_target_test.gd`

## Automated Test Evidence

- RED: `reports/report_328/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_006_long_tail_multi_target_test.gd --ignoreHeadlessMode`
  - Result: expected failure before implementation; `WeaponComponent` did not expose the collision adapter or current-attack hitbox activation API.
- GREEN: `reports/report_329/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_006_long_tail_multi_target_test.gd --ignoreHeadlessMode`
  - Result: 3/3 passing.
- Focused regression: `reports/report_330/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_001_weapon_config_catalog_test.gd -a res://tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd -a res://tests/unit/weapon/story_003_weapon_swap_state_machine_test.gd -a res://tests/unit/weapon/story_004_special_attack_gates_test.gd -a res://tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd -a res://tests/unit/weapon/story_006_long_tail_multi_target_test.gd -a res://tests/unit/collision/story_004_multi_target_hits_duplicate_suppression_test.gd -a res://tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd --ignoreHeadlessMode`
  - Result: 33/33 passing.
- Final verification: `reports/report_331/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_001_weapon_config_catalog_test.gd -a res://tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd -a res://tests/unit/weapon/story_003_weapon_swap_state_machine_test.gd -a res://tests/unit/weapon/story_004_special_attack_gates_test.gd -a res://tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd -a res://tests/unit/weapon/story_006_long_tail_multi_target_test.gd -a res://tests/unit/collision/story_004_multi_target_hits_duplicate_suppression_test.gd -a res://tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd --ignoreHeadlessMode`
  - Result: 33/33 passing.

## Runtime Evidence

- Headless startup:
  - Command: `godot --headless --path . --quit-after 1`
  - Result: exit code 0; DataManager loaded manifest, domains, and MCP helper registered.
- Godot MCP runtime:
  - Session: `cinderpaw@c4d7`
  - Godot: 4.6.3 stable
  - Main scene: `res://scenes/main.tscn`
  - Screenshot: `reports/visual/cinderpaw-mcp-long-tail-multi-target-runtime-20260624.png`
  - `game_eval` result:
    - Long Tail hitbox activation returned `activated=true`
    - hitbox metadata returned `weapon_id=long_tail`
    - metadata returned `multi_target=true`
    - metadata returned `targeting_type=multi_target`
    - metadata returned `max_targets=5`
    - metadata returned `attack_range=2.0`
    - first detection frame emitted three hit events for target IDs `201`, `202`, and `203`
    - second detection frame against target `201` emitted no duplicate hit
    - runtime HUD label showed `长尾刃`

## Acceptance Criteria Mapping

- Long Tail attack parameters expose 2.0 tile range and multi-target type: covered by `test_long_tail_attack_parameters_expose_two_tile_multi_target_contract` and MCP runtime metadata.
- Hitbox metadata marks the attack as multi-target with a bounded max target count: covered by `test_long_tail_hitbox_metadata_marks_multi_target_and_keeps_collision_duplicate_tracking` and MCP runtime metadata.
- WeaponComponent does not bypass CollisionComponent duplicate-hit tracking: covered by the same story test, `tests/unit/collision/story_004_multi_target_hits_duplicate_suppression_test.gd`, and MCP runtime duplicate-frame check.

## Notes

- This story completes the Core weapon-to-collision contract. The current playable main scene still uses the prototype `PlayerController` attack chain for direct enemy damage; full player attack wiring into Core Combat/Collision should be handled as a future gameplay integration story.
