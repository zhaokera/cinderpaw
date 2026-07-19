# Story 177: Old Factory Lower Deck Skirmish Production-Input Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Input
> **Type**: Integration + Gameplay Runtime + Production Input
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-19

## Context

Story053 implemented the optional Lower Deck skirmish, animated Spark Rat,
steam-pressure hazard, reward cache and persistence contract. Its tests invoked
`try_activate_factory_lower_deck_skirmish()` directly, but the production
`OldFactoryEntranceScene._process()` loop never called that API. Consequently,
normal movement past the authored activation boundary could not enter the
encounter or the already-authored Lower Deck chain behind it.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/combat-presentation.md`.

**Requirements**: `TR-ability-005`, `TR-scene-003`, `TR-scene-005`.

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0005 Combat State
Machine; ADR-0006 AI Framework; ADR-0007 Scene Management; ADR-0018 Player
Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] After the checkpoint overdrive duo is cleared, moving Cinderpaw across
  the existing Lower Deck activation boundary at `x=780` automatically starts
  the skirmish through the production `_process()` path.
- [x] The encounter does not activate before the overdrive clear or while the
  player remains before the existing activation boundary.
- [x] Activation remains idempotent and continues to use the Story053 API and
  persisted state without duplicating encounter setup.
- [x] Enemy entity `2108` becomes visible, targets Cinderpaw, and enables
  process and physics; its existing `idle`, `run`, `attack_tell`, `attack`,
  `hurt`, and `death` animations retain at least three frames each.
- [x] The Lower Deck steam-pressure hazard becomes active and the route
  objective changes to `clear_lower_deck_skirmish` / `Clear Lower Deck
  Skirmish`.
- [x] The independent reward cache remains hidden and unclaimed until the
  enemy is defeated.
- [x] The optional service lift remains available as `Call lift`; crossing the
  encounter boundary does not request a scene transition.
- [x] One intentional RED, focused GREEN, bounded related regression, and one
  Godot 4.7 + MCP 3.0.2 real-input acceptance pass provide completion evidence.

## Out Of Scope

- No changes to enemy combat, damage, pacing, reward value, persistence schema,
  SceneManager, registry data, collision geometry or later Lower Deck gates.
- No checkpoint-aware Factory re-entry behavior and no service-lift scene-flow
  changes.
- No new scene nodes, visual assets, frame animations, audio, VFX, UI, asset
  manifest entries or image-generation work.

## Implementation Notes

- `OldFactoryEntranceScene._process()` now calls the existing
  `try_activate_factory_lower_deck_skirmish(_player)` after the checkpoint
  encounter auto-activation checks and before later forward-pressure chains.
- The callee retains all prerequisite, range, idempotency, objective, enemy,
  hazard, reward and persistence ownership established by Story053.
- The regression test exercises `_process()` directly and deliberately avoids
  calling the activation API, so it protects the production handoff rather
  than only the encounter implementation.

## Test Evidence

- Intentional RED `reports/report_2029/results.xml`: the focused suite recorded
  `3` tests and `7` expected assertion failures in the new production-path
  case because the encounter, actor, hazard and objective stayed inactive.
- Focused GREEN `reports/report_2032/results.xml`: Story053 plus the new
  production-path regression passed `3/3`, with `0` failures or errors.
- Bounded related GREEN `reports/report_2033/results.xml`: checkpoint overdrive
  duo, overlapping reward/lift input priority and Lower Deck suites passed
  `8/8`, with `0` failures or errors.
- Godot MCP run `r356346134-118` used real `move_right` input to move Cinderpaw
  from approximately `x=748` to `x=795.9` across the `x=780` boundary. Entity
  `2108`, the pressure hazard and Lower Deck objective activated while the
  service lift stayed `Call lift` and SceneManager remained idle.
- The MCP screenshot was non-empty at `1278x718`, all six enemy animations
  reported three frames, game logs contained only the MCP helper registration,
  editor logs contained `0` rows, and stopping restored editor readiness.
- Full traceability is recorded in
  `production/qa/evidence/old-factory-lower-deck-skirmish-production-input-handoff-2026-07-19.md`.

## Completion Notes

- Completed 2026-07-19 as a one-line production caller plus one focused
  regression test; no Story053 behavior or content was rewritten.
- The complete-game goal remains active. Checkpoint-aware Factory re-entry and
  authored service-lift presentation remain separate bounded Stories.
