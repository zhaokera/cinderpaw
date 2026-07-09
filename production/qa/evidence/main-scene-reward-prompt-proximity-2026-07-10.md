# QA Evidence: Main Scene Reward Prompt Proximity -- 2026-07-10

## Scope

Story104 removes far-away reward prompt clutter from MainScene. It changes
`AbilityRewardSource` prompt visibility so generated Double Jump reward visuals
remain in the scene, but `Claim Double Jump` only appears when Cinderpaw is near
the source. This preserves the hidden Double Jump path, Boss2 Double Jump
payoff, room seals, Double Jump gate, save-state, and factory route handoff.

## Automated Evidence

- RED focused: `reports/report_1275/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/boss2_victory_route_handoff_test.gd -a res://tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`, `0/3` passed. Expected failure because reward prompt
    visibility did not yet respect player proximity.
- GREEN focused: `reports/report_1277/`
  - Same command.
  - Result: exit `0`, `3/3` passed.
- Related regression: `reports/report_1278/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/boss2_victory_route_handoff_test.gd -a res://tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd -a res://tests/unit/gameplay/boss2_room_seal_runtime_test.gd -a res://tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `9/9`; Boss2 victory route, Boss2 Double Jump payoff,
    Boss2 room seals, and hidden Double Jump reward coverage passed.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/main.tscn`.
- Runtime checks:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Current game log contains only helper/DataManager info lines.
  - Initial runtime eval:
    - `Boss2EchoGuardian` alive.
    - `HiddenDoubleJumpRewardSource.is_claim_available() == true`.
    - `HiddenDoubleJumpRewardSource.is_provider_in_reward_range(Player) == false`.
    - `HiddenDoubleJumpRewardSource.is_prompt_visible() == false`.
    - `Boss2DoubleJumpRewardSource.is_claim_available() == false`.
    - `Boss2DoubleJumpRewardSource.is_prompt_visible() == false`.
  - Direct runtime reward-source probe at 150px from hidden source:
    - `prompt_radius_px == 192.0`.
    - `claim_radius_px == 104.0`.
    - distance `150.0`.
    - prompt visible `true`.
    - claim range `false`.
- Screenshot:
  `reports/visual/cinderpaw-mcp-main-scene-reward-prompt-proximity-20260710.png`
  is non-empty, `1278x718`, and shows the running Boss2 arena without a
  far-away `Claim Double Jump` prompt over the scene.

## MCP Notes

- The editor log still returns retained Old Factory parse rows whose line
  numbers no longer match `src/gameplay/old_factory_entrance_scene.gd` on disk.
  This was treated as retained MCP/editor log state for Story104 because the
  final run reported `project_run.current_run_errors=[]`, the game helper was
  live, focused and related GdUnit suites passed, and the current game log was
  clean.
- `editor_manage(game_eval)` with `await get_tree().process_frame` did not
  reliably advance MainScene `_process` during the MCP probe, so the near-source
  runtime check called `set_prompt_provider(Player)` directly on the reward
  source after positioning the player. The GdUnit runtime tests cover the
  normal per-frame MainScene refresh path.

## Asset Pipeline

- No new visual asset was generated for Story104.
- Existing generated reward-source textures remain in place:
  - `assets/environment/double_jump_reward/hidden_double_jump_reward_source.png`
  - `assets/environment/double_jump_reward/boss2_double_jump_reward_source.png`

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Far-away reward prompts hidden | `report_1277`; MCP initial eval; screenshot | PASS |
| Near-source reward prompt appears before claim range | `report_1277`; MCP direct probe | PASS |
| Hidden Double Jump reward remains once-only and save-safe | `report_1278` | PASS |
| Boss2 reward remains locked while alive and claimable after defeat | `report_1278` | PASS |
| MainScene current-run logs are clean | MCP `current_run_errors=[]`; game log | PASS |
