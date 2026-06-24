# Fish Bone Shield Break Evidence - 2026-06-24

## Scope

- Story: `production/epics/weapon-styles/story-007-fish-bone-charged-shield-break.md`
- Requirement: `TR-weapon-007`
- Code paths:
  - `src/core/weapon_component.gd`
  - `src/core/health_component.gd`
- Test path: `tests/unit/weapon/story_007_fish_bone_shield_break_test.gd`

## Automated Test Evidence

- RED: `reports/report_332/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_007_fish_bone_shield_break_test.gd --ignoreHeadlessMode`
  - Result: expected failure before implementation; `HealthComponent` did not expose `break_shield()` and `WeaponComponent` did not expose `apply_confirmed_hit_effects()`.
- GREEN: `reports/report_333/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_007_fish_bone_shield_break_test.gd --ignoreHeadlessMode`
  - Result: 3/3 passing.
- Focused regression: `reports/report_334/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_001_weapon_config_catalog_test.gd -a res://tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd -a res://tests/unit/weapon/story_003_weapon_swap_state_machine_test.gd -a res://tests/unit/weapon/story_004_special_attack_gates_test.gd -a res://tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd -a res://tests/unit/weapon/story_006_long_tail_multi_target_test.gd -a res://tests/unit/weapon/story_007_fish_bone_shield_break_test.gd -a res://tests/unit/health/story_001_hp_damage_pipeline_test.gd -a res://tests/unit/combat/story_005_heavy_charge_hit_stun_aerial_hooks_test.gd -a res://tests/unit/collision/story_004_multi_target_hits_duplicate_suppression_test.gd -a res://tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd --ignoreHeadlessMode`
  - Result: 50/50 passing.

## Runtime Evidence

- Headless startup:
  - Command: `godot --headless --path . --quit-after 1`
  - Result: exit code 0; DataManager loaded manifest, weapon configs, damage params, tuning knobs, and MCP helper.
- Godot MCP runtime:
  - Session: `cinderpaw@c4d7`
  - Godot: 4.6.3 stable
  - Main scene: `res://scenes/main.tscn`
  - Screenshot: `reports/visual/cinderpaw-mcp-fish-bone-shield-break-runtime-20260624.png`
  - `game_eval` result:
    - runtime weapon was `fish_bone`
    - full-charge metadata returned `charge_ratio=1.0`
    - full-charge hit returned `shield_break_attempted=true`
    - full-charge hit returned `shield_broken=true`
    - full-charge shield changed from 35 to 0
    - partial-charge metadata returned `charge_ratio=0.5`
    - partial-charge hit returned `shield_break_attempted=false`
    - partial-charge shield remained 35
    - target without `break_shield()` preserved `final_damage=17` and returned `missing_break_shield`
    - runtime HUD label showed `鱼骨大剑`

## Acceptance Criteria Mapping

- Fish Bone full-charge hits call target `break_shield()`: covered by `test_full_charge_fish_bone_hit_breaks_target_shield` and MCP runtime.
- Partial-charge hits do not break shields: covered by `test_partial_charge_fish_bone_hit_does_not_break_target_shield` and MCP runtime.
- Missing shield APIs degrade to normal hit metadata without errors: covered by `test_missing_shield_api_degrades_to_normal_hit_metadata` and MCP runtime.

## Notes

- This story completes the Core weapon-to-health shield-break contract. The current playable main scene still uses the prototype `PlayerController` attack chain for direct enemy damage; full player attack wiring into Core Combat/Collision/Health remains future gameplay integration work.
