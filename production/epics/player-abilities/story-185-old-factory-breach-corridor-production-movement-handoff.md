# Story 185: Old Factory Breach Corridor Production Movement Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Movement
> **Type**: Integration + Gameplay Runtime + Production Movement + Visual Readability
> **Estimate**: S
> **Manifest Version**: 2026-07-20
> **Last Updated**: 2026-07-20

## Context

Story061 implemented the complete Breach Corridor ambush behind the opened
Lower Deck deep bulkhead, but production `_process()` never called its front
guard or rear pincer activation APIs. Tests and MCP probes could start both
stages directly while normal player movement skipped the required encounter.
The same live audit also showed the active characters and steam hazard rendered
behind overlapping `z=24` bulkhead/lift visuals. This Story connects the
existing combat contract to real movement and restores player-visible layering.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/scene-management.md`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0005 Combat State
Machine; ADR-0006 AI Framework; ADR-0007 Scene Management; ADR-0018 Player
Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] With the deep bulkhead opened, production `_process()` keeps the breach
  inactive below `x=1256`, then calls the existing front activation API when
  Cinderpaw reaches the boundary.
- [x] Front activation reveals entity `2115`, assigns Cinderpaw as target,
  enables processing and the animated steam hazard, and exposes
  `Clear Breach Corridor Ambush` without a direct activation call from tests.
- [x] Production `_process()` calls the front stage before the rear stage, so
  reaching `x=1264` activates entity `2116` and exposes
  `Survive Breach Pincer`; a single frame that crosses both boundaries retains
  the same front-before-rear order.
- [x] Cinderpaw, both breach Spark Rats and the breach steam hazard render
  above the overlapping bulkhead/lift visuals while endpoint prompt text stays
  above the combat layer.
- [x] The service lift remains optional and unchanged: available, not
  activated, no exit requested and prompt `Call lift`.
- [x] Existing Story060/061 state, combat, defeat, objective, persistence and
  SpriteFrames contracts remain unchanged.
- [x] Thin RED/GREEN, bounded related regressions, a 180-frame Factory smoke
  and one Godot MCP 3.0.4 runtime pass complete under Godot 4.7 with clean
  project logs and a non-empty inspected screenshot.

## Out Of Scope

Earlier Lower Deck guard production handoffs, post-relay trial/reward/hatch
handoffs, new enemy families, combat balance, damage/timing changes, service
lift routing, SaveSystem schema changes, new visual assets and Story181's
pressure-valve animation.

## Implementation Notes

- Production `_process()` calls
  `try_activate_factory_lower_deck_breach_corridor_ambush(_player)` and then
  `try_activate_factory_lower_deck_breach_rear_ambusher(_player)` immediately
  after the existing Lower Deck skirmish handoff and before forward-pressure
  content.
- The existing APIs continue to own prerequisites, inclusive boundary checks,
  state synchronization, target assignment, pacing and objective refresh.
- The scene uses combat layer `z=26` for Cinderpaw and the two breach Spark
  Rats, and `z=25` for the breach steam hazard. Existing endpoint roots remain
  `z=24`; their child prompt labels retain effective layer `z=28`.

## Asset Use

No new asset was required. The Story reuses the image-generated post-bulkhead
backdrop, both existing Factory Spark Rat `AnimatedSprite2D + SpriteFrames`
instances with six three-frame animations, and the existing four-frame active
steam animation. Existing source and import records remain authoritative.

## Verification Evidence

- Canonical movement RED: `reports/report_2083/report_1/results.xml` recorded
  one expected failure at the missing production front activation.
- Rendering RED: `reports/report_2086/report_1/results.xml` recorded one
  expected `Player z=20` versus endpoint `z=24` failure.
- Focused GREEN: `reports/report_2087/report_1/results.xml` passed `2/2`.
- Related GREEN: `reports/report_2088/report_1/results.xml` passed four suites
  at `8/8`, with zero failures, errors, flaky cases, skips or orphans.
- Godot 4.7 loaded `factory_route_transition_shell.tscn` headlessly for `180`
  frames and exited `0`; the log contains no project parse, script, invalid-call
  or missing-resource error.
- Godot AI MCP 3.0.4 run `r17664088-14` proved the production movement stages,
  frame contracts, visible layering, service-lift invariants and clean logs.
  The accepted screenshot is
  `reports/visual/cinderpaw-mcp-old-factory-breach-corridor-production-movement-handoff-20260720.png`.
- Full evidence:
  `production/qa/evidence/old-factory-breach-corridor-production-movement-handoff-2026-07-20.md`.

**Status**: [x] Complete.
