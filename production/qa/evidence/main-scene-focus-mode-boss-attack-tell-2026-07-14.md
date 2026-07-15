# Main Scene 专注模式 Boss 攻击预警放大验收证据

> **Story**: Player Abilities 158
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- 真实 Player Health 在战斗中降至 `25/100` 后，Rat King 与 Echo Guardian
  新发起攻击的信号红预警面积固定为 `1.25x`，持续时间固定为 `1.10x`。
- Rat King 视觉预警由 base `15` 变为 `ceil(15*1.10)=17` 帧，Echo Guardian
  由 base `8` 变为 `ceil(8*1.10)=9` 帧。
- 视觉预警结束后各自恢复隐藏、alpha `0` 和原始缩放；Story157 的攻击 startup
  仍保持 `21`/`14` 帧，不改变 hitbox、damage、active/recovery 或角色缩放。
- 两名 Boss 复用 image-generated 透明 `256x128` 红色开放中心警示环，角色本体
  继续使用现有 `AnimatedSprite2D + SpriteFrames` 三帧攻击动画。

## 自动化证据

- Initial RED：`reports/report_1660/results.xml`，`1` case / `3` 个预期
  failure，锁定缺失纹理与两名 Boss 缺失诊断接口。
- Refinement RED：`reports/report_1661/results.xml`，`1` case / `3` 个预期
  lifecycle failure，暴露 Rat King deterministic advance 未推进表现层计时。
- Focused GREEN：`reports/report_1662/results.xml`，`1/1` 通过，0 error、
  failure、flaky、skipped、orphan。
- Final bounded related GREEN：`reports/report_1663/results.xml`，Story158、
  Story157、Boss2 telegraph、Rat King runtime 和双 Boss handoff 共 `12/12`
  通过，0 error、failure、flaky、skipped、orphan。
- Target smoke：
  `tests/smoke/main_scene_focus_mode_boss_attack_tell_smoke.gd` 退出码 0，
  输出 `main_scene_focus_mode_boss_attack_tell_smoke=passed`。
- 未运行 full suite；本切片按项目风险分层规则只执行聚焦测试、有限相关回归、
  target smoke 和一次正式 MCP runtime。
- Godot 关闭时仍有项目既有 ObjectDB/resource teardown 提示，但 GREEN 报告
  没有新增 test error、failure 或 orphan。

## 视觉素材证据

- 精确提示词与处理记录：
  `assets/generated/source/combat_focus_mode_boss_attack_tell_imagegen_20260714.md`。
- 生成源 `1672x941`，alpha 中间文件 `1672x941`，运行时输出为精确
  `256x128` RGBA；四角透明，alpha 范围 `0..1`。
- Godot 4.7 已生成 `.import`，运行态纹理路径为
  `res://assets/generated/combat_focus_mode_boss_attack_tell.png`。

## Godot MCP 运行证据

Godot `4.7-stable`，项目 Godot AI MCP plugin/CLI `2.9.2`，session
`cinderpaw@d40a`，run `r27682351-33`：

- MCP 启动真实 `res://scenes/main.tscn`，`current_run_errors=[]`，helper live。
- `player_hp=25`、`player_focus_active=true`，两名 Boss 均成功进入 startup。
- Rat King：startup `15+6=21`；预警 base `15`、total/remaining `17`、
  base scale `0.95`、focus scale `1.1875`、area `1.25`、duration `1.10`。
- Echo Guardian：startup `8+6=14`；预警 base `8`、total/remaining `9`、
  base scale `0.68`、focus scale `0.85`、area `1.25`、duration `1.10`。
- 两个节点均为可见 `Sprite2D`，纹理路径正确；Rat King `claw_swipe` 与
  Echo Guardian `attack` 均为第 `1` 帧、总 `3` 帧。
- 分别推进 `17`/`9` 帧后，两个预警均 `remaining_frames=0`、隐藏、
  alpha `0` 并恢复原始缩放，同时 Boss 仍处于延长后的 startup。
- 截图 `reports/visual/cinderpaw-mcp-focus-boss-attack-tell-20260714.png`
  为非空 `1278x718` sRGB PNG；人工检查可见 Cinderpaw、Rat King、Echo
  Guardian、两处红色攻击预警、Boss/Player HUD 与实际场景素材。
- 最终 game log 仅 helper、boss_configs、enemy_stats 三条 info；editor log
  0 行；stop 后 editor readiness 为 `ready`。
