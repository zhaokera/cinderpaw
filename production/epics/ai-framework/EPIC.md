# Epic: AI Framework

> **Layer**: Core
> **GDD**: design/gdd/ai-framework.md
> **Architecture Module**: AISystem
> **Status**: Complete
> **Stories**: 6 stories

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | AI State Machine + Active Enemy Count | Logic | Complete | ADR-0001, ADR-0002, ADR-0006 |
| 002 | Perception Cone + Line-of-Sight Query | Logic | Complete | ADR-0006 |
| 003 | Data-Driven Attack Pattern Loading | Integration | Complete | ADR-0003, ADR-0006 |
| 004 | Attack Phase Execution + Collision Adapter | Integration | Complete | ADR-0004, ADR-0006 |
| 005 | Boss Phase + Focus Mode Signal Integration | Integration | Complete | ADR-0002, ADR-0006 |
| 006 | Low-HP Adaptation + Weighted Attack Selection | Logic | Complete | ADR-0006 |

## Overview

Implement `AIComponent` as a Core enemy component with a six-state behavior machine, perception checks, data-driven attack patterns, frame-level attack execution through CollisionComponent, focus-mode windup extension, boss phase switching, active-enemy counting, and low-HP behavior adaptation. The MVP scope favors predictable, learnable enemy behavior over generalized behavior trees or automatic navigation.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Autoload architecture | AI is an entity component mounted under Enemy nodes, not an Autoload. | LOW |
| ADR-0002: Signal communication | AI listens to Health/Boss/Focus signals using Godot typed `Signal.connect(callable)` patterns. | LOW |
| ADR-0003: Data manager architecture | Enemy attack patterns are source JSON data loaded through DataManager domains. | LOW |
| ADR-0004: Collision detection architecture | AI attack execution activates CollisionComponent hitboxes rather than using PhysicsBody hit detection. | LOW |
| ADR-0006: AI behavior system architecture | AI uses enum + match state machine, RayCast2D-style perception, data-driven attack patterns, static active enemy count, and focus windup extension. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-ai-001 | 每个AI实体需要独立的行为状态机（IDLE/PATROL/CHASE/ATTACK/FLEE/STUN），支持帧级状态转换 | ADR-0006 ✅ |
| TR-ai-002 | 感知系统需要射线投射（RayCast2D）实现视线检测，支持可配置的感知半径（100-500px）和感知角度（60-180°） | ADR-0006 ✅ |
| TR-ai-003 | 攻击模式数据结构需要包含 startup_frames/active_frames/recovery_frames/hitbox_config/vulnerability_window，从数据基础设施加载 | ADR-0003, ADR-0006 ✅ |
| TR-ai-004 | AI需要监听 on_boss_phase_change(boss_id, new_phase) 信号，在阶段转换后切换攻击模式集 | ADR-0002, ADR-0006 ✅ |
| TR-ai-005 | AI需要监听 on_focus_mode_changed(active: bool) 信号，激活时对后续攻击追加 windup_extension_frames（默认6帧） | ADR-0002, ADR-0006 ✅ |
| TR-ai-006 | 需要提供 get_active_enemy_count() → int 查询接口，返回处于 CHASE 或 ATTACK 状态的敌人数量 | ADR-0006 ✅ |
| TR-ai-007 | 攻击执行需要调用碰撞系统的 activate_hitbox() 接口 | ADR-0004, ADR-0006 ✅ |
| TR-ai-008 | 敌人攻击前摇结束到Hitbox激活需要帧级同步，startup_frames 精度为1帧（16.6ms@60fps） | ADR-0006 ✅ |
| TR-ai-009 | 低HP行为适应需要查询自身HP百分比（FLEE阈值<20%，狂暴阈值<30%攻击速度+20%） | ADR-0006 ✅ |
| TR-ai-010 | 攻击选择使用加权随机（base_weight × phase_modifier × hp_modifier），权重范围0.05-40.0 | ADR-0006 ✅ |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`.
- AIComponent can be instantiated in GdUnit4 without a full Enemy scene.
- The six-state AI machine, perception, attack pattern loading, attack execution, focus/boss integration, active-enemy counting, low-HP adaptation, and weighted selection are covered by passing tests.
- AI attack execution calls CollisionComponent-compatible adapters and never calls Presentation directly.
- Boss-specific behavior configuration remains delegated to the Boss Configuration epic.

## Next Step

AI Framework Core scope is complete. Continue with a downstream consumer epic such as Boss Configuration, Combat Presentation, Audio, HUD/UI, or enemy tuning integration.
