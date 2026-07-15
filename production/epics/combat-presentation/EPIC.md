# Epic: Combat Presentation

> **Layer**: Presentation
> **GDD**: design/gdd/combat-presentation.md
> **Architecture Module**: CombatPresentation
> **Status**: Complete
> **Stories**: 19 stories tracked

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
| TR-combatfx-003 | Particle system supports GDD particle types with a 200-particle performance cap. | ADR-0002, Story012 cap, Story013 weapon family variants |
| TR-combatfx-004 | Dodge, dash, and perfect parry support afterimage feedback modes. | ADR-0002, Story004, Story016 |
| TR-combatfx-005 | Damage number size, color, and animation communicate damage tier. | ADR-0002 partial |
| TR-combatfx-006 | Perfect parry, character hit, and enemy crit flash effects use authored durations and alpha. | ADR-0002 partial |
| TR-combatfx-007 | Combat presentation work stays within the 3ms frame budget. | ADR-0002, Story012 |
| TR-combatfx-008 | Colorblind mode remaps particle colors to the accessibility palette. | ADR-0002, Story011 |
| TR-combatfx-009 | Low-HP focus mode reduces screen shake intensity by 30%. | ADR-0002, Story011 |
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
| 009 | Boss Phase Transition Signal Contract | Integration | Complete | ADR-0002 |
| 010 | Boss Phase Visual Feedback | Visual/Feel | Complete | ADR-0002 |
| 011 | Colorblind Combat VFX + Focus Shake Accessibility | Accessibility/Integration | Complete | ADR-0002 |
| 012 | Particle Budget + Performance Guardrails | Logic/Performance | Complete | ADR-0002 |
| 013 | Weapon Style VFX Variants | Visual/Feel | Complete | ADR-0002, ADR-0016 |
| 014 | Rat King Boss Frame Animation Slice | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 015 | Rat King Specialized Attack Animation Expansion | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 016 | Perfect Parry Gold Afterimage Feedback | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 017 | Rat King Victory Death Presentation Hold | Integration/Visual | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 018 | Echo Guardian Death Presentation Hold | Integration/Visual | Complete | ADR-0002, ADR-0005, ADR-0007, ADR-0018 |
| 019 | Boss Phase Overlay Readability | Visual/Feel | Complete | ADR-0001, ADR-0002 |

## Definition of Done

This epic is complete when:
- Hit, crit, kill, parry, dodge, weapon trail, boss phase, and damage-number
  feedback all satisfy `design/gdd/combat-presentation.md` acceptance criteria.
- Combat VFX are generated/imported through the project asset pipeline rather
  than represented by prototype ColorRect blocks.
- Runtime evidence is captured through Godot MCP when available.
- Particle counts and lifetimes stay within the GDD performance budget.

## Completion Evidence

Combat Presentation has all 19 tracked stories complete. Story014 adds the
first Rat King boss frame-animation asset slice so the MVP boss no longer exists
only as data. Story015 adds data-aligned specialized Rat King attack animations
for `charge`, `claw_swipe`, `summon_minion`, `slam`, and `berserk_combo`.
Story016 closes the remaining GDD perfect-parry afterimage gap with one
current-frame cat-eye-gold silhouette driven by the real Main parry event.
Story017 preserves the Rat King's existing three-frame death payoff for the
Boss GDD's `3.0s` presentation window before revealing the reward menu, while
keeping reward persistence immediate and duplicate defeat/death requests inert.
Story018 keeps Echo Guardian's existing three-frame `death` animation visible
for `2.0s`, holds its camera and room seals, and delays the Double Jump payoff
until the presentation completes without replaying the transient hold on load.
Story019 replaces the runtime Boss phase image with a center-clear generated
edge frame, fades the single overlay in `0.40s`, keeps the existing 32 debris
pieces for `1.50s`, and preserves the HUD above the effect without changing Boss
phase logic. Its repaired full-rect layout uses zero offsets, so the runtime
rect, texture and viewport all remain `1280x720` without edge cropping.
Evidence is recorded in
`production/qa/evidence/rat-king-boss-frame-animation-2026-06-25.md` and
`production/qa/evidence/rat-king-specialized-attack-animation-2026-06-25.md`,
plus Story016 evidence in
`production/qa/evidence/main-scene-perfect-parry-gold-afterimage-2026-07-14.md`
and
`production/qa/evidence/rat-king-victory-death-presentation-hold-2026-07-14.md`.
Story018 evidence is recorded in
`production/qa/evidence/echo-guardian-death-presentation-hold-2026-07-14.md`.
Story019 evidence is recorded in
`production/qa/evidence/boss-phase-overlay-readability-2026-07-14.md`.
