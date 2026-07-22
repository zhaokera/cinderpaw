# Story 191: Old Factory Forward Pressure Counter-Ambush Production Movement Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Movement
> **Type**: Integration + Gameplay Runtime + Production Movement + Combat Readability
> **Estimate**: S
> **Manifest Version**: 2026-07-21
> **Last Updated**: 2026-07-21

## Context

Story070 authored the forward-pressure counter-ambush, entity `2119`, its
animated steam hazard and persistence contract, but the Factory production loop
did not activate it from normal movement. The authored vent also became
contact-active immediately on activation and its hazard id was absent from the
shared Factory steam-damage allowlist, producing an unfair trigger geometry
that still dealt no damage through the authoritative path.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Governing ADRs**: ADR-0002 Event Bus; ADR-0004 Collision Detection;
ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene Management;
ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] From a valid Story190-complete local state, real `move_right` and
  production physics cross inclusive `x=1336` and activate Story070 without a
  direct activation call.
- [x] Entity `2119` becomes visible and processing with Cinderpaw as its target;
  `idle`, `run`, `attack_tell`, `attack`, `hurt` and `death` each contain at
  least three frames.
- [x] The counter vent becomes visible immediately but remains non-contacting
  for the authored 18-frame opening grace, preventing unavoidable spawn damage.
- [x] After grace expires, the vent becomes contact-active and deals `8` steam
  damage through the shared Factory hazard path with a `1.0` second per-target
  cooldown.
- [x] Active HUD reads `Survive Forward Pressure Ambush`; enemy and steam render
  at effective `z=26`, above hatch `z=25` and lift `z=24`.
- [x] Story069 remains crossed/inactive, Story071 reward content and the exit
  guard remain hidden/locked, and the optional service lift remains idle.
- [x] Thin RED/GREEN, bounded related regressions, a 180-frame Factory smoke
  and Godot MCP 3.0.4 real-input acceptance pass under Godot 4.7.

## Out Of Scope

Story070 combat rebalance, new enemy attacks, Story071 reward-cache production
input, the later exit-guard handoff, service-lift routing, save-schema changes,
new audio and new visual assets.

## Implementation Notes

- Factory production `_process()` invokes Story070 after Story069 activation,
  timing and completion, preserving the authored progression order.
- Activation starts a scene-local 18-frame vent grace counter before syncing
  collision. The vent and four-frame active steam remain visible during grace;
  monitoring, layer, mask and shape enable only when the counter reaches zero.
- Restoring an active counter-ambush restarts the same safety window, matching
  the enemy opening pacing and avoiding immediate load damage. Defeat clears
  the transient counter and disables the vent.
- `old_factory_lower_deck_forward_pressure_counter_ambush` is now accepted by
  the existing shared steam damage/cooldown implementation; no parallel damage
  system was added.

## Asset Use

No image-generation request was needed. The slice reuses the imported and
manifest-listed Factory Spark Rat `AnimatedSprite2D` resource at
`assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres` and
the four-frame steam resource at
`assets/environment/old_factory_steam_vent/factory_steam_vent_sprite_frames.tres`.
The steam prompt/source remains recorded at
`assets/environment/old_factory_steam_vent/source/factory_steam_vent_motion_sheet_imagegen_20260716.md`.
No placeholder or single-frame character was added.

## Verification Evidence

- Initial production RED `reports/report_2134/report_1/results.xml` captured the missing
  movement wiring and depth contract. Safety refinement RED
  `reports/report_2137/results.xml` failed the two intended opening-grace
  assertions.
- Final focused GREEN `reports/report_2138/results.xml` passed `3/3`.
- Final related GREEN `reports/report_2139/results.xml` passed five suites at
  `10/10`, with zero failures, errors, flaky cases, skips or orphans.
- Godot 4.7 loaded the Factory scene for `180` fixed frames and exited `0`;
  `reports/old_factory_forward_pressure_counter_ambush_production_movement_handoff_smoke.log`
  contains no project parse, script, invalid-call/access, warning or error.
- Godot AI MCP 3.0.4 accepted clean run `r95391117-5`. Real input moved
  Cinderpaw from `x=1335.9` to `x=1337.5667`; the opening sample reported
  visible steam, `hazard_grace_frames=6`, contact inactive and HP `100`.
  Natural expiry reported grace `0`, contact active and HP `92`, with the exact
  Story070 hazard id recorded as the damage source.
- Runtime diagnostics confirmed entity/animation, objective, depth, downstream
  locks and idle-lift contracts. Current-run game logs contained helper
  registration only; editor logs were empty and stop restored `ready`.
- Accepted non-empty `1278x718` screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-counter-ambush-production-movement-handoff-active-20260721.png`.
- Full evidence:
  `production/qa/evidence/old-factory-forward-pressure-counter-ambush-production-movement-handoff-2026-07-21.md`.

**Status**: [x] Complete.
