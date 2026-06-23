# 生命与死亡检测系统 (Health & Death Detection System)

> **Status**: In Review (Rev.3 — 专注模式激活信号, 伪代码防护补全, 音效规格化, AC补至31条)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-21
> **Implements Pillar**: 猫科战斗美学, 技巧优先成长
> **Supports Pillar**: 机制探索回报, 叙事融入世界（通过接口钩子）
> **Systems Index**: #4 | MVP核心 | Core
> **Creative Director Review (CD-GDD-ALIGN)**: CONCERNS (accepted — low-HP focus mode added, visual requirements redesigned, death metadata expanded, pillar 4/5 hooks added) [2026-06-18]
> **Retrofit (2026-06-20)**: 8项修复 — Rule 6缺失(+healing+i-frames)、低HP脉动矛盾、心跳音矛盾、AI耦合接口、on_hp_milestone阈值、公式HD-前缀+F2/F3变量表、Edge Cases补充
> **Design Review #1 (2026-06-20)**: NEEDS REVISION → Rev.1 — windup_modifier 0.9→0.8, 受伤音效低频混响, AC 14→23条(+9), 信号顺序修复(on_death最后)
> **Design Review #2 (2026-06-21)**: MAJOR REVISION NEEDED → Rev.2 — 全局speed_scale→逐招式前摇帧数修正, 阈值迟滞(25%/28%), 感知变化9→4项, 护盾标记休眠, 公式内联保护, Boss阶段while循环, i-frame 7→8帧, revive()重置focus_mode, AC合并+新增至28条
> **Design Review #3 (2026-06-21)**: NEEDS REVISION → Rev.3 — 专注模式激活信号(猫眼金闪光+提示音), 伪代码4项防护(state guard/零伤害/max保护/entity统一), 低频混响绑定focus_mode(含迟滞), 受伤音高公式化(HD-F4), AC补至31条(+3)

## Overview

**生命与死亡检测系统**是《废土喵影》的核心状态管理器，负责维护所有实体的生命值（HP）并检测死亡条件。它接收伤害计算系统的输出（`final_damage` + metadata），更新HP值，并在HP≤0时触发死亡事件。

**玩家直接感受它**：对于ACT游戏，生命值是玩家与游戏世界博弈的核心筹码。当HP条从绿色变黄再变红时的紧张感、当Boss血量进入最后阶段时的兴奋感、当自己被一击秒杀时的挫败感——这些都源于生命系统的设计。HP不是数字，是生存焦虑的具象化。

**技术职责**：
- HP状态管理：当前HP、最大HP、护盾值（如果有）
- 伤害应用：接收`final_damage`，扣减HP，处理护盾优先级
- 死亡检测：HP≤0时触发`on_death`信号，传递死亡元数据
- Boss阶段转换：当Boss HP降到阈值时触发阶段变更信号
- 生命值查询接口：为AI、UI、状态效果等系统提供HP百分比查询

**与死亡重生系统的边界**：
- 本系统负责：HP管理 + 死亡检测 + 信号发射
- 死亡重生系统（#12）负责：死亡后的复活流程、重生点选择、惩罚机制

**为什么存在**：没有它，伤害只是数字——没有"我还活着"的确认感、没有"快死了"的紧张感、没有"死了"的终结感。生命系统是"伤害数字"变成"生存体验"的桥梁。

## Player Fantasy

**「猫科镇定」+「猎手学费」— 活着专注如刃，倒下学到了东西**

生命与死亡检测系统的终极使命是让每一次HP变化都传递**猫科猎手的生存智慧**。当HP条从猫眼金渐变为信号红，玩家的心跳加速，但手指反而更稳——因为猫在绝境中从不慌乱。

**锚定时刻（镇定层）**：Boss第三阶段，HP被压到1。画面边缘微微收束，敌人攻击的前摇变得比满血时更可读取——这不是恐慌，是**猫科猎手的专注模式被激活**。猫在黑暗中瞳孔放大，猎手在绝境中看得更清。每一次闪避都带着"我还在这里"的冷静决断。当最终一击命中Boss、HP从1反弹到安全值时，玩家感受到的不是侥幸，而是**"我还能赢"的反抗意志**。

**锚定时刻（学费层）**：第一次挑战精英敌人，被打掉70%HP后倒下。但玩家已经知道了——第一招需要侧闪，第二招可以弹反，第三招有2秒硬直。重新站起来时，心中想的不是"又来了"，而是"这次我知道怎么躲了"。死亡从来不是惩罚，而是"你已经交了学费，下次该用上了"的邀请。

- **核心承诺**：
- **低血更专注**：HP越低，视觉反馈越清晰（而非越混乱），猎手在绝境中**看得更清**——感知优势转化为操作优势
- **死亡有收获**：每次死亡都让玩家对敌人模式的理解更深，快速重试让学到的教训立刻变成武器
- **1HP不是终点**：只要还活着，就有反杀的机会——HP条永远在说"你还可以"

