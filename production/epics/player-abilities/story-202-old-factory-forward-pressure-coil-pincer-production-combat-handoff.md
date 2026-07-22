# Story 202: Old Factory Forward Pressure Coil Pincer Production Combat Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Combat
> **Type**: Integration + Gameplay Runtime + Production Combat + Death Feedback + Encounter Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story082 已有 Coil Pincer encounter、entities `2126`/`2127`、双敌持久化和
Story083 gating，但击败验收仍以直接 API 为主。任一 pincer enemy 归零后会被
Factory callback 当帧隐藏；Story083 entity `2128` inactive 时 hurtbox 仍为
`normal`，且第二只 pincer enemy 归零后会立即自动启动 Coil Aftershock。本 Story
完成双敌真实攻击击败、partial-defeat survivor 合同、可见死亡反馈，以及必须经过
稳定 clear frame 和新正向位移的 Story083 安全交接。

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

- [x] 有效 Story201-complete 状态中，真实 `move_right` 启动 Story082，同时激活
  entities `2126`、`2127` 并显示 `Break Coil Pincer`。
- [x] Story083 entity `2128` inactive 时 hidden、process/physics disabled、HP
  保持 `24`、hurtbox 为 `gone`，不参与 pincer 的攻击检测。
- [x] 玩家轻攻击走 `Input.attack -> CombatComponent -> WeaponComponent ->
  CollisionComponent`；仅用直接 API 做非致命 `12 HP` setup，最终致死由真实
  攻击链路完成。MCP 使用实际 Area2D 物理重叠分别击败 2126 与 2127。
- [x] 第一只敌人归零后立即关闭 body collision、hurtbox、target 与 physics，
  但保留 visible/process 播放既有三帧 `death`；另一只敌人继续 visible、targeted、
  process/physics enabled、hurtbox `normal`，HUD 仍为 `Break Coil Pincer`。
- [x] 第二次攻击不能重伤已死亡的第一只敌人，也不能伤害 hidden 2128；survivor
  独立归零后同样保留可见死亡反馈。
- [x] 双敌 defeat 状态持久化，HUD 显示 `Forward Pressure Coil Pincer Cleared`；
  2128 只变为 available，仍 hidden/inactive、hurtbox `gone`、HP `24`。
- [x] defeat 同帧、残余位移、静止或反向位移均不得启动 Story083；只有 clear 后
  新的正向位移满足 `current_x > previous_x && current_x >= 2144` 才启动 2128。
- [x] 激活后的 2128 visible/targeted、process/physics enabled、hurtbox `normal`、
  HP `24`，family 为 `factory_coil_rat`，HUD 为 `Contain Coil Aftershock`。
- [x] Coil Aftershock 保持既定 `8` 帧 opening grace；runtime 使用
  `AnimatedSprite2D` + `SpriteFrames`，六个 gameplay animation 各三帧。
- [x] 不新增视觉或音频资产；复用已登记的 image-generated Factory Spark Rat、
  Factory Coil Rat、Cinderpaw 与 Factory 环境。
- [x] Thin RED/GREEN、相邻回归、180 帧 Factory smoke，以及 Godot 4.7 /
  Godot AI MCP 3.0.4 真实输入、真实碰撞、日志和非空截图验收通过。

## Out Of Scope

entity `2128` 的完整 combat/death 与 Story084 handoff、Spark/Coil Rat AI 或数值
重做、opening grace 调整、pincer 自然站位重叠修整、全局 RatMinion hurt/death
播放时长与尸体停留、SaveSystem schema、地图扩建、新视觉或音频素材。

现有 RatMinion 的 death hold/fade 总时长约 `0.4s`，短于 health/death GDD 的
`0.5-1.0s` 可读窗口；HIT state 约 `5` physics frames，也不足以完整显示三帧
`hurt`。这是共享表现债务，不作为本 Story 已满足项。

## Implementation Notes

- 每个 pincer defeat callback 只同步仍存活的 partner；已死亡目标保持自身 death
  presentation，不会被第二次 callback 提前隐藏。
- death presentation 当帧关闭 body collision、hurtbox、target 与 physics，角色
  节点继续 visible/process，让既有 RatMinion `death`、短 hold 和 fade 完成。
- 第二只敌人归零时建立 clear-frame barrier 并快照玩家 X。生产 auto-activation
  使用 process-frame 开始时的 availability 快照，并要求新的正向位移达到
  `x=2144`，因此致死 tick 残余位移不会串联 Story083。
- Story083 既有显式 activation API 保持不变；本 Story 只收紧生产自动交接。
- Canonical GdUnit 用真实 `Input.attack` 激活玩家 hitbox，并通过定向 detection
  注入保证 focused test 确定性；MCP 最终运行使用真实 `J` 和实际 Area2D 重叠。

## Asset Use

本 Story 不需要 image generation。entities `2126`/`2127`/`2128` 复用现有
96x96 透明 Factory Spark Rat / Factory Coil Rat 帧动画；`idle`、`run`、
`attack`、`attack_tell`、`hurt`、`death` 均为三帧，已有 manifest 与 entity
inventory 记录。

## Verification Evidence

- Canonical RED `reports/report_2203/report_1/results.xml` 为 `0/1`、十八个预期
  failure、零 error，暴露 2128 inactive hurtbox、pincer death 当帧隐藏、
  Story083 提前启动、clear HUD 被覆盖和 fresh-movement 合同缺失。
- Focused GREEN `reports/report_2204/results.xml` 为 `1/1`。首次 related
  `reports/report_2205/results.xml` 为 `5/6`，定位到旧 Story082 对可见死亡的
  过时断言，并暴露第二次 callback 会隐藏已死亡 partner；修复后 final bounded
  related `reports/report_2207/results.xml` 为四个 suite、`6/6`，零 failure、
  error、flaky、skip 或 orphan。
- Godot 4.7 对 Factory scene 执行 `180` 帧 headless smoke 并退出 `0`；日志为
  `reports/old_factory_forward_pressure_coil_pincer_production_combat_handoff_smoke.log`。
- Godot AI MCP 3.0.4 accepted clean run `r119912042-35`：真实右移启动 pincer；
  两次真实 `J` 通过实际物理重叠分别完成 entities `2126`/`2127` 的
  `12 HP -> 0 HP`，最终命中均为 `cat_claw_light`、damage `12`、facing `-1`。
- partial defeat 中第一只敌人保持 visible death 且战斗能力关闭，survivor 保持
  active；full clear 后 2128 仍为 `24 HP`、hidden、hurtbox `gone`。反向移动不
  激活，新真实 `move_right` 才启动 2128 并恢复 normal hurtbox 与正确 HUD。
- MCP 返回非空 RGB `1278x718` pincer active、partial defeat、full clear 与
  Coil Aftershock active screenshots；accepted game log 仅 helper registration
  info，editor log 为空，输入与 `time_scale` 已恢复，Godot 已停止并回到 ready。
- 未运行 full suite；验证限定在 Story081/082/083 production handoff 与直接相邻
  encounter。
- 完整证据：
  `production/qa/evidence/old-factory-forward-pressure-coil-pincer-production-combat-handoff-2026-07-21.md`。

**Status**: [x] Complete.
