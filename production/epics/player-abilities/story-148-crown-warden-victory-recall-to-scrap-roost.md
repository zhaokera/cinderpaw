# Story 148: Crown Warden Victory Recall To Scrap Roost

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / Scene Flow / Presentation
> **Type**: Integration + Runtime Handoff + Generated Visual Contract
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-13

## Context

**GDD**: `design/gdd/game-concept.md`, `design/gdd/scene-management.md`,
`design/gdd/save-system.md`, `design/gdd/hud-ui.md`,
`design/art/art-bible.md`

**Quick Design**:
`design/quick-specs/crown-warden-victory-recall-to-scrap-roost-2026-07-13.md`

**Requirements**: `TR-scene-001`, `TR-scene-004`, `TR-save-001`, `TR-hud-001`

**ADR Governing Implementation**: ADR-0001, ADR-0003, ADR-0007, ADR-0018,
ADR-0021.

Story147 completes the Boss4 reward and leaves the player in Crown Observatory
with an existing return to Apex Approach. The GDD session loop requires a Boss
victory to reconnect to the hub. This Story adds an optional direct recall to
the established `main / scrap_roost` endpoint while preserving the Tower route.
It explicitly does not claim an ending because the full-version concept defines
five Bosses and Crown Warden is Boss4.

## Acceptance Criteria

- [x] `crown_warden_arena.tscn` contains `CrownVictoryRecallRoute` at
  `(1180,536)` using route id `crown_warden_victory_recall`, target `main`, spawn
  `scrap_roost` and a generated transparent `256x384` transmitter texture.
- [x] The recall node is hidden and unavailable until both
  `boss_04_crown_warden_defeated` and `boss_04_wall_climb_reward_claimed` are
  true. Story145's `CentralTowerReturnRoute` remains available after defeat.
- [x] A provider outside the authored range cannot request recall. A provider in
  range requests `main / scrap_roost` once; repeat input during the transition
  is idempotently rejected.
- [x] Successful recall persists `boss_04_victory_recall_requested=true`, Boss4
  defeat, reward claim and the exact unlocked ability list before SceneManager
  receives the request. Rejection rolls back the durable proof.
- [x] Arena restore preserves the durable proof, defeated/reward/ability state
  and both routes, but clears transition, feedback, VFX and control-lock latches.
- [x] Returned MainScene recognizes only the full Boss4 recall proof while at
  `main / scrap_roost`, moves Cinderpaw to the existing Scrap Roost, discovers
  that savepoint, records `boss_04_victory_hub_return_secured=true` and shows
  `Crown secured - returned to Scrap Roost` once.
- [x] Incomplete proof, wrong scene or wrong spawn does not secure the hub and
  does not replace the normal MainScene objective.
- [x] Image-generation source, exact prompt/processing record, alpha source and
  runtime PNG are retained and recorded in asset spec, manifest, inventory and
  QA evidence. No primitive route placeholder is visible.
- [x] Existing Cinderpaw/Crown Warden `AnimatedSprite2D + SpriteFrames`, Boss4
  combat/reward, Tower return and Scrap Roost regressions remain green.
- [x] Focused RED/GREEN, bounded related regression, one target smoke and one
  Godot MCP 2.9.1 pass cover real movement/Interact, runtime transition, hub
  arrival, imported art, non-empty screenshots and clean current logs. No full
  suite.

## Out Of Scope

- Boss5, final-Boss language, ending, credits, post-game, dialogue or new lore.
- New hub/area registry entries, SaveSystem schema, new Autoload, combat/reward
  changes, character animation changes or a global route refactor.

## Test Evidence Contract

- Focused suite:
  `tests/unit/gameplay/crown_warden_victory_recall_to_scrap_roost_test.gd`
- Target smoke:
  `tests/smoke/crown_warden_victory_recall_to_scrap_roost_smoke.gd`
- QA evidence:
  `production/qa/evidence/crown-warden-victory-recall-to-scrap-roost-2026-07-13.md`

## Dependencies

- Depends on: Story147 Crown Warden Wall Climb Reward Payoff. Complete.
- Unlocks: separately authored Boss5/final-route work based on approved GDD.

## Implementation

- Added a generated owl-crown recall transmitter and an optional right-side
  `CrownVictoryRecallRoute`; the existing left Apex return remains intact.
- Added durable recall proof, rollback on rejected persistence/request, restore
  diagnostics and one shared transition latch in `CrownWardenArena`.
- Added strict Boss4 proof recognition in `MainScene`, exact Scrap Roost
  placement/discovery, a durable secured flag and one victory-return notice.
- Corrected persistent MainScene restoration so previously defeated Rat King
  and Echo Guardian actors, collisions and Boss HUD do not reappear after the
  post-Boss4 return.

## Verification

- RED: `reports/report_1560/results.xml`, three focused tests with nine expected
  missing-contract failures.
- Final bounded GREEN: `reports/report_1564/results.xml`, `16/16` across
  Stories 148, 147, 146, 145 and the existing Scrap Roost return.
- Persistence regression RED `reports/report_1565/results.xml` reproduced the
  Rat King respawn; final related GREEN `reports/report_1567/results.xml`
  passed `13/13` across Story148, Rat King and Boss2 HUD contracts.
- Target smoke: `crown_warden_victory_recall_to_scrap_roost_smoke=passed`, exit
  `0`, with a real SceneManager swap to `main / scrap_roost`.
- Godot MCP 2.9.1, Godot 4.7-stable, session `cinderpaw@13e3`, final Run
  `r21750636-14`: physical `E` interaction, imported route art visible, runtime
  handoff complete, both defeated MainScene bosses hidden with collisions at
  zero, Boss HUD hidden, two non-empty `1278x718` screenshots, three info log
  rows and zero new editor errors.
- Evidence:
  `production/qa/evidence/crown-warden-victory-recall-to-scrap-roost-2026-07-13.md`
  and
  `production/qa/evidence/crown-warden-victory-recall-to-scrap-roost-mcp-run14.json`.

## Completion Notes

Story148 closes the Boss4 session at the established hub without treating Crown
Warden as the final Boss. No full suite was run; the verification scope remained
bounded to the changed post-Boss4 route and its immediate regressions.
