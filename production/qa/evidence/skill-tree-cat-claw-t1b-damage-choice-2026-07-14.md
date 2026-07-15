# Skill Tree Cat Claw T1-B Damage Choice 验收证据

> **Story**: Player Abilities 160
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- `cat_claw_t1b` 是与 T1-A 并行的 1 SP 被动节点，无前置条件。
- 数据保留 GDD 指定的 `stat_key="damage"`、`ADD 0.05` 与
  `condition.weapon="cat_claw"`。
- 运行时只在消费 modifier 时按当前武器过滤；同一节点不注册 F9
  `skill_weapon_bonus`，避免双轨重复增伤。
- 5% 在最终整数取整前进入攻击伤害。普通低伤害命中可能因整数 floor
  显示不变，但真实 PERFECT 起手从 `25` 提升为 `26`。

## 自动化证据

- Initial RED：`reports/report_1672/results.xml`，`1` case / `1` 个预期
  failure，锁定缺失节点定义。
- 实现过程中的 `report_1673` 至 `report_1675` 用于定位测试时序：
  `HitEvent.hit_frame` 是 hitbox 剩余帧，最终以剩余 `2` 帧稳定命中
  PERFECT 窗口。这些中间报告不作为通过证据。
- Focused GREEN：`reports/report_1676/results.xml`，`1/1` 通过，0 error、
  failure、flaky、skipped、orphan。
- 最终 fresh focused：`reports/report_1679/results.xml`，`1/1` 通过，0
  error、failure、flaky、skipped、orphan。
- Bounded related GREEN：`reports/report_1678/results.xml`，`23/23` 通过，
  覆盖 Story160、Cat Claw/Long Tail/Fish Bone/Electro Bell T1-A、
  DamageCalculator modifier 与 Main 玩家真实命中链。
- `jq empty data/skill_tree.json` 与
  `jq empty data/schemas/skill_tree.schema.json` 均通过。
- 未运行 full suite；本切片按验证预算只执行 focused/related 与一次 MCP
  runtime。Godot 退出时的既有 ObjectDB/resource teardown 提示不属于测试
  failure，XML 报告无新增错误。

## Godot MCP 运行证据

Godot AI MCP plugin/server `3.0.2`，session `cinderpaw@3736`，Godot
`4.7-stable (official)`，run `r6401979-3`：

- `project_run(autosave=false)` 启动真实 `res://scenes/main.tscn`，helper
  live，`current_run_errors=[]`。
- 独立 control Main 通过真实 Player/Collision/Combat/DamageCalculator 链：
  Enemy HP `300 -> 275`，`hit_frame=2`，`attack_damage=25.0`，
  `final_damage=25`，伤害数字 `25`。
- 当前可见 Main 授予 1 SP 并打开 Skill Tree；第 2/5 节点为
  `cat_claw_t1b`，subtitle 显示 `Cat Claw T1 - Honed Claws`、`5% more
  damage`，真实 `SkillUnlockButton.pressed` 可用。
- 按钮解锁后 SP `1 -> 0`，`has_skill=true`，
  `get_stat_bonus("damage")=0.05`，按钮变为 disabled，文本为
  `Honed Claws learned`。
- 升级后同一真实碰撞链：Enemy HP `300 -> 274`，元数据
  `weapon_id=cat_claw`、`hit_frame=2`、`skill_damage_bonus=0.05`、
  `base_damage=10`、`attack_damage=26.25`、`final_damage=26`，伤害数字
  `26`。
- 最终 game log 仅 helper、`boss_configs`、`enemy_stats` 三条 info；
  editor log 0 行。停止后 editor readiness 为 `ready`。
- 技能树与战斗截图均为非空 `1278x718` PNG：
  `reports/visual/cinderpaw-mcp-skill-tree-cat-claw-t1b-20260714.png`、
  `reports/visual/cinderpaw-mcp-cat-claw-t1b-damage-20260714.png`。

## 素材说明

本 Story 不新增视觉或音频资产，复用现有 image-generated 场景、角色、
敌人与 HUD。没有需要进入 image generation 管线的新素材。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 1 SP、无前置、可见菜单购买 | Focused GREEN + MCP 按钮 | PASS |
| 解锁、查询与存档恢复 | Focused GREEN | PASS |
| 仅 Cat Claw 消费 5% | Focused/related GREEN | PASS |
| 真实伤害 `25 -> 26` | Focused GREEN + MCP collision eval | PASS |
| 非空截图与干净日志 | MCP capture/logs | PASS |
