# Story 225: Old Factory Service Sluice Production Combat Reward Cache Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Combat Handoff
> **Type**: Integration + Production Movement + Production Combat + Live Death + Reward
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story224 stops with Story113 crossed and Story114 available but inactive.
Story225 closes the next playable ACT slice: real forward movement activates
the service-sluice Spark Rat, a real Cinderpaw light-attack Hitbox kills entity
`2142`, the authored death presentation completes, and Story115 appears as a
visible, claimable, but still unclaimed reward boundary.

**GDD**: `design/gdd/input.md`, `design/gdd/collision-detection.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-input-001`, `TR-collision-004`, `TR-combat-001`,
`TR-scene-004`, `TR-explore-005`

**Governing ADRs**: ADR-0002 Event Bus; ADR-0004 Collision Detection;
ADR-0005 Combat State Machine; ADR-0007 Scene Management.

## Acceptance Criteria

- [x] No-input placement beyond x `10920` cannot activate Story114. Real
  positive-x `move_right` activates entity `2142` and changes the objective to
  `Clear Service Sluice Spark Rat`.
- [x] The active Spark Rat is visible, targeted, processing and physical at
  `24 HP`, with a normal hurtbox and its existing opening grace `12`.
- [x] `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` remain
  `AnimatedSprite2D + SpriteFrames` animations with at least `3` frames each.
- [x] The combat pocket renders duct/cache at z `22`, entity `2142` at z `24`,
  and Cinderpaw at z `26` so both combatants remain readable.
- [x] Direct damage is used only for deterministic nonlethal setup `24 -> 12`;
  the lethal `12 -> 0` transition comes from real `Input.attack`, the real
  `cat_claw_light` Hitbox, and entity `2142`'s real Hurtbox.
- [x] Hit metadata records target `2142`, attack type `light`, hitbox
  `cat_claw_light`, damage `12`, and `damage_was_applied=true`.
- [x] Runtime defeat clears target/combat physics, preserves the authored
  `death` presentation until fade/despawn, persists Story114 cleared state,
  and changes the objective to `Service Sluice Spark Rat Cleared`.
- [x] Story115 becomes visible, available and claimable at
  `Vector2(11360, 410)` with prompt `+20 Gears`, while claimed state, reward
  payload and feedback remain empty.
- [x] No-input placement inside the cache radius does not claim Story115, and
  Story116 remains unavailable, hidden and unopened.
- [x] Focused/related GdUnit, a marker-backed `180`-frame Factory smoke, and
  Godot 4.7 / Godot AI MCP 3.0.4 runtime/log/two-framebuffer acceptance pass.

## Out of Scope

Story115 production `interact` routing and reward grant, Story116 exit-hatch
input, deeper route content, new AI or balance changes, new art/audio/VFX,
SaveSystem schema changes, Boss content, and full-suite testing.

## Implementation Notes

- One integration test owns the whole Story114-to-Story115 production boundary.
- Existing Story224 movement gating and shared combat/collision routing already
  supplied the required behavior; the only production gap was entity `2142`
  rendering behind the z `22` service-sluice environment.
- The scene change raises only that Spark Rat from z `20` to z `24`.
- Story115 intentionally remains outside the production reward interaction
  router; its fresh-input claim is the next bounded Story.

## Asset Use

No image generation was required. The slice reuses imported Cinderpaw, Factory
Spark Rat, service-sluice landing and reward-cache assets. No new visual,
audio, animation or manifest entry was introduced.

## Verification Evidence

- Canonical RED `reports/report_2361/results.xml` ran `1` integrated test with
  zero errors and exactly one failure: entity `2142` z `20` was not in front of
  the duct/cache z `22`.
- Focused GREEN `reports/report_2362/results.xml` passed `1/1` with zero
  failure/error/flaky/skip/orphan after the z `24` scene fix.
- Related GREEN `reports/report_2363/results.xml` passed `7/7` across Story225,
  Story224, the Story223 production-combat analogue, and Story114/115 baselines.
- `reports/old_factory_service_sluice_production_combat_reward_cache_handoff_smoke.log`
  exited `0` with marker `story225_smoke=passed frames=180`.
- Godot MCP 3.0.4 session `cinderpaw@198e` used real `move_right`, real facing
  input and real `attack`. Clean run `r177921577-21` recorded target `2142`,
  `light`, `cat_claw_light`, damage `12`, Story114 cleared, Story115
  visible/claimable/unclaimed, Story116 hidden, helper-only game log, empty
  editor delta after cursor `2`, released inputs and a clean stop.
- A supplemental clean runtime probe captured the transient live-death state as
  `death`, visible, processing, non-physical and untargeted before despawn.
- Two non-empty MCP framebuffer responses at RGB `1278x718` show the active
  Spark Rat/Cinderpaw pocket and the cleared `+20 Gears` cache handoff.

## Dependencies

- Depends on: Story224 production service-hatch/service-sluice handoff and
  Stories114-115 baseline content.
- Unlocks: Story115 production reward input and Story116 exit-hatch handoff.

## Verification Summary

One thin integrated test closed the actual player path without adding another
combat system. RED isolated one visible defect, the scene fix was one property,
focused `1/1`, related `7/7`, smoke and MCP runtime/log/visual evidence passed,
and Story115 remains deliberately unclaimed for the next slice.
