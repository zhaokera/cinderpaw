# Main Scene 死亡与复活视觉反馈验收证据

> **Story**: Death & Respawn 008
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- 真实 Main lethal damage 保留既有 `1.5s` GameFlow 死亡延迟与三帧
  `death` 动画，不新增第二个复活所有者。
- `PlayerDeathFeedbackLayer` 使用 screen-sampling `ShaderMaterial`，灰度在
  `0.5s` 内从 `0.0` 到 `1.0`；真实复活后在 `0.5s` 内退回 `0.0`。
- `PlayerDeathVfxLayer` 位于灰度层之上，死亡时显示 8 个 image-generated
  猫眼金灵魂光点，复活时显示 1 个持续 `1.0s` 的猫眼金光环。
- 真实复活仍为 `50/100 HP`、三帧 `revive` 动画和既有 2 秒无敌闪烁。
- VFX Tween 已结束或节点被提前释放时，计时桶清理保持幂等，不产生运行时
  freed-instance 错误或残留节点。

## 自动化证据

- 初始合同 RED：`reports/report_1611/results.xml`。
- 初始 focused GREEN：`reports/report_1612/results.xml`，`1/1` 通过。
- MCP 首轮发现真实 Tween/计时桶竞态；回归 RED
  `reports/report_1614/results.xml` 精确复现 `Trying to assign invalid
  previously freed instance`，修复后 `reports/report_1615/results.xml`
  `33/33` 通过。
- 金色 VFX 必须高于灰度层的合同 RED：`reports/report_1617/results.xml`；
  focused GREEN：`reports/report_1618/results.xml`，`1/1` 通过。
- 最终 bounded related：`reports/report_1620/results.xml`，6 个套件、
  `47/47`，0 error、0 failure、0 flaky、0 skipped、0 orphan。
- Target smoke：
  `tests/smoke/main_scene_death_respawn_visual_feedback_smoke.gd` 退出码 0，
  输出 `main_scene_death_respawn_visual_feedback_smoke=passed`。
- 未运行全量测试；本切片按项目风险分层规则执行 focused、有限相关回归、
  target smoke 和 Godot MCP runtime。

## MCP 运行时证据

Godot `4.7-stable`，Godot AI MCP plugin/server `2.9.2`，session
`cinderpaw@d40a`：

- 正式截图 run `r17113490-19` 在真实 Main 中验证死亡阶段
  `flow_state=dying`、三帧 `death`、8 个 wisp、灰度 `1.0`，灰度层为 `102`、
  保色 VFX 层为 `103`。
- 同一 run 验证复活阶段 `flow_state=revived`、三帧 `revive`、`50 HP`、
  invincibility visual active、1 个 halo；灰度按 `1.0 -> 0.5 -> 0.0` 退出，
  halo 在灰度消失后继续存在并于累计 `1.0s` 清理，最终 phase 为 `idle`。
- 死亡截图
  `reports/visual/cinderpaw-mcp-main-scene-death-greyout-feedback-20260714.png`
  为非空 `1278x718` PNG，可见灰色 Main/Boss/HUD 与角色位置上方保留金色的
  灵魂光点。
- 复活截图
  `reports/visual/cinderpaw-mcp-main-scene-revive-halo-feedback-20260714.png`
  为非空 `1278x718` PNG，可见 `50/100 HP`、灰色世界与金色复活光环。
- 首轮 MCP 捕获 freed-instance runtime error；修复并加回归后不再复现。
  随后清理局部变量遮蔽和整数除法 warning。最终 clean run
  `r17306475-20` 重放完整死亡到 idle 链路，game log 仅 3 条
  helper/DataManager info，editor log 为 0 行，clean stop 回到 ready。

## 素材证据

- 生成源：
  `assets/generated/source/combat_player_death_revive_feedback_sheet_imagegen_20260714.png`
  (`1672x941` RGB)。
- Alpha 中间件：
  `assets/generated/source/combat_player_death_revive_feedback_sheet_alpha_20260714.png`。
- Runtime：`assets/generated/combat_player_death_soul_wisp.png`
  (`256x256` RGBA) 与 `assets/generated/combat_player_revive_halo.png`
  (`512x512` RGBA)，均带透明通道并由 Godot Import System 导入。
- 完整 image generation prompt、用途、色键与拆分步骤记录在
  `assets/generated/source/combat_player_death_revive_feedback_imagegen_20260714.md`，
  manifest 已登记用途与接入路径。
