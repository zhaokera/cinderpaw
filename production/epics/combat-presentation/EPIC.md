# Epic: Combat Presentation

> **Layer**: Presentation
> **GDD**: design/gdd/combat-presentation.md
> **Architecture Module**: CombatPresentation
> **Status**: In Progress
> **Stories**: 8 stories tracked

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
| TR-combatfx-001 | Hitstop durations are selected by event type, and same-frame events take the maximum duration. | ADR-0002 partial |
| TR-combatfx-002 | Screen shake intensity and duration are selected by event type, and same-frame events take the maximum intensity. | ADR-0002 partial |
| TR-combatfx-003 | Particle system supports GDD particle types with a 200-particle performance cap. | Gap |
| TR-combatfx-004 | Dodge, dash, and perfect parry support afterimage feedback modes. | ADR-0002 partial |
| TR-combatfx-005 | Damage number size, color, and animation communicate damage tier. | ADR-0002 partial |
| TR-combatfx-006 | Perfect parry, character hit, and enemy crit flash effects use authored durations and alpha. | ADR-0002 partial |
| TR-combatfx-007 | Combat presentation work stays within the 3ms frame budget. | Gap |
| TR-combatfx-008 | Colorblind mode remaps particle colors to the accessibility palette. | Gap |
| TR-combatfx-009 | Low-HP focus mode reduces screen shake intensity by 30%. | Gap |
| TR-combatfx-010 | Player runtime character art uses AnimatedSprite2D + SpriteFrames frame animation instead of static Sprite2D art. | ADR-0005 partial |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Textured Hit Spark + Enemy Debris Slice | Visual/Runtime | Complete | ADR-0001, ADR-0002 |
| 002 | Parry Flash + Cat Claw Trail Slice | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0016 |
| 003 | Cinderpaw Player Frame Animation Slice | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 004 | Dodge Afterimage + Cinderpaw Dodge Animation Slice | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 005 | Cinderpaw Hurt, Death, and Revive Animation Slice | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0005, ADR-0019 |
| 006 | Cinderpaw Jump and Fall Animation Slice | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 007 | Textured Parry Flash + Main Scene Visual Contract | Visual/Feel | Complete | ADR-0001, ADR-0002 |
| 008 | Damage Number Tier Polish | Visual/Feel | Complete | ADR-0001, ADR-0002 |

## Definition of Done

This epic is complete when:
- Hit, crit, kill, parry, dodge, weapon trail, boss phase, and damage-number
  feedback all satisfy `design/gdd/combat-presentation.md` acceptance criteria.
- Combat VFX are generated/imported through the project asset pipeline rather
  than represented by prototype ColorRect blocks.
- Runtime evidence is captured through Godot MCP when available.
- Particle counts and lifetimes stay within the GDD performance budget.

## Next Step

Continue with boss phase feedback, colorblind remaps, performance-budget checks,
low-HP focus shake reduction, and remaining weapon presentation variants. The
epic stays In Progress until all feedback modes satisfy
`design/gdd/combat-presentation.md`.
