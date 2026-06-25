# Story 004: Double Jump Activation Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Presentation / Gameplay Runtime
> **Type**: Integration + Visual/Feel + Audio
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/audio-system.md`

**Requirements**: `TR-ability-004`, `TR-ability-005`, `TR-audio-003`,
`TR-audio-005`

**ADR Governing Implementation**: ADR-0018 Player abilities; ADR-0010 Audio
system; ADR-0002 Signal communication.

Story003 made Double Jump playable and connected it to the high-platform
ExplorationGate. This story adds the player-facing activation feedback required
by the GDD: when Cinderpaw spends the airborne Double Jump, the player sees a
textured foot whirlwind and hears a short bounce cue.

## Acceptance Criteria

- [x] `CombatPresentation` exposes `on_double_jump_event(texture,
  world_position, facing)` and spawns a textured Sprite2D whirlwind VFX using an
  image-generated transparent PNG, not `ColorRect`, `Polygon2D`, or a solid
  placeholder.
- [x] The VFX is short-lived, uses a recorded texture path under
  `assets/generated/`, participates in existing particle cleanup/cap accounting,
  and can be verified by focused presentation tests.
- [x] `MainScene` connects `Player.double_jump_started` and forwards the event
  to `CombatPresentation` and `AudioSystem` without coupling presentation back
  into Core/Feature systems.
- [x] `AudioSystem` exposes `on_double_jump_event(...)`, routes it to
  `sfx_double_jump`, and loads an imported baseline WAV from
  `assets/audio/sfx/sfx_double_jump.wav`.
- [x] The new visual source and runtime PNG are recorded in asset docs, with the
  image-generation prompt and import path preserved in QA evidence.
- [x] Godot MCP verifies `res://scenes/main.tscn` runs, Double Jump activation
  creates visible textured VFX near Cinderpaw, `AudioSystem` records
  `sfx_double_jump` with `stream_found=true`, logs are clean, and a nonblank
  screenshot captures the runtime feedback.

## Out of Scope

- Boss2, hidden-boss, shrine, pickup, or any real `double_jump` reward source.
- Full factory area transition, new map UI, fast travel, or scene registry
  expansion.
- New Cinderpaw `double_jump` character frames; Story003's existing `jump`
  `AnimatedSprite2D + SpriteFrames` remains the character animation for this
  slice.
- Skill-tree spending UI or ability parameter modifiers.
- Replacing the current procedural baseline audio library with final mastered
  audio.

## Implementation Notes

- Treat the player signal as the runtime source of truth: `PlayerController`
  emits `double_jump_started` only after `AbilityComponent.try_activate_ability`
  succeeds.
- Presentation consumes the event through existing signal routing. Do not make
  `CombatPresentation` query `AbilityComponent`, `PlayerController`, or
  `MainScene` state.
- Reuse the existing `AudioSystem` event-adapter style: missing streams must
  remain silent-safe, but this story should add the baseline stream so runtime
  requests return `stream_found=true`.
- Keep the VFX small and readable under Cinderpaw's feet; avoid screen-wide
  overlays or long-lived effects.

## Test Evidence

**Required evidence**:

- `tests/unit/presentation/combat_presentation_test.gd`
- `tests/unit/presentation/audio_system_test.gd`
- `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/double-jump-activation-feedback-2026-06-26.md`

**Status**: [x] RED/GREEN focused evidence, related regression, asset import,
headless smoke, and MCP runtime evidence captured in
`production/qa/evidence/double-jump-activation-feedback-2026-06-26.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Textured Double Jump whirlwind VFX | `combat_presentation_test`; MCP screenshot | PASS |
| MainScene forwards Double Jump signal | `main_scene_audio_event_adapter_test`; MCP runtime probe | PASS |
| AudioSystem routes `sfx_double_jump` | `audio_system_test`; MCP runtime probe | PASS |
| Generated asset documented/imported | Asset manifest; QA evidence | PASS |
| Runtime logs and screenshot verified through MCP | QA evidence | PASS |
