# Story 194: Old Factory Forward Pressure Exit Relay Production Contact Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Savepoint Contact
> **Type**: Integration + Gameplay Runtime + Production Contact + Savepoint Readability
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story074 已创建 forward-pressure exit relay、稳定 checkpoint contract 与
scene-local persistence；Story193 已把前置 entity `2120` 接入真实移动战斗。
但生产场景中，守卫死亡后 relay 不会启用，玩家也无法通过
`Area2D.body_entered` 触发存档点。本 Story 补齐守卫死亡到 relay、relay 到
exit gate 的生产 handoff，并保留 gate 与 service lift 的独立操作边界。

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`, `TR-respawn-002`

**Governing ADRs**: ADR-0002 Event Bus; ADR-0004 Collision Detection;
ADR-0007 Scene Management; ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] 在有效 Story193 状态中击败 entity `2120` 后，relay 在安全的 deferred
  physics 更新中显示并启用 `InteractionArea`，提示为
  `Repair Exit Relay`。
- [x] 不调用 relay 激活 helper、也不按 `interact`；真实 `move_right` 让
  Cinderpaw 进入 `Area2D` 后，由 `SavepointRuntime.body_entered` 激活 relay。
- [x] 激活只发生一次，并写入稳定 checkpoint：
  `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory /
  lower_deck_forward_pressure_exit_relay`。
- [x] 激活后 relay 不再 available，monitoring/monitorable 与 collision
  均关闭，`Repair Exit Relay` 隐藏，HUD 显示
  `Forward Pressure Exit Relay Secured`。
- [x] Story075 gate 仅变为 visible、available、blocking，保持
  `opened=false` 并显示 `Open Exit Gate`；relay 接触不能链式开门。
- [x] Service lift 保持 unactivated、无 exit request，提示仍为
  `Call lift`。
- [x] 不新增视觉或音频资产；复用已登记的 image-generated relay、gate、
  lift、VFX、Cinderpaw 与 Factory 环境资源。
- [x] Thin RED/GREEN、相关回归、180 帧 Factory smoke，以及 Godot 4.7 /
  Godot AI MCP 3.0.4 真实输入、日志与非空截图验收通过。

## Out Of Scope

全局 slot-0 `SaveSystem` 自动写盘、存档 schema 变更、Story075 真实开门输入、
service-lift 路由、SceneManager handoff、新敌人、新战斗调优、新视觉/音频资产。

## Implementation Notes

- Entity `2120` 的死亡回调立即同步守卫状态，并以 deferred collision 更新启用
  Story074 relay，避免在 physics callback 中直接改变 monitoring 状态。
- Relay 继续使用既有 `SavepointRuntime`；生产逻辑不把它加入
  `interact` arbitration。
- Relay activation signal 持久化 Story074 状态后 deferred 同步 Story075
  gate。Gate 只解锁，不调用其 activation API。
- Relay prompt 的可见性跟随 `available`，避免已完成 relay 的提示与新出现
  gate 提示重叠。
- Story073 的持久化测试把玩家移出 relay contact 半径，维持该 Story 的隔离
  边界；生产行为由 Story194 测试覆盖。

## Asset Use

本 Story 不需要 image generation。继续复用
`assets/environment/old_factory_lower_deck_breach_relay/` 下已导入、已登记的
relay 资产，以及既有 gate、service lift、savepoint activation VFX 和角色/
环境资源；没有新增 placeholder、单帧角色或 manifest 条目。

## Verification Evidence

- Canonical RED `reports/report_2155/results.xml`：单个生产接触测试因守卫死亡
  后 relay 未启用而失败。
- 初始 GREEN `reports/report_2156/results.xml`；相关回归
  `reports/report_2157/results.xml` 暴露 Story073 fixture 位于新 relay 半径内，
  隔离修正后 `reports/report_2158/results.xml` 通过 `8/8`。
- 可读性 RED `reports/report_2159/results.xml` 精确捕获激活后 relay prompt
  未隐藏；focused GREEN `reports/report_2160/results.xml` 通过 `1/1`。
- 最终 related GREEN `reports/report_2161/results.xml` 覆盖 Stories
  192/193/073/074/075、Story194 与 service lift，共 `11/11`，零 failure、
  error、flaky、skip 或 orphan。
- Godot 4.7 对 Factory scene 执行 `180` 帧 headless smoke 并以 `0` 退出；
  `reports/old_factory_forward_pressure_exit_relay_production_contact_handoff_smoke.log`
  仅保留既有 Factory cleanup baseline。
- Godot AI MCP 3.0.4 干净运行 `r102766178-20` 以真实 `move_right` 将玩家从
  `x=1240` 移至 `x=1409.9253`，确认精确 checkpoint、once-only VFX、隐藏
  relay prompt、关闭且阻挡的 gate、idle lift、helper-only game log 与空
  editor log。
- 非空 RGB `1278x718` 截图：
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-exit-relay-production-contact-handoff-20260721.png`。
- 完整证据：
  `production/qa/evidence/old-factory-forward-pressure-exit-relay-production-contact-handoff-2026-07-21.md`。

**Status**: [x] Complete.
