# Story 015: Old Factory Spark Rat Dodge-Counter Readability

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Combat Integration
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`

**Requirements**: `TR-combat-003`, `TR-combat-006`, `TR-ai-007`, `TR-ai-008`,
`TR-collision-002`

**ADR Governing Implementation**: ADR-0004 Collision architecture; ADR-0005
Combat state machine; ADR-0007 Scene management; ADR-0018 Player abilities.

Story014 made the Factory Spark Rat attack startup readable through a red
`attack_tell` animation. This story connects that tell to the player's existing
dodge i-frame and Cat Claw counter systems so the Old Factory loop becomes:
read the tell, dodge the bite, then punish during the counter window.

## Acceptance Criteria

- [x] `PlayerController.request_dodge()` drives both the visible player dodge
  state and the Core `CombatComponent` dodge state used by i-frame/counter
  logic.
- [x] When the active Factory Spark Rat bite is resolved while the player is in
  dodge i-frames, the player takes no damage and the scene records deterministic
  dodge-counter diagnostics for tests and MCP probes.
- [x] Finishing that successful dodge opens the existing 30-frame Cat Claw
  counter window; diagnostics expose remaining counter frames and the last
  dodged Spark Rat bite metadata.
- [x] A Cat Claw light hit on Spark Rat during the counter window injects and
  consumes `claw_counter_crit_window_bonus_frames = 3` through the existing
  `CombatComponent` hit metadata path.
- [x] A Spark Rat bite resolved without an active dodge i-frame damages the
  player for the existing 9-point `factory_spark_rat_bite` damage contract.
- [x] Story013/Story014 frame-animation and attack-tell behavior remain
  unchanged: `FactorySparkRat/Sprite` uses `AnimatedSprite2D + SpriteFrames`,
  `attack_tell` has at least 3 frames, and startup switches to active `attack`.
- [x] Focused RED/GREEN tests, related Old Factory/combat regression, Godot
  import/headless smoke, and Godot MCP runtime screenshot/log evidence are
  recorded.

## Out of Scope

- Spark Rat patrol pacing, NavigationAgent2D, patrol splines, new rooms, Boss2,
  hidden boss, savepoints, minimap, skill-tree UI, SFX, shaders, loot/economy,
  new generated visual assets, or a full enemy AI rewrite.
- Changing the Cat Claw counter math, dodge frame windows, Spark Rat base bite
  damage, or existing Story013/Story014 generated frames.

## Implementation Notes

- Keep the existing `CombatComponent` dodge/counter implementation as source of
  truth; this story should wire gameplay runtime to it instead of duplicating
  counter logic in the Factory scene.
- Add scene-level deterministic APIs only where they describe real gameplay
  state and can be used by GdUnit and Godot MCP probes.
- The Factory scene may resolve the Spark Rat bite deterministically for tests
  and smoke probes, but damage/counter metadata must still flow through
  `PlayerController`, `CombatComponent`, and `OldFactoryEntranceScene` adapters.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_spark_rat_dodge_counter_readability_test.gd`
- `tests/unit/gameplay/old_factory_spark_rat_attack_tell_feedback_test.gd`
- `tests/unit/gameplay/old_factory_spark_rat_patrol_encounter_test.gd`
- `tests/unit/combat/story_003_dodge_iframes_hurtbox_adapter_test.gd`
- `tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-spark-rat-dodge-counter-readability-2026-06-26.md`

**Status**: [x] Complete.
