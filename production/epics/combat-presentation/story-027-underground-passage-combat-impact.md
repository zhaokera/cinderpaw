# Story 027: Underground Passage Combat Impact

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

Underground Passage already had a playable four-view route, two Factory Sluice
Leeches, one Cistern Stalker, route rewards, hazards, recovery, and complete
three-frame character animation sets. It lacked the shared scene-mounted combat
presentation and hitstop input handoff used by the other player-facing combat
scenes. This Story closes that runtime gap without changing encounter balance,
route rules, rewards, or assets.

## Acceptance Criteria

- [x] Underground Passage mounts exactly one `CombatPresentation` and one
  `HitstopInputBridge`.
- [x] A real Cat Claw hit applies damage `12`, shows one damage number and six
  sparks, and uses exact three-frame gameplay hitstop.
- [x] Real attacks from both Sluice Leeches apply damage `11`; a real Cistern
  Stalker leap applies damage `14`; both use the same three-frame path.
- [x] One attack buffered during hitstop dispatches once, clears the queue,
  and returns InputManager to `direct`.
- [x] Dodge iframes reject enemy damage before ordinary damage metadata and
  produce no false hit feedback.
- [x] A real PERFECT parry preserves player HP, emits no ordinary damage
  number, and uses exact eight-frame hitstop, 22 parry sparks, one flash, and
  one gold afterimage.
- [x] A real lethal Stalker hit uses maximum six-frame hitstop, six hit sparks,
  18 debris, one kill event, and the existing three-frame `death` animation.
- [x] Reattaching a cached Underground instance after one Leech is freed does
  not access a stale reference; the remaining Leech can still hit once and the
  bridge returns to `direct`.
- [x] The existing corrosion encounter clear/reward and deep-cistern Stalker
  behavior remain deterministic.
- [x] Godot MCP verifies scene nodes, real runtime combat events, multi-frame
  characters, logs, and non-empty screenshots.

## Out of Scope

- Enemy AI, HP, damage values, authored attack timing, parry windows, hazards,
  rewards, routes, save schema, audio ids, or player ability changes.
- New or regenerated character, environment, VFX, UI, or audio assets.
- Environment animation, Cinderpaw art consistency remediation, or combat
  presentation integration for other independent scenes.

## Required Evidence

- `tests/unit/gameplay/underground_passage_combat_impact_test.gd`
- Underground corrosion-channel and deep-cistern related regressions
- `production/qa/evidence/underground-passage-combat-impact-2026-07-15.md`

## Test Evidence

- Initial RED: `reports/report_1804/results.xml`, six cases with 14 expected
  failures for missing presentation, bridge, and diagnostics behavior.
- Initial focused GREEN: `reports/report_1808/results.xml`, `6/6` passing.
- Review-hardening RED: `reports/report_1814/results.xml` reproduced missing
  PERFECT-parry feedback and the freed-Leech cached-reentry runtime error.
- Final focused GREEN: `reports/report_1815/results.xml`, `7/7` passing.
- Final related GREEN: `reports/report_1816/results.xml`, corrosion channel
  `3/3` and deep-cistern Stalker `3/3` passing.
- Final focused/related total: `13/13`; full suite was not run.

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 10/10 passing

**Implementation note**: The Leech `CombatComponent` was missing its existing
scene damage-calculator adapter, so its real active lunge hitbox could not apply
the already-authored damage `11`. Story027 connects that adapter and routes the
existing hit id without changing the intended balance value.

**Assets**: No new bitmap/audio asset and no image generation. Existing
Cinderpaw, Factory Sluice Leech, and Cistern Stalker
`AnimatedSprite2D + SpriteFrames`, generated Underground environments, HUD,
audio, and combat VFX are reused.

**QA Evidence**:
`production/qa/evidence/underground-passage-combat-impact-2026-07-15.md`
