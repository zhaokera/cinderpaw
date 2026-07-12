# QA Evidence: Central Tower Deep Lift Counterweight Ambush

## 范围

Story143 将 `area_05_central_tower` 扩展为 `5120x720` 的第四视口，加入真实
物理同步 Deep Lift、一次 Counterweight Sentry 伏击、死亡重试和一个持久化上层
端点。该切片消费 Story142 的 Cooling Shaft 完成状态，不定义 Boss4、新场景、
能力或奖励。

## 自动化证据

- 预期 RED `reports/report_1516/report_1/results.xml` 在实现前以 `1` 个失败退出；
  Story143 控制器、第四视口、敌人和素材契约尚不存在。
- `report_1517` 将实现期问题收敛到玩家/敌人初始重叠、物理同步平台测试路径和
  当前尝试结束后的确定性停靠；这些问题均在生产实现或物理帧测试中修复。
- 最终 focused GREEN `reports/report_1520/report_1/results.xml` 通过 `3/3`，覆盖
  精确素材/场景/数据/动画契约、Story142 gate、真实平台携带、敌我伤害、死亡
  重置、死亡窗口 durable clear、无敌人重试直达、上层端点和无反馈重放恢复。
- 邻接回归 `reports/report_1519/report_1/results.xml` 对 Story141-142 通过 `6/6`。
- MCP Run69 发现 Story142 完成后 fall zone 被关闭，Deep Lift 未清场死亡后从
  Cooling Roost 返回会持续坠落。修复后 `report_1521` 对 Story142-143 通过
  `6/6`，并新增“已 traversed 仍可坠落死亡并在 Cooling Roost 复活”回归。
- 关闭 Story 前 fresh 回归 `reports/report_1522/results.xml` 在 Godot 4.7 下
  再次通过 Story142-143 `6/6`，`0` error、`0` failure、`0` skipped，退出码
  `0`。仅保留测试直接读取 PNG 的已知导出警告及退出时资源清理噪声。
- 目标 headless smoke 退出 `0`，标记
  `central_tower_deep_lift_counterweight_ambush_smoke=passed`。未重复运行全量套件。

## 素材证据

- Image generation 生成并保留第四视口背景、六格 Deep Lift 道具/VFX 源图、
  Counterweight Sentry `3x6` 源图，以及对应 prompt、alpha 和 preview 记录。
- 运行时环境素材包括 `1280x720` 背景、平台、配重、闸门、投放架、制动台和
  warning sweep；透明尺寸、alpha、锚点和导入路径由 focused 测试断言。
- Sentry 的 `idle`、`run`、`attack_tell`、`attack`、`hurt`、`death` 均为
  三张透明 `96x96` 连续帧，并通过
  `assets/characters/central_tower_counterweight_sentry/central_tower_counterweight_sentry_sprite_frames.tres`
  接入 `AnimatedSprite2D`。
- 人工检查 Run73 截图确认背景、平台、角色、Sentry、HUD 和目标文字可见，未见
  方块占位、纯色矩形、烘焙角色/文字、洋红溢色或不连贯遮挡。

## 运行时结果

- 仅 `central_tower_cooling_shaft_traversed=true` 解锁升降台，Story141 cache
  仍可选；玩家站在下层平台并触发 `interact` 后，平台从 `(4380,590)` 到
  `(4380,450)`，真实物理帧把玩家从 y `552` 携带到 y `412`，相对偏移保持
  `-38px`。
- 实体 `2703` 从 lock stop 投放，数据加载为 `44` HP、`24/5/24` 帧、
  `12` 伤害、`120px/s` ram。真实玩家攻击命中后 HP 从 `44` 降到 `32`。
- 未清场死亡使用既有 `1.5s` death beat，在 Cooling Roost `(2740,552)` 以
  `50` HP 和 `120` i-frame 复活；平台、闸门和满血敌人重置。敌人 defeat 与
  上层端点分别持久化，重试不会把玩家锁在升降台下方。
- `central_tower_deep_lift_upper_endpoint` 仅在当前 ride 到达上层且敌人已败时
  接受一次激活，并持久化 `central_tower_deep_lift_ascended=true`。

## Godot MCP 证据

- Session `cinderpaw@e40d`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `2.9.1`。新增类导入后 global class cache 从 `292` 增至 `295`。
- Run69 首次完成真实 `E` 激活、平台携带、Sentry 攻击、死亡与 Cooling Roost
  复活，并由真实返程输入暴露上述 Story142 fall-zone 软锁；该运行作为缺陷发现
  证据，不作为最终 clean run。
- 最终 Run73，id `r444160184-73`，返回 `current_run_errors=[]`；editor logger
  cursor `3 -> 3`，无新增行。启动响应中的 retained recent errors 明确标记为
  pre-run 历史，未出现在当前 run 或 cursor-scoped 日志中。
- Run73 使用真实键 `E` 激活、`move_right` 移动和真实键 `J` 攻击。运行时探针
  记录平台 `(4380,450)`、玩家 `(4416.333,412)`、combat phase、Sentry
  `44 -> 32` HP；随后节点检查看到 `AnimatedSprite2D` 的 `attack` 第 `2` 帧
  和精确 SpriteFrames 路径。
- 当前 run 的七条 game log 均为 helper、DataManager、probe、diagnostics 和
  `idle/attack_tell/hurt` 三次成功截图，没有 error/warning。
- 最终非空截图为 `1278x718`、`1,296,055` bytes：
  `reports/visual/cinderpaw-mcp-central-tower-deep-lift-run73-20260712.png`；
  SHA-256 `d53351fa75f225db81fcdde14edb1afff5c0416f266cdd98704e5eee79ebd888`。
- Run73 已停止，Godot editor 恢复 `ready`，未留下运行中的游戏进程。

## 结论

PASS。Story143 已交付可见生成素材、真实物理平台携带、可交互战斗、帧动画、
死亡/重试和持久端点，并修复了 MCP 实玩发现的 Cooling Roost 返回软锁。
