# QA Evidence: Old Factory Forward Pressure Coil Pincer Production Combat Handoff -- 2026-07-21

## Scope

Player Abilities Story202 证明 Story082 的双敌夹击可由真实玩家攻击逐个击败，
partial defeat 不会关闭 survivor，双方死亡帧不会被 Factory callback 当帧隐藏，
并把 Story083 改为 full clear 稳定后、下一次正向位移才启动的安全交接。Story083
inactive hurtbox 同步关闭，避免 entity `2128` 抢走 pincer 攻击命中。

## TDD Evidence

- `reports/report_2203/report_1/results.xml`: canonical RED，`1` test、`18`
  expected failures、`0` errors。失败点覆盖 inactive 2128 hurtbox、pincer death
  不可见、partial/full-clear 状态错误、Story083 提前激活、clear HUD 被覆盖与
  fresh-movement 合同缺失。
- `reports/report_2204/results.xml`: focused GREEN，`1/1`。
- `reports/report_2205/results.xml`: 首次 bounded related run，四个 suite、
  `5/6`。唯一旧 Story082 failure 位于 line 189，证明既有断言仍要求 final death
  当帧隐藏；同轮检查也发现第二次 defeat callback 会隐藏已死亡 partner。
- `reports/report_2207/results.xml`: final bounded related GREEN，四个 suite、
  `6/6`，零 failure、error、flaky、skip 或 orphan。Canonical test 的第二次
  碰撞候选同时包含 hidden 2128、已死亡 2126 与存活 2127，证明前两者不被重伤。
- Godot 4.7 对 `res://scenes/factory_route_transition_shell.tscn` 执行
  `180` 帧 headless smoke 并退出 `0`。日志为
  `reports/old_factory_forward_pressure_coil_pincer_production_combat_handoff_smoke.log`；
  四个 leaked ObjectDB instance 与两个 retained resource 是既有 Factory exit
  cleanup baseline。
- 未运行 full suite；最终验证限定在 Story081/082/083 production handoff 与
  直接相邻 encounter。

## Runtime Contract

- Story082 仍由 Story201 clear 后的新正向位移启动；双敌 opening grace
  `10/26`、HP `24/24`、family 与 objective 合同保持不变。
- 玩家攻击走生产 Input/Combat/Weapon/Collision 链路。Canonical test 使用定向
  detection 保证确定性；MCP 使用实际 Area2D 物理重叠。
- Story083 inactive 时 entity `2128` hidden、hurtbox `gone`、process/physics
  disabled、HP `24`；active 时恢复 `normal`，不能参与 Story082 攻击候选。
- 任一 pincer enemy defeat 时立即关闭 body collision、hurtbox、target 与
  physics，但保留 visible/process 供 RatMinion 播放三帧 `death`、短 hold、fade。
  仅同步仍存活的 partner，避免后一次 callback 提前隐藏先死亡的角色。
- partial defeat 中 survivor 维持完整战斗状态与 `Break Coil Pincer` HUD。
  full clear 原子写入双敌 defeat 持久化，并建立 clear-frame barrier、快照玩家 X。
- Story083 在 full clear 后只 available；致死 tick、残余位移、静止或反向位移
  不触发。后续只有 `current_x > previous_x && current_x >= 2144` 才自动激活。
- 本 Story 不改变敌人数值、AI、SaveSystem schema、Story084 或资产合同。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `3.0.4`；accepted clean run `r119912042-35`（run token `35`）。
- Custom Factory scene 以 `autosave=false` 启动，helper live，startup errors
  为空。MCP 只用 scene-local state 建立 Story081-complete 前置条件。
- Story083 初始 inactive：2128 HP `24`、hidden、process/physics disabled、
  hurtbox `gone`。真实 `input_key(D)` 将玩家从 `x=2012` 推进到约
  `x=2023.925` 并启动 Story082；2126/2127 visible/targeted、process/physics
  enabled、hurtbox `normal`，HUD 为 `Break Coil Pincer`。
- 自然激活画面中两只 96x96 角色中心间距仅约 `70px`，视觉有明显重叠；该问题
  已记录为下一切片的 encounter-spacing debt，未通过取证摆位伪装成已修复。
- 致死取证只做 scene-local instrumentation：把 pincer locomotion 冻结并临时
  调整位置、玩家 hurtbox 切为 `gone`、hidden 2128 与目标重叠；为捕捉现有短
  death 窗口暂时设置 `Engine.time_scale=0.05`。未写回场景、资源或生产时序。
