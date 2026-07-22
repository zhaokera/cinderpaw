# QA Evidence: Old Factory Coil Pincer Flank Spacing -- 2026-07-21

## Scope

Player Abilities Story203 修复 Story202 记录的自然站位重叠：Story082 仍由真实
玩家右移启动，但两只敌人改为围绕实际 activation provider 形成前后夹击，且在
opening grace 结束后的自然追击中继续满足最低视觉分离阈值。本切片不修改敌人
战斗、死亡、数值、持久化或后续 Story083/084 交接。

## TDD Evidence

- `reports/report_2215/results.xml`: canonical RED，`1` test、`6` expected
  failures、`0` errors。失败覆盖 Spark/Coil 同侧、两侧最小 `48px` 空间、最小
  `130px` 中心距，以及 opening grace 后拓扑保持。
- `reports/report_2221/results.xml`: final focused GREEN，`1/1`，零 failure、
  error、flaky、skip 或 orphan。
- `reports/report_2218/results.xml`: 首次 bounded related，五个 suite、`6/7`。
  唯一失败来自 Story083 对 defeated Coil Rat 当帧 hidden 的旧断言，与已批准的
  Story202/Combat Presentation Story037 可见 death 合同冲突。
- `reports/report_2220/results.xml`: 修正旧断言后的 final bounded related，
  五个 suite、`7/7`，零 failure、error、flaky、skip 或 orphan；覆盖本 Story、
  Story201 production handoff、Story082、Story202 production combat 与 Story083。
- Godot 4.7 对 `res://scenes/factory_route_transition_shell.tscn` 执行 `180` 帧
  headless smoke 并退出 `0`。日志为
  `reports/old_factory_coil_pincer_flank_spacing_smoke.log`；关机阶段的
  `4 ObjectDB / 2 resources` 为既有 Factory teardown baseline。
- 未运行 full suite；本次只执行变更表面对应的 focused、bounded related、
  smoke 与一次最终 MCP runtime acceptance。

## Runtime Contract

- 激活 helper 以实际 provider X 为 anchor，Spark Rat 使用 `+144px`，Coil Rat
  使用 `-160px`，初始中心距固定为 `304px`；两者 Y 不变。
- `-160px` 是 MCP 对初版 `-176px` 的反馈修正：玩家继续越过 trigger 后，后侧
  Coil 仍需保留在 `180px` alert radius 内。
- Authored fallback X 为 `2160/1856`，与默认 activation `2016` 对齐；生产
  activation 会按玩家实时位置重新 stage，不依赖固定场景坐标。
- opening grace 仍为 `10/26`，HP 仍为 `24/24`，entity IDs `2126/2127`、
  target、process/physics、hurtbox、family、攻击和移动参数均不变。
- Focused test 只用真实 `Input.move_right` 激活，不直接调用 encounter activation
  API，不移动/冻结敌人。它在双 grace 归零后继续等待 `20` physics frames，再
  验证一左一右、每侧至少 `48px`、中心至少 `130px`。
- 新增 diagnostics 仅暴露 activation anchor 和实时中心距，不进入 local state
  或 SaveSystem schema。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `3.0.4`；accepted clean run `r124835541-44`（run token `44`）。
- MCP 用 custom Factory scene、`autosave=false` 和 scene-local Story081-complete
  状态建立前置条件；敌人没有被重定位或冻结，`Engine.time_scale` 未修改。
- 真实 `input_action(move_right)` 从玩家 `x=2004` 启动 Story082；activation
  anchor `2016.222`，Spark `x=2160.222`、Coil `x=1856.222`，中心距 `304px`。
- 输入停止时玩家约 `x=2029`，Spark/Coil 位于约 `+131.22/-172.78px`；双方
  `target_in_alert_radius=true`，grace 剩余 `5/21`，总合同仍为 `10/26`，HUD
  为 `Break Coil Pincer`。
- 连续自然运行约 `20` post-grace physics frames 后，玩家约 `x=2035.33`，
  Spark/Coil 分别约 `x=2094.62/1832.89`，相对玩家 `+59.29/-202.44px`，
  中心距 `261.73px`；双方 grace 为 `0`，仍 visible、targeted、physics enabled。
- MCP screenshot 为非空 RGB `1278x718`，可见 Cinderpaw、左右两侧动画敌人、
  image-generated Factory 环境和目标 HUD，不是占位方块。
- Accepted-run game log 只有 game-helper registration info；editor log 零行，
  没有新增 script、runtime、resource 或 scene error。游戏已 clean stop。

## Residual Risks

- 本 Story 保证激活和短期追击的可读拓扑，不实现全局 crowd steering；长时间战斗、
  玩家反向穿越或墙角压缩仍可能让敌人交叉，应由共享多敌 AI slice 统一处理。
- Post-grace Coil 可在自然追击中暂时离开 `180px` alert radius，但仍保持左侧
  patrol 和视觉分离；本 Story 只要求激活时双方可感知玩家。
- Story083 entity `2128` 的 production combat/death 与 Story084 handoff 仍是
  下一 Old Factory gameplay slice。

## Asset Use

未生成新图片。Story203 复用已登记的 image-generated Factory Spark Rat、
Factory Coil Rat、Cinderpaw 与 Factory 环境；没有 PNG、SpriteFrames、source、
import、manifest 或 entity inventory 变更。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| 真实右移启动 Story082 | Story203 focused；MCP real `move_right` | PASS |
| 玩家相对前后 flank staging | Focused GREEN；MCP anchor/position diagnostics | PASS |
| 初始 `48/130px` 可读阈值 | Focused GREEN；MCP `304px` center | PASS |
| 双方初始处于 alert radius | Focused GREEN；MCP initial pacing | PASS |
| grace `10/26` 与战斗合同不变 | Related GREEN；MCP runtime | PASS |
| post-grace 20 帧仍保持两侧拓扑 | Focused GREEN；MCP natural chase | PASS |
| Story202/083 相邻合同不回归 | Bounded related `7/7` | PASS |
| Godot 4.7 / MCP 3.0.4 runtime 干净 | Smoke；accepted logs；screenshot | PASS |
