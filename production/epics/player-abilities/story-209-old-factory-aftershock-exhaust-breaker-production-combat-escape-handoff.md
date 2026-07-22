# Story 209: Old Factory Aftershock Exhaust Breaker Production Combat Escape Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat and Interaction Handoff
> **Type**: Integration + Production Movement + Production Combat + Hazard + Production Input
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story208 清除 aftershock exhaust flank 后只让 Story090 可用。本 Story 把
Story090 接入完整生产 ACT 闭环：真实右移启动带预警的蒸汽与 Coil Rat，真实
伤害链完成敌我交锋，两次真实轻攻击击败守卫，再通过真实交互切断断路器，同时
保证 Story091 只进入 available 而不在同帧连锁启动。

**GDD**: design/gdd/player-abilities.md,
design/gdd/exploration-ability-gating.md, design/gdd/feline-combat.md,
design/gdd/collision-detection.md, design/gdd/scene-management.md

**Requirements**: TR-scene-004, TR-explore-005, TR-combat-001,
TR-respawn-002

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management. ADR-0018 and ADR-0021 remain no-change dependencies.

## Acceptance Criteria

- [x] Story089 已清除且 Story090 在帧开始可用时，新的真实
  move_right 正向位移跨过 x 2928 才启动 entity 2133；恢复、瞬移和
  Story089 致死同帧都不能触发。
- [x] 启动后蒸汽先进入 warning 共 21 个物理帧，播放四帧 warning
  动画并关闭 contact；随后才进入 active 并开启接触伤害。
- [x] vent 位于 x 2880、Coil Rat 位于 x 3008，初始中心距 128px；
  玩家跨线时形成后方环境压力与前方敌人的清晰 staging。
- [x] active vent 的真实 Area2D overlap 对 Cinderpaw 造成 8 steam
  damage，并记录 Story090 hazard source、target 1 和 1.0s cooldown。
- [x] Coil Rat 的真实 bite 经过 rat_minion_bite 命中链，记录 attacker
  2133、target 1、weapon factory_coil_rat_bite、final damage 10。
- [x] 两次独立真实 attack 输入经 cat_claw_light 将 entity 2133
  从 24 -> 12 -> 0。
- [x] live death 保持可见/processing 的三帧 death，同时关闭 target、
  physics 和 hurtbox；vent 同步隐藏并停止接触，breaker console 出现。
- [x] breaker 使用 120px 交互半径并进入生产 nearest-interaction 路由；
  新的真实 interact 只切断一次、只生成一次 unlock spark，并将 Story090
  四个持久化状态全部置为 true。
- [x] cut 同帧 Story091 只变为 available。Entities 2134/2135 保持
  hidden、process/physics off、24 HP、hurtbox gone；玩家静止时继续
  inactive，必须等待下一次新鲜正向位移。
- [x] 薄 TDD、五 suite 有界回归、Factory smoke 和 Godot 4.7 /
  Godot AI MCP 3.0.4 运行态、日志及非空截图验收通过。

## Out Of Scope

Story091 实际启动与双敌战斗、完整循环 steam FSM 重做、新角色或环境素材、
新音频/VFX、敌人 AI 重构、伤害/HP 再平衡、SaveSystem schema、新存档点、
service lift、Rat King Phase III 和更深路线内容。

## Implementation Notes

- OldFactoryEntranceScene 为 Story090 增加 runtime-only warning frame
  计数与 phase/contact/animation 诊断，不新增存档键。
- Story090 与 Story091 都在 _process 帧开始快照 availability，并要求
  tracker 已初始化后的正向 x 增量；set_local_state() 重置 tracker。
- 生产交互仲裁把 aftershock breaker 加入最近目标候选链，仍由真实
  Input.interact rising edge 消费。
- 敌人命中表现从实际 Coil Rat attack metadata 转发完整
  weapon_id/target_id/final_damage，不再丢失 bite 诊断字段。
- Story090 诊断 API 对场景启动早期尚未缓存的 vent 节点做空值保护，避免
  MCP probe 将游戏停入 debugger break。

## Asset Use

无需 image generation。复用已登记的 image-generated Cinderpaw、Factory
Coil Rat、动态 steam、breaker console 与 Old Factory 环境；未修改 PNG、
SpriteFrames、import、manifest 或 entity inventory。

## Verification Evidence

- Canonical RED reports/report_2259/results.xml 产生预期失败；实现后
  reports/report_2262/results.xml 首次 focused GREEN。
- 美术/QA 审查将 warning 固化为覆盖 .35s 的 21 个物理帧，并要求真实
  bite 与更宽 staging。Review-hardened RED reports/report_2265/results.xml
  精确暴露 bite metadata 缺少 weapon_id/target_id；修复后
  reports/report_2266/results.xml focused GREEN。
- Final bounded related reports/report_2267/results.xml 覆盖 Story209、
  Story090、Story091、Story208 与 steam vent runtime，共 10/10，零
  failure/error/flaky/skip/orphan。21 帧和诊断空值保护后的 focused
  reports/report_2268/results.xml、reports/report_2269/results.xml
  均为 1/1。未运行 full suite。
- Godot 4.7 Factory 180 帧 smoke 退出 0；日志：
  reports/old_factory_aftershock_exhaust_breaker_production_combat_escape_handoff_smoke.log。
  关键错误词扫描为空，仅保留既有 4 ObjectDB / 2 resources 退出诊断。
- Godot MCP 3.0.4 accepted run r139679441-66 通过真实
  move_right/attack/interact、真实 Area2D overlap 和真实 enemy bite
  完成整条链路。Warning probe 为 warning、remaining 18、contact off；
  hazard 50 -> 42，bite 42 -> 32，Coil 24 -> 12 -> 0。
- Cut 后 Story090 四个状态均为 true，unlock spark count 为 1；Story091
  available/inactive，2134/2135 hidden、process/physics off、24HP。
  Accepted game log 仅 helper registration，editor log 为空，所有输入释放，
  project 已停止并返回 editor ready。
- 非空视觉证据：
  reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-breaker-production-combat-escape-handoff-cut-20260722.png
  （RGBA 1628x1012）。MCP 同时返回非空 1278x718 warning、active/death
  和 cut 截图。
- 完整 QA 记录：
  production/qa/evidence/old-factory-aftershock-exhaust-breaker-production-combat-escape-handoff-2026-07-22.md。

**Status**: [x] Complete.

## Dependencies

- Depends on: Stories 089, 090 and 208.
- Unlocks: Story091 production movement, dual-enemy combat and escape handoff.
