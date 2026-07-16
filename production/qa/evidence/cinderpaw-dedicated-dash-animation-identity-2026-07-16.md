# QA Evidence: Cinderpaw Dedicated Dash Animation Identity

> **Story**: `production/epics/combat-presentation/story-030-cinderpaw-dedicated-dash-animation-identity.md`
> **Date**: 2026-07-16
> **Engine**: Godot 4.7 stable
> **Godot AI MCP**: 3.0.2
> **Result**: PASS

## Scope

仅替换 Cinderpaw 的三张 Dash PNG，使其不再复制 Dodge，并补充运行时像素差异
验收。未修改 SpriteFrames 路径、PlayerController、能力参数、场景、Dodge、
hitbox、存档、关卡或音频运行时代码。

## Asset Pipeline

- Built-in image generation，参考 Cinderpaw 主精灵表和最新 jump/fall alpha sheet。
- 完整提示词与处理记录：
  `assets/characters/cinderpaw/source/cinderpaw_dash_strip_imagegen_20260716.md`。
- 生成源图 `2172x724`，固定三等分为三个 `724x724` 单元；chroma helper +
  despill 后硬 Alpha，Point/Nearest 统一缩放到 `88x88` 并居中到 `96x96`。
- 三帧为 PNG-8、61-63 色、`1302-1348` bytes，半透明像素均为 `0`。
- 非透明像素 `908/916/891`，最大/最小体量比约 `1.028`。
- 红围巾像素 `48/78/69`，琥珀身份像素 `71/73/65`。
- 对应 Dodge alpha silhouette 差异为 `71.23%/49.89%/58.79%`。

## TDD And Regression

- RED `report_1831`: 旧 Dash 与 Dodge 三对像素完全相同，差异比例均为 `0`，
  产生预期 `6` 项失败。
- Focused GREEN `report_1832`: 新 Dash identity 测试 `1/1`。
- Related 首轮 `report_1833`: `7/7` 断言通过，但 CLI 退出发现两个音频 stream
  与两个 playback 仍被测试用 AudioSystem 持有。
- Root cause: `player_dash_ability_runtime_test` 实例化 Main 并触发音乐/Dash SFX，
  清理时未 stop 并置空 autoload player 的 stream。按项目现有测试模式补齐
  cleanup，未修改游戏音频行为。
- Final `report_1835`: 三套件 `7/7`，`0 errors / 0 failures / 0 orphans`，
  exit `0` 且不再出现 ObjectDB/resource leak。

## Godot MCP Runtime

- Session: `cinderpaw@af5f`。
- Version: Godot `4.7-stable (official)`；plugin/server `3.0.2`。
- Scene: `res://scenes/main.tscn`；run id `r141438875-37`。
- 真实 Input `dash` 触发后：`animation=dash`、中间帧 `frame=1`、
  `velocity.x=620.0`、cooldown remaining `0.9333s`。
- `$Player/Sprite` 为可见 `AnimatedSprite2D`；Dash 为 3 帧、非循环、
  `18 FPS`，三张纹理均为 `96x96` 且路径位于 `assets/characters/cinderpaw/dash/`。
- 运行时三帧与 Dodge 像素比较为 `[true, true, true]`，表示全部不同。
- MCP 返回非空 `1278x718` 游戏截图，Main gameplay 与 Dash 中的 Cinderpaw
  可见。
- Logs: 3 条 helper/DataManager game info；editor log 为 0；无 error、warning、
  script error 或 invalid call。最终 stop 后 editor 为 `ready`。

## Residual Work

GDD 中 Dash 的两道高速残影、独立速度线表现事件和专用风声仍未由本 Story
实现；现有 Dash 仍复用 Dodge presentation event。该差距应单独立项，避免把
帧动画身份修复误报为完整 Dash presentation。

## Verdict

PASS。Dash 已成为与 Dodge 可辨认的三帧高速穿越动作，保持 Cinderpaw 身份、
现有 gameplay 参数和 Godot 资产接线。
