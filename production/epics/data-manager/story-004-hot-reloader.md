# Story 004: HotReloader 热重载机制

> **Epic**: data-manager
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 4-5 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/data-balance.md`
**Requirement**: `TR-data-003`

**ADR Governing Implementation**: ADR-0003: 数据管理架构
**ADR Decision Summary**: HotReloader 1 秒轮询文件修改时间，仅 Debug 构建。验证通过后原子替换缓存 + 信号传播。多文件同周期变更合并为一次重载。

**Engine**: Godot 4.7 | **Risk**: LOW

**Control Manifest Rules (Foundation layer)**:
- Required: 热重载 1 秒轮询（Debug only）；验证通过才替换缓存
- Guardrail: 轮询开销 <0.1ms/frame

---

## Acceptance Criteria

- [x] AC-01: Debug 构建文件变更 → 重载 + on_domain_changed 信号发射 + get_entry() 返回新数据
- [x] AC-02: 热重载验证失败 → 信号不发射，保留旧缓存 + ERROR 日志
- [x] AC-03: Debug 构建 Timer 间隔 1.0 秒且正在运行
- [x] AC-04: Release 构建 Timer 未创建/未启动，零开销
- [x] AC-05: 同一轮询周期多文件变更 → 合并重载，每个域各发射一次信号但在同帧完成
- [x] AC-06: 域文件被删除 → 该域进入 FALLBACK 状态（默认值），其他域不受影响

---

## Implementation Notes

1. **Timer**: `Timer(1.0)` 仅在 `OS.is_debug_build()` 时创建和启动
2. **文件变更检测**: `FileAccess.get_modified_time()` 比较上次记录时间
3. **重载流程**: 重读文件 → SchemaValidator 验证 → 通过→原子替换缓存+发射信号 / 失败→保留旧缓存
4. **多文件合并**: 同一轮询周期内检测到的所有变更，批量处理后统一替换
5. **FALLBACK 状态**: 文件删除后，域缓存替换为空 Dictionary，标记为 FALLBACK
6. **信号**: `signal on_domain_changed(domain_name: StringName)` — 每个变更域各发射一次

---

## Out of Scope

- [Story 002]: SchemaValidator 验证逻辑
- [Story 005]: TuningKnobRegistry 旋钮热重载

---

## QA Test Cases

- **AC-01**: 文件变更检测 + 信号
  - Given: DataManager READY（Debug），域已加载
  - When: 修改 JSON 文件并等待 >1 秒
  - Then: `on_domain_changed` 发射，`get_entry()` 返回新数据

- **AC-02**: 验证失败保留旧缓存
  - Given: 域有有效缓存
  - When: 文件修改为验证失败内容
  - Then: 信号不发射，`get_entry()` 返回旧数据

- **AC-03**: Debug 轮询间隔
  - Given: `OS.is_debug_build() == true`
  - When: HotReloader 初始化
  - Then: Timer 间隔 1.0 秒且正在运行

- **AC-04**: Release 零开销
  - Given: `OS.is_debug_build() == false`
  - When: HotReloader 初始化
  - Then: Timer 未创建或未启动

- **AC-05**: 多文件合并
  - Given: READY（Debug）
  - When: 同一轮询周期内 2 个文件变更
  - Then: 2 次信号发射但在同帧完成

- **AC-06**: 域文件删除
  - Given: 域文件存在
  - When: 文件删除，下一轮询检测到
  - Then: 域进入 FALLBACK，其他域不受影响

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/data/story_004_hot_reloader_test.gd` — must exist and pass
**Status**: [x] Created (6 test functions covering AC-01~AC-06)

---

## Dependencies

- Depends on: Story 001, Story 002, Story 003
- Unlocks: None

---

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 passing
**Deviations**: None
**Test Evidence**: Logic — test file at `tests/unit/data/story_004_hot_reloader_test.gd` (6 functions covering AC-01~AC-06)
**Code Review**: Complete — local review against ADR-0003, control manifest, GDD TR-data-003, and passing GdUnit evidence. Specialist subagent gates were not spawned because current tool policy requires explicit user request for subagents.
