# Story 199: Old Factory Forward Pressure Breaker Production Combat/Cut Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Combat and Input
> **Type**: Integration + Gameplay Runtime + Production Combat + Production Input + Encounter Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story079 已有 forward-pressure breaker encounter、entity `2123`、breaker
console、Spark Rat 帧动画、蒸汽 vent、持久化和 Story080 gating，但验收主要依赖
直接 API。生产交互路由尚未把已 secured 的 breaker 纳入最近 provider 仲裁，
Story080 的 inactive entity `2124` hurtbox 也没有关闭；如果玩家在 `x=1804`
切断 breaker，availability 变化还可能让同帧或残余位移直接启动下一战。本 Story
完成 2123 的生产攻击击败、真实交互切断，以及清晰可读的下一次移动交接。

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/feline-combat.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-combat-001`, `TR-combat-004`, `TR-scene-004`,
`TR-explore-005`, `TR-respawn-002`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management; ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] 有效 Story198-complete 状态中，真实 `move_right` 启动 Story079，显示
  entity `2123`、breaker vent 与 `Secure Forward Pressure Breaker`。
- [x] 真实玩家轻攻击走 `Input.attack -> CombatComponent -> WeaponComponent ->
  CollisionComponent`，使用实际物理重叠把 entity `2123` 从
  `24 HP -> 12 HP -> 0 HP`；最终命中是 `cat_claw_light`、damage `12`、
  facing `-1`。
- [x] Story080 inactive 时 entity `2124` hidden、HP 保持 `24`、hurtbox 为
  `gone`，不参与 Story079 的攻击检测。
- [x] entity `2123` 归零后持久化 secured，移除敌人及 hurtbox、关闭 breaker
  vent、显示 breaker console，prompt 为 `Cut Pressure`，HUD 为
  `Cut Forward Pressure`。
- [x] 真实 `interact` 通过 `handle_factory_interact_input` 和最近 provider 仲裁
  切断 breaker；本地 cut 状态持久化，反馈 VFX 只生成一次，console prompt
  变为 `Pressure Cut`。
- [x] 玩家位于 Story080 阈值 `x=1804` 时，cut 同帧、held input、release 和
  静止 process frame 均不得启动 entity `2124`；HUD 保持
  `Forward Pressure Breaker Cut`。
- [x] breaker cut 后只有新的正向位移才启动 Story080；entity `2124` 恢复
  visible/targeted、hurtbox `normal`、HP `24`，relief vent active，HUD 为
  `Survive Forward Pressure Relief Ambush`。
- [x] Story080 Spark Rat 六个 gameplay animation 各三帧；动态 steam 的
  `safe`、`warning`、`active` 各四帧且 active animation 正在播放。
- [x] 不新增视觉或音频资产；复用已登记的 image-generated Factory Spark
  Rat、steam vent、breaker console、Cinderpaw 与 Factory 环境。
- [x] Thin RED/GREEN、相关回归、共享交互仲裁、180 帧 Factory smoke，以及
  Godot 4.7 / Godot AI MCP 3.0.4 真实输入、真实碰撞、日志和非空截图验收通过。

## Out Of Scope

entity `2124` 的击败、Story081 coil-rat breakthrough、Spark Rat AI/数值重做、
vent 预警或 grace 调整、SaveSystem schema、地图或房间扩建、新视觉或音频素材。

## Implementation Notes

- 已 secured 的 breaker console 加入 lower-deck progression 的最近 provider
  候选，并沿用单 rising-edge 仲裁；切断仍走既有
  `try_activate_factory_lower_deck_forward_pressure_breaker` 合同。
- breaker cut callback 建立一个 clear-frame barrier，同时快照玩家 X。生产
  auto-activation 使用 process-frame 开始时的 availability 快照，并要求
  `current_x > previous_x && current_x >= 1804`，因此 cut、held、release 和
  静止状态不会串联 Story080。
- Story080 inactive 时 entity `2124` hurtbox 切为 `gone`；encounter active
  时恢复为 `normal`。
- Canonical GdUnit 把 2123 非致命预置到 `12 HP`，并用定向 detection 注入
  保证 focused test 确定性；MCP 验收从 `24 HP` 开始，以两次真实 `J` 和
  实际 Area2D 物理重叠完成 `24 -> 12 -> 0`。

## Asset Use

本 Story 不需要 image generation。现有 Factory Spark Rat 使用
`AnimatedSprite2D` + `SpriteFrames`，`idle`、`run`、`attack`、
`attack_tell`、`hurt`、`death` 均为三帧；动态 steam 的三个状态均为四帧。
breaker console、Cinderpaw 与 Factory 环境已有资产管线和 manifest 记录。

## Verification Evidence

- Canonical RED `reports/report_2188/results.xml` 为 `0/1`，十五个预期失败精确
  暴露 inactive 2124 hurtbox、真实 interact 未切断、console/HUD/VFX/local
  cut 状态错误，以及 fresh movement 无法启动 Story080。
- Focused GREEN `reports/report_2190/results.xml` 为 `1/1`；bounded related
  `reports/report_2191/results.xml` 为五个 suite、`7/7`；共享 progression
  interact arbitration `reports/report_2192/results.xml` 为 `2/2`。最终均为零
  failure、error、flaky、skip 或 orphan。
- Godot 4.7 对 Factory scene 执行 `180` 帧 headless smoke 并退出 `0`；日志为
  `reports/old_factory_forward_pressure_breaker_production_combat_cut_handoff_smoke.log`。
- Godot AI MCP 3.0.4 clean run `r114202700-29`：真实右移启动 2123；真实左移
  后两次 `J` 以实际物理重叠完成 HP `24 -> 12 -> 0`，最终 metadata 为
  target `2123`、weapon `cat_claw`、hitbox `cat_claw_light`、facing `-1`、
  damage `12`，同时 2124 保持 `24 HP` 且 hurtbox 为 `gone`。
- secured 状态 enemy/vent 已关闭，console 显示 `Cut Pressure`，HUD 为
  `Cut Forward Pressure`。真实 interact 在 `(1804,456)` 切断 breaker，VFX
  count 为 `1`；同帧、重复 interact 与静止均不启动 Story080，新的真实
  `move_right` 才激活 2124 与动态 steam。
- MCP 返回非空 RGB `1278x718` secured 和 Story080 active screenshots；最终
  画面可见有纹理的 Factory、Cinderpaw、breaker console、2124、动态 steam
  和对应 HUD。Accepted-run game log 仅 helper registration info，editor log
  为空，输入已释放，Godot 已停止并恢复 ready。
- 未运行 full suite；验证限定在 Story079/080 handoff、直接相邻 encounter 与
  共享 interaction arbitration。
- 完整证据：
  `production/qa/evidence/old-factory-forward-pressure-breaker-production-combat-cut-handoff-2026-07-21.md`。

**Status**: [x] Complete.
