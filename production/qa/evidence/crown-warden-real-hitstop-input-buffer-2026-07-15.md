# Crown Warden 真实 Hitstop 与输入缓冲验收证据

> **Story**: Combat Presentation 022
> **日期**: 2026-07-15
> **结论**: PASS（Main 共享桥 + Crown Warden Arena 范围）

## 交付合同

- `HitstopInputBridge` 统一负责 CombatPresentation、InputManager 和
  PlayerController 之间的暂停、缓冲及单次释放；Main 与 Crown Warden
  Arena 都使用该节点，Player CombatComponent 不再并行消费同一个输入信号。
- CombatComponent 在命中 metadata 中记录 `damage_applied` 和
  `damage_was_applied`。PlayerController 返回 HP+护盾的实际损失；拒伤路径不再
  被错误当作普通命中反馈。
- 玩家命中 Boss 和 Boss 命中玩家都必须来自真实 Hitbox -> Collision ->
  Combat -> Health 路径，并在实际伤害生效时触发三帧 gameplay freeze。

## TDD 与自动化证据

- 初始 bridge RED：`reports/report_1750/results.xml`，`2` 个用例、`9` 个预期
  行为失败。
- 审查加固 RED：`reports/report_1759/results.xml`，真实 Boss 命中已经造成
  `14` 伤害并进入三帧反馈，但缺少 `damage_applied=14` 契约。
- `report_1760` 的 dodge 用例没有推进到 GDD 的第 3 帧 i-frame，属于测试设置
  错误，不计入验收。
- Focused GREEN：`reports/report_1761/results.xml`，`3/3` 通过，覆盖玩家命中
  与缓冲释放、Boss 真实命中、dodge i-frame 拒伤无误触发。
- 最终集成后 focused：`reports/report_1763/results.xml`，`3/3`、零错误、零
 失败。
- Bounded related：`reports/report_1762/results.xml`，十四套 `93/93` 通过，
  覆盖共享 CombatComponent、InputManager、Main Story021、
  CombatPresentation、Crown Warden core、Phase II 与 perfect parry。
- 未运行 full suite。

## Godot MCP 运行证据

Godot `4.7-stable`，Godot AI MCP plugin/server `3.0.2`，session
`cinderpaw@af5f`，有效 run `r68236156-17`：

- `res://scenes/bosses/crown_warden_arena.tscn` 从磁盘强制重载并以 current
  scene 启动，helper 状态为 live。
- 玩家真实 Cat Claw 碰撞令 Crown Warden HP `160 -> 148`；命中瞬间
  SceneTree paused、CombatPresentation active/remaining=`3`、InputManager 为
  `BUFFERING`、队列为 `1`，伤害数字为 `12`。
- 解冻后记录 completed hitstop=`3`、pause=false、InputManager=`DIRECT`、
  queue=`0`；bridge 记录 `attack / accepted=true / delay=2ms /
  dispatch_count=1`。释放动作进入二段攻击并再次真实命中，Boss HP 最终为
  `136`，证明没有重复派发或只改测试替身。
- 反向真实 `wing_sweep` 碰撞令玩家 HP `100 -> 86`；Boss metadata 为
  `damage_applied=14 / damage_was_applied=true`，Arena 伤害数字为 `14`，同样
 进入并完成精确 `3` 帧 hitstop，随后恢复 DIRECT 且队列为空。
- 运行时树包含 `HitstopInputBridge`、`CombatPresentation`、Player 与 Crown
  Warden。两名角色 Sprite 均为可见 `AnimatedSprite2D`；玩家 `attack`、Boss
  `hurt/idle` 当前动画都引用三帧 SpriteFrames。
- 两张截图均为非空 `1278x718` PNG，可见 Cinderpaw、Crown Warden、Crown
  Observatory 环境和实际 HUD；第一张还显示缓冲释放后的 Boss HP `136/160`，
  第二张显示 Boss 命中后的玩家 HP `86/100`。
- game log 只有 helper、enemy_stats、boss_configs 三条 info；editor log 为
  `0`。停止后 editor readiness 返回 `ready`。

## 素材说明

- 本 Story 不新增 bitmap/audio，也不调用 image generation。
- 复用现有 Cinderpaw 17 组/51 帧、Crown Warden 8 组/24 帧角色动画，以及
  Crown Warden Arena 背景、HUD 和现有 CombatPresentation VFX。
- 没有新增占位方块、纯色角色或单帧伪动画。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| Main/Crown 共用 bridge 且单一派发者 | focused + related + MCP | PASS |
| 玩家真实命中 Boss 并精确 3 帧 | focused + MCP | PASS |
| Boss 真实命中玩家并精确 3 帧 | focused + MCP | PASS |
| 缓冲一次、释放一次、恢复 DIRECT | focused + MCP | PASS |
| dodge 拒伤无普通反馈 | focused + Crown parry regression | PASS |
| 可见多帧 AnimatedSprite2D 与非空截图 | MCP | PASS |
| 运行日志无新增错误 | MCP | PASS |

## 已知边界

- Story022 只统一 Main 与 Crown Warden Arena。其他独立挂载 Player 和
  CombatPresentation 的战斗场景仍需后续 Story 接入，Combat Presentation Epic
  因此保持 In Progress。
- Crown Arena 的暂停菜单恢复 predicate 未在本 Story 定义；Main 原有恢复行为
  保持不变。
- 现有角色资源预算、旧 VFX 命名与跨状态底线漂移属于独立美术债务，不在本
  Story 顺带修改。