**猎手的生存智慧，从HP开始。** 当低血让专注取代恐慌，当死亡让理解取代挫败，当1HP让反抗取代绝望——生命系统就在背后支撑着猫科战斗的全部生存体验。

## Detailed Design

### Core Rules

#### 规则1：HP状态管理
每个实体（玩家、敌人、Boss）拥有：
- `current_hp`：当前生命值（int, 0-max_hp）
- `max_hp`：最大生命值（int, 由数据基础设施提供）
- `shield`：护盾值（int, 0-max_shield，可选）`# 休眠特性 — 护盾来源由状态效果系统定义。max_shield 默认为 0，护盾机制不激活直到上游系统提供护盾来源`

#### 规则2：伤害应用
```
apply_damage(entity_id, final_damage, metadata):
    entity = get_entity(entity_id)
    if entity.state != EntityState.ALIVE:
        return  # DYING/DEAD状态不接收伤害（AC-4, AC-18）
    if entity.is_invincible:
        return  # i-frame期间免疫伤害
    if final_damage <= 0:
        return  # 零/负伤害不处理，不触发on_hp_changed（AC-27）
    
    if entity.shield > 0:
        shield_damage = min(entity.shield, final_damage)
        entity.shield -= shield_damage
        remaining_damage = final_damage - shield_damage
    else:
        remaining_damage = final_damage
    
    entity.current_hp = max(0, entity.current_hp - remaining_damage)
    
    # 先发射HP变更（信号顺序：状态变更 → 死亡检测）
    emit on_hp_changed(entity_id, entity.current_hp, entity.max_hp)
    
    # 检查里程碑阈值
    hp_pct = get_hp_percentage(entity_id)
    for threshold in [0.75, 0.50, 0.25, 0.01]:
        if hp_pct <= threshold and threshold not in entity.triggered_milestones:
            emit on_hp_milestone(entity_id, threshold)
            entity.triggered_milestones.add(threshold)
    
    # 检查专注模式（含迟滞缓冲：进入 ≤25%，退出 >28%）
    if entity.is_player and active_enemies_count > 0:
        if not entity.focus_mode_active and hp_pct <= low_hp_warning_threshold:
            entity.focus_mode_active = true
            emit on_focus_mode_changed(true)
        elif entity.focus_mode_active and hp_pct > low_hp_warning_threshold + focus_hysteresis:
            entity.focus_mode_active = false
            emit on_focus_mode_changed(false)
    elif entity.is_player and entity.focus_mode_active and active_enemies_count == 0:
        entity.focus_mode_active = false
        emit on_focus_mode_changed(false)  # 脱战后退出专注模式
    
    # 死亡检测放在最后（终结事件）
    if entity.current_hp == 0:
        entity.state = EntityState.DYING
        emit on_death(entity_id, metadata)
```

#### 规则3：死亡检测
- HP ≤ 0 时触发`on_death(entity, metadata)`信号
- 信号携带元数据：最后一击的伤害类型、来源、是否暴击
- 死亡后实体进入DEAD状态，不再接收伤害

#### 规则4：Boss阶段转换
Boss拥有多个HP阈值（如66%、33%），当HP降到阈值时触发阶段变更：
```
if boss.phase_thresholds.is_empty() or boss.next_phase >= boss.phase_thresholds.size():
    return  # 无更多阶段

phase_percentage = get_hp_percentage(boss_id)
while boss.next_phase < boss.phase_thresholds.size() and phase_percentage <= boss.phase_thresholds[boss.next_phase]:
    emit on_boss_phase_change(boss, boss.next_phase)
    boss.next_phase++
```

**注意**：使用 `while` 循环确保跨跳场景（如从70%直接到20%）触发所有经过的阈值。Boss阶段转换信号在 `on_hp_milestone` 之后、`on_focus_mode_changed` 之前发射（在 apply_damage 信号序列中）。

#### 规则5：HP查询接口
```
get_hp_percentage(entity) → float  # 0.0-1.0，用于AI决策、UI显示
is_alive(entity) → bool
is_dead(entity) → bool
get_shield_percentage(entity) → float  # 0.0-1.0
```

