# Main Scene 专注模式环境粒子清晰度验收证据

> **Story**: Player Abilities 159
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- Main 新增一个持续发射、固定 seed 的 `CPUParticles2D` 环境层，使用
  image-generated 透明废土尘粒纹理，保持在角色、交互物、地面和 HUD 后方。
- 正常态粒子层 alpha 为 `1.0`；真实 Player Health 在两个 active enemies
  条件下降至 `25/100` 后进入 focus，仅该层 alpha 降为 `0.30`。
- 治疗至 `35/100` 后退出 focus，粒子 alpha 恢复 `1.0`。
- 三个阶段 Camera2D 均保持 zoom `(1.08, 1.08)`、limits
  `[0, 0, 1120, 720]`；未新增 vignette、screen mask、blur 或 FOV 变化。

## 自动化证据

- Initial RED：`reports/report_1664/results.xml`，`1` case / `3` 个预期
  failure，分别锁定缺失运行时纹理、粒子节点和诊断合同。
- Focused GREEN：`reports/report_1665/results.xml`，`1/1` 通过，0 error、
  failure、flaky、skipped、orphan。
- Bounded related GREEN：`reports/report_1666/results.xml`，Story159、focus
  激活、Boss windup、Boss attack tell 和 Main audio adapter 共 `15/15`
  通过，0 error、failure、flaky、skipped、orphan。
- MCP 3.0.2 升级后 focused 复验：`reports/report_1667/results.xml`，`1/1`
  通过，0 error、failure、flaky、skipped、orphan。
- Target smoke：
  `tests/smoke/main_scene_focus_mode_environment_particle_clarity_smoke.gd`
  退出码 0，输出
  `main_scene_focus_mode_environment_particle_clarity_smoke=passed`，并记录
  normal/focus/restored alpha `1.0/0.3/1.0` 与相机不变合同。
- 未运行 full suite；本切片按项目验证预算只执行 focused/related GdUnit、
  target smoke 和一次干净 MCP runtime。
- Godot 关闭时仍有项目既有 ObjectDB/resource teardown 提示，但 GREEN
  报告没有新增 test error、failure 或 orphan。

## 视觉素材证据

- 精确提示词与处理记录：
  `assets/generated/source/combat_focus_environment_dust_mote_imagegen_20260714.md`。
- 生成源与 alpha 中间文件均为 `1254x1254`；运行时输出为精确 `64x64`
  RGBA，alpha `0..1`，四角透明，可见 bounds `24x24+20+20`。
- Godot 4.7 已生成 `.import`，运行态纹理路径为
  `res://assets/generated/combat_focus_environment_dust_mote.png`。

## Godot MCP 运行证据

Godot `4.7-stable`，当次 Story 验收使用 Godot AI MCP plugin/server
`2.9.2`，session `cinderpaw@d40a`，clean run `r29075015-35`：

- MCP 强制从磁盘重载并启动真实 `res://scenes/main.tscn`，
  `current_run_errors=[]`、helper live。
- Normal：HP `100`、focus `false`、`CPUParticles2D` emitting、amount `24`、
  fixed seed `159`、texture path 正确、alpha `1.0`。
- Focus：HP `25`、focus `true`，同一节点 alpha `0.3000000119`；amount、
  seed、纹理、z index `-90` 和相机 framing 不变。
- Restored：HP `35`、focus `false`、alpha 恢复 `1.0`，相机仍不变。
- 正常截图
  `reports/visual/cinderpaw-mcp-focus-environment-normal-20260714.png` 与
  focus 截图
  `reports/visual/cinderpaw-mcp-focus-environment-clarity-20260714.png` 均为
  非空 `1278x718` sRGB PNG；人工检查可见实际 Main、Cinderpaw、两名 Boss、
  HUD 和稀疏背景尘粒，focus 图保持相同视野且环境干扰更弱。
- 最终 game log 仅 helper、boss_configs、enemy_stats 三条 info；editor log
  0 行；stop 后 editor readiness 为 `ready`。
- 前一探索 run34 因 MCP 操作脚本误读不存在的 `current_health` 字段进入
  debugger break；该操作脚本错误已定位为 `get_current_hp()`、停止并清空
  debugger，run35 从全新启动完成干净验收，run34 不作为通过证据。
- Story 验收完成后，项目 Godot AI MCP 已升级到 `3.0.2`，并另以
  `production/qa/evidence/godot-ai-3-0-2-upgrade-2026-07-14.md` 证明新基线
  的连接、Main 启动和 clean logs；Story159 focused test 与 target smoke
  也在升级后复验通过。
