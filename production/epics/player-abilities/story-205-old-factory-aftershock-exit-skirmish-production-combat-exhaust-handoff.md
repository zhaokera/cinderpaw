# Story 205: Old Factory Aftershock Exit Skirmish Production Combat Exhaust Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat and Traverse Handoff
> **Type**: Integration + Gameplay Runtime + Production Combat + Production Movement + Encounter Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story204 ends with the Story084 cache claimed and Story085 available. This
Story closes the next production path: claiming the cache cannot start combat
in the same frame, a fresh forward move starts the dual-enemy encounter, real
player attacks clear it, and another fresh move starts Story086 without being
borrowed from the lethal tick.

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/feline-combat.md`,
`design/gdd/collision-detection.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-combat-001`, `TR-combat-004`, `TR-scene-004`,
`TR-explore-005`, `TR-respawn-002`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management; ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] Before Story084 is claimed, inactive entities `2129` and `2130` have
  hidden visuals, disabled process/physics and `gone` hurtboxes.
- [x] Real `Input.interact` at x `2288` claims Story084 but cannot activate
  Story085 in the same process frame.
- [x] A fresh real forward move after the claim activates Story085 with both
  enemies visible, targeted, process/physics enabled, `normal` hurtboxes,
  `24 HP`, opening grace `12/24`, and HUD `Break Aftershock Exit Skirmish`.
- [x] Initial staging puts the Spark Rat on the forward flank and the Coil Rat
  on the rear flank, each at least `48px` from the player and at least `250px`
  center-to-center, before their normal pursuit AI closes distance.
- [x] Real `Input.attack` through Combat/Weapon/Collision and
  `cat_claw_light` can finish entities `2129` and `2130`; direct damage is used
  only for deterministic nonlethal `24 -> 12` setup.
- [x] Partial defeat preserves the defeated enemy's visible/process
  three-frame `death` presentation while removing physics, target and hurtbox;
  the survivor remains fully active. Full clear preserves both deaths as
  noncombat presentations.
- [x] Full clear immediately makes Story086 visible/available but inactive.
  The lethal frame and stationary frames cannot activate it; a fresh positive
  movement at/after x `2416` starts `grace`, keeps contact off and updates HUD
  to `Cross Aftershock Exhaust`.
- [x] Both enemy families remain `AnimatedSprite2D + SpriteFrames` with six
  gameplay animations at three frames each. No new visual or audio asset is
  added.
- [x] Thin RED/GREEN, four-suite bounded regression, Factory smoke, and Godot
  4.7 / Godot AI MCP 3.0.4 runtime/log/screenshot acceptance pass.

## Out Of Scope

Global crowd steering, permanent enemy separation during pursuit, new enemy or
vent art, new audio, Story086 warning/active/safe traversal completion, new
reward economy, SaveSystem schema, service-lift routing and map expansion.

## Implementation Notes

- Story084 claim and Story085 clear create one-frame handoff barriers and
  snapshot player X. Auto activation requires both prior availability and a
  newly increased player X, so one input cannot chain adjacent objectives.
- Story085 stages the existing Spark Rat at `+144px` and Coil Rat at `-160px`
  from the activation anchor. Normal pursuit remains unchanged after opening.
- Shared encounter synchronization now explicitly sets inactive/defeated
  hurtboxes to `gone` and active hurtboxes to `normal`.
- The canonical test uses production interact, movement and attack inputs. It
  calls scene damage only for the two nonlethal setup hits.

## Asset Use

No image generation was required. The Story reuses registered image-generated
Cinderpaw, Factory Spark Rat, Factory Coil Rat, dynamic steam vent and Factory
environment assets. No PNG, SpriteFrames, source/import, manifest or entity
inventory file changed.

## Verification Evidence

- Refined canonical RED `reports/report_2231/report_1/results.xml` failed `0/1`
  with ten expected contract failures and zero errors. Initial GREEN
  `reports/report_2232/report_1/results.xml` passed `1/1`.
- Readability RED `reports/report_2234/report_1/results.xml` failed only because
  `224px < 250px`; focused GREEN `reports/report_2235/report_1/results.xml`
  passed `1/1` after the bounded staging adjustment.
- Final bounded related `reports/report_2237/report_1/results.xml` passed four
  suites and `8/8` tests with zero failure, error, flaky, skip or orphan. No
  full suite was run.
- Godot 4.7 Factory `180`-frame headless smoke exited `0`; log:
  `reports/old_factory_aftershock_exit_skirmish_production_combat_exhaust_handoff_smoke.log`.
  It retained only the established `4 ObjectDB / 2 resources` shutdown
  baseline and no project script/parse/resource error.
- Godot MCP 3.0.4 accepted run `r130447473-54` used real interact, movement and
  two real lethal attacks. It confirmed `304px` initial center spacing,
  `2129/2130` hit metadata, partial/full death semantics, stationary Story086
  idle state, and real-movement entry into exhaust `grace`.
- Non-empty RGB `1278x718` screenshots showed the active flanked encounter,
  partial death and visible exhaust grace state. Game log contained only helper
  registration, editor log was empty, inputs/time scale were restored, and the
  editor returned to ready.
- Full evidence:
  `production/qa/evidence/old-factory-aftershock-exit-skirmish-production-combat-exhaust-handoff-2026-07-21.md`.

**Status**: [x] Complete.

## Dependencies

- Depends on: Stories 084, 085, 086, 203 and 204.
- Unlocks: Story086 production traversal completion and the next deeper Factory handoff.
