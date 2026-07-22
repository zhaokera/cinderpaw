# Story 126: Old Factory Tailrace Exit Spillway Sluice Leech Skirmish

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Combat
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/ai-framework.md`, `design/gdd/feline-combat.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`, `design/art/art-bible.md`

**Requirements**: `TR-ai-001`, `TR-ai-003`, `TR-ai-007`, `TR-ai-008`,
`TR-scene-004`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision Detection; ADR-0005
Combat State Machine; ADR-0006 AI Behavior; ADR-0007 Scene Management.

Story124 leaves Cinderpaw beyond the crossed Tailrace Exit Spillway, and
Story125 gives that space a dedicated visual identity. Story126 converts the
next pocket into a short ACT combat peak and introduces the first planned
organic mutated-creature enemy family instead of reusing another Spark Rat or
Coil Rat. The Factory Sluice Leech uses a readable startup, a short forward
lunge, and complete generated frame animation while preserving the Tailrace
Relay savepoint and existing route history.

## Acceptance Criteria

- [x] `FactoryTailraceExitSluiceLeech` exists in
  `factory_route_transition_shell.tscn`, starts hidden/inactive, uses entity id
  `2146`, and is placed at `Vector2(17760, 482)`.
- [x] The skirmish remains unavailable until Story124's
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed`
  state is true. Crossing activation x `17360` reveals the enemy, assigns
  Cinderpaw as target, enables process/physics, and shows
  `Break Tailrace Sluice Leech`.
- [x] Factory Sluice Leech is a distinct enemy family
  `factory_sluice_leech` with a deterministic `18`-frame attack tell and a
  short forward lunge during active frames; its attack continues to use the
  shared CollisionComponent hitbox path and duplicate-hit protection.
- [x] The visible character uses `AnimatedSprite2D + SpriteFrames`. Generated
  transparent `96x96` PNGs live under
  `assets/characters/factory_sluice_leech/<animation>/`; `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` each contain exactly `3` frames
  with continuous names and a consistent ground anchor.
- [x] `scenes/characters/factory_sluice_leech.tscn`,
  `src/characters/factory_sluice_leech.gd`,
  `src/gameplay/factory_sluice_leech.tscn`, and
  `src/gameplay/factory_sluice_leech.gd` provide the presentation and runtime
  enemy surfaces without adding a new Autoload or bypassing shared combat
  components.
- [x] Defeating entity `2146` persists activated, defeated and cleared state,
  disables targeting/physics/collision, and preserves the visible three-frame
  live death presentation until its authored hold/fade completes. The current
  route objective advances to `Enter Sluice Matriarch Lair`; restored cleared
  state remains hidden and disabled.
- [x] Restoring only the Story126 cleared key backfills Story124 crossed state,
  prevents pincer/cache/hatch/spillway replay, and preserves the Story119
  Tailrace Relay savepoint payload.
- [x] Route support extends to right wall x `18120`, camera/background right
  `18140`, ground right edge `18240`, and at least `72` floor visuals.
- [x] The image-generation prompt, source, alpha source, preview, runtime
  frames, import details, and usage are recorded in the asset spec, manifest,
  entity inventory, and QA evidence.
- [x] Focused/related GdUnit, targeted headless smoke, and Godot MCP runtime
  checks pass under Godot 4.7 / Godot AI MCP 2.9.1. MCP confirms the character
  scene, six animations/frame counts, live activation/lunge/defeat state,
  clean current-run logs, and a non-empty screenshot containing the enemy.

## Out of Scope

- Additional enemies, pincer composition, reward cache, hatch, savepoint,
  route transition, minimap/fast travel, or SaveSystem schema changes.
- New status-effect gameplay, toxic damage-over-time, ranged attacks, boss
  behavior, authored audio, particles, shaders, or broader biome replacement.
- Refactoring the pre-existing Old Factory route state machine beyond the
  small Story126 integration points.

## Implementation Notes

- Keep the encounter to one enemy and roughly 10-20 seconds of combat. The new
  family and lunge read supply novelty; enemy count does not.
- Use a flat magenta chroma key because the creature includes restrained toxic
  green mutation highlights. Retain the generated source before alpha removal.
- Runtime balance stays local to the enemy subclass: startup `18` frames,
  attack damage `11`, and a short lunge. Do not introduce new data domains in
  this slice.
