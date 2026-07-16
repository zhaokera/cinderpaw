# QA Evidence: Cinderpaw Dash Afterimage, Speed-Line, and Wind Feedback

> **Story**: `production/epics/combat-presentation/story-031-cinderpaw-dash-afterimage-speed-line-wind-feedback.md`
> **Date**: 2026-07-16
> **Engine**: Godot 4.7 stable
> **Godot AI MCP**: 3.0.2
> **Result**: PASS

## Scope

Main 现在把成功 `dash_started` 独立路由到 Dash presentation/audio：两道当前帧
残影、一组定向速度线和 `sfx_dash`。没有修改 Dash/Dodge gameplay 参数、
角色 SpriteFrames、门控、碰撞、Boss、关卡、存档或 HUD。

## Asset Pipeline

- Built-in image generation 生成无角色、无背景的冷白/月光蓝像素速度线，原始
  RGB source 为 `1717x916`，保留于
  `assets/generated/source/combat_dash_speed_lines_imagegen_20260716.png`。
- Chroma key、despill、Nearest 缩放和硬 Alpha 后得到透明 `192x64` runtime
  PNG；非空 bounds 为 `184x53+4+5`，48 色，alpha 仅 `0/255`。
- 提示词和处理记录：
  `assets/generated/source/combat_dash_speed_lines_imagegen_20260716.md`。
- `sfx_dash.wav` 由留档脚本确定性生成：44.1kHz、mono、PCM16、`0.20s`，
  peak `-5.0dBFS`、RMS `-19.25dBFS`、160ms 后尾音 `-38.01dBFS`。
- Dash WAV SHA-256 为
  `a6badef` 开头，且与 Dodge WAV 的 `4b7c8` 开头 SHA 不同。
- Godot `--import --quit` exit `0`；运行时纹理和 WAV 均能从 `res://` 路径加载。

## TDD And Regression

- RED `report_1836`: 旧 Main 路由产生 3 道 Dodge 残影、alpha
  `[0.5, 0.3, 0.1]`、`dodge/sfx_dodge`，缺少速度线 API/资源，共 `7` 项预期失败。
- GREEN `report_1837`: 新 Story 验收 `1/1`。
- Related `report_1838`: `41` 个用例中 `40` 通过；唯一失败是旧 audio adapter
  在 authored startup 前采样 hitbox。测试改为推进真实 startup，未改 gameplay。
- Adapter `report_1841`: `12/12`，并清理测试触发的 autoload audio players，
  无 ObjectDB/resource leak。
- MCP 暴露已释放速度线诊断的强类型赋值错误；`report_1843` 以过期后等待一帧
  稳定复现，修复后的 `report_1844` 为 `1/1`。
- Final `report_1845`: Dash presentation、Dash runtime、Dodge afterimage、
  AudioSystem、Main audio adapter 五套件 `41/41`，`0 errors / 0 failures /
  0 orphans`，exit `0`。

## Godot MCP Runtime

- Session: `cinderpaw@af5f`。
- Version: Godot `4.7-stable (official)`；plugin/server `3.0.2`。
- Final clean run: `r148800817-42`；自包含验收 wrapper 实例化真实
  `res://scenes/main.tscn`，不会进入提交。
- MCP `input_action(dash)` 后：`animation=dash`、`frame=0`、
  `velocity.x=620.0`、Dash afterimages `2`、Dodge afterimages `0`、
  speed lines `1`。
- 速度线 runtime path 为
  `res://assets/generated/combat_dash_speed_lines.png`，visible=true，
  lifetime `0.10s`，右向 Dash 时 `flip_h=false`。
- Audio event 为 `dash / sfx_dash`，position `(300, 416)`，
  `stream_found=true`，runtime path 为 `res://assets/audio/sfx/sfx_dash.wav`。
- 手动推进 `0.101s` 后 speed-line count 为 `0`，过期诊断 visible=false，
  Dash 残影仍为 `2`；再推进 `0.067s` 后残影为 `0`。
- 再用 MCP `input_action(dodge)`：`animation=dodge`、Dodge afterimages `3`、
  Dash afterimages `0`、speed lines `0`、audio `dodge / sfx_dodge`。
- MCP 返回非空 `1278x718` 游戏截图，真实 Main 和 Dash 速度线/残影可见。
- Game log 为 5 条 helper/DataManager/Story info；editor log 为 0；无 error、
  warning、script error 或 invalid call。最终 stop 后 editor 为 `ready`。

## Residual Work

自动化和 MCP 只证明 `sfx_dash` 与 Dodge 使用不同文件、能正确加载并收到空间
播放请求；高速感、与音乐/环境音的主观层次以及平台响度仍需真人音频评审。
其他独立场景是否需要 Dash presentation owner 由后续 Story 单独评估。

## Verdict

PASS。Main 的 Dash 已拥有与 Dodge 明确区分的角色动作、残影数量、速度线和
独立风声路由，且短生命周期清理不会留下失效实例访问。
