# Echo Guardian Attack Tell 帧动画验收证据

> **Story**: Player Abilities 165
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- Boss2 startup 使用独立的非循环三帧 `attack_tell`，命中框保持关闭。
- 普通 startup 仍为 `8` 帧；Focus 模式仍为 `14` 帧。动画先播完时停在
  frame `2`，不重启、不回到 frame `0`。
- active 边界切换到原有三帧 `attack` 并开启 `boss2_echo_swipe`。
- HP、伤害、阶段、冷却、碰撞、音频、存档和 Double Jump 奖励均未改动。

## 素材证据

- 通过 built-in image generation 生成恰好三格的 `2172x724` 源图，并以
  现有 Echo Guardian sheet 作为视觉参考。
- 保留源图、透明中间图和 JSON 元数据；检测色键为 `#09ed13`。
- 三帧运行时 PNG 均为透明 `160x128`，连续命名 `_000` 到 `_002`，透明
  角点通过自动检查。
- Godot 4.7 headless import 退出码 `0`；`SpriteFrames` 中 `attack_tell`
  为 exactly 3 frames、non-looping、`18 FPS`。

## 自动化证据

- Initial RED：`reports/report_1701/results.xml`，缺少 `attack_tell` 的预期
  failure。
- Initial GREEN：`reports/report_1702/results.xml`，`1/1` 通过。
- Hold RED：`reports/report_1704/results.xml`，复现非循环动画播完后被
  startup tick 重启的问题。
- Final focused GREEN：`reports/report_1705/results.xml`，`1/1` 通过。
- Final bounded related GREEN：`reports/report_1708/results.xml`，`16/16`
  通过，0 error/failure/skipped/orphan。
- `report_1706` 的唯一失败是循环 `run` 在采样点合法回绕到 frame `0`；
  `report_1707` 隔离运行 `6/6` 通过。相关测试改为在 25 个物理帧内记录是否
  观察到任意进阶帧，最终 `report_1708` 通过。
- 未运行 full suite，也未在文档更新后重复等价测试。

## Godot MCP 运行证据

Godot AI MCP plugin/server `3.0.2`，session `cinderpaw@af5f`，Godot
`4.7-stable`，最终验收 run `r12850599-8`：

- 真实 `res://scenes/main.tscn` 中通过 Rat King defeated 世界标记完成
  Main handoff；Echo Guardian 可见、激活、有目标，房间封锁和 Boss HUD
  `Echo Guardian  Phase I  36/36` 正常。
- `/Main/Boss2EchoGuardian/Sprite` 是 `AnimatedSprite2D`，资源路径为
  `res://assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres`；
  动画集合包含 `idle/run/attack_tell/attack/hurt/death`。
- Focus startup 为 `14` 帧。启动后观察到 `attack_tell` frame `2`、
  `is_playing=false`、phase `startup`、hitbox inactive；再推进一帧仍保持同一
  帧和状态。
- 推进到边界后 phase 为 `active`、动画为 `attack` frame `0`、hitbox active，
  Story158 的外部 Focus tell 已按既有时长隐藏。
- 最终 game log 只有 helper、`boss_configs`、`enemy_stats` 三条 info；
  editor log 为 0 行；停止后 readiness 为 `ready`。

截图均为非空 `1278x718` PNG 并已人工检查：

- Startup：
  `reports/visual/cinderpaw-mcp-boss2-echo-guardian-attack-tell-startup-20260714.png`
  (`a5cdb7d68205f8b667ef17660929d5e58dc7436e957edc9b3dbf7318668b584b`)
- Active：
  `reports/visual/cinderpaw-mcp-boss2-echo-guardian-attack-active-20260714.png`
  (`8626ca1db7ef002506966d225263ddf492ca49c6685482a3c70578d67d050c08`)

两张截图中场景、Boss HUD、玩家和 Echo Guardian 均完整可见；startup 的
蓄力轮廓与 active 的出招轮廓清楚不同，无绿色背景或裁切。

## 技术美术复核

- 三帧都是 `160x128` RGBA，四角透明，不透明像素底线均为 `y=119`；画布
  pivot 与现有 Boss2 资源一致。
- 姿势递进使可见像素中心约从 `x=84` 移到 `x=72`。这是蓄力轮廓内的
  12px 运动，未改变 AnimatedSprite2D 节点、角色碰撞体或命中框；结合最终
  MCP 截图判定为可接受的预备动作，不作为阻塞缺陷。
- 普通 8 帧 startup 在 `18 FPS` 下会进入第三帧但停留较短；Focus 14 帧会
  完整播完并保持第三帧。修改 FPS 或 startup 会重开已锁定的表现/玩法边界，
  因此本 Story 保持当前值。
- 项目现有 Echo Guardian 资源采用 `160x128`，与 Art Bible 的通用 Boss
  `96x96`/PNG-8 预算不一致；统一像素过滤和资源预算属于既有项目级美术债务，
  不是本次状态映射的回归。

## 拒绝的运行

- Run token `6` / `r11167773-6`：临时 MCP eval 使用空格缩进，与 3.0.2
  wrapper 的 Tab 缩进冲突，出现 `EVAL_COMPILE_ERROR`。项目文件无错误，
  该 run 不作为验收证据。
- Run token `7` / `r11474731-7`：探索运行发现完成后的非循环 tell 被重复
  启动。新增 last-frame hold 回归并修复后停止，该 run 不作为验收证据。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 三帧透明生成素材与导入 | PNG/metadata/import + focused test | PASS |
| startup tell、inactive hitbox | focused/related GREEN + MCP | PASS |
| Focus 扩展时保持末帧 | hold RED/GREEN + MCP | PASS |
| active 使用 attack、active hitbox | related GREEN + MCP | PASS |
| 游戏参数与奖励契约未变 | 16-case bounded regression | PASS |
| 非空截图与干净日志 | MCP run `r12850599-8` | PASS |
