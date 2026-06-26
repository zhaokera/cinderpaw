# Story 018: Skill Tree Cat Claw T1-A First Spend

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / UI
> **Type**: Integration + Gameplay Runtime + UI
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/skill-tree.md`,
`design/gdd/feline-combat.md`

**Requirements**: `TR-ability-006`, `TR-skill-005`

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0003
Data management; ADR-0005 Combat state machine; ADR-0009 Skill Tree Modifier
System; ADR-0018 Player abilities; ADR-0021 Save system.

Rat King now grants skill points, but before this story those points had no
runtime spend path. This slice implements the first visible skill-tree spend:
Cat Claw T1-A, GDD name `疾步连爪`, implemented with the current HUD display
name `Quickstep Claws`. Buying it consumes 1 SP and immediately changes Cat Claw
light attack 2 by adding an 8px forward lunge.

## Acceptance Criteria

- [x] `skill_tree` data loads through DataManager and exposes a Cat Claw T1-A
  modifier node with cost 1, target `light_attack_2`, stat `dash_distance`,
  operation `ADD`, value `8.0`, and Cat Claw weapon condition.
- [x] MainScene owns a scene-local `SkillTreeManager` node rather than adding a
  new Autoload, and exposes runtime query/spend APIs for tests and MCP probes.
- [x] The pause flow can open a minimal Skill Tree HUD, show current SP, show
  Cat Claw T1-A details, and emit a skill unlock request.
- [x] Rat King reward SP can be spent on Cat Claw T1-A exactly once; successful
  spend reduces skill points, records `unlocked_skills`, refreshes the HUD, and
  shows a learned notification.
- [x] Unlocked skills persist through runtime progress, no-loss state, save
  snapshot, and restore.
- [x] Cat Claw light attack 2 reads the unlocked modifier, lunges the player
  forward by 8px, and carries `skill_lunge_px` metadata into the Core weapon
  hitbox chain.
- [x] Player-visible character animation remains `AnimatedSprite2D` +
  `SpriteFrames`, and MCP runtime verifies the scene, logs, nodes, modifier,
  attack behavior, and screenshot.

## Out of Scope

- Full 65-node skill tree layout, T2-T5 branches, T3 mutual exclusion, reset
  economy, NPC mentor UI, mouse/gamepad node graph navigation, charm F8
  combined bonus, full F7 caps, and all other weapon T1-A/T1-B nodes.
- New visual assets. This story reuses the existing image-generated Cinderpaw,
  combat HUD, environment, and gate feedback assets.
- Reworking DamageCalculator, the whole CombatComponent modifier model, all
  weapon hitbox facing behavior, or final localization.

## Implementation Notes

- Keep SkillTreeManager scene-local and DataManager-fed. Do not add a sixth
  Autoload.
- Treat this as the first vertical slice of the skill tree, not the final
  production UI. The HUD is intentionally minimal but must be player-visible
  and runtime-operable.
- Keep DamageCalculator decoupled from skill-tree state. PlayerController may
  consume action modifiers for movement behavior, while weapon hitbox metadata
  remains a plain Dictionary payload.
- If later stories add damage/stat bonuses, extend the same provider interface
  rather than hard-coding new gameplay branches.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/skill_tree_spending_ui_runtime_test.gd`
- HUD/MainScene/weapon/save related regression
- Headless main-scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/skill-tree-cat-claw-t1a-first-spend-2026-06-26.md`

**Recorded evidence**:

- RED: `reports/report_719/`, expected failure on missing MainScene/HUD skill
  tree APIs and signals.
- GREEN focused before final refactor: `reports/report_720/`, Story018 `2/2`.
- Related regression before final refactor: `reports/report_723/`, `42/42`.
- Final focused after refactor: `reports/report_724/`, Story018 `2/2`.
- Final related regression: `reports/report_725/`, `42/42`.
- Headless smoke:
  `reports/skill_tree_cat_claw_t1a_main_scene_smoke.log`.
- MCP runtime screenshot:
  `reports/visual/cinderpaw-mcp-skill-tree-cat-claw-t1a-20260626.png`.
- QA evidence:
  `production/qa/evidence/skill-tree-cat-claw-t1a-first-spend-2026-06-26.md`.

**Status**: [x] Complete.
