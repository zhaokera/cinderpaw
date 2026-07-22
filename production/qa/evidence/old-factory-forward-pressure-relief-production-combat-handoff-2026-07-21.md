# QA Evidence: Old Factory Forward Pressure Relief Production Combat Handoff -- 2026-07-21

## Scope

Player Abilities Story200 证明 Story080 可由真实移动启动、由真实玩家攻击击败，
可见死亡帧不会被场景 callback 当帧隐藏，并把 Story081 改为 clear 稳定后、
下一次正向位移才启动的安全交接。Story081 inactive enemy hurtbox 同步关闭，
避免 entity `2125` 抢走 2124 的攻击命中。

## TDD Evidence

- `reports/report_2193/results.xml`: canonical RED，`1` test、`10` expected
  failures、`0` errors。失败点覆盖 2125 hurtbox 未关闭、Story081 提前激活、
  clear HUD 被覆盖、clear frame/fresh movement 合同失效。
- `reports/report_2196/results.xml`: death-presentation RED，`1` test、`1`
  expected failure、`0` errors，精确证明 defeat callback 当帧隐藏了已制作的
  2124 `death` 帧。
- `reports/report_2197/results.xml`: final focused GREEN，`1/1`。
- `reports/report_2198/results.xml`: final bounded related GREEN，四个 suite、
  `6/6`，零 failure、error、flaky、skip 或 orphan；覆盖 Story200、Story199、
  Story080 与 Story081。
- `reports/report_2194` 与 `report_2195` 是死亡反馈审查前的中间 GREEN；最终
  通过证据以加入 death assertions 后的 `2197`、`2198` 为准。
- Godot 4.7 对 `res://scenes/factory_route_transition_shell.tscn` 执行
  `180` 帧 headless smoke 并退出 `0`。日志为
  `reports/old_factory_forward_pressure_relief_production_combat_handoff_smoke.log`；
  四个 leaked ObjectDB instance 与两个 retained resource 是既有 Factory
  exit cleanup baseline。
- 未运行 full suite；最终验证限定在 Story080/081 production combat/death
  handoff 与直接相邻 encounter。

## Runtime Contract

- Story080 只有在 Story079 breaker cut 且玩家产生新的正向位移、达到
  `x>=1804` 时启动；entity `2124`、vent、pacing 与 objective 合同保持不变。
- 玩家攻击走生产 Input/Combat/Weapon/Collision 链路。Canonical test 使用
  定向 detection 保证确定性；MCP 使用实际 Area2D 物理重叠。
- Story081 inactive 时 entity `2125` hidden、hurtbox `gone`、process/physics
  disabled、HP `24`；active 时恢复 `normal`，不能参与 Story080 的攻击候选。
- 2124 defeat callback 原子写入 activated/defeated，立即关闭 body collision、
  hurtbox、target 与 hazard，但保留 visible/process 供 RatMinion 播放三帧
  `death`、短 hold、fade，然后自行 `queue_free`。
- defeat callback 同时建立 clear-frame barrier 并快照玩家 X。Story081 在
  defeat 后只 available；致死 tick 残余位移和静止 process frame不触发。
- 后续只有 `current_x > previous_x && current_x >= 1888` 才自动激活 Story081。
  既有显式 activation API 不变。
- 本 Story 不改变敌人数值、AI、SaveSystem schema、Story082 或资产合同。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `3.0.4`；accepted clean run `r117055706-33`（run token `33`）。
- Custom Factory scene 以 `autosave=false` 启动，helper live，startup errors
  为空。MCP 只用 scene-local state 建立 Story199-complete 前置条件。
- Story081 初始 inactive：2125 HP `24`、hidden、process/physics disabled、
  hurtbox `gone`。真实 `input_key(D)` 将玩家从 `x=1800` 推进到约
  `x=1852.333` 并启动 Story080；2124 visible/targeted、process/physics
  enabled、relief vent active，HUD 为 `Survive Forward Pressure Relief Ambush`。
- Canonical MCP 致死检查只冻结 2124 locomotion，保留 Health、
  CollisionComponent、Hurtbox 与角色 process；双方和隐藏 2125 被放在相同
  `x=1916`，玩家真实 `A` 定向为 `-1`。先用既有 `apply_damage` 做非致命
  `24 -> 12` setup，再用真实 `input_key(J)` 与实际物理重叠完成 `12 -> 0`。
