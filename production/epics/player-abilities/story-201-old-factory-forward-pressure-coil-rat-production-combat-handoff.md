# Story 201: Old Factory Forward Pressure Coil Rat Production Combat Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Combat
> **Type**: Integration + Gameplay Runtime + Production Combat + Death Feedback + Encounter Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story081 已有 forward-pressure Coil Rat encounter、entity `2125`、Factory
Coil Rat 帧动画、持久化和 Story082 gating，但击败验收仍以直接 API 为主。
Story082 inactive entities `2126`、`2127` 的 hurtbox 保持 normal，会在重叠时
抢走玩家攻击；2125 defeat 又会立即被 Factory callback 隐藏，导致已有的
`death` 帧玩家不可见。availability 在击败同帧改变时还可能把残余位移直接
串联到 Coil Pincer。本 Story 完成 2125 的生产攻击击败、可见死亡反馈，以及
必须经过稳定 clear frame 和新正向位移的 Story082 交接。

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/feline-combat.md`,
`design/gdd/collision-detection.md`, `design/gdd/health-death.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-combat-001`, `TR-combat-004`, `TR-enemy-001`,
`TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management; ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] 有效 Story200-complete 状态中，真实 `move_right` 启动 Story081，显示
  entity `2125` 与 `Face Coil Rat Breakthrough`。
- [x] 真实玩家轻攻击走 `Input.attack -> CombatComponent -> WeaponComponent ->
  CollisionComponent`，使用实际物理重叠把 entity `2125` 的最终 `12 HP`
  清零；最终命中是 `cat_claw_light`、damage `12`、facing `-1`。
- [x] Story082 inactive 时 entities `2126`、`2127` hidden、HP 均保持 `24`、
  hurtbox 为 `gone`，不参与 Story081 的攻击检测。
- [x] entity `2125` 归零后立即关闭 body collision、hurtbox、target 与 physics，
  但保留 visible `AnimatedSprite2D` 播放三帧 `death`，随后沿用 RatMinion 自身
  hold/fade 并退出。
- [x] defeat 状态持久化，HUD 先显示
  `Forward Pressure Coil Rat Breakthrough Cleared`；Story082 只变为 available，
  两个敌人仍 hidden、process/physics disabled、hurtbox `gone`、HP `24`。
- [x] defeat 同帧、残余位移和静止 process frame 均不得启动 Story082；只有
  clear 后新的正向位移满足 `current_x > previous_x && current_x >= 2016`
  才同时激活 entities `2126`、`2127`。
- [x] 激活后的 2126/2127 均 visible/targeted、process/physics enabled、hurtbox
  `normal`、HP `24`，family 分别为 `factory_spark_rat` 与
  `factory_coil_rat`，HUD 为 `Break Coil Pincer`。
- [x] Coil Pincer 保持既定 `10/26` 帧 opening grace；两个敌人都使用
  `AnimatedSprite2D` + `SpriteFrames`，六个 gameplay animation 各三帧。
- [x] 不新增视觉或音频资产；复用已登记的 image-generated Factory Spark
  Rat、Factory Coil Rat、Cinderpaw 与 Factory 环境。
- [x] Thin RED/GREEN、相关回归、180 帧 Factory smoke，以及 Godot 4.7 /
  Godot AI MCP 3.0.4 真实输入、真实碰撞、日志和非空截图验收通过。

## Out Of Scope

entities `2126`、`2127` 的完整击败与 Story083 Coil Aftershock handoff、
Spark/Coil Rat AI 或数值重做、opening grace 调整、全局 RatMinion 尸体停留
时长调整、SaveSystem schema、地图扩建、新视觉或音频素材。

## Implementation Notes

- Story082 inactive 时 entities `2126`、`2127` 的 hurtbox 切为 `gone`；
  encounter active 时恢复为 `normal`。
- 2125 defeat callback 不再立即执行完整隐藏同步，而是先进入 death
  presentation：body collision、hurtbox、target 与 physics 当帧关闭，角色节点
  继续 visible/process，让既有 RatMinion `death` 动画、短 hold 和 fade 完成。
- defeat callback 建立 clear-frame barrier 并快照玩家 X。生产 auto-activation
  使用 process-frame 开始时的 availability 快照，同时要求新的正向位移达到
  `x=2016`，因此致死 tick 的残余位移不能串联 Story082。
- Story082 既有显式 activation API 保持不变；本 Story 只收紧生产自动交接。
- Canonical GdUnit 先通过既有 `apply_damage` 做一次非致命 `12 HP` setup，
  再由真实 `Input.attack` 激活玩家 hitbox，并用定向 detection 注入保证 focused
  test 确定性；MCP 最终运行使用真实 `J` 和实际 Area2D 重叠完成致死命中。

## Asset Use

本 Story 不需要 image generation。现有 Factory Spark Rat 与 Factory Coil Rat
均使用 `AnimatedSprite2D` + `SpriteFrames`，`idle`、`run`、`attack`、
`attack_tell`、`hurt`、`death` 均为三帧。所有资源已有资产管线和 manifest
记录。

## Verification Evidence

- Canonical RED `reports/report_2199/results.xml` 为 `0/1`、十九个预期失败，
  暴露 inactive 2126/2127 hurtbox、隐藏敌人抢命中、2125 death 不可见、
  Story082 提前启动和 clear HUD 被覆盖。
- Final focused GREEN `reports/report_2200/results.xml` 为 `1/1`。首次 related
  `reports/report_2201/results.xml` 的唯一失败暴露 2125 death presentation 未
  关闭 physics；修复后 final bounded related `reports/report_2202/results.xml`
  为四个 suite、`6/6`，零 failure、error、flaky、skip 或 orphan。
- Godot 4.7 对 Factory scene 执行 `180` 帧 headless smoke 并退出 `0`；日志为
  `reports/old_factory_forward_pressure_coil_rat_production_combat_handoff_smoke.log`。
- Godot AI MCP 3.0.4 accepted clean run `r118359094-34`：真实右移启动 2125；
  真实左移定向后，真实 `J` 以实际物理重叠把 `12 HP -> 0 HP`，metadata 为
  target `2125`、weapon `cat_claw`、hitbox `cat_claw_light`、facing `-1`、
  damage `12`，同时 2126/2127 保持 `24 HP` 且 hurtbox 为 `gone`。
- 致死后 2125 visible `death`、body layer/mask `0`、hurtbox `gone`、physics
  off；clear 稳定后节点自行退出，2126/2127 仍 inactive。新的真实
  `move_right` 才同时激活二者，恢复 visible/targeted、process/physics、normal
  hurtbox 与正确 HUD。
- MCP 返回非空 RGB `1278x718` active、death-clear 与 Coil Pincer active
  screenshots；accepted game log 仅 helper registration info，editor log 为空，
  输入已释放，Godot 已停止并恢复 ready。
- 未运行 full suite；验证限定在 Story081/082 handoff 与直接相邻 encounter。
- 完整证据：
  `production/qa/evidence/old-factory-forward-pressure-coil-rat-production-combat-handoff-2026-07-21.md`。

**Status**: [x] Complete.