#### 规则6：HP恢复
- **存档点回复**：到达存档点 → current_hp = max_hp, shield = max_shield（如有）
- **道具回复**：使用回复道具 → current_hp = min(max_hp, current_hp + heal_amount)
- **被动回复**：无 — 非战斗状态不自动回血（维持低血量紧张感）。设计意图：低HP时的"被困"感受由关卡设计缓解（存档点导航提示），而非被动回血。被动回复会摧毁"1HP反杀"的设计张力
- **复活回复**：revive() → current_hp = max(1, floor(max_hp × revive_hp_percentage))
  ```
  revive(entity_id):
      entity = get_entity(entity_id)
      entity.current_hp = max(1, floor(entity.max_hp * revive_hp_percentage))  # 内部计算HP，调用者无需关心
      entity.triggered_milestones.clear()   # AC-20
      entity.focus_mode_active = false       # 重置专注模式
      emit on_focus_mode_changed(false)      # 通知AI框架恢复正常速度
      entity.state = EntityState.ALIVE
  ```

#### 规则7：无敌帧（i-frames）
实体在特定动作期间拥有无敌帧，不接收伤害：
- 闪避翻滚：总时长约12帧，其中i-frame活跃窗口为帧3-10（8帧无敌，详见 feline-combat.md）
- PERFECT弹反后：约8帧（133ms @60fps）
- 复活后：120帧（2秒，由死亡重生系统管理）
- 无敌状态效果（invincible）：由状态效果系统管理

apply_damage 需检查 is_invincible 标志：
```
if entity.is_invincible:
    return  # 跳过伤害，不触发 on_hp_changed（HP未变）
```

来源系统提供 i-frame 时长：
- 闪避 → 猫科战斗系统设置 i_frame_remaining
- 弹反 → 猫科战斗系统设置 i_frame_remaining
- 复活 → 死亡重生系统设置 i_frame_remaining
- 无敌状态效果 → 状态效果系统设置 i_frame_remaining

**闪避冷却约束**：连续闪避受 `dodge_cooldown_sec`（feline-combat.md 定义，默认0.5秒）约束。i-frame覆盖率上限约19%（8帧无敌 / (12帧总时长 + 30帧冷却)），防止"翻滚滥用"退化策略。

#### 规则8：低HP专注模式（猫科镇定）
当玩家HP ≤ 25% **且处于战斗状态**（附近存在敌对实体，`active_enemies_count > 0`）时，激活"专注模式"。退出阈值为 HP > 28%（3% 迟滞缓冲带，防止阈值附近震荡）。

**4项核心感知/机制变化**：
0. **激活信号（一次性过渡）**：专注模式激活瞬间，播放0.3秒猫眼金色（`#ECC94B`）画面边缘闪光 + 低频猫科提示音（低沉"咕噜"声，0.5秒）。此信号仅在**激活时**播放一次，退出时不播放。设计意图：为玩家提供明确的"模式已切换"锚点，使后续4项感知变化可被归因和感知
1. **敌人攻击前摇延长**：每个攻击模式的 startup_frames 追加 `windup_extension_frames`（默认+6帧，即30帧基准的20%延长），仅影响**新发起的攻击**，已在执行中的攻击不受影响。不改变 active_frames 和 recovery_frames
2. **攻击预兆特效增强**：敌人攻击蓄力时的信号红闪烁面积增大25%，持续时间延长10%
3. **环境干扰减少**：背景粒子效果透明度降至30%，画面边缘轻微暗角（非收束）
4. **受伤音效变化**：低HP时受伤音效增加低频混响（"沉闷感"）

**已移除的变化**（Rev.2）：~~敌人轮廓1px白色描边~~（与信号红闪烁冲突）、~~音频聚焦（环境音-50%）~~（ACT战斗中感知不到，代码复杂度不值得）

**设计意图**：低血量时给予玩家**感知优势**（"猫在黑暗中瞳孔放大，猎手在绝境中看得更清"）。前摇延长本身已是操作窗口优势——闪避和弹反的绝对时间增加。反杀工具由猫科战斗系统通过 `on_focus_mode_changed` 信号提供（专注模式下PERFECT暴击窗口+1帧），技能树预留接口。

**专注模式仅在战斗状态激活**：脱战后即使 HP ≤ 25% 也不激活，防止"在安全区保持低血白嫖专注"的退化策略。

#### 规则9：死亡元数据扩展（猎手学费）
`on_death`信号携带扩展元数据，供死亡重生系统用于"学费"反馈：
```
death_metadata = {
    last_hit: { damage, type, source, is_crit },
    battle_stats: {
        duration_sec: float,           # 战斗持续时间
        damage_received: int,          # 总受伤量
        damage_dealt: int,             # 总输出量
        dodge_success_rate: float,     # 闪避成功率
        parry_success_rate: float,     # 弹反成功率
        hits_received_by_pattern: Dictionary  # 按敌人攻击模式分类的受击次数
    },
    context: {
        zone_id: String,              # 死亡区域
        enemy_type: String,           # 击杀者类型
        boss_phase: int               # Boss阶段（如果是Boss战）
    }
}
```

**设计意图**：下游系统可利用这些数据向玩家展示"你学到了什么"——如"本次战斗中你被'三连击'命中5次，下次注意第二击的闪避窗口"。

