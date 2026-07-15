# Main Scene 自动存档猫爪印反馈验收证据

> **Story**: 153
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- `HUDManager` 在右上 HUD 集群挂载稳定 `AutosavePawStamp` `TextureRect`，
  初始隐藏，只在 Main 自动存档被接受后显示。
- 猫爪通过 `AtlasTexture` 复用 image-generated
  `scene_transition_paw_spinner.png` 的 `(88,16,80,80)` 区域，不新增重复素材。
- 每次显示前 `1.0s` 保持不透明，最后 `0.5s` 线性淡出，`1.5s` 时隐藏；
  最大 HUD 缩放 `1.5` 下尺寸为 `96x96`，位于小地图下方且不遮挡核心 HUD。
- Main 仅在 autosave adapter 返回成功时路由一次 `ui_save`，metadata 保留
  `slot=0`、`source=autosave`、reason 与深复制 context；失败不产生反馈。

## 自动化证据

- RED: `reports/report_1597/results.xml`，`2/2` 用例执行并产生 `3` 个预期
  assertion failure，证明缺少 HUD API/节点/生命周期。
- Final focused GREEN: `reports/report_1603/results.xml`，`2/2` 通过，0 error、
  0 failure、0 flaky、0 skipped、0 orphan。
- Bounded related GREEN: `reports/report_1602/results.xml`，Story153、HUD、Main
  savepoint、Main audio adapter 与 autosave adapter 共 `41/41` 通过，0 error、
  0 failure、0 flaky、0 skipped、0 orphan。
- Target smoke: `tests/smoke/main_scene_autosave_paw_stamp_feedback_smoke.gd`
  退出码 0，输出 `main_scene_autosave_paw_stamp_feedback_smoke=passed`；覆盖真实
  Main、同步临时 SaveSystem、最大 HUD 缩放、文件写入、音效 metadata 和生命周期。
- 未运行全量测试；按项目风险分层采用 focused + bounded related + target smoke
  + 一次正式 MCP runtime。GdUnit CLI 退出时仍打印无项目路径的通用 ObjectDB /
  resource cleanup 提示，但 XML 为 0 error/0 orphan，正式 MCP 日志干净。

## MCP 运行时证据

Godot `4.7-stable`，Godot AI MCP plugin/server `2.9.2`，session
`cinderpaw@d40a`，最终 run `r14231021-14`：

- `project_run(mode=main, autosave=false)` 成功，helper live，初始
  `current_run_errors=[]`；SaveSystem 被临时重定向到
  `user://cinderpaw_story153_mcp/`，未覆盖正常玩家存档。
- 真实 `activate_runtime_savepoint(scrap_roost, main, scrap_roost)` 返回 true，
  slot 0 文件存在；AudioSystem 最后一条请求为 `event_id/ui_sfx_id=ui_save`、
  `stream_found=true`，metadata 包含 slot 0、savepoint reason、autosave source
  和完整 savepoint context。
- 初始诊断返回 `visible=true / alpha=1.0 / remaining=1.5`；推进至 `1.0s`
  后仍为 `alpha=1.0`，再推进 `0.25s` 为 `alpha=0.5`，`1.5s` 时为
  `visible=false / alpha=0.0`。
- 运行时层级确认 `/Main/HUD/HudRoot/AutosavePawStamp` 存在且类型为
  `TextureRect`，纹理属性为 `AtlasTexture`；最大缩放位置 `(1152,295)`、
  尺寸 `(96,96)`、`z_index=8`。
- `reports/visual/cinderpaw-mcp-main-scene-autosave-paw-stamp-feedback-20260714.png`
  是非空 `1278x718` PNG，画面可见真实 Cinderpaw、Boss、HUD 和小地图下方猫爪，
  未遮挡小地图、货币或底部状态面板。
- 最终 game log 仅 3 条 helper/DataManager info，editor log 为 0 行；MCP
  正常停止后 editor readiness 回到 `ready`。

第一次诊断 eval 使用可静态推断的临时 `texture` 变量，触发 MCP 临时代码的
Parser Error，并同时发现 Story153 局部变量 `visible` 遮蔽 CanvasLayer 属性的
告警。项目变量已改为 `stamp_visible`；随后停止运行、清空 debugger 并重新启动，
以上正式证据全部来自干净 run `r14231021-14`。

## 素材范围

本切片不生成新位图或音频，复用已登记的 image-generated 猫爪源和现有
`ui_save.wav`。复用用途、AtlasTexture 区域和接入 Story 已回写资产 manifest；
最终猫叫加书写 Foley 仍属于后续音频制作范围。
