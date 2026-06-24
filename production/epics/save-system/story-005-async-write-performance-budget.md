# Story 005: Async Write Performance Budget

> **Epic**: Save System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Logic/Performance
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-007`
**ADR Governing Implementation**: ADR-0021: Save system architecture

The Save System currently satisfies slot layout, backup recovery, migration,
autosave triggers, and MainScene runtime handoff. This story closes the
remaining performance requirement: save writes must avoid gameplay stalls by
dispatching file I/O asynchronously, while keeping a deterministic synchronous
fallback for platforms or tests that disable async writes.

## Acceptance Criteria

- [x] Given async save writes are enabled, when `manual_save()` or `auto_save()`
  is called with a valid slot payload, then the call dispatches the write and
  returns within the `TR-save-007` `100ms` budget instead of blocking until the
  file is fully written.
- [x] Given an async write is in progress, when another save request arrives,
  then SaveSystem rejects the second request without corrupting the pending
  save and keeps the first write authoritative.
- [x] Given an async write completes, when SaveSystem polls completion on the
  main thread, then it clears the pending state, emits `on_save_written(slot)`,
  and leaves a valid JSON slot file with backup behavior preserved.
- [x] Given async save writes are disabled or unavailable, when a valid save is
  requested, then SaveSystem uses the existing synchronous file path and emits
  the same success signal immediately.
- [x] Given an async write fails, when completion is polled on the main thread,
  then SaveSystem clears the pending state and emits a write-failure signal
  without reporting the save as written.

## Implementation Notes

- Follow ADR-0021 section 5: Thread-backed file I/O, a single-write lock, and
  main-thread completion handling from `_process()`.
- Keep load operations synchronous; this story covers save-write dispatch only.
- Preserve Story001 backup semantics by writing the previous slot contents to
  `.bak` before replacing the active slot file.
- Preserve existing `manual_save()`, `auto_save()`, and `save_game()` public
  entry points. Returning `true` for async mode means dispatch succeeded; final
  file success is reported through completion signals.
- Expose narrow diagnostic methods needed by tests and runtime QA, such as
  pending-write state and last dispatch duration. Do not expose thread objects.

## Out of Scope

- Save thumbnails, loading-screen art, cloud saves, encryption, compression,
  multi-backup rotation, or screenshot capture.
- SceneManager async scene loading and scene-state restoration.
- HUD save/load menu changes beyond consuming existing signals.
- Changing SaveSystem slot numbering, JSON payload schema, migrations, or
  registered serializable ordering.

## QA Test Cases

- **AC-1**: Async dispatch budget
  - Given: async writes are enabled and a normal slot payload is provided
  - When: `manual_save(1, ...)` is called
  - Then: the call returns `true`, reports dispatch duration `< 100ms`, and the
    write remains pending until completion is polled
  - Edge cases: invalid slots still reject immediately

- **AC-2**: Single-write lock
  - Given: async writes are enabled and one save is pending
  - When: a second save is requested before the first completion is polled
  - Then: the second save returns `false`, does not create another slot file,
    and the first pending write completes normally

- **AC-3**: Completion signal and JSON validity
  - Given: an async save has been dispatched
  - When: SaveSystem processes the write completion
  - Then: `on_save_written(slot)` emits, pending state clears, and the slot JSON
    parses through SaveSystem validation

- **AC-4**: Synchronous fallback
  - Given: async writes are disabled
  - When: `manual_save(1, ...)` is called
  - Then: the slot file exists before the next frame, pending state is false,
    and `on_save_written(1)` has emitted

- **AC-5**: Async failure cleanup
  - Given: async writes are enabled but the destination path cannot be opened
  - When: completion is polled
  - Then: pending state clears and write failure is signaled without emitting
    `on_save_written`

## Test Evidence

**Required test file**:
`tests/unit/save/story_005_async_write_performance_budget_test.gd`

**Required verification**:
- Focused Story005 GdUnit RED/GREEN.
- SaveSystem Story001-005 regression.
- MainScene/HUD save-load regression for async completion feedback.
- Godot headless project boot.
- Godot MCP runtime check for `/root/SaveSystem` pending/dispatch APIs and
  clean logs.

## Traceability

| Source | Requirement | Story Coverage |
|--------|-------------|----------------|
| `TR-save-007` | Save operations do not block gameplay; `SAVING` state `<100ms` async write | Async write dispatch, pending lock, completion polling, and sync fallback |
| ADR-0021 §5 | Thread async write, Mutex/single-write lock, main-thread callback, Web fallback | Implements SaveSystem write dispatch and completion path |
| `design/gdd/save-system.md` | Saves use `.bak` backup and JSON slot files | Keeps backup and validation semantics in async and sync paths |

## Dependencies

- Depends on: Save System Stories 001-004.
- Unlocks: Death & Respawn Story 004 savepoint respawn selection and final Save
  System Epic closure.