#### 规则10：探索与叙事接口钩子
为支柱4（机制探索回报）和支柱5（叙事融入世界）预留接口：
- `on_hp_milestone(entity, percentage)` — HP首次（本场景生命周期内）降到以下阈值时触发：
    - 75%（轻伤）
    - 50%（中伤）
    - 25%（重伤 — 与专注模式阈值一致）
    - 1%（濒死）
    每次触发仅一次/阈值/生命周期。复活后重置所有阈值。供探索奖励系统监听（如"首次低血量存活"成就）
- `on_death_in_zone(entity, zone_id)` — 在特定区域死亡时触发，供叙事系统监听（如"在下水道死亡"触发特殊叙事事件）

### States and Transitions

**实体HP状态机（3状态）**：

| 状态 | 触发 | 行为 |
|------|------|------|
| ALIVE | 初始化 | 正常接收伤害，HP可变 |
| DYING | HP=0 | 播放死亡动画，不接收伤害 |
| DEAD | 动画完成 | 从场景移除或保留尸体 |

**状态转换**：
- ALIVE → DYING：`on_death`信号触发
- DYING → DEAD：死亡动画完成
- DEAD → ALIVE：复活系统调用`revive(entity, hp)`（由死亡重生系统#12管理）

### Interactions with Other Systems

#### 上游依赖（输入）
- **伤害计算系统**：接收`final_damage` + metadata，调用`apply_damage()`
- **猫科战斗系统**：提供i_frame_remaining（闪避/弹反无敌帧时长）
- **死亡重生系统**：提供i_frame_remaining（复活无敌帧时长）
- **状态效果系统**：提供invincible状态效果（无敌期间is_invincible=true）

#### 下游被依赖（输出）
- **死亡与重生系统**：监听`on_death`信号，处理复活流程
- **AI框架**：查询`get_hp_percentage()`用于行为决策（低血量逃跑/狂暴）+ 监听`on_focus_mode_changed`调整攻击前摇
- **Boss配置层**：监听`on_boss_phase_change`信号，切换攻击模式
- **HUD/UI系统**：监听`on_hp_changed`信号，更新血条显示
- **状态效果系统**：查询HP百分比触发条件效果（如"低血量时攻击力+20%"）
- **输入系统**：`on_death`时清空输入缓冲
- **探索与能力门控**：监听`on_hp_milestone`信号

#### 接口签名
```
apply_damage(entity_id: int, final_damage: int, metadata: Dictionary) → void
get_hp_percentage(entity_id: int) → float  # 内部使用 max(1, max_hp) 保护
is_alive(entity_id: int) → bool
revive(entity_id: int) → void  # 由死亡重生系统调用，内部计算HP=max(1, floor(max_hp×revive_hp_percentage))
grant_iframes(entity_id: int, frames: int) → void  # i-frame管理：entity.i_frame_remaining = max(current, frames)

#### 专注模式接口（规则8配套）
- 当玩家进入/退出专注模式时，发射 `on_focus_mode_changed(active: bool)` 信号
- AI框架监听此信号，对后续攻击应用前摇帧数修正：
  - active=true → 每个攻击模式的 startup_frames 追加 `windup_extension_frames`
  - active=false → 恢复正常 startup_frames
- **已在执行中的攻击不受影响**——仅新发起的攻击使用修正后的前摇
- 不改变 active_frames、recovery_frames、动画播放速度

AI框架 attack_pattern 新增字段：
```
windup_extension_frames: int  # 专注模式激活时追加到 startup_frames 的帧数（默认6）
```
```

## Formulas

### HD-F0: max_hp_aggregation（最大HP汇总）

本系统是 max_hp 的**最终计算者和权威所有者**。

`max_hp = base_hp + skill_hp_flat + charm_hp_flat`

| 变量 | 类型 | 来源 | 范围 | 说明 |
|------|------|------|------|------|
| base_hp | int | 数据基础设施 (enemy_stats / player_stats) | 50-500 | 基础最大HP（player默认100） |
| skill_hp_flat | int | 技能树 F4 被动节点 | 0-25 | 技能树HP加成累计（受 F7 cap +25 约束） |
| charm_hp_flat | int | 护符系统 charm_life | 0-20 | 生命护符提供的HP加成 |
| **输出 max_hp** | int | 本系统 | 50-545 | 进入 HD-F1/HD-F2/HD-F3 的最终最大HP |

**执行时机**：`max_hp` 在以下事件后重新计算：技能解锁、护符装备变更、存档加载。

### HD-F1: hp_percentage（HP百分比）
`hp_percentage = current_hp / max(1, max_hp)`

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| current_hp | int | 0-max_hp | 当前HP |
| max_hp | int | 1-9999 | 最大HP（`max(1, ...)` 内联保护，防止除零） |
| **输出** | float | 0.0-1.0 | HP百分比 |

