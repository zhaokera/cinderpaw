# Central Tower 真实 Hitstop 与输入缓冲验收证据

> **Story**: Combat Presentation 024
> **日期**: 2026-07-15
> **结论**: PASS（Central Tower 战斗表现接入范围）

## 交付合同

- `central_tower_threshold.tscn` 接入一个共享 `CombatPresentation` 和一个
  `HitstopInputBridge`，不创建第二个 InputManager 消费者。
- 玩家命中敌人和敌人命中玩家都通过真实 Hitbox -> Collision -> Combat ->
  Health 链路；只有 `damage_was_applied=true` 才产生普通命中表现。
- Threshold Guard、Relay Mantis、Counterweight Sentry 共用场景级落地命中
  handler。PERFECT parry 继续走专用表现，不产生虚假普通伤害数字。

## TDD 与自动化证据

- 初始 RED：`reports/report_1774/report_1/results.xml`，`5` 个用例中 `2`
  个预期失败，证明 Central Tower 当时缺少 presentation/bridge。
- 迭代 `report_1775` 至 `report_1778` 校正了错误的 dodge 前置预期，并定位
  `RatMinion` 在伤害被 i-frame 拒绝时仍发出落地命中信号的根因。
- Focused GREEN：`reports/report_1779/results.xml`，`6/6` 通过。
- 初始相关回归 `report_1780` 暴露旧 fixture 未等待真实 hitstop/hit-stun，
  且没有把 Cat Claw 推进到 authored frame `4`；修正后 Threshold、Inner
  Relay、Old Factory 分别在 `report_1782`、`report_1784`、`report_1786`
  通过。
- 最终 bounded related：`reports/report_1787/results.xml`，九套 `66/66`
  通过，零错误、零失败、零跳过、零 orphan。覆盖 Story024、Threshold、
  Inner Relay、Deep Lift、玩家 authored hitbox timing、Crown shared bridge、
  CombatPresentation、Rat King live summon 和 Old Factory entrance。
- MCP 发现的五处 GDScript 参数 shadowing warning 通过纯命名修复消除；
  `reports/report_1788/results.xml` 覆盖 Cooling Shaft 和 Apex Purge，`6/6`
  通过。
- 完成声明前 focused：`reports/report_1789/results.xml`，`6/6`、零测试错误、
  零失败、零跳过、零 orphan，进程退出码 `0`。GdUnit 退出清理阶段打印项目
  既有的 `2 ObjectDB instances / 1 resource still in use` 提示，未改变测试结果。
- 未运行 full suite，也没有为文档改动重复跑宽回归。

## Godot MCP 运行证据

Godot `4.7-stable (official)`，Godot AI MCP plugin/server `3.0.2`，session
`cinderpaw@af5f`：

- 功能验收 run `r81591668-24` 从磁盘加载并启动
  `res://scenes/areas/central_tower_threshold.tscn`，`current_run_errors=[]`。
- 玩家真实 Cat Claw 令 Threshold Guard HP `48 -> 36`，显示伤害数字 `12`；
  命中时 SceneTree paused、剩余 hitstop=`3`。输入队列接收一个 `attack`，
  解冻后 completed frames=`3`、pause=false、InputManager=`DIRECT`、queue=`0`，
  bridge 记录 `accepted=true / dispatch_count=1`。
- Threshold Guard 真实攻击令玩家 HP `100 -> 86`；敌人 metadata 为
  `damage_applied=14 / damage_was_applied=true`，场景记录实际伤害 `14`，
  显示伤害数字 `14` 并完成相同的三帧 hitstop。
- respawn i-frame 探针保持玩家 `100 -> 100`，敌人 metadata 为
  `damage_applied=0 / damage_was_applied=false`；场景没有普通命中 metadata、
  hitstop 或伤害数字，证明拒伤不会产生假反馈。
- 运行时恰好存在一个 `CombatPresentation` 和一个 `HitstopInputBridge`。
  Player、Threshold Guard、Relay Mantis、Counterweight Sentry 均存在可见
  `AnimatedSprite2D`；玩家状态动画和三类敌人的六个 gameplay animations
  均为至少三帧 `SpriteFrames`。
- 功能验收截图为 `1278x718` 非空图像，可见 Cinderpaw、Threshold Guard、
  Central Tower 关卡环境与 HUD。最终 clean reload run `r82274190-25`
  再次返回 `current_run_errors=[]`，截图非空，game log 只有 helper/DataManager
  info，editor log 为 `0`，停止后 editor readiness=`ready`。

## 素材说明

- 本 Story 不新增 bitmap/audio，也不调用 image generation。
- 复用现有 Cinderpaw 与 Central Tower 三类敌人的多帧角色动画、场景环境、
  HUD、音效和 CombatPresentation VFX。
- 没有新增占位方块、纯色角色或单帧伪动画。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 场景仅一个 presentation/bridge | focused + MCP | PASS |
| 玩家真实命中 Guard、12 伤害、精确 3 帧 | focused + MCP | PASS |
| Guard 真实命中玩家、14 伤害、精确 3 帧 | focused + MCP | PASS |
| 缓冲一次、派发一次、恢复 DIRECT | focused + MCP | PASS |
| dodge/respawn i-frame 无普通假反馈 | focused + MCP | PASS |
| PERFECT parry 保留 8 帧专用反馈且无虚假 14 | focused | PASS |
| 三类敌人共享 handler，多帧动画与非空截图 | focused + MCP | PASS |
| 相关回归与最终运行日志 | related + MCP | PASS |

## 已知边界

- Story024 只覆盖 Central Tower 当前玩家可达战斗路线；Combat Presentation
  Epic 仍保持 In Progress，其他独立战斗场景需要按风险继续接入。
- 最终 clean MCP 采样约 `120 FPS`、`398` draw calls。帧率可运行，但 draw
  calls 高于技术美术建议的 `300` 上限。Story024 只增加空载 presentation/
  bridge 节点，现有 Central Tower 渲染批次优化作为独立性能债务跟踪，本文不
  将其误报为性能预算通过。
