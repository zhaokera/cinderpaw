# Epic: Combat Presentation

> **Layer**: Presentation
> **GDD**: design/gdd/combat-presentation.md
> **Architecture Module**: CombatPresentation
> **Status**: In Progress
> **Stories**: 35 stories tracked

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
| TR-combatfx-004 | Dodge, dash, and perfect parry support afterimage feedback modes. | ADR-0002, Story004, Story016, Story031 |
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
| 020 | Cat Claw Combo Finisher Impact Feedback | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0016 |
| 021 | Main Scene Real Hitstop + Input Buffer | Feel/Runtime | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 022 | Reusable Hitstop Input Bridge + Crown Warden Arena | Integration/Feel | Complete | ADR-0001, ADR-0002, ADR-0004, ADR-0005 |
| 023 | Sluice Matriarch Arena Real Hitstop + Input Buffer | Integration/Feel | Complete | ADR-0001, ADR-0002, ADR-0004, ADR-0005 |
| 024 | Central Tower Real Hitstop + Input Buffer | Integration/Feel | Complete | ADR-0001, ADR-0002, ADR-0004, ADR-0005 |
| 025 | Crown Warden Victory Death Presentation Hold | Integration/Visual | Complete | ADR-0001, ADR-0002, ADR-0004, ADR-0005 |
| 026 | Neon Rooftops Combat Impact | Integration/Feel | Complete | ADR-0001, ADR-0002, ADR-0004, ADR-0005 |
| 027 | Underground Passage Combat Impact | Integration/Feel | Complete | ADR-0001, ADR-0002, ADR-0004, ADR-0005 |
| 028 | Old Factory Spark Rat Combat Impact | Integration/Feel | Complete | ADR-0001, ADR-0002, ADR-0004, ADR-0005 |
| 029 | Cinderpaw Air Animation Identity Consistency | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 030 | Cinderpaw Dedicated Dash Animation Identity | Visual/Feel | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 031 | Cinderpaw Dash Afterimage, Speed-Line, and Wind Feedback | Visual/Feel/Audio | Complete | ADR-0001, ADR-0002, ADR-0005 |
| 032 | Rat Minion Attack Tell Frame Animation | Visual/Feel + Frame Animation Contract | Complete | ADR-0001, ADR-0002, ADR-0004, ADR-0005, ADR-0006 |
| 033 | Old Factory Steam Vent Motion Readability | Visual/Feel + Hazard Telegraph Contract | Complete | ADR-0002, ADR-0004, ADR-0010, ADR-0018 |
| 034 | Old Factory Environment Cohesion | Visual/Environment Cohesion Contract | Complete | ADR-0004, ADR-0010, ADR-0018 |
| 035 | Rat King Phase-I Authored Intro Frames | Visual/Frame Animation | Complete | ADR-0005, ADR-0010, ADR-0011 |

## Definition of Done

This epic is complete when:
- Hit, crit, kill, parry, dodge, weapon trail, boss phase, and damage-number
  feedback all satisfy `design/gdd/combat-presentation.md` acceptance criteria.
- Combat VFX are generated/imported through the project asset pipeline rather
  than represented by prototype ColorRect blocks.
- Runtime evidence is captured through Godot MCP when available.
- Particle counts and lifetimes stay within the GDD performance budget.

## Completion Evidence

