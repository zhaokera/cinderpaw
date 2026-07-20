# Story 178: Rat King Committed Charge Locomotion

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Boss Combat
> **Type**: Attack Pattern + Collision + Data Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-20

## Context

Rat King already owned image-generated multi-frame `charge` animation, attack
timing, damage and hitbox data, but every active attack forced horizontal
velocity to zero. The production Main opening places Cinderpaw and Rat King
about `260px` apart while normal attack acquisition stopped at `110px`, so the
Boss could remain visually present without closing space or starting Phase-I
combat.

**GDD**: `design/gdd/boss-config.md`, `design/gdd/combat-presentation.md`,
`design/gdd/feline-combat.md`.

**Governing ADRs**: ADR-0002 Game Loop; ADR-0003 Data Registry; ADR-0004
Collision Detection; ADR-0005 Combat State Machine; ADR-0006 AI Framework;
ADR-0018 Player Abilities.

## Acceptance Criteria

- [x] At the authored `260px` Main opening distance, an idle Phase-I Rat King
  selects `charge` as a gap closer instead of remaining inert.
- [x] The existing `20` startup frames lock the facing direction; moving the
  target behind the Boss during startup does not retarget the active lunge.
- [x] During the existing `8` active frames, Rat King moves at the data-driven
  `720px/s` speed, for up to `96px` on an unobstructed 60 Hz simulation.
- [x] Horizontal collision stops the lunge without disabling the existing
  `rat_king_charge` hitbox, damage timing or animation.
- [x] Recovery, completion, death, respawn restore, progress defeat and phase
  transition all clear active charge motion.
- [x] Non-charge patterns preserve their previous stationary attack behavior,
  and phases that do not list `charge` never acquire it as a gap closer.
- [x] One intentional RED, focused GREEN, bounded related regression, headless
  Main smoke and Godot 4.7 + MCP 3.0.2 runtime acceptance provide evidence.

## Out Of Scope

- No changes to `charge` damage, startup/active/recovery timing, hitbox geometry,
  Boss HP, phase thresholds, rewards or save schema.
- No new attack pattern, scene node, collision geometry, camera behavior, audio,
  VFX or UI.
- No new visual asset or image-generation work. The existing image-generated
  Rat King `charge` SpriteFrames remain the player-visible presentation.

## Implementation Notes

- `enemy_stats.json` now keeps charge locomotion beside the existing pattern
  contract through `lunge_speed=720` and `attack_range_px=320`.
- `RatKingBoss` loads those values through `DataManager`, chooses `charge` only
  while idle and within the authored vertical band, then commits to the facing
  captured at attack startup.
- Active frames use `CharacterBody2D.move_and_slide()`, retain gravity, measure
  actual horizontal travel and stop on a horizontal slide collision.
- Bounded diagnostics expose loaded configuration, locked direction, distance,
  collision count, stop reason and current velocity for tests and MCP probes.

## Test Evidence

- Intentional RED `reports/report_2047/results.xml`: the focused test recorded
  four expected failures because distant auto-acquisition, active displacement,
  horizontal velocity and charge diagnostics did not exist.
- Focused GREEN `reports/report_2048/results.xml`: Story178 passed `1/1` with
  zero failures, errors or orphans.
- Related GREEN `reports/report_2049/results.xml`: Story178 plus Rat King runtime,
  specialized animation and Phase-I intro suites passed `15/15`, with zero
  failures, errors, flaky cases, skips or orphans.
- Fresh pre-push gate `reports/report_2050/results.xml` repeated the same four
  suites at `15/15`, with zero failures, errors, flaky cases, skips or orphans.
- Godot 4.7 Main headless smoke ran for `180` frames and exited `0`. It emitted
  only the existing shutdown cleanup diagnostic for two ObjectDB instances and
  one retained resource; no parse, script or runtime gameplay error appeared.
- Godot MCP accepted run `r367146508-130` loaded Main, observed natural Rat King
  gap-closing, then deterministically proved locked-left `charge` movement,
  `720px/s` velocity, active `rat_king_charge` hitbox and the existing charge
  animation. Game/editor logs contained no project errors.
- The non-empty `1278x718` screenshot is stored at
  `reports/visual/cinderpaw-mcp-rat-king-committed-charge-locomotion-20260720.png`.
- Full traceability is recorded in
  `production/qa/evidence/rat-king-committed-charge-locomotion-2026-07-20.md`.

## Completion Notes

- Completed 2026-07-20 as a bounded Boss locomotion slice that reuses authored
  combat timing and existing generated frame animation.
- The complete-game goal remains active. The next functional slice should wire
  the Lower Deck reward cache to production `interact`; Boss3 retry pacing and
  the obscured pressure-valve presentation remain separate Stories.
