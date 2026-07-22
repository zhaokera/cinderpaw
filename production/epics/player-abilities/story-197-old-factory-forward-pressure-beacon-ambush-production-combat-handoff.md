# Story 197: Old Factory Forward Pressure Beacon Ambush Production Combat Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Combat
> **Type**: Integration + Gameplay Runtime + Production Combat + Encounter Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story077 已创建设施下层 forward-pressure beacon ambush、entity `2121`、
Spark Rat 帧动画、蒸汽 vent、持久化与 Story078 gating；Story196 已让真实
右移启动该战斗。但生产玩家攻击尚未被用来证明完整击败路径，而且 Story078
原先可在 Story077 致命帧的残余位移中立即启动，玩家看不到稳定的清场反馈。
本 Story 完成真实战斗击败、碰撞安全和下一 encounter 的两阶段交接。

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/combat-system.md`, `design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-combat-001`, `TR-combat-004`, `TR-scene-004`,
`TR-explore-005`, `TR-respawn-002`

**Governing ADRs**: ADR-0002 Combat System; ADR-0004 Collision Detection;
ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene Management;
ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] 有效 Story196-complete 状态中，真实 `move_right` 启动 Story077，显示
  entity `2121`、Spark Rat、vent 和 `Clear Forward Pressure Beacon Ambush`。
- [x] 真实玩家轻攻击走 `Input.attack -> CombatComponent -> WeaponComponent ->
  CollisionComponent`，产生 `cat_claw_light` 并对 entity `2121` 应用伤害；
  不以 encounter `apply_damage` helper 代替验收命中。
- [x] 左向攻击把基础武器 hitbox offset 放在玩家左侧，命中左侧目标；右向及
  未传 facing 的既有武器合同保持不变。
- [x] entity `2121` 归零后持久化 activated/defeated，移除敌人 hurtbox，关闭
  vent，并显示 `Forward Pressure Beacon Ambush Cleared`。
- [x] Story077 清场至少保持一个稳定 process frame。致命帧残余位移、静止或
  仅处于 `x>=1620` 不得自动启动 Story078。
- [x] Story078 在清场后变为 available，但只有新的正向位移且玩家位于
  `x>=1620` 才启动 entity `2122`、Spark Rat、vent 和 overrun objective。
- [x] 隐藏或 inactive 的后续敌人 hurtbox 不参与当前攻击检测。
- [x] 不新增视觉或音频资产；复用已登记的 image-generated Factory Spark
  Rat SpriteFrames、steam vent、Cinderpaw 与 Factory 环境。
- [x] Thin RED/GREEN、相关回归、180 帧 Factory smoke，以及 Godot 4.7 /
  Godot AI MCP 3.0.4 真实输入、真实碰撞、日志和非空截图验收通过。

## Out Of Scope

Story078 的击败与 Story079 breaker 交接、Spark Rat AI/数值重做、死亡动画
演出时长、service-lift destination/SceneManager handoff、SaveSystem schema、
地图或房间扩建、新视觉或音频素材。

## Implementation Notes

- Story078 使用 dedicated previous-player-x tracking，并在 Story077 defeat
  callback 置一帧 clear barrier；后续 encounter 只能消费下一次新的正向位移。
- Story077/078 inactive 或 defeated 同步会把对应 enemy hurtbox 切为 inactive，
  防止隐藏的 2122 抢走 2121 攻击命中。
- Factory entity lookup 不再构造包含已释放强类型 Node 的临时数组；先以
  `Variant` 遍历并验证实例，再转换为 `Node`，避免早期敌人 queue-free 后真实
  玩家攻击触发 invalid-freed-object 错误。
- `WeaponComponent` 先规范化 `facing`，基础 `weapon.hitbox_offset.x` 按朝向
  翻转；调用方已带符号的技能 lunge offset 保持原语义，range extension 继续
  按 facing 延伸。
- Canonical GdUnit 将 2121 预置到 `12 HP` 以聚焦最后一击与交接；MCP 验收
  则从 `24 HP` 开始，以两次真实 `J` 攻击完成 `24 -> 12 -> 0`。

## Asset Use

本 Story 不需要 image generation。Story077/078 已复用登记过的
image-generated Factory Spark Rat，运行节点使用 `AnimatedSprite2D` +
`SpriteFrames`，`idle`、`run`、`attack`、`attack_tell`、`hurt`、`death`
均为三帧；steam vent、Cinderpaw 与 Factory 环境也已有资产管线记录。

## Verification Evidence

- Canonical production-combat RED 从 `reports/report_2169/results.xml` 开始；
  调试收敛过程中暴露了 stale typed-node lookup、inactive Story078 hurtbox
  抢命中及 hitstop 后输入时序问题。
- Pre-MCP focused/related GREEN：`reports/report_2180/results.xml` 为 `1/1`，
  `reports/report_2181/results.xml` 为四个 suite、`6/6`。
- MCP 发现左向攻击 hitbox 落在玩家右侧后，新增方向回归；
  `reports/report_2182/results.xml` 精确 RED `0/1`，失败于 left-facing offset。
- 最终 focused GREEN `reports/report_2183/results.xml` 为 `1/1`；最终 related
  `reports/report_2184/results.xml` 为五个 suite、`9/9`，零 failure、error、
  flaky、skip 或 orphan。
- Godot 4.7 对 Factory scene 执行 `180` 帧 headless smoke 并以 `0` 退出；
  `reports/old_factory_forward_pressure_beacon_ambush_production_combat_handoff_smoke.log`
  仅保留既有 Factory cleanup baseline。
- Godot AI MCP 3.0.4 clean run `r110915930-25`：真实右移启动 2121；真实左移
  后两次 `J` 轻攻击均产生左侧 `cat_claw_light`，HP `24 -> 12 -> 0`，最终
  metadata 为 target `2121`、`light`、damage `12`、facing `-1`。
- 清场后 Story078 为 available/inactive；新的真实 `move_right` 才启动 2122
  与 vent。运行节点 `.../FactoryLowerDeckForwardPressureOverrunSparkRat/Sprite`
  是 visible `AnimatedSprite2D`，六个动作各三帧。
- MCP 返回两张非空 RGB `1278x718` game screenshot，分别可见 Story077 与
  Story078 的 Factory 实景、Cinderpaw、Spark Rat、vent 和目标 HUD；game
  log 仅 helper registration info，editor log 为空，输入已释放并停止运行。
- 完整证据：
  `production/qa/evidence/old-factory-forward-pressure-beacon-ambush-production-combat-handoff-2026-07-21.md`。

**Status**: [x] Complete.
