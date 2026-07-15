# Skill Tree Fish Bone T1-B Damage Choice 验收证据

> **Story**: Player Abilities 162
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- `fish_bone_t1b` 是与 T1-A 并行的 1 SP 被动节点，无前置条件。
- 数据使用 `stat_key="damage"`、`ADD 0.08` 与
  `condition.weapon="fish_bone"`。
- 运行时沿 Story160 已建立的 F7 条件伤害路径消费，不注册 F9
  `skill_weapon_bonus`，也不修改 `weapon_base`。
- 8% 在最终整数 floor 前进入浮点攻击伤害，使真实 PERFECT 起手从
  `100` 提升为 `108`；错误走 F9 会得到 `107`。

## 自动化证据

- Initial RED：`reports/report_1684/results.xml`，`1` case / `1` 个预期
  failure，锁定缺失节点定义。
- Focused GREEN：`reports/report_1685/results.xml`，`1/1` 通过，0 failure、
  flaky、skipped、orphan。
- Bounded related GREEN：`reports/report_1686/results.xml`，`16/16` 通过，
  覆盖 Story162、Cat Claw/Long Tail T1-B、Fish Bone/Electro Bell T1-A 与
  DamageCalculator special modifier。
- `jq empty data/skill_tree.json` 与
  `jq empty data/schemas/skill_tree.schema.json` 均通过。
- 未运行 full suite，也未在文档更新后重复等价 focused 测试。RED 与
  focused headless 退出时存在项目既有 ObjectDB/resource teardown 提示，
  XML 报告没有新增测试错误；最终 related run 未出现该提示。

## Godot MCP 运行证据

Godot AI MCP plugin/server `3.0.2`，session `cinderpaw@3736`，Godot
`4.7-stable (official)`，最终验收 run `r13362848-6`：

- `project_run(autosave=false)` 启动真实 `res://scenes/main.tscn`，helper
  live，`current_run_errors=[]`。
- 隔离 control Main 通过 Player -> Collision -> Combat ->
  DamageCalculator -> Enemy 链命中：Enemy HP `300 -> 200`，
  `weapon_id=fish_bone`、`crit_type=perfect`、`hit_frame=2`、
  `base_damage=40`、`attack_damage=100`、`final_damage=100`，伤害数字
  `100`。
- 当前可见 Main 通过真实 `SkillUnlockButton.pressed` 解锁 Node 6/7
  `Fish Bone T1 - Honed Fishbone`；SP `1 -> 0`，`has_skill=true`，
  `get_stat_bonus("damage")=0.08`，按钮显示 `Honed Fishbone learned` 并
  disabled。
- 升级后同一真实碰撞链：Enemy HP `300 -> 192`，元数据
  `weapon_id=fish_bone`、`crit_type=perfect`、`hit_frame=2`、
  `skill_damage_bonus=0.08`、`skill_weapon_bonus=0`、`base_damage=40`、
  `attack_damage=108`、`final_damage=108`，伤害数字 `108`。
- Fish Bone 白色骨浪 VFX 数量为 `1`、生命周期 `0.3s`，纹理为
  `res://assets/generated/combat_fish_bone_wave_runtime.png`。
- 最终 game log 仅 helper、`boss_configs`、`enemy_stats` 三条 info；
  editor log 0 行。停止后 editor readiness 为 `ready`。
- 两张截图均为非空 `1278x718` PNG，并已人工检查：技能树图可见
  `Learned`；战斗图可见 Cinderpaw、鱼骨大剑 HUD、白色骨浪、敌人
  `192/300` 与金色伤害数字 `108`。

## 素材说明

本 Story 不新增视觉或音频资产。数值被动复用现有 image-generated
Cinderpaw、敌人、环境、HUD 与 Fish Bone 骨浪；没有需要进入 image
generation 和 Godot import 管线的新素材。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 1 SP、无前置、Node 6/7 可购买 | Focused GREEN + MCP 按钮 | PASS |
| F7 伤害加成只对 Fish Bone 生效 | Focused/related GREEN | PASS |
| 真实伤害 `100 -> 108` 与数字 `108` | Focused GREEN + MCP collision eval | PASS |
| Cat Claw 保持 `25` | Focused GREEN | PASS |
| 非空截图、可见 VFX 与干净日志 | MCP capture/logs | PASS |
