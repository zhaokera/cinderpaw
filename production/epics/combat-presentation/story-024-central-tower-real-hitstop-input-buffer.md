# Story 024: Central Tower Real Hitstop + Input Buffer

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Gameplay / Presentation Integration
> **Type**: Integration / Feel/Runtime
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-15

## Context

**GDD**: `design/gdd/combat-presentation.md`, `design/gdd/input.md`

**Requirements**: `TR-combatfx-001`, `TR-combatfx-004`,
`TR-combatfx-005`, `TR-input-002`, `TR-input-007`, `TR-input-008`

**ADR Governing Implementation**: ADR-0001 autoload ownership; ADR-0002 signal
communication; ADR-0004 collision confirmation; ADR-0005 combat state
ownership.

Story021-023 established the reusable real-hitstop and buffered-input contract
in Main, Crown Warden Arena, and Sluice Matriarch Arena. Central Tower is a
separate playable ACT route containing Threshold Guard, Relay Mantis, and
Counterweight Sentry combat encounters. Its real collisions changed HP but did
not share the presentation bridge, so combat feedback and rejected-damage
handling diverged from the verified contract. This Story integrates the route
without changing encounter pacing, damage, traversal, reward, or route rules.

## Acceptance Criteria

- [x] Central Tower owns exactly one `CombatPresentation` and one shared
  `HitstopInputBridge`; the bridge is the only buffered-action dispatch owner.
- [x] A real Cat Claw collision deals `12` damage to Threshold Guard
  (`48 -> 36`), displays `12`, and freezes pausable gameplay for exactly `3`
  physics frames.
- [x] A real Threshold Guard attack deals `14` actual damage to Cinderpaw
  (`100 -> 86`), displays `14`, and follows the same `3`-frame path.
- [x] One `attack` accepted during hitstop is queued once, dispatched once,
  clears the queue, and restores InputManager to `DIRECT` after the freeze.
- [x] Dodge and respawn i-frames leave HP unchanged and emit no ordinary
  damage number or `3`-frame hitstop.
- [x] PERFECT parry leaves HP unchanged, emits no false `14` damage number,
  and preserves the dedicated `8`-frame feedback with one gold afterimage.
- [x] Threshold Guard, Relay Mantis, and Counterweight Sentry route their real
  landed-hit signals through one scene presentation handler; threshold, relay,
  lift, and authored-hit timing regressions remain green.
- [x] Focused RED/GREEN, bounded related regressions, and clean Godot MCP runs
  verify real collisions, multi-frame animation, screenshot visibility, scene
  loading, and runtime/editor logs.

## Out of Scope

- Changing Cat Claw or Central Tower enemy damage, attack timing, hitboxes,
  encounter pacing, traversal, rewards, save state, or route handoff rules.
- Replacing existing Cinderpaw, enemy, Central Tower, HUD, or VFX assets.
- Adding a global pause manager, EventBus, autoload, or second input consumer.
- Integrating unrelated independently mounted combat scenes.
- Optimizing the Central Tower's pre-existing draw-call budget.

## Required Evidence

- `tests/unit/gameplay/central_tower_real_hitstop_input_buffer_test.gd`
- Threshold Guard, Inner Relay, Deep Lift, authored player hitbox timing,
  Crown shared-bridge, CombatPresentation, Rat King summon, and Old Factory
  entrance related regressions
- Godot MCP evidence under `production/qa/evidence/`

## Test Evidence

- Initial integration RED: `reports/report_1774/report_1/results.xml`, `5`
  cases with `2` expected failures before Central Tower mounted the shared
  presentation and bridge.
- Focused GREEN after production fixes: `reports/report_1779/results.xml`,
  `6/6` passing.
- Final bounded related GREEN: `reports/report_1787/results.xml`, `66/66`
  passing across nine suites with zero errors, failures, skips, or orphans.
- MCP warning regression: `reports/report_1788/results.xml`, `6/6` passing
  across Cooling Shaft and Apex Purge after warning-only parameter renames.
- Fresh completion focused: `reports/report_1789/results.xml`, `6/6` passing
  with zero test errors, failures, skips, or orphans and process exit code `0`;
  GdUnit printed its known exit-time ObjectDB/resource cleanup notice.
- Full suite was not run.

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 8/8 passing

**Assets**: No new bitmap or audio asset. Existing Cinderpaw, Threshold Guard,
Relay Mantis, and Counterweight Sentry `AnimatedSprite2D + SpriteFrames`,
Central Tower environment, HUD, audio cues, and CombatPresentation VFX are
reused. Each inspected gameplay animation contains at least three frames.

**Known Performance Debt**: Final MCP sampling showed about `120 FPS` and
`398` draw calls. Story024 adds only the shared presentation/bridge nodes and
does not claim to resolve the route's existing draw-call budget.

**QA Evidence**:
`production/qa/evidence/central-tower-real-hitstop-input-buffer-2026-07-15.md`
