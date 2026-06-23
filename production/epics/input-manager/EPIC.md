# Epic: Input System

> **Layer**: Foundation
> **GDD**: design/gdd/input.md
> **Architecture Module**: InputManager
> **Status**: Complete
> **Stories**: 7 stories

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | InputManager Action Abstraction + Query API | Integration | Complete | ADR-0001, ADR-0003 |
| 002 | Direct Dispatch + FSM Signals | Logic | Complete | ADR-0001, ADR-0002 |
| 003 | Buffer Queue + Pre-input | Logic | Complete | ADR-0001, ADR-0003 |
| 004 | Combo Chain + Conflict Resolution | Logic | Complete | ADR-0001, ADR-0002 |
| 005 | Coyote Time + Jump Buffer | Logic | Complete | ADR-0001, ADR-0003 |
| 006 | Device Detection + Debounced Switching | Integration | Complete | ADR-0001, ADR-0002 |
| 007 | Key Rebinding Persistence | Config/Data | Deferred | N/A — Polish |

## Overview

实现 InputManager Autoload 的完整输入系统：统一输入抽象层（12 核心动作归一化）、输入缓冲队列（150ms 窗口 / 3 深度 / 50ms 预输入）、连招链管理、Coyote Time + Jump Buffer、平台检测与动态切换（500ms 防抖）、输入冲突解决（优先级互斥）、三状态 FSM（DIRECT/BUFFERING/TRANSITIONING）。InputManager 为 Autoload #2，依赖 DataManager 的 TuningKnobRegistry 注册 8 个旋钮。

**Note**: Key rebinding (TR-input-010) 推迟到 Feature/Polish 阶段（PR-EPIC 建议）。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Autoload 架构 | InputManager 为 Autoload #2 | LOW |
| ADR-0002: 信号通信 | action_triggered / device_changed 信号定义 | LOW |
| ADR-0003: 数据管理 | 8 个旋钮注册到 TuningKnobRegistry | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-input-001 | 统一输入抽象层，12 核心动作 | ADR-0001 ✅ |
| TR-input-002 | 输入缓冲 150ms/3 深度/50ms 预输入 | ADR-0001 ✅ |
| TR-input-003 | 连招链管理 combo_counter | ADR-0001 ✅ |
| TR-input-004 | Coyote Time 5-8 帧 + Jump Buffer | ADR-0001, ADR-0003 ✅ |
| TR-input-005 | 平台检测 500ms 防抖 | ADR-0001, ADR-0002 ✅ |
| TR-input-006 | 输入冲突解决（优先级互斥） | ADR-0001 ✅ |
| TR-input-007 | 三状态 FSM (DIRECT/BUFFERING/TRANSITIONING) | — ⚠️ 实现细节 |
| TR-input-008 | action_triggered 信号 + metadata | ADR-0001, ADR-0002 ✅ |
| TR-input-009 | device_changed 信号 | ADR-0001, ADR-0002 ✅ |
| TR-input-010 | 键位映射存储 + 自定义 | — ⚠️ 推迟到 Polish |
| TR-input-011 | 8 个旋钮注册 TuningKnobRegistry | ADR-0003 ✅ |
| TR-input-012 | 查询接口（is_action_pressed/strength/duration） | ADR-0001 ✅ |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`
- All acceptance criteria from `design/gdd/input.md` are verified
- All Logic stories have passing test files in `tests/unit/input/`
- InputManager 可以正确缓冲和分发输入事件
- 连招链和 Coyote Time 在集成测试中验证
- device_changed 信号在切换输入设备时正确发射

## Next Step

Input System Foundation scope complete. Story 007 key rebinding remains deferred to Feature/Polish; next recommended implementation target is Health/Death or Feline Combat integration.
