# Story 006: No-Loss Respawn State Contract

> **Epic**: Death & Respawn
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/death-respawn.md`
**Requirements**: `TR-respawn-005`

## Acceptance Criteria

- [ ] Currency amount is unchanged after death and respawn.
- [ ] Inventory and acquired weapon state are unchanged after respawn.
- [ ] World progress flags are unchanged after respawn.
- [ ] Health is restored by HealthComponent revive percentage only.

## Test Evidence

**Required evidence**: integration tests with economy/save adapters.
**Status**: [ ] Not yet created

## Dependencies

- Depends on: SaveSystem, weapon serialization, economy/currency source.
