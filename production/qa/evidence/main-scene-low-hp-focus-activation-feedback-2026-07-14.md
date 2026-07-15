# Main Scene 低血量专注激活反馈验收证据

> **Story**: 154
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- 真实 Player Health 在 active enemy 存在且 HP 首次降至 `25/100` 时进入
  focus mode；阈值、`28%` 退出迟滞和状态所有权保持不变。
- `CombatPresentation` 创建唯一稳定命名的
  `FocusModeActivationOverlay` `TextureRect`，使用透明 `1280x720`
  image-generated 猫眼金边缘纹理，中心保留 gameplay 可读区域。
- overlay 从 Health metadata 读取 `edge_flash_color=#ECC94B` 与
  `edge_flash_duration_sec=0.3`，alpha 确定性地从 `1.0` 淡至 `0.0`；退出
  focus 不创建新闪光。
- Main 同一次激活只向 AudioSystem 路由既有
  `sfx_focus_mode_activate`，实际 stream 可加载。

## 自动化证据

- RED: `reports/report_1604/results.xml`，`1/1` 用例执行并产生 `2` 个预期
  assertion failure，证明 overlay 诊断 API 尚不存在。
- Focused GREEN: `reports/report_1607/results.xml`，`1/1` 通过，0 error、
  0 failure、0 flaky、0 skipped、0 orphan。
- Bounded related GREEN: `reports/report_1610/results.xml`，Story154、
  CombatPresentation、Health focus、AudioSystem 与 Main audio adapter 共
  `75/75` 通过，0 error、0 failure、0 flaky、0 skipped、0 orphan。
- Target smoke: `tests/smoke/main_scene_focus_mode_activation_feedback_smoke.gd`
  退出码 0，输出
  `main_scene_focus_mode_activation_feedback_smoke=passed`，覆盖真实 Main、
  实际 AudioSystem、纹理、尺寸、颜色和生命周期。
- 未运行全量测试；本切片按项目 Superpowers 风险分层采用一个 RED、focused
  GREEN、有限相关回归、target smoke 和一次正式 MCP runtime。

## MCP 运行时证据

Godot `4.7-stable`，Godot AI MCP plugin/server `2.9.2`，session
`cinderpaw@d40a`：

- 初次正式 run `r15395414-15` 成功启动真实 Main。运行时节点检查确认
  `/Main/CombatPresentation/FocusModeActivationLayer/FocusModeActivationOverlay`
  存在且类型为 `TextureRect`。
- 激活诊断为 `focus_active=true`、`overlay_count=1`、尺寸 `1280x720`、
  `edge_color=ecc94b`、`duration_sec=0.3`、`alpha=1.0`；AudioSystem 最后一条
  请求为 `sfx_focus_mode_activate`、`priority=90`、`stream_found=true`。
- 手动推进 `0.15s` 后 alpha 为 `0.5`，累计 `0.3s` 后 overlay count 为 0、
  visible 为 false。
- 截图
  `reports/visual/cinderpaw-mcp-main-scene-low-hp-focus-activation-feedback-20260714.png`
  是非空 `1278x718` PNG，可见真实 Cinderpaw、Boss、HUD 和左右猫眼金边缘，
  中心战斗区域保持可读。
- 初次 editor log 捕获 `combat_presentation.gd:436` 三元表达式类型警告；已将
  NodeName 显式转为 `String`，Godot 4.7 headless editor 重新解析成功。清空
  debugger 后最终复验 run `r15524895-16` 保持同一 overlay/audio 行为，game
  log 仅 3 条 helper/DataManager info，editor log 为 0 行，clean stop。

## 素材证据

- 生成源：
  `assets/generated/source/combat_focus_mode_edge_flash_imagegen_20260714.png`
  (`1672x941` RGB)。
- Alpha 中间件：
  `assets/generated/source/combat_focus_mode_edge_flash_alpha_20260714.png`。
- Runtime：`assets/generated/combat_focus_mode_edge_flash_overlay.png`，Godot
  Import System 确认为 `1280x720` RGBA 且带透明通道。
- 完整 prompt、色键和归一化步骤记录在
  `assets/generated/source/combat_focus_mode_edge_flash_imagegen_20260714.md`，
  manifest 已登记用途与接入路径。
