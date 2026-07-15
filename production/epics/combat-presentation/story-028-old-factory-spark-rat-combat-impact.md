# Story 028: Old Factory Spark Rat Combat Impact

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Gameplay / Presentation Integration
> **Type**: Integration / Feel / Runtime
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-15

## Context

**GDD**: `design/gdd/combat-presentation.md`, `design/gdd/input.md`,
`design/gdd/feline-combat.md`

**Requirements**: `TR-collision-007`, `TR-combatfx-001`,
`TR-combatfx-002`, `TR-combatfx-003`, `TR-combatfx-004`, `TR-input-002`,
`TR-input-008`

**ADR Governing Implementation**: ADR-0001 autoload ownership; ADR-0002 signal
communication; ADR-0004 collision confirmation; ADR-0005 combat state
ownership.

Old Factory already had a complete route, authored encounters, generated
environment art, and multi-frame Cinderpaw, Spark Rat, Coil Rat, Rat Minion,
and Sluice Leech animations. Its combat owner did not mount the shared
`CombatPresentation + HitstopInputBridge` pair, leaving its real collision
events without the same impact and input handoff used by other playable combat
areas. This Story closes the bounded Spark Rat dodge-counter gap and connects
the shared Factory enemy signal path without changing encounter balance.

## Acceptance Criteria

- [x] Old Factory mounts exactly one `CombatPresentation` and one
  `HitstopInputBridge`.
- [x] A Spark Rat bite rejected by active dodge iframes preserves player HP and
  produces no false ordinary hit feedback.
- [x] The existing Cat Claw counter applies damage `12`, shows one damage
  number and six sparks, and uses exact three-frame gameplay hitstop.
- [x] One attack buffered during the dodge-counter hitstop dispatches once,
  is accepted by the existing player chain, clears the queue, and returns
  InputManager to `direct`.
- [x] A real Spark Rat collision bite applies existing damage `9` exactly once,
  shows damage `9`, and uses the same three-frame presentation path.
- [x] A real PERFECT parry preserves player HP and uses eight-frame hitstop,
  22 parry sparks, one flash, and one gold afterimage.
- [x] A lethal counter produces six-frame hitstop, 18 debris, and exactly one
  kill feedback event for Spark Rat entity `2102`.
- [x] Existing Spark Rat dodge-counter readability, pacing, and Factory route
  roundtrip behavior remain deterministic.
- [x] Godot MCP verifies the scene nodes, real runtime bite, input bridge,
  multi-frame characters, clean logs, and a non-empty screenshot.

## Out of Scope

- Enemy AI, HP, authored damage values, attack timing, dodge/parry windows,
  route progression, rewards, hazards, save schema, or audio ids.
- New or regenerated character, environment, VFX, UI, or audio assets.
- Full Factory content redesign or unrelated scene combat integration.

## Required Evidence

- `tests/unit/gameplay/old_factory_spark_rat_combat_impact_test.gd`
- Spark Rat readability/pacing and Factory route roundtrip regressions
- `production/qa/evidence/old-factory-spark-rat-combat-impact-2026-07-15.md`

## Test Evidence

- Initial RED: `reports/report_1817/results.xml`; the focused suite failed
  because Old Factory had no `CombatPresentation` or `HitstopInputBridge`.
- Final focused GREEN: `reports/report_1822/results.xml`, `3/3` passing.
- Final related GREEN: `reports/report_1823/results.xml`, `11/11` passing
  across Spark Rat dodge-counter readability, pacing, and Factory route
  roundtrip.
- Fresh completion gate: `reports/report_1824/results.xml`, all four focused and
  related suites `14/14` passing with exit `0`.
- Final focused/related total: `14/14`; full suite was not run.

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 9/9 passing

**Implementation note**: The scene owner now routes existing Factory enemy
`enemy_attack_landed` signals through one presentation/audio path and assigns
itself as their damage calculator adapter. Spark Rat remains bounded to its
existing `9` bite and `12` Cat Claw counter values. Ordinary feedback is only
emitted when player HP actually decreases, and lethal feedback is deduplicated
per entity id.

**Assets**: No new bitmap/audio asset and no image generation. Existing
Cinderpaw and Factory enemy `AnimatedSprite2D + SpriteFrames`, generated Old
Factory environments, HUD, audio, and combat VFX are reused.

**QA Evidence**:
`production/qa/evidence/old-factory-spark-rat-combat-impact-2026-07-15.md`
