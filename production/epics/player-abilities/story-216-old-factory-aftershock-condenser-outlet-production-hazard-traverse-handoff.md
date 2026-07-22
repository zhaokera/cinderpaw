# Story 216: Old Factory Aftershock Condenser Outlet Production Hazard Traverse Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Hazards
> **Type**: Integration + Production Movement + Hazard Timing + Route Handoff
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story215 activates the condenser savepoint and restores player control without
silently starting Story096. Story216 closes the next player-visible ACT beat:
Cinderpaw must enter the generated outlet through real movement, read and take
one production steam hit, cross the far edge, and reveal Story097 without
starting its Spark Rat ambush through a stale position or the crossing frame.

**GDD**: `design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-input-001`, `TR-collision-004`, `TR-scene-004`,
`TR-explore-005`

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0004
Collision detection; ADR-0007 Scene management. Story096/097 keep their
existing scene-local state contract without a SaveSystem schema change.

## Acceptance Criteria

- [x] With Story095 active, stationary frames and no-input threshold placement
  keep Story096 available/visible but idle; real `move_right` with positive x
  movement across x `4560.0` activates it once in `grace`.
- [x] Factory production `_process(delta)` advances the existing Story096 cycle
  exactly once per frame through `grace -> warning -> active -> safe` without
  changing the authored `0.25/0.35/0.40/0.45s` timings.
- [x] Only the active phase enables the real outlet `Area2D`; a player overlap
  applies one `8` damage steam hit with hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet`.
- [x] Real `move_right` traversal across x `5020.0` persists Story096 activated
  and crossed state, disables the hazard, and shows
  `Aftershock Condenser Outlet Crossed`.
- [x] Story097 becomes available and its clamp prop becomes visible after the
  crossing, but its entity `2138` remains hidden, untargeted and without
  process/physics until a later fresh positive-x `move_right` frame.
- [x] One canonical GdUnit RED/GREEN, bounded Story215/096 regression, Factory
  headless smoke and one Godot MCP runtime acceptance pass under Godot 4.7 /
  Godot AI MCP 3.0.4.

## Out of Scope

Starting, fighting or clearing Story097; Story098; new player/enemy moves; new
visual/audio assets; hazard balance changes; death/respawn retesting;
SaveSystem schema changes; full Factory replacement and full-suite testing.

## Asset Pipeline

No new asset is required. This Story reuses the registered image-generated
condenser outlet and steam vent plus Cinderpaw's existing
`AnimatedSprite2D + SpriteFrames` movement/hurt presentation.

## Test Evidence

- Canonical GdUnit:
  `tests/unit/gameplay/old_factory_aftershock_condenser_outlet_production_hazard_traverse_clamp_handoff_test.gd`
  - Initial RED: `reports/report_2308/results.xml` (`1` case, `9` expected
    failures proving production time was stuck in `grace`, real steam overlap
    could not damage, and Story097 accepted stale/no-input activation).
  - Focused GREEN: `reports/report_2310/results.xml` (`1/1`).
- Related regression:
  `reports/report_2312/results.xml` passed `4/4` across Story215, Story096 and
  Story216 with zero failure/error/flaky/skip/orphan. Story216's canonical
  directly covers the changed Story097 handoff boundary.
- Factory smoke:
  `reports/old_factory_aftershock_condenser_outlet_production_hazard_traverse_handoff_smoke.log`
  ran `180` fixed-FPS frames and exited `0`; no project parse/script,
  invalid-call/access or missing-resource error was found. Existing
  ObjectDB/resource cleanup lines remained stdout-only.
- Godot MCP: Godot AI MCP `3.0.4` on Godot `4.7`, session
  `cinderpaw@1b14`, accepted run `r153467824-10`, verified real movement from
  x `4548.0` to `4681.3384`, `idle/grace/warning/active`, real outlet overlap
  damage `100 -> 92` with steam metadata, continued real crossing, persisted
  Story096 state, disabled hazard contact, Story097 available/visible but
  inactive after a no-input x `5224.0` probe, released inputs, helper-only game
  log, empty editor log and a non-empty RGB `1278x718` active-steam screenshot:
  `reports/visual/cinderpaw-mcp-aftershock-condenser-outlet-production-hazard-traverse-active-20260722.png`
  (SHA-256
  `3df3002759b56a57318ef2b35376defb347cbd7a4b8a08992e8864ac9c87dbd8`).

## Dependencies

- Depends on: Story215 production savepoint/respawn handoff; Story096 outlet
  traverse; Story097 clamp ambush baseline.
- Unlocks: Story097 production movement/combat handoff.

## Verification Summary

The canonical RED isolated the missing production timer and stale downstream
activation. Focused GREEN passed `1/1`; bounded Story215/096/216 regression
passed `4/4`; Factory smoke exited `0`. The final MCP run completed the visible
movement, active steam hit and outlet crossing while preserving a clean
Story097 handoff. No new asset or full-suite run was needed.
