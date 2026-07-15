# Main Scene 本地小地图发现运行时验收证据

> **Story**: 152
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- `HUDManager` 在右上货币面板下方挂载稳定 `120x120` 小地图，并沿用现有
  HUD 面板样式与 `0.5-1.5` 缩放布局。
- `MinimapWidget` 以代码绘制工业路线：已发现/锁定区域使用填充/空心形状，
  当前区域为菱形，玩家为三角形，不只依赖颜色表达状态。
- Main 配置 `main`、`area_02_sewer`、`area_03_factory`、
  `area_05_central_tower`，玩家标记按 `1280x720` 边界归一化并夹紧。
- 真实 Dash ExplorationGate 解锁使 Sewer 以 `1.0s` 从灰色过渡到彩色，
  显示 `Sewer Access discovered`，继续复用原门碰撞、VFX、SFX 和 world flag。
- 存档/无损恢复直接读取既有 world flags，立即显示完整发现状态且不重放反馈。

## 自动化证据

- Complete RED: `reports/report_1592/report_1/results.xml`，`2/2` 用例完整
  执行，产生 `6` 个预期失败，0 error、0 orphan。
- Focused GREEN: `reports/report_1595/results.xml`，`2/2` 通过，0 error、
  0 failure、0 orphan；进程退出无 ObjectDB 或资源泄漏警告。
- Bounded related GREEN: `reports/report_1596/results.xml`，HUD、Dash、
  Double Jump、Parry gate、门反馈、SaveSystem/Main handoff、HUD settings 与
  Story152 共 8 个套件 `45/45` 通过，0 error、0 failure、0 orphan。组合进程
  完成后报告一个无脚本/资源路径、reference count 为 0 的匿名 `RefCounted`
  框架清理提示；Story152 focused 与 target smoke 均无该提示。
- Target smoke: `tests/smoke/main_scene_minimap_discovery_runtime_smoke.gd`
  退出码 0，输出 `main_scene_minimap_discovery_runtime_smoke=passed`；覆盖真实
  Main、真实 Dash 门、`0.0 -> 0.5 -> 1.0`、world flag 和新实例恢复不重放。
- 未运行全量测试；本切片按项目风险分层采用 focused + bounded related +
  target smoke + MCP runtime。

## MCP 运行时证据

Godot `4.7-stable`，Godot AI MCP plugin/server `2.9.2`，session
`cinderpaw@d40a`，最终 run `r12582583-12`：

- `project_run(mode=main, autosave=false)` 成功，helper live，初始
  `current_run_errors=[]`。
- 运行时层级存在 `/Main/HUD/HudRoot/MinimapHudPanel/MinimapWidget`；面板
  位置 `(1128, 76)`、尺寸 `(120, 120)`、visible，四个区域与
  `code_drawn_schematic / shape_readable=true` 均由真实游戏进程返回。
- 单次干净 eval 记录 Sewer 初始 `discovered=false / progress=0`，真实 Dash
  解锁后 `true / 0`，推进 `0.5s` 后为 `0.5`，再推进 `0.5s` 后为 `1.0` 且
  active reveal 为 0；通知文本正确。
- 保存快照返回 `area_02_sewer_unlocked=true`，重复揭示请求返回 false。
- `reports/visual/cinderpaw-mcp-main-scene-local-minimap-discovery-20260714.png`
  是非空 `1278x718` PNG，画面可见 Cinderpaw、Boss、HUD 和右上小地图；地图
  中可辨认当前菱形、玩家三角形、已发现填充节点与锁定空心节点。
- 最终 game log 仅 3 条 helper/DataManager info，editor log 为 0 行；MCP
  正常停止后 editor readiness 回到 `ready`。

正式 run 前一次诊断 eval 使用局部变量名 `duplicate`，触发 Godot 对
`Node.duplicate()` 的 shadow warning。该临时验证脚本已改名并清空 debugger，
以上正式证据全部来自重新启动后的干净 run `r12582583-12`。

## 素材范围

本切片不新增位图、角色帧或音频。小地图属于功能性代码绘制 HUD，可复用现有
面板视觉且需要实时表达发现进度，因此无需 image generation，也不新增资产
manifest 条目。
