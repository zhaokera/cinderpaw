# Main Scene PERFECT 弹反金色残影验收证据

> **Story**: Combat Presentation 016
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- 真实 Main Player 继续由既有 `CombatComponent` 判定 PERFECT 弹反；本切片
  不改变弹反窗口、伤害、Cat Energy、帧停、震屏、闪白、火花或音频。
- Main 把当前 `AnimatedSprite2D` 的 `parry` 帧纹理、世界位置、朝向、动画名
  和 frame 作为表现元数据交给 `CombatPresentation`。
- PERFECT 事件生成唯一稳定节点 `PerfectParryGoldAfterimage`。节点使用当前
  Player 帧、代码内 `ShaderMaterial` 生成纯猫眼金 `#ECC94B` 透明剪影，沿朝向
  反方向偏移 `12px`，alpha `0.82`，生命周期 `0.35s`。
- 残影计入既有 200 粒子预算并自动释放。GOOD/MISS 或无纹理的事件保持既有
  表现但不生成金色角色残影。

## 自动化证据

- 初始 RED：`reports/report_1621/results.xml`，`1/1` 用例执行并产生 2 个
  预期 failure，证明残影 API 尚不存在。
- MCP 视觉修正 RED：`reports/report_1624/results.xml`，`1/1` 用例产生 5 个
  预期 failure，锁定纯色 ShaderMaterial、源位置和 `12px` 可读偏移。
- Focused GREEN：`reports/report_1625/results.xml`，`1/1` 通过，0 error、
  failure、flaky、skipped、orphan。
- Final bounded related GREEN：`reports/report_1626/results.xml`，Main 验收、
  CombatPresentation、Main audio adapter 与 Core parry timing 共 `51/51`
  通过，0 error、failure、flaky、skipped、orphan。
- Target smoke：
  `tests/smoke/main_scene_perfect_parry_gold_afterimage_smoke.gd` 退出码 0，
  输出 `main_scene_perfect_parry_gold_afterimage_smoke=passed`。
- 未运行 full suite；本切片遵守项目级风险分层，只执行一次有效初始 RED、一次
  MCP 发现问题的修正 RED、focused/final related、target smoke 和最终 MCP。

## Godot MCP 运行证据

Godot `4.7-stable`，Godot AI MCP plugin/server `2.9.2`，session
`cinderpaw@d40a`，最终 run `r18602105-22`：

- `project_run` 启动 `res://scenes/main.tscn`，helper live，
  `current_run_errors=[]`。
- 运行态通过 Player `request_parry()` 与真实 Combat signal 得到
  `parry_type=perfect`；Player 播放 `parry`，SpriteFrames 帧数为 3。
- 残影 count 为 1、节点存在、纹理与 Player 当前帧为同一资源、material 为
  `ShaderMaterial`；shader color 为 `#ECC94B`、alpha `0.82`。
- Player 世界位置 `(300,416)`，残影位置 `(288,416)`，与向左 `12px` 偏移
  合同一致；既有 flash count 为 1、parry spark count 为 22。
- 手动推进 `0.35s` 后 active count 为 0，下一 process frame 后稳定命名节点
  不再存在。
- 截图
  `reports/visual/cinderpaw-mcp-main-scene-perfect-parry-gold-afterimage-20260714.png`
  是非空 `1278x718` PNG；人工检查可见玩家左侧清晰猫眼金猫形剪影，HUD 与
  战场保持可读。
- 最终 game log 只有 helper、BossConfig 与 EnemyStats 共 3 条 info；editor
  log 0 行；项目 clean stop 后 editor readiness 返回 `ready`。

## 素材说明

本切片没有新增位图素材。视觉直接复用玩家当前 image-generated
`AnimatedSprite2D + SpriteFrames` 帧，并由代码内 shader 派生纯色剪影；因此
不需要新增 image generation source、Godot import、asset spec 或 manifest 行。
