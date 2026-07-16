# Quick Design Spec: Rat Minion Attack Tell Frame Animation

> **Date**: 2026-07-16
> **Story target**: Combat Presentation 032
> **Status**: Approved by active-goal standing direction
> **Scope**: split Rat Minion bite startup from its active attack animation

## Decision

Add one dedicated non-looping, three-frame `attack_tell` animation to the
existing Rat Minion `AnimatedSprite2D + SpriteFrames` resource. The seven-frame
bite startup uses this anticipation sequence; the four-frame active window
continues to use the existing `attack` animation.

## Stable Gameplay Contract

| Contract | Preserved value |
|----------|-----------------|
| Startup | `7` frames |
| Active | `4` frames |
| Recovery | `12` frames |
| Cooldown | `28` frames |
| Damage | `8` |
| Hitbox | `rat_minion_bite`, `38x22`, offset `(30,-24)` |
| Runtime scene | `src/gameplay/rat_minion.tscn` |

## Visual Contract

- Generate one reference-guided horizontal strip on a removable magenta key.
- Produce three transparent `96x96` frames under
  `assets/characters/rat_minion/attack_tell/` with continuous names.
- Keep the existing Rat Minion identity, right-facing direction, scale and
  common `y=91` ground baseline.
- Poses progress from low guarded crouch, through body compression and tail
  coil, to maximum pre-lunge tension. None may show attack contact or travel.

## Out Of Scope

- AI range, scheduling, damage, collision, summon cap, cleanup or balance.
- Replacing the existing `attack`, `idle`, `run`, `hurt` or `death` frames.
- Changing Factory Spark Rat's independent 12-frame attack-tell override.

## Acceptance

- [x] `attack_tell` contains three imported transparent `96x96` frames and is
  non-looping.
- [x] `request_attack()` selects `attack_tell` with the bite hitbox disabled.
- [x] Advancing exactly seven frames selects `attack` and activates the
  unchanged bite hitbox/damage contract.
- [x] Rat King summon and Factory Spark Rat related regressions remain green.
- [x] Godot MCP shows the real summoned minion in `attack_tell`, then proves
  the active transition, clean logs and a non-empty screenshot.
