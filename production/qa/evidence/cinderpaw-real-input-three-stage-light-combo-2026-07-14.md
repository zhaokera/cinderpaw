# Cinderpaw 真实输入三段轻击连招验收证据

> **Story**: Player Abilities 166
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- 真实 `attack` InputMap 在恢复窗口内按次推进 `0 -> 1 -> 2`。
- 长按不自动续段；第三段恢复期再次按攻击不会创建或重启第四段。
- Player 表现寿命跟随 Core 的 `12/18/30` 帧，并分别播放 `attack`、
  `attack_2`、`attack_3`。
- 连段结束后再次起手回到 `combo 0`。
- 伤害、猫气、武器、技能修正、碰撞 ID、现有六帧轻击 hitbox 时长和其他
  动作状态均未修改。

## 素材证据

- 使用现有 Cinderpaw chroma sheet 作为 reference，通过 built-in image
  generation 生成 `1254x1254`、严格 `3x3` 的九姿势源图。
- 保留 RGB 源图、RGBA 中间图和提示词/处理记录；边缘采样色键为
  `#0def16`。
- 每格 `418x418`，Nearest 缩放到 `96x96`；仅做纵向平移，九帧 alpha
  下边界统一为 `y=88`，最大可见宽度 90px，未裁切。
- `attack`、`attack_2`、`attack_3` 均为 exactly 3 frames、non-looping；
  速度分别为 `15/10/6 FPS`，角色节点 `texture_filter=Nearest`。
- Godot 4.7 MCP `EditorFileSystem.scan()` 完成，六张新增 PNG 均生成并加载
  `.import` 元数据。

## 自动化证据

- Initial RED：`reports/report_1709/results.xml`，预期失败同时证明缺少
  后两段动画与真实恢复输入未推进。
- Final focused GREEN：`reports/report_1713/results.xml`，`2/2` 通过，覆盖
  真实输入、长按、第四段拒绝、重置、路径、尺寸、透明角、FPS、loop 和
  Nearest 过滤。
- Final bounded related GREEN：`reports/report_1714/results.xml`，`20/20`
  通过，覆盖 Player 动画、Core 连段窗口、Main 武器命中链、技能树第二段
  突进和重攻击隔离。
- 未运行 full suite，文档更新后未重复等价测试。
- GdUnit wrapper 中 remote-debug `127.0.0.1:0` 拒绝是脚本注释明确记录的
  防交互调试策略；相关套件退出时保留既有 ObjectDB/resource cleanup 提示，
  不影响 `20/20`、退出码 `0`，也未出现在最终 MCP 游戏/编辑器日志中。

## Godot MCP 运行证据

Godot AI MCP plugin/server `3.0.2`，session `cinderpaw@af5f`，Godot
`4.7-stable`，验收 run `r55211566-9`：

- 真实 `res://scenes/main.tscn` 启动成功，helper live。为隔离玩家动画，
  仅在运行内临时停用并隐藏 `Enemy` 与 `Boss2EchoGuardian`；未修改场景文件。
- `/Main/Player/Sprite` 为 `AnimatedSprite2D`，动画集合包含
  `attack/attack_2/attack_3`，帧数 `3/3/3`、速度 `15/10/6`、filter `1`
  (`Nearest`)。
- 第二段快照：`combo_index=1`、`animation=attack_2`、
  `total_frames=18`。
- 第三段起手：`combo_index=2`、`animation=attack_3`、
  `total_frames=30`；接触帧为 animation frame `1`、Core frame `12`、
  recovery active。
- 第三段恢复期再次发送真实攻击输入后，Core frame `12 -> 13`，仍为
  `combo_index=2 / attack_3`，`fourth_restarted=false`。
- 第三段结束并等待 20 个物理帧后，下一次真实输入为
  `combo_index=0 / attack / total_frames=12`。
- MCP 返回的第二段与第三段截图均为非空 `1278x718` PNG；人工检查可见
  Cinderpaw、场景和不同爪击轮廓，无绿色背景、裁切或 UI 遮挡。
- 最终 game log 仅三条 info（helper、`boss_configs`、`enemy_stats`），
  editor log 为 0 行；停止后 readiness 为 `ready`。

## 验收映射

| 验收项 | 证据 | 状态 |
| --- | --- | --- |
| 真实输入三段连招 | focused GREEN + MCP | PASS |
| 长按与第四段拒绝 | focused GREEN + MCP frame 12→13 | PASS |
| `12/18/30` 帧同步 | focused GREEN + MCP diagnostics | PASS |
| 九帧透明生成素材 | source/alpha/metadata + PNG 检查 | PASS |
| SpriteFrames 与 Nearest | focused GREEN + MCP | PASS |
| 既有战斗链不回归 | bounded `20/20` | PASS |
| 非空截图与干净日志 | MCP run `r55211566-9` | PASS |
