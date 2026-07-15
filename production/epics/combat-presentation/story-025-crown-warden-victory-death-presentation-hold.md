# Story 025: Crown Warden Victory Death Presentation Hold

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Gameplay / Presentation Integration
> **Type**: Integration / Visual/Runtime
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-15

## Context

**GDD**: `design/gdd/boss-config.md`,
`design/gdd/combat-presentation.md`, `design/gdd/input.md`

**Requirements**: `TR-collision-007`, `TR-combatfx-001`,
`TR-combatfx-002`, `TR-combatfx-003`, `TR-input-002`, `TR-input-008`

**ADR Governing Implementation**: ADR-0001 autoload ownership; ADR-0002 signal
communication; ADR-0004 collision confirmation; ADR-0005 combat state
ownership.

Crown Warden already had a three-frame `death` animation, kill feedback, a
Wall Climb reward, return routes, and durable defeat state. The arena exposed
the reward and released its seals in the same frame as lethal damage, so the
final strike had no readable death beat. This Story adds a transient `2.0s`
presentation hold without changing combat, reward, route, or save schema.

## Acceptance Criteria

- [x] Lethal Boss4 damage commits durable defeat state immediately, starts one
  `2.0s` transient hold, and ignores duplicate defeat signals.
- [x] The hold keeps the visible `AnimatedSprite2D` on its three-frame `death`
  animation with zero active Boss hitboxes.
- [x] The hold keeps both room seals and scene lock active, locks player
  control, and hides/disables reward, return, and recall routes.
- [x] The lethal event uses the existing kill profile: exact `6`-frame
  hitstop and `18` debris particles.
- [x] One attack buffered during kill hitstop dispatches once after the freeze
  but is rejected by the victory control lock; the queue clears and
  InputManager returns to `DIRECT`.
- [x] Completing the hold releases control and seals, exposes the Wall Climb
  reward and Apex return, and creates exactly one reward reveal VFX.
- [x] Loading durable defeated state restores the completed payoff without
  replaying the transient hold or reveal VFX.
- [x] Focused/related GdUnit and one clean Godot MCP run verify timing,
  persistence, scene nodes, animation frames, logs, and a non-empty screenshot.

## Out of Scope

- Boss HP, attacks, phase logic, AI, hitboxes, damage, reward content, route
  targets, persistence schema, or player ability changes.
- New character, environment, VFX, UI, or audio assets.
- A generic cutscene framework or changes to other Boss death holds.

## Required Evidence

- `tests/unit/gameplay/crown_warden_victory_death_presentation_hold_test.gd`
- Crown Warden core, Wall Climb reward, victory recall, and real hitstop/input
  related regressions
- `production/qa/evidence/crown-warden-victory-death-presentation-hold-2026-07-15.md`

## Test Evidence

- Initial RED: `reports/report_1790/results.xml`, `1` case with `2` expected
  failures for the missing Story025 diagnostics and deterministic advance APIs.
- Focused GREEN: `reports/report_1791/results.xml`, `1/1` passing.
- Bounded related GREEN: `reports/report_1792` through `report_1795`, `15/15`
  passing across Boss4 core, reward, recall, and shared hitstop suites.
- `git diff --check` passed for all changed implementation/test files.
- Full suite was not run.

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 8/8 passing

**Assets**: No new bitmap or audio asset and no image generation. The existing
Crown Warden `AnimatedSprite2D + SpriteFrames`, three transparent `death`
frames, arena environment, reward art, HUD, and CombatPresentation VFX are
reused.

**QA Evidence**:
`production/qa/evidence/crown-warden-victory-death-presentation-hold-2026-07-15.md`
