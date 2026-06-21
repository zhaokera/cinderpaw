# NPC对话系统 (NPC Dialogue System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 叙事融入世界
> **Systems Index**: #20 | MVP扩展 | Feature

## Overview

**NPC对话系统**管理游戏中所有非玩家角色的对话交互——对话树、分支选择、对话状态追踪、以及对话触发的事件（如任务激活、商店解锁、叙事揭示）。NPC是废土世界的"声音"——通过他们的对话，玩家了解世界的历史、获得任务线索、感受猫族社区的温暖。好的对话系统让NPC不只是信息站，而是有性格、有记忆、有故事的"人"。

## Player Fantasy

**「废土之声」— 每个NPC都是一段故事**

对话的终极使命是让废土世界**有温度**。猫族据点的长老记得你上次来时的对话；商人会根据你的探索进度推荐不同商品；神秘旅人透露的线索让你对下一个区域充满期待。好的对话让你觉得"这些猫真的生活在这里"，而不是"这个NPC在等我按A键"。

## Detailed Design

### Core Rules

#### 规则1：NPC类型定义

| NPC ID | 名称 | 位置 | 功能 | 对话类型 |
|--------|------|------|------|---------|
| npc_elder | 猫族长老 | 猫族据点 | 主线叙事+任务 | 多分支对话树 |
| npc_merchant | 猫族商人 | 猫族据点 | 商店+推荐 | 动态对话 |
| npc_traveler | 神秘旅人 | 各区域随机 | 线索+信息 | 条件触发 |

#### 规则2：对话树结构
```
dialogue_node = {
    node_id, speaker, text,
    choices: Array[Choice],
    next_node_id, conditions, events
}
```

#### 规则3：对话触发条件
- 接近触发：玩家进入范围→显示提示
- 交互触发：按键→开始对话
- 条件触发：世界状态/任务进度→解锁分支
- 首次触发：首次遇到→介绍对话

#### 规则4：对话状态追踪
- 对话历史：记录已播放节点，不重复
- 对话阶段：初次见面→熟悉→任务→完成

#### 规则5：对话事件触发
- `activate_quest(quest_id)` — 激活任务
- `unlock_shop_item(item_id)` — 解锁商品
- `set_world_flag(flag_id, value)` — 设置世界标记
- `unlock_ability_hint(ability_id)` — 能力提示
- `play_animation(npc_id, animation_id)` — NPC动画

### States and Transitions

**对话系统状态**：IDLE → PROMPT_VISIBLE（进入范围）→ DIALOGUE_ACTIVE（按键）→ CHOICE_PENDING（选择节点）→ DIALOGUE_ACTIVE（选择后）→ DIALOGUE_END（结束）→ IDLE

### Interactions with Other Systems

**上游依赖**：世界状态系统(provisional)、任务系统(undesigned)
**下游被依赖**：任务系统、商店系统(undesigned)、探索与能力门控、世界状态系统、HUD/UI

**接口签名**：
```
start_dialogue(npc_id) → void
end_dialogue() → void
get_current_dialogue_text() → String
get_current_choices() → Array[Choice]
select_choice(choice_index) → void
has_dialogue_flag(npc_id, flag_id) → bool
set_dialogue_flag(npc_id, flag_id, value) → void
```

## Formulas

条件表达式：`condition_met = check_condition(condition_type, condition_params)`

| Variable | Type | Description |
|----------|------|-------------|
| condition_type | String | world_flag/quest_state/dialogue_flag/item_owned |
| condition_params | Dictionary | 条件参数 |
| **输出** | bool | 条件是否满足 |

## Edge Cases

- **对话中玩家移动**：对话暂停或自动结束
- **对话中玩家死亡**：对话自动结束
- **对话中触发战斗**：对话自动结束
- **条件分支都不满足**：显示默认对话
- **节点ID不存在**：跳过+警告
- **选择跳转ID不存在**：结束对话+警告
- **快速连续按键**：忽略重复
- **对话中场景切换**：对话自动结束

## Dependencies

**上游依赖**：世界状态系统(provisional)、任务系统(undesigned)
**下游被依赖**：任务系统、商店系统(undesigned)、探索与能力门控、世界状态系统、HUD/UI

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| dialogue_prompt_distance | 64px | 32-128px | 太早 | 太晚 |
| dialogue_text_speed | 30字/秒 | 15-60字/秒 | 太快 | 太慢 |
| dialogue_auto_advance | false | true/false | — | — |
| dialogue_skip_delay | 0.5秒 | 0.2-1.0秒 | 太慢 | 太快 |
| choice_display_duration | ∞ | 3-∞秒 | — | 太短 |

## Visual/Audio Requirements

### NPC视觉
- 对话提示："..."气泡（NPC头顶）
- 对话头像：48×48px（对话框左侧）
- NPC动画：idle/talk/happy/sad
- 选择高亮：当前项高亮

### 对话UI
- 对话框：屏幕下方80%宽×25%高
- 文本：像素字体，白色，半透明黑底
- 选择菜单：垂直排列，猫爪图标高亮
- 跳过提示：右下角

### 音效
- 提示音：轻柔提示
- 文字音：每字轻微"嘀"音（可关闭）
- 选择音：导航+确认
- 结束音：轻微关闭

## UI Requirements

> 📌 **UX Flag — NPC对话系统**: 运行 `/ux-design` 创建 `design/ux/dialogue-ui.md`。

### 对话框UI
- 位置：屏幕下方中央
- NPC头像：左侧48×48px
- 对话文本：逐字显示（可跳过）
- 选择菜单：最多4个选项

### 对话提示UI
- NPC头顶"..."气泡
- 交互键提示"[E]对话"

## Acceptance Criteria

- **GIVEN** 玩家进入NPC范围，**WHEN** 进入64px，**THEN** 显示"..."气泡
- **GIVEN** 提示可见，**WHEN** 按交互键，**THEN** 开始对话
- **GIVEN** 对话中，**WHEN** 到达选择节点，**THEN** 显示选择菜单
- **GIVEN** 选择菜单，**WHEN** 选择选项1，**THEN** 跳转+触发事件
- **GIVEN** 初次遇到，**WHEN** 开始对话，**THEN** 播放介绍对话
- **GIVEN** 已播放节点A，**WHEN** 再次对话，**THEN** 不重复A
- **GIVEN** 对话中死亡，**WHEN** 死亡触发，**THEN** 对话自动结束
- **GIVEN** 触发activate_quest，**WHEN** 执行，**THEN** 任务激活

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 是否需要对话日志？ | ux-designer | UX设计阶段 |
| 2 | 是否需要NPC表情系统？ | art-director | 美术设计阶段 |
| 3 | 对话文本是否需要本地化？ | narrative-director | 本地化阶段 |
| 4 | 神秘旅人随机出现机制？ | game-designer | 垂直切片阶段 |
