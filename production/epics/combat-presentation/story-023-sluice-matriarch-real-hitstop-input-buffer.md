# Story 023: Sluice Matriarch Arena Real Hitstop + Input Buffer

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

Story022 established the reusable `HitstopInputBridge` contract in Main and
Crown Warden Arena. Sluice Matriarch Arena remained an independent playable
combat scene: real hits changed HP, but did not route through the shared
gameplay freeze, buffered-input release, damage-number, audio, or parry
presentation path. This Story integrates the arena without changing Boss3
phase, reward, route, damage, or attack-timing rules.

## Acceptance Criteria

- [x] Sluice Matriarch Arena owns exactly one `CombatPresentation` and one
  shared `HitstopInputBridge`; the bridge is the single buffered-action
  dispatch owner.
- [x] A real Cat Claw collision deals `12` damage (`120 -> 108`), displays
  `12`, and freezes pausable arena gameplay for exactly `3` physics frames.
- [x] A real Sluice Matriarch `pressure_lunge` collision deals `16` actual
  damage (`100 -> 84`), displays `16`, and follows the same `3`-frame path.
- [x] One `attack` accepted during hitstop is queued once, dispatched once,
  clears the queue, and restores InputManager to `DIRECT` after the freeze.
- [x] Rejected dodge damage leaves HP and ordinary Arena hit metadata
  unchanged and emits no ordinary damage number or `3`-frame hitstop.
- [x] PERFECT parry leaves HP unchanged, emits no false `16` damage number,
  and preserves the existing dedicated `8`-frame parry feedback with one gold
  afterimage.
- [x] Boss3 phase transition, defeat, aerial-attack reward, and route handoff
  regressions remain green.
- [x] Focused RED/GREEN, bounded related regressions, Godot 4.7 headless load,
  and one clean Godot MCP run verify real collisions, frame animation,
  screenshot visibility, and runtime logs.

## Out of Scope

- Changing Cat Claw or pressure-lunge damage, timing, hitbox, phase, parry,
  dodge, reward, respawn, or route rules.
- Replacing existing Sluice Matriarch, Cinderpaw, arena, HUD, or VFX assets.
- Adding a global pause manager, EventBus, autoload, or second input consumer.
- Integrating unrelated independently mounted combat scenes.
- Resolving pre-existing art-budget or asset-manifest inventory debt.

## Required Evidence

- `tests/unit/gameplay/sluice_matriarch_real_hitstop_input_buffer_test.gd`
- Boss3 core, aerial reward, route handoff, Crown shared-bridge, and
  CombatPresentation related regressions
- Godot MCP evidence under `production/qa/evidence/`

## Test Evidence

- Initial integration RED: `reports/report_1765/results.xml`, `3` cases with
  `4` expected failures before the Arena mounted presentation and bridge nodes.
- Initial GREEN: `reports/report_1767/results.xml`, `3/3` passing.
- Related-fixture RED: `reports/report_1768/results.xml`, `12` cases with `2`
  failures because the older Boss3 test did not advance Cat Claw into its
  authored active frames; the production collision timing was already correct.
- Related GREEN: `reports/report_1769/results.xml`, `12/12` passing after the
  fixture used the real frame timing.
- PERFECT-parry RED/GREEN: `reports/report_1770/results.xml` exposed three
  missing presentation assertions; `reports/report_1771/results.xml` passed
  `4/4` after the Arena routed the existing parry event.
- Final bounded related GREEN: `reports/report_1772/results.xml`, `50/50`
  passing across six suites with zero errors, failures, skips, or orphans.
- Fresh completion focused: `reports/report_1773/report_1/results.xml`, `4/4`
  passing with zero test errors, failures, skips, or orphans and process exit
  code `0`; GdUnit printed its known exit-time ObjectDB/resource cleanup notice.
- Godot 4.7 headless editor load exited `0`.
- Full suite was not run.

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 8/8 passing

**Assets**: No new bitmap or audio asset. Existing Cinderpaw and Sluice
Matriarch `AnimatedSprite2D + SpriteFrames`, Sluice arena environment, HUD, and
CombatPresentation VFX are reused. The Boss keeps six authored three-frame
animations: `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`.

**QA Evidence**:
`production/qa/evidence/sluice-matriarch-real-hitstop-input-buffer-2026-07-15.md`
