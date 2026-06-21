# Story 002: SchemaValidator + 三级失败处理

> **Epic**: data-manager
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 3-4 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-21

## Context

**GDD**: `design/gdd/data-balance.md`
**Requirement**: `TR-data-004`

**ADR Governing Implementation**: ADR-0003: 数据管理架构
**ADR Decision Summary**: SchemaValidator 为静态类，检查必填字段/类型/范围/枚举/跨字段约束。三级失败处理：首次→默认值，热重载→旧缓存，manifest→ERROR。

**Engine**: Godot 4.6.3 | **Risk**: LOW

**Control Manifest Rules (Foundation layer)**:
- Required: SchemaValidator 三级失败处理
- Forbidden: 禁止绕过 SchemaValidator

---

## Acceptance Criteria

- [ ] AC-01: 有效 JSON 通过 Schema 验证 → `result.is_valid == true`，errors 为空
- [ ] AC-02: 缺少必填字段 → `result.is_valid == false`，errors 包含字段名
- [ ] AC-03: 类型不匹配 → `result.is_valid == false`，errors 包含期望类型
- [ ] AC-04: 首次加载验证失败 → 域缓存为空 Dictionary + ERROR 日志，DataManager 仍进入 READY
- [ ] AC-05: 热重载验证失败 → 保留旧缓存不变 + ERROR 日志
- [ ] AC-06: Schema 文件不存在 → 输出 WARNING，跳过验证，数据正常加载

---

## Implementation Notes

1. **SchemaValidator 为 `class_name` 静态类**: `static func validate(data, schema) -> ValidationResult`
2. **Schema 文件路径**: `res://data/schemas/[domain_name].schema.json`
3. **三级失败处理**:
   - Level 1（首次加载）: 验证失败 → 空 Dictionary 缓存 + ERROR 日志
   - Level 2（热重载）: 验证失败 → 保留旧缓存 + ERROR 日志
   - Level 3（manifest 失败）: 由 Story 001 处理
4. **默认值策略**: 首次加载验证失败时使用空 Dictionary，消费系统在 `get_entry()` 返回 null 时自行提供默认值
5. **Schema 缺失**: 输出 WARNING，跳过验证（不阻塞加载）

---

## Out of Scope

- [Story 001]: manifest 加载和状态机
- [Story 004]: HotReloader 文件变更检测

---

## QA Test Cases

- **AC-01**: 有效 JSON 通过验证
  - Given: 符合 schema 的 JSON Dictionary
  - When: `SchemaValidator.validate(data, schema)` 执行
  - Then: `result.is_valid == true` 且 `result.errors` 为空

- **AC-02**: 缺少必填字段
  - Given: JSON 缺少 schema 定义的必填字段
  - When: validate 执行
  - Then: `is_valid == false`，errors 包含字段名

- **AC-03**: 类型不匹配
  - Given: 字段类型与 schema 不匹配
  - When: validate 执行
  - Then: `is_valid == false`，errors 包含类型描述

- **AC-04**: 首次加载验证失败
  - Given: preload 域 JSON 验证失败
  - When: DataManager._ready() 加载该域
  - Then: 域缓存为空 Dictionary + ERROR 日志，DataManager 仍 READY

- **AC-05**: 热重载验证失败
  - Given: READY 状态，域有有效缓存
  - When: 文件修改为验证失败内容
  - Then: 缓存保持旧数据 + ERROR 日志

- **AC-06**: Schema 文件不存在
  - Given: 域 JSON 存在但 .schema.json 不存在
  - When: 加载该域
  - Then: WARNING 日志，数据正常加载

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/data/story_002_schema_validator_test.gd` — must exist and pass
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003, 004, 006

---

## Completion Notes

**Completed**: 2026-06-21
**Criteria**: 6/6 passing
**Deviations**: None
**Test Evidence**: Logic — test file at `tests/unit/data/story_002_schema_validator_test.gd` (10 functions)
**Code Review**: APPROVED (LP-CODE-REVIEW + QL-TEST-COVERAGE)
