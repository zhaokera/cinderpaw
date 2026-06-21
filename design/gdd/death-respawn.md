# 死亡与重生系统 (Death & Respawn System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-21
> **Implements Pillar**: 技巧优先成长
> **Systems Index**: #12 | MVP核心 | Feature
> **Cross-doc Sync (2026-06-21)**: revive HP从满血改为health-death.md的revive_hp_percentage(50%), 状态机标注为DEAD子状态, 心跳音引用移除

## Overview

**死亡与重生系统**管理玩家死亡后的重生流程。它监听生命系统的`on_death`信号，播放死亡动画，将玩家传送到最近的存档点，恢复HP（由health-death.md的`revive_hp_percentage`决定，默认50%），并可选地展示"猎手学费"反馈（本次战斗的学习要点）。设计上确保死亡是**教育性的而非惩罚性的**——没有货币/物品损失，快速重试让学到的教训立刻变成下一次尝试的武器。

## Player Fantasy

**「猫有九命」— 每次死亡都是成长的邀请**

死亡不是Game Over，而是"你已经交了学费，下次该用上了"。猫武士倒下的瞬间不是终结，而是邀请——"再试一次，这次你知道它的第三招了"。快速重生（<3秒从死亡到可操作）确保学习的连续性，不让挫败感积累。

## Detailed Design

### Core Rules

#### 规则1：死亡触发流程
1. 生命系统检测到HP≤0 → 发射`on_death(entity, metadata)`信号
2. 死亡与重生系统接收信号 → 进入DYING状态
3. 播放死亡动画（1.5秒，猫武士单膝触地→倒地→画面渐灰）
4. 死亡动画完成 → 进入RESPAWNING状态
5. 确定重生点（最近存档点）
6. 加载/切换场景到存档点所在场景
7. 调用生命系统`revive(entity_id)`恢复HP（由health-death.md内部计算：`max(1, floor(max_hp × revive_hp_percentage))`，默认50%）
8. 恢复玩家位置到存档点坐标
9. 清空所有临时战斗状态（combo_index、闪避冷却等）
10. 进入REVIVED状态 → 恢复玩家控制

#### 规则2：重生点选择
- **优先级**：最近发现的存档点 > 猫族据点
- **Boss战特殊**：Boss战中死亡，重生在Boss战场入口（非存档点）
- **Boss战后**：Boss击败后自动存档，后续死亡重生在该存档点

#### 规则3：猎手学费反馈（可选）
死亡后可选择展示"战斗总结"（默认关闭，设置中开启）：
```
battle_summary = {
    duration_sec: float,
    damage_dealt: int,
    damage_received: int,
    dodge_success_rate: float,
    parry_success_rate: float,
    hits_by_pattern: Dictionary,
    tip: String                    # 系统生成的学习建议
}
```

**提示生成规则**：
- 受击最多的攻击模式 → "注意[攻击名]的[前摇特征]，试试闪避/弹反"
- 闪避成功率<50% → "闪避时机可以更早一点，注意敌人的蓄力动作"
- 弹反成功率<30% → "弹反窗口在攻击命中前6帧，多练习节奏感"

#### 规则4：死亡无惩罚
- 不丢失货币（齿轮币保留）
- 不丢失物品（已获得的武器/护符保留）
- 不丢失进度（世界状态不变）
- HP恢复到revive_hp_percentage（默认50%，由health-death.md的revive()内部计算）
- 不降低敌人难度（技巧优先承诺）

### States and Transitions

| 状态 | 行为 | 转换条件 |
|------|------|---------|
| ALIVE | 正常游戏 | HP≤0→DYING |
| DYING | 播放死亡动画（1.5秒） | 动画完成→RESPAWNING |
| RESPAWNING | 确定重生点+加载场景+恢复状态 | 完成→REVIVED |
| REVIVED | 短暂无敌（2秒）+ 恢复控制 | 无敌结束→ALIVE |

> ⚠️ **状态所有权说明**：health-death.md 拥有 `EntityState { ALIVE, DYING, DEAD }`。本系统的 RESPAWNING 和 REVIVED 是 health-death DEAD 状态的**内部子阶段**（`DeathPhase { RESPAWNING, REVIVED }`）。两系统通过信号协调，不共享状态枚举。health-death 的 `revive()` 将 EntityState 从 DEAD 切回 ALIVE，本系统的 REVIVED 阶段在 revive 之前完成。

