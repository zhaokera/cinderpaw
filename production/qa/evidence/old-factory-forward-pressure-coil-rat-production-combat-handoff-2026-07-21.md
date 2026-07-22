# QA Evidence: Old Factory Forward Pressure Coil Rat Production Combat Handoff -- 2026-07-21

## Scope

Player Abilities Story201 证明 Story081 可由真实移动启动、由真实玩家攻击击败，
可见死亡帧不会被场景 callback 当帧隐藏，并把 Story082 改为 clear 稳定后、
下一次正向位移才启动的安全交接。Story082 inactive enemy hurtbox 同步关闭，
避免 entities `2126`、`2127` 抢走 2125 的攻击命中。

## TDD Evidence

- `reports/report_2199/results.xml`: canonical RED，`1` test、`19` expected
  failures、`0` errors。失败点覆盖 inactive pincer hurtbox 未关闭、两个隐藏敌人
  均被误伤、2125 death 帧不可见、Story082 提前激活、clear HUD 被覆盖和 fresh
  movement 合同失效。
- `reports/report_2200/results.xml`: final focused GREEN，`1/1`。
- `reports/report_2201/results.xml`: 首次 bounded related run，四个 suite 中唯一
  失败证明 direct-defeat 路径没有关闭 2125 physics；据此补上 death presentation
  的 physics shutdown。
- `reports/report_2202/results.xml`: final bounded related GREEN，四个 suite、
  `6/6`，零 failure、error、flaky、skip 或 orphan；覆盖 Story200、Story201、
  Story081 与 Story082。
- Godot 4.7 对 `res://scenes/factory_route_transition_shell.tscn` 执行
  `180` 帧 headless smoke 并退出 `0`。日志为
  `reports/old_factory_forward_pressure_coil_rat_production_combat_handoff_smoke.log`；
  四个 leaked ObjectDB instance 与两个 retained resource 是既有 Factory exit
  cleanup baseline。
- 未运行 full suite；最终验证限定在 Story081/082 production combat/death
  handoff 与直接相邻 encounter。

## Runtime Contract

- Story081 只有在 Story080 relief cleared 且玩家产生新的正向位移、达到
  `x>=1888` 时启动；entity `2125`、pacing 与 objective 合同保持不变。
- 玩家攻击走生产 Input/Combat/Weapon/Collision 链路。Canonical test 使用
  定向 detection 保证确定性；MCP 使用实际 Area2D 物理重叠。
- Story082 inactive 时 entities `2126`、`2127` hidden、hurtbox `gone`、
  process/physics disabled、HP `24`；active 时恢复 `normal`，不能参与 Story081
  的攻击候选。
- 2125 defeat callback 原子写入 activated/defeated，立即关闭 body collision、
  hurtbox、target 与 physics，但保留 visible/process 供 RatMinion 播放三帧
  `death`、短 hold、fade，然后自行 `queue_free`。
- defeat callback 同时建立 clear-frame barrier 并快照玩家 X。Story082 在
  defeat 后只 available；致死 tick 残余位移和静止 process frame 不触发。
- 后续只有 `current_x > previous_x && current_x >= 2016` 才自动激活 Story082。
  既有显式 activation API 不变。
- 本 Story 不改变敌人数值、AI、SaveSystem schema、Story083 或资产合同。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `3.0.4`；accepted clean run `r118359094-34`（run token `34`）。
- Custom Factory scene 以 `autosave=false` 启动，helper live，startup errors
  为空。MCP 只用 scene-local state 建立 Story200-complete 前置条件。
- Story082 初始 inactive：2126/2127 HP 均为 `24`、hidden、process/physics
  disabled、hurtbox `gone`。真实 `input_key(D)` 将玩家从 `x=1884` 推进到约
  `x=1889.925` 并启动 Story081；2125 visible/targeted、process/physics
  enabled，HUD 为 `Face Coil Rat Breakthrough`。
