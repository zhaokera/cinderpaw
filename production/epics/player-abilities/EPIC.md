# Epic: Player Abilities

> **Layer**: Core / Feature
> **GDD**: design/gdd/player-abilities.md
> **Architecture Module**: AbilityComponent
> **Status**: In Progress
> **Stories**: 227 stories tracked

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
| 098 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Outlet Drip Vent Traverse | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 099 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Skirmish | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0005/0007/0018/0021 |
| 100 | Main Scene Dash Gate Authored Visual Replacement | Integration + Visual | Complete | ADR-0005/0007/0018/0021 |
| 101 | Main Scene Player Hit Damage Number Runtime | Integration + Visual/Feel | Complete | ADR-0002/0004/0005/0018 |
| 102 | Old Factory Route Floor Platform Visual Pass | Integration + Visual | Complete | ADR-0004/0005/0007/0018/0021 |
| 103 | Main Scene Boundary Wall Visual Pass | Integration + Visual | Complete | ADR-0004/0005/0007/0018 |
| 104 | Main Scene Reward Prompt Proximity | Integration + UI/Visual Feel | Complete | ADR-0004/0005/0007/0018 |
| 105 | Main Scene Gate Prompt Proximity | Integration + UI/Visual Feel | Complete | ADR-0004/0005/0007/0018 |
| 106 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Reward Cache | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 107 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Duct Traverse | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 108 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Exit Skirmish | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0005/0007/0018/0021 |
| 109 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Exit Reward Cache | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 110 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Traverse | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 111 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Skirmish | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0004/0005/0007/0018/0021 |
| 112 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Reward Cache | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 113 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Traverse | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 114 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Skirmish | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0004/0005/0007/0018/0021 |
| 115 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Reward Cache | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 116 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Exit Hatch Handoff | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 117 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Traverse | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 118 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Ambush | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0004/0005/0007/0018/0021 |
| 119 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay | Integration + Save/Respawn Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 120 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 121 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0004/0005/0007/0018/0021 |
| 122 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer Reward Cache | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 123 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer Exit Hatch Handoff | Integration + Gameplay Runtime + UI/Visual | Complete | ADR-0004/0007/0018/0021 |
| 124 | Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer Exit Spillway Traverse | Integration + Gameplay Runtime + Visual/Feel | Complete | ADR-0004/0007/0018/0021 |
| 125 | Old Factory Tailrace Exit Spillway Visual Pass | Integration + Visual | Complete | ADR-0004/0005/0007/0018/0021 |
| 126 | Old Factory Tailrace Exit Spillway Sluice Leech Skirmish | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0004/0005/0006/0007 |
| 127 | Old Factory Tailrace Sluice Matriarch Arena Handoff | Integration + Gameplay Runtime + Scene Management + Visual | Complete | ADR-0002/0007/0018/0021 |
| 128 | Sluice Matriarch Playable Boss3 Core | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 129 | Sluice Matriarch Aerial Attack Reward Payoff | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0002/0004/0005/0007/0018/0021 |
| 130 | Factory Aerial Breach Underground Passage Handoff | Integration + Ability Gate + Scene Handoff + Visual | Complete | ADR-0002/0004/0007/0018/0021 |
| 131 | Underground Corrosion Channel Skirmish | Integration + Gameplay Runtime + Environmental Hazard + Visual | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 132 | Underground Recovery Cistern Savepoint Traverse | Integration + Gameplay Runtime + Traversal + Save/Respawn + Visual | Complete | ADR-0002/0004/0007/0018/0019/0021 |
| 133 | Underground Deep Cistern Stalker Ambush | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0002/0004/0005/0006/0007 |
| 134 | Deep Cistern Ascender Factory Upper Altar Approach | Integration + Traversal + Scene Handoff + Visual | Complete | ADR-0002/0004/0007/0018/0021 |
| 135 | Factory Hidden Altar Wall Climb Reward Traversal | Integration + Player Movement + Frame Animation Contract | Complete | ADR-0001/0002/0003/0005/0007/0018/0021 |
| 136 | Neon Rooftops Magnetic Wall Gate Handoff | Integration + Ability Gate + Scene Handoff + Traversal + Visual | Complete | ADR-0001/0002/0003/0004/0007/0018/0021 |
| 137 | Neon Rooftops Signal Rat Ambush | Integration + Gameplay Runtime + Frame Animation Contract + Reward | Complete | ADR-0001/0002/0003/0004/0005/0006/0007 |
| 138 | Neon Rooftops Relay Spire Savepoint Traverse | Integration + Gameplay Runtime + Traversal + Save/Respawn + Visual | Complete | ADR-0002/0004/0007/0018/0019/0021 |
| 139 | Neon Rooftops Central Tower Parry-Laser Trial | Integration + Gameplay Runtime + Parry Timing + Visual | Complete | ADR-0001/0002/0004/0005/0007/0018/0019/0021 |
| 140 | Central Tower Threshold Guard Handoff | Integration + Scene Management + Combat + Save/Respawn + Frame Animation | Complete | ADR-0001/0002/0003/0004/0005/0006/0007 |
| 141 | Central Tower Inner Relay Skirmish | Integration + Gameplay Runtime + Combat + Frame Animation + Reward | Complete | ADR-0001/0002/0003/0004/0005/0006/0007 |
| 142 | Central Tower Cooling Shaft Roost Traverse | Integration + Gameplay Runtime + Traversal + Save/Respawn + Visual | Complete | ADR-0001/0002/0004/0005/0007/0018/0019/0021 |
| 143 | Central Tower Deep Lift Counterweight Ambush | Integration + Gameplay Runtime + Combat + Moving Platform + Frame Animation | Complete | ADR-0001/0002/0003/0004/0005/0006/0007/0019/0021 |
| 144 | Central Tower Apex Conduit Purge Run | Integration + Gameplay Runtime + Traversal + Save/Respawn + Environmental Hazard + Visual | Complete | ADR-0001/0002/0003/0004/0005/0007/0018/0019/0021 |
| 145 | Central Tower Crown Warden Arena Handoff | Integration + Gameplay Runtime + Scene Management + Visual | Complete | ADR-0001/0002/0003/0004/0007/0018/0021 |
| 146 | Crown Warden Playable Boss4 Core | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0001/0002/0003/0004/0005/0006/0007/0018/0019/0021 |
| 147 | Crown Warden Wall Climb Reward Payoff | Integration + Gameplay Runtime + Generated Visual Contract | Complete | ADR-0001/0002/0003/0007/0018/0021 |
| 148 | Crown Warden Victory Recall To Scrap Roost | Integration + Gameplay Runtime + Scene Flow + Generated Visual Contract | Complete | ADR-0001/0003/0007/0018/0021 |
| 149 | Skill Tree Long Tail T1-A Choice | Integration + Gameplay Runtime + UI | Complete | ADR-0001/0003/0005/0009/0011/0016/0021 |
| 150 | Skill Tree Fish Bone T1-A Heavy Shock | Integration + Gameplay Runtime + UI + Collision | Complete | ADR-0001/0003/0004/0005/0009/0011/0016/0021 |
| 151 | Skill Tree Electro Bell T1-A Pulse Touch | Integration + Gameplay Runtime + UI + Status + Visual/Feel | Complete | ADR-0001/0003/0004/0005/0009/0011/0016/0017/0021 |
| 152 | Main Scene Local Minimap Discovery Runtime | Integration + UI + Exploration + Save | Complete | ADR-0001/0002/0007/0008/0011/0013/0015/0021 |
| 153 | Main Scene Autosave Paw Stamp Feedback | Integration + UI + Audio/Feel + Save | Complete | ADR-0001/0002/0010/0011/0013/0015/0021 |
| 154 | Main Scene Low-HP Focus Activation Feedback | Integration + Visual/Feel + Audio | Complete | ADR-0002/0010/0013/0015/0019 |
| 155 | Crown Warden Parry Counter Runtime | Integration + Combat Runtime + Boss Config + Visual/Feel + Audio | Complete | ADR-0001/0002/0003/0004/0005/0010/0019 |
| 156 | Main Rat King to Echo Guardian Sequential Encounter Handoff | Integration + ACT Pacing + Scene/HUD | Complete | ADR-0002/0007/0018/0021 |
| 157 | Main Scene Focus Mode Boss Windup Runtime | Integration + Combat Readability + AI | Complete | ADR-0001/0002/0005/0006/0019 |
| 158 | Main Scene Focus Mode Boss Attack Tell Amplification | Integration + Combat Readability + Generated Visual | Complete | ADR-0001/0002/0005/0006/0010/0019 |
| 159 | Main Scene Focus Mode Environment Particle Clarity | Integration + Combat Readability + Generated Visual | Complete | ADR-0001/0002/0006/0010/0019 |
| 160 | Skill Tree Cat Claw T1-B Damage Choice | Integration + Gameplay Runtime + UI + Damage | Complete | ADR-0001/0003/0005/0009/0011/0016/0021 |
| 161 | Skill Tree Long Tail T1-B Damage Choice | Integration + Gameplay Runtime + UI + Damage | Complete | ADR-0001/0003/0005/0009/0011/0016/0021 |
| 162 | Skill Tree Fish Bone T1-B Damage Choice | Integration + Gameplay Runtime + UI + Damage | Complete | ADR-0001/0003/0005/0009/0011/0016/0021 |
| 163 | Crown Warden Phase II Transition Readability | Integration + Gameplay Runtime + Combat Readability | Complete | ADR-0002/0004/0005/0006/0010/0019/0020 |
| 164 | Skill Tree Electro Bell T1-B Damage Choice | Integration + Gameplay Runtime + UI + Damage | Complete | ADR-0001/0003/0005/0009/0011/0016/0021 |
| 165 | Echo Guardian Attack Tell Frame Animation Runtime | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0002/0004/0005/0006/0010/0018 |
| 166 | Cinderpaw Real-Input Three-Stage Light Combo Runtime | Integration + Gameplay Runtime + Frame Animation Contract | Complete | ADR-0001/0002/0004/0005/0010/0018 |
| 167 | Cinderpaw Authored Three-Stage Light Hitbox Timing | Integration + Gameplay Runtime + Collision Timing | Complete | ADR-0001/0002/0004/0005/0010/0018 |
| 168 | Crown Warden ACT Complete Epilogue At Scrap Roost | Integration + UI/Visual + Save/Scene Flow | Complete | ADR-0001/0002/0003/0007/0010/0011/0015/0018/0021 |
| 169 | Main Rat King Victory Continue to Echo Guardian Same-Runtime Handoff | Integration + ACT Pacing + Scene/HUD | Complete | ADR-0002/0007/0018/0021 |
| 170 | Neon Rooftops Central Tower Parry-Laser Motion Readability | Visual/Feel + Frame Animation Contract | Complete | ADR-0001/0002/0004/0005/0010/0018 |
| 171 | Central Tower Local Minimap Continuity | Integration + UI + Exploration + Save | Complete | ADR-0001/0002/0007/0008/0011/0013/0015/0021 |
| 172 | Crown Observatory Wall-Climb Epilogue Ascent | Integration + Gameplay + Exploration + Save | Complete | ADR-0001/0002/0007/0008/0013/0015/0021 |
| 173 | Sluice Matriarch Pressure Geyser Pattern | Attack Pattern + Frame Animation + VFX | Complete | ADR-0002/0004/0005/0006 |
| 174 | Sluice Matriarch Phase II Transition Readability | Integration + Gameplay Runtime + Frame Animation | Complete | ADR-0002/0004/0005/0006/0010/0019/0020 |
| 175 | Echo Guardian Secondary Attack Playable Loop | Attack Pattern + Frame Animation + Data Integration | Complete | ADR-0002/0004/0005/0006/0010/0018 |
| 176 | Crown Warden Dedicated Phase Transition Frame Animation | Visual/Feel + Frame Animation + Data Integration | Complete | ADR-0002/0004/0005/0006/0010/0019/0020 |
| 177 | Old Factory Lower Deck Skirmish Production-Input Handoff | Integration + Gameplay Runtime + Production Input | Complete | ADR-0004/0005/0006/0007/0018/0021 |
| 178 | Rat King Committed Charge Locomotion | Attack Pattern + Collision + Data Integration | Complete | ADR-0002/0003/0004/0005/0006/0018 |
| 179 | Old Factory Lower Deck Reward Cache Production-Input Handoff | Integration + Gameplay Runtime + Production Input + Reward | Complete | ADR-0004/0007/0018/0021 |
| 180 | Sluice Matriarch Shared Death and Retry Flow | Integration + Gameplay Runtime + Death/Respawn + Visual Feedback | Complete | ADR-0002/0004/0005/0007/0019/0020 |
| 181 | Old Factory Pressure Valve Authored Motion Readability | Visual/Feel + Frame Animation Contract | Blocked | ADR-0002/0007/0010/0018/0021 |
| 182 | Sluice Matriarch Chase Spacing | AI State + ACT Pacing + Existing Frame Animation | Complete | ADR-0002/0004/0005/0006 |
| 183 | Old Factory Lower Deck Progression Production-Input Handoff | Integration + Gameplay Runtime + Production Input | Complete | ADR-0004/0007/0018/0021 |
| 184 | Crown Warden Opening Approach Spacing | AI State + ACT Pacing + Existing Frame Animation | Complete | ADR-0002/0004/0005/0006 |
| 185 | Old Factory Breach Corridor Production Movement Handoff | Integration + Gameplay Runtime + Production Movement + Visual Readability | Complete | ADR-0004/0005/0006/0007/0018/0021 |
| 186 | Old Factory Deep Bulkhead Guard Production Movement Handoff | Integration + Production Movement + Frame Animation + Visual Readability | Complete | ADR-0004/0005/0006/0007/0018/0021 |
| 187 | Old Factory Post-Relay Production Movement Handoff | Integration + Gameplay Runtime + Production Movement + Visual Readability | Complete | ADR-0004/0005/0006/0007/0018/0021 |
| 188 | Old Factory Relay-Forward Reward/Hatch Production-Input Handoff | Integration + Gameplay Runtime + Production Input + Visual Readability | Complete | ADR-0004/0007/0018/0021 |
| 189 | Old Factory Forward Conduit Production Movement Handoff | Integration + Gameplay Runtime + Production Movement + Visual Readability | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 190 | Old Factory Forward Pressure Traverse Production Movement Handoff | Integration + Gameplay Runtime + Production Movement + Visual Readability | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 191 | Old Factory Forward Pressure Counter-Ambush Production Movement Handoff | Integration + Gameplay Runtime + Production Movement + Combat Readability | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 192 | Old Factory Forward Pressure Reward Cache Production-Input Handoff | Integration + Gameplay Runtime + Production Input + Reward | Complete | ADR-0002/0004/0007 |
| 193 | Old Factory Forward Pressure Exit Guard Production Movement Handoff | Integration + Gameplay Runtime + Production Movement + Combat Readability | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 194 | Old Factory Forward Pressure Exit Relay Production Contact Handoff | Integration + Gameplay Runtime + Production Contact + Savepoint Readability | Complete | ADR-0002/0004/0007/0018/0021 |
| 195 | Old Factory Forward Pressure Exit Gate Production Input Handoff | Integration + Gameplay Runtime + Production Input + Route Readability | Complete | ADR-0002/0004/0007/0018/0021 |
| 196 | Old Factory Forward Pressure Route Handoff Marker Production Input Handoff | Integration + Gameplay Runtime + Production Input + Encounter Pacing | Complete | ADR-0004/0007/0018/0021 |
| 197 | Old Factory Forward Pressure Beacon Ambush Production Combat Handoff | Integration + Gameplay Runtime + Production Combat + Encounter Pacing | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 198 | Old Factory Forward Pressure Overrun Production Combat Handoff | Integration + Gameplay Runtime + Production Combat + Encounter Pacing | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 199 | Old Factory Forward Pressure Breaker Production Combat/Cut Handoff | Integration + Gameplay Runtime + Production Combat + Production Input + Encounter Pacing | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 200 | Old Factory Forward Pressure Relief Production Combat Handoff | Integration + Gameplay Runtime + Production Combat + Death Feedback + Encounter Pacing | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 201 | Old Factory Forward Pressure Coil Rat Production Combat Handoff | Integration + Gameplay Runtime + Production Combat + Death Feedback + Encounter Pacing | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 202 | Old Factory Forward Pressure Coil Pincer Production Combat Handoff | Integration + Gameplay Runtime + Production Combat + Death Feedback + Encounter Pacing | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 203 | Old Factory Coil Pincer Flank Spacing | Integration + Gameplay Runtime + AI/Encounter Pacing + Visual Readability | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 204 | Old Factory Coil Aftershock Production Combat Reward Handoff | Integration + Gameplay Runtime + Production Combat + Production Input + Reward | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 205 | Old Factory Aftershock Exit Skirmish Production Combat Exhaust Handoff | Integration + Gameplay Runtime + Production Combat + Production Movement + Encounter Pacing | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 206 | Old Factory Aftershock Exhaust Production Traverse Pursuer Handoff | Integration + Gameplay Runtime + Production Movement + Hazard Timing | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 207 | Old Factory Aftershock Exhaust Pursuer Production Combat Reward Handoff | Integration + Gameplay Runtime + Production Combat + Production Input + Reward | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 208 | Old Factory Aftershock Exhaust Flank Production Combat Breaker Handoff | Integration + Gameplay Runtime + Production Movement + Production Combat + Hazard | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 209 | Old Factory Aftershock Exhaust Breaker Production Combat Escape Handoff | Integration + Production Movement + Production Combat + Hazard + Production Input | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 210 | Old Factory Aftershock Exhaust Escape Production Combat Exit Hatch Handoff | Integration + Production Movement + Production Combat + Live Death + Route Handoff | Complete | ADR-0002/0004/0005/0006/0007/0018/0021 |
| 211 | Old Factory Aftershock Exhaust Exit Hatch Production Input Cooling Duct Handoff | Integration + Production Input + Production Movement + Route Handoff | Complete | ADR-0004/0007/0018/0021 |
| 212 | Old Factory Aftershock Exhaust Exit Hatch Open Readability | Visual/Feel + Integration | Complete | ADR-0004/0007/0018/0021 |
| 213 | Old Factory Aftershock Cooling Duct Production Hazard Traverse Handoff | Integration + Production Movement + Hazard Timing + Route Handoff | Complete | ADR-0004/0007/0018/0021 |
| 214 | Old Factory Aftershock Condenser Valve Production Combat Savepoint Handoff | Integration + Production Movement + Production Combat + Live Death + Savepoint Handoff | Complete | ADR-0004/0005/0006/0007/0018/0021 |
| 215 | Old Factory Aftershock Condenser Savepoint Production Contact Respawn Handoff | Integration + Production Movement + Contact Activation + Death/Respawn + Route Handoff | Complete | ADR-0004/0007/0018/0021 |
| 216 | Old Factory Aftershock Condenser Outlet Production Hazard Traverse Handoff | Integration + Production Movement + Hazard Timing + Route Handoff | Complete | ADR-0001/0004/0007 |
| 217 | Old Factory Aftershock Condenser Outlet Clamp Production Combat Drip Vent Handoff | Integration + Production Movement + Production Combat + Live Death + Route Handoff | Complete | ADR-0002/0004/0005/0006/0007 |
| 218 | Old Factory Aftershock Condenser Outlet Drip Vent Production Hazard Traverse Overflow Pump Handoff | Integration + Production Movement + Hazard Timing + Route Handoff | Complete | ADR-0004/0006/0007 |
| 219 | Old Factory Aftershock Condenser Overflow Pump Production Combat Reward Cache Handoff | Integration + Production Combat + Production Input + Live Death + Reward | Complete | ADR-0002/0004/0005/0007 |
| 220 | Old Factory Aftershock Condenser Overflow Pump Runoff Hatch Production Input Duct Handoff | Integration + Production Input + Production Movement + Hazard Timing + Route Handoff | Complete | ADR-0004/0007 |
| 221 | Old Factory Runoff Exit Production Combat Reward Cache Handoff | Integration + Production Movement + Production Combat + Live Death + Reward | Complete | ADR-0002/0004/0005/0007 |
| 222 | Old Factory Runoff Exit Gate Production Input Outlet Handoff | Integration + Production Input + Production Movement + Hazard Timing + Route Handoff | Complete | ADR-0004/0007 |
| 223 | Old Factory Runoff Outlet Production Combat Reward Cache Handoff | Integration + Production Movement + Production Combat + Live Death + Reward | Complete | ADR-0002/0004/0005/0007 |
| 224 | Old Factory Runoff Outlet Service Hatch Production Input Sluice Handoff | Integration + Production Input + Production Movement + Physical Hazard | Complete | ADR-0004/0007/0018/0021 |
| 225 | Old Factory Service Sluice Production Combat Reward Cache Handoff | Integration + Production Movement + Production Combat + Live Death + Reward | Complete | ADR-0002/0004/0005/0007 |
| 226 | Old Factory Service Sluice Reward Cache Production Input Exit Hatch Handoff | Integration + Production Input + Reward + Route Handoff | Complete | ADR-0004/0007 |
| 227 | Old Factory Service Sluice Exit Hatch Production Input Tailrace Handoff | Integration + Production Input + UI/Visual + Route Handoff | Complete | ADR-0004/0007/0018/0021 |
| 228 | Old Factory Service Sluice Tailrace Production Hazard Traverse Ambush Handoff | Integration + Production Movement + Physical Hazard + Route Handoff | Complete | ADR-0004/0007/0018/0021 |
| 229 | Old Factory Service Sluice Tailrace Ambush Production Combat Relay Handoff | Integration + Production Movement + Production Combat + Live Death + Route Handoff | Complete | ADR-0002/0004/0005/0007 |
| 230 | Old Factory Service Sluice Tailrace Relay Production Contact Respawn Runoff Handoff | Integration + Production Movement + Contact Activation + Death/Respawn + Route Handoff | Complete | ADR-0004/0007/0018/0021 |
| 231 | Old Factory Service Sluice Tailrace Relay Runoff Production Hazard Traverse Pincer Handoff | Integration + Production Movement + Physical Hazard + Route Handoff | Complete | ADR-0004/0007 |

## Definition of Done

This epic is complete when:

- Ability registry data loads through DataManager and validates through schema.
- `AbilityComponent` is mounted under Player and exposes all GDD query and
  activation APIs.
- Initial abilities are available at game start and boss rewards unlock later
  abilities exactly once.
- Dash, double jump, aerial attack, wall climb, parry, and future ability
  consumers are connected to gameplay input/presentation as their stories land.
- Authored optional encounters are reachable through production movement and
  interaction paths rather than test-only direct API calls.
- Player-visible 2D ability states use `AnimatedSprite2D` + `SpriteFrames` and
  pass MCP runtime checks.
- Logic and integration stories have passing focused tests plus risk-appropriate
  Godot MCP evidence.

## Next Step

Story231 now activates and completes Story120 through fresh real movement,
applies exact physical steam damage through the four-frame vent cycle, and
leaves Story121 available but inactive behind no-input and positive-displacement
guards. The next Old Factory priority is Story121 production movement,
shared-hit combat and live dual-death closure into Story122's cache handoff.
Rat King Phase III's documented three-hit berserk combo remains the next
independent Boss-depth slice, while Story181 remains blocked only on external
image2 connectivity.
