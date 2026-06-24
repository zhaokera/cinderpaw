# QA Evidence: Rat King Runtime MainScene Replacement - 2026-06-25

## Scope

验证 Boss Configuration Story007：`MainScene` 的可见主敌从 Shadow Beast
prototype 替换为 Rat King runtime boss shell，并保持现有 MainScene 敌人契约、
BossConfig phase hook、HUD/Presentation/Audio/SaveSystem 集成可用。

本证据不声明完整 Rat King Boss 战斗完成。完整 AI 调度、召唤、场地变体、boss
music/SFX、奖励表现和更多专用攻击动画仍是后续工作。

## Implemented Runtime Surface

- New scene: `res://src/gameplay/rat_king_boss.tscn`
- New script: `res://src/gameplay/rat_king_boss.gd`
- MainScene instance: `/Main/Enemy`
- Runtime visual surface:
  `res://scenes/characters/rat_king.tscn` mounted as `Enemy/Sprite`
- SpriteFrames:
  `res://assets/characters/rat_king/rat_king_sprite_frames.tres`
- BossConfig identity: `boss_01_rat_king`, display name `垃圾桶鼠王`, max HP
  `300`

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_468/`.

Summary: expected failure. `res://src/gameplay/rat_king_boss.tscn` and
`res://src/gameplay/rat_king_boss.gd` did not exist, and MainScene still failed
the Rat King visible boss contract.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_469/`.

Summary: `7/7` passing, `0` errors, `0` failures.

### Related Visual / Runtime Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/rat_king_character_animation_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd -a res://tests/unit/gameplay/simple_enemy_respawn_reset_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_470/`.

Summary: `28/28` passing, `0` errors, `0` failures.

### Related Boss / Gameplay / Save Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/boss -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/rat_king_character_animation_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_475/`.

Summary: `57/57` tests passed, `0` errors, `0` failures.

### Post-MCP Scene Save Focused Check

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_474/`.

Summary: `7/7` passing after MCP replaced the stale editor-cached Enemy node
and saved `res://scenes/main.tscn`.

## Headless Smoke

Commands:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 2 --log-file reports/rat_king_boss_main_scene_smoke_after_mcp.log
/opt/homebrew/bin/godot --headless --path . --scene res://src/gameplay/rat_king_boss.tscn --fixed-fps 60 --quit-after 1 --log-file reports/rat_king_boss_scene_smoke.log
```

Result: both exited `0`.

Log scans:

```bash
rg -n "ERROR|SCRIPT ERROR|WARNING|Invalid call|Parse Error|FAILED" reports/rat_king_boss_main_scene_smoke_after_mcp.log
rg -n "ERROR|SCRIPT ERROR|WARNING|Invalid call|Parse Error|FAILED" reports/rat_king_boss_scene_smoke.log
```

Result: no matches.

## Godot MCP Evidence

Session:

- Godot version: `4.6.3-stable (official)`
- Editor state before runtime: ready
- Project run mode: current scene, `res://scenes/main.tscn`
- Editor state during runtime: playing, game capture ready
- Editor state after stop: ready

Editor-scene validation:

- `res://src/gameplay/rat_king_boss.tscn` opened successfully.
- `/RatKingBoss/Sprite` is `AnimatedSprite2D`, visible, animation `idle`.
- `/RatKingBoss/Sprite.sprite_frames` is
  `res://assets/characters/rat_king/rat_king_sprite_frames.tres`.
- Editor logs returned `0` lines after scene checks.

MainScene editor validation:

- Initial MCP inspection found stale editor cache:
  `/Main/Enemy` still pointed at `res://src/gameplay/simple_enemy.gd` even
  after disk changes.
- Fix: MCP deleted the stale `/Main/Enemy`, instantiated
  `res://src/gameplay/rat_king_boss.tscn` as `/Main/Enemy`, restored
  `position = Vector2(560, 456)` and `z_index = 20`, then saved MainScene.
- Follow-up MCP inspection confirmed:
  `/Main/Enemy.script = res://src/gameplay/rat_king_boss.gd` and
  `/Main/Enemy/Sprite.sprite_frames =
  res://assets/characters/rat_king/rat_king_sprite_frames.tres`.

Runtime probe:

```json
{
  "enemy_script": "res://src/gameplay/rat_king_boss.gd",
  "boss_id": "boss_01_rat_king",
  "display_name": "垃圾桶鼠王",
  "hp": 300,
  "max_hp": 300,
  "phase": 1,
  "sprite_type": "AnimatedSprite2D",
  "sprite_visible": true,
  "sprite_frames": "res://assets/characters/rat_king/rat_king_sprite_frames.tres",
  "animation": "idle",
  "boss_phase_source_connected": true,
  "uses_simple_enemy": false
}
```

Animation frame counts observed at runtime:

```json
{
  "idle": 3,
  "attack_tell": 3,
  "attack": 3,
  "hurt": 3,
  "death": 3,
  "phase_1_intro": 3,
  "phase_2_rebuild": 3,
  "phase_3_overload": 3
}
```

Phase probe:

```json
{
  "hp": 180,
  "phase": 2,
  "animation": "phase_2_rebuild",
  "presentation_phase": 2,
  "active_debris": 32,
  "hitstop_frames": 4
}
```

Logs:

- `logs_read(source="game", count=100)` returned only MCP helper registration
  and `DataManager: domain 'boss_configs' loaded`.
- `logs_read(source="editor", count=100)` returned `0` lines after clearing a
  transient `game_eval` local-variable shadowing warning caused by the probe
  script itself.

Screenshot:

- `editor_screenshot(source="game", max_resolution=960)` returned a nonblank
  `960x540` image from the running `MainScene`.
- The screenshot visibly shows the large Rat King boss in the arena and the
  boss HUD text `垃圾桶鼠王 Phase II 180/300`.

## Verdict

PASS. `MainScene` now runs with a visible Rat King boss backed by
`AnimatedSprite2D + SpriteFrames`, not a block, single-frame placeholder, or
old Shadow Beast prototype. The runtime shell is connected to BossConfig phase
events, existing combat/presentation/save/audio contracts remain covered, and
Godot MCP verified the live scene tree, logs, and screenshot.