- Canonical MCP 致死检查只冻结 2125 locomotion，保留 Health、
  CollisionComponent、Hurtbox 与角色 process；2125 和隐藏的 2126/2127 被放在
  相同 `x=2044`，玩家从 `x=2076` 真实 `A` 定向到 `-1`。先用既有
  `apply_damage` 做非致命 `24 -> 12` setup，再用真实 `input_key(J)` 与实际
  物理重叠完成 `12 -> 0`。
- 最终命中 metadata 为 target `2125`、weapon `cat_claw`、hitbox
  `cat_claw_light`、attack `light`、facing `-1`、damage applied `12`；
  2126/2127 HP 仍为 `24` 且 hurtbox `gone`。
- 为避免 MCP 调用延迟错过现有约 `0.4s` death/fade 窗口，最终运行仅在取证时
  临时把 `Engine.time_scale` 降为 `0.05`，截图后恢复 `1.0`；未修改项目配置
  或生产时序。致死状态中 2125 HP `0`、visible，runtime `Sprite` 为
  `AnimatedSprite2D`、animation `death`；body layer/mask `0`、hurtbox `gone`、
  physics off，HUD 为 `Forward Pressure Coil Rat Breakthrough Cleared`。
- 恢复正常时速并等待 `0.6s` 后，2125 节点自行退出；2126/2127 仍 available
  但 inactive/hidden、process/physics disabled、hurtbox `gone`、HP `24`。
  新的真实 `input_key(D)` 将玩家从约 `x=2070.075` 推进到 `x=2085.742`，
  此时才同时激活 Story082。
- 激活后的 2126/2127 均 visible/targeted、process/physics enabled、hurtbox
  `normal`、HP `24`，family 分别为 `factory_spark_rat` 与 `factory_coil_rat`，
  HUD 为 `Break Coil Pincer`。两个 runtime `Sprite` 都是 visible
  `AnimatedSprite2D`；`idle`、`run`、`attack_tell`、`attack`、`hurt`、`death`
  各三帧，opening grace totals 保持 `10/26`。
- 为最终截图临时把两个敌人分开摆放并冻结 locomotion，未写回场景或资源。
  MCP 返回三张 accepted 非空 RGB `1278x718` screenshots：Story081 active、
  2125 death-clear、Story082 active。画面可见有纹理的 Factory、Cinderpaw、
  对应动画敌人和正确 HUD，不是占位方块。
- Accepted-run game log 仅一行 game-helper registration info；editor log 为
  零行，没有新增 script/runtime/resource error。所有 input action 均 released，
  游戏已停止，editor 恢复 ready。

## Test Determinism Note

Canonical GdUnit 为控制单测时序，先通过既有 `apply_damage` 做一次非致命
`12 HP` setup，再由真实 `Input.attack` 激活玩家 hitbox，并用
`process_detection_frame` 定向注入 enemy hurtbox 完成致命碰撞。该测试证明
输入、攻击状态、命中 metadata、death presentation、defeat 与交接合同；MCP
则独立证明真实 `J` 在实际 Area2D 物理重叠下完成致死命中，两类证据没有混用。

## Asset Use

未生成新图片。Story201 复用已登记的 image-generated Factory Spark Rat、
Factory Coil Rat SpriteFrames、Cinderpaw 与 Factory 环境。没有 source、import、
manifest、entity inventory 或动画资源变更。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| 真实移动启动 Story081 | Story201 test；MCP real `D` | PASS |
| 真实攻击与物理碰撞击败 2125 | Story201 test；MCP real `J` lethal hit | PASS |
| Inactive 2126/2127 不抢命中 | RED/GREEN；MCP hurtbox gone、HP `24` | PASS |
| 2125 death 帧可见且战斗能力关闭 | Related GREEN；MCP runtime + screenshot | PASS |
| Clear frame 不串联 Story082 | Story201 test；MCP stable clear probe | PASS |
| 新正向位移才启动 Story082 | Story201 test；MCP real `D` | PASS |
| Coil Pincer 战斗与帧动画合同 | Related tests；MCP runtime/frame counts | PASS |
| Godot 4.7 / MCP 3.0.4 runtime 干净 | Smoke；accepted logs；screenshots | PASS |
