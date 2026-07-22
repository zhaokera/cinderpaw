# Story 206: Old Factory Aftershock Exhaust Production Traverse Pursuer Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Traverse and Combat Handoff
> **Type**: Integration + Gameplay Runtime + Production Movement + Hazard Timing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story205 connects the aftershock exit skirmish to Story086 `grace`. This Story
closes the production traversal gap: the Factory scene process loop advances
the exhaust through warning, active and safe, active overlap applies real steam
damage, a real forward crossing completes the vent, and Story087 becomes
available without activating before its own boundary.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/collision-detection.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management; ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] With Story085 cleared, Story086 is available but inactive; inactive
  Story087 remains hidden, process/physics disabled, `24 HP`, and its hurtbox is
  `gone`.
- [x] Real positive movement across x `2416` starts Story086 in `grace` and
  updates the HUD to `Cross Aftershock Exhaust`.
- [x] The production `_process(delta)` path advances the vent through
  `grace -> warning -> active -> safe` without test-only transition calls.
- [x] Grace, warning and safe keep contact disabled. A real `Area2D` overlap in
  active applies exactly one verified `8`-damage contact and records source
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust`.
- [x] Real positive movement across x `2480` completes Story086, hides and
  disables the vent, stops its animation, and updates the HUD to
  `Forward Pressure Aftershock Exhaust Crossed`.
- [x] Story086 completion makes Story087 available but inactive while the
  player remains below x `2552`; entity `2131` stays hidden, non-processing,
  non-physical, `24 HP`, and its hurtbox remains `gone`.
- [x] A live Story087 defeat preserves visible/process three-frame `death`
  presentation while disabling physics, target and hurtbox. Restored completed
  state remains fully hidden and inactive.
- [x] Existing dynamic steam `AnimatedSprite2D + SpriteFrames` provides four
  frames each for `safe`, `warning` and `active`. No new asset is added.
- [x] Thin RED/GREEN, four-suite bounded regression, Factory smoke, and Godot
  4.7 / Godot AI MCP 3.0.4 runtime/log/screenshot acceptance pass.

## Out Of Scope

Story087 production activation/combat/reward handoff, repeated-overlap balance
changes shared by every steam hazard, new visual/audio assets, SaveSystem
schema changes, service-lift routing, map expansion and Rat King Phase III.

## Implementation Notes

- The Factory scene process loop now advances and completes Story086 after its
  existing activation check. The public deterministic APIs remain unchanged.
- Story087 synchronization explicitly maps inactive/cleared states to a `gone`
  hurtbox and active state to `normal`.
- The Story087 live defeat callback prepares death presentation directly so
  signal ordering cannot hide the final animation. Save restoration still uses
  the normal completed-state synchronization and remains hidden.
- The canonical test uses production movement for both boundaries and invokes
  `_process(delta)` for timing progression. Its direct steam contact call is
  limited to deterministic unit-level damage gating; MCP verifies real overlap.

## Asset Use

No image generation was required. The Story reuses the registered
image-generated Cinderpaw, Factory Coil Rat, Factory environment and dynamic
steam vent assets. The vent uses
`assets/environment/old_factory_steam_vent/factory_steam_vent_sprite_frames.tres`
with four transparent frames each for `safe`, `warning` and `active`. No PNG,
SpriteFrames, source/import, manifest or entity inventory file changed.

## Verification Evidence

- Canonical RED `reports/report_2238/report_1/results.xml` failed `0/1` with
  fifteen expected assertions and zero errors. Focused GREEN
  `reports/report_2239/report_1/results.xml` passed `1/1`.
- The first bounded run `reports/report_2240/report_1/results.xml` exposed one
  stale Story087 expectation that hid a live death immediately. After aligning
  it with the frame-animation rule, focused Story087
  `reports/report_2242/report_1/results.xml` passed `2/2`.
- Final bounded related `reports/report_2244/results.xml` passed four
  suites and `7/7` tests with zero failure, error, flaky, skip or orphan. No
  full suite was run.
- Godot 4.7 Factory `180`-frame headless smoke exited `0`; log:
  `reports/old_factory_aftershock_exhaust_production_traverse_pursuer_handoff_smoke.log`.
  It retained only the established `4 ObjectDB / 2 resources` shutdown
  baseline and no project script/parse/resource error.
- Godot MCP 3.0.4 accepted run `r133380254-57` used real movement for Story086
  entry and completion. It verified warning contact off, active physical
  overlap `100 -> 92`, safe HP stability, x `2480` completion below the x
  `2552` pursuer boundary, and Story087 available/inactive safety.
- Non-empty RGB `1278x718` screenshots showed the four-frame active exhaust and
  the crossed route with no residual steam. Game log contained only helper
  registration, editor log was empty, inputs/time scale were restored, and the
  editor returned to ready.
- Full evidence:
  `production/qa/evidence/old-factory-aftershock-exhaust-production-traverse-pursuer-handoff-2026-07-21.md`.

**Status**: [x] Complete.

## Dependencies

- Depends on: Stories 085, 086, 087 and 205.
- Unlocks: Story087 production combat and its reward-cache handoff.