### HD-F2: effective_damage（有效伤害，含护盾）
```
shield_absorbed = min(max(0, shield), incoming_damage)
effective_damage = max(0, incoming_damage - shield_absorbed)
new_hp = max(0, current_hp - effective_damage)
```

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| incoming_damage | int | 1-999 | DC-F4输出的final_damage |
| shield | int | 0-max_shield | 当前护盾值 |
| current_hp | int | 0-max_hp | 当前HP |
| **输出 effective_damage** | int | 0-999 | 穿透护盾后实际扣除HP的伤害 |
| **输出 new_hp** | int | 0-max_hp | 扣除后的新HP值 |

**Example**: shield=20, incoming=50, current_hp=80 → shield_absorbed=20, effective=30, new_hp=50

### HD-F3: boss_phase_check（Boss阶段检测）
```
if phase_thresholds.is_empty() or next_phase >= phase_thresholds.size():
    return false  # 无更多阶段，安全返回

phase_percentage = current_hp / max(1, max_hp)
while next_phase < phase_thresholds.size() and phase_percentage <= phase_thresholds[next_phase]:
    trigger_phase_change(next_phase)
    next_phase++
```

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| current_hp | int | 0-max_hp | Boss当前HP |
| max_hp | int | 1-9999 | Boss最大HP |
| next_threshold | float | 0.0-1.0 | 下一阶段触发阈值 |
| **输出** | bool | true/false | 是否触发阶段转换 |

**Example**: max_hp=300, current_hp=190, next_threshold=0.66 → 190/300=0.633 ≤ 0.66 → trigger ✅

### HD-F4: injury_pitch_offset（受伤音效音调偏移）
`injury_pitch_offset = (1.0 - hp_percentage) × injury_pitch_max_semitones`

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| hp_percentage | float | 0.0-1.0 | HD-F1输出 |
| injury_pitch_max_semitones | int | 5-15 | 0%HP时的最大音调偏移（默认10半音） |
| **输出** | float | 0.0-10.0 | 音调偏移量（半音），传递给audio-system的pitch参数 |

**Example**: hp_percentage=0.25, max_semitones=10 → (1.0-0.25)×10 = 7.5半音
**Example**: hp_percentage=1.0（满血）→ 0半音（基准音调）

**实现说明**：音调偏移应用于受伤音效的 pitch_db 参数。audio-system 需支持 `play_sfx(sfx_id, position, volume_db, pitch_offset)` 接口。Playtest 参数 — 如果音调变化在战斗中不可感知，可提升至15半音或移除此特性。

## Edge Cases

- **HP已为0时再次受到伤害**：忽略，不触发重复死亡
- **护盾+HP同时被清零**：护盾先扣减，剩余扣HP，HP=0触发死亡
- **max_hp为0**：数据验证层拦截，使用默认值100
- **Boss阶段阈值被跳过**（如从70%直接到20%）：触发所有经过的阈值阶段
- **复活后HP仍为0**：`revive()`强制设置HP=max(1, revive_hp)
- **多个伤害同帧到达**：按接收顺序依次处理；i-frame期间全部跳过；HP=0后停止处理
- **i-frame期间受击**：忽略伤害，不触发on_hp_changed，不更新伤害统计
- **治疗溢出max_hp**：clamp到max_hp，不溢出
- **不同来源i-frame重叠**：取最长剩余时间，不叠加
- **DoT在i-frame期间tick**：DoT伤害被i-frame免疫（与直接伤害一致）

## Dependencies

