# Architecture Review Report

> **Date**: 2026-06-21
> **Engine**: Godot 4.6.3 (historical snapshot; current project baseline is Godot 4.7)
> **GDDs Reviewed**: 24
> **ADRs Reviewed**: 7
> **Technical Requirements Extracted**: 185

---

## Traceability Summary

| Layer | Total TRs | ✅ Covered | ⚠️ Partial | ❌ Gaps |
|-------|:---------:|:----------:|:----------:|:-------:|
| Foundation | 40 | 28 (70%) | 10 (25%) | 2 (5%) |
| Core | 78 | 35 (45%) | 20 (26%) | 23 (29%) |
| Feature | 52 | 2 (4%) | 8 (15%) | 42 (81%) |
| Presentation | 30 | 0 (0%) | 5 (17%) | 25 (83%) |
| **Total** | **185** | **65 (35%)** | **43 (23%)** | **77 (42%)** |

Foundation layer has **zero blocking gaps** — implementation can begin.

---

## Foundation Layer Coverage

| System | TRs | ADR Coverage | Status |
|--------|-----|-------------|--------|
| Data/Balance (8 TRs) | TR-data-001~008 | ADR-0001 + ADR-0003 | ✅ Full |
| Input (12 TRs) | TR-input-001~012 | ADR-0001 (InputManager Autoload) | ⚠️ Interface covered; buffer FSM details deferred to implementation |
| Damage Calc (11 TRs) | TR-damage-001~011 | ADR-0001 (static class) + ADR-0002 (DamageResult) | ⚠️ Core covered; F9/F10 modifiers depend on Skill Tree ADR |
| Collision (9 TRs) | TR-collision-001~009 | ADR-0004 (complete architecture) | ✅ Full |

---

## Coverage Gaps

### Core Layer (non-blocking — can be ADR extensions or new P2 ADRs)

| Gap | System | TRs | Suggested Resolution |
|-----|--------|:---:|---|
| ❌ No standalone ADR | weapon-styles.md | 7 | Extend ADR-0005 (CombatComponent) or write lightweight ADR |
| ❌ No standalone ADR | status-effects.md | 6 | Write P2 ADR (independent component) |
| ❌ No standalone ADR | player-abilities.md | 6 | Write P2 ADR (independent component) |
| ❌ No standalone ADR | boss-config.md | 7 | Extend ADR-0006 (AIComponent) + HealthComponent |
| ⚠️ No GDD written | Player Movement (#27) | — | Write GDD before implementation |

### Feature Layer (P2 ADRs planned — non-blocking)

| Planned ADR | Covers | TRs |
|-------------|--------|:---:|
| P2-#8 Save Serialization | save-system.md | 7 |
| P2-#9 Skill Tree Modifier | skill-tree.md | 12 |
| ❌ Not planned | charm-equipment.md | 6 |
| ❌ Not planned | death-respawn.md | 7 |
| ❌ Not planned | exploration-ability-gating.md | 6 |
| ❌ Not planned | npc-dialogue.md | 5 |
| ❌ Not planned | map-system.md | 5 |

### Presentation Layer (P2 ADRs planned — non-blocking)

| Planned ADR | Covers | TRs |
|-------------|--------|:---:|
| P2-#10 Audio System | audio-system.md | 9 |
| P2-#11 UI Focus Management ⚠️HIGH | hud-ui.md | 8 |
| ❌ Not planned | combat-presentation.md | 9 |

---

## Cross-ADR Conflicts

**None found.** ✅

- Data ownership: Each ADR clearly declares data owner (HealthComponent owns HP, CombatComponent owns combat state)
- Signal contracts: ADR-0002 payload classes match all ADR usage
- Performance budgets: No overcommitment (ADR-0004 <3ms collision, total budget 16.6ms)
- Dependencies: Valid DAG, no cycles

---

## ADR Dependency Order (topologically sorted)

```
Foundation (no dependencies):
  1. ADR-0001: Autoload 架构与初始化顺序

Depends on ADR-0001:
  2. ADR-0002: 事件/信号通信模式
  3. ADR-0003: 数据管理架构
  4. ADR-0007: 场景管理架构

Depends on ADR-0001 + ADR-0002:
  5. ADR-0004: 碰撞检测架构

Depends on ADR-0001 + ADR-0002 + ADR-0004:
  6. ADR-0005: 战斗状态机架构

Depends on ADR-0001 + ADR-0002 + ADR-0004 + ADR-0005:
  7. ADR-0006: AI 行为系统架构
```

No unresolved dependencies. No cycles.

---

## Engine Compatibility

| Check | Result |
|-------|--------|
| ADRs with Engine Compatibility section | 7/7 ✅ |
| Deprecated API references | 0 ✅ |
| Stale version references | 0 ✅ |
| Post-cutoff API conflicts | 0 ✅ |
| Knowledge Risk level | All LOW ✅ |

**Key notes**:
- UI dual-focus (4.6) correctly deferred to P2 ADR #11 (HIGH risk)
- Jolt Physics 3D (4.6 default) does not affect 2D game
- Required parameters (4.6) reflected in type-safety requirements

**Open Question status**:
- ⚠️ QQ-02 (NavigationAgent2D) resolved by ADR-0006 (decided NOT to use) but architecture.md not updated — **fixed in this review**

---

## GDD Revision Flags

None — all GDD assumptions are consistent with verified engine behaviour.

---

## Architecture Document Coverage

- 28/28 systems mapped to architecture layers ✅
- Orphaned architecture: None
- Missing GDD: Player Movement (#27) — slot reserved, GDD not yet written

---

## Verdict: CONCERNS

Foundation layer fully covered, no blocking conflicts, engine compatible. Feature/Presentation gaps can be addressed incrementally with P2 ADRs.

### Concerns

| # | Concern | Severity | Action |
|---|---------|----------|--------|
| C-1 | 5 Core systems lack standalone ADRs | MEDIUM | Evaluate: extension vs. new ADR |
| C-2 | 5 Feature systems not in planned ADR list | MEDIUM | Add as needed before implementation |
| C-3 | QQ-02 stale in architecture.md | LOW | ✅ Fixed in this review |
| C-4 | Combat Presentation has no ADR | LOW | Add before implementation |

### Recommended Next ADRs

| Priority | Title | Layer |
|----------|-------|-------|
| 1 | UI 焦点管理策略 (4.6 双焦点) | Presentation |
| 2 | 存档序列化模式 | Feature |
| 3 | 技能树 Modifier | Feature |
| 4 | 音频系统架构 | Presentation |
| 5 | 状态效果系统 | Core |
| 6 | 玩家能力系统 | Core |
