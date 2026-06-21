# AI框架 (AI Framework)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 猫科战斗美学, 技巧优先成长
> **Systems Index**: #7 | MVP核心 | Core

## Overview

**AI框架**是《废土喵影》的敌人行为引擎，负责管理所有非玩家实体的决策逻辑、行为模式和攻击序列。它为每种敌人定义"它会做什么"——巡逻、追击、攻击、逃跑——并通过状态机协调这些行为。

**玩家直接感受它**：敌人的行为模式决定了战斗的节奏和挑战。当机械鼠兵的三连击有清晰的攻击前摇，当Boss的阶段转换改变战斗规则，当精英敌人学会包抄——这些都是AI框架在塑造玩家的战斗体验。

**技术职责**：
- 行为状态机：管理敌人的IDLE/PATROL/CHASE/ATTACK/FLEE/STUN状态
- 攻击模式定义：每种敌人的攻击序列（前摇帧数、攻击范围、伤害类型）
- 感知系统：检测玩家位置、距离、视线
- 与碰撞系统协调：调用`activate_hitbox()`执行攻击
- 与伤害计算协调：传递攻击参数
- 与生命系统协调：监听`on_boss_phase_change`信号切换Boss行为

## Player Fantasy

**「读懂猎物」— 模式识别的猎手快感**

AI框架的终极使命是让每个敌人都成为**可学习的谜题**。不是随机的混乱，而是有规律的模式——玩家通过观察、尝试、死亡、再尝试，逐渐"读懂"敌人的行为，然后在精确的时机执行弹反和暴击。

**锚定时刻**：第一次面对机械鼠队长，被它的"冲刺→上挑→下砸"三连击打败。第二次，玩家读懂了冲刺的前摇（身体后仰2帧），成功闪避。第三次，玩家在上挑的破绽窗口（第3-5帧）精准弹反——全额反弹伤害。那一刻的感受是"我看穿了你"。

**核心承诺**：
- **模式可学习**：每个敌人的攻击模式是固定的、可预测的
- **前摇可读**：每次攻击都有清晰的视觉预告（动画帧、颜色闪烁）
- **公平一致**：相同条件下，敌人总是做相同的事

## Detailed Design

### Core Rules

#### 规则1：行为状态机

每个AI实体拥有一个状态机，包含以下状态：

| 状态 | 行为 | 转换条件 |
|------|------|---------|
| IDLE | 原地待机，播放idle动画 | 感知到玩家→CHASE；计时器→PATROL |
| PATROL | 沿巡逻路径移动 | 感知到玩家→CHASE；到达终点→IDLE |
| CHASE | 追击玩家 | 进入攻击范围→ATTACK；丢失目标→PATROL |
| ATTACK | 执行攻击模式 | 攻击完成→IDLE/CHASE；被弹反→STUN |
| FLEE | 远离玩家逃跑 | HP>阈值→CHASE；到达安全距离→IDLE |
| STUN | 眩晕不可操作 | 眩晕时间结束→IDLE |

#### 规则2：感知系统

```
detect_player(entity) → {
    can_see: bool,          # 视线检测（射线投射）
    distance: float,        # 到玩家的距离
    direction: Vector2,     # 到玩家的方向
    in_attack_range: bool   # 是否在攻击范围内
}
```

- **视线检测**：从敌人眼睛位置向玩家位置发射射线，检测是否有障碍物
- **感知范围**：每种敌人可配置感知半径（默认200px）和感知角度（默认120°）
- **追击丢失**：玩家离开感知范围3秒后，CHASE→PATROL

#### 规则3：攻击模式定义

每种敌人类型拥有一个攻击模式列表（从数据基础设施加载）：
```
attack_pattern = {
    pattern_id: String,
    startup_frames: int,     # 前摇帧数（视觉预告时间）
    active_frames: int,      # Hitbox活跃帧数
    recovery_frames: int,    # 后摇帧数
    damage_type: String,     # "physical" | "electric" | "fire" | "toxic"
    hitbox_config: { offset: Vector2, size: Vector2 },
    vulnerability_window: {  # 暴击破绽窗口（供伤害计算F5使用）
        start_frame: int,
        size_frames: int     # 窗口宽度（4-10帧）
    }
}
```

**攻击执行流程**：
1. ATTACK状态开始 → 选择攻击模式
2. 播放前摇动画（startup_frames帧）→ 视觉预告
3. 前摇结束 → 调用`activate_hitbox()`激活Hitbox
4. Hitbox活跃active_frames帧 → 碰撞系统检测命中
5. Hitbox停用 → 播放后摇动画（recovery_frames帧）
6. 后摇结束 → 回到IDLE或CHASE

#### 规则4：Boss阶段转换

Boss实体监听生命系统的`on_boss_phase_change(boss_id, new_phase)`信号：
- 阶段1：基础攻击模式
- 阶段2：增强攻击模式（新增攻击、更快节奏）
- 阶段3：狂暴模式（所有攻击加速、新增特殊招式）

#### 规则5：低HP行为适应

当AI实体HP低于阈值时：
- FLEE阈值：HP<20%时可能触发逃跑（小怪）
- 狂暴阈值：HP<30%时攻击速度+20%（精英/Boss）

### States and Transitions

见规则1行为状态机表。

### Interactions with Other Systems

#### 上游依赖（输入）
- **伤害计算系统**：敌人攻击时调用`calculate_damage()`
- **生命与死亡检测系统**：监听`on_boss_phase_change`、`on_hp_milestone`、`on_death`、`on_focus_mode_changed`
- **碰撞与判定系统**：调用`activate_hitbox()`执行攻击
- **数据基础设施**：加载敌人攻击模式配置

