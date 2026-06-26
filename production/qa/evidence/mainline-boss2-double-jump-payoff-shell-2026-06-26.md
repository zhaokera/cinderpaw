# QA Evidence: Mainline Boss2 Double Jump Payoff Shell

Date: 2026-06-26

Story:
`production/epics/player-abilities/story-021-mainline-boss2-double-jump-payoff-shell.md`

## Scope

This slice adds a visible mainline Boss2 payoff for the Double Jump route.
`res://scenes/main.tscn` now contains `Boss2EchoGuardian` with generated
character frame animation, plus `Boss2DoubleJumpRewardSource` as a generated
reward prop. Defeating Boss2 reveals the reward, claiming it unlocks
`double_jump`, and Cinderpaw can immediately use Double Jump to open the
existing high-platform ExplorationGate.

This is intentionally a shell: it proves the route, reward, save state, and
frame-animation contract without claiming final Boss2 arena design or full boss
AI.

## Asset Pipeline

Generated through image generation:

- Boss2 source sprite sheet:
  `assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_sprite_sheet_imagegen_20260626.png`
- Boss2 alpha source:
  `assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_sprite_sheet_alpha_20260626.png`
- Boss2 runtime frames:
  `assets/characters/boss2_echo_guardian/idle/boss2_echo_guardian_idle_000.png`
  through `_002.png`
- Boss2 runtime frames:
  `assets/characters/boss2_echo_guardian/attack/boss2_echo_guardian_attack_000.png`
  through `_002.png`
- Boss2 runtime frames:
  `assets/characters/boss2_echo_guardian/hurt/boss2_echo_guardian_hurt_000.png`
  through `_002.png`
- Boss2 runtime frames:
  `assets/characters/boss2_echo_guardian/death/boss2_echo_guardian_death_000.png`
  through `_002.png`
- Boss2 SpriteFrames:
  `assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres`
- Boss2 reward source:
  `assets/generated/source/boss2_double_jump_reward_source_imagegen_20260626.png`
- Boss2 reward alpha source:
  `assets/generated/source/boss2_double_jump_reward_source_alpha_20260626.png`
- Boss2 reward runtime prop:
  `assets/environment/double_jump_reward/boss2_double_jump_reward_source.png`

Prompt summaries:

- Boss2: side-view pixel-art cyber feline echo guardian boss, armored scrap
  silhouette, cat ears and glowing eye, green chroma-key background, 4 animation
  rows for idle/attack/hurt/death with 3 consistent frames each.
- Reward prop: side-view pixel-art Double Jump relic with violet/gold cat-paw
  air core, scrap pedestal, upward wind motif, green chroma-key background.

Godot import completed through the editor import pipeline. Runtime frames are
transparent PNGs with consistent frame dimensions and continuous names.

## Automated Tests

- RED: `reports/report_756/`
  - Command:
    `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd --ignoreHeadlessMode`
  - Result: expected failure. The new Boss2 character scene, script,
    SpriteFrames, and main-scene reward flow were missing.
- Intermediate RED: `reports/report_757/`
  - Same focused command.
  - Result: expected failure on hidden-path/Boss2 idempotence before final
    reward-source placement and availability sync.
- GREEN focused: `reports/report_758/`
  - Same focused command.
  - Result: exit `0`, `3/3`.
- Related regression RED: `reports/report_762/`
  - Command included Boss2 payoff, hidden Double Jump reward, Double Jump gate,
    ability-gate feedback, Rat King reward, and MainScene audio adapter suites.
  - Result: `17` executed, `1` failure. The failure exposed stale root
    SceneManager pending-load pollution from ability-gate tests before a menu
    load audio assertion.
- Focused stale-pending RED/GREEN:
  - `reports/report_768/`: expected failure, new stale pending SceneManager
    regression test failed.
  - `reports/report_769/`: exit `0`, `10/10` after MainScene local load
    restore stopped requesting stale root SceneManager transitions for current
    `main` snapshots.
- Final related regression: `reports/report_771/`
  - Command:
    `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd -a res://tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd -a res://tests/unit/gameplay/exploration_gate_unlock_feedback_test.gd -a res://tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd --ignoreHeadlessMode`
  - Result: exit `0`, `22/22`.
  - Notes: Godot process-exit cleanup warnings appeared after the GdUnit result;
    test result itself passed.

