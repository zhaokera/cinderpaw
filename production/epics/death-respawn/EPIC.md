# Epic: Death & Respawn

> **Layer**: Feature
> **GDD**: design/gdd/death-respawn.md
> **Architecture Module**: GameFlowController + HealthComponent adapters
> **Status**: In Progress
> **Stories**: 6 stories

## Overview

Implement the non-punitive death loop: detect death, delay for the death beat,
revive with HealthComponent's configured HP percentage, restore the player to a
respawn point, provide short invincibility, preserve progress, and optionally
surface a learning-focused battle summary.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | Respawn flow is scene-owned controller logic, not a global Autoload. | LOW |
| ADR-0002: Signal communication | HealthComponent death and GameFlow respawn use typed signals. | LOW |
| ADR-0007: Scene management | Future scene/savepoint transitions must route through SceneManager. | MED |
| ADR-0019: Health component | Revive percentage, death metadata, i-frames, and HP state are HealthComponent references. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-respawn-001 | Death flow progresses through death delay, respawn, revive, and control return. | ADR-0001, ADR-0002 ✅ partial |
| TR-respawn-002 | Respawn point priority: savepoint, clan base fallback, boss entrance. | ADR-0007 ✅ boss entrance |
| TR-respawn-003 | Boss death resets arena state and boss HP. | ADR-0007 ✅ |
| TR-respawn-004 | Optional hunter lesson battle summary. | ADR-0002 ✅ partial |
| TR-respawn-005 | No currency/item/progress loss. | ADR-0007 ✅ runtime adapter |
| TR-respawn-006 | Total death-to-control budget remains under 5.5 seconds. | ADR-0001 ✅ partial |
| TR-respawn-007 | 2 seconds invincibility plus visual feedback after revive. | ADR-0019 ⚠️ partial |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Runtime Death + Quick Respawn Loop | Integration | Complete | ADR-0001, ADR-0002, ADR-0019 |
| 002 | Respawn Invincibility Visual Feedback | Visual/Feel | Complete | ADR-0019 |
| 003 | Boss Arena Respawn Reset | Integration | Complete | ADR-0007 |
| 004 | Savepoint Respawn Selection | Integration | Ready | ADR-0007 |
| 005 | Battle Summary Handoff | Integration | Complete | ADR-0002, ADR-0019 |
| 006 | No-Loss Respawn State Contract | Integration | Complete | ADR-0007 |

## Definition of Done

This epic is complete when:
- Death, respawn, revive HP, invincibility, and control unlock are automated.
- Respawn point priority works across savepoints, clan base fallback, and boss
  entrances.
- Boss arena reset has runtime evidence.
- Optional battle-summary UI is settings-controlled.
- No-loss rules are covered by save/economy integration tests.

## Next Step

Continue with Death & Respawn Story 004 now that SaveSystem and the logical
SceneManager baseline are available for savepoint priority.
