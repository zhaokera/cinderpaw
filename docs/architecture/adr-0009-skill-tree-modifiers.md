# ADR-0009: 技能树 Modifier 系统架构

## Summary
定义技能树如何向战斗系统注入加成：采用 Modifier Provider 模式，SkillTreeManager 注册 modifier，CombatComponent 查询当前生效的 modifier 列表。使用 F8 combined_bonus 统一上限公式（乘法递减，cap 0.75）。

## Status
Proposed

## Date
2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6.3 |
| **Domain** | Core / GDScript |
| **Knowledge Risk** | LOW — 纯 GDScript 设计，无引擎特定 API |
| **Post-Cutoff APIs Used** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Autoload), ADR-0003 (数据管理), ADR-0005 (战斗状态机) |
| **Enables** | 技能树实现, 护符系统集成 |
| **Blocks** | 技能树和护符系统的战斗集成 |

## Context

### Problem Statement

技能树解锁的加成需要注入到战斗计算中。但战斗系统（DamageCalculator）是纯函数，不知道技能树的存在。需要一种机制让技能树向战斗系统提供加成数据，同时保持解耦。

### Constraints

- **解耦**: DamageCalculator 不直接引用 SkillTreeManager
- **统一上限**: 技能+护符的同类加成使用 F8 combined_bonus（乘法递减，cap 0.75）
- **可扩展**: 新增 modifier 类型不需要修改 CombatComponent
- **可查询**: CombatComponent 每帧可以查询当前生效的 modifier

## Decision

### Modifier 数据结构

```gdscript
class_name SkillModifier
extends RefCounted

var skill_id: StringName      # 来源技能节点ID
var type: StringName          # "damage_bonus" | "cooldown_reduction" | "window_extension" | ...
var target_action: StringName # "light_attack" | "heavy_attack" | "dodge" | ... (空=全局)
var stat_key: StringName      # "attack_power" | "crit_window" | "dodge_iframes" | ...
var operation: StringName     # "add_flat" | "add_percent" | "multiply"
var value: float              # 加成值
var condition: Dictionary     # 触发条件（如 {"weapon": "cat_claw", "after_dodge": true}）
```

### Modifier Provider 接口

```gdscript
# SkillTreeManager (场景级组件，挂在World场景树下)
# 参考 ADR-0001 的节点结构
func register_modifier(modifier: SkillModifier) -> void
func unregister_modifier(skill_id: StringName) -> void
func get_modifiers(action_id: StringName = &"") -> Array[SkillModifier]
func get_stat_bonus(stat_key: StringName) -> float  # 聚合后的总加成
```

**注意**: SkillTreeManager不是Autoload，而是场景级组件（参考ADR-0001的节点结构）。CombatComponent通过场景树查找获取其引用：
```gdscript
# CombatComponent 获取 SkillTreeManager 引用
var skill_tree: SkillTreeManager = get_tree().get_first_node_in_group(&"skill_tree_manager")
```

### F8 Combined Bonus（技能+护符统一上限）

```gdscript
# SkillTreeManager
func get_combined_bonus(stat_key: StringName, charm_bonus: float) -> float:
    var skill_bonus: float = _get_skill_bonus(stat_key)  # 技能树提供的加成
    # 乘法递减叠加: combined = 1 - (1 - skill) * (1 - charm)
    var combined: float = 1.0 - (1.0 - skill_bonus) * (1.0 - charm_bonus)
    return minf(combined, 0.75)  # 硬上限 0.75
```

### CombatComponent 集成

```gdscript
# CombatComponent._calculate_attack_damage()
# 通过场景树查找获取 SkillTreeManager（参考 ADR-0001 通信规则）
var skill_tree: SkillTreeManager = get_tree().get_first_node_in_group(&"skill_tree_manager")
var modifiers: Array = skill_tree.get_modifiers(&"light_attack") if skill_tree else []
var charm_bonus: float = CharmSystem.get_charm_bonus(&"attack_power") if Engine.has_singleton("CharmSystem") else 0.0
var bonus: float = skill_tree.get_combined_bonus(&"attack_power", charm_bonus) if skill_tree else 0.0
var result = DamageCalculator.calculate_damage(
    attack_type, weapon_id, hit_frame, combo_index,
    parry_timing, attack_power * (1.0 + bonus), enemy_defense, modifiers
)
```

### 护符系统集成

护符系统通过 `charm_bonus` 参数传入 F8 公式：
```gdscript
# CharmSystem
func get_charm_bonus(stat_key: StringName) -> float:
    var total: float = 0.0
    for charm in _equipped_charms:
        if charm.has_bonus(stat_key):
            total += charm.get_bonus(stat_key)
    return minf(total, _charm_cap)  # 护符自身上限（由技能树定义）
```

## Consequences

### Positive
- **解耦**: DamageCalculator 不知道技能树/护符的存在
- **统一上限**: F8 公式确保加成不会无限叠加
- **灵活**: 新增 modifier 类型只需扩展数据结构
- **可测试**: modifier 注册/查询可独立测试

### Negative
- **复杂度**: modifier condition 系统可能变得复杂
- **性能**: 每帧查询 modifier 列表（数据量小，可接受）
- **调试**: modifier 叠加链路不直观

## GDD Requirements Addressed

- `design/gdd/skill-tree.md` — Rule 3 (F8 combined_bonus), Rule 9 (Modifier Provider API)
- `design/gdd/charm-equipment.md` — charm_bonus 集成

## Verification

- [ ] 单元测试：modifier 注册/注销/查询
- [ ] 单元测试：F8 combined_bonus 计算正确性
- [ ] 集成测试：技能树加成正确注入战斗计算
