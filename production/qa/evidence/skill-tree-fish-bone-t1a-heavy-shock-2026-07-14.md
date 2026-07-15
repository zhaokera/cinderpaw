# Fish Bone T1-A Heavy Shock 验收证据

> **Story**: 150
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- `fish_bone_t1a` 是 Fish Bone 分支的 1 SP T1-A 节点，作用于
  `heavy_attack / knockback_distance / ADD 8.0`。
- Skill Tree 保持 Cat Claw -> Long Tail -> Fish Bone -> Electro Bell 的固定
  分支顺序；Fish Bone 当前是第三个可选节点，购买一次并随存档恢复。
- 任意合法 `0.5-1.5s` Fish Bone grounded heavy 命中普通敌人后，由目标
  `CollisionComponent` 沿攻击方向移动 `8px`；墙体可以截短位移，重复检测
  不会重复击退。
- 命中结果保留 requested/applied/direction/blocked 元数据，并在接触点复用
  既有 image generation 素材 `combat_fish_bone_wave_runtime.png`。

## 自动化证据

- RED: `reports/report_1579/report_1/results.xml`，原始 3 个测试产生 16 个
  预期失败。
- Related GREEN: `reports/report_1582/report_1/results.xml`，9 个测试套件
  `60/60` 通过，覆盖 Story150/149/018、grounded heavy、Fish Bone shield
  break、Collision Story003/004、Main attack routing 与 CombatPresentation。
- Final focused GREEN: `reports/report_1585/results.xml`，`4/4` 通过，0 error、
  0 failure、0 orphan，并补齐墙体裁剪和反向击退边界。
- SchemaValidator regression: `reports/report_1586/results.xml`，`13/13`
  通过，覆盖 integral JSON float 对 int schema 的兼容与 fractional float
  拒绝；控制台 error/warning 来自测试刻意构造的负例。
- Target smoke: `reports/skill_tree_fish_bone_t1a_heavy_shock_smoke.log`，
  退出码 0，输出 `skill_tree_fish_bone_t1a_heavy_shock_smoke=passed`，精确
  位移 `8.0`，目标存活，进程无资源泄漏或清理警告。
- 未运行全量测试；本 Story 使用风险分层的 focused + bounded related +
  headless smoke + MCP runtime 组合。

## MCP 运行时证据

Godot `4.7-stable`，Godot AI MCP plugin/server `2.9.2`，session
`cinderpaw@d40a`，最终 run `r8347138-8`：

- `project_run(mode=main, autosave=false)` 启动成功，helper 状态为 live，
  `current_run_errors=[]`。
- 正式 runtime eval 返回 `ok=true`、`unlocked=true`、`skill_knockback_px=8`、
  `displacement=8`、`duplicate_displacement=8`、`knockback_applied=true`、
  `knockback_blocked=false`、`vfx_count=2`、目标 HP `52`。
- 玩家 `heavy_charge`、`heavy_attack` 和普通 Rat Minion `hurt` 均为
  `AnimatedSprite2D + SpriteFrames` 三帧动画。
- `skill-tree-fish-bone-t1a-heavy-shock-mcp-charge-2026-07-14.png` 与
  `skill-tree-fish-bone-t1a-heavy-shock-mcp-hit-2026-07-14.png` 均为非空
  `1278x718` PNG；后者清晰显示 Cinderpaw 与存活普通鼠敌。
- 最终 game log 只有 3 条 helper/DataManager info，editor log 为 0 行；
  无新增 warning/error，随后通过 MCP 正常停止运行。

首次诊断 eval 使用了不存在的 `Main.get_current_weapon_id()` 读取方法，MCP
将运行置于 debugger break。该诊断 run 已停止并清空日志；正式证据来自随后
重新启动的干净 run `r8347138-8`，没有把诊断错误计入通过结果。

结构化值保存在
`skill-tree-fish-bone-t1a-heavy-shock-mcp-run-2026-07-14.json`。

## 素材范围

本切片不新增图片或音频。既有 Fish Bone 波纹来自 image generation，源文件
为 `assets/generated/source/combat_fish_bone_wave_imagegen_20260624.png`，运行时
文件为 `assets/generated/combat_fish_bone_wave_runtime.png`；新增 Story 用途已
登记到 `design/assets/asset-manifest.md`。
