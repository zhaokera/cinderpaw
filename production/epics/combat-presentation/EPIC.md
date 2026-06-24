# Epic: Combat Presentation

> **Layer**: Presentation
> **GDD**: design/gdd/combat-presentation.md
> **Architecture Module**: CombatPresentation
> **Status**: In Progress
> **Stories**: 2 stories tracked

## Overview

Implement the combat feedback layer that turns Core combat events into readable
hitstop, screen shake, damage numbers, hit sparks, debris, flash, trails, and
afterimages. This epic stays Presentation-only: it listens to combat, damage,
collision, health, boss, and weapon events without owning their gameplay rules.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | CombatPresentation is scene-mounted Presentation, not an autoload owner. | LOW |
| ADR-0002: Signal communication | Combat feedback is driven from event dictionaries/signals emitted by gameplay systems. | LOW |
| ADR-0016: Weapon styles | Weapon metadata can tint or specialize feedback without bypassing Core damage rules. | MEDIUM |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-combatfx-001 | Normal hits produce hitstop, light shake, and 5-8 white sparks. | ADR-0002 partial |
| TR-combatfx-002 | Crit hits produce stronger hitstop, shake, gold particles, and gold damage text. | ADR-0002 partial |
| TR-combatfx-003 | Particle system supports GDD particle types with a 200-particle performance cap. | Gap |
| TR-combatfx-004 | Perfect parry triggers hitstop, flash, shake, and radial particles. | Gap |
| TR-combatfx-005 | Dodge and fast movement support afterimage feedback. | Gap |
| TR-combatfx-006 | Boss phase changes trigger shake, metal debris, and vignette. | Gap |
| TR-combatfx-007 | Enemy death triggers hitstop and 15-20 debris particles. | ADR-0002 partial |
| TR-combatfx-008 | Damage number size, color, and animation communicate damage tier. | ADR-0002 partial |
| TR-combatfx-009 | Combat presentation work stays within the 3ms frame budget. | Gap |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Textured Hit Spark + Enemy Debris Slice | Visual/Runtime | Complete | ADR-0001, ADR-0002 |
| 002 | Parry Flash + Cat Claw Trail Slice | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0016 |

## Definition of Done

This epic is complete when:
- Hit, crit, kill, parry, dodge, weapon trail, boss phase, and damage-number
  feedback all satisfy `design/gdd/combat-presentation.md` acceptance criteria.
- Combat VFX are generated/imported through the project asset pipeline rather
  than represented by prototype ColorRect blocks.
- Runtime evidence is captured through Godot MCP when available.
- Particle counts and lifetimes stay within the GDD performance budget.

## Next Step

Continue with dodge afterimages and remaining weapon/boss presentation slices.
The epic stays In Progress until parry, dodge, weapon trail, boss phase, and
damage-number feedback all satisfy `design/gdd/combat-presentation.md`.
