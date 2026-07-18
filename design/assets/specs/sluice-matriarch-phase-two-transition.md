# Asset Spec: Sluice Matriarch Phase II Transition

Date: 2026-07-18
Story: `production/epics/player-abilities/story-174-sluice-matriarch-phase-two-transition-readability.md`
Status: Implemented

## Role

The animation makes the Boss3 half-health rules change readable without
misusing a short hurt reaction or an attack tell. It occupies the full `2.5s`
invulnerable phase window while the existing overlay, debris, shake and audio
carry the arena-wide feedback.

## Contract

| Field | Value |
|-------|-------|
| Runtime type | Existing `AnimatedSprite2D + SpriteFrames` |
| Animation | `phase_transition` |
| Frame count | Exactly 3 |
| Runtime canvas | Transparent `192x192` sRGBA PNG |
| Playback | `6 FPS`, looping, five cycles over `2.5s` |
| Facing | Authored right-facing; runtime retains existing `flip_h` behavior |
| Anchor | Shared center pivot and bottom ground baseline |
| Directory | `assets/characters/sluice_matriarch/phase_transition/` |
| Naming | `sluice_matriarch_phase_transition_000.png` through `_002.png` |

## Readability

- Frame one compresses the planted body and starts the cyan pressure pulse.
- Frame two lifts the ceramic pressure plates and inflates pale pressure sacs.
- Frame three reaches full cyan-white pressure with clamps locked and no strike,
  projectile, geyser, movement translation, injury collapse, or death pose.
- Signal red remains a restrained identity accent. Active attack language stays
  owned by `attack_tell`, `attack`, `geyser_tell`, and `geyser_attack`.

## Pipeline

Generation prompt, identity reference, alpha process, normalization and hashes
are retained in
`assets/characters/sluice_matriarch/source/sluice_matriarch_phase_transition_sheet_imagegen_20260718.md`.

## Validation

- Three continuous unique frames, exact `192x192` dimensions and transparent
  corners.
- Runtime state reports `phase_transition`, animation loops visibly, Boss
  Hurtbox is `gone`, and every attack hitbox/VFX is inactive.
- At the `2.5s` boundary the existing idle animation resumes without changing
  Boss scale, pivot, facing, or baseline.
