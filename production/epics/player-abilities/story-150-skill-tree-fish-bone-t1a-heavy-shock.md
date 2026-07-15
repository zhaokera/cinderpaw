# Story 150: Skill Tree Fish Bone T1-A Heavy Shock

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / UI / Collision
> **Type**: Integration + Gameplay Runtime + UI
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/skill-tree.md`, `design/gdd/weapon-styles.md`,
`design/gdd/feline-combat.md`

**Requirements**: `TR-skill-001`, `TR-skill-005`

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0003
Data management; ADR-0004 Collision architecture; ADR-0005 Combat state
machine; ADR-0009 Skill Tree Modifier System; ADR-0011 UI focus management;
ADR-0016 Weapon styles; ADR-0021 Save system.

Story149 exposed two real Build choices. This slice adds the approved Fish Bone
T1-A node `重击震荡` (`Heavy Shock`) and carries its `8px` micro-knockback
through the existing grounded heavy hitbox. The movement is resolved by the
target CollisionComponent so walls can reduce the displacement without
teleporting an actor through environment collision. Existing generated Fish
Bone impact art, heavy animations, hitstop, shake and audio provide the visible
feedback; no temporary bitmap or sound is required.

## Acceptance Criteria

- [x] `skill_tree` data and schema expose `fish_bone_t1a` as a 1 SP modifier
  targeting `heavy_attack`, stat `knockback_distance`, operation `ADD`, value
  `8.0`, with a `fish_bone` weapon condition.
- [x] The Skill Tree HUD preserves the existing Cat Claw -> Long Tail order,
  adds Fish Bone as the third selectable node, purchases the selected node once
  for exactly 1 SP, and restores its learned state from a save snapshot.
- [x] An unlocked Fish Bone T1-A adds deterministic `skill_knockback_px=8.0`
  and attack direction metadata to every valid grounded Fish Bone heavy release
  from the existing `0.5-1.5s` charge window.
- [x] A confirmed hit asks the target CollisionComponent for one horizontal,
  collision-safe reaction. On open ground the target moves exactly `8px` in
  attack direction; duplicate detection cannot apply the reaction twice.
- [x] Hit results expose requested/applied displacement and whether collision
  blocked part of the movement. A successful skill hit reuses the existing
  generated Fish Bone wave at the contact point in addition to normal hit
  feedback.
- [x] Without the unlock, with another weapon, on a light attack, on an early
  heavy release, or without a confirmed hit, the skill does not move a target
  or spawn the skill-only contact wave.
- [x] Fish Bone full-charge shield break and partial-charge behavior remain
  unchanged, as do Story018 Cat Claw and Story149 Long Tail modifiers.
- [x] Focused GdUnit, bounded related regression, target smoke and Godot MCP
  runtime evidence verify purchase, persistence, animation, exact displacement,
  metadata, reused VFX, non-empty gameplay capture and clean logs.

## Out of Scope

- Fish Bone special attack `300` knockback force, launch arcs, airborne heavy,
  landing shockwaves, cliff rules, wall damage, resistance tiers or a general
  physics impulse simulation.
- Electro Bell T1-A, weapon T1-B nodes, T2-T5, T3 mutual exclusion, reset
  economy, mentor NPC and the final radial skill-tree screen.
- New character frames, bitmap assets, audio files or temporary skill icons.
- Boss5, ending, credits, new narrative or post-game content.
- Broad rewrites of DamageCalculator, StatusEffectComponent or hit events.

## Implementation Notes

- Keep `SkillTreeManager` scene-local and DataManager-fed. Preserve canonical
  branch display order rather than relying on alphabetical skill ids.
- PlayerController resolves only the applicable `heavy_attack` modifier and
  writes pixel displacement into attack metadata. It must not move targets.
- CollisionComponent owns collision-safe target displacement and reports the
  actual distance. Hitbox duplicate suppression remains the exactly-once gate.
- Preserve the current uppercase `ADD` data convention and runtime weapon id
  `fish_bone`; do not introduce ADR example aliases.
- Reuse `combat_fish_bone_wave_runtime.png` for the contact pulse and record the
  additional Story use in the asset manifest and QA evidence.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/skill_tree_fish_bone_t1a_heavy_shock_test.gd`
- Story149, grounded-heavy, Collision Story003/004 and Fish Bone shield-break
  related regression
- `tests/smoke/skill_tree_fish_bone_t1a_heavy_shock_smoke.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/skill-tree-fish-bone-t1a-heavy-shock-2026-07-14.md`

**Evidence captured**:

- RED `reports/report_1579/report_1/results.xml` captured `16` expected failures
  across the original three cases before the node, HUD ordering, runtime
  metadata, target displacement and contact-wave contract existed.
- Bounded related GREEN `reports/report_1582/report_1/results.xml` passed
  `60/60` across Story150, Story149, Story018, grounded heavy, Fish Bone shield
  break, Collision Story003/004, Main attack routing and CombatPresentation.
- Final focused GREEN `reports/report_1585/results.xml` passed `4/4`, including
  open-ground exactly-once movement, left-facing direction, wall clipping,
  purchase ordering and save restoration, with a clean process exit.
- SchemaValidator regression `reports/report_1586/results.xml` passed `13/13`,
  including integral JSON-float compatibility and fractional-int rejection.
- `tests/smoke/skill_tree_fish_bone_t1a_heavy_shock_smoke.gd` exited `0` with
  `skill_tree_fish_bone_t1a_heavy_shock_smoke=passed`, exact `8px` displacement,
  duplicate suppression, a surviving target and no cleanup warnings.
- Godot `4.7-stable` with Godot AI MCP plugin/server `2.9.2`, session
  `cinderpaw@d40a`, final run `r8347138-8`, returned `ok=true`: three-frame
  `heavy_charge`, `heavy_attack` and Rat Minion `hurt`; exact `8px` requested
  and applied movement; duplicate displacement still `8px`; two Fish Bone VFX;
  target HP `52`; three info-only game rows and zero editor rows.
- Two non-empty `1278x718` MCP captures and structured runtime values are
  retained under `production/qa/evidence/skill-tree-fish-bone-t1a-heavy-shock-*`.

**Status**: [x] Complete.
