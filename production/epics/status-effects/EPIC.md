# Epic: Status Effects

> **Layer**: Core
> **GDD**: design/gdd/status-effects.md
> **Architecture Module**: StatusEffectManager
> **Status**: Complete
> **Stories**: 6 stories

## Overview

Implement `StatusEffectComponent` as a Core entity component that owns active
buff/debuff instances, applies immunity rules, refreshes or stacks effects,
processes duration and DoT ticks, exposes movement/damage modifiers, and clears
state on death or scene transitions. The system remains a gameplay/core service
for Combat, AI, Health, Weapon Styles, Boss Configuration, HUD, and Presentation
without becoming an Autoload or visual/audio owner.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | StatusEffectComponent is mounted on entities as a scene component, not an Autoload. | LOW |
| ADR-0002: Signal communication | Effect lifecycle changes emit direct Godot signals for local consumers. | LOW |
| ADR-0003: Data management | Effect tuning values are loaded through the existing tuning knob data pipeline. | LOW |
| ADR-0005: Combat state machine | STUN is consumed by Combat/AI state machines through component queries/adapters. | LOW |
| ADR-0017: Status effects architecture | Status effects use a small component-owned list, tick timing, modifiers, immunities, and cleanup hooks. | LOW |
| ADR-0019: Health component | Health/invulnerability adapters provide death, i-frame, and DoT damage integration points. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-status-001 | 7 effect types and at most 5 simultaneous effects per entity. | ADR-0017 ✅ |
| TR-status-002 | Apply flow checks immunity, refreshes existing effects, then emits apply events. | ADR-0002, ADR-0017 ✅ |
| TR-status-003 | DoT ticks call `apply_damage()` and movement modifiers multiply together. | ADR-0017, ADR-0019 ✅ |
| TR-status-004 | i-frames/debuff immunity and invincible status integration. | ADR-0017, ADR-0019 ✅ |
| TR-status-005 | Effect priority and oldest-effect eviction when full. | ADR-0017 ✅ |
| TR-status-006 | Death and scene changes clear all effects. | ADR-0002, ADR-0017 ✅ |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | StatusEffectComponent + Effect Catalog | Logic | Complete | ADR-0001, ADR-0003, ADR-0017 |
| 002 | Status Application + Boss STUN Immunity | Integration | Complete | ADR-0002, ADR-0017 |
| 003 | Duration Tick + Modifier Queries | Integration | Complete | ADR-0017, ADR-0019 |
| 004 | I-frame + Invincible Debuff Immunity | Integration | Complete | ADR-0017, ADR-0019 |
| 005 | Effect Priority + Capacity Eviction | Logic | Complete | ADR-0017 |
| 006 | Death + Scene Cleanup Hooks | Integration | Complete | ADR-0002, ADR-0017 |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`.
- StatusEffectComponent can be instantiated in GdUnit4 without a full entity scene.
- Poison, slow, stun, burn, speed_boost, damage_boost, and invincible are defined.
- Apply, refresh, immunity, duration, DoT, modifiers, capacity, and cleanup rules
  from `design/gdd/status-effects.md` are verified by automated tests.
- Status effects expose adapter/query boundaries for Combat, AI, Health, Weapon
  Styles, Boss Configuration, HUD, and Presentation without owning those systems.

## Next Step

Status Effects Core scope is complete. Choose a downstream consumer epic next:
HUD/UI status icons, Weapon Styles status application, Combat/AI STUN consumption,
SceneManager implementation, or combat presentation VFX/audio.
