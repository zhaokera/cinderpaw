# Cross-GDD Review Report

**Date**: 2026-06-19
**GDDs Reviewed**: 22 system GDDs + game-concept.md
**Review Mode**: Full (Consistency + Design Theory + Scenario Walkthrough)
**Agents**: game-designer (consistency), creative-director (design theory)

---

## Consistency Issues

### Blocking (must resolve before architecture begins)

#### 🔴 C-1: damage-calculation.md — Internal Rule vs. Formula vs. AC Value Mismatch

**GDDs**: damage-calculation.md (internal), skill-tree.md, boss-config.md

| Element | Rule 2/4 | Formula F5/F7 | AC | Verification Table |
|---------|:---:|:---:|:---:|:---:|
| PERFECT暴击 | **2.0x** | **2.5** | **2.0** | **2.5** |
| PERFECT弹反 | **3.0x** | **4.0** | **3.0** | **4.0** |

Resolution: Unify Rules and ACs to Formulas values (2.5/4.0). Verification table and boss-config already use formula values.

#### 🔴 C-2: Heartbeat Sound Contradiction

**GDDs**: health-death.md, audio-system.md, hud-ui.md

- health-death Rule 7: "不添加心跳音"（猫科镇定）
- health-death UI Requirements: "HP<25%时HP条脉动+心跳音"
- audio-system Rule 2: "sfx_low_hp心跳音"
- hud-ui: "心跳音（频率随HP加快）"

Resolution: Design decision needed. Rule 7 aligns with 猫科镇定 fantasy — recommend removing heartbeat from UI Reqs, audio-system, hud-ui.

#### 🔴 C-3: charm-equipment.md Rule 4 vs. skill-tree F8

**GDDs**: charm-equipment.md, skill-tree.md

charm-equipment Rule 4: `final = base × (1 + charm + status)` — additive, no skill_bonus, can exceed 0.75.
skill-tree F8: `min(0.75, 1-(1-skill)(1-charm))` — multiplicative diminishing.

Resolution: Rewrite charm-equipment Rule 4 to reference skill-tree F8.

#### 🔴 C-4: completion_weight_* Knob Ownership Conflict

**GDDs**: exploration-ability-gating.md, map-system.md

Both define identical completion_weight_hub/normal/boss values. exploration-gating owns the formula.

Resolution: map-system.md should remove these knobs and reference exploration-gating.

#### 🔴 C-5: damage-calculation AC Values Wrong (Same Root as C-1)

3 ACs use Rule values (2.0x/3.0x) instead of Formula values (2.5/4.0).

Resolution: Fix with C-1.

### Warnings

⚠️ **W-1**: save-system.md Rule 2 data structure missing skill_tree_state and charm_state fields
⚠️ **W-2**: weapon-styles.md "闪避后暴击率+50%" has no crit_rate mechanism in damage-calculation (uses timing windows, not probability)
⚠️ **W-3**: damage-calculation.md F1 missing F9 override note (flagged ⏳ in skill-tree cross-GDD sync)
⚠️ **W-4**: hud-ui.md 小地图 attributed to "场景管理" — should be "地图系统"
⚠️ **W-5**: damage_number_duration knob in both combat-presentation and hud-ui
⚠️ **W-6**: skill_damage_cap listed in damage-calculation Tuning Knobs but owned by skill-tree
⚠️ **W-7**: 17 missing bidirectional dependency references across GDDs (4 high-impact)
⚠️ **W-8**: health-death AC doesn't verify heartbeat absence per Rule 7

---

## Game Design Issues

### Blocking

#### 🔴 D-1: Gear Coin Economy Undefined

Referenced in: boss-config (50/Boss), skill-tree (respec 30-100), weapon-styles (upgrade at NPC), charm-equipment (merchant purchases).
No GDD defines: total income, drop rates, upgrade costs, charm prices, late-game sinks.

Recommendation: Author economy-currency.md GDD or expand data-balance.md.

#### 🔴 D-2: Boss Phase Transition Race Condition

boss-config: "当前攻击完成后转换（不中断）"
health-death: emits `on_boss_phase_change` immediately at HP threshold.
No buffering mechanism defined — INVULNERABLE may activate mid-attack animation.

Recommendation: boss-config should specify "transition begins at next IDLE state, not mid-attack."

### Warnings

⚠️ **D-3**: Pillar 4 (Cute/Dangerous Contrast) underrepresented — no system GDD enforces "cute" visual anchors in combat feedback
⚠️ **D-4**: PERFECT Parry as gravity well — 4.0× highest multiplier + highest cat energy gain creates parry-or-nothing incentive
⚠️ **D-5**: Fishbone Greatsword burst dominance — highest base × highest combo × highest ultimate, "slow" penalty mitigated by i-frames
⚠️ **D-6**: Mid-game power spike — Boss defeat grants ability + SP + coins + possible charm simultaneously
⚠️ **D-7**: Charm variety low — 8 charms / 3 slots = 56 combinations (Hollow Knight: 45 charms / 3-11 slots)
⚠️ **D-8**: Double auto-save trigger — Boss defeat + ability unlock both trigger auto-save

---

## Cross-System Scenario Walkthrough

**Scenarios walked**: 5

| # | Scenario | Blockers | Warnings |
|---|---------|:---:|:---:|
| 1 | First Boss Encounter (Rat King) | D-2 (phase transition race) | — |
| 2 | Perfect Parry → Special Move Chain | C-1 (damage-calc values) | — |
| 3 | Death → Learning → Retry Loop | — | cat energy clear not explicit |
| 4 | New Ability → Previously Blocked Area | — | D-8 (double save) |
| 5 | Skill Tree Investment → Combat Validation | — | modifier+status stacking untested |

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| damage-calculation.md | C-1/C-5: Internal contradictions | Consistency | Blocking |
| charm-equipment.md | C-3: Rule 4 formula | Consistency | Blocking |
| health-death.md | C-2: Heartbeat contradiction | Consistency | Blocking |
| audio-system.md | C-2: Heartbeat reference | Consistency | Blocking |
| hud-ui.md | C-2/W-4: Heartbeat + minimap ref | Consistency | Warning |
| map-system.md | C-4: Knob ownership | Consistency | Blocking |
| boss-config.md | D-2: Phase transition buffer | Design | Blocking |
| weapon-styles.md | W-2: Crit rate mechanism gap | Consistency | Warning |
| save-system.md | W-1: Missing data fields | Consistency | Warning |

---

## Verdict: CONCERNS

**5 consistency 🔴 + 2 design 🔴 = 7 blocking items.**

### Critical Path (must fix, ~1 hour):
1. damage-calculation.md — unify Rules/ACs to Formulas (30 min)
2. charm-equipment.md — rewrite Rule 4 to reference F8 (15 min)
3. boss-config.md — add phase transition buffer spec (15 min)

### Requires New GDD (2-3 hours):
4. economy-currency.md — define complete gear coin economy

### Design Warnings (address before Tier 2):
5. Pillar 4 visual enforcement in combat/presentation GDDs
6. Charm roster expansion (8 → 15-20)
7. Boss reward decoupling for smoother progression curve

### Positive Notes:
- Combat pipeline (feline-combat → damage-calc → combat-presentation → input) is exceptional
- Skill-first commitment validated by verification table (2.0× peak advantage)
- Cat identity deeply embedded across all systems
- Anti-pillar compliance strong across all 22 GDDs
- Player fantasy coherence excellent — all systems orbit "skilled feline warrior"
- entities.yaml well-maintained with 8 current entries
