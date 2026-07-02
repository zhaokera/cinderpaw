# Story 009: Boss Phase Transition Signal Contract

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: 3 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`
**Requirement**: `TR-combatfx-006`

**ADR Governing Implementation**: ADR-0002: Signal communication
**ADR Decision Summary**: Combat presentation must consume gameplay state through
Godot signals instead of direct Core method calls.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Use typed direct signal connections and keep the payload at
three arguments or fewer.

---

## Acceptance Criteria

- [x] BossConfigComponent emits `on_boss_phase_transition_started(entity_id, phase, metadata)` only when the queued phase transition actually starts.
- [x] If Health emits a phase threshold while AI is attacking, no presentation-facing transition-start signal emits until the AI reports idle.
- [x] HealthComponent threshold ordinal signals map to actual Boss phase IDs so threshold 1 starts phase 2 and threshold 2 starts phase 3.
- [x] Cross-threshold damage preserves phase start order and emits one start signal per actual phase.
- [x] Foreign entity Health phase signals do not emit transition-start events.
- [x] Metadata includes boss identity, HP percentage, transition duration, animation id, attack patterns, speed modifier, special attacks, and arena changes for downstream presentation/audio/HUD consumers.

## Implementation Notes

Add a presentation-facing signal to BossConfigComponent from the point where
`_start_next_transition()` begins, not from HealthComponent's raw
`on_boss_phase_change`. This ensures visual, audio, and HUD consumers play
phase feedback after active boss attacks complete and the invulnerability window
starts.

## Out of Scope

- New boss phase VFX, animation, audio, HUD layout, or image-generated assets.
- Changes to HealthComponent's existing signal signature.
- Boss-specific scene instantiation.

## QA Test Cases

- **AC-1**: AI attack gate
  - Given: Health emits the first phase threshold while AI reports `active`.
  - When: BossConfigComponent advances transition processing.
  - Then: no transition-start signal emits until AI reports `none`.

- **AC-2**: Metadata contract
  - Given: phase 2 starts.
  - When: the transition-start signal emits.
  - Then: metadata contains the fields required by presentation consumers.

- **AC-3**: Cross-threshold order
  - Given: Health emits threshold ordinal 1 and 2 for one damage event.
  - When: BossConfigComponent processes queued transitions.
  - Then: phase 2 starts before phase 3 and each emits exactly once.

- **AC-4**: Entity filtering
  - Given: BossConfigComponent is configured for entity 42.
  - When: Health emits a phase signal for entity 7.
  - Then: no transition-start signal emits.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/boss/story_007_phase_transition_start_signal_contract_test.gd`

**Status**: [x] Created and passing

**Evidence**:
- RED: `reports/report_358/` failed because `BossConfigComponent` did not expose
  `on_boss_phase_transition_started`.
- GREEN: `reports/report_359/` passed Story009 focused tests `3/3`.
- Regression: `reports/report_360/` passed Boss 001-007, Health phase, and AI
  phase/focus related suites `39/39`.
- Headless smoke: `reports/boss_phase_transition_signal_contract_main_scene_smoke.log`
  exited `0`; log scan found no error or warning matches.
- Godot MCP: session `cinderpaw@c1b2` ran `res://scenes/main.tscn`; runtime
  probe loaded BossConfigComponent, mapped Health threshold ordinal `1` at
  `0.65` HP to actual phase `2`, emitted `phase_2_rebuild` metadata, and final
  game/editor logs were clean.
- Asset note: no image-generated visual asset was required for this signal
  contract slice.

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1, AC-2 | `test_transition_started_signal_waits_for_ai_idle_and_emits_metadata_once` | COVERED |
| AC-3 | `test_health_threshold_ordinals_preserve_actual_phase_start_order` | COVERED |
| AC-4 | `test_transition_started_signal_filters_foreign_entity_health_events` | COVERED |

## Dependencies

- Depends on: Boss Configuration Story 002 Complete.
- Unlocks: Combat Presentation boss phase feedback.

## Completion Notes

**Completed**: 2026-06-24
**Criteria**: 6/6 passing
**Deviations**: None. This story intentionally stops at the Core signal
contract required by downstream presentation, HUD, and audio consumers; authored
boss phase VFX remain in a follow-up story.
