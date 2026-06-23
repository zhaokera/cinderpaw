# ADR-0010: 音频系统架构 (总线, 池化, 空间)

## Summary
定义音频系统的技术架构：5 条音频总线（Master/Music/SFX/Ambient/UI），音效池化（max 16 并发），空间音频（AudioStreamPlayer2D），音乐状态机（区域主题+Boss战斗切换）。

## Status
Proposed

## Date
2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6.3 |
| **Domain** | Audio / Presentation |
| **Knowledge Risk** | LOW — Audio API stable since 4.0 |
| **Post-Cutoff APIs Used** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Autoload), ADR-0007 (场景管理) |
| **Enables** | 所有需要音效的系统 |
| **Blocks** | 音频系统实现 |

## Context

### Problem Statement

架构文档定义 AudioSystem 为 Autoload，但未确定：
1. 音频总线结构
2. 音效池化策略
3. 空间音频实现
4. 音乐切换机制
5. 并发控制

## Decision

### 音频总线结构

```
Master (80%)
├── Music (60%)
├── SFX (80%)
├── Ambient (50%)
└── UI (70%)
```

**配置**: project.godot 中定义总线布局，AudioSystem 在 `_ready()` 时验证。

### 音效池化

```gdscript
# AudioSystem (Autoload)
const MAX_CONCURRENT_SFX: int = 16
var _sfx_pool: Array[AudioStreamPlayer2D] = []
var _sfx_index: int = 0

func _ready():
    for i in MAX_CONCURRENT_SFX:
        var player = AudioStreamPlayer2D.new()
        player.bus = "SFX"
        add_child(player)
        _sfx_pool.append(player)

func play_sfx(sfx_id: StringName, position: Vector2, volume_db: float = 0.0):
    var player = _sfx_pool[_sfx_index]
    _sfx_index = (_sfx_index + 1) % MAX_CONCURRENT_SFX
    player.stream = _load_sfx(sfx_id)
    player.position = position
    player.volume_db = volume_db
    player.play()
```

**规则**:
- 池化避免频繁创建/销毁 AudioStreamPlayer
- 超过 16 并发时覆盖最旧的音效
- 优先级系统：弹反/暴击 > 普通命中 > 环境音效（通过 `play_sfx_priority()` 实现）

### 空间音频

- **2D 音效**: 使用 `AudioStreamPlayer2D`，位置与游戏世界坐标绑定
- **距离衰减**: 300px 开始，600px 外静音（使用 `max_distance` 属性）
- **全局音效**: UI、音乐使用 `AudioStreamPlayer`（无空间定位）

### 音乐状态机

```gdscript
enum MusicState { EXPLORING, BOSS_FIGHT, CUTSCENE, MENU }
var _current_state: MusicState = MusicState.EXPLORING
var _current_music: AudioStreamPlayer

func change_music(music_id: StringName, fade_in_sec: float = 1.0):
    if _current_music:
        _fade_out(_current_music, fade_in_sec)
    _current_music = AudioStreamPlayer.new()
    _current_music.stream = _load_music(music_id)
    _current_music.bus = "Music"
    add_child(_current_music)
    _fade_in(_current_music, fade_in_sec)
```

**场景切换**: 3 秒交叉淡入淡出  
**Boss 战**: 1 秒硬切  
**Boss 阶段转换**: 2 秒过渡  
**Boss 战结束**: 3 秒淡出

## Consequences

### Positive
- **性能**: 池化避免 GC 压力
- **控制**: 总线独立控制音量
- **沉浸**: 空间音频增强定位感
- **灵活**: 音乐状态机支持动态切换

### Negative
- **内存**: 16 个 AudioStreamPlayer 常驻（开销小）
- **复杂度**: 音乐状态机需要管理过渡

## GDD Requirements Addressed

- `design/gdd/audio-system.md` — Rule 1 (总线), Rule 2 (触发), Rule 3 (音乐), Rule 4 (空间), Rule 5 (优先级)
