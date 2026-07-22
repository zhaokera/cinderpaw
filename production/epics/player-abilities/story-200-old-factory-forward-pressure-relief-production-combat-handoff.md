# Story 200: Old Factory Forward Pressure Relief Production Combat Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Combat
> **Type**: Integration + Gameplay Runtime + Production Combat + Death Feedback + Encounter Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story080 已有 forward-pressure relief encounter、entity `2124`、Factory
Spark Rat 帧动画、动态 steam vent、持久化和 Story081 gating，但击败验收仍以
直接 API 为主。Story081 inactive entity `2125` 的 hurtbox 保持 normal，会在
双方重叠时抢走玩家攻击；2124 defeat 又会立即被 Factory callback 隐藏，导致
已制作的 `death` 帧玩家不可见。availability 在击败同帧改变时还可能把残余位移
直接串联到下一战。本 Story 完成 2124 的生产攻击击败、可见死亡反馈，以及必须
经过稳定 clear frame 和新正向位移的 Story081 交接。

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/feline-combat.md`,
`design/gdd/enemies.md`, `design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-combat-001`, `TR-combat-004`, `TR-enemy-001`,
`TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management; ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] 有效 Story199-complete 状态中，真实 `move_right` 启动 Story080，显示
  entity `2124`、relief vent 与 `Survive Forward Pressure Relief Ambush`。
- [x] 真实玩家轻攻击走 `Input.attack -> CombatComponent -> WeaponComponent ->
  CollisionComponent`，使用实际物理重叠把 entity `2124` 的最终 `12 HP`
  清零；最终命中是 `cat_claw_light`、damage `12`、facing `-1`。
- [x] Story081 inactive 时 entity `2125` hidden、HP 保持 `24`、hurtbox 为
  `gone`，不参与 Story080 的攻击检测。
- [x] entity `2124` 归零后立即关闭 body collision、hurtbox、target 和 relief
  vent，但保留 visible `AnimatedSprite2D` 播放三帧 `death`，随后沿用 RatMinion
  自身淡出并退出。
- [x] defeat 状态持久化，HUD 先显示
  `Forward Pressure Relief Ambush Cleared`；Story081 只变为 available，仍
  hidden、process/physics disabled、hurtbox `gone`、HP `24`。
- [x] defeat 同帧、残余位移和静止 process frame 均不得启动 Story081；只有
  clear 后新的正向位移满足 `current_x > previous_x && current_x >= 1888`
  才激活 entity `2125`。
- [x] 激活后的 2125 visible/targeted、process/physics enabled、hurtbox
  `normal`、HP `24`、family `factory_coil_rat`，HUD 为
  `Face Coil Rat Breakthrough`。
- [x] 2124 与 2125 均使用 `AnimatedSprite2D` + `SpriteFrames`；六个 gameplay
  animation 各三帧，动态 steam 的 `safe`、`warning`、`active` 各四帧。
- [x] 不新增视觉或音频资产；复用已登记的 image-generated Factory Spark
  Rat、Factory Coil Rat、steam vent、Cinderpaw 与 Factory 环境。
- [x] Thin RED/GREEN、相关回归、180 帧 Factory smoke，以及 Godot 4.7 /
  Godot AI MCP 3.0.4 真实输入、真实碰撞、日志和非空截图验收通过。

## Out Of Scope

entity `2125` 的击败与 Story082 coil pincer handoff、全局 RatMinion 尸体停留
时长调整、Spark/Coil Rat AI 或数值重做、vent 预警或 grace 调整、SaveSystem
schema、地图扩建、新视觉或音频素材。

## Implementation Notes

- Story081 inactive 时 entity `2125` hurtbox 切为 `gone`；encounter active
  时恢复为 `normal`。
- 2124 defeat callback 不再立即执行完整隐藏同步，而是先进入 death
  presentation：战斗碰撞、hurtbox、target 和 hazard 当帧关闭，角色节点继续
  visible/process，让既有 RatMinion `death` 动画、短 hold 和 fade 自行完成。
- defeat callback 建立 clear-frame barrier 并快照玩家 X。生产 auto-activation
  使用 process-frame 开始时的 availability 快照，同时要求新正向位移跨过
  `x=1888`，因此致死 tick 的残余位移不能串联 Story081。
- Story081 既有显式 activation API 保持不变；本 Story 只收紧生产自动交接。
- Canonical GdUnit 先通过既有 `apply_damage` 做一次非致命 `12 HP` setup，
  再由真实 `Input.attack` 激活玩家 hitbox，并用定向 detection 注入保证 focused
  test 确定性；MCP 最终运行使用真实 `J` 和实际 Area2D 重叠完成致死命中。

## Asset Use

本 Story 不需要 image generation。现有 Factory Spark Rat 与 Factory Coil Rat
均使用 `AnimatedSprite2D` + `SpriteFrames`，`idle`、`run`、`attack`、
`attack_tell`、`hurt`、`death` 均为三帧；动态 steam 的三个状态均为四帧。
所有资源已有资产管线和 manifest 记录。

## Verification Evidence

- Canonical RED `reports/report_2193/results.xml` 为 `0/1`、十个预期失败，暴露
  inactive 2125 hurtbox、提前串联 Story081、clear HUD 被覆盖和 fresh movement
  失效。死亡反馈审查新增 RED `reports/report_2196/results.xml`，以唯一失败证明
  2124 death 帧被 Factory callback 当帧隐藏。
- Final focused GREEN `reports/report_2197/results.xml` 为 `1/1`；final bounded
  related `reports/report_2198/results.xml` 为四个 suite、`6/6`，最终均为零
  failure、error、flaky、skip 或 orphan。
- Godot 4.7 对 Factory scene 执行 `180` 帧 headless smoke 并退出 `0`；日志为
  `reports/old_factory_forward_pressure_relief_production_combat_handoff_smoke.log`。
- Godot AI MCP 3.0.4 accepted clean run `r117055706-33`：真实右移启动 2124；
  真实左移定向后，真实 `J` 以实际物理重叠把 `12 HP -> 0 HP`，metadata 为
  target `2124`、weapon `cat_claw`、hitbox `cat_claw_light`、facing `-1`、
  damage `12`，同时 2125 保持 `24 HP` 且 hurtbox 为 `gone`。
- 致死后 2124 visible `death`、body layer/mask `0`、hurtbox `gone`、vent off；
  clear 稳定后节点自行退出，2125 仍 inactive。新的真实 `move_right` 才激活
  2125，恢复 visible/targeted、process/physics、normal hurtbox 与正确 HUD。
- MCP 返回非空 RGB `1278x718` active、death-clear 与 Story081 active
  screenshots；accepted game log 仅 helper registration info，editor log 为空，
  输入已释放，Godot 已停止并恢复 ready。
- 未运行 full suite；验证限定在 Story080/081 handoff 与直接相邻 encounter。
- 完整证据：
  `production/qa/evidence/old-factory-forward-pressure-relief-production-combat-handoff-2026-07-21.md`。

**Status**: [x] Complete.
