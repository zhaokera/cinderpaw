# Story 151: Skill Tree Electro Bell T1-A Pulse Touch

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / UI / Status / Presentation
> **Type**: Integration + Gameplay Runtime + UI + Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/skill-tree.md`, `design/gdd/weapon-styles.md`,
`design/gdd/status-effects.md`

**Requirements**: `TR-skill-001`, `TR-skill-005`, `TR-status-002`,
`TR-status-003`, `TR-weapon-006`

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0003
Data management; ADR-0004 Collision architecture; ADR-0005 Combat state
machine; ADR-0009 Skill Tree Modifier System; ADR-0011 UI focus management;
ADR-0016 Weapon styles; ADR-0017 Status effects; ADR-0021 Save system.

Story150 completed the first three weapon T1-A choices. This slice adds the
approved Electro Bell node `脉冲触击` (`Pulse Touch`) as the fourth choice. The
original T1-A shorthand conflicts with the existing weapon/status baseline:
all Electro Bell hits already apply one non-stacking `30% / 2s` slow. Replacing
that baseline with `15% / 0.5s` would be a downgrade, while creating another
slow would violate the refresh-only rule. The binding contract therefore uses
one slow instance with a front-loaded intensity envelope: light attack 1 adds
15 percentage points for `0.5s` (`45%` total), then the same instance returns to
the `30%` baseline until its total `2s` duration expires.

## Acceptance Criteria

- [x] `skill_tree` data and schema expose `electro_bell_t1a` as a 1 SP modifier
  targeting `light_attack_1`, stat `slow_percentage`, operation `ADD`, value
  `0.15`, pulse duration `0.5`, with an `electro_bell` weapon condition.
- [x] The Skill Tree HUD preserves Cat Claw -> Long Tail -> Fish Bone -> Electro
  Bell order, selects Pulse Touch fourth, purchases it once for exactly 1 SP,
  and restores its learned state from a save snapshot.
- [x] Without the skill, every valid Electro Bell hit keeps the existing single
  `slow` instance at `30% / 2s`; Story008 weapon behavior is not weakened.
- [x] With the skill, only Electro Bell light attack 1 carries the pulse profile.
  A confirmed hit produces one slow instance at `45%` for `0.5s`, then `30%`
  for the remaining `1.5s`, then expires.
- [x] A repeated light attack 1 refreshes both the `2s` baseline and `0.5s`
  pulse. Other Electro Bell stages refresh the baseline without duplicating the
  effect or cancelling a pulse that is still active.
- [x] Hit metadata reports baseline, pulse bonus, pulse total, durations,
  movement modifiers and whether the pulse was applied. Missing status APIs
  remain a clean skipped result.
- [x] Pulse contact reuses the existing generated Electro Bell arc texture as a
  tighter, brighter hit-position burst. Locked and later-stage hits do not spawn
  this skill-only burst; no new bitmap or audio asset is required.
- [x] Focused GdUnit, bounded related regression, SchemaValidator, target smoke
  and Godot MCP runtime evidence verify purchase, persistence, stage gating,
  exact timing, one-instance refresh, VFX, non-empty capture and clean logs.

## Out of Scope

- Electro Bell T1-B, T2-T5, EMP special behavior, stun/overload, status HUD
  icons, reset economy, mentor NPC and final radial skill-tree presentation.
- A general arbitrary status stacking rewrite, ADR-0017 reconciliation beyond
  the binding GDD refresh-only rule, or new status effect IDs.
- New character frames, bitmap assets, audio files or temporary skill icons.
- Boss5, ending, credits, new narrative or post-game content.

## Implementation Notes

- Keep `slow` as the sole effect ID. Store baseline and optional pulse values on
  the same active effect instance; `get_movement_modifier()` selects the pulse
  value only while its own timer is positive.
- Carry the unlocked modifier through light attack 1 hitbox metadata. Weapon
  and status components consume a profile; DamageCalculator remains unaware of
  status timing.
- Resolve a target's `StatusEffectComponent` through its existing getter when
  available so normal enemies with the component receive the same behavior as
  bosses exposing an `apply_status` proxy.
- Reuse `combat_electro_bell_arc_runtime.png` for the contact burst and record
  the additional Story use in the asset manifest and QA evidence.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/skill_tree_electro_bell_t1a_pulse_touch_test.gd`
- Story008 Electro Bell slow, status catalog/application, Story149/150 and Main
  attack/presentation bounded regression
- `tests/smoke/skill_tree_electro_bell_t1a_pulse_touch_smoke.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/skill-tree-electro-bell-t1a-pulse-touch-2026-07-14.md`

**Evidence captured**:

- Complete RED `reports/report_1588/report_1/results.xml` executed all `3/3`
  cases with fail-fast disabled and captured `7` expected failures before the
  node, pulse profile, refresh semantics and skill-only contact burst existed.
- Focused GREEN `reports/report_1589/report_1/results.xml` passed `3/3` with
  zero errors, failures or orphans.
- Bounded related GREEN `reports/report_1590/report_1/results.xml` passed
  `73/73` across 11 suites covering status application/catalog behavior,
  Story008 Bell slow, Main attack routing, Story149/150 and presentation.
- SchemaValidator regression `reports/report_1591/report_1/results.xml` passed
  `13/13`; console error/warning lines are expected negative-schema fixtures.
- `tests/smoke/skill_tree_electro_bell_t1a_pulse_touch_smoke.gd` exited `0`
  with `skill_tree_electro_bell_t1a_pulse_touch_smoke=passed`, exact
  `45% -> 30%` timing, one effect instance, stage-safe refresh, nine contact
  VFX and persisted unlock state.
- Godot `4.7-stable` with Godot AI MCP plugin/server `2.9.2`, session
  `cinderpaw@d40a`, final run `r10990678-10`, returned `ok=true`: unlocked
  first-stage hit, `0.45` total slow, `0.55` movement modifier, `2.0s` base and
  `0.5s` pulse timers, one effect, nine Bell arcs, three-frame player `attack`
  and enemy `hurt`, target HP `288`, three info-only game rows and zero editor
  rows.
- Non-empty `1278x718` MCP capture retained at
  `reports/visual/cinderpaw-mcp-electro-bell-pulse-touch-20260714.png`; detailed
  acceptance mapping is in
  `production/qa/evidence/skill-tree-electro-bell-t1a-pulse-touch-2026-07-14.md`.

**Status**: [x] Complete.
