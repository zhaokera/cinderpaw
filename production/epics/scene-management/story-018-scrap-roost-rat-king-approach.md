# Story 018: Scrap Roost Rat King Approach

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration
> **Type**: Gameplay / Visual / Integration
> **Estimate**: M
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/game-concept.md`, `design/gdd/ai-framework.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`
**Requirements**: first post-onboarding ACT encounter, enemy telegraph
readability, `TR-scene-001`

**ADR Governing Implementation**: ADR-0004: Collision detection architecture,
ADR-0007: Scene management architecture

Stories016-017 establish movement, jump, ordinary-enemy combat and dodge before
the first Boss. This Story adds one bounded post-onboarding approach encounter
between the exhaust trial and Rat King. It uses the existing frame-animated
Shadow Beast and production combat chain, then hands the player to the existing
Scrap Roost savepoint instead of extending tutorial scope.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] Story017 exits through SceneManager to registered scene
  `area_01_scrap_roost_rat_king_approach/default`; Rat King is absent from the
  approach.
- [x] The room uses the production Player, HUD, HitstopInputBridge,
  CombatPresentation, WeaponComponent and runtime damage adapter.
- [x] One existing Shadow Beast starts frozen, activates after player
  `x=440`, targets the Player and uses the production patrol/contact/bite FSM.
- [x] Its `AnimatedSprite2D + SpriteFrames` exposes `idle`, `patrol`,
  `attack_tell`, `attack`, `hurt` and `death`, with at least three transparent
  frames in every state.
- [x] Real player attack input routes through the shared weapon/collision/damage
  chain. Enemy defeat plays `death`, opens the seal and disables the gate.
- [x] Player death or a fall resets player, enemy, gate and transition state
  without leaving stale collision or an unlocked exit.
- [x] The unlocked exit requests `main/scrap_roost`; Main activates the existing
  Scrap Roost savepoint and completes Rat King Phase-I intro once.
- [x] The room uses a generated imported opaque `1280x720` background with its
  retained source and exact prompt. Actors, UI, gate state and collision remain
  separate Godot runtime layers.
- [x] Focused physical-input coverage, the Story015-018 route regression and one
  clean Godot MCP run verify animation frames, attack response, gate unlock,
  Main handoff, logs and non-empty screenshots.

## Implementation Notes

- `ScrapRoostRatKingApproach` owns only encounter activation, reset, gate state
  and SceneManager handoff. Shared Player and `SimpleEnemy` code is unchanged.
- The enemy is instantiated from `src/gameplay/simple_enemy.tscn` and remains
  physics-disabled until the player crosses the authored activation threshold.
- The generated gate background communicates Rat King territory through the
  distant mechanical-rat silhouette, torn clan banner and warm sealed entrance;
  no tutorial text or Boss entity is baked into the scene.
- `main/scrap_roost` is intentional: Story018 ends beside the existing savepoint
  and lets Main own Rat King intro, Boss HUD and arena systems.

## Thin TDD / Verification

- RED: one physical-input acceptance failed only because the authored scene did
  not exist.
- GREEN: register the scene, route Story017 into it, activate one existing
  Shadow Beast, defeat it through real attack input and request the exact Main
  savepoint handoff.
- Related regression: title New Game routing and Stories016-017 only. Main
  savepoint runtime was checked once because the new route changes its spawn.
- Runtime: open the target scene through MCP, inspect the animation contract and
  attack tell, land a real `J` attack, clear the remaining HP through the same
  target damage boundary, cross the unlocked exit, inspect Main/Rat King and
  read game/editor logs.

## Out of Scope

- New enemy family art, multi-target adapters, Spark Rat regional identity,
  rewards, dialogue, tutorial UI or Boss retuning.
- Changes to shared Shadow Beast timing, Player damage values, Rat King phase
  logic or Main savepoint behavior.
- A second encounter, arena wave controller or persistence for this short room.

## Dependencies

- Depends on: Scene Management Stories001-007 and 015-017.
- Depends on: ADR-0004 Player/Enemy collision and shared hitbox contracts.
- Reuses: Player, SimpleEnemy Shadow Beast, HUD, CombatPresentation and Main
  Scrap Roost savepoint runtime.

## Test Evidence

- Intentional RED: `reports/report_1959/report_1/results.xml` failed `1/1` only
  because `scrap_roost_rat_king_approach.tscn` was absent.
- Import/staging diagnostics: `report_1960` exposed the unimported generated
  texture; `report_1961` then exposed a one-pixel test staging gap. Reports
  `1962-1963` measured the real attack overlap and corrected only the helper.
- Focused GREEN: `reports/report_1964/report_1/results.xml` passed Story018
  `1/1` with no errors, failures, flaky cases, skips or orphans.
- Related GREEN: `reports/report_1965/report_1/results.xml` passed Story015-018
  plus Main savepoint runtime `8/8`; final clean route gate
  `reports/report_1966/report_1/results.xml` passed Story015-018 `5/5` with zero
  errors, failures, flaky cases, skips or orphans and exit code `0`.
- Godot 4.7 / Godot AI MCP 3.0.2 accepted run `r288970422-90` (token `90`)
  verified all six three-frame enemy states, live `attack_tell`, real `J`-key
  damage `30 -> 20`, death/gate unlock, `main/scrap_roost`, the discovered
  savepoint and completed Rat King Phase-I intro. Both `1278x718` screenshots
  were non-empty; game output was info-only and editor logs contained zero rows.
- Detailed evidence:
  `production/qa/evidence/scrap-roost-rat-king-approach-2026-07-19.md`.
