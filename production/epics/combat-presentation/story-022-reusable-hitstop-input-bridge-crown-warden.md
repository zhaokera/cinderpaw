# Story 022: Reusable Hitstop Input Bridge + Crown Warden Arena

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Core / Foundation / Gameplay / Presentation Integration
> **Type**: Integration / Feel/Runtime
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-15

## Context

**GDD**: `design/gdd/combat-presentation.md`, `design/gdd/input.md`

**Requirements**: `TR-combatfx-001`, `TR-input-002`, `TR-input-007`,
`TR-input-008`

**ADR Governing Implementation**: ADR-0001 autoload ownership; ADR-0002 signal
communication; ADR-0004 collision confirmation; ADR-0005 combat state
ownership.

Story021 proved exact real hitstop and one-shot buffered input in Main, but the
implementation was owned by `main_scene.gd`. Crown Warden Arena mounts its own
Player, CombatPresentation, and combat chain, so it still counted hitstop
without freezing gameplay. This Story extracts the scene-level handoff into a
reusable bridge and integrates Crown Warden without creating another input
consumer.

## Acceptance Criteria

- [x] Main and Crown Warden Arena use the same `HitstopInputBridge`; each scene
  has one buffered-action dispatch owner and the Player CombatComponent is not
  left directly subscribed to InputManager.
- [x] A real Cat Claw hit through Hitbox, CollisionComponent, CombatComponent,
  and Crown Warden hurtbox deals `12` damage and freezes pausable arena logic
  for exactly `3` physics frames.
- [x] A real Crown Warden `wing_sweep` follows the reverse collision chain,
  deals `14` actual damage, displays `14`, and uses the same `3`-frame hitstop.
- [x] InputManager enters `BUFFERING` during the freeze; one buffered `attack`
  is released through PlayerController at most once, clears the queue, restores
  `DIRECT`, and advances the existing light chain without duplicate Core input.
- [x] Gameplay that was pausable before the hit remains stopped during the
  freeze and resumes afterward; the previous SceneTree pause state is restored.
- [x] Rejected damage does not create ordinary hit feedback. The covered dodge
  i-frame path keeps HP unchanged and emits no ordinary damage number, audio,
  or `3`-frame hitstop; existing perfect-parry `8`-frame feedback remains
  independent.
- [x] Combat hit metadata records `damage_applied` and
  `damage_was_applied`, so phase immunity and other damage rejection paths do
  not masquerade as confirmed presentation hits.
- [x] Focused RED/GREEN, bounded related regressions, and one Crown Warden MCP
  run verify both real collision directions, exact freeze/release behavior,
  visible AnimatedSprite2D characters, a non-empty screenshot, and clean logs.

## Out of Scope

- Changing damage values, hitstop tuning, combo timing, Boss attack timing,
  parry/dodge rules, input queue limits, or animation frames.
- Adding a global pause manager, EventBus, or new autoload.
- Integrating every remaining independently mounted player-facing combat scene.
- Defining a Crown-specific pause-menu restore predicate during hitstop.
- Generating or renaming visual/audio assets.

## Required Evidence

- `tests/unit/gameplay/crown_warden_real_hitstop_input_buffer_test.gd`
- Existing Story021 Main acceptance, CombatComponent, InputManager,
  CombatPresentation, Crown core, phase-transition, and parry regressions
- Godot MCP evidence under `production/qa/evidence/`

## Test Evidence

- Initial bridge RED: `reports/report_1750/results.xml`, `2` cases with `9`
  expected failures before Crown Warden had the reusable runtime handoff.
- Review-hardening RED: `reports/report_1759/results.xml`, the real Boss hit
  passed damage/hitstop but failed the new actual-damage metadata contract.
- `reports/report_1760/results.xml` is rejected as acceptance evidence because
  its dodge setup had not advanced into the authored i-frame window.
- Focused GREEN: `reports/report_1761/results.xml`, `3/3` passing across player
  hit/buffer release, real Boss hit, and rejected dodge damage.
- Final post-integration focused verification:
  `reports/report_1763/results.xml`, `3/3` passing with zero errors/failures.
- Bounded related GREEN: `reports/report_1762/results.xml`, `93/93` passing
  across fourteen suites covering shared combat, InputManager, Story021 Main,
  CombatPresentation, Crown core, phase transition, and perfect parry.
- Godot MCP `3.0.2` run `r68236156-17` verified both real collision directions,
  exact `3`-frame freezes, one buffered dispatch, visible three-frame character
  animations, non-empty `1278x718` screenshots, and clean logs.
- Full suite was not run.

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 8/8 passing

**Assets**: No new bitmap or audio asset. Existing Cinderpaw and Crown Warden
SpriteFrames, Crown Observatory environment art, HUD, and CombatPresentation
VFX are reused.

**QA Evidence**:
`production/qa/evidence/crown-warden-real-hitstop-input-buffer-2026-07-15.md`
