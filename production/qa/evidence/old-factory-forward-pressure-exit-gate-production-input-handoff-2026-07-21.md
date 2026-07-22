# QA Evidence: Old Factory Forward Pressure Exit Gate Production Input Handoff -- 2026-07-21

## Scope

Player Abilities Story195 将 Story075 authored gate API 接到 Factory 生产
`interact` rising-edge 路径，并验证一次按住输入只开门，不会连锁点亮
Story076 route marker、启动 beacon ambush 或触发 service lift。

## TDD Evidence

- `reports/report_2162/results.xml`: canonical RED，`0/1`；Story194 状态下
  available gate 不在 progression candidates 中，真实 `interact` 未开门。
- `reports/report_2163/results.xml`: focused GREEN，`1/1`。
- `reports/report_2164/results.xml`: bounded related GREEN，六个 suite、
  `9/9`，零 failure、error、flaky、skip 或 orphan；覆盖 Story195、Story075
  gate、Story076 marker、Story194 relay contact、Story192 input latch 与
  service-lift SceneManager contract。
- Godot 4.7 对 `res://scenes/factory_route_transition_shell.tscn` 执行
  `180` 帧 headless smoke 并退出 `0`。保留日志为
  `reports/old_factory_forward_pressure_exit_gate_production_input_handoff_smoke.log`；
  四个 leaked ObjectDB instance 与两个 retained resource 是既有 Factory
  exit cleanup baseline。
- 未运行 full suite；变更面仅为 Story075 gate 的 production candidate 与
  gate-to-marker prompt handoff。

## Runtime Contract

- Story075 gate 仅在 Story194 relay 已激活、gate 尚未打开且玩家位于
  activation radius 内时进入 production progression arbitration。
- 真实 `interact` rising edge 调用既有 gate open API；held input 不产生第二个
  edge，也不会继续消费新出现的 Story076 marker。
- Gate 激活一次，持久化 scene-local opened 标记，播放一次既有 unlock VFX，
  保持可见并关闭 blocker。
- Gate prompt 跟随 availability；打开后隐藏 `Exit Gate Open`，marker 解锁后
  显示 `Light Route Beacon`。
- Marker 保持 unlit、VFX spawn count `0`；beacon ambush 保持 unavailable /
  inactive；service lift 保持 idle。
- Story194 checkpoint snapshot 不变：
  `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory /
  lower_deck_forward_pressure_exit_relay`。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `3.0.4`；accepted run `r106257818-22`（run token `22`）。
- Custom Factory scene 以 `autosave=false` 启动，helper live，startup error
  为空；输入在验收前后均显式 release。
- MCP 写入有效 Story194-complete scene-local state，把 Cinderpaw 放在 gate
  中心 `(1446,392)` 并暂停其 physics。Pre-interact diagnostics 为 gate
  available/visible/unopened/blocking，prompt `Open Exit Gate`；marker hidden、
  unavailable、unlit；relay checkpoint 精确，lift idle。
- 发送真实 `input_action(interact)` 后保持输入。Held diagnostics 确认 gate
  opened、non-blocking、VFX `played=true/spawn_count=1`、HUD 精确为
  `Forward Pressure Exit Gate Opened`；opened 标记为 true。
- 同一 held 输入中 marker 仅变为 visible/available，仍 unlit、unlock VFX
  spawn count `0`；beacon ambush unavailable/inactive/enemy hidden；lift
  unactivated 且无 exit request。
- Gate 的 `PromptLabel.visible=false`，marker 的
  `PromptLabel.visible=true`，marker prompt 为 `Light Route Beacon`；旧 gate
  prompt 不与 marker 文字重叠。
- 释放 interact 后，以正确的两参数 runtime API 将 Cinderpaw 放到
  `(1400,456)`，再发送真实 `move_right`；最终位置
  `(1481.6671,456)`，证明已穿过原 gate blocker。
- 一个较早的非验收 run 因 MCP-only 验收脚本误用单参数 `respawn_at` 而废弃；
  项目源码未因此修改。停止、清空日志并重启后，accepted run `22` 从干净状态
  重做全部输入与 diagnostics。
- Accepted-run game log 只有 game helper registration info；editor log 为零
  行。停止运行后 editor 恢复 `ready`。
- 截图为非空 `1278x718`、8-bit RGB PNG；可见 Cinderpaw、relay、opened
  gate、route marker、service lift、`Forward Pressure Exit Gate Opened`、
  `Light Route Beacon` 与 `Call lift`，不可见旧 gate/relay prompt。SHA-256：
  `84937157501bf61f9f3cb897b70cdb73c25110038c90048d2467ceb1596cf0d3`。

## Asset Use

未生成新图片。Story195 复用已在 asset manifest 登记的 image-generated
gate、marker、relay、service lift、unlock VFX、Cinderpaw 与 Factory 环境
资源。现有 runtime/source/alpha source/metadata 完整，不需要导入路径、层级、
动画或 manifest 变更。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| 真实 rising-edge input 开门，不调用 helper | Story195 RED/GREEN；MCP run 22 | PASS |
| Gate once-only、持久化、VFX、HUD 与 blocker | Focused/related；MCP diagnostics | PASS |
| Gate prompt 隐藏，marker prompt 清晰 | Story195 test；MCP screenshot | PASS |
| Held input 不连锁 marker/ambush/lift | Story195/192 related；MCP held diagnostics | PASS |
| 真实移动穿过 opened gate | MCP `move_right` position evidence | PASS |
| Godot 4.7 / MCP 3.0.4 runtime 干净 | Smoke；accepted logs；screenshot | PASS |
