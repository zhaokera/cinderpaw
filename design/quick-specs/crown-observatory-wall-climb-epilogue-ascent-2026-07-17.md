# Quick Spec: Crown Observatory Wall-Climb Epilogue Ascent

> **Date**: 2026-07-17
> **Status**: Approved by active-goal standing direction
> **Target Story**: Player Abilities Story 172

## Player-Facing Goal

Boss4 的 `wall_climb` 奖励不能只停留在解锁提示。玩家领取 Crown Core 后，
必须立即攀上 Crown Observatory 的外侧信号塔，完成一段可失败、可复活、可恢复
进度的横版攀墙终章，之后才开放既有 Scrap Roost Recall。

## Route

1. Boss4 战斗与原 `1280x720` 竞技场保持不变。
2. 奖励领取后关闭直接 Recall，目标切换为 `Climb to the Crown Signal`。
3. 玩家从竞技场右墙开始真实 `wall_climb`，进入第二个 `1280x720` 观测台画面。
4. 首次有效攀墙激活终章检查点；坠落或死亡从该点复活，不重置 Boss 和奖励。
5. 玩家越过中段落脚点并攀上信号脊柱，在高处终点完成一次性证明。
6. 完成后目标切换为 `Recall to Scrap Roost`，原 Recall 装置在终点开放。

## State Contract

- `crown_observatory_epilogue_checkpoint_activated`: 终章检查点已激活。
- `crown_observatory_epilogue_ascent_completed`: 真实攀墙证明和终点均已满足。
- 已存在的 `boss_04_victory_recall_requested=true` 存档按兼容路径推导为终章已完成。
- 完成、检查点与 Boss/奖励状态共同保存在 Crown Warden Arena 本地状态中。

## Visual Contract

- 通过 built-in image generation 生成一个与现有 Crown Observatory 连续的
  `1280x720` 不透明第二画面，运行时拼接为 `2560x720`。
- 画面必须读出入口高台、中段落脚点、深竖井、可攀磁性信号脊柱和右上终点；
  不包含角色、UI、文字或纯色占位块。
- Godot 碰撞体负责玩法，生成背景负责玩家可见的建筑表面与深度。

## Verification Budget

- 一条聚焦 GdUnit 验收覆盖奖励门控、真实攀墙信号、检查点复活、一次性完成、
  Recall 解锁与存档兼容。
- 最小相关回归只覆盖 Story147 奖励和 Story148 Recall。
- 一次 Godot AI MCP 运行，检查日志、节点、状态和非空截图；不跑全量测试。

## Out Of Scope

- Crown Warden 第三阶段、Boss5、真结局、字幕、全屏地图或新角色动画。
- 改写 `PlayerController` 的攀墙物理、增加新能力或改变 Boss4 数值。