**上游依赖**：
- 伤害计算系统 — 提供`final_damage` + metadata
- 数据基础设施 — 提供max_hp、phase_thresholds配置
- 猫科战斗系统 — 提供i_frame_remaining（闪避/弹反无敌帧）+ `get_battle_stats() → Dictionary`（闪避/弹反成功率、受击模式统计，供death_metadata.battle_stats使用）
- 死亡重生系统 — 提供i_frame_remaining（复活无敌帧）
- 状态效果系统 — 提供invincible状态（无敌状态效果）
- AI框架 — 提供 `get_active_enemy_count()` 查询（处于 CHASE/ATTACK 状态的敌人数量），供专注模式战斗状态判断使用（规则2/8）
**下游被依赖**：
- 死亡与重生系统 — 监听`on_death`，管理复活
- AI框架 — 查询HP百分比做行为决策 + 监听`on_focus_mode_changed`调整攻击前摇
- Boss配置层 — 监听`on_boss_phase_change`
- HUD/UI系统 — 监听`on_hp_changed`更新显示
- 状态效果系统 — 查询HP触发条件效果
- 输入系统 — `on_death`时清空缓冲
- 探索与能力门控 — 监听`on_hp_milestone`（"首次低血量存活"成就等）
- 音效系统 — 监听`on_focus_mode_changed`切换低HP音效
- 护符/装备系统 — 查询HP百分比触发护符效果
- 战斗表现系统 — 监听`on_hp_milestone`触发低HP视觉特效

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| player_max_hp | 100 | 50-500 | 玩家太肉 | 一击必杀 |
| enemy_hp_multiplier | 1.0 | 0.5-3.0 | 敌人太肉 | 敌人太脆 |
| boss_phase_1_threshold | 0.66 | 0.5-0.8 | 阶段转换太早 | 阶段转换太晚 |
| boss_phase_2_threshold | 0.33 | 0.2-0.5 | — | — |
| low_hp_warning_threshold | 0.25 | 0.1-0.4 | 警告太早 | 警告太晚 |
| revive_hp_percentage | 0.5 | 0.1-1.0 | 复活太安全 | 复活即死 |
| dodge_total_frames | 12 | 6-20 | 闪避太长 | 闪避太短（i-frame窗口由feline-combat定义） |
| parry_iframe_frames | 8 | 4-15 | 弹反过强 | 弹反后仍受伤 |
| windup_extension_frames | 6 | 3-12 | 敌人太慢 | 专注无感知（3帧≈50ms低于感知阈值） |
| focus_hysteresis | 0.03 | 0.01-0.05 | 退出太迟钝 | 阈值震荡频繁 |
| injury_pitch_max_semitones | 10 | 5-15 | 音效刺耳/失真 | 音调变化不可感知（playtest参数） |

## Acceptance Criteria

> **信号发射顺序**：apply_damage 中信号按以下顺序发射：on_hp_changed → on_hp_milestone → on_boss_phase_change → on_focus_mode_changed → on_death

