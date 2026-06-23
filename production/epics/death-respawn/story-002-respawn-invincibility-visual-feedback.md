# Story 002: Respawn Invincibility Visual Feedback

> **Epic**: Death & Respawn
> **Status**: Ready
> **Layer**: Feature
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/death-respawn.md`
**Requirements**: `TR-respawn-007`

## Acceptance Criteria

- [ ] Player becomes semi-transparent or shimmered during the revived
  invincibility window.
- [ ] Feedback stops exactly when GameFlow control unlocks.
- [ ] Feedback does not override attack/dodge/damage color states after the
  window ends.
- [ ] Runtime screenshot or capture shows visible revive feedback.

## Test Evidence

**Required evidence**: focused player/flow test plus MCP runtime screenshot.
**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 001 runtime death loop.