- Route objective priority is: Story126 active/cleared before Story124 crossed.
  Ready state keeps `Tailrace Exit Spillway Crossed` until activation.
- Story126 local state uses concise keys:
  `factory_tailrace_exit_sluice_leech_skirmish_activated`,
  `factory_tailrace_exit_sluice_leech_defeated`, and
  `factory_tailrace_exit_sluice_leech_skirmish_cleared`.

## QA Test Cases

- **AC-1: Generated character and lunge contract**
  - Given: the Factory Sluice Leech character/runtime scenes are loaded.
  - When: the enemy receives a target and advances through its attack tell.
  - Then: all six animations have three transparent `96x96` frames, startup is
    `18` frames, the attack becomes active through CollisionComponent, and the
    body moves toward the target during the lunge.
  - Edge cases: no movement before startup completes; no fourth animation frame;
    no opaque chroma-key corners.
- **AC-2: Route gate, clear, and restore**
  - Given: Story124 is either locked, crossed, or restored from Story126 clear.
  - When: Cinderpaw crosses x `17360`, defeats entity `2146`, and local state is
    restored in a fresh scene.
  - Then: locked/ready/active/cleared states, route labels, persistence,
    backfill, route bounds, and Tailrace Relay savepoint remain deterministic.
  - Edge cases: activation below threshold returns false; duplicate activation
    returns false; restored clear does not replay prior VFX or enemies.

## Test Evidence

**Story Type**: Integration + Gameplay Runtime + Frame Animation Contract

**Required evidence**:

- `tests/unit/gameplay/old_factory_tailrace_exit_spillway_sluice_leech_skirmish_test.gd`
- `tests/smoke/old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke.gd`
- `production/qa/evidence/old-factory-tailrace-exit-spillway-sluice-leech-skirmish-2026-07-11.md`

**Status**: [x] RED/GREEN focused evidence, adjacent regression, targeted smoke,
Godot import, and MCP runtime evidence complete.

- RED focused: `reports/report_1385/` captured the missing asset/runtime/API
  contracts before implementation.
- GREEN focused: `reports/report_1388/` passed Story126 `2/2` with no errors,
  failures, or warnings.
- Related GREEN: `reports/report_1390/` passed Story126 plus Story124, Story125,
  and Story121 suites `7/7`.
- Story235 adjacency correction: `reports/report_2408/results.xml` reproduced
  two obsolete immediate-hide assertions after shared live-death behavior was
  introduced; `reports/report_2409/results.xml` passed Story126 `2/2`, and
  final related `reports/report_2410/results.xml` passed `7/7` under Godot 4.7.
- Headless smoke:
  `reports/old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke.log`
  exited `0` and printed
  `old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke=passed`.
- Godot MCP evidence:
  `production/qa/evidence/old-factory-tailrace-exit-spillway-sluice-leech-skirmish-2026-07-11.md`.

## Dependencies

- Depends on: Story124 Tailrace Exit Spillway Traverse and Story125 Tailrace
  Exit Spillway Visual Pass.
- Unlocks: deeper Tailrace route handoff or chapter-exit work after Story126.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Entity `2146`, route gate, activation, labels, and bounds | `reports/report_1388`; MCP runtime eval | COVERED |
| Distinct family, 18-frame tell, lunge, and CollisionComponent hit path | Focused GdUnit; targeted smoke; MCP runtime eval | COVERED |
| Six 3-frame transparent 96x96 animations and character scenes | Focused GdUnit; image audit; MCP scene/runtime inspection | COVERED |
| Defeat, persistence, Story124 backfill, and Story119 checkpoint preservation | `reports/report_1388`; smoke; MCP defeat/restore eval | COVERED |
| Adjacent spillway/pincer behavior remains intact | `reports/report_1390` | COVERED |
| Godot 4.7 import, clean current run, and non-empty screenshot | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-07-11
**Criteria**: 10/10 passing
**Deviations**: Runtime frames are `96x96` rather than the Art Bible's generic
`64x64` small-enemy target so the enemy matches the established Old Factory
character contract; this exception is recorded in the asset spec. The route
ships with `73` floor visuals, exceeding the required minimum of `72`. One
Story124 assertion was updated to the Story125 dedicated spillway texture
because the previous expectation described superseded content rather than a
runtime regression.
**QA Evidence**:
`production/qa/evidence/old-factory-tailrace-exit-spillway-sluice-leech-skirmish-2026-07-11.md`
