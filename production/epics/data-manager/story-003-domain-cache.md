# Story 003: DomainCache + 核心查询接口 + 懒加载

> **Epic**: data-manager
> **Status**: Ready
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 2-3 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: —

## Context

**GDD**: `design/gdd/data-balance.md`
**Requirement**: `TR-data-002`, `TR-data-007`

**ADR Governing Implementation**: ADR-0003: 数据管理架构, ADR-0001: Autoload 架构
**ADR Decision Summary**: JSON 为源格式 + Resource 桥接。标准接口契约：`_ready()` 获取域 + 连接 `on_domain_changed` + `get_entry()` null→优雅降级。

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: `get_entry()` 返回 Variant — Godot 4.6 required types 下需验证是否允许返回 null。如不允许，改为 `Dictionary` + `has_entry()` 前置检查。

**Control Manifest Rules (Foundation layer)**:
- Required: JSON 为源格式；标准数据消费契约
- Forbidden: 禁止 Resource (.tres) 作为源数据格式

---

## Acceptance Criteria

- [ ] AC-01: get_entry() 返回已加载域中存在的条目 → 非 null Dictionary
- [ ] AC-02: get_entry() 对不存在的条目返回 null，不抛出异常
- [ ] AC-03: get_entry() 对不存在的域返回 null
- [ ] AC-04: preload=false 域首次查询时自动懒加载 → 返回正确数据，后续调用命中缓存
- [ ] AC-05: load_input_config(path) 返回完整配置 Dictionary

---

## Implementation Notes

1. **缓存结构**: `_cache: Dictionary[StringName, Dictionary]` — domain_name → entries
2. **懒加载**: `get_entry()` 发现域未加载时，调用内部 `_load_domain()` 按需加载
3. **Variant 返回**: 验证 Godot 4.6 是否允许 Variant 函数返回 null。如不允许，增加 `has_entry(domain, id) -> bool` 前置检查
4. **load_input_config**: 特殊接口，返回 input_config 域的完整 Dictionary

---

## Out of Scope

- [Story 002]: SchemaValidator 验证
- [Story 004]: HotReloader 触发缓存更新

---

## QA Test Cases

- **AC-01**: get_entry 返回正确数据
  - Given: DataManager READY，"damage_params" 域已加载含 "cat_claw"
  - When: `get_entry("damage_params", "cat_claw")`
  - Then: 返回非 null Dictionary

- **AC-02**: 不存在条目返回 null
  - Given: 域已加载
  - When: `get_entry("damage_params", "nonexistent")`
  - Then: 返回 null，无异常

- **AC-03**: 不存在域返回 null
  - Given: DataManager READY
  - When: `get_entry("nonexistent_domain", "any")`
  - Then: 返回 null

- **AC-04**: 懒加载 preload=false 域
  - Given: manifest 中 "enemy_stats" preload=false
  - When: 首次 `get_entry("enemy_stats", "some_enemy")`
  - Then: 域按需加载，返回正确数据

- **AC-05**: load_input_config 返回完整配置
  - Given: "input_config" 域已加载
  - When: `load_input_config(path)`
  - Then: 返回非空 Dictionary

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/data/story_003_domain_cache_test.gd` — must exist and pass
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 001, Story 002
- Unlocks: Story 004
