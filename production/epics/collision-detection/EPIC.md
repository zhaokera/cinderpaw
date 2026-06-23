# Epic: Collision Detection

> **Layer**: Core
> **GDD**: design/gdd/collision-detection.md
> **Architecture Module**: CollisionSystem
> **Status**: Complete
> **Stories**: 5 stories

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | HitboxArea + Activation Lifecycle | Logic | Complete | ADR-0001, ADR-0004 |
| 002 | Hurtbox States + Collision Layers | Logic | Complete | ADR-0004 |
| 003 | Frame-Level Hit Detection + HitEvent Signal | Integration | Complete | ADR-0002, ADR-0004 |
| 004 | Multi-Target Hits + Duplicate Suppression | Logic | Complete | ADR-0004 |
| 005 | Entity Death Cleanup + Combat Adapter Integration | Integration | Complete | ADR-0002, ADR-0004, ADR-0005 |

## Overview

Implement `CollisionComponent` as a Core entity component that owns per-entity Hitbox/Hurtbox state, frame-level hit detection, Godot 2D collision layer configuration, duplicate-hit suppression, and typed hit-confirmation payloads. Combat, AI, and Presentation consume its `on_hit_confirmed` signal; Collision never calls Presentation directly.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Autoload architecture | Collision is an entity component under Player/Enemy, not an Autoload. | LOW |
| ADR-0002: Signal communication | `on_hit_confirmed` uses a `HitEvent` payload because the hit payload has more than three fields. | LOW |
| ADR-0004: Collision detection architecture | Collision uses Godot `Area2D` + `CollisionShape2D`, 5 collision layers, frame-level detection, and `HitboxArea` duplicate tracking. | LOW |
| ADR-0005: Combat state machine architecture | Combat activates hitboxes and consumes confirmed hit payloads through narrow component interfaces. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-collision-001 | 需要帧级Hitbox/Hurtbox碰撞检测引擎，在 `_physics_process` 中每帧执行所有活跃Hitbox与Hurtbox的重叠检测 | ADR-0004 ✅ |
| TR-collision-002 | Hitbox需要帧级精度控制：`activate_hitbox(entity_id, hitbox_id, duration_frames, offset, size)` 激活后超时自动停用 | ADR-0004 ✅ |
| TR-collision-003 | Hurtbox需要三种状态（normal/shrunk/gone），shrunk缩小50%，gone完全消失 | ADR-0004 ✅ |
| TR-collision-004 | 需要5层碰撞分层（player_attack/enemy_attack/player_hurt/enemy_hurt/environment），位掩码匹配防止自伤和友军伤害 | ADR-0004 ✅ |
| TR-collision-005 | `on_hit_confirmed` 信号需要携带 hit_data，`mark_hit()` 防止同一攻击多次命中 | ADR-0002, ADR-0004 ✅ |
| TR-collision-006 | 同一Hitbox同帧可重叠多个Hurtbox（范围攻击），每个独立触发 `on_hit_confirmed` | ADR-0004 ✅ |
| TR-collision-007 | 实体死亡时需要自动停用所有活跃Hitbox，监听 `on_death` 信号 | ADR-0002, ADR-0004 ✅ |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`.
- All Core acceptance criteria from `design/gdd/collision-detection.md` are covered by passing tests under `tests/unit/collision/`.
- `CollisionComponent` can be instantiated in GdUnit4 without a full Player scene.
- Combat can connect to `on_hit_confirmed` and receive `HitEvent` payloads with hitbox id, target id, hit position, hit frame, and attack metadata.
- Presentation-layer VFX, debug UI, and audio requirements are explicitly deferred to downstream epics.

## Next Step

Collision Detection Core scope is complete. Continue with a downstream consumer epic such as AI Framework, Combat Presentation, Weapon Styles, Audio, or HUD/UI.
