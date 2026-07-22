# Story 195: Old Factory Forward Pressure Exit Gate Production Input Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Input
> **Type**: Integration + Gameplay Runtime + Production Input + Route Readability
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story075 已创建 forward-pressure exit gate、阻挡碰撞、scene-local persistence
与一次性 unlock VFX；Story194 已把前置 relay 接到生产 contact，并让 gate 在
checkpoint 激活后显示且可用。但生产 `interact` 仲裁尚未包含 gate，玩家只能
通过测试 helper 开门。本 Story 把既有 gate API 接入真实 rising-edge 输入，
并把旧 gate prompt 干净交接给 Story076 route marker。

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`

**Governing ADRs**: ADR-0002 Event Bus; ADR-0004 Collision Detection;
ADR-0007 Scene Management; ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] 在有效 Story194-complete 状态中，玩家进入 Story075 gate 的 activation
  radius 后，一次真实 `interact` rising edge 在不调用 gate helper 的情况下
  打开 gate。
- [x] Gate 只激活一次，写入
  `factory_lower_deck_forward_pressure_exit_gate_opened=true`，播放一次既有
  unlock VFX，并把 HUD 更新为 `Forward Pressure Exit Gate Opened`。
- [x] 打开后 gate 保持可见，但变为 unavailable、non-blocking；玩家可通过
  真实 `move_right` 穿过原阻挡位置。
- [x] 已打开 gate 的 `Exit Gate Open` prompt 隐藏；Story076 marker 显示、
  available、unlit，且 `Light Route Beacon` prompt 清晰可见。
- [x] 同一次按住的 `interact` 不会连锁点亮 marker、播放 marker VFX、启动
  beacon ambush 或触发 service lift。
- [x] Story194 relay 的精确 checkpoint 保持不变；service lift 保持
  unactivated、无 exit request，提示仍为 `Call lift`。
- [x] 不新增视觉或音频资产；复用已登记的 image-generated gate、marker、
  relay、lift、VFX、Cinderpaw 与 Factory 环境资源。
- [x] Thin RED/GREEN、相关回归、180 帧 Factory smoke，以及 Godot 4.7 /
  Godot AI MCP 3.0.4 真实输入、日志与非空截图验收通过。

## Out Of Scope

Story076 marker 的生产输入接线、marker 点亮/VFX、beacon ambush、service-lift
路由、SceneManager handoff、存档 schema、新敌人、新战斗调优、新视觉或音频
资产。

## Implementation Notes

- Story075 gate 以稳定顺序追加到 lower-deck progression candidates：pressure
  valve、steam sluice、deep bulkhead、forward hatch、forward-pressure exit gate。
- 继续由生产 `_process()` 的 interact rising-edge latch 驱动；一次边沿只选择
  一个最近候选，不绕过既有 availability 与 activation-radius 判断。
- Gate 状态同步时让 `PromptLabel.visible` 跟随 `available`。因此 gate 打开后
  prompt 立即隐藏，而相距约 `90.6px` 的 Story076 marker prompt 可以独立显示。
- Marker 本身不在本 Story 加入 production candidate，确保当前切片只完成
  gate opening handoff；marker 点亮需要后续独立输入边沿。

## Asset Use

本 Story 不需要 image generation。Gate、marker、relay、service lift、unlock
VFX、Cinderpaw 与 Factory 环境均已有导入资源及 manifest 记录；本次只有生产
输入与 prompt 可读性接线，没有新增 placeholder、单帧角色或资产条目。

## Verification Evidence

- Canonical RED `reports/report_2162/results.xml`：`0/1`，真实 `interact`
  未打开 available gate。
- Focused GREEN `reports/report_2163/results.xml`：`1/1`。
- Final related GREEN `reports/report_2164/results.xml`：六个 suite、`9/9`，
  零 failure、error、flaky、skip 或 orphan；覆盖 Stories 075/076/192/194、
  Story195 与 service-lift SceneManager contract。
- Godot 4.7 对 Factory scene 执行 `180` 帧 headless smoke 并以 `0` 退出；
  `reports/old_factory_forward_pressure_exit_gate_production_input_handoff_smoke.log`
  仅保留既有 Factory cleanup baseline。
- Godot AI MCP 3.0.4 干净运行 `r106257818-22` 通过真实 `interact` 打开 gate，
  在输入仍 held 时确认 marker unlit、VFX `0`、ambush inactive、lift idle；随后
  真实 `move_right` 将 Cinderpaw 从 `x=1400` 移到 `x=1481.6671`，穿过已关闭
  collision 的 gate。
- 非空 RGB `1278x718` 截图：
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-exit-gate-production-input-handoff-20260721.png`。
- 完整证据：
  `production/qa/evidence/old-factory-forward-pressure-exit-gate-production-input-handoff-2026-07-21.md`。

**Status**: [x] Complete.
