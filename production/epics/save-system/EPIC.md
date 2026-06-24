# Epic: Save System

> **Layer**: Feature
> **GDD**: design/gdd/save-system.md
> **Architecture Module**: SaveSystem
> **Status**: In Progress
> **Stories**: 4 stories

## Overview

Implement the game persistence layer that coordinates JSON save files, slot
metadata, backup recovery, version migration, and ISerializable system
registration. SaveSystem is a Feature-layer service for HUD/UI, respawn,
SceneManager, and progression systems; Core systems expose data but never depend
on SaveSystem directly.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | SaveSystem is the fourth global service after DataManager, InputManager, and AudioSystem. | LOW |
| ADR-0008: Save serialization pattern | Systems expose JSON-safe `serialize()` / `deserialize()` payloads and SaveSystem coordinates file I/O. | MEDIUM |
| ADR-0021: Save system architecture | SaveSystem owns slot layout, backup recovery, migration, registered system order, and save/load trigger boundaries. | MEDIUM |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-save-001 | ISerializable interface pattern; systems serialize themselves and SaveSystem coordinates writes. | ADR-0008, ADR-0021 |
| TR-save-002 | Save data contains version, timestamp, play time, player_state, world_state, and settings. | ADR-0021 |
| TR-save-003 | Save slots use JSON under `user://saves/`, with slot 0 reserved for autosave. | ADR-0008, ADR-0021 |
| TR-save-004 | Save writes preserve `.bak` backup and corrupt saves fall back to backup. | ADR-0008, ADR-0021 |
| TR-save-005 | Save version mismatches run a migration pipeline. | ADR-0008, ADR-0021 |
| TR-save-006 | Autosaves are triggered by savepoints, boss defeats, key events, and scene changes. | ADR-0021 |
| TR-save-007 | Save operations avoid gameplay stalls and stay below the 100ms budget. | ADR-0021 |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Save Slots + Backup JSON Pipeline | Integration | Complete | ADR-0008, ADR-0021 |
| 002 | Version Migration + SaveInfo Metadata | Logic | Complete | ADR-0021 |
| 003 | Autosave Trigger Adapters | Integration | Complete | ADR-0021 |
| 004 | MainScene SaveSystem Runtime Handoff | Integration | Complete | ADR-0001, ADR-0021 |

## Definition of Done

This epic is complete when:
- SaveSystem can write and read the reserved autosave slot plus manual slots.
- SaveSystem exposes slot information for HUD/UI without letting HUD own file
  rules.
- Corrupt main saves recover from `.bak` when a valid backup exists.
- Registered serializable systems round-trip in deterministic order.
- SceneManager and respawn stories can consume SaveSystem through narrow
  adapters instead of direct reload logic.
- Godot CLI/GdUnit and Godot MCP smoke verify the autoload in runtime.

## Next Step

Connect save/load presentation through HUD/UI Story 005. Keep threaded async
write hardening as a later SaveSystem performance follow-up for TR-save-007.
