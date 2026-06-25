# Epic: Audio System

> **Layer**: Presentation
> **GDD**: design/gdd/audio-system.md
> **Architecture Module**: AudioSystem
> **Status**: In Progress
> **Stories**: 6 stories tracked

## Overview

Implement the global presentation audio service for Cinderpaw. AudioSystem owns
runtime audio buses, SFX pooling, music and ambience request state, and safe
playback APIs for gameplay, UI, scene transitions, and boss encounters. Core
systems emit gameplay events; AudioSystem consumes events or explicit adapter
calls without pushing logic back into Core.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | AudioSystem is the third global service after InputManager and before SaveSystem. | LOW |
| ADR-0010: Audio system architecture | AudioSystem owns the five-bus mix, SFX pool, spatial audio, and music state boundaries. | MEDIUM |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-audio-001 | Five independent buses: Master, Music, SFX, Ambient, UI, each with 0-100% volume control. | ADR-0001, ADR-0010 |
| TR-audio-002 | Maximum 16 simultaneous SFX, priority sorted with lowest priority dropped on overflow. | ADR-0010 |
| TR-audio-003 | 2D spatial audio with distance attenuation from 300px and silence beyond 600px. | ADR-0010 |
| TR-audio-004 | Music switching supports area crossfade, boss hard cuts, and boss phase transitions. | ADR-0010 |
| TR-audio-005 | Same SFX within 100ms merges with +20% volume. | ADR-0010 |
| TR-audio-006 | AudioSystem listens to upstream combat, health, death, dodge, parry, and boss signals. | ADR-0002, ADR-0010 |
| TR-audio-007 | Audio state machine handles NORMAL, BOSS_FIGHT, LOW_HP, DEATH, MENU, CUTSCENE. | ADR-0010 |
| TR-audio-008 | Scene switching forces unfinished audio to fade out over 2 seconds. | ADR-0010 |
| TR-audio-009 | `play_sfx` supports `pitch_offset` for Health/Death injury pitch formula. | ADR-0010 |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Autoload Bus + Pool Baseline | Integration | Complete | ADR-0001, ADR-0010 |
| 002 | Scene Transition Audio Fades | Integration | Complete | ADR-0007, ADR-0010 |
| 003 | Combat + Health Event Audio Adapters | Integration | Complete | ADR-0010 |
| 004 | Rat King Boss Music State Transitions | Integration | Complete | ADR-0010 |
| 005 | Core Combat SFX Asset Import Baseline | Integration | Complete | ADR-0010 |
| 006 | Weapon Style SFX Asset Expansion | Integration | Complete | ADR-0010 |

## Definition of Done

This epic is complete when:
- AudioSystem is registered as Autoload #3 in `project.godot`.
- Five runtime buses initialize idempotently and expose 0-100% volume controls.
- SFX playback uses a 16-voice `AudioStreamPlayer2D` pool with priority overflow
  handling, pitch offset support, and 600px max distance.
- Music and ambience request APIs record fade state and become ready for
  SceneManager and boss-transition integration.
- Missing or unloaded audio assets fail safely without blocking gameplay.
- The first core combat SFX batch is imported through Godot and loaded by
  AudioSystem by default.
- Weapon-style attack SFX and GOOD parry cue streams are imported through Godot
  and loaded by AudioSystem by default.
- Combat, health, scene, UI, and boss event adapters are wired and covered.
- Godot CLI/GdUnit and Godot MCP verify runtime autoload, bus state, public API,
  and clean logs.

## Next Step

Audio System Story 006 is complete. Next recommended work is UI menu audio,
same-SFX merge, authored/final audio replacement, and broader mix polish.
