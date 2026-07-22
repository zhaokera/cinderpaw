# Story 208: Old Factory Aftershock Exhaust Flank Production Combat Breaker Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat and Hazard Handoff
> **Type**: Integration + Gameplay Runtime + Production Movement + Production Combat + Hazard
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story207 claims the Story088 pursuer cache and leaves Story089 available. This
Story closes the next production ACT beat: fresh forward movement activates the
Spark Rat flank, real overlap drives the steam hazard, real player attacks
defeat entity `2132`, and the clear leaves Story090 available but inactive.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/collision-detection.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management. ADR-0018 and ADR-0021 remain no-change dependencies.

## Acceptance Criteria

- [x] Restoring or teleporting beyond x `2768` cannot activate Story089.
  Availability must already exist at frame start and a later positive player-x
  sample must cross the boundary.
- [x] Real `move_right` activates entity `2132` with `24 HP`, target, process,
  physics and hurtbox `normal`; HUD becomes `Break Aftershock Exhaust Flank`.
- [x] Entity `2132` uses `AnimatedSprite2D + SpriteFrames`; `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` each contain three frames.
- [x] The active dynamic steam vent uses four-frame `active` animation and real
  `Area2D` overlap to damage Cinderpaw by `8`, recording the Story089 hazard
  source. Its static `Visual` remains hidden.
- [x] Spark Rat production bite metadata records attacker `2132`, target `1`,
  weapon `factory_spark_rat_bite`, and final damage `9`.
- [x] Two real player light attacks route through `cat_claw_light` and reduce
  entity `2132` from `24 -> 12 -> 0` in MCP acceptance.
- [x] Live defeat preserves visible/processing three-frame `death` while
  disabling target, physics and hurtbox; the flank vent becomes hidden and
  non-contacting, and HUD becomes `Forward Pressure Exhaust Flank Cleared`.
- [x] Story089 defeat cannot consume the same process sample to activate
  Story090. Entity `2133` remains hidden, non-processing, non-physical,
  `24 HP`, and hurtbox `gone`; its vent and breaker remain hidden.
- [x] Story090 requires its own later fresh positive movement sample across x
  `2928`; restored state also resets the runtime movement tracker.
- [x] Thin RED/GREEN, five-suite bounded regression, Factory smoke and Godot
  4.7 / Godot AI MCP 3.0.4 runtime/log/screenshot acceptance pass.

## Out Of Scope

Story090 production combat and breaker interaction, steam warning/grace
redesign, room-node repositioning, new enemy families, new visual/audio assets,
SaveSystem schema changes, service-lift routing and Rat King Phase III.

## Implementation Notes

- Story089 and Story090 each snapshot availability at `_process` start and
  track the previous processed player x. `set_local_state()` resets both
  runtime-only trackers so loading and fixture teleports cannot count as input.
- Story090 synchronization maps the inactive Coil Rat hurtbox to `gone`, so it
  cannot steal Story089 player attacks.
- The canonical test uses direct damage only as deterministic nonlethal setup;
  its lethal hit uses production input. MCP acceptance additionally proves two
  consecutive real player light hits.
- The related Story090 test now follows the shared RatMinion live-death
  contract instead of expecting the enemy to disappear in the death signal.

## Asset Use

No image generation was required. Existing registered image-generated
Cinderpaw, Factory Spark Rat, Factory Coil Rat, dynamic steam and Factory
environment assets were reused. No PNG, SpriteFrames, import, manifest or
entity inventory file changed.

## Verification Evidence

- Canonical RED `reports/report_2252/results.xml` failed because stationary x
  beyond `2768` activated Story089. A second RED
  `reports/report_2253/results.xml` proved restored-state teleport could seed
  the same false activation.
- `reports/report_2254/results.xml` reached combat and exposed the test's
  missing wait for the player's 12-frame steam hit-stun. Focused GREEN
  `reports/report_2255/results.xml` passed `1/1` after waiting for combat
  `IDLE`.
- The first bounded run `reports/report_2256/results.xml` passed ten tests and
  exposed one stale Story090 immediate-hide assertion. Focused Story090
  `reports/report_2257/results.xml` passed `2/2` after adopting visible live
  death.
- Final bounded related `reports/report_2258/results.xml` passed five suites
  and `11/11` tests with zero failure, error, flaky, skip or orphan. No full
  suite was run.
- Godot 4.7 Factory `180`-frame headless smoke exited `0`; log:
  `reports/old_factory_aftershock_exhaust_flank_production_combat_breaker_handoff_smoke.log`.
  Only the established `4 ObjectDB / 2 resources` shutdown baseline remained.
- Godot MCP 3.0.4 accepted run `r137556639-60` used real `move_right`, real
  steam overlap, a real Spark Rat bite, and two real `attack` inputs. It
  verified `24 -> 12 -> 0`, lethal metadata target `2132`, Story089 clear and
  Story090 available/inactive with entity `2133` hurtbox `gone`.
- Non-empty RGB `1278x718` captures:
  `reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-flank-production-combat-breaker-handoff-active-20260721.png`
  and
  `reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-flank-production-combat-breaker-handoff-cleared-20260721.png`.
  The accepted game log contained only helper registration, editor log was
  empty, inputs/time scale were restored, and the editor returned to ready.
- Full evidence:
  `production/qa/evidence/old-factory-aftershock-exhaust-flank-production-combat-breaker-handoff-2026-07-21.md`.

## Visual Follow-Up

The active screenshot confirms that Cinderpaw, the Spark Rat and the steam
vent are all readable authored assets, but their silhouettes overlap tightly
near x `2788`. A separate follow-up should use the vent's existing `warning`
animation and/or adjust staging before changing Story090 production combat.

**Status**: [x] Complete.

## Dependencies

- Depends on: Stories 087, 088, 089 and 207.
- Unlocks: Story090 production movement, combat, death and breaker interaction.