- **AC-1** [基础扣血] **GIVEN** current_hp=100, max_hp=100, **WHEN** 受到30点伤害, **THEN** current_hp=70
- **AC-2** [护盾吸收] **GIVEN** current_hp=80, max_hp=100, shield=20, max_shield=20, **WHEN** 受到50点伤害, **THEN** shield=0, current_hp=50（shield_absorbed=20, effective=30）
- **AC-3** [过量伤害致死] **GIVEN** current_hp=10, **WHEN** 受到15点伤害, **THEN** current_hp=0, `on_death`信号发射
- **AC-4** [死后免疫] **GIVEN** current_hp=0（已死亡）, **WHEN** 再次受到伤害, **THEN** 忽略, 不触发重复死亡
- **AC-5** [Boss阶段转换] **GIVEN** Boss max_hp=300, phase_thresholds=[0.66, 0.33], current_hp=200, **WHEN** 受到10点伤害→current_hp=190(63%), **THEN** `on_boss_phase_change(1)`信号发射
- **AC-6** [Boss阶段跨跳] **GIVEN** Boss max_hp=300, current_hp=210(70%), **WHEN** 受到150点伤害→current_hp=60(20%), **THEN** `on_boss_phase_change(1)` 和 `on_boss_phase_change(2)` 依次发射
- **AC-7** [HP百分比查询] **GIVEN** current_hp=50, max_hp=100, **WHEN** 查询`get_hp_percentage()`, **THEN** 返回0.5
- **AC-8** [复活公式验证] **GIVEN** max_hp=100, revive_hp_percentage=0.5, **WHEN** revive(), **THEN** current_hp = max(1, floor(100×0.5)) = 50, 状态回到ALIVE
- **AC-9** [专注模式激活+信号] **GIVEN** 玩家HP从30%降到25%（战斗状态 active_enemies_count>0）, **WHEN** apply_damage, **THEN** focus_mode_active=true, `on_focus_mode_changed(true)`信号发射
- **AC-9b** [低HP视觉状态-手动] **GIVEN** 玩家HP=25%（战斗状态）, **WHEN** 查看屏幕, **THEN** HP条颜色=#E53E3E（信号红）、不脉动、不闪烁；攻击预兆信号红闪烁面积增大25%
- **AC-10** [i-frame免疫] **GIVEN** i_frame_remaining>0, **WHEN** 受到伤害, **THEN** 忽略伤害, 不触发on_hp_changed, 不更新伤害统计
- **AC-11** [治疗溢出clamp] **GIVEN** current_hp=80, max_hp=100, **WHEN** 使用回复道具(heal_amount=30), **THEN** current_hp=min(100, 80+30)=100
- **AC-12** [HP里程碑首次触发] **GIVEN** 本场景未触发过里程碑, **WHEN** HP首次降到75%, **THEN** `on_hp_milestone(entity, 0.75)`发射且后续HP再次经过75%不重复触发
- **AC-14** [专注模式退出] **GIVEN** 玩家HP=25%, focus_mode_active=true, **WHEN** 治疗到30%（>25%+3%迟滞=28%）, **THEN** focus_mode_active=false, `on_focus_mode_changed(false)`发射
- **AC-14b** [专注模式迟滞边界] **GIVEN** 玩家HP=25%, focus_mode_active=true, **WHEN** 治疗到恰好28%（=0.25+0.03, 严格等于）, **THEN** focus_mode_active保持true（不退出，因为退出条件是>28%而非≥28%）
- **AC-15** [死亡元数据结构] **GIVEN** 实体在战斗中死亡, **WHEN** on_death信号发射, **THEN** metadata包含last_hit{damage,type,source,is_crit}、battle_stats{duration_sec,damage_received,damage_dealt,dodge_success_rate,parry_success_rate,hits_received_by_pattern}、context{zone_id,enemy_type,boss_phase}
- **AC-16** [存档点回复] **GIVEN** current_hp=30, max_hp=100, shield=5, max_shield=20, **WHEN** 到达存档点, **THEN** current_hp=100, shield=20
- **AC-17** [复活HP下限保护] **GIVEN** max_hp=1, revive_hp_percentage=0.1, **WHEN** revive(), **THEN** current_hp=max(1, floor(1×0.1))=max(1,0)=1（不会返回0）
- **AC-18** [多伤害同帧处理] **GIVEN** current_hp=10, **WHEN** 同帧收到3次伤害(5, 5, 5), **THEN** 处理第1次→hp=5, 处理第2次→hp=0+on_death, 第3次被忽略
- **AC-19** [max_hp=0防御] **GIVEN** max_hp=0（数据异常）, **WHEN** 数据验证层检查, **THEN** 使用默认值100, 系统不崩溃
- **AC-20** [里程碑复活重置] **GIVEN** 本场景已触发on_hp_milestone(0.75), **WHEN** 实体死亡后复活, **THEN** triggered_milestones清空, HP再次降到75%时重新触发on_hp_milestone(0.75)
- **AC-21** [存亡+护盾查询] **GIVEN** current_hp=50, shield=10, max_shield=20, **WHEN** 查询, **THEN** is_alive()=true, is_dead()=false, get_shield_percentage()=0.5
- **AC-22** [信号发射顺序] **GIVEN** 玩家current_hp=10, 战斗状态, **WHEN** 受到15点伤害(致死), **THEN** 信号发射顺序为: ①on_hp_changed(hp=0) → ②on_hp_milestone(0.01) → ③on_focus_mode_changed(true) → ④on_death（GdUnit4验证策略：计数器方案，为每个信号连接lambda记录发射序号）
- **AC-23** [低HP受伤音效] [手动] **GIVEN** 玩家HP=20%(≤25%专注模式), **WHEN** 受到伤害, **THEN** 受伤音效包含低频混响效果（与满血时的音效不同）
- **AC-24** [i-frame重叠取最长] **GIVEN** 闪避 i_frame_remaining=5帧, **WHEN** 获得 invincible 状态效果(30帧), **THEN** i_frame_remaining=max(5,30)=30（不叠加为35）
- **AC-25** [DoT被i-frame免疫] **GIVEN** 玩家有毒素DoT(3DPS)且 i_frame_remaining>0, **WHEN** DoT tick触发 apply_damage(3), **THEN** 伤害被忽略, HP不变
- **AC-26** [Boss致死跨越阶段] **GIVEN** Boss max_hp=300, phase_thresholds=[0.66, 0.33], current_hp=100(33%), **WHEN** 受到100点伤害→current_hp=0, **THEN** on_boss_phase_change(1) 先发射, 然后 on_death 发射
- **AC-27** [零伤害/负伤害防御] **GIVEN** current_hp=50, **WHEN** apply_damage(0) 或 apply_damage(-5), **THEN** HP不变=50, 不触发 on_hp_changed
- **AC-28** [复活退出专注模式] **GIVEN** 玩家死亡时 focus_mode_active=true, **WHEN** revive() 恢复 HP=50%, **THEN** focus_mode_active=false, on_focus_mode_changed(false) 发射
- **AC-29** [区域死亡信号] **GIVEN** 实体在 zone_id="sewer_01" 区域中, **WHEN** 实体死亡（on_death 触发）, **THEN** on_death_in_zone(entity_id, "sewer_01") 信号发射
- **AC-30** [脱战退出专注模式] **GIVEN** 玩家 HP=20%, focus_mode_active=true, active_enemies_count>0, **WHEN** 所有敌人被击杀（active_enemies_count→0）, **THEN** focus_mode_active=false, on_focus_mode_changed(false) 发射
- **AC-31** [专注模式激活信号] **GIVEN** 玩家 HP从26%降到25%（战斗状态, focus_mode_active从false变为true）, **WHEN** apply_damage, **THEN** ①on_focus_mode_changed(true) 发射 ②激活视觉闪光触发（猫眼金色边缘闪光0.3秒）③激活音效触发（低频猫科提示音0.5秒）