#### 专注模式接口（health-death 规则8配套）
当生命系统检测到玩家进入/退出低HP专注模式时，发射 `on_focus_mode_changed(active: bool)` 信号。AI框架监听此信号，对后续攻击应用前摇帧数修正：
- active=true → 每个攻击模式的 startup_frames 追加 `windup_extension_frames`（默认6帧，即30帧基准的20%延长）
- active=false → 恢复正常 startup_frames
- **已在执行中的攻击不受影响**——仅新发起的攻击使用修正后的前摇
- 不改变 active_frames、recovery_frames、动画播放速度

attack_pattern 新增字段：
```
windup_extension_frames: int = 6  # 专注模式激活时追加到 startup_frames 的帧数
```

#### 下游被依赖（输出）
- **Boss配置层**：使用AI框架定义Boss特殊行为
- **猫科战斗系统**：监听`on_hit_confirmed`用于受击处理
- **生命与死亡检测系统**：调用`get_active_enemy_count()`查询战斗状态（供专注模式使用）

#### 接口签名
```
# 攻击执行
activate_hitbox(entity_id, hitbox_id, duration_frames, offset, size) → void

# 战斗状态查询（供 health-death 专注模式使用）
get_active_enemy_count() → int  # 返回当前处于 CHASE 或 ATTACK 状态的敌人数量

# 事件监听
on_boss_phase_change(boss_id, new_phase) → void
on_hp_milestone(entity_id, percentage) → void
on_death(entity_id, metadata) → void
on_focus_mode_changed(active: bool) → void

# 专注模式
# windup_extension_frames 通过 attack_pattern 字段配置，无需独立接口方法
```

## Formulas

### F1: 感知角度检测
`in_perception_cone = angle_between(entity_facing, direction_to_player) <= perception_angle / 2`

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| perception_angle | float | 60-180° | 感知锥角度 |
| **输出** | bool | true/false | 玩家是否在感知锥内 |

### F2: 攻击选择权重
`attack_weight = base_weight × phase_modifier × hp_modifier`

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| base_weight | float | 0.1-10.0 | 攻击模式基础权重 |
| phase_modifier | float | 0.5-2.0 | Boss阶段修正 |
| hp_modifier | float | 0.5-2.0 | 低HP修正 |
| **输出** | float | 0.05-40.0 | 加权权重 |

## Edge Cases

- **攻击前摇中被弹反**：立即进入STUN状态（1秒），取消当前攻击
- **多个敌人同时攻击同一玩家**：各自独立执行，不做协调
- **Boss阶段转换时正在攻击**：当前攻击完成后切换模式（不中断）
- **玩家在攻击范围内但被障碍物遮挡**：视线检测失败，不触发ATTACK
- **敌人死亡时正在执行攻击**：立即停用Hitbox，进入DEAD状态
- **追击时玩家穿过墙壁**：射线投射检测障碍物，无法穿墙追击

## Dependencies

**上游依赖**：
- 伤害计算系统 — 敌人攻击时调用`calculate_damage()`
- 生命与死亡检测系统 — 监听`on_boss_phase_change`、`on_hp_milestone`、`on_death`
- 碰撞与判定系统 — 调用`activate_hitbox()`执行攻击
- 数据基础设施 — 加载敌人攻击模式配置

**下游被依赖**：
- Boss配置层 — 使用AI框架定义Boss特殊行为
- 猫科战斗系统 — 监听`on_hit_confirmed`用于受击处理

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| perception_radius | 200px | 100-500px | 敌人太远就追击 | 敌人太近才发现 |
| perception_angle | 120° | 60-180° | 背后也能发现 | 正面也发现不了 |
| chase_lost_delay_sec | 3.0 | 1.0-5.0 | 追击太久 | 追击太短 |
| attack_startup_min_frames | 12 | 6-30 | 攻击太快无反应时间 | 攻击太慢无聊 |
| stun_duration_sec | 1.0 | 0.5-2.0 | 眩晕太久 | 眩晕太短 |
| flee_hp_threshold | 0.2 | 0.1-0.4 | 太早逃跑 | 太晚逃跑 |
| berserk_hp_threshold | 0.3 | 0.1-0.5 | 太早狂暴 | 太晚狂暴 |
| berserk_speed_multiplier | 1.2 | 1.1-1.5 | 狂暴太快 | 狂暴无感 |

## Acceptance Criteria

- **GIVEN** 敌人IDLE状态，**WHEN** 玩家进入感知范围且视线无遮挡，**THEN** 转换到CHASE状态
- **GIVEN** 敌人CHASE状态，**WHEN** 进入攻击范围，**THEN** 转换到ATTACK状态
- **GIVEN** 敌人ATTACK状态执行攻击模式，**WHEN** 前摇结束，**THEN** 调用`activate_hitbox()`
- **GIVEN** 敌人攻击前摇中，**WHEN** 被玩家弹反，**THEN** 进入STUN状态1秒
- **GIVEN** Boss HP降到66%阈值，**WHEN** `on_boss_phase_change`信号触发，**THEN** 切换到阶段2攻击模式
- **GIVEN** 小怪HP<20%，**WHEN** flee行为配置启用，**THEN** 转换到FLEE状态
- **GIVEN** 敌人追击玩家，**WHEN** 玩家离开感知范围3秒，**THEN** 转换到PATROL状态

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 精英敌人是否需要协调攻击（如包夹、轮流攻击）？ | game-designer | Boss配置层GDD |
| 2 | 是否需要"仇恨系统"（多敌人时优先攻击谁）？ | game-designer | AI框架实现阶段 |
| 3 | 巡逻路径是手工配置还是自动生成？ | level-designer | 关卡设计阶段 |
