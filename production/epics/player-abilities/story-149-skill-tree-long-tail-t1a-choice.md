# Story 149: Skill Tree Long Tail T1-A Choice

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / UI
> **Type**: Integration + Gameplay Runtime + UI
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/skill-tree.md`, `design/gdd/weapon-styles.md`,
`design/gdd/feline-combat.md`

**Requirements**: `TR-skill-001`, `TR-skill-005`

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0003
Data management; ADR-0005 Combat state machine; ADR-0009 Skill Tree Modifier
System; ADR-0011 UI focus management; ADR-0016 Weapon styles; ADR-0021 Save
system.

Story018 proved the first skill spend, but its HUD always selects the first and
only Cat Claw node. This slice creates the first real Build choice by adding the
approved Long Tail T1-A node `延伸横扫` (`Extended Sweep`) and allowing the
player to move between the two available nodes before spending SP. The Long
Tail modifier increases only light attack 1 by `0.3` tile (`9.6px` at the
project's `32px` combat tile), so the result is visible in the Core hitbox rather
than existing only as data.

## Acceptance Criteria

- [x] `skill_tree` data exposes `long_tail_t1a` as a 1 SP modifier targeting
  `light_attack_1`, stat `attack_range`, operation `ADD`, value `0.3`, with a
  `long_tail` weapon condition.
- [x] The Skill Tree HUD shows both T1-A nodes, preserves the active selection
  during refresh, and supports previous/next selection through visible controls
  plus keyboard/gamepad left and right actions.
- [x] The selected node is the node requested for purchase; each node can be
  purchased only once, consumes exactly 1 SP, and refreshes its learned state.
- [x] With `long_tail_t1a` unlocked, Long Tail light attack 1 increases from
  `2.0` to `2.3` tiles and its Core hitbox width increases from `64.0px` to
  `73.6px` while carrying deterministic skill-range metadata.
- [x] Long Tail light attack 2 and Cat Claw attacks retain their authored base
  range and hitbox size when the Long Tail modifier is unlocked.
- [x] `long_tail_t1a` persists through runtime progress and save snapshot
  restore without regressing Story018 `cat_claw_t1a` persistence.
- [x] Focused GdUnit regression and a Godot MCP runtime probe verify menu
  selection, purchase, weapon attack metadata, hitbox size, scene state, and no
  new runtime errors.

## Out of Scope

- Full 65-node graph layout, branch prerequisites, T2-T5 nodes, T3 mutual
  exclusion, reset economy, mentor NPC, and the remaining T1-A/T1-B nodes.
- Replacing the current menu with the final radial skill-tree screen.
- New bitmap assets. This slice reuses the existing image-generated HUD and
  Cinderpaw presentation; node icon generation is deferred to the final graph
  UI so temporary art is not produced and discarded.
- Fixing pre-existing attack-facing behavior or changing authored base weapon
  configuration.

## Implementation Notes

- Keep `SkillTreeManager` scene-local and DataManager-fed.
- Keep the range modifier data-driven. PlayerController resolves the applicable
  action/weapon condition and WeaponComponent owns the final Core hitbox size.
- Treat one tile as `32px`, consistent with the Long Tail base contract
  (`2.0` tiles / `64px`).
- Keep the existing Cat Claw lunge path intact and cover it in related
  regression rather than refactoring unrelated modifier types.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/skill_tree_long_tail_t1a_runtime_test.gd`
- Story018 and Long Tail weapon contract related regression
- One focused smoke/runtime launch
- Godot MCP runtime evidence under
  `production/qa/evidence/skill-tree-long-tail-t1a-choice-2026-07-14.md`

**Evidence captured**:

- RED `reports/report_1568/report_1/results.xml` reproduced the missing HUD
  selection contract.
- Focused GREEN `reports/report_1569/report_1/results.xml` passed `3/3`.
- Related GREEN `reports/report_1570/report_1/results.xml` passed `8/8` across
  Story149, Story018 Cat Claw, and the Long Tail weapon contract.
- Post-warning-fix focused GREEN `reports/report_1571/results.xml` passed `3/3`
  with exit code `0`.
- Godot `4.7-stable` with Godot AI MCP `2.9.2` selected and learned
  `long_tail_t1a`, then measured the live first-stage hitbox at `73.6px` with
  `attack_range=2.3`, `skill_range_tiles=0.3`, and `skill_range_px=9.6`.
- After renaming a shadowing HUD parameter, the final MCP restart reported zero
  editor rows and info-only game logs.

**Status**: [x] Complete.
