# Boss Phase Overlay Readability 验收证据

> **Story**: Combat Presentation 019
> **日期**: 2026-07-14
> **结论**: PASS（Run2 布局修复取代 Run1 截图结论）

## 交付合同

- 运行时 Boss 阶段覆盖层改用 image-generated 边缘构图，中心
  `Rect2i(320, 180, 640, 360)` 全透明。
- 只生成一层 `CanvasLayer + TextureRect`，覆盖层为 layer `0`，Arena HUD
  为 layer `1`，鼠标输入不被拦截。
- `BossPhaseOverlay` 运行时 position=`(0, 0)`，rect、纹理和 viewport 均为
  `1280x720`；full-rect anchors 的四个 offset 必须全为 `0`。
- 覆盖层在 `0.40s` 内线性淡出并移除；既有 32 个金属碎片继续保持到
  `1.50s`，不更改 Boss 阶段状态机。

## 自动化证据

- Initial RED：`reports/report_1690/results.xml`，`1` case / `2` 个预期
  failures，失败点为缺少专用素材与 runtime readability diagnostics。
- `reports/report_1691/results.xml` 虽显示 `1/1`，但运行中出现新 PNG 尚未
  完成 Godot import 的 ResourceLoader 错误，因此明确拒绝作为 GREEN。
- Focused GREEN：完成 Godot 4.7 headless editor import 后，
  `reports/report_1692/results.xml` 为 `1/1`，0 failure/error/skipped。
- Bounded related GREEN：`reports/report_1693/results.xml` 为 `40/40`，覆盖
  Story019、CombatPresentation、Rat King runtime contract 与 Crown Warden
  Phase II transition。
- 布局修复 RED：`reports/report_1698/results.xml` 精确复现实际 rect
  `2560x1440`、预期 `1280x720` 的裁切缺陷。
- 布局修复 focused GREEN：`reports/report_1699/results.xml` 为 `1/1`；bounded
  related GREEN：`reports/report_1700/results.xml` 为 `39/39`，均为 0
  failure/error/skipped/orphan。
- Target smoke 退出码 `0`，打印
  `crown_warden_phase_two_transition_feedback_smoke=passed`。
- 未运行 full suite，也未在文档更新后重复等价测试。

## 素材管线证据

- 生成源：
  `assets/generated/source/combat_boss_phase_overlay_readable_imagegen_20260714.png`
  (`1672x941`)。
- Alpha 中间件：
  `assets/generated/combat_boss_phase_overlay_readable_alpha_raw.png`。
- 运行时素材：
  `assets/generated/combat_boss_phase_overlay_readable.png`，sRGBA
  `1280x720`，中心区域 alpha min/max/mean 均为 `0`。
- 三个 PNG 均已由 Godot 4.7 生成 `.import` 记录；精确提示词、处理参数、
  失败的自动取 key 尝试和 SHA-256 记录在
  `design/assets/specs/boss-phase-overlay-readability.md`。

## Godot MCP Run1（布局证据已作废）

Godot AI MCP plugin/server `3.0.2`，session `cinderpaw@af5f`，Godot
`4.7-stable (official)`，run `r22854-1`：

- `project_run(mode="current", autosave=false)` 启动真实
  `res://scenes/bosses/crown_warden_arena.tscn`，helper live，启动错误为空。
- `wing_sweep` 完整收招后进入 Phase II，伤害接受，HP `80/160`，Boss
  animation=`hurt` 且 `3` 帧；Cinderpaw animation=`idle` 且 `3` 帧。
- 峰值诊断为 overlay `1`、debris `32`、纹理已加载、layer `0`、HUD layer
  `1`、lifetime `0.4`、remaining `0.4`、中心安全区
  `[P: (0.25, 0.25), S: (0.5, 0.5)]`，HUD 文本为
  `Crown Warden  Phase II  80/160`。
- 推进到 `0.39s` 时 overlay=`1`、debris=`32`、remaining=`0.01`；推进到
  `0.41s` 时 overlay=`0` 且节点已排队删除，debris 仍为 `32`；推进到
  `1.51s` 时 debris=`0`。
- 原截图：
  `reports/visual/cinderpaw-mcp-boss-phase-overlay-readability-20260714.png`，
  `1278x718`、非空。后续 QA 复查发现右边和底边被裁掉，因此该截图不得再
  用于“覆盖层完整匹配 viewport”的验收；其 Phase II、HUD、动画和时序证据
  仍保留。
- 截图 SHA-256：
  `c8b9b22a12acad14fdbf4b9a1d4bcc0e663b15535d0d8799d5f4b8769fa365f3`。
- 最终 game log 只有 helper、`enemy_stats`、`boss_configs` 三条 info；
  editor log 为 0 行；停止后 readiness=`ready`。

缺陷根因是 `PRESET_FULL_RECT` 已把 anchors 设置为 `(0,0,1,1)`，又设置
positive right/bottom offsets `1280/720`，令 `TextureRect` 实际成为
`2560x1440`；`STRETCH_KEEP_ASPECT_COVERED` 因而只显示源图局部。

旧编辑器会话曾保留 RED 阶段已修复的 `assert_rect2()` 解析缓存。磁盘文件和
CLI GREEN 均已确认修复；强制扫描/重导入仍未清理内存缓存，因此重启 Godot
4.7 后使用新会话完成上述零错误验收，旧缓存不计入最终证据。

## Godot MCP Run2（最终布局验收）

同一 Godot/MCP 版本和 session，最终布局验收 run `r7097860-5`：

- `project_run(mode="custom", scene="res://scenes/main.tscn", autosave=false)`
  启动真实 Main 场景，helper live，启动错误为空。
- 通过真实 Rat King `HealthComponent.apply_damage(120)` 与
  `advance_boss_runtime(0.0)` 进入 Phase II；Boss phase/presentation phase
  均为 `2`，Boss animation=`phase_2_rebuild`。
- 峰值 runtime diagnostics：overlay/debris=`1/32`，position=`(0,0)`，
  overlay rect、texture 和 viewport 均为 `1280x720`，anchors=`[0,0,1,1]`，
  offsets=`[0,0,0,0]`，effect/HUD layer=`0/1`，玩家与 Boss 均 visible。
- 最终截图：
  `reports/visual/cinderpaw-mcp-boss-phase-overlay-readability-run2-20260714.png`，
  `1278x718`、非空；人工检查确认上、右、下、左四边机械框完整，中心
  Cinderpaw、Rat King、Phase II Boss HUD、玩家 HUD 与武器 HUD 清晰可见。
- 截图 SHA-256：
  `785270d6ecc10e18298f2e42eea4b8207002e07461ed46bbc99581b706bb7f3b`。
- game log 只有 helper、`boss_configs`、`enemy_stats` 三条 info；editor log
  为 0 行；停止后 readiness=`ready`。
- 结构化记录：
  `production/qa/evidence/boss-phase-overlay-readability-mcp-run2.json`。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 中心 `50% x 50%` 全透明 | 像素断言 + ImageMagick alpha 统计 | PASS |
| 单层、HUD 在上、输入穿透 | Focused GREEN + MCP Run2 diagnostics/screenshot | PASS |
| rect/texture/viewport 同为 `1280x720`、offset 全零 | Repair RED/GREEN + MCP Run2 | PASS |
| `0.40s` 覆盖层与 `1.50s` 碎片边界 | Focused/related GREEN + MCP deterministic advance | PASS |
| Boss 阶段逻辑不回归 | Crown Warden smoke + bounded Boss regressions | PASS |
| Godot import、四边完整截图、干净日志 | Godot 4.7 import + MCP 3.0.2 Run2 | PASS |
