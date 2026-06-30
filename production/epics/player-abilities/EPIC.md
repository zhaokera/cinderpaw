# Epic: Player Abilities

> **Layer**: Core / Feature
> **GDD**: design/gdd/player-abilities.md
> **Architecture Module**: AbilityComponent
> **Status**: In Progress
> **Stories**: 33 stories tracked

## Overview

This epic implements player ability unlocks, runtime activation gates,
cooldowns, and ability-driven presentation hooks. It starts by making Rat King's
`dash` reward consumable by the playable Cinderpaw controller instead of only
recording the reward in progression state.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | Ability state lives on scene/entity components, not a new Autoload. | LOW |
| ADR-0003: Data management | Ability registry data is JSON source data loaded through DataManager. | LOW |
| ADR-0005: Combat state machine | Ability activation must respect combat-state blocking rules. | LOW |
| ADR-0018: Player abilities | AbilityComponent owns unlocks, cooldowns, activation checks, and signals. | LOW |
| ADR-0021: Save system | Runtime progression and unlocked abilities persist through save snapshots. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-ability-001 | Ability registry contains eight core abilities with initial and boss-based unlocks. | ADR-0003, ADR-0018 |
| TR-ability-002 | Runtime queries expose `has_ability`, `get_unlocked_abilities`, `is_ability_on_cooldown`, `unlock_ability`, and `reset_air_abilities`. | ADR-0018 |
| TR-ability-003 | Abilities use different cooldowns: dodge 0.5s, dash 1.0s, parry 0.3s, double jump air-count reset. | ADR-0018 |
| TR-ability-004 | Ability activation follows input, unlock, cooldown, prerequisite, activation/event, cooldown-start order. | ADR-0018 |
| TR-ability-005 | Ability unlocks emit events for presentation, gates, HUD, and save recording. | ADR-0002, ADR-0018, ADR-0021 |
| TR-ability-006 | Skill-tree modifiers can adjust ability parameters. | ADR-0009, ADR-0018 |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Dash Runtime Ability Gate | Integration + Gameplay Runtime + Visual | Complete | ADR-0003/0005/0018/0021 |
| 002 | Dash Exploration Gate Runtime | Integration + Gameplay Runtime + Visual | Complete | ADR-0007/0018/0021 |
| 003 | Double Jump Runtime + High Platform Gate | Integration + Gameplay Runtime + Visual | Complete | ADR-0007/0018/0021 |
| 004 | Double Jump Activation Feedback | Integration + Visual/Feel + Audio | Complete | ADR-0002/0010/0018 |
| 005 | Hidden Double Jump Reward Source | Integration + Gameplay Runtime + Visual | Complete | ADR-0007/0018/0021 |
| 006 | Factory Route Transition Shell | Integration + Gameplay Runtime + Visual | Complete | ADR-0007/0018/0021 |
| 007 | Old Factory Entrance Combat Slice | Integration + Gameplay Runtime + Visual/Feel + Audio | Complete | ADR-0007/0018/0021 |
| 008 | Old Factory Double Jump Combat Cache | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0007/0018/0021 |
| 009 | Old Factory Steam Vent Hazard Route | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 010 | Old Factory Deep Route Micro-Slice | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 011 | Old Factory Deep Guard Activation Pacing | Integration + Gameplay Runtime + Combat Pacing | Complete | ADR-0004/0007/0018/0021 |
| 012 | Old Factory Deep Route Unlock Feedback | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0002/0007/0018/0021 |
| 013 | Old Factory Spark Rat Patrol Encounter | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 014 | Old Factory Spark Rat Attack Tell Feedback | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0005/0007/0018 |
| 015 | Old Factory Spark Rat Dodge-Counter Readability | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0005/0007/0018 |
| 016 | Ability Gate Unlock Feedback | Integration + Gameplay Runtime + Visual/Feel + Audio | Complete | ADR-0002/0007/0010/0018/0021 |
| 017 | Old Factory Spark Rat Pacing Polish | Integration + Gameplay Runtime + Combat Pacing | Complete | ADR-0004/0005/0006/0007/0018 |
| 018 | Skill Tree Cat Claw T1-A First Spend | Integration + Gameplay Runtime + UI | Complete | ADR-0001/0003/0005/0009/0018/0021 |
| 019 | Parry Laser Gate Runtime | Integration + Gameplay Runtime + Visual | Complete | ADR-0005/0007/0018/0021 |
| 020 | Parry Success Feedback Runtime | Integration + Visual/Feel + Audio | Complete | ADR-0002/0005/0010/0018 |
| 021 | Mainline Boss2 Double Jump Payoff Shell | Integration + Gameplay Runtime + Visual | Complete | ADR-0007/0018/0021 |
| 022 | Boss2 Echo Guardian Telegraph Strike | Integration + Gameplay Runtime + Combat Feel | Complete | ADR-0004/0005/0007/0018/0021 |
| 023 | Boss2 HUD Focus Runtime | Integration + Gameplay Runtime + HUD/Feel | Complete | ADR-0002/0007/0018/0021 |
| 024 | Boss2 Autonomous Pressure Runtime | Integration + Gameplay Runtime + Combat Feel | Complete | ADR-0004/0005/0006/0007/0018/0021 |
| 025 | Boss2 Run Frame Animation Runtime | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0005/0006/0007/0018/0021 |
| 026 | Boss2 Arena Bounds Reset Runtime | Integration + Gameplay Runtime + Combat Feel | Complete | ADR-0004/0005/0006/0007/0018/0021 |
| 027 | Parry Laser Gate Authored Visual Replacement | Integration + Visual | Complete | ADR-0005/0007/0018/0021 |
| 028 | Boss2 HUD Hit Feedback + Arena Visual Runtime | Integration + Gameplay Runtime + HUD/Visual | Complete | ADR-0002/0004/0005/0007/0018/0021 |
| 029 | Boss2 Arena Camera Lock Runtime | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0002/0005/0007/0018/0021 |
| 030 | Boss2 Room Seal Runtime | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0002/0005/0007/0018/0021 |
| 031 | Boss2 HUD Portrait Runtime | Integration + HUD Visual Polish | Complete | ADR-0002/0005/0010/0018 |
| 032 | Boss2 Phase II Runtime Pressure Mix | Integration + Gameplay Runtime + Combat Feel + Audio | Complete | ADR-0002/0004/0005/0006/0007/0010/0018/0021 |
| 033 | Boss2 Victory Route Handoff | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0002/0007/0018/0021 |
| 034 | Factory Route Arrival Objective Handoff | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0002/0007/0018/0021 |

## Definition of Done

This epic is complete when:

- Ability registry data loads through DataManager and validates through schema.
- `AbilityComponent` is mounted under Player and exposes all GDD query and
  activation APIs.
- Initial abilities are available at game start and boss rewards unlock later
  abilities exactly once.
- Dash, double jump, aerial attack, wall climb, parry, and future ability
  consumers are connected to gameplay input/presentation as their stories land.
- Player-visible 2D ability states use `AnimatedSprite2D` + `SpriteFrames` and
  pass MCP runtime checks.
- Logic and integration stories have passing focused tests plus risk-appropriate
  Godot MCP evidence.

## Next Step

Stories001-034 are complete. Continue with the next playable ACT slice:
deeper Old Factory combat encounters, savepoint/minimap gameplay, additional
player-visible character/enemy frame-animation replacement, authored Factory
Route progression, or final Boss2 balancing/cutscene polish.
