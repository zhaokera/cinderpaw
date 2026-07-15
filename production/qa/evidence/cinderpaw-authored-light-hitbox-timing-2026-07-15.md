# Cinderpaw 三段轻击判定时序验收证据

> **Story**: Player Abilities 167
> **日期**: 2026-07-15
> **结论**: PASS

## 交付合同

- 三段轻击分别使用 `4/4/4`、`6/6/6`、`10/10/10` 的启动、有效和纯后摇窗口。
- 启动期 hitbox 关闭；Core 第 `4/6/10` 帧同时切到视觉帧 1 并开启 hitbox；
  有效期结束后切到视觉帧 2 并关闭 hitbox。
- 有效期攻击输入只排队，不截断当前接触窗口；纯后摇仍沿用已有连段推进。
- 基础猫爪伤害 `10`、猫气 `+5`、单次激活重复命中抑制、技能修正与其他动作状态保持不变。

## 自动化证据

- Initial timing RED：`reports/report_1715/results.xml`，证明旧逻辑在第 0 帧立即开启六帧 hitbox。
- Visual-sync RED：`reports/report_1725/results.xml`，同步推进 Core 四帧后视觉仍为帧 0，稳定复现 MCP 发现的时钟相位问题。
- Final focused GREEN：`reports/report_1730/results.xml`，`3/3` 通过。
- Final bounded related GREEN：`reports/report_1731/results.xml`，九套 `34/34` 通过，覆盖真实输入、Core 连段、Main 命中链、hitbox 生命周期、多目标重复抑制、命中确认与猫气、技能树突进和重攻击隔离。
- 未运行 full suite，也未在文档修改后重复等价测试。
- GdUnit 退出时保留项目既有 ObjectDB/resource cleanup 提示；测试退出码为 `0`，最终 MCP 游戏和编辑器日志均无对应错误。

## Godot MCP 运行证据

Godot AI MCP plugin/server `3.0.2`，session `cinderpaw@af5f`，Godot `4.7-stable`，最终验收 run `r59179809-12`：

- `res://scenes/main.tscn` 启动成功，game helper live；运行内临时停止敌人处理以隔离玩家采样，未写入场景。
- 第一段：frame 3 为 sprite 0 / hitbox false；frame 4 为 sprite 1 / hitbox true。
- 第二段：frame 5 为 sprite 0 / hitbox false；frame 6 为 sprite 1 / hitbox true。
- 第三段：frame 9 为 sprite 0 / hitbox false；frame 10 为 sprite 1 / hitbox true。
- 第一、二段有效期输入均返回 `true` 且 `chain_queued=true`，下一段起手回到 frame 0、hitbox false。
- 游戏截图为非空 `1278x718` PNG；人工检查可见 Cinderpaw、主场景、HUD 和第三段接触姿势，不是空白画面。
- game log 仅三条 info（helper、`boss_configs`、`enemy_stats`）；editor log 为 0 行；停止后 readiness 为 `ready`。

## 素材说明

- 本 Story 未新增视觉或音频素材。
- 复用 Story166 已生成并导入的三套 Cinderpaw 轻击帧；本次修改仅同步 gameplay phase、hitbox 和现有 `AnimatedSprite2D` 帧。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 三段 authored timing | focused GREEN + MCP | PASS |
| 启动期无 hitbox | focused GREEN + MCP 边界采样 | PASS |
| 接触帧与 hitbox 同步 | visual-sync regression + MCP | PASS |
| 有效期输入排队 | focused GREEN + MCP | PASS |
| 伤害、猫气、重复抑制 | focused hit test | PASS |
| 相关系统无回归 | bounded `34/34` | PASS |
| 非空截图与干净日志 | MCP run `r59179809-12` | PASS |
