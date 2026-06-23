# Epic: Feline Combat

> **Layer**: Core
> **GDD**: design/gdd/feline-combat.md
> **Architecture Module**: CombatComponent
> **Status**: Complete
> **Stories**: 7 stories

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Combat State Machine + Input Entry Points | Integration | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 002 | Light Combo Chain + Cancel Windows | Logic | Complete | ADR-0005 |
| 003 | Dodge I-Frames + Hurtbox Adapter | Integration | Complete | ADR-0004, ADR-0005 |
| 004 | Parry Timing Windows + Counter Outcome | Logic | Complete | ADR-0004, ADR-0005 |
| 005 | Heavy Charge + Hit Stun + Aerial Hooks | Logic | Complete | ADR-0005 |
| 006 | Cat Energy + Special/Ultimate Gates | Integration | Complete | ADR-0005, ADR-0016 |
| 007 | Hit Confirmation + Focus Damage Metadata | Integration | Complete | ADR-0002, ADR-0004, ADR-0005 |

## Overview

Implement `CombatComponent` as a Core entity component that turns normalized input actions into frame-level combat state transitions. It owns the 6-state combat FSM, light combo chain, dodge and parry windows, heavy charge lifecycle, cat energy, battle statistics, and the provisional adapters used to hand off hitbox, damage, health, weapon, and focus-mode data without making Combat an Autoload.

Visual effects, audio, combo HUD, and charge UI remain out of scope for this Core epic. Those requirements are delegated to Combat Presentation, Audio, and HUD/UI epics, which consume Combat signals instead of being called directly.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Autoload architecture | CombatComponent is a Core scene component under an entity node, not an Autoload. | LOW |
| ADR-0002: Signal communication | Combat emits typed Godot signals and uses signal boundaries for downstream presentation consumers. | LOW |
| ADR-0004: Collision detection architecture | Combat coordinates Area2D Hitbox/Hurtbox activation through CollisionComponent interfaces. | LOW |
| ADR-0005: Combat state machine architecture | Combat uses enum + match FSM, AnimationPlayer, 3-step combo, dodge/parry subsystems, and cat energy. | LOW |
| ADR-0016: Weapon styles architecture | Proposed reference for special/ultimate gates and weapon-specific CombatComponent extension points. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-combat-001 | 攻击状态机需要6状态，支持帧级状态转换和动作取消规则 | ADR-0001, ADR-0005 ✅ |
| TR-combat-002 | 轻攻击3段连招需要不同帧参数 | ADR-0005 ✅ |
| TR-combat-003 | 闪避i-frame窗口第3-10帧、位移3个角色宽度、冷却0.5秒 | ADR-0004, ADR-0005 ✅ |
| TR-combat-004 | 弹反18帧窗口，PERFECT/GOOD/LATE分档，成功眩晕1秒 | ADR-0004, ADR-0005 ✅ |
| TR-combat-005 | 动作取消规则表 | ADR-0005 ✅ |
| TR-combat-006 | 与输入系统协调，消费 action_triggered，notify_animation_lock/unlock | ADR-0001, ADR-0005 ✅ |
| TR-combat-007 | 猫气系统，12种行为获取，脱战10秒清零 | ADR-0005 ✅ |
| TR-combat-008 | 特殊招式受冷却和猫气双重约束 | ADR-0005, ADR-0016 ⚠️ Proposed reference |
| TR-combat-009 | 极意技需要技能树T5门控并统一消耗80猫气 | ADR-0005, ADR-0016 ⚠️ Proposed reference |
| TR-combat-010 | 专注模式监听 on_focus_mode_changed，PERFECT暴击窗口+1帧 | ADR-0002, ADR-0005 ✅ |
| TR-combat-011 | 受击硬直最多3次叠加，空中攻击命中可弹跳恢复跳跃 | ADR-0005 ✅ |
| TR-combat-012 | heavy_attack 0.5-1.5秒蓄力，可被闪避取消或受击打断 | ADR-0005 ✅ |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`.
- All Core acceptance criteria from `design/gdd/feline-combat.md` are covered by passing tests under `tests/unit/combat/`.
- `CombatComponent` can be instantiated in GdUnit4 without a full Player scene.
- Input, DamageCalculator, HealthComponent focus mode, and provisional CollisionComponent adapters are integrated through typed methods/signals.
- Presentation-layer visual/audio/UI requirements are explicitly deferred to downstream epics and are not implemented in Core.

## Next Step

Feline Combat Core is complete. Continue with a downstream integration epic that consumes Combat signals and metadata, such as Weapon Styles, Combat Presentation, Audio, HUD/UI, or Death metadata integration.
