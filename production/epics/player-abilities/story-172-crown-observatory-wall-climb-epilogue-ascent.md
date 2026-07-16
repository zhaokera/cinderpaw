# Story 172: Crown Observatory Wall-Climb Epilogue Ascent

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay / Exploration / Save Integration
> **Type**: Traversal + Reward Payoff + Player Feedback
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-17

## Context

Story147 在 Crown Warden 战后发放 `wall_climb`，Story148 随即开放 Scrap
Roost Recall。当前奖励缺少 ACT 内的最终玩法证明。Story172 在同一 Arena 右侧
追加一个生成式美术驱动的攀墙终章，让玩家必须实际触发 Cinderpaw 的
`wall_climb_started` 并抵达高处终点，才可使用原 Recall。

**GDD**: `design/gdd/game-concept.md`, `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/death-respawn.md`

**Governing ADRs**: ADR-0001, ADR-0002, ADR-0007, ADR-0008, ADR-0013,
ADR-0015, ADR-0021.

## Acceptance Criteria

- [x] Crown Warden Arena 扩展为连续 `2560x720` 横版场景；第二画面使用
  image generation 生成的 `1280x720` Crown Observatory 延伸背景，并有与
  画面对应的入口墙、中段落脚点、终点信号脊柱、完成区和坠落区碰撞。
- [x] Boss4 未击败或奖励未领取时终章不可完成；奖励领取后 Recall 保持关闭，
  Objective 显示 `Climb to the Crown Signal`。
- [x] 完成必须同时满足 `wall_climb` 已解锁、终章区域内收到一次真实
  `PlayerController.wall_climb_started`、玩家位于终点范围；跳过攀墙不能完成。
- [x] 首次终章攀墙激活一次性检查点；Boss4 战后坠落或死亡从该点满血复活，
  不重置 Boss、奖励、能力或完成状态。
- [x] 完成写入 `crown_observatory_epilogue_ascent_completed`，重复进入不重放
  完成反馈；旧存档若已有 `boss_04_victory_recall_requested` 则兼容推导为完成。
- [x] 只有终章完成后原 Crown Victory Recall 才可见、可用，Objective 切换为
  `Recall to Scrap Roost`，既有 ACT Complete 证明链保持有效。
- [x] 聚焦 GdUnit、Story147/148 最小回归和一次 Godot AI MCP 运行通过；MCP
  日志无新增错误，截图非空且可见生成背景、Cinderpaw 和终点 Recall。

## Out Of Scope

- Crown Warden 第三阶段、Boss5、真结局、字幕和新叙事演出。
- 修改 Cinderpaw 帧动画、攀墙速度/手感、Boss4 战斗数值或 Main ACT Complete UI。
- 全屏地图、Crown Observatory minimap、音频或新 Autoload。

## Implementation Notes

- 新建专用 `CrownObservatoryEpilogueAscentController` 管理区域证明、检查点、
  终点和坠落信号；Arena 继续拥有存档、Objective、Recall 和玩家复活集成。
- 第二画面使用现有 Observatory 背景作为风格参考生成；碰撞与视觉分离。
- Recall 的 durable proof 不新增 Main 侧条件：新流程通过 Arena 门控保证其传递
  包含终章完成，旧 Recall 存档继续兼容。

## Test Evidence

- Initial RED: `reports/report_1878/results.xml`, `1/1` expected failure on
  missing controller and generated asset artifacts.
- Focused GREEN: `reports/report_1881/results.xml`, `1/1` passed.
- Related regression: `reports/report_1884/results.xml`, Story147/148 `6/6`
  passed.
- Final pre-commit bounded gate: `reports/report_1886/report_1/results.xml`, Story172/147/148
  `7/7` passed, exit code `0`.
- Godot MCP runtime:
  `production/qa/evidence/crown-observatory-wall-climb-epilogue-ascent-2026-07-17.md`.

## Completion Notes

**Completed**: 2026-07-17

**Criteria**: 7/7 passing

**Deviation**: None. Crown Warden Phase III and Boss5 remain separate future
Stories; this slice closes only the approved Wall Climb reward payoff.
