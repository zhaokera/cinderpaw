# Neon Rooftops 战斗冲击表现验收证据

> **Story**: Combat Presentation 026
> **日期**: 2026-07-15
> **结论**: PASS（Neon Rooftops 战斗表现与输入交接范围）

## 交付合同

- Signal Rat 双向真实碰撞统一接入场景内唯一一套
  `CombatPresentation + HitstopInputBridge`。
- 普通命中使用精确 `3` 帧 hitstop；致死命中取最大 `6` 帧并生成 `18`
  debris；塔激光 PERFECT 招架使用精确 `8` 帧、`22` 招架火花、一次闪光和
  一帧金色残影。
- SceneManager 缓存实例重新挂载后重新配置桥接，不依赖不会重跑的 `_ready()`。

## TDD 与自动化证据

- Initial RED：`report_1796`，`6` 个用例、`11` 个预期失败，均来自缺少
  Story026 节点和诊断接口，无解析错误。
- Focused GREEN：`report_1798`，`6/6` 通过，覆盖真实玩家命中、敌人命中、
  闪避拒绝、致死反馈、激光招架和缓存场景重连。
- Related GREEN：`report_1801` 中塔激光 `3/3`、共享 hitstop `3/3` 通过；
  `report_1802` 中 Signal Rat `3/3` 通过。合计 focused/related `15/15`。
- Fresh completion gate：Godot 4.7 下 `report_1803` 再次通过 Story026
  `6/6`，0 error、0 failure、0 flaky、0 skipped、0 orphan，exit `0`。
- 旧 Neon 测试原先把暂停帧计入招架恢复，并假设 Cat Claw 命中框在
  `request_attack()` 当帧激活；修订后按 `CombatPresentation` 活跃状态、
  `CombatComponent.IDLE` 和 authored `startup_frames` 推进，不修改生产时序。
- 未运行 full suite，也未为文档改动重复跑测试。

## Godot MCP 运行证据

Godot `4.7-stable (official)`，Godot AI MCP plugin/server `3.0.2`，session
`cinderpaw@af5f`：

- 从磁盘打开并运行
  `res://scenes/areas/neon_rooftops_entry.tscn`；编辑器层级确认唯一的
  `CombatPresentation`、`HitstopInputBridge`，并确认 Player/Signal Rat 的
  `AnimatedSprite2D` 节点存在。
- 真实 Cat Claw 探针返回 Signal Rat `36 -> 24`、`damage_applied=12`、
  `damage_was_applied=true`、hitstop=`3`、spark=`6`、damage number=`1`，
  InputManager 状态为 `buffering`；Signal Rat 动画为三帧 `hurt`。
- 非空 `1278x718` 截图可见 Cinderpaw、Signal Rat、伤害数字、命中火花、
  双侧信号封锁、完整 Neon 环境和 HUD，没有角色占位方块。
- 塔激光真实 PERFECT 招架返回 hitstop=`8`、parry spark=`22`、flash=`1`、
  perfect afterimage=`1`、damage number=`0`；截图可见 Cinderpaw 招架帧、
  激光、金色全屏闪光和塔门。
- 最终 run `r90548920-30` 的 game log 只有 helper/DataManager info，无
  error；游戏停止后 editor readiness 恢复 `ready`。
- Editor Errors 面板仍有 `neon_relay_spire_controller.gd:604/639` 两条既有
  `SHADOWED_VARIABLE_BASE_CLASS` warning；本 Story 未改该文件，且最终运行
  没有脚本、资源或 runtime error。
- 一次中间 MCP eval 错把 `AnimatedSprite2D` 当成 `Sprite2D` 读取
  `texture`，该临时探针进入 debugger break；已停止、清理后用正确
  `SpriteFrames.get_frame_texture()` 重新运行，最终两次功能探针均无错误。

## 素材说明

- 本 Story 不新增 bitmap/audio，也不调用 image generation。
- 复用现有 Cinderpaw、Neon Signal Rat 六组透明三帧动画、Neon Rooftops
  环境、HUD、音频和 CombatPresentation VFX。
- 没有新增占位方块、纯色角色或单帧伪动画。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 唯一 presentation/bridge 与缓存重连 | focused + MCP | PASS |
| 玩家真实命中、12 伤害、3 帧、6 火花 | focused + MCP | PASS |
| 缓冲攻击单次派发并恢复 direct | focused | PASS |
| Signal Rat 真实 11 伤害与 3 帧反馈 | focused + related | PASS |
| 闪避拒绝无普通表现 | focused + related | PASS |
| 致死 6 帧、18 debris、death/cache 保留 | focused | PASS |
| 激光 PERFECT 8 帧特殊反馈 | focused + related + MCP | PASS |
| 多帧角色、非空截图、最终运行无 error | related + MCP | PASS |

## 已知边界

- 本 Story 只覆盖 Neon Rooftops；Combat Presentation Epic 仍为 In Progress，
  Underground Passage 等独立玩家可见战斗场景仍需按玩家价值逐项补齐。
