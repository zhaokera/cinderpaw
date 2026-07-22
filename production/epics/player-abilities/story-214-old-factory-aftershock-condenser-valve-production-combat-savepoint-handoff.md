# Story 214: Old Factory Aftershock Condenser Valve Production Combat Savepoint Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Production Movement + Production Combat + Live Death + Savepoint Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story213 crosses the cooling duct and exposes Story094 without starting it in
the same frame. Story214 closes the next player-visible ACT beat: Cinderpaw must
advance under real movement input to start the condenser ambush, defeat both
animated enemies through the production combat path, and receive a readable
handoff to Story095 without silently consuming the savepoint interaction.

**GDD**: `design/gdd/feline-combat.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005
Combat state machine; ADR-0006 Enemy AI; ADR-0007 Scene management. The Story
inherits ADR-0018 Player abilities and ADR-0021 Save system without changing
their contracts.

## Acceptance Criteria

- [x] Standing at or beyond x `3920.0` cannot activate Story094 while
  Cinderpaw is stationary; a fresh production `move_right` advance must cross
  the tracked boundary.
- [x] Activation enables both entity `2136` and `2137` hurtboxes, targets and
  processing through the existing animated Spark Rat and Coil Rat scenes.
- [x] The opening stages one enemy ahead and one behind Cinderpaw with at least
  `128px` player flank distance and `304px` enemy-center separation; the
  existing opening grace remains `10` frames for Spark and `22` for Coil.
- [x] Production `attack` input with `cat_claw_light` can defeat each live
  enemy; a defeated enemy keeps its `death` animation visible and processing,
  while physics, targeting, collision and bite hitbox are disabled.
- [x] After both deaths, Story094 is cleared and each enemy completes the
  existing three-frame death plus corpse-hold/fade lifecycle before cleanup.
- [x] Story095 becomes visible and contact-ready after clear, but remains
  unactivated in the lethal frame even when Cinderpaw is already inside its
  contact radius; normal contact consumption may occur on a later physics step.
- [x] One canonical GdUnit RED/GREEN, the bounded Story093/094/095 regression,
  Factory headless smoke and one Godot MCP runtime acceptance pass under Godot
  4.7 / Godot AI MCP 3.0.4.

## Out of Scope

Activating or respawning from Story095, Story096 outlet traversal, new enemy or
player art, new combat moves, authored audio, shaders, broad Factory scene
replacement, and SaveSystem schema changes.

## Asset Pipeline

No new visual asset is required. This Story reuses the generated
`factory_spark_rat` and `factory_coil_rat` `AnimatedSprite2D + SpriteFrames`
resources plus the existing generated condenser valve and savepoint props.

## Test Evidence

- Canonical GdUnit:
  `tests/unit/gameplay/old_factory_aftershock_condenser_valve_production_combat_savepoint_handoff_test.gd`
  - Initial RED: `reports/report_2292/results.xml` (`1` case, `6`
    expected failures covering stationary activation, pincer spacing and live
    death presentation).
  - Final focused GREEN: `reports/report_2297/results.xml` (`1/1`).
- Related regression:
  `reports/report_2298/results.xml` passed `6/6` across Story213,
  Story094, Story095 and Story214 with zero
  failure/error/flaky/skip/orphan.
- Factory smoke:
  `reports/old_factory_aftershock_condenser_valve_production_combat_savepoint_handoff_smoke.log`
  ran `180` fixed-FPS frames and exited `0`; no project parse/script,
  invalid-call/access or missing-resource error was found. Existing
  ObjectDB/resource cleanup lines remained stdout-only.
- Godot MCP: Godot AI MCP `3.0.4` on Godot `4.7`, session
  `cinderpaw@1b14`, accepted run `r149702722-5`, verified scene reload,
  stationary rejection, real `move_right` activation, real `attack` deaths,
  live `death` animation state, Story094 clear, Story095 visible/available but
  inactive in the lethal frame, released inputs, clean project logs and a
  non-empty RGB `1278x718` screenshot:
  `reports/visual/cinderpaw-mcp-aftershock-condenser-valve-production-combat-savepoint-handoff-20260722.png`
  (SHA-256
  `7a5906d04274a1696ca7f4601fc8a3bb38082f7b27228820694361b59657a5b4`).

## Dependencies

- Depends on: Story213 production cooling-duct handoff; Story094 condenser
  valve ambush; Story095 condenser savepoint.
- Unlocks: Story095 production interaction and Story096 outlet continuation.

## Verification Summary

The canonical RED isolated six missing production expectations. Focused GREEN
passed `1/1`, the bounded Story213/094/095/214 regression passed `6/6`, and the
Factory smoke exited `0`. The final MCP run completed the player-visible
movement, combat, live-death and savepoint-handoff path without activating the
savepoint in the lethal frame. No new visual asset or full-suite run was needed.
