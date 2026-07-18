# Story 016: New Game Scrap Roost Hunt Initiation

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration
> **Type**: Gameplay / Visual / Integration
> **Estimate**: M
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/game-concept.md`, `design/gdd/scene-management.md`
**Requirements**: Onboarding curve, `TR-scene-001`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0004: Collision detection architecture,
ADR-0007: Scene management architecture

The approved onboarding curve requires the first ten minutes to teach movement,
jumping and ordinary combat through the environment before the player reaches a
Boss. Story015 established a real title bootstrap, but New Game still entered
the Rat King arena directly. This Story inserts one bounded Scrap Roost hunt
initiation scene between the title and Story017's dedicated dodge trial.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] New Game requests registered scene `area_01_scrap_roost_hunt/default`
  through SceneManager; Continue and Load Slot retain their saved target route.
- [x] The first gameplay viewport contains a safe runway and a raised scrap step
  that can be crossed with real movement and jump input without spawning a Boss.
- [x] Crossing the runway activates exactly one existing Rat Minion ordinary
  enemy; the Rat King is absent throughout this scene.
- [x] The Rat Minion uses its existing visible `AnimatedSprite2D + SpriteFrames`
  states, including a three-frame `attack_tell`, and attacks through the existing
  runtime damage path.
- [x] Real player attack input defeats the enemy through the shared weapon,
  collision and damage path; the exit remains blocked before defeat.
- [x] Enemy defeat opens the authored exit and entering it requests
  `area_01_scrap_roost_dodge_trial/default`; Story017 owns the later
  `main/default` handoff and existing Rat King Phase-I intro.
- [x] Player death or falling below the room resets the bounded attempt without
  carrying a stale enemy, gate or transition latch.
- [x] The scene uses a generated, imported opaque `1280x720` Scrap Roost
  environment plate with retained source and exact prompt; no player, enemy, UI
  or collision guide is baked into the image.
- [x] Focused physical-input GdUnit acceptance and Godot MCP journeys verify
  movement, jump, attack, the Story017 handoff, clean logs and a non-empty
  screenshot.

## Implementation Notes

- `ScrapRoostHuntInitiation` owns only the one-room attempt. It reuses the
  production Player, HUD, CombatPresentation, HitstopInputBridge, WeaponComponent,
  runtime damage adapter and Rat Minion instead of creating tutorial-only combat.
- Title bootstrap keeps separate New Game and legacy-save fallback scene IDs, so
  saves that predate explicit scene metadata still fall back to `main/default`
  instead of replaying the onboarding room before deserialization.
- The enemy remains physics-disabled until the player crosses `x=500`. The exit
  blocker is removed only after the real `enemy_defeated` signal.
- The gate texture is hidden while locked because the generated background already
  contains the authored exit arch. On unlock, the aligned low-alpha pulse provides
  state feedback without rendering a second competing gate.
- No explicit tutorial text is added. The room geometry and enemy attack tell carry
  the onboarding instruction required by the GDD.

## Thin TDD / Verification

- RED: one physical-input acceptance test first fails because the onboarding
  scene does not exist.
- GREEN: add the registered scene and only the route/runtime code needed to cross
  the runway, defeat one ordinary enemy and request the next onboarding scene.
- Related regression: Story015 title routing, real-input player combo and the Rat
  King Phase-I intro only. No full suite or duplicate smoke run is required.
- Runtime: launch the real project through Godot MCP, activate New Game from the
  title, drive movement/jump/attack, inspect the Story017 handoff, then check
  game/editor logs and a non-empty screenshot.

## Out of Scope

- Story017's dedicated dodge timing implementation, rewards, savepoints,
  cinematics, tutorial popups or new enemy AI.
- Retuning Rat Minion or Rat King health, damage, cooldowns, attack timing or
  animation assets.
- Persisting this short initiation attempt as a durable checkpoint.

## Dependencies

- Depends on: Scene Management Stories 001-007 and 015.
- Depends on: existing Player, Rat Minion, HUD and CombatPresentation runtime.

## Test Evidence

- Intentional RED: `reports/report_1945/results.xml` failed `1/1` only because
  `scrap_roost_hunt_initiation.tscn` was absent.
- Focused GREEN: `reports/report_1948/results.xml` passed Story016 `1/1` with no
  failures, engine errors or orphans.
- Related GREEN: `reports/report_1949/results.xml` passed title routing, real-input
  combo and Rat King Phase-I intro `5/5` with clean teardown.
- Post-review title compatibility: `reports/report_1950/results.xml` passed `2/2`,
  proving New Game uses the initiation route while legacy saves with no scene
  metadata still resolve to `main/default`.
- Current-route regression: `reports/report_1958/results.xml` passed Story015-017
  `4/4`, including the initiation exit target
  `area_01_scrap_roost_dodge_trial/default`.
- Godot 4.7 / Godot AI MCP 3.0.2 run `r281879257-82` (token `82`) was the isolated
  Story016 acceptance before Story017 was inserted. Final run `r284679113-84`
  (token `84`) completed the current title-to-initiation-to-dodge-trial-to-Main
  journey with real movement, jump and attack input, info-only game output and
  zero editor log rows, then stopped cleanly.
- Detailed evidence:
  `production/qa/evidence/new-game-scrap-roost-hunt-initiation-2026-07-19.md`.
