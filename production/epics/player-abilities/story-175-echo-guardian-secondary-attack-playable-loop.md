# Story 175: Echo Guardian Secondary Attack Playable Loop

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Combat Readability / Visual Integration
> **Type**: Attack Pattern + Frame Animation + Data Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-18

## Context

**GDD**: `design/gdd/game-concept.md`, `design/gdd/boss-config.md`,
`design/gdd/ai-framework.md`, `design/gdd/feline-combat.md`

**Requirements**: `TR-boss-002`, `TR-boss-004`, `TR-ai-003`, `TR-ai-004`,
`TR-combat-001`, `TR-combat-004`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0004
Collision detection; ADR-0005 Combat state machine; ADR-0006 AI behavior;
ADR-0010 Combat presentation; ADR-0018 Player abilities.

Echo Guardian currently repeats one close-range swipe in both phases. Phase II
increases chase speed and lowers cooldown, but it does not create a new read or
new player decision. This story adds one deterministic, fixed-location echo
pounce so the player must distinguish a close swipe from a delayed landing and
move after the landing point is committed.

## Acceptance Criteria

- [x] Boss2 attack selection starts with `echo_swipe` and then alternates
  deterministically `echo_swipe -> echo_pounce -> echo_swipe`; phase changes do
  not reset or randomize the sequence.
- [x] `echo_pounce` captures the target's world X at startup, clamps the landing
  center inside the existing arena bounds, and never follows later target
  movement.
- [x] Pounce timing comes from data: Phase I uses `18/6/18` startup/active/
  recovery frames; Phase II applies its `1.2` speed modifier to startup and
  recovery for `15/6/15`; Focus adds the existing six startup frames.
- [x] The pounce hitbox is inactive throughout startup, activates only after the
  Boss moves to the committed landing point, deals `12` damage at most once per
  target, and is inactive throughout recovery.
- [x] Existing swipe timing, `14` damage, hitbox, cooldown, chase, Phase II,
  health, defeat hold, Double Jump reward, save flag, HUD, audio routing and
  scene handoff remain unchanged.
- [x] Add generated, transparent, continuously named `160x128` frames for
  `echo_pounce_tell`, `echo_pounce`, and `echo_pounce_recovery`; each runtime
  animation has at least three frames and uses the existing
  `AnimatedSprite2D + SpriteFrames` character surface.
- [x] The existing Focus warning is repositioned to the committed landing point
  during pounce startup, then hidden before the Boss lands. No new warning node
  or additional draw call is introduced.
- [x] One focused RED/GREEN acceptance test, the smallest related Boss2
  regression, one targeted smoke, and Godot 4.7 + MCP 3.0.2 runtime evidence
  pass with clean logs and a non-empty pounce-tell screenshot.

## Out of Scope

- Phase III, random attack weighting, summons, projectiles, multi-hit attacks,
  arena mutation, a generic Boss scheduler, new audio assets, reward/save schema
  changes, other Bosses, final balance, and the Crown Warden transition artwork.

## Implementation Notes

- Store Boss2 phase pattern IDs and speed modifiers in
  `data/combat/boss_configs.json`; store both attack timing/damage/hitbox
  definitions in `data/combat/enemy_stats.json` with validated schema entries.
- Preserve the verified swipe as the first pattern so Stories022/024/032/165
  retain their existing startup and active boundaries.
- Reuse the generated tell poses in reverse as the authored rise-to-stand
  recovery motion, but export them under the required `echo_pounce_recovery`
  path and names.
- Reuse Boss2's existing startup/active audio events and include `pattern_id` in
  metadata; authored pounce audio remains out of scope.

## Test Evidence

- RED `report_1936` failed `1/1` on the missing secondary-attack runtime API.
- Intermediate `report_1937` exposed the shared heavy-attack multiplier; the
  data/fallback correction made focused GREEN `report_1938` pass `1/1`.
- Bounded Boss2 regression `report_1939` passed `6/6`; the targeted real-Main
  smoke completed with exit `0` under Godot 4.7.
- Fresh pre-push gate `report_1940` repeated the bounded regression at `6/6`,
  with `0` GdUnit errors, failures, skipped, flaky tests or orphans.
- Godot MCP 3.0.2 run token `77` verified locked-position startup, one real
  `12`-damage active hit, recovery cleanup, three-frame animations, clean logs
  and a non-empty game screenshot.
- Full traceability is recorded in
  `production/qa/evidence/echo-guardian-secondary-attack-playable-loop-2026-07-18.md`.

## Completion Notes

- Completed 2026-07-18 with a data-driven two-pattern Boss2 scheduler and no
  changes to the established swipe or progression contracts.
- Built-in image generation supplied nine transparent runtime frames; source,
  alpha intermediates, exact prompts and hashes remain in the asset pipeline.
- The broader complete-game goal remains active. Crown Warden's dedicated
  phase-transition animation is the next bounded player-visible combat debt.
