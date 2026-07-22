# Story 182: Sluice Matriarch Chase Spacing

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Boss Combat
> **Type**: AI State + ACT Pacing + Existing Frame Animation
> **Estimate**: S
> **Manifest Version**: 2026-07-20
> **Last Updated**: 2026-07-20

## Context

The playable Sluice Matriarch owns a generated three-frame `run` animation,
but its runtime currently attacks from any target distance and never enters the
AI Framework's `CHASE` behavior. At the authored `670px` opening gap this makes
the boss alternate stationary attacks instead of deliberately closing space.
This Story adds a bounded chase-to-commit loop without changing the established
lunge, geyser, phase, retry, reward or persistence contracts.

**GDD**: `design/gdd/ai-framework.md`, `design/gdd/feline-combat.md`,
`design/gdd/boss-config.md`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0005 Combat State
Machine; ADR-0006 AI Framework.

## Acceptance Criteria

- [x] A valid target farther than `300px` moves the active Matriarch into a
  `CHASE` behavior instead of starting an attack from idle.
- [x] Chase faces and moves toward Cinderpaw within the arena bounds, uses the
  existing `run` `AnimatedSprite2D` animation, and exposes deterministic
  diagnostics for state, distance, velocity and phase speed.
- [x] Reaching the `300px` commit distance starts the existing next attack at
  startup with no active hitbox; explicit pattern requests remain available for
  deterministic tests and MCP probes.
- [x] Phase II chases faster than Phase I while lunge/geyser timing, damage,
  strict alternation and cooldown values remain unchanged.
- [x] Target loss, death, progress-defeated restore, phase transition and retry
  clear chase velocity and cannot leave the boss moving or damaging Cinderpaw.
- [x] One focused RED/GREEN, the smallest related Boss3 regression, a bounded
  arena headless smoke and one Godot MCP 3.0.4 runtime pass complete under
  Godot 4.7 with clean current-run logs and a non-empty screenshot.

## Out Of Scope

New attacks, Phase III, pathfinding, navigation meshes, line-of-sight changes,
arena geometry, player abilities, damage balance, new assets, audio, reward,
route, save schema or shared AI-framework refactoring.

## TDD Evidence

- Exploratory `reports/report_2072/results.xml` was superseded because its two
  missing-API assertions duplicated the same absent chase surface.
- Canonical RED `reports/report_2073/results.xml` ran one case with exactly one
  expected missing chase-API failure and zero parse errors, flaky cases, skips
  or orphans.
- Focused GREEN `reports/report_2075/results.xml` and final pre-completion
  `reports/report_2078/results.xml` each passed `1/1`, including the Phase II
  speed assertion, with zero failures, errors, flaky cases, skips or orphans.
- Related GREEN `reports/report_2076/results.xml` passed five Boss3 suites at
  `7/7`, covering chase, core attacks, pressure geyser, phase transition and
  shared death/retry with all failure/error counters at zero.
- Godot 4.7 loaded `sluice_matriarch_arena.tscn` headlessly for `180` frames
  and exited `0` without parse, script, invalid-call or missing-resource errors.
- Godot AI MCP 3.0.4 run `r12135259-8` loaded the disk scene, exposed the player
  and Boss `AnimatedSprite2D` nodes, produced the inspected non-empty screenshot
  `reports/visual/cinderpaw-mcp-sluice-matriarch-chase-spacing-20260720.png`,
  and returned helper-info-only game logs plus zero editor errors.
- QA details: `production/qa/evidence/sluice-matriarch-chase-spacing-2026-07-20.md`.

**Status**: [x] Complete.
