# Story 220: Old Factory Aftershock Condenser Overflow Pump Runoff Hatch Production Input Duct Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Input + Hazard Handoff
> **Type**: Integration + Production Input + Production Movement + Hazard Timing + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story219 leaves Story106's runoff hatch visible, blocking and unopened after
the overflow-pump reward is claimed. Story220 closes the next playable ACT
loop: a fresh production interaction opens a shape-readable hatch, real
movement starts Story107, the live runoff steam cycle damages through its
connected `Area2D`, and crossing hands control to Story108 without consuming
the same frame.

**GDD**: `design/gdd/input.md`, `design/gdd/collision-detection.md`,
`design/gdd/scene-management.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-input-001`, `TR-collision-004`, `TR-scene-004`,
`TR-explore-005`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0007 Scene Management.
The existing persistence schema is unchanged.

## Acceptance Criteria

- [x] Story106's runoff hatch participates in the production nearest-provider
  interaction route. Holding `interact` before entering range stays stale;
  releasing and pressing it again in range opens the hatch exactly once.
- [x] Opening persists the existing Story106 flag, disables the blocker, hides
  the prompt and plays one unlock burst without replay on later interaction.
- [x] The open hatch is shape-readable: its visual moves to `(48,-136)`, rotates
  `6deg`, renders at effective z `23` above the duct (`22`) and below Cinderpaw
  (`26`), while the interaction/collision root remains fixed.
- [x] Opening only reveals Story107. Same-frame input, stationary frames and a
  no-input displacement beyond x `7160` cannot activate the duct.
- [x] A later held `move_right` with fresh positive x movement across x `7160`
  starts Story107 in `grace` through production `_process(delta)`.
- [x] Production time advances `grace -> warning -> active -> safe`; only the
  active phase enables the connected runoff vent contact.
- [x] Physical contact applies exactly `8` steam damage with source id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct`.
- [x] Real movement across x `7560` persists Story107 crossed, disables hazard
  contact and reveals Story108 as available while its Coil Rat remains
  inactive, hidden, non-processing and non-physical.
- [x] A crossing frame at Story108's own threshold cannot activate Story108;
  downstream availability is consumed only from a later frame.
- [x] Existing imported image-generated hatch, duct, vent, Factory and
  Cinderpaw assets remain in use; no placeholder or new asset is introduced.
- [x] Thin RED/GREEN, nine-suite bounded regression, Factory smoke and Godot
  4.7 / Godot AI MCP 3.0.4 runtime/log/three-screenshot acceptance pass.

## Out of Scope

Story108 production combat, Story109 reward interaction, new art/audio/VFX,
enemy/player balance, SaveSystem schema changes, service lift, Boss2, Rat King
Phase III and full-suite testing.

## Implementation Notes

- Story106's existing endpoint is added to the shared nearest progression
  interaction candidates; rising-edge arbitration and endpoint APIs remain
  unchanged.
- Story107 now owns a previous-x snapshot and requires frame-start
  availability, `move_right` and positive displacement before activation.
- Factory `_process(delta)` advances and completes Story107 once per frame.
  Story108 activation receives a frame-start availability snapshot, preventing
  a Story107 crossing from chaining the encounter in the same frame.
- Story108's bounded regression was aligned with the established live-death
  contract: a defeated Coil Rat keeps its three-frame death presentation while
  physics and targeting stop; restored cleared state remains hidden.

## Asset Use

No image generation was required. The Story reuses already registered and
imported image-generated Cinderpaw, runoff hatch, cooling duct, steam vent and
Old Factory environment assets.

## Verification Evidence

- Canonical RED `reports/report_2335/results.xml` failed `0/1` with `23`
  expected production/input/timing/handoff assertions.
- Focused GREEN `reports/report_2337/results.xml` passed `1/1`.
- Completion spot-check `reports/report_2340/results.xml` reran the canonical
  Story220 suite at `1/1` with zero error/failure/flaky/skip/orphan.
- Final related `reports/report_2339/results.xml` passed nine suites and
  `13/13` tests with zero failure, error, flaky, skip or orphan. It covers
  Stories106-108, Story219, prior hatch/duct production slices and shared
  progression interaction. No full suite was run.
- Factory `180`-frame smoke exited `0` with no matching project error or
  shutdown leak:
  `reports/old_factory_aftershock_condenser_overflow_pump_runoff_hatch_production_input_duct_handoff_smoke.log`.
- Godot MCP 3.0.4 session `cinderpaw@198e` used real held/fresh `interact`,
  real `move_right`, production `_process`, and the connected vent `Area2D`.
  It observed stale approach rejection, one open VFX, x `7154 -> 7195.33`
  activation in `grace`, active contact HP `100 -> 92`, safe contact shutdown,
  and x `7554 -> 7586.33` crossing with Story108 available/inactive/hidden.
- The accepted final run `r161548718-2` had helper-only game log, no editor
  entries after cursor `2`, released inputs and a clean stop at editor readiness
  `ready`. A preliminary input probe was restarted after the MCP eval itself
  queried overlaps on a disabled monitor; no project-code error was involved.
- Non-empty RGB `1278x718` captures:
  - `reports/visual/cinderpaw-mcp-overflow-pump-runoff-hatch-production-input-open-20260722.png`, SHA-256 `59c9638125faa5b7560e7feac1d5218e7c5a6f8af3ddcfa258b1a95eeeda9c1a`.
  - `reports/visual/cinderpaw-mcp-overflow-pump-runoff-duct-production-hazard-active-20260722.png`, SHA-256 `3003ab9f5e3ce72808605490e4eea85139327466ac16f2b92b0f9e86c4fd7c1d`.
  - `reports/visual/cinderpaw-mcp-overflow-pump-runoff-duct-production-handoff-crossed-20260722.png`, SHA-256 `8b303aee4ba7dada2e127bf8e9f37acf2c0ac933eeac524a548758084b699540`.

## Dependencies

- Depends on: Story219 production combat/reward handoff; Story106 hatch and
  Story107 hazard baselines.
- Unlocks: Story108 production movement/combat and Story109 reward-cache
  handoff.

## Verification Summary

One integrated production test drove hatch input, movement-gated hazard
activation, timing/contact, crossing and downstream isolation. Focused `1/1`,
related `13/13`, smoke, clean MCP logs and three visible runtime states passed
without new assets or persistence-schema changes.
