# QA Evidence: Old Factory Aftershock Exhaust Escape Production Combat Exit Hatch Handoff -- 2026-07-22

## Scope

Player Abilities Story210 将 Story091 接入真实移动、可读夹击、两种真实 bite、
四次真实玩家轻攻击、partial/full live death 与 Story092 unopened hatch 交接。
本切片不新增素材、经济规则、存档 schema、全局敌人分离或开舱流程。

## TDD And Regression Evidence

- `reports/report_2270/results.xml`：初始 canonical RED，`1` case、`5` 个
  预期 failure。
- `reports/report_2271/results.xml`：review-refined RED，仍为 `5` 个精确
  failure，覆盖旧 `44px` overlap 与首具尸体在 full clear 被隐藏。
- `reports/report_2272/results.xml`：focused GREEN，`1/1`。
- `reports/report_2273/results.xml`：四 suite 首轮相关回归，`6` case 中仅
  Story091 的旧即时隐藏断言失败。
- `reports/report_2274/results.xml`：更新旧契约后的 Story091 focused，`2/2`。
- `reports/report_2275/results.xml`：最终四 suite bounded related，`6/6`，
  零 failure/error/flaky/skip/orphan。
- Factory `180` 帧 headless smoke 退出 `0`；日志：
  `reports/old_factory_aftershock_exhaust_escape_skirmish_production_combat_exit_hatch_handoff_smoke.log`。
  项目 script/parse/invalid-call/access/resource-load 关键错误词为空，仅 stdout
  保留既有 `4 ObjectDB / 2 resources` 退出诊断。
- 未运行 full suite。

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`；Godot `4.7-stable`；Godot AI MCP
  plugin/server `3.0.4`。
- Accepted run `r142990853-69` 启动
  `res://scenes/factory_route_transition_shell.tscn`，`autosave=false`，helper live。
- 真实 `move_right` 从 x `3096` 越过 activation x `3112`。Opening anchors
  为 Coil `2952`、Cinderpaw `3112`、Spark `3256`，两侧 `160/144px`、
  enemy center `304px`；opening grace 为 Coil/Spark `22/10`。
- Spark 的真实 `rat_minion_bite` 记录 attacker `2134`、target `1`、weapon
  `factory_spark_rat_bite`、final damage `9`；Coil 对应记录 attacker
  `2135`、weapon `factory_coil_rat_bite`、final damage `10`。
- 四次真实 `attack` / `cat_claw_light` 完成 Spark 和 Coil 各自
  `24 -> 12 -> 0`。第一具尸体 hurtbox 为 `gone` 后与 Coil 重叠，后续命中
  仍正确落到 entity `2135`，证明尸体不会截获攻击。
- Partial clear 保持首具 `death` visible/process，关闭 physics、target、
  hurtbox、bite 与 body collision；幸存敌人继续战斗，hatch 仍隐藏。
- Full clear 瞬间两具均为三帧 `death`、visible/process on，physics/target/
  hurtbox/body/bite off。Story092 变为 available/visible/interactive/blocking，
  `opened=false`、unlock VFX count `0`；静止复查仍未自动打开。
- Accepted game log 只有 helper registration info，editor log 为空；所有
  gameplay input 均 released，project stop 后 editor ready。
- Exploratory runs 67/68 只暴露 MCP eval 探针的缩进/死亡展示窗口问题；
  停止、清空 Debugger 后由无探针错误的 run 69 完整替代。

## Visual Evidence

- MCP 返回非空 RGB `1278x718` opening 与 cleared hatch screenshots；opening
  清楚显示 Coil/Cinderpaw/Spark 三个 authored 角色轮廓，不是方块占位。
- 本地保留 cleared handoff 截图：
  `reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-escape-skirmish-production-combat-exit-hatch-handoff-cleared-20260722.png`，
  非空 RGB `1278x718`，显示 Factory authored 环境、`Open Aftershock Exhaust
  Hatch` 目标与关闭的 hatch visual。

## Asset Use

未新增视觉素材。复用已登记的 image-generated Cinderpaw、Factory Spark Rat、
Factory Coil Rat、Old Factory 环境、exit hatch 与 unlock spark，不修改 asset
manifest、entity inventory、SpriteFrames 或 import。

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Fresh movement activates Story091 | Canonical; MCP real input | PASS |
| 304px pincer keeps 128px+ flanks | Canonical; scene; MCP probe | PASS |
| 10/22 opening grace | Canonical; MCP diagnostics | PASS |
| Real Spark/Coil bites deal 9/10 | Canonical; MCP metadata | PASS |
| Four real attacks defeat 2134/2135 | Canonical; MCP 24 -> 12 -> 0 | PASS |
| Corpse cannot steal survivor hit | Canonical; MCP overlapping target | PASS |
| Partial/full live death is collision-safe | Canonical; related; MCP state | PASS |
| Story092 is ready but unopened | Story092 regression; MCP stationary probe | PASS |
| Godot 4.7 / MCP 3.0.4 logs are clean | Smoke; accepted run 69 | PASS |
