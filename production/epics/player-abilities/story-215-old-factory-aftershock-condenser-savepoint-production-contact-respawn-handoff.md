# Story 215: Old Factory Aftershock Condenser Savepoint Production Contact Respawn Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Death/Respawn
> **Type**: Integration + Production Movement + Contact Activation + Death/Respawn + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story214 clears the condenser ambush and exposes Story095 without consuming it
in the lethal frame. Story215 closes the next player-visible ACT beat:
Cinderpaw must physically move into the repair relay, activate it exactly once,
die through the production player-death path, and revive at that relay while
Story096 is revealed but not silently started.

**GDD**: `design/gdd/death-respawn.md`,
`design/gdd/scene-management.md`, `design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-respawn-001`, `TR-respawn-002`, `TR-scene-004`,
`TR-explore-005`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0021 Save system. ADR-0018 remains inherited without changing
the player ability contract.

## Acceptance Criteria

- [x] With Story094 cleared, the relay is visible and contact-ready but remains
  inactive while Cinderpaw is outside its `112px` `Area2D` contact shape.
- [x] Real production `move_right` movement from outside to inside the relay
  triggers `SavepointRuntime.body_entered` exactly once without `interact` or a
  direct Story activation call.
- [x] Activation persists the condenser savepoint snapshot, plays one existing
  generated activation burst, disables further contact, hides the stale
  `Repair Condenser Relay` prompt, and shows route feedback
  `Aftershock Condenser Savepoint Secured`.
- [x] A real lethal `PlayerController.apply_damage()` enters the animated
  `death` state and production `GameFlowController` death flow; after the
  `1.5s` death hold, Cinderpaw revives at the condenser savepoint with `50%`
  HP, `revive` animation, respawn flash and route feedback
  `Returned to Aftershock Condenser Savepoint`. Control remains locked through
  the authored `2.0s` revive protection, then returns to `playing`.
- [x] Story096 becomes visible and available after relay activation but remains
  inactive in the contact and respawn frames; outlet hazard contact stays off
  after a no-input threshold teleport and until a later fresh production
  traverse reaches its activation boundary.
- [x] One canonical GdUnit RED/GREEN, bounded Story095/096/214 regression,
  Factory headless smoke and one Godot MCP runtime acceptance pass under Godot
  4.7 / Godot AI MCP 3.0.4.

## Out of Scope

Traversing or completing Story096, Story097 combat, new visual/audio assets,
new player/enemy animation frames, SaveSystem schema changes, full Factory
scene replacement, Boss content and broad death/respawn refactors.

## Asset Pipeline

No new visual asset is required. This Story reuses the generated condenser
savepoint, outlet, unlock burst and Cinderpaw `AnimatedSprite2D + SpriteFrames`
death/revive animations already registered in the project asset pipeline.

## Test Evidence

- Canonical GdUnit:
  `tests/unit/gameplay/old_factory_aftershock_condenser_savepoint_production_contact_respawn_handoff_test.gd`
  - Refined initial RED: `reports/report_2300/results.xml` (`1` case with
    expected prompt/control failures; it also exposed unsafe synchronous
    scene mutation during `body_entered`).
  - Boundary hardening RED: `reports/report_2303/results.xml` proved a
    stationary no-input threshold teleport could incorrectly start Story096.
  - Pending-transition RED: `reports/report_2305/results.xml` proved the old
    current spawn could overwrite an in-flight savepoint respawn.
  - Final focused GREEN: `reports/report_2306/results.xml` (`1/1`).
- Related regression:
  `reports/report_2307/results.xml` passed `6/6` across Story214, Story095,
  Story096 and Story215 with zero failure/error/flaky/skip/orphan.
- Factory smoke:
  `reports/old_factory_aftershock_condenser_savepoint_production_contact_respawn_handoff_smoke.log`
  ran `180` fixed-FPS frames and exited `0`; no project parse/script,
  invalid-call/access or missing-resource error was found. Existing
  ObjectDB/resource cleanup lines remained stdout-only.
- Godot MCP: Godot AI MCP `3.0.4` on Godot `4.7`, session
  `cinderpaw@1b14`, accepted run `r151899297-9`, verified real movement from
  outside contact, one savepoint activation, hidden prompt, persisted snapshot,
  live `death`, `revive` at `50/100` HP and distance `0` from the relay,
  restored control, Story096 available/visible but inactive, released inputs,
  helper-only game log, empty editor log and a non-empty RGB `1278x718`
  screenshot:
  `reports/visual/cinderpaw-mcp-aftershock-condenser-savepoint-production-contact-respawn-handoff-20260722.png`
  (SHA-256
  `e82fbeafdad2bc2c39abb8daa8cedea387c60e0628e348d6291b0db4bfa74310`).

## Dependencies

- Depends on: Story214 production combat/savepoint handoff; Story095 condenser
  savepoint; Story096 condenser outlet traverse.
- Unlocks: Story096 production movement/hazard traversal.

## Verification Summary

The focused Story215 test passed `1/1`, and the bounded
Story214/095/096/215 regression passed `6/6`. Factory smoke exited `0`. The
final clean MCP run completed the real contact, savepoint snapshot,
death/revive and control-restoration path while keeping Story096 idle until a
later fresh movement. No new visual asset or full-suite run was needed.
