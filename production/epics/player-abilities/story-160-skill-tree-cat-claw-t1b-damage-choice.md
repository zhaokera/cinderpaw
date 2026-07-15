# Story 160: Skill Tree Cat Claw T1-B Damage Choice

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

Story018 delivered Cat Claw T1-A. This slice adds the parallel 1 SP passive
`猫爪攻击力+5%`, displayed as `Honed Claws`, and carries it through the real
Player -> Collision -> Combat -> DamageCalculator -> Enemy chain.

The GDD's node-specific acceptance requires `stat_key="damage"` and
`get_stat_bonus("damage") == 0.05`, while F9 separately defines nodes authored
as `skill_weapon_bonus`. Story160 treats the specific node contract as binding:
it uses one Cat-Claw-conditioned F7-style damage modifier, applies it before the
single final integer floor, and never mirrors the same node into F9. This avoids
double application and preserves an observable `25 -> 26` PERFECT hit.

## Acceptance Criteria

- [x] `skill_tree` data and schema expose `cat_claw_t1b` as a passive T1 node,
  cost 1, no prerequisites, `damage` ADD `0.05`, conditioned on `cat_claw`.
- [x] The HUD order is Cat Claw T1-A, Cat Claw T1-B, Long Tail T1-A, Fish Bone
  T1-A, Electro Bell T1-A; Honed Claws can be selected and learned once.
- [x] Learning spends exactly 1 SP, sets `has_skill("cat_claw_t1b")`, exposes
  `get_stat_bonus("damage") == 0.05`, and survives save snapshot restore.
- [x] Cat Claw light, heavy and aerial hitbox metadata receives at most one
  capped `skill_damage_bonus`; weapon conditions are evaluated by the runtime
  consumer rather than the context-free stat query.
- [x] A real Cat Claw PERFECT light hit increases from attack/final damage
  `25.0/25` to `26.25/26`; damage-number presentation reports `26`.
- [x] Long Tail receives no Story160 damage modifier.
- [x] Focused GdUnit, bounded related regression, JSON validation and one clean
  Godot MCP 3.0.2 runtime verify menu purchase, real collision damage, non-empty
  screenshots and clean logs.

## Out Of Scope

- Other weapon T1-B nodes, Cat Claw T2-T5, respec economy, mentor NPC or final
  radial skill-tree presentation.
- Reworking F9 weapon-level base-damage propagation or changing global integer
  damage rounding.
- Charm/F8 combination, damage-cap overflow UI, balance tuning beyond the
  approved 5% value, or adding a second damage track for this node.
- New bitmap, audio or character-animation assets. Existing generated Main,
  Cinderpaw, enemy and HUD assets are reused, so image generation is not needed.

## Implementation Notes

- `SkillTreeManager.get_stat_bonus()` remains the GDD query surface. Runtime
  attacks use `get_modifiers()` so `condition.weapon` cannot leak across
  weapons.
- PlayerController filters ADD `damage` modifiers for the equipped weapon,
  clamps their aggregate to the F7 `0.25` cap and emits one metadata value.
- DamageCalculator multiplies the floating attack damage before DC-F4's final
  floor across normal, parry, special, heavy and aerial paths. F9's existing
  `skill_weapon_bonus` path remains independent.

## Test Evidence

- Intentional RED: `reports/report_1672/results.xml`, `1/1` expected failure on
  the missing `cat_claw_t1b` definition.
- Focused GREEN: `reports/report_1676/results.xml`, `1/1` passed with no errors,
  failures, flaky tests, skips or orphans.
- Final focused verification after documentation/evidence updates:
  `reports/report_1679/results.xml`, `1/1` passed with the same clean result.
- Bounded related GREEN: `reports/report_1678/results.xml`, `23/23` passed across
  Story160, four existing T1-A choices, DamageCalculator modifiers and the Main
  player-hit chain.
- JSON source/schema parse: `jq empty data/skill_tree.json` and
  `jq empty data/schemas/skill_tree.schema.json` both passed.
- Godot MCP evidence:
  `production/qa/evidence/skill-tree-cat-claw-t1b-damage-choice-2026-07-14.md`
  and
  `production/qa/evidence/skill-tree-cat-claw-t1b-damage-choice-mcp-run1.json`.

**Status**: [x] Complete.
