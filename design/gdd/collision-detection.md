# 碰撞与判定系统 (Collision & Detection System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 猫科战斗美学, 技巧优先成长
> **Systems Index**: #6 | MVP核心 | Core

## Overview

**碰撞与判定系统**是《废土喵影》的帧级命中检测引擎，负责管理所有实体的Hitbox（攻击判定框）和Hurtbox（受击判定框），并在每帧检测碰撞重叠。它是战斗手感的物理基础——当玩家按下攻击键，是碰撞系统决定"这一刀砍到了没有"。

**技术职责**：
- Hitbox管理：攻击动作期间激活/停用攻击判定框，支持帧级精度控制
- Hurtbox管理：管理实体的受击判定框，支持缩小（防御）和消失（闪避i-frame）
- 碰撞检测：每帧检测Hitbox-Hurtbox重叠，输出命中事件
- 碰撞分层：友方/敌方/中立碰撞层，防止自伤和友军伤害
- 命中事件输出：发射`on_hit_confirmed(attacker, target, hit_data)`信号

**与猫科战斗系统的关系**：战斗系统管理"做什么动作"，碰撞系统管理"动作是否命中"。战斗系统激活Hitbox，碰撞系统检测命中，伤害计算系统计算伤害。

## Player Fantasy

**「每一刀都有份量」— 精准判定的信任感**

碰撞系统的终极使命是让玩家**完全信任判定**。当玩家看到爪刃划过敌人身体时，伤害数字必须弹出——不多不少，不早不晚。没有"明明砍到了却没伤害"的挫败感，没有"还没碰到就掉血了"的困惑。

**锚定时刻**：玩家在弹反窗口（6帧≈100ms）内按下parry键，碰撞系统精确检测到Hurtbox在i-frame期间与敌人Hitbox重叠——弹反成功。玩家感受到的不是"运气好"，而是"我的时机对了"。

**核心承诺**：
- **所见即所得**：视觉上的命中 = 判定上的命中，零偏差
- **帧级精度**：碰撞检测与动画帧同步，不存在"延迟判定"
- **公平透明**：敌人的Hitbox和玩家的Hitbox遵循相同规则

## Detailed Design

### Core Rules

#### 规则1：Hitbox管理
每个实体拥有可配置的Hitbox列表（攻击判定框）：
- **激活条件**：由战斗系统在攻击动作前摇结束后调用`activate_hitbox(entity, hitbox_id, duration_frames)`
- **帧级控制**：Hitbox在指定帧数内活跃，超时自动停用
- **多Hitbox支持**：一个攻击动作可激活多个Hitbox（如大范围斩击=前+侧两个判定框）
- **Hitbox数据**：位置偏移(relative to entity)、尺寸(width×height)、碰撞层

#### 规则2：Hurtbox管理
每个实体拥有一个Hurtbox（受击判定框）：
- **默认状态**：与实体轮廓匹配（站立/蹲伏/空中各有不同尺寸）
- **缩小状态**：防御时Hurtbox缩小50%（更难被命中）
- **消失状态**：闪避i-frame期间Hurtbox完全消失（无敌）
- **状态切换**：由战斗系统调用`set_hurtbox_state(entity, "normal"|"shrunk"|"gone")`

#### 规则3：碰撞检测
每帧（`_physics_process`）执行：
```
for each active_hitbox in all_active_hitboxes:
    for each hurtbox in all_active_hurtboxes:
        if active_hitbox.owner != hurtbox.owner:  # 防止自伤
            if active_hitbox.collision_layer & hurtbox.collision_mask:  # 层匹配
                if active_hitbox.overlaps(hurtbox):
                    emit on_hit_confirmed(active_hitbox.owner, hurtbox.owner, hit_data)
                    active_hitbox.mark_hit(hurtbox.owner)  # 防止同一次攻击多次命中
```

#### 规则4：碰撞分层
| 碰撞层 | 用途 | 可命中 |
|--------|------|--------|
| player_attack | 玩家攻击 | enemy_hurt |
| enemy_attack | 敌人攻击 | player_hurt |
| player_hurt | 玩家受击 | — |
| enemy_hurt | 敌人受击 | — |
| environment | 环境碰撞 | player_hurt, enemy_hurt |

#### 规则5：命中事件数据
`on_hit_confirmed`信号携带：
```
hit_data = {
    hitbox_id: String,           # 哪个Hitbox命中
    hit_position: Vector2,       # 命中位置（世界坐标）
    hit_frame: int,              # 命中帧号
    attack_metadata: Dictionary  # 从战斗系统传递的攻击参数
}
```

### States and Transitions

碰撞系统本身无状态机——它是被动响应的检测引擎。状态由战斗系统管理：
- 战斗系统调用`activate_hitbox()` → 碰撞系统开始检测该Hitbox
- 战斗系统调用`set_hurtbox_state()` → 碰撞系统更新Hurtbox行为
- 碰撞系统自动停用超时Hitbox

### Interactions with Other Systems

#### 上游依赖（输入）
- **猫科战斗系统**：调用`activate_hitbox()`、`set_hurtbox_state()`、传递attack_metadata
- **输入系统**：通过战斗系统间接影响（闪避i-frame）

#### 下游被依赖（输出）
- **猫科战斗系统**：监听`on_hit_confirmed`信号，调用伤害计算
- **AI框架**：监听`on_hit_confirmed`信号，用于敌人攻击判定
- **战斗表现系统**：监听`on_hit_confirmed`信号，触发帧停/震屏/粒子

