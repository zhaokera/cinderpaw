# Story 196: Old Factory Forward Pressure Route Handoff Marker Production Input Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Input
> **Type**: Integration + Gameplay Runtime + Production Input + Encounter Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story076 已创建 route handoff marker、scene-local persistence、一次性 VFX 与
Story077 beacon ambush gating；Story195 已让玩家通过真实 `interact` 打开
Story075 gate，使 marker 显示且可用。但 marker helper 尚未进入生产输入
仲裁，玩家不能实际点灯。Marker 的 `112px` 交互圈还与 Story077 的
`x=1560` 伏击线重叠，因此直接接线会在点灯同帧把敌人与 vent 生成到玩家
脚下。本 Story 同时完成生产输入和安全的移动武装边界。

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0007 Scene Management;
ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] 在有效 Story195-complete 状态中，玩家位于 Story076 marker 的
  activation radius 内时，一次真实 `interact` rising edge 在不调用 marker
  helper 的情况下点亮 marker。
- [x] Marker 只激活一次，写入
  `factory_lower_deck_forward_pressure_route_handoff_marker_lit=true`，保持
  visible、变为 unavailable，提示为 `Route Beacon Lit`，播放一次既有 unlock
  VFX，并把 HUD 更新为 `Forward Pressure Route Beacon Lit`。
- [x] 同一次 held 输入不会重复 marker VFX、触发 service lift 或产生 lift
  rejection；gate 继续 opened/non-blocking，lift 保持 `Call lift`。
- [x] 玩家可在 marker 范围内且位于 `x>=1560` 时安全点灯。点灯帧及后续
  静止帧只让 Story077 变为 available，不激活敌人或 vent，也不覆盖 marker
  HUD 反馈。
- [x] Marker 已点亮后，只有新的正向位移且当前 `x>=1560` 才启动 Story077
  beacon ambush；向左移动、静止、按住或释放 `interact` 均不能代替移动。
- [x] Story077 启动继续复用既有 entity `2121`、AnimatedSprite2D/
  SpriteFrames、vent、opening pacing 与 route objective，不改变战斗数值。
- [x] 不新增视觉或音频资产；复用已登记的 image-generated marker、unlock
  VFX、Factory Spark Rat、steam vent、gate、relay、lift、Cinderpaw 与环境。
- [x] Thin RED/GREEN、相关回归、180 帧 Factory smoke，以及 Godot 4.7 /
  Godot AI MCP 3.0.4 真实输入、日志与非空截图验收通过。

## Out Of Scope

Story077 敌人/vent 的 AI、伤害、动画、击败流程或数值重做，Story078 overrun，
service-lift destination/SceneManager handoff，gate/relay/savepoint 语义，地图、
新房间、SaveSystem schema、关卡布局调整、新视觉或音频资产。

## Implementation Notes

- Story076 marker 以稳定顺序追加到 lower-deck progression candidates：
  pressure valve、steam sluice、deep bulkhead、forward hatch、exit gate、route
  marker。Availability 使高度重叠的 gate/marker 状态互斥。
- `_process()` 在消费输入前快照 Story077 availability；marker 不能在点亮自身
  的同一帧把新 availability 用于伏击激活。
- Dedicated previous-player-x tracking 要求 Story077 已在帧开始 armed，且
  `current_x > previous_x`、`current_x >= 1560`。即使玩家在阈值右侧点灯，
  也需要下一次实际向右移动才开战，不要求先退回阈值左侧。
- Marker 点亮后的 `Route Beacon Lit` prompt 保留 Story076 已批准合同；本
  Story 不改变 endpoint scene、texture、VFX 或 prompt policy。

## Asset Use

本 Story 不需要 image generation。Marker、unlock spark、Story077 Spark Rat
SpriteFrames、steam vent、gate、relay、service lift、Cinderpaw 与 Factory
环境均已有 source/runtime/metadata 和 manifest/inventory 记录；本次只有生产
输入与 encounter pacing 接线。

## Verification Evidence

- Canonical RED `reports/report_2165/results.xml`：`0/1`，真实 `interact`
  未点亮 available marker。
- Candidate partial GREEN / pacing RED `reports/report_2166/results.xml`：
  marker 已点亮，但 HUD 同帧被 `Clear Forward Pressure Beacon Ambush` 覆盖，
  enemy/vent 立即激活，共五个预期 safety failure。
- Focused GREEN `reports/report_2167/results.xml`：`1/1`。
- Final related GREEN `reports/report_2168/results.xml`：六个 suite、`9/9`，
  零 failure、error、flaky、skip 或 orphan；覆盖 Stories 076/077/192/195、
  Story196 与 lower-deck nearest-candidate arbitration。
- Godot 4.7 对 Factory scene 执行 `180` 帧 headless smoke 并以 `0` 退出；
  `reports/old_factory_forward_pressure_route_handoff_marker_production_input_handoff_smoke.log`
  仅保留既有 Factory cleanup baseline。
- Godot AI MCP 3.0.4 干净运行 `r107886046-23` 在 `(1560,456)` 以真实 held
  `interact` 点亮 marker，确认 VFX `1`、HUD 保留、ambush/vent/lift idle；
  释放后真实 `move_right` 将 Cinderpaw 从 `x=1485` 移至 `x=1577.334`，此时
  Story077 才启动并显示 `Clear Forward Pressure Beacon Ambush`。
- 非空 RGB `1278x718` 截图：
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-route-handoff-marker-production-input-handoff-20260721.png`。
- 完整证据：
  `production/qa/evidence/old-factory-forward-pressure-route-handoff-marker-production-input-handoff-2026-07-21.md`。

**Status**: [x] Complete.
