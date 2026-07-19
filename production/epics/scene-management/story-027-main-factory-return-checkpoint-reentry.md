# Story 027: Main Factory Return Checkpoint Reentry

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration
> **Type**: Integration / SceneManager / Persistence
> **Estimate**: S
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/scene-management.md`,
`design/gdd/player-abilities.md`, `design/gdd/save-system.md`

**Requirements**: `TR-scene-001`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0007: Scene management architecture,
ADR-0021: Save data schema

Story038 made Main's post-service-lift route readable but deliberately kept its
destination fixed at `area_03_factory/factory_gate_entry`. Story025 later
completed the repaired Factory return checkpoint. Reusing the Main shortcut
still discarded that newer spawn contract and sent the player back to the
first-entry gate.

Story027 supersedes only Story038's fixed-spawn condition. The Sewer
Double-Jump junction remains the sole owner of first Factory entry, and the
Main shortcut remains unavailable until the complete service-lift return
contract exists.

**Engine**: Godot 4.7 | **Risk**: LOW

## Acceptance Criteria

- [x] A complete service-lift return plus
  `factory_return_checkpoint_activated=true` makes Main expose and request
  `area_03_factory/return_checkpoint`.
- [x] Missing or false checkpoint state rewrites the Main shell back to
  `factory_gate_entry`; a prior synchronized value cannot remain sticky.
- [x] Missing or incomplete service-lift return state keeps the Main shortcut
  locked, and first Factory entry through the Sewer remains unchanged.
- [x] SceneManager commits `area_03_factory/return_checkpoint`, the Factory
  runtime applies the checkpoint spawn and shows
  `Returned to Factory Savepoint`.
- [x] Activating the older return checkpoint during reentry cannot replace an
  already-recorded deeper savepoint in the same Factory scene.
- [x] Existing route roundtrip, Scrap Roost return hub, return checkpoint and
  transition-shell contracts remain green.
- [x] Intentional RED evidence, focused GREEN, bounded related regression and
  one clean Godot MCP real-input acceptance are recorded without a full suite.

## Implementation Notes

- `MainScene._sync_factory_route_transition_shell()` derives the spawn on every
  synchronization. It chooses `return_checkpoint` only when both the complete
  service-lift return contract and the dedicated checkpoint flag are present;
  otherwise it writes `factory_gate_entry` explicitly.
- `OldFactoryEntranceScene` retains an existing non-empty same-Factory
  checkpoint whose spawn is deeper than `return_checkpoint` when the older
  repair station emits its activation signal during reentry.
- The change uses the existing SceneManager scene-state dictionary and
  SavepointRuntime contract. It adds no registry entry, SaveSystem schema,
  scene node or gameplay state.
- No visual asset was required. Existing image-generated Factory presentation
  and existing frame-animated characters remain authoritative.

## Out of Scope

- Sewer first-entry ownership, route unlock requirements, service-lift exit
  input, Factory combat, rewards, Lower Deck progression or balance.
- Choosing among every deeper Factory spawn from Main; this Story only routes
  the repaired Main shortcut to the established return checkpoint.
- SaveSystem schema, scene registry, new room, enemy, audio, art or animation
  changes.
- Service-lift arrival, docked-idle and departure animation. That is a separate
  image-generation and Godot animation Story.

## Test Evidence

- Main route RED: `reports/report_2034/results.xml` ran three cases and recorded
  two expected failures because both diagnostics and the SceneManager request
  still used `factory_gate_entry`.
- Main route GREEN: `reports/report_2035/results.xml` passed `3/3` with zero
  errors, failures, flaky cases, skips or orphans.
- Deeper-checkpoint regression RED: `reports/report_2037/results.xml` ran the
  existing eight-case checkpoint suite and recorded two expected failures when
  the old repair station downgraded the deeper checkpoint id and spawn.
- Deeper-checkpoint GREEN: `reports/report_2038/results.xml` passed `8/8` with
  zero errors, failures, flaky cases, skips or orphans.
- Final related GREEN: `reports/report_2039/results.xml` passed five suites and
  `17/17` cases with zero errors, failures, flaky cases, skips or orphans. No
  full suite ran.
- Godot MCP 3.0.2 run `r360343098-123` in Godot 4.7 used the production
  `move_right` action to enter Main's route trigger from outside its radius,
  observed pending `area_03_factory/return_checkpoint`, committed the runtime
  swap and verified the repaired checkpoint, route label, non-empty
  `1278x718` screenshot and clean game/editor logs.
- Detailed evidence:
  `production/qa/evidence/main-factory-return-checkpoint-reentry-2026-07-19.md`.
