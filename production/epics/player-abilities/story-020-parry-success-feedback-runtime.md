# Story 020: Parry Success Feedback Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Visual/Feel + Audio
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/feline-combat.md`,
`design/gdd/combat-presentation.md`, `design/gdd/audio-system.md`

**Requirements**: `TR-combat-004`, `TR-combatfx-004`,
`TR-combatfx-006`, `TR-audio-005`, `TR-audio-006`,
`TR-ability-004`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0005
Combat state machine; ADR-0010 Audio system; ADR-0018 Player abilities.

Story019 made Cinderpaw's `parry` input playable and connected it to the
laser-gate route. Core combat already emitted `CombatComponent.on_parry_resolved`,
and the presentation/audio layers already knew how to react to parry events, but
`MainScene` did not bridge the runtime player parry resolution into those
systems. The result was a playable parry that still felt muted unless it happened
to be part of a separate gate interaction.

This story closes that integration gap: when Cinderpaw resolves a parry in the
main scene, the same combat metadata is enriched with runtime position/source
data and forwarded to both combat presentation and audio.

## Acceptance Criteria

- [x] `MainScene` connects the player's `CombatComponent.on_parry_resolved`
  signal during runtime initialization without duplicate connections.
- [x] A PERFECT parry resolved from the running player flow forwards enriched
  `parry_data` to `CombatPresentation.on_parry_event()`.
- [x] PERFECT parry feedback produces the existing GDD-tuned presentation:
  8 frames hitstop, strong shake, one flash overlay, and 20-25 radial parry
  sparks.
- [x] The same PERFECT parry event forwards to `AudioSystem.on_parry_event()`
  and requests `sfx_parry_perfect` at the Cinderpaw sprite position.
- [x] GOOD parry resolution is forwarded without triggering PERFECT-only
  flash/spark presentation.
- [x] Forwarded `parry_data` preserves Core fields (`parry_type`, `is_success`,
  `parry_frame`) and adds `position` plus `source="player_parry"` when needed.
- [x] Existing parry timing and laser-gate runtime behavior do not regress.
- [x] Godot MCP verifies `res://scenes/main.tscn` runs, Player uses
  `AnimatedSprite2D + SpriteFrames`, the `parry` animation has three frames,
  PERFECT parry runtime feedback/audio are produced, logs are clean, and a
  nonblank screenshot is captured.

## Out of Scope

- Rebalancing Core parry timing windows or changing `CombatComponent`
  classification.
- New parry VFX/SFX assets, late-parry visual design, and full authored audio
  replacement.
- Enemy stun/counterattack damage automation beyond the existing Core
  `resolve_parry_result()` behavior.
- Parry skill-tree modifiers, UI prompts, full performance profiling, and
  global physics pause/hitstop refactors.
- Additional Central Tower route content or further laser-gate art replacement.

## Implementation Notes

- Keep Core parry state and timing in `CombatComponent`; `MainScene` only
  listens to `on_parry_resolved` and enriches metadata for presentation/audio.
- Prefer the player's `Sprite` global position for parry feedback so VFX and
  spatial SFX land on the visible character instead of `(0,0)`.
- `CombatPresentation` remains responsible for PERFECT-only flash/spark rules.
  `AudioSystem` remains responsible for mapping parry type to SFX cues.
- This story reuses existing image-generated parry VFX textures and existing
  imported parry SFX; no new visual asset generation was required.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`
- `tests/unit/presentation/combat_presentation_test.gd`
- `tests/unit/presentation/audio_system_test.gd`
- `tests/unit/combat/story_004_parry_timing_counter_outcome_test.gd`
- `tests/unit/gameplay/player_parry_laser_gate_runtime_test.gd`
- Headless main-scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/parry-success-feedback-runtime-2026-06-26.md`

**Status**: [x] RED/GREEN focused evidence, related regression, headless smoke,
and MCP runtime evidence complete.

- RED: `reports/report_733/` failed as expected because the newly added
  MainScene parry bridge test saw no presentation flash/sparks and no audio
  parry event.
- Initial GREEN focused: `reports/report_734/` passed `8/8` after connecting
  `CombatComponent.on_parry_resolved` to MainScene feedback forwarding.
- Focused after GOOD-parry negative coverage:
  `reports/report_736/` passed `9/9`.
- Final related regression: `reports/report_737/` passed `72/72` across
  MainScene audio adapters, combat presentation, audio system, Core parry
  timing, and ParryLaserGate runtime suites.
- Headless smoke:
  `reports/parry_success_feedback_runtime_main_scene_smoke.log`.
- Godot MCP evidence:
  `production/qa/evidence/parry-success-feedback-runtime-2026-06-26.md`.
- MCP runtime screenshot:
  `reports/visual/cinderpaw-mcp-parry-success-feedback-runtime-20260626.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| MainScene connects Core parry resolve signal | `main_scene_audio_event_adapter_test`; MCP probe | COVERED |
| PERFECT parry routes to presentation | `main_scene_audio_event_adapter_test`; MCP probe | COVERED |
| PERFECT parry GDD visual feedback counts | `combat_presentation_test`; MCP probe | COVERED |
| PERFECT parry routes to audio and requests SFX | `audio_system_test`; MCP probe | COVERED |
| GOOD parry does not trigger PERFECT-only visuals | `main_scene_audio_event_adapter_test` | COVERED |
| Metadata preserves Core fields and adds position/source | `main_scene_audio_event_adapter_test`; MCP probe | COVERED |
| Core timing and parry gate do not regress | `story_004_parry_timing_counter_outcome_test`; `player_parry_laser_gate_runtime_test` | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 8/8 passing
**Deviations**: No new visual or audio asset was generated; this integration
story intentionally reuses the existing image-generated parry flash/spark assets
and imported `sfx_parry_perfect` / `sfx_parry_good` cues.
**QA Evidence**:
`production/qa/evidence/parry-success-feedback-runtime-2026-06-26.md`
