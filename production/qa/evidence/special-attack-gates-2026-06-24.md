# Special Attack Gates Evidence — 2026-06-24

## Scope

- Story: `production/epics/weapon-styles/story-004-special-attack-cooldown-cat-energy-gate.md`
- Requirement: `TR-weapon-003`
- Code path: `src/core/weapon_component.gd`
- Test path: `tests/unit/weapon/story_004_special_attack_gates_test.gd`

## Automated Test Evidence

- RED: `reports/report_320/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_004_special_attack_gates_test.gd --ignoreHeadlessMode`
  - Result: expected failure before implementation; missing special attack API/signals.
- GREEN: `reports/report_321/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_004_special_attack_gates_test.gd --ignoreHeadlessMode`
  - Result: 4/4 passing.
- Focused regression: `reports/report_323/`
  - Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/weapon/story_001_weapon_config_catalog_test.gd -a res://tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd -a res://tests/unit/weapon/story_003_weapon_swap_state_machine_test.gd -a res://tests/unit/weapon/story_004_special_attack_gates_test.gd -a res://tests/unit/combat/story_006_cat_energy_special_ultimate_gates_test.gd -a res://tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd --ignoreHeadlessMode`
  - Result: 28/28 passing.

## Runtime Evidence

- Headless startup:
  - Command: `godot --headless --path . --quit-after 1`
  - Result: exit code 0; DataManager loaded manifest and weapon configs.
- Godot MCP runtime:
  - Session: `cinderpaw@c4d7`
  - Godot: 4.6.3 stable
  - Main scene: `res://scenes/main.tscn`
  - Screenshot: `reports/visual/cinderpaw-mcp-special-gate-runtime-20260624.png`
  - `game_eval` result:
    - insufficient cat energy: `request_special_attack()` returned `false`, emitted `[30]`
    - enough cat energy: `request_special_attack()` returned `true`, emitted `["gale_claw"]`
    - active cooldown: `request_special_attack()` returned `false`, emitted `[8]`
    - remaining cooldown: `8`
    - cat energy after successful special: `70`
    - exposed params: `attack_id=gale_claw`, `cooldown_sec=8`, `required_energy=30`

## Acceptance Criteria Mapping

- Each weapon exposes GDD special id and cooldown: covered by `test_each_weapon_exposes_special_id_cooldown_and_energy_cost`.
- Insufficient cat energy rejects special and emits insufficient signal: covered by `test_insufficient_cat_energy_rejects_special_and_emits_required_energy` and MCP runtime.
- Active cooldown rejects special and emits remaining cooldown: covered by `test_active_cooldown_rejects_special_and_emits_remaining_cooldown` and MCP runtime.
- Passing gates consumes cat energy through combat adapter: covered by `test_passing_gates_consumes_cat_energy_starts_cooldown_and_emits_start_signal` and MCP runtime.
- Passing gates emits `on_special_attack_started(attack_id)`: covered by automated test and MCP runtime.
