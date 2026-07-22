# QA Evidence: Old Factory Aftershock Exhaust Breaker Production Combat Escape Handoff -- 2026-07-22

## Scope

Player Abilities Story209 将 Story090 接入真实移动、warning/active 蒸汽、
Coil Rat bite、玩家轻攻击、live death、断路器交互和 Story091 安全交接。
本切片不新增素材、经济规则、存档 schema 或房间。

## TDD And Regression Evidence

- reports/report_2259/results.xml: canonical RED，25 个预期断言失败。
- reports/report_2262/results.xml: 第一版 focused GREEN，1/1。
- reports/report_2265/results.xml: review-hardened RED，仅剩真实 bite
  metadata 的 weapon_id/target_id 两项失败。
- reports/report_2266/results.xml: metadata 修复后 focused GREEN，1/1。
- reports/report_2267/results.xml: 最终五 suite bounded related，
  10/10，零 failure/error/flaky/skip/orphan。
- reports/report_2268/results.xml: warning 改为 21 physics frames 后
  focused GREEN，1/1。
- reports/report_2269/results.xml: MCP 早期诊断空值保护后 focused GREEN，
  1/1。
- Factory 180 帧 headless smoke 退出 0；日志：
  reports/old_factory_aftershock_exhaust_breaker_production_combat_escape_handoff_smoke.log。
  项目 script/parse/invalid-call/access/resource-load 关键错误词为空，仅有既有
  4 ObjectDB / 2 resources 退出诊断。
- 未运行 full suite。

## Godot MCP Runtime Evidence

- Session cinderpaw@1311；Godot 4.7-stable；Godot AI MCP
  plugin/server 3.0.4。
- Accepted run r139679441-66 启动
  res://scenes/factory_route_transition_shell.tscn，autosave=false，
  helper live。
- 为稳定采样短暂使用 Engine.max_fps=5；真实 move_right 从 x 2927.5
  跨过 2928，Story090 启动。Probe 返回 warning、remaining 18、
  contact off、四帧 warning 动画、entity 2133 visible/targeted。
- 初始 vent/Coil 中心距 128px（x 2880/3008）。MCP screenshot 证明
  Cinderpaw、动态蒸汽和 Coil Rat 均为可见美术，不是方块占位。
- Warning 结束后真实 Area2D overlap 记录 Story090 source、target 1、
  final damage 8，玩家 HP 50 -> 42。
- 真实 Coil Rat attack sequence 经 rat_minion_bite 记录 attacker 2133、
  target 1、weapon factory_coil_rat_bite、final damage 10，玩家
  HP 42 -> 32。
- 两个独立真实 attack 输入自然命中 cat_claw_light，entity 2133
  24 -> 12 -> 0。Live death 为 death，visible/process on，
  physics/target/hurtbox off；vent hidden/contact off，breaker visible。
- 玩家位于 grounded x 3116 时真实 interact 切断 breaker；四个 Story090
  状态均 true，unlock spark count 1。Story091 available 但 inactive，
  entities 2134/2135 hidden、process/physics off、24HP；静止等待后仍未激活。
- Accepted game log 只有 helper registration info，editor log 为空；所有
  gameplay input 均为 released，project 停止后 editor ready。
- Exploratory run 64 在场景启动早期调用诊断时暴露 vent 节点空值缺口；实现
  null guard、focused 回归并清日志后，run 66 完整替代该运行。

## Visual Evidence

- MCP 返回非空 RGB 1278x718 warning、active/death 和 cut screenshots。
- 本地保留的 cut 截图：
  reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-breaker-production-combat-escape-handoff-cut-20260722.png
  为非空 RGBA 1628x1012，清楚显示 authored Factory 环境、Cinderpaw、
  breaker console 和 Exhaust Cut 状态。

## Asset Use

未新增视觉素材。复用已登记的 image-generated Cinderpaw、Factory Coil Rat、
动态 steam、breaker console 与 Factory 环境，不修改 asset manifest 或
entity inventory。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Fresh movement activates Story090 | Canonical; MCP real input | PASS |
| 21-frame warning keeps contact off | Focused; MCP warning probe | PASS |
| Real steam overlap deals 8 | Canonical; MCP hazard metadata | PASS |
| Coil Rat bite metadata is complete | Canonical; MCP attack metadata | PASS |
| Two real attacks defeat entity 2133 | Canonical; MCP 24 -> 12 -> 0 | PASS |
| Live death opens breaker | Related tests; MCP state/screenshot | PASS |
| Real interact cuts exactly once | Canonical; MCP input/state | PASS |
| Story091 stays available/inactive | Canonical; MCP stationary probe | PASS |
| Godot 4.7 / MCP 3.0.4 logs are clean | Smoke; accepted run 66 | PASS |