- entities `2126`/`2127` 均先通过既有 API 做非致命 `24 -> 12` setup，再由
  真实 `input_key(A)` 定向和真实 `input_key(J)` 通过实际物理重叠完成致死。
  两次最终命中 metadata 均为 weapon `cat_claw`、hitbox `cat_claw_light`、
  attack `light`、facing `-1`、damage applied `12`，target 分别为 `2126`/`2127`。
- 第一击后 2126 HP `0`、visible death、physics/target off、hurtbox `gone`；
  2127 HP `12`、visible/targeted、process/physics enabled、hurtbox `normal`；
  2128 HP `24`、hidden、hurtbox `gone`，HUD 仍为 `Break Coil Pincer`。
- 第二击后 2127 同样进入 visible death，双敌 defeat 持久化，HUD 为
  `Forward Pressure Coil Pincer Cleared`；2128 仅 available，仍 inactive、
  hidden、hurtbox `gone`、HP `24`。反向移动到 `x=2160` 和等待 `0.6s` 均未
  激活 Story083，且两只 death 节点按既有时序退出。
- 恢复 `Engine.time_scale=1.0` 后，新的真实 `input_key(D)` 将玩家从 `x=2160`
  推进到约 `x=2173.925`，此时才启动 2128。它恢复 visible/targeted、
  process/physics enabled、hurtbox `normal`、HP `24`，opening grace `8`，HUD
  为 `Contain Coil Aftershock`。
- 2128 runtime `Sprite` 为 visible `AnimatedSprite2D`；`idle`、`run`、
  `attack_tell`、`attack`、`hurt`、`death` 各三帧。MCP 返回四张非空 RGB
  `1278x718` screenshots，画面可见有纹理的 Factory、Cinderpaw、动画敌人与
  对应 HUD，不是占位方块。
- Accepted-run game log 仅一行 game-helper registration info；editor log 为
  零行，没有新增 script/runtime/resource error。所有 input action 均 released，
  `Engine.time_scale` 恢复 `1.0`，游戏已停止，editor 恢复 ready。

## Test Determinism Note

Canonical GdUnit 先通过既有 `apply_damage` 分别做一次非致命 `12 HP` setup，
再由真实 `Input.attack` 激活玩家 hitbox，并用 `process_detection_frame` 定向注入
候选 hurtbox。第二击候选明确含 hidden 2128、已死亡 2126 与存活 2127。该测试
证明输入、攻击状态、死亡免疫、inactive 隔离、partial/full clear 与交接合同；
MCP 独立证明真实 `J` 在实际 Area2D 物理重叠下完成两次致死命中。

## Residual Risks

- 现有 RatMinion death hold/fade 合计约 `0.4s`，短于 health/death GDD 的
  `0.5-1.0s` 可读窗口；HIT state 约 `5` physics frames，通常只来得及显示
  第一张 `hurt` 帧。下一 ACT 表现切片应统一修正共享 hurt/death pacing。
- Coil Pincer 自然生成时角色视觉重叠明显。下一 encounter-spacing 切片应调整
  spawn separation 或敌人避让，同时保留双敌夹击压力。
- 2128 combat/death 与 Story084 handoff 尚未生产化，留给后续 Story。

## Asset Use

未生成新图片。Story202 复用已登记的 image-generated Factory Spark Rat、
Factory Coil Rat SpriteFrames、Cinderpaw 与 Factory 环境；没有 source、import、
manifest、entity inventory 或动画资源变更。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| 真实移动启动 Story082 | Story201/202 tests；MCP real `D` | PASS |
| 真实攻击逐个击败 2126/2127 | Story202 test；MCP two real `J` lethal hits | PASS |
| Partial defeat survivor 保持战斗 | Related GREEN；MCP runtime + screenshot | PASS |
| 死亡目标不可重伤、hidden 2128 不抢命中 | Story202 candidate set；MCP HP/hurtbox | PASS |
| 双敌 death 可见且战斗能力关闭 | Related GREEN；MCP runtime + screenshots | PASS |
| Clear frame、反向位移不串联 Story083 | Story202 test；MCP reverse/stable probes | PASS |
| 新正向位移才启动 Story083 | Story202 test；MCP real `D` | PASS |
| 2128 帧动画与战斗合同 | Related tests；MCP runtime/frame counts | PASS |
| Godot 4.7 / MCP 3.0.4 runtime 干净 | Smoke；accepted logs；screenshots | PASS |
