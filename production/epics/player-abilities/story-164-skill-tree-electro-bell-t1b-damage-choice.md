# Story 164: Skill Tree Electro Bell T1-B Damage Choice

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / UI / Damage
> **Type**: Integration + Gameplay Runtime + UI + Logic
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/skill-tree.md`, `design/gdd/damage-calculation.md`,
`design/gdd/weapon-styles.md`

**Requirements**: `TR-skill-005`, `TR-skill-006`

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0003
Data management; ADR-0005 Combat state machine; ADR-0009 Skill Tree Modifier
System; ADR-0011 UI focus management; ADR-0016 Weapon styles; ADR-0021 Save
system.

Story151 delivered Electro Bell T1-A as the behavior-changing Pulse Touch
choice. This slice adds its approved parallel 1 SP passive `铃铛攻击力+5%`,
displayed as `Honed Bell`, and closes the four-weapon T1-B set through the
weapon-conditioned F7 damage path established by Story160.

The node applies once to floating attack damage before the final integer floor
and never enters F9 `skill_weapon_bonus`. A real PERFECT first light hit changes
from `30.0/30` to `31.5/31` while the other weapons remain unchanged.

## Acceptance Criteria

- [x] `skill_tree` data and schema expose `electro_bell_t1b` as a passive T1
  node, cost 1, no prerequisites, `damage` ADD `0.05`, conditioned on
  `electro_bell`.
- [x] The HUD places Honed Bell at Node 8/8 after Pulse Touch; the real unlock
  button spends exactly 1 SP, marks it learned once and disables itself.
- [x] The unlock survives save snapshot restore and exposes
  `get_stat_bonus("damage") == 0.05`.
- [x] A real Electro Bell PERFECT first light hit traverses Player, Collision,
  Combat, DamageCalculator and Enemy HP, changing final damage `30 -> 31` and
  showing damage number `31`.
- [x] Cat Claw receives no Story164 damage modifier.
- [x] Focused GdUnit, bounded related regression, JSON validation and one clean
  Godot MCP 3.0.2 runtime verify the purchase, real hit, screenshots and logs.

## Out Of Scope

- Electro Bell T2-T5, EMP special behavior, respec economy, mentor NPC or final
  radial skill-tree presentation.
- Reworking F9 weapon-base propagation, damage rounding or the existing Pulse
  Touch slow envelope.
- New bitmap, audio or animation assets. Existing generated Electro Bell arc,
  Cinderpaw, enemy, environment and HUD assets are reused.

## Implementation Notes

- The implementation is data/schema only because Story160 already owns the
  shared runtime consumer and final-floor damage behavior.
- `SkillTreeManager.get_stat_bonus()` remains the aggregate query surface;
  attacks consume `get_modifiers()` so the weapon condition cannot leak.
- Existing skill-ID save snapshots need no persistence-format change.

## Test Evidence

- Intentional RED: `reports/report_1694/results.xml`, `1` case with the expected
  failure on the missing `electro_bell_t1b` definition.
- Focused GREEN: `reports/report_1696/results.xml`, `1/1` passed.
- Bounded related GREEN: `reports/report_1697/results.xml`, `13/13` passed
  across all four T1-B choices, Electro Bell T1-A and DamageCalculator special
  modifiers.
- Both skill-tree JSON files parse with `jq empty`.
- Godot MCP evidence:
  `production/qa/evidence/skill-tree-electro-bell-t1b-damage-choice-2026-07-14.md`
  and
  `production/qa/evidence/skill-tree-electro-bell-t1b-damage-choice-mcp-run1.json`.
- No full suite or redundant post-documentation focused run was used.

**Status**: [x] Complete.
