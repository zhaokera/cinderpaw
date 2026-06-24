# QA Evidence: Rat King AI Attack Scheduler - 2026-06-25

## Scope

验证 Boss Configuration Story008：Rat King runtime boss 不再只有硬编码
`rat_king_claw` 攻击，而是通过 BossConfig phase pattern ids、`enemy_stats`
attack profiles、`AIComponent` attack phase lifecycle、Collision/Combat adapter
桥接来调度 `charge`、`claw_swipe`、`slam` 和 `berserk_combo`。

本证据不声明完整最终 Boss 战完成。真实冲撞/跳砸位移、三连击逐段表现、召唤、
场地变化、boss music/SFX、奖励展示和专属攻击帧动画仍是后续工作。

## Implemented Runtime Surface

- Runtime script: `res://src/gameplay/rat_king_boss.gd`
- Data domain: `res://data/combat/enemy_stats.json`
- Boss phase domain: `res://data/combat/boss_configs.json`
- AI runtime component: `/Main/Enemy/AIComponent`
- Visible surface:
  `res://assets/characters/rat_king/rat_king_sprite_frames.tres`
- Current shared animations used by this slice: `attack_tell`, `attack`

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/ai/story_005_boss_phase_focus_mode_signal_integration_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_476/`.

Summary: expected failure. `AIComponent` did not expose
`apply_boss_phase` / current phase pattern ids / pattern-id attack start, and
`RatKingBoss` did not expose the scheduler contract used by MainScene tests.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/ai/story_003_data_driven_attack_pattern_loading_test.gd -a res://tests/unit/ai/story_005_boss_phase_focus_mode_signal_integration_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_478/`.

Summary: `18/18` passing, `0` errors, `0` failures.

### Related Boss / AI / Gameplay Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/ai -a res://tests/unit/boss -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/rat_king_character_animation_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_479/`.

Summary: `74/74` passing, `0` errors, `0` failures.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 2 --log-file reports/rat_king_ai_attack_scheduler_main_scene_smoke.log
rg -n "ERROR|SCRIPT ERROR|WARNING|Invalid call|Parse Error|FAILED" reports/rat_king_ai_attack_scheduler_main_scene_smoke.log
```

Result: Godot exited normally. `rg` returned `1` because there were no
error/warning keyword matches.

## Godot MCP Evidence

Session:

- Godot version: `4.6.3-stable (official)`
- Editor scene: `res://scenes/main.tscn`
- Editor readiness before runtime: ready
- Runtime state: playing, game capture ready
- Runtime tree: `/Main/Enemy` is `CharacterBody2D` scripted by
  `res://src/gameplay/rat_king_boss.gd`
- Runtime children include `HealthComponent`, `CollisionComponent`,
  `CombatComponent`, `StatusEffectComponent`, `BossConfigComponent`, and
  `AIComponent`.

Runtime probe result:

```json
{
  "ok": true,
  "enemy_script": "res://src/gameplay/rat_king_boss.gd",
  "sprite_type": "AnimatedSprite2D",
  "has_sprite_frames": true,
  "attack_tell_frames": 3,
  "attack_frames": 3,
  "has_ai_component": true,
  "phase_one_patterns": ["charge", "claw_swipe"],
  "request_claw": true,
  "claw_active": true,
  "claw_pattern_id": "claw_swipe",
  "claw_startup": 15,
  "phase": 2,
  "phase_two_patterns": ["charge", "claw_swipe", "slam"],
  "speed_modifier": 1.2,
  "request_slam": true,
  "slam_active": true,
  "slam_pattern_id": "slam",
  "slam_startup": 21,
  "slam_damage": 16,
  "sprite_animation": "attack"
}
```

Logs:

- `logs_read(source="game", count=120)` returned only MCP helper registration
  and DataManager domain load lines for `boss_configs` / `enemy_stats`.
- `logs_read(source="editor", count=120)` returned `0` lines.

Screenshot:

- `editor_screenshot(source="game", max_resolution=960)` returned a nonblank
  `960x540` image.
- Screenshot visibly shows Rat King in the playable arena using the current
  frame-animation sprite, not a ColorRect, block, or single static placeholder.

## Verdict

PASS. Rat King now consumes data-driven AI attack pattern profiles in the
playable MainScene runtime. Phase 1 and phase 2 pattern pools are selected by
BossConfig, `slam` is scheduled after phase 2 transition, attack timing honors
the phase speed modifier, and the existing Collision/Combat/MainScene damage
chain remains intact.