- 最终命中 metadata 为 target `2124`、weapon `cat_claw`、hitbox
  `cat_claw_light`、attack `light`、facing `-1`、damage applied `12`；2125
  HP 仍为 `24` 且 hurtbox `gone`。实现审查前的 clean run `r115678658-30`
  另行证明同一物理链路可用两次真实 `J` 完成完整 `24 -> 12 -> 0`，但不作为
  最终 death-presentation 代码的 accepted run。
- 为避免 MCP 调用延迟错过现有约 `0.4s` death/fade 窗口，最终运行仅在取证时
  临时把 `Engine.time_scale` 降为 `0.05`，截图后恢复 `1.0`；未修改项目配置
  或生产时序。致死状态中 2124 HP `0`、visible，runtime `Sprite` 为
  `AnimatedSprite2D`、animation `death`、sprite visible；body layer/mask `0`、
  hurtbox `gone`、physics off、vent inactive，HUD 为
  `Forward Pressure Relief Ambush Cleared`。
- 恢复正常时速并等待 `0.6s` 后，2124 节点自行退出；2125 仍 available 但
  inactive/hidden、process/physics disabled、hurtbox `gone`、HP `24`，HUD 保持
  clear。新的真实 `input_key(D)` 将玩家从约 `x=1940.075` 推进到
  `x=1961.339`，此时才激活 Story081。
- 激活后的 2125 visible/targeted、process/physics enabled、hurtbox `normal`、
  HP `24`、family `factory_coil_rat`，HUD 为 `Face Coil Rat Breakthrough`。
  Runtime `Sprite` 为 visible `AnimatedSprite2D`；`idle`、`run`、`attack_tell`、
  `attack`、`hurt`、`death` 各三帧。
- MCP 返回三张 accepted 非空 RGB `1278x718` screenshots：Story080 active、
  2124 death-clear、Story081 active。画面可见有纹理的 Factory、Cinderpaw、
  对应敌人/危险物和正确 HUD，不是占位方块。
- Accepted-run game log 仅一行 game-helper registration info；editor log 为
  零行，没有新增 script/runtime/resource error。`attack`、`move_left`、
  `move_right` 均为 released，游戏已停止，editor 恢复 ready。
- `r115678658-31` 与 `r116735354-32` 是已丢弃的检查器实验：前者在节点淡出后
  访问已释放引用，后者的并发 eval 临时节点超时后恢复协程导致 debugger break。
  两者均非项目代码错误，均未作为通过证据；随后停止、清空 debugger，并以
  独立 clean run `33` 重新完成全部最终检查。

## Test Determinism Note

Canonical GdUnit 为控制单测时序，先通过既有 `apply_damage` 做一次非致命
`12 HP` setup，再由真实 `Input.attack` 激活玩家 hitbox，并用
`process_detection_frame` 定向注入 enemy hurtbox 完成致命碰撞。该测试证明
输入、攻击状态、命中 metadata、death presentation、defeat 与交接合同；MCP
则独立证明真实 `J` 在实际 Area2D 物理重叠下完成致死命中，两类证据没有混用。

## Asset Use

未生成新图片。Story200 复用已登记的 image-generated Factory Spark Rat、
Factory Coil Rat SpriteFrames、动态 steam、Cinderpaw 与 Factory 环境。没有
source、import、manifest、entity inventory 或动画资源变更。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| 真实移动启动 Story080 | Story200 test；MCP real `D` | PASS |
| 真实攻击与物理碰撞击败 2124 | Story200 test；MCP real `J` lethal hit | PASS |
| Inactive 2125 不抢命中 | RED/GREEN；MCP hurtbox gone、HP `24` | PASS |
| 2124 death 帧可见且战斗/危险关闭 | Death RED/GREEN；MCP runtime + screenshot | PASS |
| Clear frame 不串联 Story081 | Story200 test；MCP stable clear probe | PASS |
| 新正向位移才启动 Story081 | Story200 test；MCP real `D` | PASS |
| 2125 正常战斗与帧动画合同 | Related tests；MCP runtime nodes/frame counts | PASS |
| Godot 4.7 / MCP 3.0.4 runtime 干净 | Smoke；accepted logs；screenshots | PASS |
