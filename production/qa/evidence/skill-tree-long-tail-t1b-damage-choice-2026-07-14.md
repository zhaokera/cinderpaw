# Skill Tree Long Tail T1-B Damage Choice 验收证据

> **Story**: Player Abilities 161
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- `long_tail_t1b` 是与 T1-A 并行的 1 SP 被动节点，无前置条件。
- 数据使用 `stat_key="damage"`、`ADD 0.05` 与
  `condition.weapon="long_tail"`。
- 运行时沿 Story160 已建立的 F7 条件伤害路径消费，不注册 F9
  `skill_weapon_bonus`，也不修改 `weapon_base`。
- 5% 在最终整数 floor 前进入浮点攻击伤害，使真实 PERFECT 起手从
  `37.5/37` 提升为 `39.375/39`。

## 自动化证据

- Initial RED：`reports/report_1680/results.xml`，`1` case / `1` 个预期
  failure，锁定缺失节点定义。
- Focused GREEN：`reports/report_1681/results.xml`，`1/1` 通过，0 failure、
  flaky、skipped、orphan。
- `report_1682` 是相关回归的中间诊断，九个 failure 均为新增节点导致的
  Fish Bone/Electro Bell 固定菜单索引过期，不是产品行为错误。
- Bounded related GREEN：`reports/report_1683/results.xml`，`22/22` 通过，
  覆盖 Story161、Story160、三个相邻 T1-A、DamageCalculator modifier 与
  Main 玩家真实命中链。
- `jq empty data/skill_tree.json` 与
  `jq empty data/schemas/skill_tree.schema.json` 均通过。
- 未运行 full suite，也未在文档更新后重复等价 focused 测试。Godot
  headless 退出时存在项目既有 ObjectDB/resource teardown 提示，但 XML
  报告没有新增测试错误。

## Godot MCP 运行证据

Godot AI MCP plugin/server `3.0.2`，session `cinderpaw@3736`，Godot
`4.7-stable (official)`，最终验收 run `r10362250-5`：

- `project_run(autosave=false)` 启动真实 `res://scenes/main.tscn`，helper
  live，`current_run_errors=[]`。
- 隔离 control Main 通过 Player -> Collision -> Combat ->
  DamageCalculator -> Enemy 链命中：Enemy HP `300 -> 263`，
  `hit_frame=2`，`attack_damage=37.5`，`final_damage=37`，伤害数字 `37`。
- 当前可见 Main 通过真实 `SkillUnlockButton.pressed` 解锁 Node 4/6
  `Long Tail T1 - Honed Tailblade`；SP `1 -> 0`，`has_skill=true`，
  `get_stat_bonus("damage")=0.05`，按钮显示 `Honed Tailblade learned` 并
  disabled。
- 升级后同一真实碰撞链：Enemy HP `300 -> 261`，元数据
  `weapon_id=long_tail`、`hit_frame=2`、`skill_damage_bonus=0.05`、
  `base_damage=15`、`attack_damage=39.375`、`final_damage=39`，伤害数字
  `39`。
- Long Tail 银色攻击弧线 VFX 数量为 `1`，纹理为
  `res://assets/generated/combat_long_tail_arc_runtime.png`。
- 最终 game log 仅 helper、`boss_configs`、`enemy_stats` 三条 info；
  editor log 0 行。停止后 editor readiness 为 `ready`。
- 两张截图均为非空 `1278x718` PNG，并已人工检查：技能树图可见
  `Learned`，战斗图同时可见长尾刃 HUD、银色攻击弧线、敌人 `261/300`
  与金色伤害数字 `39`。

## 素材说明

本 Story 不新增视觉或音频资产。数值被动复用现有 image-generated
Cinderpaw、敌人、环境、HUD 与 Long Tail 弧线；没有需要进入 image
generation 和 Godot import 管线的新素材。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 1 SP、无前置、Node 4/6 可购买 | Focused GREEN + MCP 按钮 | PASS |
| F7 伤害加成只对 Long Tail 生效 | Focused/related GREEN | PASS |
| 真实伤害 `37 -> 39` 与数字 `39` | Focused GREEN + MCP collision eval | PASS |
| Cat Claw 保持 `25` | Focused GREEN | PASS |
| 非空截图、可见 VFX 与干净日志 | MCP capture/logs | PASS |
