# Epic: Player Abilities

> **Layer**: Core / Feature
> **GDD**: design/gdd/player-abilities.md
> **Architecture Module**: AbilityComponent
> **Status**: In Progress
> **Stories**: 94 stories tracked

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
| 035 | Old Factory Service Lift Handoff | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0002/0007/0018/0021 |
| 036 | Old Factory Service Lift SceneManager Exit | Integration + Gameplay Runtime + Scene Management | Complete | ADR-0007/0018/0021 |
| 037 | Factory Route Runtime Roundtrip | Integration + Gameplay Runtime + Scene Management | Complete | ADR-0007/0018/0021 |
| 038 | Factory Route Return Prompt | Integration + Gameplay Runtime + Scene Management + UI | Complete | ADR-0007/0018/0021 |
| 039 | Scrap Roost Return Hub Runtime | Integration + Gameplay Runtime + UI | Complete | ADR-0007/0018/0021 |
| 040 | Old Factory Return Patrol Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0007/0018/0021 |
| 041 | Old Factory Return Patrol Reward Cache | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0007/0018/0021 |
| 042 | Old Factory Cache Claim Feedback | Integration + UI/Visual | Complete | ADR-0007/0018/0021 |
| 043 | Old Factory Return Checkpoint | Integration + Gameplay Runtime + Visual | Complete | ADR-0007/0018/0021 |
| 044 | Old Factory Return Checkpoint Respawn Runtime | Integration + Gameplay Runtime + Scene Management | Complete | ADR-0007/0018/0021 |
| 045 | Old Factory Runtime Death Integration | Integration + Gameplay Runtime + Scene Management | Complete | ADR-0007/0018/0021 |
| 046 | Old Factory Checkpoint-Forward Combat Route | Integration + Gameplay Runtime + Combat Pacing | Complete | ADR-0007/0018/0021 |
| 047 | Old Factory Checkpoint Steam Vent Gauntlet | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 048 | Old Factory Checkpoint Rear Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 049 | Old Factory Checkpoint Overdrive Duo | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 050 | Old Factory Overdrive Duo Staggered Pincer Pacing | Logic + Visual/Feel | Complete | ADR-0004/0005/0006/0007 |
| 051 | Old Factory Checkpoint Overdrive Reward Cache | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0007/0018/0021 |
| 052 | Old Factory Overdrive Defeat Burst | Integration + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 053 | Old Factory Lower Deck Skirmish Cache | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 054 | Old Factory Lower Deck Parry-Laser Ambush Gate | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 055 | Old Factory Lower Deck Shortcut Seal Combat Gate | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 056 | Old Factory Lower Deck Shortcut Payoff Cache | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0007/0018/0021 |
| 057 | Old Factory Lower Deck Shortcut Pursuer | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0007/0018/0021 |
| 058 | Old Factory Lower Deck Pressure Valve Combat Gate | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0007/0018/0021 |
| 059 | Old Factory Lower Deck Steam Sluice Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 060 | Old Factory Lower Deck Deep Bulkhead Combat Gate | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 061 | Old Factory Lower Deck Breach Corridor Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 062 | Old Factory Lower Deck Breach Relay Savepoint | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0007/0018/0021 |
| 063 | Old Factory Lower Deck Breach Relay Activation Feedback | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0002/0007/0018/0021 |
| 064 | Old Factory Lower Deck Breach Relay Audio Feedback | Integration + Gameplay Runtime + Visual/Feel + Audio | Complete | ADR-0002/0007/0010/0018/0021 |
| 065 | Old Factory Lower Deck Post-Relay Combat Feedback | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 066 | Old Factory Lower Deck Relay Forward Reward Hatch | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 067 | Old Factory Lower Deck Forward Conduit Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 068 | Old Factory Lower Deck Forward Conduit Clear Feedback | Integration + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 069 | Old Factory Lower Deck Forward Pressure Traverse | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 070 | Old Factory Lower Deck Forward Pressure Counter-Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 071 | Old Factory Lower Deck Forward Pressure Reward Cache | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 072 | Old Factory Lower Deck Forward Pressure Reward Cache Audio Feedback | Integration + Gameplay Runtime + Audio/Feel | Complete | ADR-0002/0007/0010/0018/0021 |
| 073 | Old Factory Lower Deck Forward Pressure Exit Guard | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 074 | Old Factory Lower Deck Forward Pressure Exit Relay Savepoint | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0007/0018/0021 |
| 075 | Old Factory Lower Deck Forward Pressure Exit Gate Handoff | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0007/0018/0021 |
| 076 | Old Factory Lower Deck Forward Pressure Route Handoff Marker | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0007/0018/0021 |
| 077 | Old Factory Lower Deck Forward Pressure Beacon Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 078 | Old Factory Lower Deck Forward Pressure Overrun | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 079 | Old Factory Lower Deck Forward Pressure Breaker | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 080 | Old Factory Lower Deck Forward Pressure Relief Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 081 | Old Factory Lower Deck Forward Pressure Coil Rat Breakthrough | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 082 | Old Factory Lower Deck Forward Pressure Coil Pincer | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 083 | Old Factory Lower Deck Forward Pressure Coil Aftershock | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 084 | Old Factory Lower Deck Forward Pressure Aftershock Reward Cache | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 085 | Old Factory Lower Deck Forward Pressure Aftershock Exit Skirmish | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 086 | Old Factory Lower Deck Forward Pressure Aftershock Exhaust Traverse | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 087 | Old Factory Lower Deck Forward Pressure Aftershock Exhaust Pursuer | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 088 | Old Factory Lower Deck Forward Pressure Aftershock Exhaust Pursuer Reward Cache | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 089 | Old Factory Lower Deck Forward Pressure Aftershock Exhaust Flank Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 090 | Old Factory Lower Deck Forward Pressure Aftershock Exhaust Breaker Corridor | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 091 | Old Factory Lower Deck Forward Pressure Aftershock Exhaust Escape Skirmish | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 092 | Old Factory Lower Deck Forward Pressure Aftershock Exhaust Exit Hatch Handoff | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 093 | Old Factory Lower Deck Forward Pressure Aftershock Cooling Duct Traverse | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 094 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Valve Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 095 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Savepoint | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 096 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Outlet Traverse | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 097 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Outlet Clamp Ambush | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |

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

Stories001-097 are complete. Continue deeper Old Factory route content after the
aftershock condenser outlet clamp ambush, minimap gameplay,
additional player-visible character/enemy frame-animation replacement, more
skill-tree branches, authored hazard/audio polish, or final Boss2 balancing/
cutscene polish.
