# Story 006: VersionMigrator 版本迁移

> **Epic**: data-manager
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 2-3 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/data-balance.md`
**Requirement**: `TR-data-006`

**ADR Governing Implementation**: ADR-0003: 数据管理架构
**ADR Decision Summary**: `_meta.version` MAJOR.MINOR，链式迁移（1.0→1.1→1.2），每步一个迁移函数。MAJOR 不兼容则拒绝加载。

**Engine**: Godot 4.7 | **Risk**: LOW

**Control Manifest Rules (Foundation layer)**:
- Required: 数据版本 MAJOR.MINOR + 链式迁移

---

## Acceptance Criteria

- [x] AC-01: 版本完全兼容 → 数据原样返回，无迁移执行
- [x] AC-02: MINOR 版本低 → 自动执行迁移链（1.0→1.1→1.2），返回目标版本数据
- [x] AC-03: MAJOR 版本不同 → 拒绝加载，返回 null + ERROR 日志，原始数据不修改
- [x] AC-04: 文件 MINOR 高于期望（向后兼容）→ 数据原样返回
- [x] AC-05: 迁移链中间步骤失败 → 回滚到迁移前原始数据 + ERROR 日志
- [x] AC-06: 版本兼容性公式 4 象限边界值测试全部通过

---

## Implementation Notes

1. **版本兼容性公式**: `version_compatible = (file_major == expected_major AND file_minor >= expected_minor)`
2. **迁移链**: `migration_chain: Dictionary[Vector2i, Callable]` — key 为 `[from_major, from_minor]`
3. **回滚策略**: 迁移前 deep copy 原始数据，任何步骤失败→返回原始数据
4. **MAJOR 不兼容**: `file_major != expected_major` → 直接返回 null

---

## Out of Scope

- [Story 003]: DomainCache 数据访问
- [Story 004]: HotReloader 触发迁移

---

## QA Test Cases

- **AC-01**: 完全兼容
  - Given: 文件 version=1.2, 期望=1.2
  - When: `check_and_migrate(data)`
  - Then: 数据原样返回

- **AC-02**: MINOR 迁移链
  - Given: 文件 version=1.0, 期望=1.2, 迁移函数存在
  - When: `check_and_migrate(data)`
  - Then: 依次执行 1.0→1.1, 1.1→1.2, 返回 1.2 数据

- **AC-03**: MAJOR 不兼容
  - Given: 文件 version=2.0, 期望=1.x
  - When: `check_and_migrate(data)`
  - Then: 返回 null + ERROR，原始数据不修改

- **AC-04**: 向后兼容
  - Given: 文件 version=1.3, 期望=1.1
  - When: `check_and_migrate(data)`
  - Then: 数据原样返回

- **AC-05**: 迁移中间失败回滚
  - Given: 1.0→1.1 成功, 1.1→1.2 失败
  - When: `check_and_migrate(data)`
  - Then: 返回原始 1.0 数据 + ERROR

- **AC-06**: 边界值
  - Given: 期望版本=1.2
  - When: 输入 "1.0" / "1.2" / "1.5" / "2.0" / "0.9"
  - Then: compatible/needs_migration 标志正确

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/data/story_006_version_migrator_test.gd` — must exist and pass
**Status**: [x] Created (6 test functions covering AC-01~AC-06)
**Note**: GdUnit4 available; Story 006 test passes 6/6 and full data unit suite passes 43/43 as of 2026-06-23.

---

## Dependencies

- Depends on: Story 001, Story 002
- Unlocks: None (可与 003, 004, 005 并行)

---

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 passing
**Deviations**: None
**Test Evidence**: Logic — test file at `tests/unit/data/story_006_version_migrator_test.gd` (6 functions covering AC-01~AC-06)
**Code Review**: Complete — local review against ADR-0003, control manifest, GDD TR-data-006, and passing GdUnit evidence. Specialist subagent gates were not spawned because current tool policy requires an explicit user request for subagents.
