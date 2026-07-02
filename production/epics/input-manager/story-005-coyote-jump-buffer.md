# Story 005: Coyote Time + Jump Buffer

> **Epic**: Input System
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/input.md`
**Requirement**: `TR-input-004`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0003: Data management
**ADR Decision Summary**: InputManager exposes timing helpers for movement systems while staying independent of player physics implementation.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Unit tests should use injected frame counters instead of relying on physics ticks.

**Control Manifest Rules (Foundation)**:
- Required: InputManager does not reference movement, collision, or player nodes.
- Required: coyote/jump-buffer windows use registered tuning values.
- Forbidden: Never put CharacterBody2D movement code in InputManager.

---

## Acceptance Criteria

- [x] `can_use_coyote_jump(frames_since_left_ground)` returns true for values within `coyote_frames` (default 6).
- [x] Coyote jump returns false once the configured frame window is exceeded.
- [x] `should_consume_jump_buffer(frames_before_landing)` returns true for jump presses within `jump_buffer_frames` (default 6).
- [x] Jump buffer returns false outside the configured frame window.
- [x] Tuned coyote/jump values from DataManager affect the helper results.

---

## Implementation Notes

- Provide pure helper methods so Player movement can call them without InputManager knowing terrain or velocity.
- Treat negative frame counts as safe false unless explicitly documented by the caller contract.

---

## Out of Scope

- PlayerController physics integration and jump velocity application.
- Animation or VFX feedback for buffered jumps.

---

## QA Test Cases

- **AC-1**: Coyote within window
  - Given: `coyote_frames=6`
  - When: `can_use_coyote_jump(6)` is called
  - Then: it returns true
  - Edge cases: `7` returns false

- **AC-2**: Jump buffer within window
  - Given: `jump_buffer_frames=6`
  - When: `should_consume_jump_buffer(5)` is called
  - Then: it returns true
  - Edge cases: `7` returns false

- **AC-3**: Tuned frame windows
  - Given: DataManager tuning overrides coyote_frames to 8
  - When: `can_use_coyote_jump(8)` is called
  - Then: it returns true
  - Edge cases: fallback defaults are used when tuning is unavailable

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/story_005_coyote_jump_buffer_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence**:
- TDD red: `tests/unit/input/story_005_coyote_jump_buffer_test.gd` failed on missing coyote/jump helper APIs (`reports/report_80/`).
- Story suite: 5/5 passing (`reports/report_81/`).
- Input regression: 27/27 passing (`reports/report_82/`).
- Data regression: 43/43 passing (`reports/report_83/`).
- Damage regression: 24/24 passing (`reports/report_84/`).
- Static checks: `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 50 lines.

---

## Completion Notes

- Implemented pure InputManager timing helpers for coyote jump and jump buffer frame windows.
- Negative frame counts safely return false.
- Helper windows read registered DataManager tuning values when available and fall back to default 6-frame windows.
- No movement, collision, velocity, animation, or VFX integration was added.

---

## Dependencies

- Depends on: Story 001
- Unlocks: Player movement integration
