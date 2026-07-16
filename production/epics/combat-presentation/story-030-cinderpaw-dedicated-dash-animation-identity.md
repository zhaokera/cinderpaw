# Story 030: Cinderpaw Dedicated Dash Animation Identity

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual / Feel / Asset Repair
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-16

## Context

**GDD**: `design/gdd/combat-presentation.md`, `design/gdd/feline-combat.md`,
`design/gdd/player-abilities.md`

**Requirement**: `TR-combatfx-010`

Player Abilities Story001 已为 Rat King 奖励接入独立 `dash` SpriteFrames
状态和资源路径，但三张 PNG 暂时逐像素复制 Dodge。玩家因此无法仅凭动作判断
自己执行的是防御闪避还是高速穿越。本 Story 只替换 Dash 三帧的动作身份，
保留能力门控、速度、持续时间、冷却、事件和现有 SpriteFrames 接线。

## Acceptance Criteria

- [x] `dash` 保持 3 张透明 `96x96` 连续命名 PNG，并继续由
  `AnimatedSprite2D + SpriteFrames` 以非循环 `18 FPS` 播放。
- [x] 三帧分别表现即时发射、最大速度水平拉伸、前向动量收束；不复用 Dodge
  的伏地准备、翻滚或扬尘刹停语义，并兼容空中 Dash。
- [x] 三张 Dash PNG 均与对应 Dodge PNG 像素不同，alpha silhouette 差异
  均不低于 15%。
- [x] 每帧保留 Cinderpaw 的黑锈毛色、暗砖红围巾、琥珀高光、深钢护甲；
  红围巾和琥珀身份像素均不少于 30，半透明软边比例不高于 8%。
- [x] image generation 提示词、参考图、chroma source、alpha source、固定切片
  与量化流程留档并通过 Godot 4.7 资产管线导入。
- [x] 真实 Dash 仍为 `620 px/s`、能力冷却生效，Dodge 三帧和行为回归通过。
- [x] Godot MCP 3.0.2 在 Main 中用真实输入验证 Dash、帧资源、节点可见性、
  非空截图、无新增运行时错误，并 clean stop。

## Out of Scope

- Dash 解锁、速度、10 physics-frame 持续时间、距离、冷却或技能加成调整。
- Dodge 动画、i-frame、反击窗口、冷却或取消规则。
- GDD 要求的两道高速残影、独立速度线事件和专用风声；这些仍需后续
  Combat Presentation Story，不能由本次帧素材替代。
- Dash 是否应共享 Dodge 无敌窗口的规则审计。
- ExplorationGate、Boss 奖励、存档、HUD、关卡和其他角色动画。

## Required Evidence

- `tests/unit/gameplay/cinderpaw_dash_animation_readability_test.gd`
- `tests/unit/gameplay/player_dash_ability_runtime_test.gd`
- `tests/unit/gameplay/player_dodge_animation_test.gd`
- `assets/characters/cinderpaw/source/cinderpaw_dash_strip_imagegen_20260716.md`
- `production/qa/evidence/cinderpaw-dedicated-dash-animation-identity-2026-07-16.md`

## Test Evidence

- RED: `reports/report_1831/results.xml`，`1` 个验收测试产生预期的 `6` 个
  复制素材失败；三对轮廓差异均为 `0`。
- Focused GREEN: `reports/report_1832/results.xml`，`1/1`。
- Final focused + related: `reports/report_1835/results.xml`，Dash identity、
  Dash runtime、Dodge animation 共 `7/7`，`0 errors / 0 failures / 0 orphans`，
  exit `0` 且无引擎退出泄漏。
- Full suite 未运行，符合可见素材小 Story 的验证预算。

## Completion Notes

**Completed**: 2026-07-16

**Criteria**: 7/7 passing

三帧继续使用原路径，因此 `cinderpaw_sprite_frames.tres`、场景和运行时控制器
无需修改。相关回归额外补齐 Dash runtime 测试的 AudioSystem 清理，避免 Main
音乐和 Dash SFX 在 CLI 退出时保留 stream/playback；游戏音频逻辑未变。