## Visual/Audio Requirements

### HP条视觉反馈
- **颜色渐变**：猫眼金(100-75%) → 黄色(74-50%) → 橙色(49-25%) → 信号红(24-1%)
- **受伤闪红**：受击瞬间HP条闪白0.1秒
- **护盾显示**：HP条上方叠加蓝色护盾条
- **低HP状态**（24-1%）：HP条颜色稳定为信号红，**不脉动、不闪烁**（保持视觉清晰，CD-GDD-ALIGN决定）

### 低HP专注模式视觉（规则8配套）
- **激活闪光（一次性）**：专注模式启动瞬间，画面边缘出现0.3秒猫眼金色（`#ECC94B`）柔和闪光，渐入渐出，明确通知玩家模式切换
- **攻击预兆放大**：敌人蓄力攻击时的信号红闪烁面积增大25%，持续时间延长10%
- **环境干扰减少**：背景粒子效果透明度降至30%，画面边缘轻微暗角（聚焦战斗区域）
- **无画面收束**：视野范围保持不变，不做vignette效果

### 死亡视觉反馈
- **玩家死亡**：猫武士单膝触地（尊严感），画面渐灰，1.5秒后触发重生流程
- **敌人死亡**：倒地动画（0.5-1秒），尸体保留2秒后消失
- **Boss死亡**：特殊死亡动画（2-3秒），阶段转换时Boss姿态变化

### 音效设计
- **受伤音效**：低沉撞击音，音调随HP降低线性升高（详见公式 HD-F4）。**专注模式激活时**（非直接绑定HP阈值，继承迟滞逻辑）受伤音效增加低频混响（"沉闷感"），提供不干扰战斗节奏的持续听觉信号
- **低HP音效**：战斗音效保持清晰，**不添加心跳音**（避免干扰专注）
- **专注模式激活音效（一次性）**：模式启动瞬间播放0.5秒低频猫科提示音（低沉"咕噜"声），仅在激活时播放，退出时不播放。与激活视觉闪光同步
- **死亡音效**：玩家死亡=沉重落地音；敌人死亡=消散音；Boss死亡=史诗终结音

## UI Requirements

### 玩家HP条
- 位置：屏幕左下角
- 尺寸：宽200px × 高20px
- 数值显示：当前HP/最大HP（如 75/100）
- 低HP警告：HP<25%时HP条颜色稳定为信号红，不脉动。战斗音效保持清晰，不添加心跳音（与规则8专注模式一致）

### Boss HP条
- 位置：屏幕顶部中央
- 尺寸：宽400px × 高15px
- 阶段标记：在阈值位置显示垂直分割线
- Boss名称：HP条上方显示Boss名称

### 敌人HP条
- 位置：敌人头顶
- 尺寸：宽60px × 高8px
- 显示条件：受到伤害时显示3秒后淡出

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 护盾来源由状态效果系统GDD定义（当前休眠 — 护盾接口和公式保留，max_shield默认0，待上游系统提供护盾来源后激活） | status-effects GDD | 状态效果系统GDD |
| 2 | 死亡惩罚机制（丢失物品？回到检查点？） | game-designer | 死亡与重生系统GDD |
| 3 | ~~是否需要"无敌帧"（受伤后短暂无敌）？~~ → **已解决**：规则7定义了i-frames（闪避总12帧/窗口8帧、弹反8帧、复活120帧） | — | ✅ 2026-06-20 |
| 4 | ⚠️ audio-system.md 心跳音矛盾：audio-system.md 仍定义 LOW_HP 心跳音状态 + sfx_low_hp 资产 + 对应AC，与本文档"不添加心跳音"直接冲突 | producer 协调 audio-system.md | Design Review #3 发现 |
| 5 | ⚠️ death-respawn.md revive HP 不一致：death-respawn.md 说"恢复玩家HP到max_hp"（满血），本文档 revive_hp_percentage=0.5（50%）。CD裁定50% | producer 协调 death-respawn.md | Design Review #3 发现 |
| 6 | ⚠️ audio-system.md 需添加 pitch_offset 参数：HD-F4 受伤音高公式要求 play_sfx 支持 pitch 参数，当前接口无此字段 | producer 协调 audio-system.md | Design Review #3 发现 |
| 7 | ~~active_enemies_count 来源系统未定义~~ → **已解决**：由AI框架提供 `get_active_enemy_count()` 查询（处于CHASE/ATTACK状态的敌人数量） | — | ✅ 2026-06-21 |
