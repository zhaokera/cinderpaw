# QA Evidence: Old Factory Forward Pressure Beacon Ambush Production Combat Handoff -- 2026-07-21

## Scope

Player Abilities Story197 证明 Story077 可由生产移动启动、由真实玩家攻击击败，
并把 Story078 改为清场后一帧稳定、下一次正向位移才启动的安全交接。同时修复
MCP 暴露的左向武器 hitbox 基础偏移未翻转问题。

## TDD Evidence

- `reports/report_2169/results.xml`: 初始 production-combat RED；真实攻击与
  Story077 defeat handoff 尚未闭环。
- `reports/report_2172/results.xml`: 调试 RED 暴露 Factory enemy lookup 在
  已释放早期敌人节点上触发 typed-array invalid-freed-object 错误。
- `reports/report_2175/results.xml` / `report_2176/results.xml`: 调试 RED 证明
  inactive Story078 entity `2122` 的 hurtbox 会抢走当前 2121 命中。
- `reports/report_2180/results.xml`: pre-MCP focused GREEN，`1/1`。
- `reports/report_2181/results.xml`: pre-MCP related GREEN，四个 suite、`6/6`。
- `reports/report_2182/results.xml`: MCP symptom 对应的 left-facing canonical
  RED，`0/1`、零 error，精确失败于 `cat_claw_light` 未位于玩家左侧。
- `reports/report_2183/results.xml`: 最终 focused GREEN，`1/1`。
- `reports/report_2184/results.xml`: 最终 bounded related GREEN，五个 suite、
  `9/9`，零 failure、error、flaky、skip 或 orphan；覆盖 Story197、Story196
  marker handoff、Story077、Story078 及共享 WeaponComponent multi-target/
  single-target 合同。
- Godot 4.7 对 `res://scenes/factory_route_transition_shell.tscn` 执行
  `180` 帧 headless smoke 并退出 `0`。日志为
  `reports/old_factory_forward_pressure_beacon_ambush_production_combat_handoff_smoke.log`；
  四个 leaked ObjectDB instance 与两个 retained resource 是既有 Factory
  exit cleanup baseline。
- 未运行 full suite；最终验证限定在 production handoff、相邻 encounters 与
  共享武器 hitbox surface。

## Runtime Contract

- Story077 只有在 Story076 marker lit 且玩家产生新的正向位移、达到
  `x>=1560` 时启动；既有 entity `2121`、vent、opening grace 与 objective
  合同保持不变。
- 玩家攻击走生产 Input/Combat/Weapon/Collision 链路。基础武器 X offset 按
  facing 翻转；技能 lunge 的调用方有符号 offset 与 range extension 不变。
- Hidden/inactive Story077/078 enemy 的 hurtbox 为 inactive，不能参与玩家
  hitbox detection；defeat queue-free 后 entity lookup 跳过失效实例。
- 2121 defeat callback 写入 activated/defeated、关闭 hazard、刷新 clear HUD，
  并建立一个 clear-frame barrier。
- Story078 在 Story077 clear 后仅 available；`x>=1620` 本身、静止及致命帧
  残余位移不触发。下一次 `current_x > previous_x` 的正向位移才激活 2122。
- Story078 启动继续复用其 existing enemy/vent/pacing/objective，不改变数值、
  SaveSystem schema、service lift 或后续 Story079 breaker。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `3.0.4`；accepted run `r110915930-25`（run token `25`）。
- 停止旧热重载进程后清空日志，custom Factory scene 以 `autosave=false`
  启动；helper live，startup errors 为空。验收结束时 `move_left`、`move_right`
  和 `attack` 全为 released。
- MCP 只用 scene-local state 建立 Story196-complete 前置条件。真实
  `input_action(move_right)` 将玩家越过 `x=1560`，Story077 变为 active，2121
  visible/targeted、vent active，HUD 为 `Clear Forward Pressure Beacon Ambush`。
- 为避免人工检查等待期间敌人杀死玩家，仅把 2121 locomotion physics 冻结并
  固定双方位置；没有调用 encounter `apply_damage`、defeat 或 activation API。
  Enemy hurtbox 保持 collision layer `8`，初始 HP `24`。
- 真实 `move_left` 把玩家从 `x=1644` 移到 `x=1639.333` 并设置 facing `-1`。
  第一次真实 `input_key(J)` 生成 `cat_claw_light`，hitbox 中心
  `x=1616.075`、玩家 `x=1632.075`，物理命中 2121 后 HP `24 -> 12`。
- 命中停顿结束后第二次真实 `input_key(J)` 再次产生相同左向 hitbox，2121
  HP `12 -> 0`。最终命中 metadata：target `2121`、weapon `cat_claw`、attack
  `light`、facing `-1`、damage applied `12`、`damage_was_applied=true`。
- 等待四个 process frame 后：Story077 defeated/hidden、vent inactive、HUD
  `Forward Pressure Beacon Ambush Cleared`；Story078 available 但 inactive，
  entity/vent hidden，local activated flag false。
- 新的真实 `input_action(move_right)` 之后，Story078 local activated flag
  变为 true；entity `2122` visible/targeted、vent active，HUD 为
  `Survive Forward Pressure Overrun`。
- 运行节点
  `/root/FactoryRouteTransitionShellScene/FactoryLowerDeckForwardPressureOverrunSparkRat/Sprite`
  是 visible `AnimatedSprite2D`，当前 animation `run`；`idle`、`run`、
  `attack`、`attack_tell`、`hurt`、`death` 各三帧。
- MCP 返回两张非空 RGB `1278x718` game screenshots。两张均可见有纹理的
  Factory 环境与 Cinderpaw；第一张可见 Story077 Spark Rat/vent，第二张可见
  Story078 Spark Rat/vent 与 `Survive Forward Pressure Overrun` HUD。
- Accepted-run game log 仅一行 game-helper registration info；editor log 为
  零行，没有新增 script/runtime error。游戏已停止，editor 恢复 ready。

## Asset Use

未生成新图片。Story197 复用已登记的 image-generated Factory Spark Rat
SpriteFrames、steam vent、Cinderpaw 与 Factory 环境。没有 source、import、
manifest、entity inventory 或动画资源变更。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| 真实移动启动 Story077 | Story197 test；MCP real `move_right` | PASS |
| 真实攻击与物理碰撞击败 2121 | Direction RED/GREEN；MCP two-hit `J` | PASS |
| 左向 hitbox offset 正确 | `report_2182`/`2183`；MCP positions | PASS |
| Defeat persistence、enemy/hazard/HUD clear | Related tests；MCP diagnostics | PASS |
| 清场帧不串联 Story078 | Story197 test；MCP four-frame stationary probe | PASS |
| 新正向位移才启动 Story078 | Story197 test；MCP real `move_right` | PASS |
| AnimatedSprite2D/SpriteFrames 合同 | MCP runtime node + six 3-frame sets | PASS |
| Godot 4.7 / MCP 3.0.4 runtime 干净 | Smoke；accepted logs；screenshots | PASS |
