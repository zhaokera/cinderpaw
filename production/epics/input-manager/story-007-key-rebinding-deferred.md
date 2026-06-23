# Story 007: Key Rebinding Persistence

> **Epic**: Input System
> **Status**: Deferred
> **Layer**: Foundation
> **Type**: Config/Data
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/input.md`
**Requirement**: `TR-input-010`

**ADR Governing Implementation**: N/A — explicitly deferred by this epic to Feature/Polish
**ADR Decision Summary**: The Input EPIC states key rebinding is postponed to the Feature/Polish phase.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM
**Engine Notes**: Requires save/load of `user://input_bindings.cfg`, UI settings integration, and platform-specific input event serialization.

**Control Manifest Rules (Foundation)**:
- Required: JSON/source data and user config writes must validate or gracefully fall back.
- Forbidden: Do not mix settings UI with Foundation input logic.
- Guardrail: Rebinding must not break default action map startup.

---

## Acceptance Criteria

- [ ] PC key bindings can be persisted to `user://input_bindings.cfg`.
- [ ] Saved bindings are loaded on startup after default bindings are available.
- [ ] Invalid or missing binding config falls back to default mappings without crashing.
- [ ] Rebinding UI and accessibility validation are covered by Polish/UI work before implementation.

---

## Implementation Notes

- Do not implement in Foundation milestone unless the epic scope is revised.
- This story records the active TR so it is not lost, but it should not block Stories 001-006.

---

## Out of Scope

- All implementation is deferred.

---

## QA Test Cases

- **Deferred**: Generate final automated and UI/manual test specs when this story is pulled into a Polish sprint.

---

## Test Evidence

**Story Type**: Config/Data
**Required evidence**: Deferred; future evidence should include config round-trip tests and UI rebinding manual checks.
**Status**: [ ] Deferred

---

## Dependencies

- Depends on: Stories 001-006, Settings UI
- Unlocks: Accessibility/key rebinding polish
