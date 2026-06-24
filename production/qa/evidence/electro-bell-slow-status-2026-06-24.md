# Electro Bell Slow Status Evidence - 2026-06-24

## Scope

- Story: `production/epics/weapon-styles/story-008-electro-bell-slow-status-application.md`
- Requirement: `TR-weapon-006`
- Code paths:
  - `src/core/weapon_component.gd`
  - `src/core/status_effect_component.gd`
- Test path: `tests/unit/weapon/story_008_electro_bell_slow_test.gd`

## Automated Test Evidence

- RED: `reports/report_337/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_008_electro_bell_slow_test.gd --ignoreHeadlessMode`
  - Result: expected failure before implementation; Electro Bell hit effects did not apply slow status or return slow metadata.
- GREEN: `reports/report_338/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_008_electro_bell_slow_test.gd --ignoreHeadlessMode`
  - Result: 4/4 passing.
- Focused regression: `reports/report_340/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_001_weapon_config_catalog_test.gd -a res://tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd -a res://tests/unit/weapon/story_003_weapon_swap_state_machine_test.gd -a res://tests/unit/weapon/story_004_special_attack_gates_test.gd -a res://tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd -a res://tests/unit/weapon/story_006_long_tail_multi_target_test.gd -a res://tests/unit/weapon/story_007_fish_bone_shield_break_test.gd -a res://tests/unit/weapon/story_008_electro_bell_slow_test.gd -a res://tests/unit/status/story_001_status_effect_catalog_test.gd -a res://tests/unit/status/story_002_status_application_immunity_test.gd -a res://tests/unit/status/story_003_status_duration_tick_modifiers_test.gd -a res://tests/unit/status/story_004_status_iframe_immunity_test.gd -a res://tests/unit/status/story_005_status_priority_capacity_test.gd -a res://tests/unit/status/story_006_status_cleanup_hooks_test.gd -a res://tests/unit/health/story_001_hp_damage_pipeline_test.gd -a res://tests/unit/combat/story_005_heavy_charge_hit_stun_aerial_hooks_test.gd -a res://tests/unit/collision/story_004_multi_target_hits_duplicate_suppression_test.gd -a res://tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd --ignoreHeadlessMode`
  - Result: 80/80 passing.

## Runtime Evidence

- Headless startup:
  - Command: `godot --headless --path . --quit-after 1`
  - Result: exit code 0; DataManager loaded manifest, weapon configs, damage params, tuning knobs, and MCP helper.
- Headless main scene smoke:
  - Command: `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/weapon_story008_main_scene_smoke.log`
  - Result: exit code 0; follow-up log scan found no error/warning matches.
- Godot MCP runtime:
  - Server: Godot AI 3.4.2 over `http://127.0.0.1:8000/mcp`
  - Session: `cinderpaw@c4d7`
  - Godot: 4.6.3 stable
  - Main scene: `res://scenes/main.tscn`
  - Screenshot: `reports/visual/cinderpaw-mcp-electro-bell-slow-runtime-20260624.png`
  - `game_eval` result:
    - runtime scene was `Main`
    - runtime weapon was `electro_bell`
    - status effect id was `slow`
    - first hit returned `slow_status_applied=true`
    - first hit returned `slow_duration_sec=2.0`
    - first hit returned `slow_percentage=0.3`
    - target movement modifier became `0.7`
    - after 1.1 seconds, remaining slow duration was `0.9`
    - repeated hit returned `slow_status_applied=true`
    - repeated hit kept one active effect and refreshed remaining duration to `2.0`
    - target without `apply_status()` preserved `final_damage=11` and returned `missing_apply_status`
  - Game log after runtime validation contained only MCP helper and DataManager info lines.

## Acceptance Criteria Mapping

- Electro Bell hits call `apply_status(target_id, slow, source_id)`: covered by `test_electro_bell_hit_applies_slow_status_to_target` and MCP runtime.
- Slow metadata remains 2 seconds and -30% movement: covered by `test_electro_bell_slow_metadata_matches_gdd_values` and MCP runtime.
- Repeated Electro Bell hits refresh slow through StatusEffectComponent: covered by `test_repeated_electro_bell_hits_refresh_slow_without_duplicate_effects` and MCP runtime.
- Missing status APIs degrade without errors: covered by `test_missing_status_api_preserves_hit_metadata_without_error` and MCP runtime.

## Notes

- This story completes the Core weapon-to-status slow contract. The current playable main scene still uses the prototype `PlayerController` attack chain for direct enemy damage; full player attack wiring into Core Combat/Collision/Health/Weapon callbacks remains future gameplay integration work.
