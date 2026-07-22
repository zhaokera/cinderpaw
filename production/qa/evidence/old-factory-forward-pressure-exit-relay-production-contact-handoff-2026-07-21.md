# QA Evidence: Old Factory Forward Pressure Exit Relay Production Contact Handoff -- 2026-07-21

## Scope

Player Abilities Story194 将 Story074 的 authored savepoint 接到生产
`Area2D.body_entered` 路径，并验证 Story193 守卫死亡只解锁 relay、relay
接触只解锁 Story075 gate，不会链式开门或触发 service lift。

## TDD Evidence

- `reports/report_2155/results.xml`: canonical RED，`0/1`；entity `2120`
  死亡后 relay 仍隐藏且不可 monitoring，真实移动无法接触激活。
- `reports/report_2156/results.xml`: 初始 focused GREEN，`1/1`。
- `reports/report_2157/results.xml`: 首轮 related 暴露 Story073 的隔离 fixture
  位于新启用 relay 的 contact 半径内；将该 fixture 移出半径后，
  `reports/report_2158/results.xml` 以五个 suite、`8/8` 通过。
- `reports/report_2159/results.xml`: 可读性 RED，`0/1`；MCP 截图发现
  `Repair Exit Relay` 与 `Open Exit Gate` 重叠，测试精确锁定 relay prompt
  激活后仍可见。
- `reports/report_2160/results.xml`: 最终 focused GREEN，`1/1`。
- `reports/report_2161/results.xml`: 最终 bounded related GREEN，七个 suite、
  `11/11`，零 failure、error、flaky、skip 或 orphan；覆盖 Stories
  192/193/073/074/075、Story194 与 service-lift SceneManager contract。
- Godot 4.7 对 `res://scenes/factory_route_transition_shell.tscn` 执行
  `180` 个 fixed frame 并退出 `0`。保留日志为
  `reports/old_factory_forward_pressure_exit_relay_production_contact_handoff_smoke.log`；
  四个 leaked ObjectDB instance 与两个 retained resource 是既有 Factory
  exit cleanup baseline。
- 未运行 full suite；变更面仅为 Story073 defeat 到 Story074 relay contact、
  Story075 gate unlock 与相邻 fixture 隔离。

## Runtime Contract

- Story193 entity `2120` defeat signal 先完成 guard 清理，再 deferred 启用
  relay 的 monitoring、monitorable 与 collision。
- Relay 不参与 `interact` arbitration。玩家真实移动进入 `InteractionArea`
  后，由 `SavepointRuntime.body_entered` 发出 activation。
- Activation 写入 scene-local Story074 标记和精确 checkpoint snapshot，关闭
  relay contact，播放一次既有 image-generated activation VFX，并隐藏旧
  relay prompt。
- Story075 gate 同步为 available/visible/blocking，但保持 unopened；下一次
  独立 `interact` 才能开门。
- Service lift 保持 available 但 unactivated，不产生 SceneManager exit
  request。
- 本 Story 不增加全局 slot-0 autosave；持久化范围遵守 Story074 与
  ADR-0021 的 scene-local contract。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `3.0.4`；accepted run `r102766178-20`（run token `20`）。
- Custom Factory scene 以 `autosave=false` 启动，helper live，startup error
  为空；输入在验收前后均显式 release。
- MCP 恢复有效 Story193 active state，将 Cinderpaw 放在 relay 外侧，并通过
  scene production damage API 击败 entity `2120`。Deferred 更新后 relay
  visible/available/monitoring/monitorable，collision enabled，尚未 activated。
- Cinderpaw 重置到 `(1240,456)`、HP `100` 后发送真实
  `input_action(move_right)`；最终位置 `(1409.9253,455.9253)`，没有调用
  relay activation helper 或 `interact`。
- Relay 最终 activated、unavailable、non-monitoring、non-monitorable、
  collision-disabled；checkpoint 为
  `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory /
  lower_deck_forward_pressure_exit_relay`。
- Activation VFX `played=true`、`spawn_count=1`、来源
  `image_generation`；relay `PromptLabel.visible=false`，HUD 精确显示
  `Forward Pressure Exit Relay Secured`。
- Gate `available=true`、`visible=true`、`opened=false`、
  `collision_blocking=true`，提示 `Open Exit Gate`。Lift
  `activated=false`、`exit_requested=false`，提示 `Call lift`。Exit guard 与
  guard vent 均 absent 或 hidden。
- Current-run game log 只有 game helper registration info；editor log 为零
  行。停止运行后 editor 恢复 `ready`。
- 截图为非空 `1278x718`、8-bit RGB PNG；没有 `Repair Exit Relay` 残留，
  可见 Cinderpaw、cyan relay、关闭 gate、`Open Exit Gate` 与 `Call lift`。
  SHA-256：
  `b1ee9540b427adc1e3d54247d5cc01e52e2ad6ecfd98349c96d6613c0cfc512b`。

## Asset Use

未生成新图片。Story194 复用 Story074 已在 asset manifest 登记的
image-generated relay，以及既有 gate、service lift、activation VFX、
Cinderpaw 和 Factory 环境资源。现有 runtime/source/alpha source/metadata
完整，不需要 transform、`z_index`、导入路径或 manifest 变更。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| 守卫死亡后 relay 安全启用 | RED/GREEN；MCP pre-contact diagnostics | PASS |
| 真实移动 contact 激活，不依赖 helper/interact | Story194 test；MCP run 20 | PASS |
| 精确 checkpoint、once-only 与 contact 关闭 | Focused/related；MCP diagnostics | PASS |
| Relay prompt 隐藏且 gate prompt 清晰 | Readability RED/GREEN；MCP screenshot | PASS |
| Gate 只解锁不打开，lift 不链式触发 | Related；MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 runtime 干净 | Smoke；final logs；screenshot | PASS |
