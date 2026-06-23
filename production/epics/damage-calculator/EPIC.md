# Epic: Damage Calculation

> **Layer**: Foundation
> **GDD**: design/gdd/damage-calculation.md
> **Architecture Module**: DamageCalculator
> **Status**: Complete
> **Stories**: 4 stories

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | FormulaPipeline + DamageResult 核心公式 | Logic | Complete | ADR-0001, ADR-0002 |
| 002 | CritComboParry 倍率路径 | Logic | Complete | ADR-0001, ADR-0002 |
| 003 | SpecialMoves + Skill/Window Modifiers | Logic | Complete | ADR-0001 |
| 004 | DamageParams Data API Integration | Integration | Complete | ADR-0003, ADR-0001, ADR-0002 |

## Overview

实现 DamageCalculator 静态工具类（`class_name`，非 Autoload）的完整伤害流水线：9 个公式（DC-F1~F9），三步计算（base_damage → attack_damage → final_damage），确定性暴击窗口、连招倍率查表、弹反 4 档倍率、防御递减曲线、伤害 clamp(1,999)。DamageCalculator 是纯函数无状态，100% 可单元测试，GDD 有 20 条 Acceptance Criteria 可直接转为 GdUnit4 测试用例。

**Note**: TR-damage-009（F9 技能树 weapon_base 覆盖）和 TR-damage-010（charm_crit 窗口扩展）预留接口参数，具体逻辑在 Skill Tree / Charm Epic 中实现。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Autoload 架构 | DamageCalculator 为 `class_name` 静态类，非 Autoload | LOW |
| ADR-0002: 信号通信 | DamageResult payload 类定义 | LOW |
| ADR-0003: 数据管理 | 从 DataManager 读取 damage_params 域 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-damage-001 | 三步伤害流水线，纯函数无状态 | ADR-0001 ✅ |
| TR-damage-002 | 确定性暴击窗口（PERFECT/GOOD/NORMAL） | ADR-0001 ⚠️ |
| TR-damage-003 | 连招倍率查表（4 武器 × 3 段） | ADR-0001 ⚠️ |
| TR-damage-004 | 弹反 4 档倍率（5.0×/2.5×/1.5×/1.0×） | ADR-0001 ⚠️ |
| TR-damage-005 | 防御减伤递减曲线 60/(defense+60) | ADR-0001 ⚠️ |
| TR-damage-006 | final_damage clamp(1,999) + damage_multiplier | ADR-0001 ✅ |
| TR-damage-007 | 特殊招式独立倍率 DC-F9 | ADR-0001 ⚠️ |
| TR-damage-008 | calculate_damage 输出 metadata | ADR-0002 ✅ |
| TR-damage-009 | F9 weapon_base 覆盖（技能树） | — ⚠️ 预留接口 |
| TR-damage-010 | DC-F5 暴击窗口扩展（护符 + 专注模式） | ADR-0005 ⚠️ |
| TR-damage-011 | 空中/蓄力攻击第三路径 | ADR-0001 ⚠️ |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`
- All acceptance criteria from `design/gdd/damage-calculation.md` are verified
- All 20 GDD AC 转为单元测试并通过（`tests/unit/damage/`）
- 100% 公式覆盖率（DC-F1~F9 各有至少 3 个测试用例：正常/边界/极端）
- DamageResult 类正确封装所有 metadata 字段
- skill_modifiers 参数预留接口（Dictionary，默认空）

## Next Step

Damage Calculation epic complete. Next recommended implementation target: Health/Death or Feline Combat integration, because both can now consume the completed DamageCalculator API.
