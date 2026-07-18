# Story 169: Main Rat King Victory Continue to Echo Guardian Same-Runtime Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Scene Management / HUD
> **Type**: Integration + ACT Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-16

> **Lifecycle Note (2026-07-19)**: Scene Management Story019 supersedes this
> Story's automatic activation step for new live defeats. Continue now enters a
> persisted safe intermission and a nearby real interaction starts Echo
> Guardian. The automatic branch remains only for legacy saves that contain Rat
> King defeat but neither Story019 flag.

## Context

**GDD**: `design/gdd/player-abilities.md`

**Requirements**: `TR-ability-001`, Player Abilities rules 1 and 2, Story156.

Story156 activates Echo Guardian when a persisted Rat King defeat is restored
into a fresh Main scene. In the live same-runtime path, however, the Rat King
reward menu's `Continue` action only hid the menu. GameFlow remained in
`victory`, player control stayed locked, and the Boss2 activation guard kept
Echo Guardian hidden indefinitely.

## Acceptance Criteria

- [x] Rat King death still holds its existing three-second victory presentation
  before showing the retry-mode reward menu.
- [x] Pressing the focused `Continue` action exits `victory`, unlocks the
  player, hides Rat King, and keeps the current Main scene instance running.
- [x] Echo Guardian atomically gains its AI target, collision, existing
  multi-frame `AnimatedSprite2D`, arena frame, HUD focus, camera lock and room
  seals.
- [x] The handoff captures a new Boss entry snapshot after Echo Guardian is
  active, so death and quick respawn return to the Echo Guardian encounter.
- [x] Existing persisted restore handoff, Rat King death hold, GameFlow and
  Boss2 reward/Factory route behavior remain functional.
- [x] One focused RED/GREEN acceptance test, bounded related regression and one
  Godot MCP same-runtime run verify the handoff, real input, screenshot and
  clean logs.

## Out Of Scope

- New Boss attacks, balance, rewards, rooms, transitions or world flags.
- New visual/audio generation; this fix reuses the approved generated Main,
  Rat King, Echo Guardian, arena, room seal and HUD assets.
- Redesigning the retry menu or changing post-Echo-Guardian route behavior.

## Test Evidence

- `tests/unit/gameplay/main_scene_sequential_boss_handoff_test.gd`
- `tests/unit/gameplay/game_flow_controller_test.gd`
- `tests/unit/gameplay/rat_king_victory_death_presentation_hold_test.gd`
- `tests/unit/gameplay/boss2_victory_route_handoff_test.gd`
- `production/qa/evidence/main-rat-king-victory-continue-echo-guardian-same-runtime-handoff-2026-07-16.md`

**Status**: [x] Complete.

- Initial RED: `reports/report_1862/report_1/results.xml`, `2` cases with the
  new same-runtime case producing `10` expected failures before the fix.
- Focused GREEN: `reports/report_1863/report_1/results.xml`, `2/2` passed.
- Final bounded related GREEN: `reports/report_1866/report_1/results.xml`,
  `9/9` passed with zero errors, failures, flaky cases, skips or orphans.
- Godot `4.7-stable` / MCP `3.0.2` run `r166455681-52` used physical Enter,
  confirmed the active three-frame Echo Guardian encounter, accepted real
  movement input, restored the same Boss2 encounter after death, captured a
  non-empty screenshot, and returned clean game/editor logs.
