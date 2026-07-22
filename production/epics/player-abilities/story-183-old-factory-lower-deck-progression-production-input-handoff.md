# Story 183: Old Factory Lower Deck Progression Production-Input Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Old Factory
> **Type**: Integration + Gameplay Runtime + Production Input
> **Estimate**: S
> **Manifest Version**: 2026-07-20
> **Last Updated**: 2026-07-20

## Context

Stories058-060 implemented the Lower Deck pressure valve, steam sluice and deep
bulkhead contracts, but the production `interact` rising edge never called
their public activation methods. Tests could advance the route through direct
APIs while a player could not. This Story connects the existing endpoints to
the production input loop without changing their guards, ranges, persistence,
combat or presentation behavior.

**GDD**: `design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Governing Architecture**: `docs/architecture/architecture.md`, ADR-0004
Collision Detection, ADR-0007 Scene Management,
`docs/architecture/control-manifest.md`

## Acceptance Criteria

- [x] A real `interact` rising edge opens the ready pressure valve through
  `try_open_factory_lower_deck_pressure_valve` and preserves Story058's guard,
  `96px` radius, endpoint id and state keys.
- [x] After the valve opens, a new rising edge activates the steam sluice
  through its existing one-way activation boundary and preserves Story059's
  combat, entity and persistence contract.
- [x] After the steam sluice and deep-bulkhead guard clear, a new rising edge
  opens the deep bulkhead through its existing endpoint contract.
- [x] Holding `interact` does not repeat activation. If multiple progression
  endpoints are simultaneously ready and in range, only the nearest is called;
  exact-distance ties keep deterministic Story058-to-Story060 order.
- [x] Existing priority remains Factory cache, deep-route endpoint, nearest
  available reward cache, nearest Lower Deck progression endpoint, then service
  lift. One rising edge cannot both progress the route and activate the lift.
- [x] Focused and smallest related GdUnit suites pass under Godot 4.7, and one
  Godot MCP 3.0.4 production-scene run has clean current-run logs and a
  non-empty inspected screenshot.

## Out Of Scope

New endpoint visuals, image generation, interaction ranges, guard AI, combat
balance, route objectives, reward values, save schema, service-lift behavior,
input bindings, scene geometry or shared interaction-system refactoring.

## TDD Evidence

- Intentional RED in the isolated implementation workstream exited `100`: real
  `Input.action_press("interact")` plus production `_process` left the valve,
  sluice and bulkhead unopened because no production route called their APIs.
- Focused integration GREEN `reports/report_2077/results.xml` passed `2/2`,
  covering the full valve-to-sluice-to-bulkhead chain, held-input suppression,
  nearest-overlap selection and one action per rising edge.
- Related GREEN `reports/report_2079/results.xml` passed six suites at `13/13`:
  Story183 handoff, Stories058-060, Lower Deck reward-cache input and
  reward-before-lift priority. Failures, errors, flaky cases, skips and orphans
  were all zero.
- Godot AI MCP 3.0.4 run `r13170960-9` loaded the production Factory scene,
  found the player plus valve, steam-sluice, deep-bulkhead and service-lift
  runtime nodes, produced an inspected non-empty screenshot, and returned
  helper-info-only game logs plus zero editor errors.
- QA details:
  `production/qa/evidence/old-factory-lower-deck-progression-production-input-handoff-2026-07-20.md`.

**Status**: [x] Complete.
