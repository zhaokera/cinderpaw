# Main Scene 专注模式 Boss 启动优势运行时验收证据

> **Story**: Player Abilities 157
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- 真实 Player Health 在 active enemy 存在且 HP 降至 `25/100` 时进入 focus
  mode；Main 将同一信号路由给 Rat King 与 Echo Guardian。
- focus 内新开始的攻击仅延长 startup：Rat King `claw_swipe` 为
  `15 + 6 = 21` 帧，Echo Guardian 为 `8 + 6 = 14` 帧。
- HP 恢复到 `35/100` 并退出 focus 后，后续攻击扩展归零；已经进入 startup
  的攻击仍保持 `21`/`14`，不会中途缩短。
- 本切片未新增素材，继续复用 Story154 的 image-generated 猫眼金边缘遮罩和
  Rat King `claw_swipe`、Echo Guardian `attack` 的既有三帧动画。

## 自动化证据

- Initial RED：`reports/report_1656/results.xml`，`1` case 产生 `3` 个预期
  failure，锁定 Main 与两名 Boss 缺少运行时 focus 接口。
- Focused GREEN：`reports/report_1657/results.xml`，`1/1` 通过，0 error、
  failure、flaky、skipped、orphan。
- Final bounded related GREEN：`reports/report_1659/results.xml`，Story157、
  Story154、AI Story005、Boss2 telegraph、Rat King runtime 与 Main audio
  adapter 共 `28/28` 通过，0 error、failure、flaky、skipped、orphan。
- Target smoke：
  `tests/smoke/main_scene_focus_mode_boss_windup_runtime_smoke.gd` 退出码 0，
  输出 `main_scene_focus_mode_boss_windup_runtime_smoke=passed`，并打印
  `15/6/21` 与 `8/6/14` 诊断。
- 未运行 full suite；本切片按风险边界使用一个 RED、focused GREEN、一次
  有限相关回归、target smoke 和一次正式 MCP runtime。
- Godot 关闭时仍有项目既有 ObjectDB/resource teardown 提示，但 GREEN
  报告没有新增 test error、failure 或 orphan。

## Godot MCP 运行证据

Godot `4.7-stable`，Godot AI MCP plugin/server `2.9.2`，session
`cinderpaw@d40a`，run `r26343036-32`：

- MCP 启动真实 `res://scenes/main.tscn`，`current_run_errors=[]`，helper live。
- 真实 Health transition 得到 `player_hp=25`、`player_focus_active=true`；
  Rat King 与 Echo Guardian 均成功请求攻击并停留在 `startup`。
- Rat King 诊断为 base `15`、extension `6`、current `21`、pattern
  `claw_swipe`；Echo Guardian 为 base `8`、extension `6`、current `14`。
- 两个运行态节点均为 `AnimatedSprite2D`，当前攻击动画各 `3` 帧。现有
  `FocusModeActivationOverlay` 为可见 `TextureRect`，alpha `1.0`、尺寸
  `1280x720`、纹理路径为
  `res://assets/generated/combat_focus_mode_edge_flash_overlay.png`。
- 恢复到 `35 HP` 后 focus 退出，两名 Boss 的 future extension 都为 `0`，
  当前攻击 startup 仍保持 `21`/`14`。
- 截图
  `reports/visual/cinderpaw-mcp-focus-boss-windup-20260714.png` 是非空
  `1278x718` RGB PNG；人工检查可见 Cinderpaw、两名生成角色的攻击帧、
  Boss/Player HUD 和猫眼金边缘遮罩。
- 最终 game log 仅 helper、boss_configs、enemy_stats 三条 info；editor log
  0 行；stop 后 editor readiness 为 `ready`。
