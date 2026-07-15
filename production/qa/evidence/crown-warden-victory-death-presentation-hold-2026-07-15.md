# Crown Warden 胜利死亡演出停留验收证据

> **Story**: Combat Presentation 025
> **日期**: 2026-07-15
> **结论**: PASS（Boss4 死亡演出与奖励交接范围）

## 交付合同

- Boss4 致死后立即保存 durable defeat，但将奖励、回程路线、房门与玩家控制
  的释放延迟到 `2.0s` 演出结束。
- 演出期间保持现有三帧 `death` 可见、Boss hitbox 为 `0`，并使用既有击杀
  表现的 `6` 帧 hitstop 与 `18` 个 debris。
- 演出计时不写入存档；读取已击败状态直接恢复完成后的奖励和路线，不重播。

## TDD 与自动化证据

- Initial RED：`reports/report_1790/results.xml`，`1` 个用例因缺少 Story025
  diagnostics/advance API 产生 `2` 个预期失败，无解析错误。
- Focused GREEN：`reports/report_1791/results.xml`，`1/1` 通过，覆盖 exact
  timing、击杀反馈、输入锁、即时持久化、重复信号和读取不重播。
- Bounded related：`reports/report_1792` 至 `report_1795`，Boss4 core `6/6`、
  reward `3/3`、recall `3/3`、shared hitstop `3/3`，合计 `15/15` 通过。
- 合计 `16/16` 通过；未运行 full suite，也未为文档改动重复跑测试。

## Godot MCP 运行证据

Godot `4.7-stable (official)`，Godot AI MCP plugin/server `3.0.2`，session
`cinderpaw@af5f`，run `r86792500-26`：

- 从磁盘打开并运行
  `res://scenes/bosses/crown_warden_arena.tscn`，helper live，启动无 current
  run error。
- 运行时致死探针返回 `pending=true / remaining=2.0`、动画 `death`、帧数
  `3`、active hitbox=`0`、hitstop=`6`、debris=`18`；奖励和路线不可用、
  两侧房门/scene lock/player lock 保持。
- 演出完成后返回 `pending=false / remaining=0`、奖励 visible/available、
  Apex return available、房门和 scene lock 释放、player lock=false，reward
  reveal spawn count=`1`。
- 运行时节点树确认 Player 与 Crown Warden 都使用 `AnimatedSprite2D`；Boss
  `SpriteFrames` 包含 `death/hurt/idle/run/talon_dive/talon_dive_tell/
  wing_sweep/wing_sweep_tell`，`death` 为三帧。
- 截图为 `1278x718` 非空图像，可见 Cinderpaw、Crown Warden 倒地帧、
  Observatory 环境、Wall Climb reward 与 HUD。
- game log 只有 helper/DataManager info，无新增脚本、资源或运行时错误；停止
  后 editor readiness=`ready`。一次场景树查询使用旧参数 `max_depth` 被 MCP
  参数校验拒绝，立即改为 3.0.2 要求的 `depth` 后成功；这不是 Godot runtime
  error。

## 素材说明

- 本 Story 不新增 bitmap/audio，也不调用 image generation。
- 复用已有透明、多帧、连续命名的 Crown Warden 角色动画和既有场景资产。
- 没有新增占位方块、纯色角色或单帧伪动画。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| durable defeat 即时保存，transient hold 不持久化 | focused + MCP | PASS |
| 三帧 death 可见、hitbox=0、exact 2.0s | focused + MCP | PASS |
| 房门/scene/player lock 与奖励/路线隔离 | focused + MCP | PASS |
| 6 帧 kill hitstop、18 debris | focused + MCP | PASS |
| 缓冲输入单次派发但不穿透控制锁 | focused | PASS |
| 演出结束只揭示一次奖励并开放回程 | focused + MCP | PASS |
| 读取已击败状态不重播瞬时演出 | focused + related | PASS |
| 相关回归、非空截图、clean logs | related + MCP | PASS |

## 已知边界

- 本 Story 只补 Boss4 胜利演出，不将四 Boss 降级完整路线误报为最终结局。
- Combat Presentation Epic 仍为 In Progress；Neon Rooftops、Underground
  Passage 等独立玩家可见战斗场景仍需按玩家价值逐项补齐共享表现。
