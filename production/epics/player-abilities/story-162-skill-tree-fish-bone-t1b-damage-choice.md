# Story 162: Skill Tree Fish Bone T1-B Damage Choice

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

Story150 delivered Fish Bone T1-A as a behavior-changing heavy-shock choice.
This slice adds the approved parallel T1-B passive `鱼骨大剑攻击力+8%`, displayed
as `Honed Fishbone`, and routes it through the existing weapon-conditioned F7
damage path established by Story160.

The node remains a `damage` ADD modifier with `condition.weapon="fish_bone"`.
It is applied once to floating `attack_damage` before the final integer floor;
it is not registered as F9 `skill_weapon_bonus` and does not modify
`weapon_base`. A PERFECT first light hit therefore changes from `100` to `108`.
Applying the bonus incorrectly through F9 would produce `107`, so the observed
result also protects the formula boundary.

## Acceptance Criteria

- [x] `skill_tree` data and schema expose `fish_bone_t1b` as a passive T1 node,
  cost 1, no prerequisites, `damage` ADD `0.08`, conditioned on `fish_bone`.
- [x] The HUD order places Honed Fishbone at Node 6/7 after Fish Bone T1-A; it
  can be selected and learned through the real runtime button.
- [x] Learning spends exactly 1 SP, sets `has_skill("fish_bone_t1b")`, exposes
  `get_stat_bonus("damage") == 0.08`, and disables the learned button.
- [x] A real Fish Bone PERFECT first light hit traverses Player, Collision,
  Combat, DamageCalculator and Enemy HP, changing final damage from `100` to
  `108`; the damage-number presentation reports `108`.
- [x] Cat Claw remains at `25` and receives no Story162 modifier.
- [x] Focused GdUnit, bounded related regression, JSON validation and one clean
  Godot MCP 3.0.2 runtime verify the menu, purchase, collision damage,
  non-empty screenshots and clean logs.

## Out Of Scope

- Electro Bell T1-B, Fish Bone T2-T5, respec economy, mentor NPC or final radial
  skill-tree presentation.
- Reworking F9 weapon-base propagation, changing global damage rounding, or
  resolving the historical Fish Bone `weapon_base` documentation/data
  difference.
- Heavy shock, multi-target, hit-limit or Fish Bone T1-A behavior changes.
- New bitmap, audio or animation assets. Existing generated Fish Bone wave,
  Cinderpaw, enemy, environment and HUD assets are reused, so image generation
  is not needed for this numeric passive.

## Implementation Notes

- The implementation is data/schema only because Story160 already owns the
  shared runtime consumer and final-floor damage behavior.
- `SkillTreeManager.get_stat_bonus()` remains the aggregate query surface;
  attacks consume `get_modifiers()` so the weapon condition cannot leak.
- The F7 damage cap remains `0.25`. This node contributes `0.08` exactly once
  and never enters the F9 base-damage track.
- Existing save snapshots are skill-ID driven and this slice does not alter the
  persistence format or path.

## Test Evidence

- Intentional RED: `reports/report_1684/results.xml`, `1` case with the expected
  failure on the missing `fish_bone_t1b` definition.
- Focused GREEN: `reports/report_1685/results.xml`, `1/1` passed with zero
  failures, skips, flaky tests or orphans.
- Bounded related GREEN: `reports/report_1686/results.xml`, `16/16` passed
  across Story162, Story160, Story161, Fish Bone/Electro Bell T1-A and
  DamageCalculator special modifiers.
- `jq empty data/skill_tree.json` and
  `jq empty data/schemas/skill_tree.schema.json` both passed.
- Godot MCP evidence:
  `production/qa/evidence/skill-tree-fish-bone-t1b-damage-choice-2026-07-14.md`
  and
  `production/qa/evidence/skill-tree-fish-bone-t1b-damage-choice-mcp-run1.json`.
- No full suite was run; the bounded slice used the project verification
  budget and did not repeat an equivalent focused pass after documentation.

**Status**: [x] Complete.
