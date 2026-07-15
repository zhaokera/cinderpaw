# Story 161: Skill Tree Long Tail T1-B Damage Choice

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

Story149 delivered Long Tail T1-A as a behavior-changing range choice. This
slice adds the approved parallel T1-B passive `长尾刃攻击力+5%`, displayed as
`Honed Tailblade`, and routes it through the existing weapon-conditioned F7
damage path established by Story160.

The node remains a `damage` ADD modifier with `condition.weapon="long_tail"`.
It is applied once to floating `attack_damage` before the final integer floor;
it is not registered as F9 `skill_weapon_bonus` and does not modify
`weapon_base`. A PERFECT first light hit therefore changes from `37.5/37` to
`39.375/39`, which is visible to the player.

## Acceptance Criteria

- [x] `skill_tree` data and schema expose `long_tail_t1b` as a passive T1 node,
  cost 1, no prerequisites, `damage` ADD `0.05`, conditioned on `long_tail`.
- [x] The HUD order places Honed Tailblade at Node 4/6 after Long Tail T1-A;
  it can be selected and learned through the real runtime button.
- [x] Learning spends exactly 1 SP, sets `has_skill("long_tail_t1b")`, exposes
  `get_stat_bonus("damage") == 0.05`, and disables the learned button.
- [x] A real Long Tail PERFECT first light hit traverses Player, Collision,
  Combat, DamageCalculator and Enemy HP, changing final damage from `37` to
  `39`; the damage-number presentation reports `39`.
- [x] Cat Claw remains at `25` and receives no Story161 modifier.
- [x] Focused GdUnit, bounded related regression, JSON validation and one clean
  Godot MCP 3.0.2 runtime verify the menu, purchase, collision damage,
  non-empty screenshots and clean logs.

## Out Of Scope

- Fish Bone or Electro Bell T1-B, Long Tail T2-T5, respec economy, mentor NPC
  or final radial skill-tree presentation.
- Reworking F9 weapon-base propagation, changing global damage rounding, or
  resolving the historical Long Tail `weapon_base` documentation/data
  difference.
- Range, multi-target, hit-limit or Long Tail T1-A behavior changes.
- New bitmap, audio or animation assets. Existing generated Long Tail attack
  arc, Cinderpaw, enemy, environment and HUD assets are reused, so image
  generation is not needed for this numeric passive.

## Implementation Notes

- The implementation is data/schema only because Story160 already owns the
  shared runtime consumer and final-floor damage behavior.
- `SkillTreeManager.get_stat_bonus()` remains the aggregate query surface;
  attacks consume `get_modifiers()` so the weapon condition cannot leak.
- The F7 damage cap remains `0.25`. This node contributes `0.05` exactly once
  and never enters the F9 base-damage track.
- Existing save snapshots are skill-ID driven and this slice does not alter the
  persistence format or path.

## Test Evidence

- Intentional RED: `reports/report_1680/results.xml`, `1` case with the expected
  failure on the missing `long_tail_t1b` definition.
- Focused GREEN: `reports/report_1681/results.xml`, `1/1` passed with zero
  failures, skips, flaky tests or orphans.
- Intermediate `reports/report_1682/results.xml` exposed nine stale fixed-index
  assertions in Fish Bone/Electro Bell menu-order tests; no production failure
  was found and the assertions were updated for the approved new node.
- Bounded related GREEN: `reports/report_1683/results.xml`, `22/22` passed
  across Story161, Story160, Long Tail/Fish Bone/Electro Bell T1-A,
  DamageCalculator modifiers and the Main player-hit chain.
- `jq empty data/skill_tree.json` and
  `jq empty data/schemas/skill_tree.schema.json` both passed.
- Godot MCP evidence:
  `production/qa/evidence/skill-tree-long-tail-t1b-damage-choice-2026-07-14.md`
  and
  `production/qa/evidence/skill-tree-long-tail-t1b-damage-choice-mcp-run1.json`.
- No full suite was run; the bounded slice used the project verification
  budget and did not repeat an equivalent focused pass after documentation.

**Status**: [x] Complete.
