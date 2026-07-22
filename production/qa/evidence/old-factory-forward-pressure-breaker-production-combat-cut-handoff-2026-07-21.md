# QA Evidence: Old Factory Forward Pressure Breaker Production Combat/Cut Handoff -- 2026-07-21

## Scope

Player Abilities Story199 证明 Story079 可由真实移动启动、由真实玩家攻击击败，
已 secured 的 breaker 可通过生产交互路由切断，并把 Story080 改为 cut 稳定后、
下一次正向位移才启动的安全交接。Story080 inactive enemy hurtbox 同步关闭，
避免 entity `2124` 抢走 2123 的攻击命中。

## TDD Evidence

- `reports/report_2188/results.xml`: canonical RED，`1` test、`15` expected
  failures、`0` errors。失败点覆盖 2124 hurtbox 未关闭、真实 interact 未切断、
  prompt/HUD/VFX/local cut 状态错误，以及后续真实移动不能启动 Story080。
- `reports/report_2190/results.xml`: focused GREEN，`1/1`。
- `reports/report_2191/results.xml`: bounded related GREEN，五个 suite、`7/7`，
  零 failure、error、flaky、skip 或 orphan；覆盖 Story199、Story198、
  Story197、Story079 与 Story080。
- `reports/report_2192/results.xml`: 共享 lower-deck progression interact
  arbitration，`2/2`，零 failure、error、flaky、skip 或 orphan。该 suite 单独
  执行，避免重复运行已由 `report_2191` 覆盖的七个测试。
- `reports/report_2189/results.xml` 是实现过程中发现常量名拼写错误的 compile
  diagnostic，不作为 RED 或通过证据；错误已修复，后续 `2190` 至 `2192`
  均通过。
- Godot 4.7 对 `res://scenes/factory_route_transition_shell.tscn` 执行
  `180` 帧 headless smoke 并退出 `0`。日志为
  `reports/old_factory_forward_pressure_breaker_production_combat_cut_handoff_smoke.log`；
  四个 leaked ObjectDB instance 与两个 retained resource 是既有 Factory
  exit cleanup baseline。
- 未运行 full suite；最终验证限定在 Story079/080 production combat/cut
  handoff、直接相邻 encounter 与共享交互仲裁。

## Runtime Contract

- Story079 只有在 Story078 defeated 且玩家产生新的正向位移、达到
  `x>=1668` 时启动；entity `2123`、vent、pacing 与 objective 合同保持不变。
- 玩家攻击走生产 Input/Combat/Weapon/Collision 链路；MCP 使用实际 Area2D
  物理重叠，不调用 encounter `apply_damage`、defeat 或 activation helper。
- Story080 inactive 时 entity `2124` hidden、hurtbox `gone`；active 时恢复
  `normal`，不能参与 Story079 的攻击候选。
- 2123 defeat callback 原子写入 activated/defeated、关闭 hazard、显示 breaker
  console，并把 objective 更新为 `Cut Forward Pressure`。
- 真实 `interact` 进入既有 nearest-provider arbitration；breaker activation
  原子写入 cut，播放一次 VFX，并建立一个 clear-frame barrier。
- Story080 在 breaker cut 后仅 available；cut 同帧、held、release、静止及
  threshold position 不触发。只有后续 `current_x > previous_x` 且
  `current_x >= 1804` 才激活 2124。
- 本 Story 不改变敌人数值、AI、SaveSystem schema、Story081 或资产合同。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `3.0.4`；accepted clean run `r114202700-29`（run token `29`）。
- Custom Factory scene 以 `autosave=false` 启动，helper live，startup errors
  为空。MCP 只用 scene-local state 建立 Story198-complete 前置条件。
- Story080 初始 inactive：2124 HP `24`、hidden、vent inactive、hurtbox
  `gone`。真实 `input_action(move_right)` 将玩家从 `x=1664` 推进到约
  `x=1687.925` 并启动 Story079；2123 visible/targeted、process/physics
  enabled、breaker vent active，HUD 为 `Secure Forward Pressure Breaker`。
