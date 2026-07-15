# Story 010: Grounded Heavy Charge Runtime

> **Epic**: Feline Combat
> **Status**: Complete
> **Layer**: Gameplay Runtime / Presentation / HUD
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/feline-combat.md`, `design/gdd/weapon-styles.md`

**Requirements**: `TR-combat-001`, `TR-combat-005`, `TR-combat-012`

**ADR Governing Implementation**: ADR-0002 signal communication; ADR-0004
collision detection; ADR-0005 combat state machine; ADR-0010 audio; ADR-0011
HUD focus; ADR-0016 weapon styles.

Story005 implemented deterministic heavy-charge logic in `CombatComponent`, but
the playable Cinderpaw never sends `heavy_attack` input into that path. There is
no charge presentation, charge HUD, released heavy hitbox, or runtime damage
handoff. This slice connects the existing Core contract to the live player so a
grounded heavy attack becomes a real ACT combat option.

## Acceptance Criteria

- [x] Pressing `heavy_attack` from grounded IDLE enters CHARGING, locks horizontal
  movement, plays the `heavy_charge` `AnimatedSprite2D` animation, applies an
  amber charge glow, and shows a 0-100% HUD charge bar.
- [x] Holding charge updates deterministic HUD and diagnostics state. Releasing
  before `0.5s` cancels safely; releasing from `0.5s` through `1.5s` activates
  one `<weapon>_heavy` Core hitbox; reaching `1.5s` auto-releases at full charge.
- [x] Heavy charge interpolates the authored damage multiplier from `1.2x` at
  minimum charge to `2.0x` at full charge and preserves charge seconds, ratio,
  multiplier, weapon, facing, attack type, and hitbox size in metadata.
- [x] Heavy release plays the `heavy_attack` animation, emits the existing
  weapon VFX/audio event with heavy metadata, hides the charge HUD, and requests
  a four-frame screen shake.
- [x] Dodge during charge cancels into DODGING without a heavy hitbox. Damage
  during charge forwards to Combat HIT_STUN, hides charge presentation, and
  does not release a heavy attack.
- [x] Full-charge Fish Bone hits use retained hit metadata for the existing
  shield-break contract after Combat has transitioned out of CHARGING.
- [x] `heavy_charge` and `heavy_attack` each contain at least three consistent,
  transparent PNG frames generated through image generation, stored under the
  required character animation paths and wired into `SpriteFrames`.
- [x] Focused GdUnit, minimum related combat/weapon regression, and Godot MCP
  runtime evidence verify input, HUD, animation, hitbox, damage metadata,
  cancellation, non-empty screenshot, and clean logs.

## Out of Scope

- Airborne `heavy_attack` dive behavior; the existing airborne light attack
  remains unchanged.
- Fish Bone T1-A knockback, other skill nodes, new weapon unlock rules, or a
  new heavy combo chain.
- A dedicated new heavy-attack audio asset. This slice reuses the current
  weapon attack SFX routing and records the reuse in evidence.
- Replacing existing weapon VFX textures. Heavy release amplifies the current
  weapon effect and camera response.

## Implementation Notes

- `CombatComponent` remains the authoritative timer/state owner. PlayerController
  owns input and character presentation, MainScene owns HUD/VFX/audio routing,
  and WeaponComponent owns the final hitbox.
- Normalize released charge for damage as
  `(charge_seconds - 0.5) / (1.5 - 0.5)`, then interpolate `1.2 -> 2.0`.
- Preserve charge metadata on the hit because a released attack has already
  left CHARGING when weapon post-hit effects run.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/player_grounded_heavy_charge_runtime_test.gd`
- Story005 heavy-charge Core regression
- Fish Bone charged shield-break regression
- One Godot MCP main-scene runtime acceptance

**Status**: [x] Complete.

- RED: `reports/report_1572/report_1/results.xml` failed at the missing runtime
  heavy contract before implementation.
- GREEN: `reports/report_1575/report_1/results.xml` passed `4/4` Story010 cases.
- Final focused HUD recheck: `reports/report_1577/report_1/results.xml` passed
  `26/26` cases after clearing MCP-reported naming warnings.
- Related regression: `reports/report_1576/report_1/results.xml` passed `42/42`
  combat, weapon, damage, player attack, and HUD cases.
- Runtime evidence:
  `production/qa/evidence/cinderpaw-grounded-heavy-charge-runtime-2026-07-14.md`.
