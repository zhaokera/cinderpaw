# Epic: Health & Death Detection

> **Layer**: Core
> **GDD**: design/gdd/health-death.md
> **Architecture Module**: HealthComponent
> **Status**: Complete
> **Stories**: 6 stories

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | HP State + Damage Pipeline | Logic | Complete | ADR-0001, ADR-0002 |
| 002 | HP Milestones + Boss Phase Gates | Logic | Complete | ADR-0001, ADR-0002 |
| 003 | I-Frames + Healing + Revive | Logic | Complete | ADR-0001, ADR-0002 |
| 004 | Focus Mode State + Signals | Integration | Complete | ADR-0001, ADR-0002, ADR-0006 |
| 005 | Death Metadata + Zone Hooks | Integration | Complete | ADR-0001, ADR-0002 |
| 006 | Max HP Aggregation + Serialization Prep | Integration | Complete | ADR-0001, ADR-0008 |

## Overview

Implement `HealthComponent` as a Core entity component for player, enemy, and boss nodes. It owns HP, shield, entity life state, damage application, death detection, milestone/phase/focus signals, i-frame and revive support, and query APIs consumed by Combat, HUD, AI, respawn, exploration, and narrative systems.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Autoload architecture | HealthComponent is a Core scene component, not an Autoload; each entity owns independent state. | LOW |
| ADR-0002: Signal communication | Health signals use typed Godot signals; signal order must be state change, conditionals, terminal death last. | LOW |
| ADR-0019: HealthComponent deep architecture | Detailed HealthComponent design for HP, shield, i-frames, focus mode, milestones, death metadata, and serialization. Current file status is Proposed, used here as design reference until formally accepted. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-health-001 | HP状态管理需要 current_hp/max_hp/shield（休眠），每个实体独立管理 | ADR-0001 ✅ |
| TR-health-002 | apply_damage 需要完整伪代码防护：state guard/is_invincible检查/零伤害防护 | ADR-0001, ADR-0002 ✅ |
| TR-health-003 | 护盾优先吸收伤害，剩余扣HP | ADR-0019 ⚠️ Proposed reference |
| TR-health-004 | Boss阶段转换使用while循环确保跨跳场景触发所有经过的阈值 | ADR-0019 ⚠️ Proposed reference |
| TR-health-005 | HP里程碑阈值每次仅触发一次，复活后重置 | ADR-0002, ADR-0019 ⚠️ |
| TR-health-006 | 专注模式：HP≤25%且active_enemies_count>0时激活，>28%退出 | ADR-0006, ADR-0019 ⚠️ |
| TR-health-007 | 专注模式激活瞬间触发猫眼金闪光与低频提示音 | ADR-0002, ADR-0010, ADR-0019 ✅ Story154 |
| TR-health-008 | 专注模式感知变化接口 | ADR-0006, ADR-0010, ADR-0019 ✅ Story154 activation, Story157 Boss windup, Story158 attack tell, Story159 environment particles, Audio Story010 low-frequency/damped hurt mix |
| TR-health-009 | i-frame管理使用 max(current,new) 不叠加取最长 | ADR-0019 ⚠️ Proposed reference |
| TR-health-010 | on_death 信号携带扩展元数据 | ADR-0002, ADR-0019 ⚠️ |
| TR-health-011 | apply_damage 信号顺序：HP→milestone→phase→focus→death | ADR-0002 ✅ |
| TR-health-012 | max_hp = base_hp + skill_hp_flat + charm_hp_flat | ADR-0019 ⚠️ Proposed reference |
| TR-health-013 | revive() 重置 focus_mode_active 并发射退出信号 | ADR-0019 ⚠️ Proposed reference |
| TR-health-014 | 受伤音效音调偏移 HD-F4 | ADR-0019 ⚠️ Proposed reference |
| TR-health-015 | 探索与叙事接口钩子 | ADR-0002, ADR-0019 ⚠️ |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`.
- All acceptance criteria from `design/gdd/health-death.md` are verified or explicitly deferred to Presentation evidence.
- Logic and Integration stories have passing tests in `tests/unit/health/`.
- `HealthComponent` can be instantiated in GdUnit4 without a full gameplay scene.
- Downstream Core/Presentation systems can consume health, death, milestone, boss phase, and focus signals without reverse dependencies.

## Next Step

Health & Death Detection scope is complete. Continue with the next Core/Feature integration epic that consumes HealthComponent signals, such as Feline Combat integration or Death & Respawn.