### Interactions with Other Systems

**上游依赖**：
- 生命与死亡检测 — 监听`on_death(entity, metadata)`信号
- 存档系统 — 查询最近存档点
- 场景管理系统 — 切换场景到存档点

**下游被依赖**：
- 输入系统 — DYING/RESPAWNING状态清空输入缓冲
- 战斗系统 — REVIVED时重置战斗状态

**接口签名**：
```
on_death(entity_id, metadata: Dictionary) → void
get_respawn_point() → SavePointInfo
show_battle_summary(battle_stats: Dictionary) → void
```

## Formulas

本系统不定义游戏平衡公式。时间预算：
- 死亡动画：1.5秒
- 重生流程（场景加载）：< 2秒
- 复活无敌时间：2秒
- **总死亡到可操作时间：< 5.5秒**

## Edge Cases

- **死亡动画中被Boss击杀**：不可能（DYING状态无敌）
- **重生点场景未加载**：使用场景管理系统预加载
- **Boss战中死亡**：重生在Boss战场入口，Boss HP恢复到进入时状态
- **存档点被删除**：回退到猫族据点
- **快速连续死亡**（<5秒内再次死亡）：正常处理，不增加额外惩罚
- **死亡时正在过场动画**：跳过过场，直接进入死亡流程

## Dependencies

**上游依赖**：
- 生命与死亡检测 — `on_death`信号 + `revive(entity_id)`接口（HP由生命系统计算）
- 存档系统 — 最近存档点查询
- 场景管理系统 — 场景切换

**下游被依赖**：
- 输入系统 — 清空输入缓冲
- 猫科战斗系统 — 重置战斗状态

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| death_animation_duration_sec | 1.5 | 0.5-3.0 | 死亡太长 | 死亡太短 |
| respawn_invincibility_sec | 2.0 | 1.0-5.0 | 无敌太久 | 重生即死 |
| battle_summary_enabled | false | true/false | — | — |
| fade_to_grey_duration_sec | 0.5 | 0.3-1.0 | 渐暗太慢 | 渐暗太快 |

## Visual/Audio Requirements

### 死亡视觉
- **死亡动画**：猫武士单膝触地（尊严感）→ 缓缓倒地 → 画面渐灰（0.5秒）
- **死亡粒子**：猫眼金色粒子从身体飘散（灵魂离开）
- **渐灰效果**：全屏灰度滤镜渐入

### 重生视觉
- **渐灰退去**：灰度滤镜渐出（0.5秒）
- **复活闪光**：猫眼金色光环从玩家位置扩散（1秒）
- **无敌闪烁**：复活后2秒内角色半透明闪烁

### 音效设计
- **死亡音效**：沉重落地音 → 沉默（1秒）→ 低沉哀伤弦乐
- **重生音效**：猫叫声（轻柔）→ 环境音渐入

## UI Requirements

### 死亡画面
- 全屏灰度背景
- 中央文字："按下[按键]继续"
- 底部：最近存档点名称

### 战斗总结面板（可选）
- 位置：屏幕中央弹窗
- 显示：战斗统计+学习建议
- 操作："重试"按钮 + "跳过"按钮

## Acceptance Criteria

- **GIVEN** 玩家HP≤0，**WHEN** `on_death`信号触发，**THEN** 播放死亡动画（1.5秒）
- **GIVEN** 死亡动画完成，**WHEN** 进入RESPAWNING状态，**THEN** 传送到最近存档点+调用`revive(entity_id)`恢复HP（默认50%）
- **GIVEN** Boss战中死亡，**WHEN** 重生，**THEN** 在Boss战场入口重生+Boss HP恢复
- **GIVEN** 重生完成，**WHEN** 进入REVIVED状态，**THEN** 2秒无敌+半透明闪烁
- **GIVEN** 死亡后，**WHEN** 检查玩家状态，**THEN** 货币/物品/进度无损失
- **GIVEN** 战斗总结开启，**WHEN** 死亡后，**THEN** 显示战斗统计+学习建议

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 是否需要"怜悯机制"（同一Boss连续死亡5次后降低难度）？ | game-designer | 垂直切片阶段 |
| 2 | 死亡计数器是否影响叙事/成就？ | narrative-director | 叙事系统GDD |
