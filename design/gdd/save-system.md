# 存档系统 (Save System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 间接支撑全部支柱
> **Systems Index**: #10 | MVP核心 | Feature

## Overview

**存档系统**管理游戏状态的持久化存储和恢复。它在存档点自动保存玩家进度（HP、武器等级、能力解锁、Boss击败状态、世界状态等），并支持手动加载已保存的存档。采用`ISerializable`接口模式——各系统自实现序列化方法，存档系统负责协调调用和文件写入。

## Player Fantasy

**「猫的脚印」— 进度安全的安心感**

存档系统的终极使命是让玩家**不怕探索**。每次到达存档点时自动保存，玩家知道自己的进度是安全的——不会因为游戏崩溃或意外关闭而丢失数小时的努力。存档点本身也是探索的奖励（发现新区域=发现新存档点）。

## Detailed Design

### Core Rules

#### 规则1：存档触发条件
- **自动存档**：到达存档点（猫族据点、地图中的猫窝存档点）时自动触发
- **Boss击败后**：Boss死亡后自动存档
- **手动存档**：暂停菜单中"保存游戏"选项（仅存档点附近可用）
- **关键事件后**：获得新能力、完成重要任务后自动存档

#### 规则2：存档数据结构
```
save_data = {
    version: String,                    # 存档版本号
    timestamp: String,                  # ISO 8601格式
    play_time_sec: float,
    player_state: {
        position: Vector2,
        current_hp: int, max_hp: int,
        current_weapon: String,
        weapon_levels: Dictionary,      # {weapon_id: level}
        unlocked_abilities: Array,
        currency: int
    },
    world_state: {
        defeated_bosses: Array,
        unlocked_areas: Array,
        discovered_save_points: Array,
        quest_progress: Dictionary
    },
    settings: {
        input_bindings: Dictionary,
        audio_volumes: Dictionary,
        display_settings: Dictionary
    }
}
```

#### 规则3：ISerializable接口模式
```
interface ISerializable:
    func serialize() -> Dictionary
    func deserialize(data: Dictionary)

func save_game():
    var save_data = {}
    for system in registered_systems:
        save_data[system.name] = system.serialize()
    write_to_file(save_data, get_save_path())
```

#### 规则4：存档槽位
- 支持**3个存档槽位**
- 每个槽位显示：缩略图、游玩时间、最近存档点名称、存档日期
- 槽位0为"自动存档"槽位（不可手动覆盖）

#### 规则5：存档文件管理
- 存储路径：`user://saves/slot_[0-2].json`
- 文件格式：JSON
- 备份机制：每次保存前将旧存档重命名为`.bak`
- 存档大小限制：单存档不超过100KB

### States and Transitions

存档系统无运行时状态机。操作模式：
- IDLE：等待触发
- SAVING：正在写入文件（<100ms，不阻塞游戏）
- LOADING：正在读取文件（短暂暂停，显示加载画面）

### Interactions with Other Systems

**上游依赖**：
- 所有实现`ISerializable`接口的系统

**下游被依赖**：
- HUD/UI系统 — 存档槽位显示
- 场景管理系统 — 加载时恢复场景

**接口签名**：
```
register_serializable(system_name, system: ISerializable) → void
save_game(slot: int = 0) → bool
load_game(slot: int) → bool
get_save_info(slot: int) → SaveInfo
delete_save(slot: int) → bool
has_save(slot: int) → bool
```

## Formulas

本系统不定义游戏平衡公式。存档大小估算：
`save_size_kb ≈ (player_state + world_state + settings) / 1024`
预期单存档 < 50KB。

## Edge Cases

- **存档时游戏崩溃**：`.bak`备份保留，提示"使用备份？"
- **存档文件损坏**：尝试加载`.bak`，仍失败则提示"存档损坏"
- **存档版本不匹配**：执行数据迁移，无法迁移则提示"版本过旧"
- **磁盘空间不足**：保存前检查，不足时提示
- **多槽位同时操作**：加锁机制
- **存档点附近死亡**：死亡后在最近存档点重生

## Dependencies

**上游依赖**：
- 所有实现ISerializable的系统（生命、武器、世界状态等）

**下游被依赖**：
- HUD/UI系统 — 存档槽位显示
- 场景管理系统 — 加载时恢复场景

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| max_save_slots | 3 | 1-10 | 槽位太多混乱 | 槽位太少 |
| auto_save_interval_sec | 300 | 120-600 | 太频繁 | 太少 |
| max_save_size_kb | 100 | 50-500 | 文件太大 | 数据截断 |
| backup_count | 1 | 1-3 | 占空间 | 无备份 |

## Visual/Audio Requirements

### 存档视觉反馈
- **自动存档**：屏幕右上角出现猫爪印章图标（1.5秒后淡出）
- **手动存档**：暂停菜单中的存档槽位卡片（显示缩略图+信息）
- **加载画面**：猫武士走过存档点动画（2-3秒）

### 音效设计
- **自动存档**：轻柔的猫叫声+纸笔书写音
- **手动存档确认**：印章盖下音
- **加载完成**：猫伸懒腰音

## UI Requirements

### 存档槽位卡片
- 尺寸：200×120px
- 显示：游戏截图缩略图、游玩时间、存档点名称、日期
- 空槽位：显示"空槽位 — 点击保存"

### 加载菜单
- 位置：主菜单 + 暂停菜单中
- 显示3个槽位卡片
- 操作：选择加载/删除/覆盖

## Acceptance Criteria

- **GIVEN** 玩家到达存档点，**WHEN** 自动存档触发，**THEN** 所有ISerializable系统数据写入slot_0.json
- **GIVEN** 存档文件存在且有效，**WHEN** 选择加载，**THEN** 所有系统从存档数据恢复状态
- **GIVEN** 存档过程中游戏崩溃，**WHEN** 下次启动，**THEN** .bak备份可用
- **GIVEN** 存档版本低于当前版本，**WHEN** 加载，**THEN** 自动执行数据迁移
- **GIVEN** 3个槽位已满，**WHEN** 手动保存，**THEN** 提示选择覆盖
- **GIVEN** Boss战后，**WHEN** Boss HP=0，**THEN** 自动存档触发

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 是否需要云存档支持（Steam Cloud）？ | technical-director | 发布前评估 |
| 2 | 是否需要存档加密（防止修改）？ | technical-director | 发布前评估 |
| 3 | 跨平台存档迁移方案？ | technical-director | 多平台发布阶段 |