- 仅冻结 2123 locomotion 并固定双方位置，保留 Health、CollisionComponent
  与 Hurtbox。真实 `move_left` 将 facing 设为 `-1`。
- 第一次真实 `input_key(J)` 通过实际物理重叠把 2123 HP `24 -> 12`；第二次
  把 HP `12 -> 0`。最终命中 metadata 为 target `2123`、weapon `cat_claw`、
  hitbox `cat_claw_light`、attack `light`、facing `-1`、damage applied `12`，
  2124 HP 始终为 `24`。
- 稳定 secured 状态中 2123 节点已退出、breaker vent inactive、console
  visible 且 texture 正确，prompt 为 `Cut Pressure`，HUD 为
  `Cut Forward Pressure`；Story080 仍 inactive，2124 hurtbox `gone`。
- 玩家置于 `(1804,456)` 且实际处于 console activation range。真实
  `input_action(interact)` 后 cut/local cut 均为 true，prompt 为
  `Pressure Cut`，HUD 为 `Forward Pressure Breaker Cut`，VFX active/played、
  spawn count `1`。重复真实 interact 后 count 仍为 `1`，Story080 仍 inactive。
- 新的真实 `input_action(move_right)` 将玩家从 `x=1804` 推进到约
  `x=1817` 并激活 Story080；2124 visible/targeted、hurtbox `normal`、HP
  `24`，relief vent active，HUD 为 `Survive Forward Pressure Relief Ambush`。
- 2124 runtime `Sprite` 是 `AnimatedSprite2D`；`idle`、`run`、`attack`、
  `attack_tell`、`hurt`、`death` 各三帧。动态 vent `SteamAnimation` visible、
  playing 且 current animation 为 `active`；`safe`、`warning`、`active` 各四帧。
- MCP 返回两张 accepted 非空 RGB `1278x718` screenshots：secured 画面可见
  有纹理的 Factory、Cinderpaw、breaker console、`Cut Pressure` prompt 和
  `Cut Forward Pressure` HUD；Story080 active 画面可见 2124、动态 steam、
  `Pressure Cut` console 和 `Survive Forward Pressure Relief Ambush` HUD。
- Accepted-run game log 仅一行 game-helper registration info；editor log 为
  零行，没有新增 script/runtime/resource error。`attack`、`interact`、
  `move_left`、`move_right` 均为 released，游戏已停止，editor 恢复 ready。

## Test Determinism Note

Canonical GdUnit 为控制单测时序，先通过既有 `apply_damage` 做一次非致命
`12 HP` setup，再由真实 `Input.attack` 激活玩家 hitbox，并用
`process_detection_frame` 定向注入 enemy hurtbox 完成致命碰撞。该测试证明
输入、攻击状态、命中 metadata、defeat 与交接合同；MCP 则独立证明两次真实
`J` 在实际 Area2D 物理重叠下完成完整 `24 -> 12 -> 0`，两类证据没有混用。

## Asset Use

未生成新图片。Story199 复用已登记的 image-generated Factory Spark Rat
SpriteFrames、动态 steam、breaker console、Cinderpaw 与 Factory 环境。没有
source、import、manifest、entity inventory 或动画资源变更。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| 真实移动启动 Story079 | Story199 test；MCP real `move_right` | PASS |
| 真实攻击与物理碰撞击败 2123 | MCP two-hit `J`，HP `24 -> 12 -> 0` | PASS |
| Inactive 2124 不抢命中 | RED/GREEN；MCP hurtbox gone、HP `24` | PASS |
| Secured enemy/hazard/console/HUD | Related tests；MCP diagnostics | PASS |
| 真实 interact 通过共享仲裁切断 | Story199/arbitration tests；MCP real interact | PASS |
| Cut 同帧、held、release 与静止不串联 | Story199 test；MCP stable cut probe | PASS |
| 新正向位移才启动 Story080 | Story199 test；MCP real `move_right` | PASS |
| AnimatedSprite2D/steam frame contracts | MCP runtime nodes and frame counts | PASS |
| Godot 4.7 / MCP 3.0.4 runtime 干净 | Smoke；accepted logs；screenshots | PASS |
