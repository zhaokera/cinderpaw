# Story 021: Main Scene Real Hitstop + Input Buffer

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Foundation / Gameplay / Presentation Integration
> **Type**: Feel/Runtime
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-15

## Context

**GDD**: `design/gdd/combat-presentation.md`, `design/gdd/input.md`

**Requirements**: `TR-combatfx-001`, `TR-input-002`, `TR-input-007`,
`TR-input-008`

**ADR Governing Implementation**: ADR-0001 autoload ownership; ADR-0002 signal
communication; ADR-0005 combat state ownership.

`CombatPresentation.play_hitstop()` previously recorded a remaining-frame
counter but did not pause gameplay. A hit therefore produced visual feedback
without the GDD's actual logic freeze, and inputs made during that window were
not handed through `InputManager` after the freeze. This Story closes that gap
for the playable Main scene while preserving Core as the combat-state owner.

## Acceptance Criteria

- [x] A Main-scene hitstop request pauses pausable gameplay logic for exactly
  the requested physics-frame count and restores the tree's previous pause
  state afterward.
- [x] `CombatPresentation` continues processing while the tree is paused,
  resolves overlapping requests by the existing maximum-frame rule, exposes
  deterministic diagnostics, and restores pause state during teardown.
- [x] `InputManager` enters `BUFFERING` for the freeze window, captures
  bufferable trigger actions while paused, and returns to direct input after
  the presentation releases the lock.
- [x] Main consumes at most one released buffered action and routes it through
  `PlayerController`, avoiding duplicate direct `CombatComponent` dispatch.
- [x] A buffered light attack is accepted exactly once, advances the existing
  Core attack chain, and keeps Player/Core presentation state synchronized.
- [x] Direct input outside hitstop preserves existing behavior; the shared
  InputManager queue, metadata signal, priority, expiry, and depth contracts
  remain intact.
- [x] Focused RED/GREEN, bounded input/combat/presentation regressions, and one
  clean Godot MCP Main run verify a real collision hit, frozen gameplay,
  buffered attack release, visible AnimatedSprite2D character, non-empty
  screenshot, and clean runtime/editor logs.

## Out of Scope

- Wiring the same runtime freeze/input handoff into independent player-facing
  scenes that own their own `CombatPresentation`, including Crown Warden Arena.
- Changing hitstop tuning values, attack damage, combo windows, animation
  timing, input queue depth, pre-input weighting, or mobile adaptation.
- Adding a dedicated buffered heavy-charge gesture; this Story's runtime
  acceptance action is the standard light attack.
- Generating new visual or audio assets.

## Required Evidence

- `tests/unit/gameplay/main_scene_real_hitstop_input_buffer_test.gd`
- Existing InputManager, Main combat-chain, CombatPresentation, animation,
  dodge, and parry regressions
- Godot MCP evidence under `production/qa/evidence/`

## Test Evidence

- Expected RED: `reports/report_1737/results.xml`, `1` case with `10` expected
  behavior failures and no test-harness error.
- Focused GREEN: `reports/report_1746/results.xml`, `1/1` passing.
- Bounded related GREEN: `reports/report_1747/results.xml`, `68/68` passing
  across nine executed suites covering Main, InputManager, presentation,
  combo, air, and dodge behavior.
- Corrected parry regression path: `reports/report_1748/results.xml`, `5/5`
  passing.
- Godot MCP `3.0.2` run `r65195448-16` verified a real Main collision reduced
  Enemy HP `300 -> 290`, paused the tree for `3` completed frames, buffered one
  attack with `36ms` delay, dispatched it once, advanced the combo to stage
  `1`, restored direct input, and ended with clean game/editor logs.
- Full suite was not run and no equivalent test was repeated after documentation.

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 7/7 passing

**Assets**: No new bitmap or audio asset. Existing Cinderpaw SpriteFrames and
combat feedback resources are reused.

**QA Evidence**:
`production/qa/evidence/main-scene-real-hitstop-input-buffer-2026-07-15.md`
