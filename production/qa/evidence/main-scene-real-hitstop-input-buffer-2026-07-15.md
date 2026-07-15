# Main 真实 Hitstop 与输入缓冲验收证据

> **Story**: Combat Presentation 021
> **日期**: 2026-07-15
> **结论**: PASS（Main 场景范围）

## 交付合同

- Main 场景的 hitstop 从表现计数器升级为真实 `SceneTree` 暂停；可暂停的
  gameplay 节点在请求帧数内停止，CombatPresentation 自身继续计帧并恢复原
  pause 状态。
- hitstop 开始时由 Main 通知 `InputManager` 进入动画锁定；暂停期间按下的
  bufferable trigger action 被缓存，结束后只释放一个动作。
- Main 是运行时 Player/Core 表现同步的唯一输入派发者。Player 下属
  `CombatComponent` 不再同时订阅 InputManager，避免一次缓冲输入推进两次 Core。
- 本 Story 的玩家动作验收为普通 `attack`：释放后只派发一次、请求成功，并
  推进既有三段轻击链。直接输入、伤害、hitbox 和动画时序不改。

## TDD 与自动化证据

- 清洁 RED：`reports/report_1737/results.xml`，`1` 个用例、`0` 个测试框架错误，
  真实冻结、缓冲、恢复和单次派发共 `10` 个预期行为失败。
- Focused GREEN：`reports/report_1746/results.xml`，`1/1` 通过。
- Bounded related：`reports/report_1747/results.xml`，实际执行九套、`68/68`
  通过，覆盖 Story021/020、Main 攻击链、CombatPresentation、InputManager
  direct/buffer/conflict、空中动画和闪避动画。
- 该 related 命令里一个不存在的旧 parry 文件名被 GdUnit 忽略；随后用正确的
  `player_parry_laser_gate_runtime_test.gd` 单独执行，
  `reports/report_1748/results.xml` 为 `5/5` 通过。
- 未运行 full suite，也未在文档写入后重复等价测试。GdUnit 仅保留项目既有
  ObjectDB/resource cleanup 提示，GREEN 进程均正常退出。

## Godot MCP 运行证据

Godot `4.7-stable`，Godot AI MCP plugin/server `3.0.2`，session
`cinderpaw@af5f`，最终有效 run `r65195448-16`：

- `res://scenes/main.tscn` 从磁盘强制重载并启动成功；之前一次包含临时
  `game_eval` 编译错误的探索 run 已停止、清空日志并作废，不计入验收。
- 通过真实 Player、Core `CombatComponent`、`CollisionComponent` 和 Enemy
  执行轻击命中，Enemy HP `300 -> 290`；命中发生时 Core attack frame 保持
  `4`，Player `attack` 动画和 hitbox 均处于有效接触状态。
- 命中后 `tree_paused=true`、InputManager=`BUFFERING`、队列数量为 `1`、
  CombatPresentation 剩余 `3` 帧；完成后记录的实际 hitstop 为 `3` 帧。
- 结束快照为 `tree_paused=false`、InputManager=`DIRECT`、queue=`0`；Main
  记录 `attack / accepted=true / delay=36ms / dispatch_count=1`。
- 缓冲攻击把连段推进到 `combo_index=1`，证明输入是在真实活动命中期间缓存，
  并在 hitstop 后由现有 Core 链路消费，而不是只改测试替身状态。
- 运行时 CombatPresentation 为 `PROCESS_MODE_ALWAYS`、physics priority
  `1000`、gameplay freeze enabled；Player Sprite 为可见 `AnimatedSprite2D`
  且使用真实 `SpriteFrames`。
- 最终截图为非空 `1278x718` PNG，可见 Cinderpaw、Rat King 和现有游戏美术；
  game log 仅三条 info，editor log 为 `0`，停止后 readiness 回到 `ready`。

## 素材说明

- 本 Story 没有新增视觉或音频素材，也没有新增占位方块。
- 复用现有 Cinderpaw 多帧动画与战斗 VFX；变更只负责 gameplay pause、输入
  缓冲和运行时接线，不需要重复调用 image generation。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| Main 真实逻辑暂停且精确 3 帧 | focused GREEN + MCP | PASS |
| 暂停期间捕获 attack | focused GREEN + MCP | PASS |
| 结束后恢复 pause/input 状态 | focused GREEN + MCP | PASS |
| 只派发一次并推进 Core 连段 | focused GREEN + MCP | PASS |
| direct/input/presentation 无相关回归 | bounded `68/68` + parry `5/5` | PASS |
| 可见 AnimatedSprite2D 与非空截图 | MCP run `r65195448-16` | PASS |
| 干净最终运行日志 | MCP run `r65195448-16` | PASS |

## 已知边界

- 本证据只验收 Main。拥有独立 CombatPresentation 和玩家实例的其他场景，
  特别是 Crown Warden Arena，需要后续 Story 接入同一 freeze/input handoff 后
  才能宣称跨场景覆盖。
