# Story 005: TuningKnobRegistry 旋钮管理

> **Epic**: data-manager
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 2-3 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/data-balance.md`
**Requirement**: `TR-data-005`

**ADR Governing Implementation**: ADR-0003: 数据管理架构
**ADR Decision Summary**: TuningKnobRegistry 集中管理旋钮。三级值优先级：调试面板运行时 > JSON 文件值 > 注册默认值。`register()` / `get_value()` / `set_value()` 接口。

**Engine**: Godot 4.6.3 | **Risk**: LOW

**Control Manifest Rules (Foundation layer)**:
- Required: TuningKnobRegistry 三级值优先级
- Forbidden: 禁止绕过 TuningKnobRegistry 直接修改游戏值

---

## Acceptance Criteria

- [x] AC-01: 注册旋钮后 get_value() 返回注册的默认值
- [x] AC-02: set_value() 在范围内 → 新值生效 + on_knob_changed 信号发射
- [x] AC-03: set_value() 超过 max → 自动 clamp 到 max，不报错
- [x] AC-04: set_value() 低于 min → 自动 clamp 到 min
- [x] AC-05: 查询未注册旋钮 → 返回传入的 default 参数 + WARNING 日志
- [x] AC-06: JSON 热重载更新旋钮值 → get_value() 返回新值 + on_knob_changed 信号

---

## Implementation Notes

1. **数据结构**: `registered_knobs: Dictionary[StringName, TuningKnobEntry]`
2. **TuningKnobEntry**: `class_name TuningKnobEntry` — id, type, default_value, min_value, max_value, current_value
3. **三级优先级**: `current_value = debug_panel_override ?? json_file_value ?? registered_default`
4. **Clamp**: `set_value()` 内部 `clamped_value = clamp(requested, min, max)`
5. **信号**: `signal on_knob_changed(knob_id: StringName, new_value: Variant)`

---

## Out of Scope

- [Story 004]: HotReloader 文件监控（旋钮 JSON 热重载依赖 HotReloader）

---

## QA Test Cases

- **AC-01**: 注册和获取
  - Given: 旋钮 "input.buffer_window_ms" 已注册，default=150
  - When: `get_value("input.buffer_window_ms", 0)`
  - Then: 返回 150

- **AC-02**: 范围内设置
  - Given: 旋钮 min=80, max=250
  - When: `set_value("input.buffer_window_ms", 180)`
  - Then: get_value 返回 180 + 信号发射

- **AC-03**: 超 max clamp
  - Given: 旋钮 max=250
  - When: `set_value(knob, 999)`
  - Then: get_value 返回 250，无 ERROR

- **AC-04**: 低于 min clamp
  - Given: 旋钮 min=80
  - When: `set_value(knob, 10)`
  - Then: get_value 返回 80

- **AC-05**: 未注册旋钮
  - Given: 旋钮未注册
  - When: `get_value("nonexistent", 42)`
  - Then: 返回 42 + WARNING 日志

- **AC-06**: JSON 热重载更新
  - Given: 旋钮 default=150，JSON 中值=200
  - When: tuning_knobs.json 热重载
  - Then: get_value 返回 200 + 信号发射

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/data/story_005_tuning_knob_test.gd` — must exist and pass
**Status**: [x] Created (6 test functions covering AC-01~AC-06)
**Note**: GdUnit4 available; Story 005 test passes 6/6 and full data unit suite passes 37/37 as of 2026-06-23.

---

## Dependencies

- Depends on: Story 001
- Unlocks: None (可与 003, 004, 006 并行)

---

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 passing
**Deviations**: None
**Test Evidence**: Logic — test file at `tests/unit/data/story_005_tuning_knob_test.gd` (6 functions covering AC-01~AC-06)
**Code Review**: Complete — local review against ADR-0003, control manifest, GDD TR-data-005, and passing GdUnit evidence. Specialist subagent gates were not spawned because current tool policy requires an explicit user request for subagents.
