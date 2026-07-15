# Underground Passage 战斗冲击表现验收证据

> **Story**: Combat Presentation 027
> **日期**: 2026-07-15
> **结论**: PASS（Underground Passage 战斗表现与缓存重入范围）

## 交付合同

- Underground 场景只保留一套
  `CombatPresentation + HitstopInputBridge`，统一消费玩家、水蛭和潜伏者的
  真实碰撞结果。
- 普通命中为精确 `3` 帧 hitstop；致死命中取最大 `6` 帧并生成 `18`
  debris；PERFECT 招架为精确 `8` 帧、`22` 个招架火花、一次闪光和一个金色
  残影。
- SceneManager 缓存实例重新挂载时重配桥接；已经死亡并释放的敌人引用不会被
  再次用于信号连接。

## TDD 与自动化证据

- Initial RED：`report_1804`，`6` 个用例、`14` 个预期失败，均来自缺少
  Story027 节点、接线和诊断接口。
- Initial focused GREEN：`report_1808`，`6/6` 通过。
- Review-hardening RED：`report_1814` 精确复现两项审查缺口：PERFECT 招架
  无专用反馈，以及左水蛭释放后缓存重入在
  `_connect_enemy_presentation_signal()` 触发 `previously freed` runtime error。
- Final focused GREEN：Godot 4.7 下 `report_1815` 为 `7/7`，0 error、0
  failure、0 flaky、0 skipped、0 orphan，exit `0`。
- Final related GREEN：`report_1816` 中腐蚀通道 `3/3`、深水池潜伏者
  `3/3`，合计 focused/related `13/13`。
- 两个既有 related fixture 原先假定 Cat Claw 在
  `request_attack()` 同帧激活；已按 authored `startup_frames` 推进并等待
  场景 hitstop，不改变生产时序。
- 未运行 full suite，也未对文档改动重复跑测试。

## Godot MCP 运行证据

Godot `4.7-stable (official)`，Godot AI MCP plugin/server `3.0.2`，session
`cinderpaw@af5f`：

- 从磁盘强制重载并运行
  `res://scenes/areas/underground_passage.tscn`。编辑器层级共 `106` 个节点，
  确认唯一 `CombatPresentation`、唯一 `HitstopInputBridge`，以及 Player、
  两只 Sluice Leech、Cistern Stalker 的 `AnimatedSprite2D`。
- 左水蛭真实 lunge 把玩家 `100 -> 89`；右水蛭真实 lunge 把玩家
  `89 -> 78`。两者均为实际伤害 `11`、hitstop=`3`、spark=`6`、damage
  number=`1`、InputManager=`buffering`，攻击动画均为 `3` 帧。
- Run `r92910348-33` 的真实 PERFECT 招架保持玩家 `100/100`，返回
  hitstop=`8`、parry spark=`22`、flash=`1`、gold afterimage=`1`、damage
  number=`0`、普通 enemy-hit metadata 为空。
- 最终 run `r92976327-34` 的真实致死 Cat Claw 把 Stalker `12 -> 0`，返回
  hitstop=`6`、spark=`6`、debris=`18`、damage number=`1`、kill feedback
  count=`1`；Stalker 为三帧 `death`，玩家攻击动画也为三帧。
- 两张 `1278x718` 非空截图可见 Cinderpaw、Sluice Leech/Cistern Stalker、
  完整 Underground 环境和 HUD；没有纯色角色方块或玩家可见占位场景。
- 最终 game log 仅有 Godot AI helper 注册 info，无 parse、resource 或
  runtime error；停止后 editor readiness 恢复 `ready`。
- Editor Errors 面板仍有
  `underground_recovery_cistern_controller.gd:542/562` 两条既有
  `SHADOWED_VARIABLE_BASE_CLASS` warning。本 Story 未改该控制器，且最终
  功能运行没有 error；warning 作为后续技术债保留。
- 中间右水蛭 MCP 探针曾出现一次临时 eval 语法错误，随后又调用了敌人不存在的
  `get_current_animation()`，产生 `gdscript://` eval runtime error；命中动作在
  该行前已实际完成。停止并清理后改为读取 `AnimatedSprite2D.animation`，最终
  parry/lethal 两个新运行会话无项目运行错误。

## 素材说明

- 本 Story 不新增 bitmap/audio，也不调用 image generation。
- 复用现有 Cinderpaw `17` 组、每组 `3` 帧动画；Sluice Leech 与 Cistern
  Stalker 各 `6` 组、每组 `3` 帧动画；复用四屏 Underground 生成环境、HUD、
  音频和 CombatPresentation VFX。
- 技术美术静态审查确认核心视觉闭包 `99/99` runtime PNG 有有效导入目标，
  `127` 条 `res://` 引用缺失 `0`，未引用 runtime PNG 为 `0`。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 唯一 presentation/bridge | focused + MCP | PASS |
| 玩家真实命中、12 伤害、3 帧、6 火花 | focused | PASS |
| 左右水蛭 11、潜伏者 14 真实伤害 | focused + related + MCP | PASS |
| 单次缓冲派发并恢复 direct | focused | PASS |
| 闪避拒绝无普通表现 | focused | PASS |
| PERFECT 招架 8 帧专用反馈 | focused + MCP | PASS |
| 致死 6 帧、18 debris、三帧 death | focused + related + MCP | PASS |
| 敌人释放后缓存重入无 stale reference | focused | PASS |
| 多帧角色、非空截图、最终运行无 error | related + MCP | PASS |

## 已知边界

- 本 Story 不修改 Recovery Cistern 的两条参数遮蔽 warning。
- 技术美术审查发现 Cinderpaw 跨生成批次存在造型和脚底锚点漂移，四屏背景也仍
  以静态全幅图为主；这些是独立的角色一致性和环境动态化 Story，不阻塞本次战斗
  接线验收。
- Combat Presentation Epic 仍为 In Progress；其他独立玩家可见战斗场景继续
  按玩家价值逐项补齐。
