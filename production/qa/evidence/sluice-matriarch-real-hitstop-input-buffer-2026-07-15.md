# Sluice Matriarch 真实 Hitstop 与输入缓冲验收证据

> **Story**: Combat Presentation 023
> **日期**: 2026-07-15
> **结论**: PASS（Sluice Matriarch Arena 范围）

## 交付合同

- Sluice Matriarch Arena 接入共享 `CombatPresentation` 和
  `HitstopInputBridge`，不创建第二个 InputManager 消费者。
- 玩家命中 Boss 和 Boss 命中玩家都通过真实 Hitbox -> Collision -> Combat
  -> Health 链路；只有 `damage_was_applied=true` 才产生普通命中反馈。
- 玩家 PERFECT parry 继续走专用表现：不扣血、不显示虚假普通伤害数字，保留
  `8` 帧停顿和一张当前角色帧的金色残影。

## TDD 与自动化证据

- 初始 RED：`reports/report_1765/results.xml`，`3` 个用例、`4` 个预期失败，
  证明 Arena 当时没有 presentation/bridge 集成。
- 初始 GREEN：`reports/report_1767/results.xml`，`3/3` 通过。
- 相关回归 RED：`reports/report_1768/results.xml`，`12` 个用例中 `2` 个失败；
  根因是旧 Boss3 fixture 未将 Cat Claw 推进到已定义的攻击有效帧，不是生产
  碰撞逻辑回归。修正 fixture 后 `reports/report_1769/results.xml` 为 `12/12`。
- PERFECT parry RED：`reports/report_1770/results.xml`，新增用例准确暴露
  Arena 未转发专用 parry presentation 的三项失败；
  `reports/report_1771/results.xml` 为 `4/4` GREEN。
- 最终 bounded related：`reports/report_1772/results.xml`，六套 `50/50`
  通过，零错误、零失败、零跳过、零 orphan。覆盖 Story023、Boss3 core、
  Story129 aerial reward、旧工厂 handoff、Crown shared bridge 和
  CombatPresentation。
- 完成声明前 focused：`reports/report_1773/report_1/results.xml`，`4/4`、零
  测试错误、零失败、零跳过、零 orphan，进程退出码 `0`。GdUnit 退出清理阶段
  打印项目既有的 `2 ObjectDB instances / 1 resource still in use` 提示，未改变
  测试结果。
- Godot `4.7-stable` headless editor load 退出码为 `0`。
- 未运行 full suite。

## Godot MCP 运行证据

Godot `4.7-stable (official)`，Godot AI MCP plugin/server `3.0.2`，session
`cinderpaw@af5f`，最终有效 run `r74236222-21`（run token `21`）：

- `res://scenes/bosses/sluice_matriarch_arena.tscn` 以 custom scene 启动，
  helper 状态为 live，启动窗口 `current_run_errors=[]`。
- 玩家真实 Cat Claw 碰撞令 Boss HP `120 -> 108`；命中瞬间 SceneTree
  paused、CombatPresentation active/remaining=`3`、InputManager 为
  `BUFFERING`、缓冲队列为 `1`，最后伤害数字快照为可见 `12`。
- 解冻后 completed hitstop=`3`、pause=false、InputManager=`DIRECT`、
  queue=`0`；bridge 记录 `attack / accepted=true / dispatch_count=1`。
- 反向真实 `pressure_lunge` 碰撞令玩家 HP `100 -> 84`；Boss metadata 为
  `damage_applied=16 / damage_was_applied=true`，Arena 记录实际伤害 `16`，
  伤害数字快照为可见 `16`，并完成同样的 `3` 帧 hitstop。
- 运行时只有一个 `CombatPresentation` 和一个 `HitstopInputBridge`。Player
  与 Boss Sprite 均为可见 `AnimatedSprite2D`；玩家当前动画为三帧，Boss 的
  `attack/attack_tell/death/hurt/idle/run` 六组动画全部为三帧。
- 两张 `1278x718` PNG 截图均非空，可见 Cinderpaw、Sluice Matriarch、
  Sluice arena 环境和实际 HUD；截图中的 Boss HP `108/120` 与玩家 HP
  `84/100` 分别对应双向真实命中。
- 最终 game log 仅有一条 MCP helper info；editor log 为 `0`。停止运行后
  editor readiness 为 `ready`。

## 探针状态诊断

- 一次中间 MCP 探针在调用 `PlayerController.respawn_at()` 后同帧触发 Boss
  攻击，结果正确返回 `damage_was_applied=false`。根因是 respawn 合同授予
  `120` 帧无敌；MCP 读取到 `iframe_remaining=120 / invincible=true`。
- 最终有效 run 使用 HealthComponent 的正常可受伤前置状态后得到
  `100 -> 84`。该诊断没有改动生产 respawn 或伤害规则；历史探针日志已清理，
  最终 run 单独重启并保持零错误。

## 素材说明

- 本 Story 不新增 bitmap/audio，也不调用 image generation。
- 复用现有 Cinderpaw 与 Sluice Matriarch 帧动画、Sluice Arena 背景、HUD、
  room seal、reward source 和 CombatPresentation VFX。
- 没有新增占位方块、纯色角色或单帧伪动画。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| Arena 仅一个 presentation/bridge | focused + MCP | PASS |
| 玩家真实命中 Boss、12 伤害、精确 3 帧 | focused + MCP | PASS |
| Boss 真实命中玩家、16 伤害、精确 3 帧 | focused + MCP | PASS |
| 缓冲一次、派发一次、恢复 DIRECT | focused + MCP | PASS |
| dodge 拒伤无普通反馈 | focused | PASS |
| PERFECT parry 保留 8 帧专用反馈且无虚假 16 | focused + related | PASS |
| 可见多帧 AnimatedSprite2D 与非空截图 | MCP | PASS |
| phase/reward/route 回归与运行日志 | related + headless + MCP | PASS |

## 已知边界

- Story023 只覆盖 Sluice Matriarch Arena；其他独立挂载 Player 和
  CombatPresentation 的战斗场景仍需逐个接入共享桥，Epic 保持 In Progress。
- Sluice Matriarch 现有角色帧为 `192x192`，高于 Art Bible 的建议预算；当前
  截图可读且运行正常，统一缩放和 asset-manifest inventory 属于独立美术债务。