Combat Presentation has all 35 tracked stories complete, but the Epic remains
In Progress until the Main-scene real hitstop/input handoff is extended to
independent player-facing combat scenes. Story014 adds the
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
Story020 consumes the already-authored Cat Claw third-hit metadata to produce
the GDD finisher profile: five feedback frames, `4px/5-frame` shake, one gold
`28px` damage number, one gold `终结` label, and existing hit sparks at `1.5x`
scale while preserving damage, cat energy, combo timing and critical priority.
Story021 turns Main's hitstop counter into an exact gameplay pause, keeps
InputManager alive to buffer one trigger action, restores the prior pause/input
state, and advances the real Core attack chain exactly once after the freeze.
Story022 extracts that handoff into a reusable scene node, integrates Crown
Warden Arena in both real collision directions, records actual applied damage,
and suppresses ordinary feedback for rejected dodge damage. Main and Crown now
share the same single-dispatch contract. Story023 applies that contract to
Sluice Matriarch Arena in both real collision directions, preserves rejected
dodge and dedicated PERFECT-parry behavior, and verifies all six existing Boss3
animations as three-frame SpriteFrames. Story024 extends the same shared
contract across Central Tower's Threshold Guard, Relay Mantis, and
Counterweight Sentry encounters. It verifies real player/Guard damage in both
directions, one buffered dispatch, dodge/respawn rejection, dedicated PERFECT
parry, and existing three-frame character animation without changing encounter
rules or adding assets. Story025 keeps Crown Warden's existing three-frame
death animation visible for `2.0s`, commits durable defeat immediately, holds
player/room/scene locks through the kill feedback, and delays Wall Climb reward
and return-route release without replaying transient state on load. Story026
extends the shared runtime contract to Neon Rooftops: real Cat Claw and Signal
Rat hits, lethal feedback, Tower laser PERFECT parry, one buffered dispatch,
and cached-scene bridge reconnection all use the scene-mounted presentation
owner without changing encounter rules or assets. Story027 extends the same
contract to Underground Passage: real Cat Claw, both Sluice Leech, and Cistern
Stalker hits share one presentation owner; PERFECT parry keeps its dedicated
feedback; lethal Stalker feedback remains one-shot; and cached reentry remains
valid after a defeated Leech is freed. Story028 extends the same runtime owner
to Old Factory, verifies the real Spark Rat bite and Cat Claw dodge-counter,
preserves dedicated PERFECT-parry and one-shot lethal feedback, and connects
the shared Factory enemy landed-hit path without changing encounter balance.
Story029 replaces the six blue-cloak, soft-edge jump/fall frames with
reference-guided hard-edge Cinderpaw pixel art while preserving the existing
SpriteFrames paths, air-state selection, and gameplay rules.
Story030 replaces Dash's three pixel-identical Dodge copies with dedicated
launch, maximum-speed, and carry-through poses while preserving the existing
SpriteFrames paths and ability rules. Story031 then separates Main's Dash from
Dodge presentation with two `20px/40px` cool-white afterimages, one generated
directional speed-line burst, and an imported `sfx_dash` cue while preserving
the existing `620 px/s` movement, cooldown and three-image Dodge behavior.
Other independently mounted
player-facing combat scenes remain follow-up coverage before Epic completion.
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
Story020 evidence is recorded in
`production/qa/evidence/cat-claw-combo-finisher-impact-feedback-2026-07-15.md`.
Story021 evidence is recorded in
`production/qa/evidence/main-scene-real-hitstop-input-buffer-2026-07-15.md`.
Story022 evidence is recorded in
`production/qa/evidence/crown-warden-real-hitstop-input-buffer-2026-07-15.md`.
Story023 evidence is recorded in
`production/qa/evidence/sluice-matriarch-real-hitstop-input-buffer-2026-07-15.md`.
Story024 evidence is recorded in
`production/qa/evidence/central-tower-real-hitstop-input-buffer-2026-07-15.md`.
Story025 evidence is recorded in
`production/qa/evidence/crown-warden-victory-death-presentation-hold-2026-07-15.md`.
Story026 evidence is recorded in
`production/qa/evidence/neon-rooftops-combat-impact-2026-07-15.md`.
Story027 evidence is recorded in
`production/qa/evidence/underground-passage-combat-impact-2026-07-15.md`.
Story028 evidence is recorded in
`production/qa/evidence/old-factory-spark-rat-combat-impact-2026-07-15.md`.
Story029 evidence is recorded in
`production/qa/evidence/cinderpaw-air-animation-identity-consistency-2026-07-15.md`.
Story030 evidence is recorded in
`production/qa/evidence/cinderpaw-dedicated-dash-animation-identity-2026-07-16.md`.
Story031 evidence is recorded in
`production/qa/evidence/cinderpaw-dash-afterimage-speed-line-wind-feedback-2026-07-16.md`.
Story032 separates the Rat Minion's seven-frame bite startup from its active
attack with three reference-guided generated anticipation frames while
preserving hitbox, damage, AI and summon contracts. Evidence is recorded in
`production/qa/evidence/rat-minion-attack-tell-frame-animation-2026-07-16.md`.
Story033 replaces the Old Factory's static steam-vent read with shared
four-frame `safe`, `warning`, and `active` loops across all twenty-six hazard
instances. It forwards eleven existing gameplay phase clocks into presentation
without changing damage, collision, phase timing or encounter rules. Evidence
is recorded in
`production/qa/evidence/old-factory-steam-vent-motion-readability-2026-07-16.md`.
Story034 replaces the Old Factory route's player-visible stretched color bands
with four image-generated `1280x720` assembly, furnace, condenser and tailrace
identities. Twenty-four unscaled Sprite2D plates cover the complete `30080px`
route without changing foreground collision, encounters, hazards or save state.
Evidence is recorded in
`production/qa/evidence/old-factory-environment-cohesion-2026-07-17.md`.
Story035 replaces the Rat King's idle-identical three-frame `phase_1_intro`
with an image-generated crouch, red-core ignition and forward-threat sequence.
The three transparent `192x192` frames retain one baseline, unique hashes and
the existing SpriteFrames path/state without changing Boss gameplay or adding
the still-separate production activation flow. Evidence is recorded in
`production/qa/evidence/rat-king-phase-one-authored-intro-2026-07-18.md`.
