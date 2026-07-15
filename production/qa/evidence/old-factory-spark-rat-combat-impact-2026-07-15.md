# Old Factory Spark Rat 战斗冲击验收证据

> **Story**: Combat Presentation 028
> **日期**: 2026-07-15
> **结论**: PASS（Old Factory / Spark Rat 范围）

## 交付合同

- Old Factory 场景挂载唯一一套 `CombatPresentation` 与
  `HitstopInputBridge`，由场景所有者统一接收玩家和 Factory 敌人的真实命中事件。
- Spark Rat 保持既有咬击伤害 `9`、Cat Claw 反击伤害 `12`、攻击时序、AI、HP、
  闪避与 PERFECT parry 窗口；本 Story 只补表现、输入交接与诊断。
- 被 dodge iframe 拒绝的伤害不会产生普通命中假反馈；致死反馈按敌人 entity id
  去重。

## TDD 与自动化证据

- RED：`reports/report_1817/results.xml`，缺少 Old Factory 场景级
  `CombatPresentation` 与 `HitstopInputBridge` 时按预期失败。
- Focused GREEN：`reports/report_1822/results.xml`，`3/3` 通过，覆盖真实闪避反击、
  真实 Spark Rat 碰撞咬击、PERFECT parry 和致死反击。
- Bounded related：`reports/report_1823/results.xml`，`11/11` 通过，覆盖 Spark Rat
  dodge-counter readability `5/5`、pacing `5/5`、Factory route roundtrip `1/1`。
- Fresh completion gate：`reports/report_1824/results.xml`，四套 focused/related
  合并执行 `14/14`，`0` error、`0` failure、exit `0`。
- 未运行 full suite。

## Godot MCP 运行证据

Godot `4.7-stable`，Godot AI MCP plugin/server `3.0.2`，session
`cinderpaw@af5f`，有效 run `r94929878-35`：

- 从磁盘强制打开并运行
  `res://scenes/factory_route_transition_shell.tscn`，helper 状态为 `live`。
- 编辑态与运行态场景树都确认只有一个 `CombatPresentation` 和一个
  `HitstopInputBridge`；bridge 初始 `configured=true`、输入状态 `direct`。
- Player/Sprite 与 FactorySparkRat/Sprite 均为可见 `AnimatedSprite2D`，Player
  动画集合包含 `idle/run/attack/dodge/parry/hurt/death/jump/fall` 等状态，Spark
  Rat 包含 `idle/run/attack_tell/attack/hurt/death`。
- 运行时沿既有 Factory 解锁链激活 Spark Rat，真实 active bite 碰撞使 Player
  HP `100 -> 91`，记录 `source=factory_spark_rat`、damage `9`，并进入三帧真实
  hitstop，生成六个火花与一个伤害数字。
- 第二次真实咬击在暂停期间成功把 `attack` 放入队列，快照为
  `tree_paused=true`、InputManager=`buffering`、queue=`1`；结束后记录
  `last_completed_hitstop_frames=3`、InputManager=`direct`、queue=`0`、
  `dispatch_count=1`。该次玩家仍处于既有 hurt 状态，所以派发结果
  `accepted=false`；focused 测试中的 dodge-counter 空闲状态路径已验证同一缓冲
  输入 `accepted=true` 且只推进一次。
- MCP `editor_screenshot(source="game")` 返回非空 `960x539` PNG，画面可见 Old
  Factory 环境、Cinderpaw、Spark Rat 和命中火花，不是占位方块画面。
- game log 只有一条 MCP helper info，editor log 为 `0`；停止后 editor
  readiness 恢复为 `ready`。

## 素材说明

- 本 Story 没有新增视觉或音频素材，不需要重复调用 image generation。
- 复用现有 image generation 资产管线导入的 Old Factory 环境、Cinderpaw、
  Spark Rat 和战斗 VFX；所有玩家可见角色继续使用多帧 SpriteFrames。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 唯一 scene-mounted presentation/bridge | focused + MCP scene tree | PASS |
| dodge iframe 无假反馈 | focused GREEN | PASS |
| 反击 12 点、3 帧、6 sparks、缓冲单次接受 | focused GREEN | PASS |
| 真实咬击 9 点且只结算一次 | focused + MCP | PASS |
| PERFECT parry 专用反馈 | focused GREEN | PASS |
| lethal 6 帧、18 debris、单次 kill | focused GREEN | PASS |
| Spark Rat pacing/readability 与 route 无回归 | related `11/11` | PASS |
| 多帧角色、非空截图、干净日志 | MCP run `r94929878-35` | PASS |

## 已知边界

- MCP 的缓冲输入是在 Player 已进入 hurt 状态时派发，因此运行态证据只声明
  “入队一次、派发一次、清空一次”；“被玩家攻击链接受”由 focused
  dodge-counter 验收覆盖。
- 本 Story 不声明 Old Factory 全路线的视觉重制或性能预算完成；只验收共享
  combat impact 接线及 Spark Rat 纵向切片。
