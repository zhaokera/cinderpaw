# QA Evidence: Main Scene Gate Prompt Proximity -- 2026-07-10

## Scope

Story105 removes far-away ability gate prompt clutter from MainScene. It changes
`ExplorationGate` prompt visibility so locked/unlockable gates still keep their
state and collision behavior, but `Requires Double Jump`, `Requires Dash`, and
equivalent prompts only appear near the player.

## Automated Evidence

- RED focused: `reports/report_1279/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/exploration_dash_gate_runtime_test.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`. Expected failure: far-away prompt labels were still
    visible and `ExplorationGate` did not expose `is_prompt_visible()`.
- GREEN focused: `reports/report_1280/`
  - Same command.
  - Result: exit `0`, `5/5` passed.
- Related regression: `reports/report_1281/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/exploration_dash_gate_runtime_test.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd -a res://tests/unit/gameplay/exploration_gate_unlock_feedback_test.gd -a res://tests/unit/gameplay/main_scene_dash_gate_authored_visual_test.gd -a res://tests/unit/gameplay/player_parry_laser_gate_runtime_test.gd -a res://tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `18/18`; Dash, Double Jump, unlock feedback, authored Dash
    visual, Parry gate, and Factory Route shell coverage passed.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/main.tscn`.
- Runtime checks:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Current game log contains only helper/DataManager info lines.
  - Initial runtime eval:
    - `DashExplorationGate.get_prompt_text() == "Requires Dash"`.
    - `DashExplorationGate.is_prompt_visible() == false`.
    - `DashExplorationGate.is_provider_in_prompt_range() == false`.
    - `DashExplorationGate.is_provider_in_unlock_range() == false`.
    - `DoubleJumpExplorationGate.get_prompt_text() == "Requires Double Jump"`.
    - `DoubleJumpExplorationGate.is_prompt_visible() == false`.
    - `DoubleJumpExplorationGate.is_provider_in_prompt_range() == false`.
    - `DoubleJumpExplorationGate.is_provider_in_unlock_range() == false`.
    - `ParryLaserExplorationGate.is_prompt_visible() == false`.
- Screenshot:
  `reports/visual/cinderpaw-mcp-main-scene-gate-prompt-proximity-20260710.png`
  is non-empty, `1278x718`, and shows the running Boss2 arena without far-away
  `Requires Double Jump` or `Requires Dash` prompt clutter.

## MCP Notes

- The editor log still returns retained Old Factory parse rows whose line
  numbers no longer match `src/gameplay/old_factory_entrance_scene.gd` on disk.
  Story105 acceptance uses `project_run.current_run_errors=[]`, clean current
  game log, focused/related GdUnit passes, and successful runtime
  gate-diagnostic/screenshot probes.

## Asset Pipeline

- No new visual asset was generated for Story105.
- Existing generated ability gate visuals remain in place, including the
  authored Dash gate marker and unlock feedback VFX.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Far-away gate prompts hidden | `report_1280`; MCP eval; screenshot | PASS |
| Near but not unlock-range gate prompts visible | `report_1280` | PASS |
| Dash/DoubleJump/Parry unlock behavior intact | `report_1281` | PASS |
| Unlock feedback and authored gate visuals intact | `report_1281` | PASS |
| MainScene current-run logs are clean | MCP `current_run_errors=[]`; game log | PASS |
