# Story 029: Cinderpaw Air Animation Identity Consistency

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual / Feel / Asset Repair
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-15

## Context

**GDD**: `design/gdd/combat-presentation.md`, `design/gdd/feline-combat.md`,
`design/gdd/player-abilities.md`

**Requirement**: `TR-combatfx-010`

Story006 已实现 jump/fall 状态选择和三帧资源接线，但 2026-06-24 的六帧
素材是蓝披风、软绘制的另一套角色设计，未保持 Cinderpaw 已确立的黑锈毛色、
红围巾、琥珀高光和深钢护甲。本 Story 只修复玩家可见空中动画身份，不更改
移动、战斗状态优先级或 SpriteFrames 路径。

## Acceptance Criteria

- [x] `jump` 与 `fall` 各保留 3 张透明 `96x96` 连续命名 PNG，并继续由
  `AnimatedSprite2D + SpriteFrames` 使用。
- [x] 六帧与 idle/run 保持黑锈猫、红围巾、琥珀眼/毛色高光、深钢护甲身份，
  不含蓝披风设计。
- [x] 每帧至少包含 30 个红围巾身份像素和 30 个琥珀身份像素，半透明软边
  比例不高于 8%。
- [x] 新源图由 image generation 参考 Cinderpaw 主精灵表和连击表生成，
  提示词、源图、alpha 图与处理方式留档并通过 Godot 4.7 导入。
- [x] 既有 upward `jump`、downward `fall` 和更高优先级动作状态保持通过。
- [x] Godot MCP 3.0.2 在 Main 中验证真实 jump/fall、帧数、节点可见性、
  非空截图、无新增运行时错误，并 clean stop。

## Out of Scope

- 跳跃物理、落地恢复、coyote time、double jump、hitbox 或状态优先级调整。
- Dash、dodge、wall climb、攻击或敌人动画重做。
- 场景、关卡、HUD、VFX、音频和存档变更。

## Required Evidence

- `tests/unit/gameplay/cinderpaw_air_animation_identity_consistency_test.gd`
- `tests/unit/gameplay/player_air_animation_test.gd`
- `tests/unit/gameplay/player_character_animation_test.gd`
- `assets/characters/cinderpaw/source/cinderpaw_jump_fall_sheet_imagegen_20260715.md`
- `production/qa/evidence/cinderpaw-air-animation-identity-consistency-2026-07-15.md`

## Test Evidence

- RED: `reports/report_1825/results.xml`, `1` 个验收测试产生预期的 `18`
  个素材身份/软边失败。
- Focused GREEN: `reports/report_1826/results.xml`, `1/1`。
- Final focused + related: `reports/report_1829/results.xml`, `12/12`。
- Fresh completion gate: `reports/report_1830/results.xml`, `12/12`，exit `0`。
- Full suite 未运行，符合可见素材小 Story 的验证预算。

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 6/6 passing

六帧仍使用原有路径，因此 `cinderpaw_sprite_frames.tres` 与玩家控制器无需
修改。相关回归同时修正一条 2026-06-24 的过时测试断言：当前三段连击会按
Core 攻击帧故意暂停在第 0 帧，测试现改为验证该确定性契约，没有修改运行时代码。
