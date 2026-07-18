# Story 173: Sluice Matriarch Pressure Geyser Pattern

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / Boss Combat / Presentation
> **Type**: Attack Pattern + Frame Animation + VFX
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-18

## Context

Story128 建立了可玩的 Boss3 核心，但 Sluice Matriarch 两个阶段都只重复
pressure lunge，且收招阶段停留在攻击末帧。Story173 增加一招锁定玩家地面位置的
pressure geyser，并补齐 Boss 专用收招动画，使战斗形成横向追击与地面控场的
可学习轮换，而不扩大既有奖励、路线和存档边界。

**GDD**: `design/gdd/boss-config.md`, `design/gdd/feline-combat.md`,
`design/gdd/combat-presentation.md`, `design/art/art-bible.md`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 AI Framework.

## Acceptance Criteria

- [x] Boss3 保留既有 `120` HP、pressure lunge 数值、50% Phase II 阈值、
  Boss HUD、击败奖励、存档与路线行为；自动攻击从 lunge 开始并严格交替为
  `pressure_lunge -> pressure_geyser -> pressure_lunge`，不得连续重复同一模式。
- [x] `pressure_geyser` 在攻击请求时记录玩家横坐标并限制在 Arena 可见范围；
  喷泉宽度不超过 `176px`，单次只生成一列，Arena 始终保留至少 `160px`
  可躲避空间。
- [x] Phase I 喷泉时序为 `24` startup、`10` active、`24` recovery；Phase II
  为 `18/10/18`。startup 仅显示预警且无伤害，active 才启用独立
  `sluice_matriarch_pressure_geyser` hitbox，基础伤害为 `14`。
- [x] Boss `geyser_tell`、`geyser_attack`、`attack_recovery` 各使用三张
  `192x192` 透明 PNG，并接入既有 `AnimatedSprite2D + SpriteFrames`；冲刺和
  喷泉 recovery 都播放 `attack_recovery`，不再停留在攻击末帧。
- [x] 喷泉 VFX 使用独立 `AnimatedSprite2D + SpriteFrames`，`warning` 与
  `active` 各三帧透明 PNG；预警与伤害状态在动画、可见性和 hitbox 上一致。
- [x] 重试、击败和进度恢复会关闭全部攻击 hitbox、隐藏喷泉 VFX、清除
  当前模式与目标位置；击败后不存在延迟喷泉伤害。
- [x] 新视觉素材由 built-in image generation 生成，保留提示词、生成源、
  alpha 源、处理记录、资产规格和 manifest 项，并通过 Godot 4.7 资产管线导入。
- [x] 一条聚焦 RED/GREEN、最小 Boss3 相关回归和一次 Godot AI MCP 实机运行
  通过；MCP 需看到 warning -> active -> recovery、三帧动画、无新增错误和
  非空截图。

## Out Of Scope

- Boss3 Phase III、召唤、复数或重叠喷泉、随机模式调度、BossConfig 数据迁移。
- 修改 Cinderpaw 能力、伤害公式、Boss3 奖励、Arena 路线、存档 schema 或
  Main 场景流程。
- 新音频、镜头震动、粒子、shader distortion、Phase II 过场或全局 Boss 重构。

## Implementation Notes

- 保持现有 Boss 状态机，新增模式选择层与模式对应的时序、动画、hitbox 元数据；
  显式模式请求仅用于确定性测试和 MCP 验收，自动调度仍受冷却控制。
- 喷泉目标在 startup 开始时冻结，玩家可通过离开预警区域躲避。Boss 在喷泉
  active 期间不横向移动，pressure lunge 的移动和伤害保持不变。
- 普通 HP 伤害沿用既有 Boss 规则，不中断已经开始的攻击链；重试、击败和进度
  恢复才执行强制攻击清理。
- Boss 新帧应延续 Story128 的低矮工业水蛭身份；VFX 预警使用信号红/琥珀，
  active 使用高亮 cyan 压力水柱，不能依赖纯色矩形表达。

## Test Evidence

- Initial RED: `reports/report_1922/results.xml`, `1/1` expected failure on the
  missing pressure-geyser `SpriteFrames` resource; `0` errors and `0` orphans.
- Focused GREEN: `reports/report_1924/results.xml`, `1/1` passed with `0`
  failures, errors, skipped, or flaky tests.
- Final pre-commit focused gate after the MCP warning fix:
  `reports/report_1928/results.xml`, `1/1` passed with `0` errors, failures,
  skipped, flaky tests, or engine orphans.
- Related regression: `reports/report_1927/results.xml`, Story173 plus the
  three directly related Boss3 suites passed `12/12` with `0` failures,
  errors, skipped, flaky tests, or engine orphans.
- Godot MCP runtime: session `cinderpaw@af5f`, final run token `72`; startup,
  active, and recovery diagnostics matched the Story contract, game/editor
  logs were clean, and the non-empty `1278x718` screenshot is retained at
  `reports/visual/cinderpaw-mcp-sluice-matriarch-pressure-geyser-pattern-20260718.png`.
- Full evidence:
  `production/qa/evidence/sluice-matriarch-pressure-geyser-pattern-2026-07-18.md`.

## Dependencies

- Depends on: Story128 Sluice Matriarch Playable Boss3 Core.
- Preserves: Story129 Sluice Matriarch Aerial Attack Reward Payoff.
