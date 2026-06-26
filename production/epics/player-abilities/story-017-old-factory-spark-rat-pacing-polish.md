# Story 017: Old Factory Spark Rat Pacing Polish

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Combat Pacing / Visual Feel
> **Type**: Integration + Gameplay Runtime + Combat Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/ai-framework.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-ai-001`, `TR-ai-002`, `TR-ai-007`, `TR-ai-008`,
`TR-combat-001`, `TR-explore-006`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005
Combat state machine; ADR-0006 AI behavior; ADR-0007 Scene management;
ADR-0018 Player abilities.

Stories013-015 made Factory Spark Rat visible, animated, readable during its
attack tell, and compatible with the player's dodge-counter window. This story
polishes the encounter pacing so the enemy no longer feels like a static prop
or an immediate bite check after the route opens. The Spark Rat now needs a
scene-local pressure line, opens with a short grace window, patrols while the
player stays outside alert range, then enters the existing tell -> active bite
loop.

## Acceptance Criteria

- [x] Spark Rat remains visible but inactive after the deep route endpoint opens
  until the player crosses the Spark Rat pressure line; inactive state has no
  target, physics/process, collision, or bite damage.
- [x] Activating Spark Rat is one-shot, exposes deterministic pacing diagnostics,
  enables collision `2/17`, binds the player target, and starts an opening grace
  window before any automatic bite.
- [x] While the target is outside alert radius, Spark Rat patrols between bounded
  points using the existing `run` animation and does not start a bite sequence.
- [x] Once the target enters alert range, Spark Rat can chase and enter the
  existing `attack_tell -> attack` chain; first bite startup is at least 12
  frames and active-frame damage still resolves only once.
- [x] Story015 dodge-counter contract remains intact: active bite deals 9 damage
  without dodge, i-frame dodge negates damage, opens a 30-frame Cat Claw counter
  window, and consumes the Cat Claw counter bonus once.
- [x] Scene-local state restore preserves active/defeated Spark Rat state and
  pacing diagnostics without replaying route feedback or stale bite diagnostics.
- [x] Focused RED/GREEN tests, Spark Rat/Old Factory related regression,
  headless smoke, and Godot MCP runtime screenshot/log evidence are recorded.

## Out of Scope

- Boss2, hidden boss, new rooms, multi-room Old Factory expansion, multi-enemy
  coordination AI, NavigationAgent2D, patrol spline tooling, new enemy families,
  skill-tree UI, savepoint/minimap gameplay, loot/economy, SFX expansion,
  shader/camera polish, and final authored art replacement.
- Reworking PlayerController, CombatComponent, Cat Claw counter math, dodge
  i-frame timing, Spark Rat base damage, Spark Rat HP, or shared Rat Minion
  constants.
- New visual assets. This story reuses the existing image-generated Factory
  Spark Rat `AnimatedSprite2D + SpriteFrames` assets from Stories013-014.

## Implementation Notes

- Keep pacing scene-local and deterministic. Do not introduce a new Autoload or
  full AIComponent integration for this small encounter polish.
- Use a small `FactorySparkRat` hook for opening grace, patrol, alert, and
  diagnostics, while keeping the shared Rat Minion combat loop intact.
- Keep `try_activate_factory_spark_rat()` backward-compatible for tests that
  activate the encounter after endpoint clear, but gate it on the Spark Rat
  pressure line.
- Record the generated asset reuse in QA evidence; no new image generation is
  required unless a later story explicitly changes the visuals.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_spark_rat_pacing_polish_test.gd`
- `tests/unit/gameplay/old_factory_spark_rat_patrol_encounter_test.gd`
- `tests/unit/gameplay/old_factory_spark_rat_attack_tell_feedback_test.gd`
- `tests/unit/gameplay/old_factory_spark_rat_dodge_counter_readability_test.gd`
- Old Factory route related regression
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-spark-rat-pacing-polish-2026-06-26.md`

**Recorded evidence**:

- RED: `reports/report_712/`, expected failure on missing pacing API,
  activation diagnostics, and pressure-line gate.
- GREEN focused: `reports/report_714/`, Story017 `5/5`.
- Related Spark Rat / dodge-counter regression: `reports/report_715/`, `32/32`.
- Related Old Factory route regression: `reports/report_716/`, `32/32`.
- Final pre-commit focused: `reports/report_717/`, Story017 `5/5`.
- Headless smoke: `reports/old_factory_spark_rat_pacing_polish_factory_scene_smoke.log`
  and `reports/old_factory_spark_rat_pacing_polish_main_scene_smoke.log`.
- MCP runtime screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-spark-rat-pacing-polish-20260626.png`.
- QA evidence:
  `production/qa/evidence/old-factory-spark-rat-pacing-polish-2026-06-26.md`.

**Status**: [x] Complete.
