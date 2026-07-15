# Story 026: Neon Rooftops Combat Impact

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

Neon Rooftops already had a real Cat Claw/Signal Rat collision loop, six
three-frame Signal Rat animations, cache reward, and a perfect-parry laser
trial. It lacked the shared scene-mounted combat presentation and hitstop input
handoff used by the other player-facing combat scenes. This Story closes that
runtime gap without changing encounter rules or assets.

## Acceptance Criteria

- [x] Neon Rooftops mounts exactly one `CombatPresentation` and one
  `HitstopInputBridge`.
- [x] A real Cat Claw hit changes Signal Rat HP `36 -> 24`, shows damage `12`
  and six normal sparks, and applies exact three-frame gameplay hitstop.
- [x] One attack buffered during hitstop dispatches once, clears the queue,
  and returns InputManager to `direct` with the bridge as the only dispatch
  owner.
- [x] A real Signal Rat lunge changes player HP `100 -> 89`, presents actual
  damage `11`, and uses the same three-frame path.
- [x] Dodge iframes reject the collision before enemy damage metadata and emit
  no ordinary damage number or hitstop.
- [x] The real lethal Cat Claw hit preserves Signal Rat `death` and cache
  behavior while using maximum six-frame kill hitstop and 18 debris once.
- [x] A real Tower laser PERFECT parry uses exact eight-frame hitstop, 22 parry
  sparks, one flash, one gold afterimage, and no damage number.
- [x] Reattaching a cached scene and calling
  `configure_scene_manager_runtime()` reconnects the input bridge.
- [x] Focused/related GdUnit and Godot MCP verify nodes, real runtime events,
  multi-frame characters, logs, and non-empty screenshots.

## Out of Scope

- Enemy AI, damage, attack timing, hitboxes, parry windows, rewards, routes,
  save schema, audio ids, or player ability changes.
- New or regenerated character, environment, VFX, UI, or audio assets.
- Combat presentation integration for other independent scenes.

## Required Evidence

- `tests/unit/gameplay/neon_rooftops_combat_impact_test.gd`
- Signal Rat ambush, Tower parry-laser, and shared hitstop related regressions
- `production/qa/evidence/neon-rooftops-combat-impact-2026-07-15.md`

## Test Evidence

- Initial RED: `reports/report_1796/results.xml`, six cases with 11 expected
  failures for the missing presentation/bridge and diagnostics APIs.
- Focused GREEN: `reports/report_1798/results.xml`, `6/6` passing.
- Related GREEN: Tower laser and shared hitstop suites passed `3/3` each in
  `report_1801`; Signal Rat passed `3/3` in `report_1802` after its older test
  was aligned with authored startup, hitstop, and hit-stun timing.
- Fresh completion gate: `reports/report_1803/results.xml`, `6/6` passing with
  zero errors, failures, flaky cases, skips, or orphans under Godot 4.7.
- Full suite was not run.

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 9/9 passing

**Assets**: No new bitmap/audio asset and no image generation. Existing
Cinderpaw and Neon Signal Rat `AnimatedSprite2D + SpriteFrames`, generated
environment art, HUD, audio, and combat VFX are reused. Signal Rat retains six
animations with three frames each.

**QA Evidence**:
`production/qa/evidence/neon-rooftops-combat-impact-2026-07-15.md`
