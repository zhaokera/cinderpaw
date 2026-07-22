# QA Evidence: Old Factory Forward Pressure Route Handoff Marker Production Input Handoff -- 2026-07-21

## Scope

Player Abilities Story196 将 Story076 authored route marker API 接到 Factory
生产 `interact` rising-edge 路径，并修复 marker 交互圈与 Story077 伏击线
重叠导致的同帧开战问题。点灯只武装伏击，新的正向位移才启动战斗。

## TDD Evidence

- `reports/report_2165/results.xml`: canonical RED，`0/1`；marker 不在
  progression candidates 中，真实 `interact` 未点亮 marker。
- `reports/report_2166/results.xml`: candidate 接线后的 pacing RED，`0/1`；
  marker 点亮成功，但 route HUD 立即变为 `Clear Forward Pressure Beacon
  Ambush`，enemy/vent 在玩家静止于 `x=1560` 时激活，共五个 safety failure。
- `reports/report_2167/results.xml`: focused GREEN，`1/1`。
- `reports/report_2168/results.xml`: bounded related GREEN，六个 suite、
  `9/9`，零 failure、error、flaky、skip 或 orphan；覆盖 Story196、Story076
  marker、Story195 gate handoff、nearest progression arbitration、Story192 held
  input latch 与 Story077 ambush contract。
- Godot 4.7 对 `res://scenes/factory_route_transition_shell.tscn` 执行
  `180` 帧 headless smoke 并退出 `0`。保留日志为
  `reports/old_factory_forward_pressure_route_handoff_marker_production_input_handoff_smoke.log`；
  四个 leaked ObjectDB instance 与两个 retained resource 是既有 Factory
  exit cleanup baseline。
- 未运行 full suite；变更面仅为 Story076 production candidate 与 Story077
  safe movement arm boundary。

## Runtime Contract

- Story076 marker 仅在 gate opened、marker unlit、玩家位于脚本定义的
  `112px` activation radius 内时进入 production progression arbitration。
- 一个真实 `interact` edge 调用既有 marker activation API；held input 不产生
  第二个 edge，也不会落入 service lift fallback。
- Marker 点亮一次，持久化 scene-local lit 标记，播放一次 VFX，并保持
  `Route Beacon Lit` / `Forward Pressure Route Beacon Lit` 可读反馈。
- `_process()` 在输入前快照 Story077 availability。点灯帧即使玩家已位于
  `x>=1560`，也不能使用刚产生的 availability 立即开战。
- Dedicated x tracking 要求后续 `current_x > previous_x` 且
  `current_x>=1560`；静止、向左移动、held/released interact 均不触发伏击。
- Story077 真正启动后继续走既有 enemy/vent/pacing/route objective API；
  service lift、gate、relay checkpoint 与 save schema 不变。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `3.0.4`；accepted run `r107886046-23`（run token `23`）。
- Custom Factory scene 以 `autosave=false` 启动，helper live，startup error
  为空；验收前后均显式 release `interact` 与 `move_right`。
- MCP 写入有效 Story195-complete scene-local state，把 physics-disabled
  Cinderpaw 放在阈值重叠点 `(1560,456)`。Pre-interact marker 为
  available/visible/unlit、prompt `Light Route Beacon`、VFX `0`；gate
  opened/non-blocking，ambush unavailable/inactive，lift idle。
- 发送真实 `input_action(interact)` 并保持。Marker 变为 lit、unavailable、
  visible，prompt `Route Beacon Lit`，scene-local flag true，VFX
  `played=true/spawn_count=1`，HUD 精确为
  `Forward Pressure Route Beacon Lit`。
- 输入 held 且玩家静止在 `x=1560` 时，Story077 仅 available；active=false、
  enemy hidden、hazard inactive。Gate 继续 opened/non-blocking；lift
  unactivated、无 exit request/rejection，prompt `Call lift`。
- VFX 消退后将玩家向左移至 `(1485,456)`，状态仍稳定；该帧用于最终截图。
  释放 interact、恢复 player physics 后发送真实 `move_right`，最终位置
  `(1577.33398,456)`；Story077 此时才 active，enemy visible、hazard active，
  route HUD 为 `Clear Forward Pressure Beacon Ambush`。Marker VFX count 保持
  `1`，lift 仍 idle。
- Accepted-run game log 只有 game helper registration info；editor log 为零
  行。停止运行后 editor 恢复 `ready`。
- 截图为非空 `1278x718`、8-bit RGB PNG；可见 Cinderpaw、lit marker、opened
  gate、relay、service lift、`Route Beacon Lit`、`Call lift` 和正确 HUD；
  不可见旧 marker/gate/relay prompt、marker VFX、Spark Rat 或 active vent。
  SHA-256：
  `bae6d2850e2606538b0833963b40a1429123435db3b0a5fc033d1648ec9b395a`。

## Asset Use

未生成新图片。Story196 复用 Story076 已登记的 image-generated endpoint
marker 与 unlock spark，以及 Story077 已登记的 Factory Spark Rat
SpriteFrames、steam vent、Cinderpaw、gate、relay、lift 与 Factory 环境资源。
无需导入路径、层级、动画、manifest 或 entity inventory 变更。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| 真实 rising-edge input 点亮 marker | Canonical RED/GREEN；MCP run 23 | PASS |
| Marker once-only、持久化、VFX、prompt 与 HUD | Focused/related；MCP diagnostics | PASS |
| 阈值重叠点静止/held 不启动伏击 | Pacing RED/GREEN；MCP held probe | PASS |
| 新的正向位移才启动 Story077 | Story196 test；MCP real `move_right` | PASS |
| Gate/lift/relay contract 不串联 | Related；MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 runtime 干净 | Smoke；accepted logs；screenshot | PASS |
