# Epic: Weapon Styles

> **Layer**: Core
> **GDD**: design/gdd/weapon-styles.md
> **Architecture Module**: WeaponStyleManager
> **Status**: In Progress
> **Stories**: 8 stories

## Overview

Implement `WeaponComponent` as the Core entity component that owns the four weapon
style configurations, current weapon, upgrade levels, swap lifecycle, special
attack gates, and weapon-specific hit callbacks. The system provides data-driven
weapon parameters to Combat and DamageCalculator without owning animation, VFX,
HUD, audio, save-file orchestration, or collision detection internals.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | WeaponComponent is mounted on Player as a Core scene component, not an Autoload. | LOW |
| ADR-0002: Signal communication | Weapon changes, upgrades, and special gates emit direct Godot signals. | LOW |
| ADR-0003: Data management | Weapon configuration is JSON source data loaded through DataManager. | LOW |
| ADR-0004: Collision detection | Range and multi-target behavior use CollisionComponent hitbox boundaries. | LOW |
| ADR-0005: Combat state machine | Combat owns state, combo, cat energy, and animation locks consumed by weapons. | LOW |
| ADR-0016: Weapon styles architecture | WeaponComponent owns weapon configs, levels, swap state, special dispatch, and hit callbacks. | LOW |
| ADR-0017: Status effects architecture | Electro Bell slow is applied through StatusEffectComponent. | LOW |
| ADR-0019: Health component | Fish Bone shield break uses HealthComponent-compatible adapters. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-weapon-001 | Four weapons expose damage, speed, range, combo table, and special mechanism data. | ADR-0003, ADR-0016 ✅ |
| TR-weapon-002 | Combat weapon swap takes 0.5s, cycles order, and clears combo/dodge state. | ADR-0002, ADR-0005, ADR-0016 ✅ |
| TR-weapon-003 | Each weapon has a special attack with cooldown and cat-energy gates. | ADR-0005, ADR-0016 ✅ |
| TR-weapon-004 | Weapon upgrades max at level 5 and raise base damage per level. | ADR-0016 ✅ |
| TR-weapon-005 | Cat Claw extends dodge-counter crit windows by 3 frames. | ADR-0005, ADR-0016 ✅ |
| TR-weapon-006 | Electro Bell applies slow for 2 seconds at -30% movement. | ADR-0016, ADR-0017 ✅ |
| TR-weapon-007 | Fish Bone full-charge hits break shields through Health integration. | ADR-0016, ADR-0019 ✅ |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Weapon Config Catalog + Base Damage Query | Logic | Complete | ADR-0003, ADR-0016 |
| 002 | Weapon Upgrade State + Serialization Prep | Logic | Complete | ADR-0016 |
| 003 | Weapon Swap State Machine + Combat Adapter | Integration | Complete | ADR-0002, ADR-0005, ADR-0016 |
| 004 | Special Attack Cooldown + Cat Energy Gate | Integration | Complete | ADR-0005, ADR-0016 |
| 005 | Cat Claw Dodge-Counter Crit Bonus | Integration | Complete | ADR-0005, ADR-0016 |
| 006 | Long Tail Multi-Target Range Contract | Integration | Complete | ADR-0004, ADR-0016 |
| 007 | Fish Bone Charged Shield Break | Integration | Complete | ADR-0016, ADR-0019 |
| 008 | Electro Bell Slow Status Application | Integration | Ready | ADR-0016, ADR-0017 |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`.
- Four weapon configs load through DataManager and validate through schema.
- Weapon swap, special gates, upgrade damage, and weapon hit callbacks are covered
  by automated tests.
- Integration boundaries remain adapter-based and do not add new Autoloads.
- Runtime smoke uses Godot MCP if exposed; otherwise Godot CLI/headless evidence
  records project boot and main-scene execution.

## Next Step

Stories 001-007 are complete. Continue with
`production/epics/weapon-styles/story-008-electro-bell-slow-status-application.md`.
