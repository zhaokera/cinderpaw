# Story 187: Old Factory Post-Relay Production Movement Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Movement
> **Type**: Integration + Gameplay Runtime + Production Movement + Visual Readability
> **Estimate**: S
> **Manifest Version**: 2026-07-20
> **Last Updated**: 2026-07-20

## Context

Story065 implemented the Lower Deck relay-forward combat trial, but normal
Factory movement never called its existing activation API. A valid player
could secure the breach relay and walk beyond the authored `x=1232` boundary
while entity `2117`, its steam hazard and the combat objective remained
inactive. Runtime review also found that the Spark Rat and steam hazard were
layered below the relay and service-lift art.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/scene-management.md`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0005 Combat State
Machine; ADR-0006 AI Framework; ADR-0007 Scene Management; ADR-0018 Player
Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] With the breach relay secured, production `_process()` keeps the
  post-relay trial inactive at `x=1231` and activates it at the inclusive
  `x=1232` boundary without a direct activation call from the test.
- [x] Activation reveals entity `2117`, assigns Cinderpaw as target, enables
  processing/physics and starts the existing 18-frame opening grace.
- [x] The Spark Rat exposes `idle`, `run`, `attack_tell`, `attack`, `hurt` and
  `death` through `AnimatedSprite2D + SpriteFrames`, with at least three frames
  per animation.
- [x] The existing post-relay steam hazard becomes active and visible with ID
  `old_factory_lower_deck_post_relay_trial`, `8` contact damage, `1.0s`
  cooldown and its four-frame active steam animation playing.
- [x] The route objective changes from `Lower Deck Relay Secured` to
  `Clear Relay Forward Trial`.
- [x] Story066's reward cache and forward hatch remain hidden and unavailable
  until the combat trial is cleared. The optional service lift remains
  available, unactivated and reports `Call lift` without an exit request.
- [x] Cinderpaw and the Spark Rat render at `z=26`; the steam effect renders
  effectively at `z=26`; relay and lift art remain at `z=24`.
- [x] Thin RED/GREEN, bounded related regressions, a 180-frame Factory smoke
  and one Godot MCP 3.0.4 real-input pass complete under Godot 4.7 with clean
  project logs and a non-empty inspected screenshot.

## Out Of Scope

Story066 reward-cache or forward-hatch production input, enemy spawn/timing or
damage rebalance, new enemy families, service-lift routing, save-schema changes,
new visual assets and Story181's authored pressure-valve animation.

## Implementation Notes

- Factory production `_process()` now calls the existing Story065 post-relay
  activation API after the breach rear handoff and before later forward-route
  pressure content.
- The existing Story065 API remains authoritative for prerequisites, inclusive
  boundary handling, target assignment, pacing, hazard state, objective refresh
  and Story066 unlock gating.
- The Spark Rat layer is `z=26`. The steam-hazard root is `z=25` and its
  runtime-created `SteamAnimation` child is `z=1`, producing effective `z=26`
  without changing hazard behavior.
- Activation remains latched when the newly spawned enemy body pushes
  Cinderpaw back below the trigger boundary. The collision therefore forms the
  intended combat gate instead of permitting route bypass.

## Asset Use

No new image-generation request was needed. The Story reuses imported,
manifest-listed image-generated assets: the Factory Spark Rat six-state
SpriteFrames, Old Factory steam-vent SpriteFrames, service lift, breach relay
and environment. No placeholder rectangle, static character or new import was
added.

## Verification Evidence

- Canonical production RED: `reports/report_2100/report_1/results.xml` failed
  only because movement did not activate the post-relay trial.
- Layer RED after behavior wiring: `reports/report_2101/report_1/results.xml`
  reported exactly four expected enemy/hazard layer assertions.
- Focused GREEN: `reports/report_2102/report_1/results.xml` passed `1/1`.
- Final related GREEN: `reports/report_2103/results.xml` passed five suites at
  `11/11`, with zero failures, errors, flaky cases, skips or orphans.
- Godot 4.7 loaded the Factory scene for `180` fixed frames and exited `0` with
  no project parse, script, invalid-call/access or missing-resource error.
- Godot AI MCP 3.0.4 accepted clean run `r22399497-22`: after startup snap
  frames were consumed, real `move_right` input activated entity `2117`
  without calling its activation API. The authored steam contact dealt `8`
  damage and the player survived; the enemy body then formed a physical combat
  gate while activation remained latched.
- Accepted screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-post-relay-production-movement-handoff-20260720.png`.
- Full evidence:
  `production/qa/evidence/old-factory-post-relay-production-movement-handoff-2026-07-20.md`.

**Status**: [x] Complete.
