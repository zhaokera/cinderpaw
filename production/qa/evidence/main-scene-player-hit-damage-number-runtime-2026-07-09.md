# QA Evidence: Main Scene Player Hit Damage Number Runtime -- 2026-07-09

## Scope

Story101 verifies that a real player hit in `scenes/main.tscn` produces a
visible `CombatPresentation` damage number whose text matches the calculated
`final_damage`. This is an integration and visual-feedback closure over the
existing damage-number renderer; no new bitmap assets were generated.

## Automated Evidence

- RED focused: `reports/report_1257/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`, `0/4` passed. Expected failure because
    `CombatPresentation.get_last_damage_number_snapshot()` did not exist yet.
- GREEN focused: `reports/report_1258/`
  - Same command.
  - Result: exit `0`, `4/4` passed.
- Final focused after readability shadow and final formatting: `reports/report_1262/`
  - Same command.
  - Result: exit `0`, `4/4` passed. This is the final focused evidence for
    the submitted code state.
- Related regression: `reports/report_1261/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `38/38`; player-hit integration, enemy-hit integration,
    and presentation damage-number coverage passed.

## Headless Runtime Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/main_scene_damage_number_runtime_smoke.log`
- Result: exit `0`.
- Log scan:
  `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Invalid access|Node not found|Failed loading resource|ERROR: Failed|Resource file not found|shadowed" reports/main_scene_damage_number_runtime_smoke.log`
- Result: no project script/parse/invalid-call/access/missing-resource/resource
  load errors found.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/main.tscn`.
- Runtime checks:
  - `Player`, `Enemy`, `HUD`, and `CombatPresentation` exist.
  - A simulated player light attack hit reduces Enemy HP.
  - `CombatPresentation.get_active_damage_number_count()` changes from `0` to
    `1`.
  - `CombatPresentation.get_last_damage_number_snapshot()` returns a visible
    Label snapshot whose text equals the hit `final_damage`, z index is `90`,
    shadow color is black with alpha `0.82`, shadow offset is `(1, 1)`, float
    distance is `30.0`, and lifetime is `1.5`.
  - After advancing the presentation clock beyond the lifetime, active damage
    number count returns to `0`.
  - `project_run.current_run_errors=[]`.
  - Current game log contains only helper/DataManager info lines.
  - The editor Debugger still retained old Factory parse rows for helper names
    no longer present in the current file; local `rg` confirmed those stale
    symbol names are absent and headless parsing/tests passed.
- Screenshot:
  `reports/visual/cinderpaw-mcp-main-scene-damage-number-runtime-20260709.png`
  is non-empty, `1278x718`, and captures the main scene after the runtime hit
  probe.

## Asset Pipeline

- New image-generation assets: none.
- Rationale: damage numbers are text Labels styled and animated by
  `CombatPresentation`, not bitmap character or environment art.
- Inventory update: `design/assets/entity-inventory.md` now marks Damage Numbers
  as implemented baseline with Story008 + Story101 sources.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Player light attack creates one damage number | `reports/report_1262/`; MCP probe | PASS |
| Text equals hit `final_damage` | `reports/report_1262/`; MCP probe | PASS |
| Duplicate detection does not duplicate damage or numbers | `reports/report_1262/` | PASS |
| Damage number has visible Label diagnostics, z index, shadow, float distance, lifetime | `reports/report_1262/`; MCP probe | PASS |
| Presentation and enemy-hit regressions remain green | `reports/report_1261/` | PASS |
| Headless and MCP runtime logs are clean | Headless smoke; MCP logs | PASS |
