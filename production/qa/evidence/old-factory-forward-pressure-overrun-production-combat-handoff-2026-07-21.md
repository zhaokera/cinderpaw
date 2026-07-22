# QA Evidence: Old Factory Forward Pressure Overrun Production Combat Handoff -- 2026-07-21

## Scope

Player Abilities Story198 证明 Story078 可由真实移动启动、由真实玩家攻击击败，
并把 Story079 改为清场稳定后、下一次正向位移才启动的安全交接。Story079
inactive enemy hurtbox 同步关闭，避免 entity `2123` 抢走 2122 的攻击命中。

## TDD Evidence

- `reports/report_2185/results.xml`: canonical RED，`1` test、`7` failures、
  `0` errors。失败点覆盖 2123 hurtbox 未关闭、清场 HUD 被 Story079 覆盖、
  Story079 提前激活，以及后续真实移动不再产生交接变化。
- `reports/report_2186/results.xml`: focused GREEN，`1/1`。
- `reports/report_2187/results.xml`: 最终 bounded related GREEN，四个 suite、
  `6/6`，零 failure、error、flaky、skip 或 orphan；覆盖 Story198、Story197、
  Story078 与 Story079。
- Godot 4.7 对 `res://scenes/factory_route_transition_shell.tscn` 执行
  `180` 帧 headless smoke 并退出 `0`。日志为
  `reports/old_factory_forward_pressure_overrun_production_combat_handoff_smoke.log`；
  四个 leaked ObjectDB instance 与两个 retained resource 是既有 Factory
  exit cleanup baseline。
- 未运行 full suite；最终验证限定在 Story078/079 production handoff 与直接
  相邻 encounter 回归。

## Runtime Contract

- Story078 只有在 Story077 defeated 且玩家产生新的正向位移、达到
  `x>=1620` 时启动；entity `2122`、vent、pacing 与 objective 合同保持不变。
- 玩家攻击走生产 Input/Combat/Weapon/Collision 链路；MCP 使用实际 Area2D
  物理重叠，不调用 encounter `apply_damage`、defeat 或 activation helper。
- Story079 inactive 时 entity `2123` hidden、hurtbox `gone`；active 时恢复
  `normal`，不能参与 Story078 的攻击候选。
- 2122 defeat callback 原子写入 activated/defeated、关闭 hazard、刷新 clear
  HUD，并建立一个 clear-frame barrier。
- Story079 在 Story078 clear 后仅 available；阈值位置、静止及致命帧残余
  位移不触发。清场后的 `current_x > previous_x` 才激活 2123。
- Story079 启动继续复用 existing enemy/vent/pacing/objective，breaker console
  在 2123 defeat 前保持 hidden；不改变数值、SaveSystem schema 或 Story080。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `3.0.4`；accepted clean run `r112550136-28`（run token `28`）。
- Custom Factory scene 以 `autosave=false` 启动，helper live，startup errors
  为空。MCP 只用 scene-local state 建立 Story197-complete 前置条件。
- 真实 `input_action(move_right)` 将玩家从 `x=1614` 推进并启动 Story078；
  2122 visible/targeted、overrun vent active，HUD 为
  `Survive Forward Pressure Overrun`。此时 2123 hidden、HP `24`、hurtbox
  `gone`、breaker vent 与 console hidden。
- 仅冻结 2122 locomotion 并固定双方位置，保留 Health、CollisionComponent
  与 Hurtbox。真实 `move_left` 将 facing 设为 `-1`。
- 第一次真实 `input_key(J)` 通过实际物理重叠把 2122 HP `24 -> 12`；命中
  metadata 为 target `2122`、weapon `cat_claw`、hitbox `cat_claw_light`、
  attack `light`、facing `-1`、damage applied `12`，2123 HP 仍为 `24`。
- 第二次真实 `input_key(J)` 把 2122 HP `12 -> 0`。稳定清场后 2122 节点已
  退出、overrun vent inactive、local activated/defeated 均为 true，HUD 为
  `Forward Pressure Overrun Cleared`。
- 清场状态中 Story079 available 但 inactive；2123 visible/process/physics
  均 false、hurtbox `gone`，breaker vent inactive、console hidden，2123 HP
  仍为 `24`。
- 新的真实 `input_action(move_right)` 令玩家 X 增加并激活 Story079；entity
  `2123` visible/targeted、process/physics enabled、hurtbox `normal`，breaker
  vent active、console hidden，objective 为 `Secure Forward Pressure Breaker`。
- 运行节点
  `/root/FactoryRouteTransitionShellScene/FactoryLowerDeckForwardPressureBreakerSparkRat/Sprite`
  是 visible `AnimatedSprite2D`；`idle`、`run`、`attack`、`attack_tell`、
  `hurt`、`death` 各三帧。
- MCP 返回非空 RGB `1278x718` screenshots：Story078 active、稳定 clear、
  Story079 active 均能看到有纹理的 Factory、Cinderpaw、目标 enemy/vent 和
  对应 HUD。长时间人工取景期间玩家曾触发既有 respawn feedback；最终
  Story079 screenshot 仅恢复当前 objective 文案，不修改 progression、enemy、
  hazard 或 collision 状态，合同判定以激活瞬间的 runtime probe 为准。
- Accepted-run game log 仅一行 game-helper registration info；editor log 为
  零行，没有新增 script/runtime/resource error。`move_left`、`move_right`、
  `attack` 均为 released，游戏已停止，editor 恢复 ready。

## Asset Use

未生成新图片。Story198 复用已登记的 image-generated Factory Spark Rat
SpriteFrames、steam vent、breaker console、Cinderpaw 与 Factory 环境。没有
source、import、manifest、entity inventory 或动画资源变更。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| 真实移动启动 Story078 | Story198 test；MCP real `move_right` | PASS |
| 真实攻击与物理碰撞击败 2122 | MCP two-hit `J`，HP `24 -> 12 -> 0` | PASS |
| Inactive 2123 不抢命中 | RED/GREEN；MCP hurtbox gone、HP `24` | PASS |
| Defeat persistence、enemy/hazard/HUD clear | Related tests；MCP diagnostics | PASS |
| 清场帧不串联 Story079 | Story198 test；MCP stable clear probe | PASS |
| 新正向位移才启动 Story079 | Story198 test；MCP real `move_right` | PASS |
| AnimatedSprite2D/SpriteFrames 合同 | MCP runtime node + six 3-frame sets | PASS |
| Godot 4.7 / MCP 3.0.4 runtime 干净 | Smoke；accepted logs；screenshots | PASS |
