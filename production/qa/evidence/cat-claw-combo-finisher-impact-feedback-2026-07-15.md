# Cat Claw 第三段终结命中反馈验收证据

> **Story**: Combat Presentation 020
> **日期**: 2026-07-15
> **结论**: PASS

## 交付合同

- 只有确认命中的 `cat_claw` 轻击第三段进入终结反馈档；挥空、其他武器、
  重击和前两段不受影响。
- 非暴击第三段保持 `18` 伤害、`+12` 猫气和 `attack_3` 接触帧，同时使用
  `5` 帧反馈、`4px/5帧` 震屏、金色 `28px` 伤害数字、金色“终结”提示与
  `1.5x` 现有 hit spark。
- 第三段与暴击同时发生时保留暴击的 `6` 帧、`5px`、猫眼金和 12 个火花，
  不被终结档降级。
- Story167 的 `10/10/10` 第三段判定窗口、动画、伤害、猫气、重复命中抑制和
  输入连段合同不变。

## 自动化证据

- RED：`reports/report_1732/results.xml`，真实第三段 damage/energy 路径通过，
  但 hitstop、shake、数字颜色/字号和终结节点共出现 `6` 个预期失败。
- Focused GREEN：`reports/report_1733/results.xml`，`1/1` 通过。
- Presentation + critical priority：`reports/report_1734/results.xml`，
  两套 `35/35` 通过。
- Bounded related：`reports/report_1735/results.xml`，三套 `9/9` 通过，覆盖
  Story167 authored timing、真实输入三段连击和 Main 攻击链。
- 未运行 full suite，也未在文档更新后重复等价测试。
- GdUnit 保留项目既有 ObjectDB/resource cleanup 提示；所有 GREEN 进程退出码
  为 `0`，最终 MCP 游戏和编辑器日志没有对应运行时错误。

## Godot MCP 运行证据

Godot `4.7-stable`，Godot AI MCP plugin/server `3.0.2`，session
`cinderpaw@af5f`，run `r62054889-14`：

- `res://scenes/main.tscn` 从磁盘强制重载并启动成功，game helper live。
- 运行时通过真实 Player、CombatComponent、CollisionComponent 和 Enemy
  节点推进三段连击；三个开始/排队请求都返回 `true`。
- 第三段命中元数据为 `cat_claw / light / combo_index=2 / combo_stage=2 /
  is_crit=false / final_damage=18`。
- Enemy HP `300 -> 282`，Cat Energy `0 -> 12`；Player 为可见
  `AnimatedSprite2D`，动画 `attack_3`、接触帧 `1`、hitbox active。
- CombatPresentation 快照为 hitstop `5`、shake `4.0/5`、damage `18 /
  #F59E0B / 28px / visible`、finisher `终结 / #F59E0B / visible / count=1`、
  实际 hit-spark scale multiplier `1.5`。
- 运行时 `ComboFinisherText` 是可见 `Label`，字号 `24`、z-index `91`；
  Cinderpaw Sprite 是带现有 SpriteFrames 的可见 `AnimatedSprite2D`。
- MCP 游戏截图为非空 `1278x718` PNG，可同时看到 Cinderpaw 第三段接触姿势、
  Rat King、金色“终结”和伤害数字 `18`。
- game log 仅三条 info；editor log 为 `0` 行；解除临时暂停后停止成功，
  editor readiness 回到 `ready`。

## 素材说明

- 本 Story 没有生成新视觉或音频素材。
- 复用 `combat_hit_spark.png` 与 Story166 的 `attack_3` 透明帧；“终结”和伤害
  数字均为运行时 Label，符合“现有素材足够时不重复生成”的资产管线原则。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 真实第三段触发且 gameplay 数值不变 | focused GREEN + MCP | PASS |
| 5 帧与 4px/5帧反馈 | focused GREEN + MCP | PASS |
| 金色 28px 伤害字与“终结”提示 | focused GREEN + MCP 截图 | PASS |
| 1.5x 现有 hit spark | actual runtime scale + MCP | PASS |
| 暴击优先级不降级 | Presentation regression | PASS |
| Story167 与 Main 攻击链无回归 | bounded `9/9` | PASS |
| 非空截图与干净日志 | MCP run `r62054889-14` | PASS |