#### 接口签名（正式化猫科战斗GDD provisional接口）
```
# Hitbox管理
activate_hitbox(entity_id, hitbox_id: String, duration_frames: int, offset: Vector2, size: Vector2) → void
deactivate_hitbox(entity_id, hitbox_id: String) → void

# Hurtbox管理
set_hurtbox_state(entity_id, state: "normal" | "shrunk" | "gone") → void
set_hurtbox_size(entity_id, size: Vector2) → void  # 姿态变化时调用

# 命中事件
signal on_hit_confirmed(attacker_id, target_id, hit_data: Dictionary)
```

## Formulas

碰撞系统不定义游戏平衡公式。核心计算为几何重叠检测：
`hit_confirmed = hitbox_rect.overlaps(hurtbox_rect)`
（由Godot引擎`Area2D`节点内置实现）

## Edge Cases

- **同一Hitbox同帧重叠多个Hurtbox**：每个Hurtbox独立触发`on_hit_confirmed`（范围攻击）
- **同一Hitbox对同一Hurtbox多次重叠**：`mark_hit()`防止重复命中，同一次攻击只触发一次
- **Hitbox激活帧与Hurtbox消失帧同帧**：Hitbox优先（该帧命中判定有效）
- **实体死亡时Hitbox仍活跃**：死亡时自动停用所有Hitbox
- **两个实体Hitbox互相重叠**：双方各自触发命中（互相伤害，除非同碰撞层）
- **Hitbox尺寸为零或负值**：数据验证层拦截，使用默认最小尺寸(4×4px)

## Dependencies

**上游依赖**：
- 猫科战斗系统 — 激活/停用Hitbox，设置Hurtbox状态
- 输入系统 — 通过战斗系统间接影响（闪避i-frame）

**下游被依赖**：
- 猫科战斗系统 — 监听命中事件，触发伤害计算
- AI框架 — 监听命中事件，用于敌人攻击
- 战斗表现系统 — 监听命中事件，触发视觉反馈

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| default_hitbox_size | 32×32px | 16-64px | 判定过大（空气斩） | 判定过小（砍不到） |
| default_hurtbox_size | 24×48px | 16-64px | 受击面积过大 | 受击面积过小 |
| hurtbox_shrink_ratio | 0.5 | 0.3-0.8 | 防御太强 | 防御太弱 |
| hitbox_max_duration_frames | 30 | 10-60 | 攻击判定持续太久 | 攻击判定太短 |

## Acceptance Criteria

- **GIVEN** 战斗系统调用`activate_hitbox(player, "slash_1", 10, offset, size)`，**WHEN** 10帧内Hitbox与敌人Hurtbox重叠，**THEN** `on_hit_confirmed`信号发射
- **GIVEN** Hitbox激活超过10帧，**WHEN** 第11帧，**THEN** Hitbox自动停用
- **GIVEN** 战斗系统调用`set_hurtbox_state(player, "gone")`，**WHEN** 敌人Hitbox与玩家Hurtbox重叠，**THEN** 不触发命中（i-frame无敌）
- **GIVEN** 同一Hitbox同帧重叠3个敌人Hurtbox，**WHEN** 碰撞检测执行，**THEN** 3次`on_hit_confirmed`信号发射
- **GIVEN** 同一Hitbox对同一敌人连续2帧重叠，**WHEN** 碰撞检测执行，**THEN** 仅第1帧触发命中，第2帧被`mark_hit()`阻止
- **GIVEN** 玩家和敌人同时攻击，**WHEN** 双方Hitbox分别命中对方Hurtbox，**THEN** 两次`on_hit_confirmed`信号发射（互相伤害）
- **GIVEN** 实体死亡，**WHEN** `on_death`信号触发，**THEN** 该实体所有活跃Hitbox自动停用

## Visual/Audio Requirements

**碰撞系统不定义详细战斗反馈**——帧停、震屏、粒子、伤害数字由 `combat-presentation.md` 基于 `on_hit_confirmed` 信号消费。本系统只定义碰撞瞬间的即时反馈。

### 命中即时反馈（由碰撞系统直接触发）

| 事件 | 视觉 | 位置 | 持续 |
|------|------|------|:---:|
| 命中确认 | 3-5个白色小火花粒子 | hit_position | 0.2秒 |
| 命中闪光 | 8×8px白色闪光 | hit_position | 1帧 |

### 调试可视化（开发模式，F4切换）

| 元素 | 颜色 | 说明 |
|------|------|------|
| 活跃Hitbox | 红色半透明矩形 | 攻击判定框 |
| 正常Hurtbox | 绿色半透明矩形 | 受击判定框 |
| 缩小Hurtbox | 蓝色半透明矩形 | 防御状态 |
| 消失Hurtbox | 虚线轮廓 | i-frame无敌 |

### 音效需求

碰撞系统本身不产生音效。命中确认音效由 `combat-presentation.md` 管理（监听 `on_hit_confirmed` 信号）。

## UI Requirements

碰撞系统无玩家可见UI。

### 调试UI（开发模式）

- **F4**：切换Hitbox/Hurtbox可视化叠加层
- **调试面板**：当前活跃Hitbox数量、实体Hurtbox状态、碰撞层信息
- **设置菜单（开发版）**："显示碰撞框"开关

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | Hitbox形状是否支持非矩形（圆形/多边形）？ | gameplay-programmer | 技术验证原型 |
| 2 | 环境碰撞（尖刺、岩浆）是否使用同一碰撞层还是独立系统？ | game-designer | 场景管理系统GDD |
| 3 | 是否需要在编辑器中可视化Hitbox/Hurtbox调试工具？ | tools-programmer | 开发工具阶段 |
