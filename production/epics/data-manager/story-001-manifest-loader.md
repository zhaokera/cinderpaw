# Story 001: ManifestLoader + 4 状态机 + 重试

> **Epic**: data-manager
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 3-4 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-21

## Context

**GDD**: `design/gdd/data-balance.md`
**Requirement**: `TR-data-001`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0001: Autoload 架构, ADR-0003: 数据管理架构
**ADR Decision Summary**: DataManager 为 Autoload #1，最先初始化。4 状态机（BOOTING→READY/ERROR，READY→RELOADING→READY）。manifest 路径为 `res://data/manifest.json`。

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: FileAccess.store_* 返回 bool (4.4)；@abstract 可用于接口定义 (4.5)

**Control Manifest Rules (Foundation layer)**:
- Required: Foundation 层零游戏逻辑；4 状态机 BOOTING→READY→RELOADING→ERROR
- Forbidden: 禁止在 DataManager 中放置游戏逻辑；禁止超过 5 个 Autoload
- Guardrail: Autoload 初始化 <1 秒；DataManager preload <500ms

---

## Acceptance Criteria

- [ ] AC-01: manifest.json 存在且格式正确 → DataManager 进入 READY 状态，所有 preload=true 域可用
- [ ] AC-02: manifest.json 不存在 → DataManager 进入 ERROR 状态，所有 get_entry() 返回 null
- [ ] AC-03: manifest.json 存在但 JSON 格式损坏 → DataManager 进入 ERROR 状态，控制台输出 ERROR 日志
- [ ] AC-04: BOOTING 状态期间外部系统调用 get_entry() → 返回 null，不抛出异常
- [ ] AC-05: ERROR 状态下调用 retry() → 重新进入 BOOTING→READY 流程（manifest 此时已修复）

---

## Implementation Notes

*Derived from ADR-0001 and ADR-0003:*

1. **脚本路径**: `res://src/foundation/data_manager.gd`
2. **manifest 路径**: `res://data/manifest.json`（硬编码，与 ADR-0003 目录结构一致）
3. **状态枚举**: `enum State { BOOTING, READY, RELOADING, ERROR }`
4. **初始化顺序**: `_ready()` 中：加载 manifest → 验证 → 逐个加载 preload 域 → READY
5. **失败传播**: ERROR 状态不崩溃，其他 Autoload 检查 `DataManager.state` 后优雅降级
6. **retry() 方法**: 从 ERROR 状态重新执行 `_ready()` 的加载管道

---

## Out of Scope

- [Story 002]: SchemaValidator 验证逻辑
- [Story 003]: DomainCache 查询接口
- [Story 004]: HotReloader 文件监控

---

## QA Test Cases

- **AC-01**: manifest 存在且格式正确
  - Given: `res://data/manifest.json` 存在且 JSON 格式正确
  - When: `DataManager._ready()` 执行完毕
  - Then: `DataManager.state == READY` 且所有 preload=true 域已加载到缓存

- **AC-02**: manifest 文件不存在
  - Given: `res://data/manifest.json` 不存在
  - When: `DataManager._ready()` 执行
  - Then: `DataManager.state == ERROR` 且 `get_entry("damage_params", "cat_claw")` 返回 null

- **AC-03**: manifest JSON 格式损坏
  - Given: `res://data/manifest.json` 存在但内容为非法 JSON
  - When: `DataManager._ready()` 执行
  - Then: `DataManager.state == ERROR` 且控制台输出包含 ERROR 级别日志

- **AC-04**: BOOTING 状态请求数据
  - Given: DataManager 处于 BOOTING 状态
  - When: 外部系统调用 `get_entry()`
  - Then: 返回 null，不抛出异常

- **AC-05**: ERROR→BOOTING 手动重试
  - Given: DataManager 处于 ERROR 状态
  - When: 调用 `retry()` 且 manifest 此时已存在且格式正确
  - Then: DataManager 重新进入 BOOTING→READY 流程

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/data/story_001_manifest_test.gd` — must exist and pass
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: Story 002, 003, 004, 005, 006

---

## Completion Notes

**Completed**: 2026-06-21
**Criteria**: 5/5 passing
**Deviations**: Advisory — `_load_preload_domains()` 不检查 `_load_domain()` 返回值（preload 域加载失败时仍进入 READY，符合 ADR-0003 优雅降级原则）。QA Lead 建议确认此设计意图。
**Test Evidence**: Logic — test file at `tests/unit/data/story_001_manifest_test.gd` (6 functions, all pass)
**Code Review**: APPROVED (LP-CODE-REVIEW)
**QA Coverage**: GAPS (advisory — 4 non-blocking test gaps identified for follow-up)
