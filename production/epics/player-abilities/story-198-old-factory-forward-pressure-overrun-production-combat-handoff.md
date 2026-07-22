# Story 198: Old Factory Forward Pressure Overrun Production Combat Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Combat
> **Type**: Integration + Gameplay Runtime + Production Combat + Encounter Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story078 已创建设施下层 forward-pressure overrun、entity `2122`、Spark Rat
帧动画、蒸汽 vent、持久化与 Story079 gating；Story197 已让真实玩家动作启动
该战斗。原实现仍可能让 Story078 的致命帧残余位移直接启动 Story079，且隐藏的
entity `2123` hurtbox 没有随 encounter inactive 状态关闭。本 Story 完成
2122 的生产攻击击败路径，并建立清场后再推进的两阶段交接。

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/feline-combat.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-combat-001`, `TR-combat-004`, `TR-scene-004`,
`TR-explore-005`, `TR-respawn-002`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management; ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] 有效 Story197-complete 状态中，真实 `move_right` 启动 Story078，显示
  entity `2122`、Spark Rat、overrun vent 与
  `Survive Forward Pressure Overrun`。
- [x] 真实玩家轻攻击走 `Input.attack -> CombatComponent -> WeaponComponent ->
  CollisionComponent`，使用实际物理重叠把 entity `2122` 从
  `24 HP -> 12 HP -> 0 HP`；最终命中是 `cat_claw_light`、damage `12`、
  facing `-1`。
- [x] Story079 inactive 时 entity `2123` hidden、HP 保持 `24`，其 hurtbox
  为 `gone`，不参与 Story078 的玩家攻击检测。
- [x] entity `2122` 归零后持久化 activated/defeated，移除敌人及 hurtbox，
  关闭 overrun vent，并显示 `Forward Pressure Overrun Cleared`。
- [x] Story078 清场至少保持一个稳定 process frame。致命帧残余位移、静止或
  仅位于 `x>=1668` 不得自动启动 Story079。
- [x] Story079 清场后变为 available，但只有新的正向位移且玩家位于
  `x>=1668` 才启动 entity `2123`、breaker vent 和
  `Secure Forward Pressure Breaker`；breaker console 仍隐藏。
- [x] Story079 激活后 entity `2123` visible/targeted、process/physics enabled、
  hurtbox `normal`；Spark Rat 六个 gameplay animation 各三帧。
- [x] 不新增视觉或音频资产；复用已登记的 image-generated Factory Spark
  Rat、steam vent、breaker console、Cinderpaw 与 Factory 环境。
- [x] Thin RED/GREEN、相关回归、180 帧 Factory smoke，以及 Godot 4.7 /
  Godot AI MCP 3.0.4 真实输入、真实碰撞、日志和非空截图验收通过。

## Out Of Scope

entity `2123` 的击败、breaker secured/cut 与 console 交互、Story080 relief
ambush、Spark Rat AI/数值重做、vent 预警或 grace、SaveSystem schema、地图或
房间扩建、新视觉或音频素材。

## Implementation Notes

- Story079 使用 dedicated previous-player-x tracking；Story078 defeat callback
  建立一个 clear-frame barrier，并在帧末重新采样玩家位置。
- 生产 auto-activation 先使用 process-frame 开始时的 availability 快照，再
  要求 `current_x > previous_x && current_x >= 1668`。本 Story 不改变测试或
  调试用途的显式 activation API。
- Story079 inactive/secured 同步会把 entity `2123` hurtbox 切为 `gone`；
  encounter active 时恢复为 `normal`。
- Canonical GdUnit 把 2122 非致命预置到 `12 HP`，并用定向 detection 注入
  保证 focused test 确定性；MCP 验收从 `24 HP` 开始，以两次真实 `J` 和
  实际 Area2D 物理重叠完成 `24 -> 12 -> 0`。

## Asset Use

本 Story 不需要 image generation。现有 Factory Spark Rat 使用
`AnimatedSprite2D` + `SpriteFrames`，`idle`、`run`、`attack`、
`attack_tell`、`hurt`、`death` 均为三帧；steam vent、breaker console、
Cinderpaw 与 Factory 环境已有资产管线和 manifest 记录。

## Verification Evidence

- Canonical RED `reports/report_2185/results.xml` 为 `0/1`，七个失败精确暴露
  inactive 2123 hurtbox、清场 HUD 被覆盖、Story079 提前 active，以及没有
  新正向位移可供交接的问题。
- Focused GREEN `reports/report_2186/results.xml` 为 `1/1`；最终 bounded related
  `reports/report_2187/results.xml` 为四个 suite、`6/6`，零 failure、error、
  flaky、skip 或 orphan。
- Godot 4.7 对 Factory scene 执行 `180` 帧 headless smoke 并退出 `0`；日志为
  `reports/old_factory_forward_pressure_overrun_production_combat_handoff_smoke.log`。
- Godot AI MCP 3.0.4 clean run `r112550136-28`：真实右移启动 2122；真实左移
  后两次 `J` 以实际物理重叠完成 HP `24 -> 12 -> 0`，最终 metadata 为
  target `2122`、weapon `cat_claw`、hitbox `cat_claw_light`、facing `-1`、
  damage `12`，同时 2123 保持 `24 HP`。
- 清场后 Story079 available/inactive、2123 hurtbox `gone`、enemy/vent/console
  hidden，HUD 为 `Forward Pressure Overrun Cleared`；新的真实 `move_right`
  才启动 2123 与 vent，console 继续 hidden。
- Story079 runtime `Sprite` 是 visible `AnimatedSprite2D`，六个动作各三帧；
  MCP 返回非空 RGB `1278x718` active、clear 与 next-encounter screenshots。
  Accepted-run game log 仅 helper registration info，editor log 为空，输入已
  释放，Godot 已停止并恢复 ready。
- 完整证据：
  `production/qa/evidence/old-factory-forward-pressure-overrun-production-combat-handoff-2026-07-21.md`。

**Status**: [x] Complete.
