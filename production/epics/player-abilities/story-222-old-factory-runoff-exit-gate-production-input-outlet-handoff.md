# Story 222: Old Factory Runoff Exit Gate Production Input Outlet Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Input + Hazard Handoff
> **Type**: Integration + Production Input + Production Movement + Hazard Timing + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story221 leaves Story109's runoff-exit gate visible, blocking and unopened
after the reward is claimed. Story222 closes the next playable ACT loop: a
fresh production interaction opens a shape-readable gate, real movement starts
Story110, the live outlet steam cycle deals physical damage, and crossing hands
control to Story111 without allowing stationary or stale-input activation.

**GDD**: `design/gdd/input.md`, `design/gdd/collision-detection.md`,
`design/gdd/scene-management.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-input-001`, `TR-collision-004`, `TR-scene-004`,
`TR-explore-005`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0007 Scene Management.
The existing persistence and ability architecture are unchanged.

## Acceptance Criteria

- [x] Story109's runoff-exit gate participates in the production nearest
  progression interaction route. Holding `interact` before entering range stays
  stale; release/rearm plus a fresh in-range press opens it exactly once.
- [x] Opening persists the existing gate flag, disables its blocker, hides its
  prompt and emits one unlock burst without replay.
- [x] The open gate is shape-readable: its visual moves to `(48,-136)`, rotates
  `6deg` and renders at effective z `23`, between the duct (`22`) and Cinderpaw
  (`26`), while the interaction/collision root remains fixed.
- [x] Opening only reveals Story110. Same-frame input, stationary frames and a
  no-input placement at x `8484` cannot activate the outlet traverse.
- [x] A later held `move_right` with fresh positive x displacement across x
  `8480` starts Story110 in `grace` through production `_process(delta)`.
- [x] Production time advances `grace -> warning -> active -> safe`; only the
  active phase enables the connected outlet vent contact.
- [x] Physical contact applies exactly `8` steam damage with source id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet`.
- [x] Real movement across x `9060` persists Story110 crossed, disables hazard
  contact and reveals Story111 as available while the Spark Rat remains
  inactive, hidden, non-processing, non-physical and untargeted.
- [x] No-input placement at x `9284` plus later stationary frames cannot start
  Story111; it still requires a later frame with actual positive-x movement.
- [x] Story111's reused Spark Rat retains six gameplay animations with three
  frames each through `AnimatedSprite2D + SpriteFrames`.
- [x] Existing imported image-generated gate, duct, vent, Factory, Cinderpaw
  and Spark Rat assets remain in use; no placeholder or new asset is added.
- [x] Thin RED/GREEN, seven-suite bounded regression, Factory smoke and Godot
  4.7 / Godot AI MCP 3.0.4 runtime/log/three-screenshot acceptance pass.

## Out of Scope

Story111 combat activation/clear, new art/audio/VFX, enemy/player balance,
SaveSystem schema changes, service-sluice content, Boss2, Rat King Phase III
and full-suite testing.

## Implementation Notes

- Story109's existing gate is added to the shared nearest progression
  interaction candidates; centralized rising-edge arbitration remains intact.
- Story110 owns a resettable previous-x snapshot and consumes frame-start
  availability. Production activation requires `move_right`, positive x
  displacement and the x `8480` threshold.
- Story111 uses the same frame-start availability and movement guard. Crossing
  Story110 or placing the player beyond x `9280` without input therefore cannot
  start the skirmish.
- A related Story111 assertion was aligned with the established live-death
  contract: `death` remains visible/processing while physics and combat
  participation stop.

## Asset Use

No image generation was required. Existing registered/imported image-generated
runoff-exit gate, aftershock cooling duct, steam vent, Cinderpaw and Factory
Spark Rat frame-animation assets fully cover this production slice.

## Verification Evidence

- Canonical RED `reports/report_2344/results.xml` failed `0/1` with ten
  expected production input, movement, hazard and handoff gaps.
- Initial focused GREEN `reports/report_2345/results.xml` passed `1/1`.
- Boundary RED `reports/report_2348/results.xml` isolated two stationary
  Story111 activation failures after Story110 crossing.
- Final focused GREEN `reports/report_2349/results.xml` passed `1/1`.
- Final related `reports/report_2350/results.xml` passed seven suites and
  `11/11` tests with zero failure, error, flaky, skip or orphan. It covers
  Story222, Story221, the analogous Story220 production loop, Stories109-111
  and shared progression interaction. No full suite was run.
- Factory `180`-frame smoke exited `0` with no matching project error or
  shutdown leak:
  `reports/old_factory_runoff_exit_gate_production_input_outlet_handoff_smoke.log`.
- Godot MCP 3.0.4 session `cinderpaw@198e`, accepted run token `9`
  (`r165369444-9`), used stale/fresh `interact`, actual `move_right`, production
  `_process(delta)` and the connected outlet vent `Area2D`.
- The run proved one gate open VFX, open visual `(48,-136)` / `6deg` / effective
  z `23`, no-input x `8484` rejection, real movement x `8475.334 -> 8482`
  activation, active contact HP `100 -> 92`, and real movement x
  `9055.334 -> 9060.223` crossing.
- Story111 remained available/inactive/hidden/non-processing/non-physical and
  untargeted after crossing and after a no-input x `9284` stationary probe.
  Game log was helper-only, editor log after cursor `2` was empty, inputs were
  released, and playback stopped at readiness `ready`.
- Non-empty RGB `1278x718` captures:
  - `reports/visual/cinderpaw-mcp-runoff-exit-gate-open-20260722.png`, SHA-256 `89c3346d72fabaae9ecae96588655a96e63a72d2a17975e465334d0752531c95`.
  - `reports/visual/cinderpaw-mcp-runoff-outlet-active-20260722.png`, SHA-256 `27b16a5140e2f3fc3a8341e2c636dae823a662ca1ae72f5e832582a78e078317`.
  - `reports/visual/cinderpaw-mcp-runoff-outlet-crossed-handoff-20260722.png`, SHA-256 `b2350aed5c747475fb95fa16d3dc14f2bb00f6e1a2483fff10236f3a3bc2d207`.

## Dependencies

- Depends on: Story221 production combat/reward handoff; Story109 gate,
  Story110 outlet and Story111 skirmish baselines.
- Unlocks: Story111 production movement/combat closure and deeper
  service-sluice content.

## Verification Summary

One integrated production test drove gate input, movement-gated hazard
activation, physical damage, crossing and downstream isolation. Final focused
`1/1`, related `11/11`, smoke, clean MCP logs and three visible runtime states
passed without new assets or persistence-schema changes.
