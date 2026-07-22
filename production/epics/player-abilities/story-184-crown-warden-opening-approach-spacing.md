# Story 184: Crown Warden Opening Approach Spacing

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Boss Combat
> **Type**: AI State + ACT Pacing + Existing Frame Animation
> **Estimate**: S
> **Manifest Version**: 2026-07-20
> **Last Updated**: 2026-07-20

## Context

The Crown Warden begins at `(900, 540)` while Cinderpaw enters at `(220, 536)`,
an opening horizontal gap of about `680px`. Its existing autonomous approach
only runs while attack cooldown is positive, so a fresh encounter with zero
cooldown starts `talon_dive` from far outside the authored `190px` commit
distance. The final Boss visibly attacks empty space before it begins closing
distance. This Story applies the AI Framework's `IDLE -> CHASE/APPROACH ->
ATTACK` rule to the opening and reuses the existing generated `run` frames.

**GDD**: `design/gdd/ai-framework.md`, `design/gdd/boss-config.md`,
`design/gdd/feline-combat.md`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0005 Combat State
Machine; ADR-0006 AI Framework.

## Acceptance Criteria

- [x] A valid target farther than `190px` moves a fresh autonomous Crown
  Warden into `APPROACH` instead of starting its first attack.
- [x] Approach faces and moves toward Cinderpaw within `320..1160`, plays the
  existing three-frame `run` `AnimatedSprite2D` animation and exposes distance,
  velocity and commit-range diagnostics.
- [x] Entering `190px` with cooldown ready starts the existing next attack at
  startup with its tell animation and no active hitbox.
- [x] Existing post-attack cooldown approach remains valid; arriving during
  cooldown waits without attacking until the timer expires.
- [x] Target loss, hit, phase transition, death, reset, progress restore and
  disabling autonomous attacks clear approach velocity.
- [x] Explicit pattern requests still bypass autonomous spacing for focused
  tests and scripted probes; attack timing, damage, alternation, phase, retry,
  reward and persistence contracts remain unchanged.
- [x] One thin RED/GREEN, the smallest related Boss4 regression, a bounded
  arena headless smoke and one Godot MCP 3.0.4 runtime pass complete under
  Godot 4.7 with clean logs and a non-empty screenshot.

## Out Of Scope

New attacks, pathfinding, navigation meshes, line-of-sight changes, arena
geometry, attack damage/timing changes, phase redesign, new assets, audio,
reward, save schema or shared AI-framework refactoring.

## TDD Evidence

- Canonical RED `reports/report_2080/results.xml` ran one case and produced
  exactly one expected failure: the `680px` opening entered attack startup
  instead of `run/approach`. It had zero parse errors, flaky cases, skips or
  orphans.
- Focused GREEN `reports/report_2081/results.xml` passed `1/1` with all
  failure/error counters at zero.
- Related GREEN `reports/report_2082/results.xml` passed Story184 plus the
  complete Story146 Boss4 core suite at `7/7`, with zero failures, errors,
  flaky cases, skips or orphans.
- Godot 4.7 loaded `crown_warden_arena.tscn` headlessly for `180` frames and
  exited `0` without parse, script, invalid-call or missing-resource errors.
- Godot AI MCP 3.0.4 run `r15342595-12` proved the authored opening enters
  `approach` with `run`, `-120px/s`, `678px` remaining distance and no attack
  hitbox; its game/editor logs were clean and the screenshot was non-empty.
- QA details:
  `production/qa/evidence/crown-warden-opening-approach-spacing-2026-07-20.md`.

**Status**: [x] Complete.
