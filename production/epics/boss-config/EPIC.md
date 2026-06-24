# Epic: Boss Configuration

> **Layer**: Core
> **GDD**: design/gdd/boss-config.md
> **Architecture Module**: BossConfigComponent
> **Status**: Complete
> **Stories**: 7 stories

## Overview

This epic implements the data-driven Boss configuration layer for the MVP boss, Garbage Bin Rat King. It provides a BossConfigComponent mounted on Boss entities, loads phase and reward data through the existing DataManager JSON pipeline, coordinates phase transitions with AI and Health signals, and exposes stable integration points for arena changes, rewards, and downstream presentation systems.
Story007 mounts this BossConfig contract into the playable `MainScene` through
the Rat King runtime shell.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | BossConfigComponent is a scene component on Boss entities; DataManager remains the only data Autoload. | LOW |
| ADR-0002: Signal communication | Boss phase and death events use direct Godot signals with typed `signal.connect(callable)` syntax. | LOW |
| ADR-0003: Data management | Boss data is JSON source data loaded through manifest domains and SchemaValidator. | LOW |
| ADR-0006: AI behavior | AI attack patterns and boss phase attack sets are data-driven and consumed by AIComponent. | LOW |
| ADR-0007: Scene management | Boss arenas use scene lock and arena-change coordination through SceneManager-compatible adapters. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-boss-001 | Boss config data includes phases with hp_threshold, attack_patterns, attack_speed_modifier, special_attacks, and arena_changes. | ADR-0001, ADR-0003, ADR-0006 |
| TR-boss-002 | Phase transition waits for current attack completion, grants invulnerability, applies arena changes, loads new patterns, and resumes action. | ADR-0002, ADR-0006 |
| TR-boss-003 | Phase 2 summons minions every 15 seconds up to 2 active minions and clears them on boss death. | ADR-0006 |
| TR-boss-004 | Phase transitions alter arena layout with obstacles or damage areas through scene coordination. | ADR-0007 |
| TR-boss-005 | Boss parry outcome deals 5.0x damage without entering STUN. | ADR-0005, ADR-0003 |
| TR-boss-006 | Boss HP below 10% applies a -30% defense modifier. | ADR-0003, damage/health integration |
| TR-boss-007 | Boss defeat rewards unlock dash, grant 50 gear coins, and grant 5 skill points. | ADR-0002, pending Ability/Progression integration |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | BossConfigComponent + Rat King Data Domain | Logic | Complete | ADR-0003 |
| 002 | Phase Transition Adapter + Invulnerability Window | Integration | Complete | ADR-0006 |
| 003 | Phase 2 Summon Scheduling + Death Cleanup Hooks | Integration | Complete | ADR-0006 |
| 004 | Phase Arena Change Adapter + Scene Lock Hooks | Integration | Complete | ADR-0007 |
| 005 | Desperation Defense + Defeat Reward Dispatch | Integration | Complete | ADR-0002 |
| 006 | Boss Parry Damage + STUN Immunity | Integration | Complete | ADR-0005 |
| 007 | Rat King Runtime MainScene Replacement | Integration + Visual/Feel | Complete | ADR-0001/0002/0006 |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`.
- BossConfigComponent loads Rat King config through the DataManager asset pipeline.
- Boss phase, summon, arena, desperation, parry, and reward criteria from `design/gdd/boss-config.md` are verified.
- MainScene instantiates the Rat King runtime shell instead of the Shadow Beast
  prototype as its visible boss surface.
- Logic and Integration stories have passing automated tests.
- Visual/audio/UI follow-up work is routed to Combat Presentation, Audio, and HUD/UI epics instead of being implemented here.

## Next Step

Boss Configuration Core scope is complete through the playable Rat King runtime
shell. Move to downstream consumer stories for full boss AI attack scheduling,
specialized attack animation expansion, boss music/SFX, HUD polish, ability
unlock presentation, and progression reward consumption.