## Headless Smoke

- Main scene:
  - Command:
    `/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/mainline_boss2_double_jump_payoff_shell_main_scene_smoke.log`
  - Result: exit `0`.
- Log keyword scan:
  - Command:
    `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Invalid get index|Cannot open|Failed loading resource|Resource file not found|missing resource|Condition .* is true|ERROR:" reports/mainline_boss2_double_jump_payoff_shell_main_scene_smoke.log`
  - Result: no matches.
  - Notes: the console still printed the project's known cleanup-time
    ObjectDB/resource warning after process exit; the smoke log itself contained
    no script, parse, invalid-call, or resource-load errors.

## Godot MCP Runtime

Session: Godot `4.6.3-stable`, main scene `res://scenes/main.tscn`,
`autosave=false`.

MCP editor state before run:

- `current_scene="res://scenes/main.tscn"`
- `game_capture_ready=true`
- `is_playing=true`

Runtime tree confirmed:

- `/Main/Boss2EchoGuardian` exists and is `CharacterBody2D`
- `/Main/Boss2EchoGuardian/Sprite` is `AnimatedSprite2D`
- `/Main/Boss2DoubleJumpRewardSource` exists
- `/Main/DoubleJumpExplorationGate` exists
- `/Main/Player` exists

Clean MCP probe returned from a fresh game run:

- Initial Boss2:
  - `boss_hp_before=36`
  - `boss_defeated=false`
  - `boss_entity_id=2200`
  - `reward_available=false`
  - `reward_claim_available=false`
  - `reward_claimed=false`
  - `initial_gate_state="locked"`
  - `initial_player_has_double_jump=false`
- Frame animation:
  - `sprite_is_animated=true`
  - `sprite_frames_path="res://assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres"`
  - `idle=3`, `attack=3`, `hurt=3`, `death=3`
- Boss defeat:
  - `defeat_result=true`
  - `boss_defeated=true`
  - `reward_available=true`
  - `reward_claim_available=true`
- Reward claim:
  - `claim_result=true`
  - `reward_claimed=true`
  - `after_claim_player_has_double_jump=true`
  - `after_claim_gate_state="unlockable"`
  - HUD notification: `Double Jump unlocked`
- Double Jump gate payoff:
  - `double_jump_request_result=true`
  - `after_double_jump_gate_state="unlocked"`
  - `after_double_jump_gate_blocking=false`
- Save snapshot:
  - `snapshot_player_abilities=["double_jump"]`
  - `boss_02_echo_guardian_defeated=true`
  - `boss_02_double_jump_claimed=true`
  - `gate_double_jump_high_platform_unlocked=true`
  - `area_03_factory_unlocked=true`
  - `exploration_gates.unlocked=["double_jump_high_platform"]`

MCP logs contained only MCP traffic, game helper registration, and DataManager
domain load info; no game/editor script, parse, invalid-call, or resource-load
errors were present after the clean probe.

Runtime screenshot was written by the running game to:

`reports/visual/cinderpaw-mcp-mainline-boss2-double-jump-payoff-shell-20260626.png`

The screenshot is `1280x720`, nonblank, and shows the main scene with Cinderpaw,
Boss2, the Double Jump route marker, and surrounding gameplay HUD.

## Acceptance Mapping

| Acceptance item | Evidence | Status |
| --- | --- | --- |
| Boss2 runtime entity exists in MainScene | `report_758`, MCP runtime tree | PASS |
| Boss2 uses AnimatedSprite2D + SpriteFrames | `report_758`, MCP probe | PASS |
| `idle`/`attack`/`hurt`/`death` have at least 3 frames | `report_758`, MCP probe | PASS |
| Defeating Boss2 reveals reward source | `report_758`, MCP probe | PASS |
| Claiming reward unlocks Double Jump through MainScene | `report_758`, MCP probe | PASS |
| Hidden path and Boss2 path are idempotent | `report_758`, hidden reward related regression | PASS |
| Double Jump opens high-platform gate after claim | `report_771`, MCP probe | PASS |
| MCP runtime logs and screenshot verified | MCP logs and screenshot | PASS |
