# QA Evidence: Central Tower Apex Conduit Purge Run

## 范围

Story144 将 `area_05_central_tower` 扩展为 `6400x720` 的第五视口，加入 Apex
Roost、带 `0.75s` 预警且以 `150px/s` 推进的净化墙、利用现有移动能力的追逐
路线、死亡重试和持久化 Apex Approach 终点。该切片消费 Story143 完成状态，
不定义 Boss4、新敌人、新能力或奖励。

## 自动化证据

- 预期 RED `reports/report_1523/results.xml` 在实现前以退出码 `100` 失败；
  Story144 控制器、第五视口和素材契约尚不存在。
- 初次 focused GREEN `reports/report_1526/results.xml` 通过 `3/3`。关闭审查发现
  底部坠落只有实现、没有直接断言后，将该路径补入第三用例；fresh closure
  `reports/report_1528/report_1/results.xml` 再次通过 `3/3`，`0` error、
  `0` failure、`0` skipped。
- 最终 focused 覆盖精确素材/alpha/几何、Story143 gate、Roost/autosave、预警、
  确定性净化墙移动、净化墙与底部坠落两条致死路径、复活、失败重置、精确能力、
  终点与 fresh restore 无反馈重放。
- 初次邻接回归 `reports/report_1527/results.xml` 通过 `6/6`；补充坠落断言后，
  fresh Story143-144 回归 `reports/report_1529/report_1/results.xml` 再次通过
  `6/6`，`0` error、`0` failure、`0` skipped，场景扩展未破坏 Deep Lift 上层
  交接。
- 目标 headless smoke 退出 `0`，标记
  `central_tower_apex_conduit_purge_run_smoke=passed`。未运行全量套件。

## 素材证据

- Built-in image generation 生成并保留第五背景、严格 `3x2` 道具/VFX 源图、
  两份精确 prompt 和完整 alpha 中间图。
- 运行时素材为精确 RGB `1280x720` 背景，以及透明 RGBA `256x256` Roost、
  `256x512` 磁性脊柱、`256x384` 发射器、`256x384` 终点信标和 `192x640`
  净化墙。focused 测试检查尺寸、透明角、非空 alpha 和导入路径。
- Run75 截图确认生成背景、Roost、发射器、净化墙、磁性脊柱、Cinderpaw、HUD
  与目标文字同时可见；未见方块占位、纯色角色、洋红键色矩形或不连贯遮挡。
- 本 Story 不新增角色。运行时 Cinderpaw 仍为 `AnimatedSprite2D`，使用既有
  `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`。

## 运行时结果

- 仅 `central_tower_deep_lift_ascended=true` 解锁路线。Apex Roost 激活后记录
  `central_tower_apex_roost` 和 `(5260,252)`，成为 Tower 最新复活点。
- 越过 x `5360` 后先进入 `0.75s` warning；净化墙从 x `5200` 以
  `150px/s` 向右推进。Run74 实时探针在 pursuit 中记录玩家
  `(5743.925,646.592)`、净化墙 x `5660`，并用真实移动/跳跃/dash 到达
  `(6319.775,295.925)`，证明第五视口路线可穿越。
- 净化墙和底部坠落均进入既有死亡/复活流程；自动化覆盖 `1.5s` death beat、
  `50%` HP、`120` i-frames、Apex Roost 返回和能力列表不变。失败会保留 Roost
  与 Story140-143 耐久状态，同时重置当前追逐。
- 终点交互、危险关闭和 `central_tower_apex_approach_secured=true` 由 focused
  与 smoke 覆盖。MCP 由于工具等待期间实时游戏继续推进，未把终点交互误报为
  实玩证据。

## Godot MCP 证据

- Session `cinderpaw@e40d`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `2.9.1`。最终 global class count 为 `296`。
- Run74 首次完成真实 warning、pursuit、净化墙推进和完整路线穿越，同时暴露
  live editor 对新 `CentralTowerApexPurgeController` 的 class cache 过期。按
  AGENTS 规则停止运行，reimport 新脚本、场景和 fixture，执行 filesystem scan
  并 force reload；该运行作为缺陷发现/路线证明，不作为最终 clean run。
- 最终 Run75，id `r452722296-75`，打开 `159` 个 authored nodes，运行时探针
  看到 `107` 个 nodes。真实 `move_right + move_up + dash` 触发 warning 并完成
  截图；`current_run_errors=[]`，editor logger cursor `8 -> 8`，无新增行。
- Run75 当前 game log 仅包含 helper、DataManager、probe、diagnostics 和 capture
  成功记录，无 error/warning。启动响应中的 retained recent errors 明确属于
  pre-run 历史，不计入当前 run。
- 最终截图为非空 RGB `1278x718`、`1,418,504` bytes、`165,480` colors、
  entropy `0.801807`：
  `reports/visual/cinderpaw-mcp-central-tower-apex-purge-run75-20260712.png`；
  SHA-256 `faa1fc72fc01b46fcc1819cadc7e97c3251f8e0ead13a152ac0bf3c73c807c5f`。
- Run75 已停止，Godot editor 恢复 `ready`，未留下运行中的游戏进程。

## 结论

PASS。Story144 已具备可见生成素材、真实移动追逐、致死/复活、可立即重试的
状态重置和持久终点；自动化、target smoke 与最终 clean MCP run 均有证据。
