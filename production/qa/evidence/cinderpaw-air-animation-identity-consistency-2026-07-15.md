# QA Evidence: Cinderpaw Air Animation Identity Consistency

> **Story**: `production/epics/combat-presentation/story-029-cinderpaw-air-animation-identity-consistency.md`
> **Date**: 2026-07-15
> **Engine**: Godot 4.7 stable
> **Godot AI MCP**: 3.0.2
> **Result**: PASS

## Scope

仅替换 Cinderpaw 的 3 帧 jump 与 3 帧 fall 素材，使其回到 idle/run 已确立
的角色身份和硬边像素风格。未修改物理、状态机、场景、SpriteFrames 路径、
hitbox、关卡或音频。

## Asset Pipeline

- Built-in image generation，参考：
  `cinderpaw_sprite_sheet_chroma.png` 与
  `cinderpaw_light_combo_sheet_alpha_20260714.png`。
- 完整提示词与处理记录：
  `assets/characters/cinderpaw/source/cinderpaw_jump_fall_sheet_imagegen_20260715.md`。
- 生成源图：`1536x1024`、严格 3x2、洋红 chroma key。
- 处理：imagegen chroma helper + despill，随后 hard alpha threshold；按
  `512x512` 单元精确切片并以 point/Nearest 缩放为 `96x96`。
- 六帧 soft-edge ratio 均为 `0.000`；红围巾像素 `57-165`，琥珀身份像素
  `82-114`，蓝色漂移像素 `0-1`。
- Godot `--import --quit` exit `0`，新 source/alpha 与六帧均完成导入。

## TDD And Regression

- RED `report_1825`: 旧六帧红色身份像素仅 `6-14`、琥珀身份像素
  `11-16`、soft-edge ratio `0.429-0.513`，验收测试预期失败 `18` 项。
- Focused GREEN `report_1826`: 新视觉身份测试 `1/1`。
- Related 首轮 `report_1827`: jump/fall `9/9` 通过，发现一条与本素材无关的
  Story003 旧断言仍要求 attack sprite 自动播放。
- Root cause: 2026-07-15 的 authored light combo 会在 `_start_attack_visual()`
  故意 pause 第 0 帧，再由 Core contact/recovery 帧切到 1/2；旧断言已改为
  验证 paused frame 0，运行时代码未变。
- Final `report_1829`: identity、air-state、player character 三套件
  `12/12`，exit `0`。
- Fresh completion gate `report_1830`: 同一变更面三套件 `12/12`，
  `0 errors / 0 failures / 0 orphans`，exit `0`。

## Godot MCP Runtime

- Session: `cinderpaw@af5f`。
- Version: Godot `4.7-stable (official)`；plugin/server `3.0.2`。
- Scene: `res://scenes/main.tscn`；run id `r97104478-36`。
- `$Player/Sprite`: `AnimatedSprite2D`，script
  `res://src/characters/cinderpaw.gd`，Nearest texture filter，可见。
- SpriteFrames: `jump=3`、`fall=3`，首帧均为 `96x96` 且资源路径指向
  `assets/characters/cinderpaw/<animation>/`。
- 真实物理帧：向上速度进入 `jump`；玩家移离地面后向下速度进入 `fall`，
  `is_on_floor=false`、sprite 正在播放。
- 截图：MCP 分别返回可见 jump 与 fall 的非空 `1278x718` 游戏截图。
- Logs: helper 与 DataManager 的 3 条 game info；无 error/warning/script
  error/invalid call。最终 stop 返回 `readiness=ready`。

## Verdict

PASS。六帧不再是蓝披风软绘制角色，已成为同一 Cinderpaw 的可见空中帧动画，
并保持既有 gameplay 状态契约。
