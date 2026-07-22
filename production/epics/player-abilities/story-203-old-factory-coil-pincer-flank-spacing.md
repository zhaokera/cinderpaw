# Story 203: Old Factory Coil Pincer Flank Spacing

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Encounter Spacing
> **Type**: Integration + Gameplay Runtime + AI/Encounter Pacing + Visual Readability
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story202 已把 Coil Pincer entities `2126`/`2127` 接入真实玩家攻击、可见死亡与
Story083 安全交接，但自然激活时两只缩放后的 `96x96` 角色中心仅相距约 `70px`，
轮廓明显重叠。本 Story 只收敛 encounter 初始编排：以实际触发玩家位置为锚点，
把短宽限 Spark Rat 放到前方，把长宽限 Coil Rat 放到后方，并证明双方在宽限期
结束后的自然追击中仍可分别辨认。

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/ai-framework.md`,
`design/gdd/feline-combat.md`, `design/gdd/collision-detection.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-combat-001`, `TR-combat-004`, `TR-enemy-001`,
`TR-scene-004`, `TR-explore-005`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management; ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] 有效 Story081-complete 状态中，真实 `move_right` 继续通过生产移动路径启动
  Story082；不使用直接 encounter activation API，也不在验收中移动或冻结敌人。
- [x] 激活时记录玩家 X 为 encounter anchor，并在同步 active 状态前把 entity
  `2126` Spark Rat 编排到 `anchor + 144px`、entity `2127` Coil Rat 编排到
  `anchor - 160px`；场景 authored fallback 保持同样 `304px` 中心间距。
- [x] Spark Rat 位于玩家前/右侧，Coil Rat 位于玩家后/左侧；初始两侧均有至少
  `48px` 可读空间，敌人中心间距至少 `130px`。
- [x] 激活时两只敌人均 visible、targeted、process/physics enabled、hurtbox
  `normal`、HP `24`，且都在既有 `180px` alert radius 内。
- [x] opening grace 保持既定 Spark `10` 帧、Coil `26` 帧，不修改伤害、速度、
  attack startup、family、entity ID、SpriteFrames 或碰撞合同。
- [x] 双方 opening grace 均归零并继续运行 `20` physics frames 后，仍保持一左
  一右、每侧至少 `48px`、中心至少 `130px` 的自然夹击拓扑。
- [x] Story202 partial/full clear 与 Story083 fresh-forward-movement barrier 保持
  不变；本 Story 不增加 SaveSystem schema 字段。
- [x] 不新增视觉或音频资产；复用已登记的 image-generated Factory Spark Rat、
  Factory Coil Rat、Cinderpaw 与 Factory 环境。
- [x] Thin RED/GREEN、相邻回归、180 帧 Factory smoke，以及 Godot 4.7 /
  Godot AI MCP 3.0.4 真实输入、自然追击、日志和非空截图验收通过。

## Out Of Scope

全局双敌 separation/steering、长期战斗中的硬性不交叉保证、共享 RatMinion AI 或
数值重做、Story202 combat/death、Story083 entity `2128` 的 production combat、
Story084 handoff、SaveSystem schema、地图扩建、新视觉或音频素材。

## Implementation Notes

- `try_activate_factory_lower_deck_forward_pressure_coil_pincer()` 在写入 active 状态
  和同步节点前调用 scene-owned staging helper；X 坐标来自真实 activation
  provider，Y 坐标和后续 RatMinion 自主 locomotion 保持不变。
- Spark `+144px` 与 Coil `-160px` 让初始中心距为 `304px`。`-160px` 替代初版
  `-176px`，为玩家跨过 `x=2016` 后仍保留 Coil 的 `180px` alert margin。
- `get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics()` 新增
  `activation_anchor_x` 与 `enemy_center_distance_x`，供 focused test 与 MCP
  运行态取证；它们不进入持久化状态。
- `.tscn` 的 `2160/1856` authored X 只提供非激活/编辑器 fallback；每次实际
  activation 都按玩家触发位置重新编排。

## Asset Use

本 Story 不需要 image generation。entities `2126`/`2127` 继续使用既有
`AnimatedSprite2D + SpriteFrames`，`idle`、`run`、`attack_tell`、`attack`、
`hurt`、`death` 各三帧；没有 PNG、SpriteFrames、manifest 或 inventory 变更。

## Verification Evidence

- Canonical RED `reports/report_2215/results.xml` 为 `0/1`、六个预期 failure、
  零 error，证明原始自然站位缺少两侧拓扑、最小侧向空间和中心距合同。
- Final focused GREEN `reports/report_2221/results.xml` 为 `1/1`，零 failure、
  error、flaky、skip 或 orphan。
- 首次 bounded related `reports/report_2218/results.xml` 为 `6/7`，唯一失败是
  Story083 仍要求 defeated Coil Rat 当帧 hidden 的过时断言；按 Story202/共享
  death presentation 合同修正后，`reports/report_2220/results.xml` 五个 suite
  通过 `7/7`，覆盖 Story201、Story082、Story202、Story083 与本 Story。
- Godot 4.7 对 Factory scene 执行 `180` 帧 headless smoke 并退出 `0`；日志为
  `reports/old_factory_coil_pincer_flank_spacing_smoke.log`。退出阶段保留既有
  Factory baseline 的 `4 ObjectDB / 2 resources` teardown diagnostic。
- Godot AI MCP 3.0.4 accepted run `r124835541-44`：真实 `move_right` 将玩家从
  `x=2004` 推进并自然激活 pincer。激活 anchor 为 `2016.222`，敌人 X 为
  `2160.222/1856.222`、中心距 `304px`；输入停止时双方相对玩家约
  `+131.22/-172.78px`，均在 `180px` alert radius 内，opening grace 为
  `10/26` 合同。
- 双方 grace 归零并继续自然运行约 `20` physics frames 后，Spark/Coil 相对
  玩家约 `+59.29/-202.44px`，中心距约 `261.73px`，仍满足左右拓扑与
  `48/130px` 可读阈值；两者 visible、targeted、process/physics enabled。
- MCP 返回非空 RGB `1278x718` screenshot，画面可见 Cinderpaw、两侧动画敌人、
  有纹理 Factory 环境与 `Break Coil Pincer` HUD。Accepted-run game log 仅
  helper registration info，editor log 为空，Godot clean stop 并回到 ready。
- 未运行 full suite；验证限定在本 Story 与 Story201/082/202/083 相邻合同。
- 完整证据：
  `production/qa/evidence/old-factory-coil-pincer-flank-spacing-2026-07-21.md`。

**Status**: [x] Complete.
