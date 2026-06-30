# ADR-0012: 2D 物理引擎选择

## Summary
确认使用 Godot Physics 2D（默认）作为 2D 物理引擎。Godot 4.6 中 Jolt Physics 仅替换 3D 默认引擎，2D 物理保持不变。

## Status
Proposed

## Date
2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | Physics / Platform |
| **Knowledge Risk** | LOW — Godot Physics 2D 自 4.0 以来稳定 |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | None — 2D 物理 API 无变化 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | 碰撞检测、角色移动、物理交互 |
| **Blocks** | 物理相关系统实现 |

## Context

### Problem Statement

Godot 4.6 将 Jolt Physics 设为 3D 默认物理引擎。需要确认 2D 物理引擎的选择，以及是否需要切换到第三方 2D 物理引擎。

### Constraints

- **性能**: 2D 平台跳跃需要精确的物理行为
- **稳定性**: 碰撞检测必须可靠
- **兼容性**: 与 Godot 的 TileMapLayer、CharacterBody2D 等节点兼容

## Decision

### 选择 Godot Physics 2D

**理由**:
1. **默认引擎**: Godot 4.6 中 2D 物理仍为 Godot Physics 2D（Jolt 仅替换 3D）
2. **稳定性**: 自 4.0 以来 API 稳定，无 breaking changes
3. **兼容性**: 与 CharacterBody2D、Area2D、CollisionShape2D 完美兼容
4. **性能**: 对于 2D 平台游戏足够，无性能瓶颈
5. **简单性**: 无需引入第三方依赖

### 不使用 Jolt 2D 的原因

- **不存在**: Jolt Physics 没有 2D 版本
- **不需要**: Godot Physics 2D 满足项目需求
- **风险**: 第三方 2D 物理引擎可能引入兼容性问题

### 物理节点选择

| 用途 | 节点类型 | 理由 |
|------|---------|------|
| 玩家/敌人移动 | `CharacterBody2D` | 精确控制移动，`move_and_slide()` 内置碰撞处理 |
| Hitbox/Hurtbox | `Area2D` + `CollisionShape2D` | 检测重叠，不需要物理响应 |
| 环境碰撞 | `StaticBody2D` + `CollisionShape2D` | 静态碰撞体 |
| 可互动物体 | `RigidBody2D`（少量） | 需要物理模拟的物体（如可推动箱子） |

### 碰撞层配置

碰撞层的具体定义由 **ADR-0004（碰撞检测架构）** 统一管理。本ADR仅确认使用Godot的Layer/Mask系统进行碰撞过滤。

**参考**: ADR-0004定义了5层碰撞层（player_attack, enemy_attack, player_hurt, enemy_hurt, environment）及其碰撞矩阵。

## Consequences

### Positive
- **简单**: 无需额外配置，开箱即用
- **稳定**: 久经考验的 2D 物理引擎
- **兼容**: 与 Godot 生态完美集成

### Negative
- **无**: 对于 2D 平台游戏，Godot Physics 2D 没有明显缺点

## GDD Requirements Addressed

- `design/gdd/collision-detection.md` — Rule 1 (Hitbox/Hurtbox), Rule 2 (碰撞层)
- `design/gdd/feline-combat.md` — 角色移动、闪避、弹反物理

## Verification

- [ ] CharacterBody2D `move_and_slide()` 在斜坡上行为正确
- [ ] Area2D 重叠检测帧级精确
- [ ] 碰撞层配置符合设计
- [ ] 性能测试：10+ 敌人同时存在时帧率稳定
