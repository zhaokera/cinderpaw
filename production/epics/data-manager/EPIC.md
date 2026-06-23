# Epic: Data/Balance Infrastructure

> **Layer**: Foundation
> **GDD**: design/gdd/data-balance.md
> **Architecture Module**: DataManager
> **Status**: Complete
> **Stories**: 6 stories created

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | ManifestLoader + 4 状态机 + 重试 | Logic | Complete | ADR-0001, ADR-0003 |
| 002 | SchemaValidator + 三级失败处理 | Logic | Complete | ADR-0003 |
| 003 | DomainCache + 核心查询 + 懒加载 | Logic | Complete | ADR-0003, ADR-0001 |
| 004 | HotReloader 热重载机制 | Logic | Complete | ADR-0003 |
| 005 | TuningKnobRegistry 旋钮管理 | Logic | Complete | ADR-0003 |
| 006 | VersionMigrator 版本迁移 | Logic | Complete | ADR-0003 |

## Overview

实现 DataManager Autoload 的完整内部架构：JSON 域数据加载管道、Schema 验证（3 级失败处理）、热重载机制（1 秒轮询，Debug 构建）、TuningKnobRegistry 集中旋钮管理、数据版本控制（MAJOR.MINOR + 链式迁移）。这是所有其他系统的数据源——每个 Core/Feature/Presentation 系统都通过 DataManager 读取配置和平衡数据。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Autoload 架构 | DataManager 为 Autoload #1，最先初始化 | LOW |
| ADR-0003: 数据管理架构 | JSON 源格式 + SchemaValidator + HotReloader + TuningKnobRegistry | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-data-001 | DataManager Autoload 单例，4 状态机 | ADR-0001, ADR-0003 ✅ |
| TR-data-002 | JSON 为源格式，Resource 桥接，标准目录 | ADR-0003 ✅ |
| TR-data-003 | 热重载（1 秒轮询，Debug 构建） | ADR-0003 ✅ |
| TR-data-004 | Schema 验证，三级失败处理 | ADR-0003 ✅ |
| TR-data-005 | TuningKnobRegistry 集中管理 | ADR-0003 ✅ |
| TR-data-006 | 数据版本 MAJOR.MINOR + 链式迁移 | ADR-0003 ✅ |
| TR-data-007 | 标准接口契约（_ready/get_entry/changed） | ADR-0003 ✅ |
| TR-data-008 | 调试面板（F12） | ADR-0003 ⚠️ 推迟到 Polish |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`
- All acceptance criteria from `design/gdd/data-balance.md` are verified
- All Logic stories have passing test files in `tests/unit/data/`
- DataManager 可以成功加载 sample JSON 域数据并通过 SchemaValidator
- TuningKnobRegistry 可以注册、查询和修改旋钮
- HotReloader 在 Debug 构建中检测到文件变更并触发 on_domain_changed

## Next Step

Run `/smoke-check sprint` before promoting Data/Balance Infrastructure beyond local implementation evidence.
