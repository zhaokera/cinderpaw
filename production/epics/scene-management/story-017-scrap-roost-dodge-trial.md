# Story 017: Scrap Roost Dodge Trial

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration
> **Type**: Gameplay / Visual / Integration
> **Estimate**: M
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/game-concept.md`, `design/gdd/collision-detection.md`,
`design/gdd/scene-management.md`
**Requirements**: Onboarding curve, gone dodge hurtbox, `TR-scene-001`

**ADR Governing Implementation**: ADR-0004: Collision detection architecture,
ADR-0007: Scene management architecture

The GDD says the first room is safe, the second introduces an enemy, and the
third requires a dodge without explicit tutorial UI. Story016 supplies the
movement/jump runway and first ordinary enemy. This Story inserts a separate
one-screen exhaust trial before Story018's first post-onboarding ACT encounter,
proving the player can use the existing dodge i-frames before meeting Rat King.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] Story016 exits through SceneManager to registered scene
  `area_01_scrap_roost_dodge_trial/default`; Rat King is absent in the trial.
- [x] The room uses the production Player, HUD, HitstopInputBridge and
  CombatPresentation, with no tutorial-only input or invulnerability path.
- [x] One exhaust cycles deterministically through `safe 30`, `warning 24`,
  `active 18` and `recovery 30` physics frames. Active contact without a valid
  dodge applies `8` environment damage at most once per active sequence.
- [x] The visible exhaust is an `AnimatedSprite2D + SpriteFrames` instance that
  reuses the existing image-generated four-frame `safe`, `warning` and `active`
  animations.
- [x] Success requires a body overlap during active phase, Core dodge i-frames,
  a `gone` CollisionComponent hurtbox, a dodge started left of the hazard while
  facing right, positive traversal velocity and the same active sequence ID.
- [x] Standing away, walking through, Dash, respawn invulnerability or a dodge
  from the wrong side cannot unlock the exit.
- [x] Success changes the hazard to `crossed`, disables its collision, opens the
  exit and requests `area_01_scrap_roost_rat_king_approach/default`; Story018
  then owns the `main/scrap_roost` Rat King handoff.
- [x] Player death or a fall resets phase, damage, sequence, gate and transition
  state without leaving stale collision or a stale unlock.
- [x] The room uses a generated imported opaque `1280x720` background with
  retained source and exact prompt; steam, actors, UI and collision are separate
  Godot runtime layers.
- [x] One focused physical-input test, bounded Story015-017 regression and one
  Godot MCP journey verify the real dodge, scene chain, animation frames, clean
  logs and a non-empty screenshot.

## Implementation Notes

- `ScrapRoostDodgeTrial` owns only this bounded attempt. It records a dodge
  sequence only when `dodge_started` occurs in the current active phase from the
  left side, then checks the independent body overlap and Core hurtbox state in
  physics processing.
- The hazard body mask includes the Player body layer so overlap remains
  measurable while the dodge intentionally removes the Player hurtbox.
- The existing `FactorySteamVentHazard` creates the runtime SteamAnimation child
  and maps the room's logical phases to the established SpriteFrames resource.
- No explicit tutorial copy or enemy was added. Warning motion, steam plume,
  narrow staging distance and locked exit carry the instruction.

## Thin TDD / Verification

- RED: one physical-input acceptance fails only because the authored scene does
  not exist.
- GREEN: add the registered scene, active-sequence proof and SceneManager route
  required to complete one real dodge.
- Related regression: title New Game routing and Story016's defeat-gated handoff
  only. No full suite or duplicate smoke run is required.
- Runtime: launch from the real title, complete Story016, stage left of the live
  exhaust, dodge through one active sequence, inspect the Story018 handoff, then
  read bounded game/editor logs and capture one screenshot.

## Out of Scope

- New enemy AI, repeated multi-hazard gauntlets, savepoints, rewards, tutorial
  popups, difficulty settings or input remapping.
- Retuning Player dodge duration/speed or Rat King combat values.
- Replacing or regenerating the existing Old Factory steam animation.

## Dependencies

- Depends on: Scene Management Stories 001-007, 015 and 016.
- Depends on: ADR-0004 Player CollisionComponent dodge hurtbox contract.
- Reuses: Player, HUD, CombatPresentation and FactorySteamVentHazard runtime.

## Test Evidence

- Intentional RED: `reports/report_1951/results.xml` failed `1/1` only because
  `scrap_roost_dodge_trial.tscn` was absent.
- Initial focused GREEN: `reports/report_1954/results.xml` passed the real-dodge
  success path `1/1` with no failures, engine errors or orphans.
- Post-review RED: `reports/report_1956/results.xml` exposed that the first
  no-dodge contact attempt started too far away to reach an 18-frame active
  window from rest. The test now stages closer and waits for a new sequence.
- Final focused GREEN: `reports/report_1957/results.xml` passed Story017 `1/1`,
  proving a no-dodge crossing applies `8` damage and keeps the exit locked before
  the next active-sequence dodge succeeds without further HP loss.
- Final bounded related GREEN: `reports/report_1958/results.xml` passed
  Story015-017
  `4/4` with no failures, errors, flaky cases, skips or orphans.
- Current successor-route GREEN: `reports/report_1966/report_1/results.xml`
  passed Story015-018 `5/5`, including the updated Story017-to-Story018 request,
  with no failures, errors, flaky cases, skips or orphans.
- Godot 4.7 / Godot AI MCP 3.0.2 run `r284679113-84` (token `84`) completed the
  then-current title-to-Story016-to-Story017-to-Main journey. The active exhaust
  reported four frames and real playback, the same active/dodge sequence `35`
  crossed at HP `100 -> 100`, the non-empty screenshot was `1278x718`, game
  output was info-only and editor logs contained zero rows before a clean stop.
  Story018 supersedes only the destination after this unchanged dodge proof.
- Detailed evidence:
  `production/qa/evidence/scrap-roost-dodge-trial-2026-07-19.md`.
