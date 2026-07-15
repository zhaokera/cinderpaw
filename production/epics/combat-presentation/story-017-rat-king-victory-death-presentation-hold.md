# Story 017: Rat King Victory Death Presentation Hold

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Gameplay Runtime / Presentation / UI
> **Type**: Integration + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/combat-presentation.md`

**Quick Spec**:
`design/quick-specs/rat-king-victory-death-presentation-hold-2026-07-14.md`

**Requirements**: Boss defeat death-animation-before-reward flow and existing
CombatPresentation kill feedback.

Rat King already owns a generated three-frame `death` animation, collision
shutdown, kill VFX/audio, configured reward dispatch and save persistence. Main
currently opens the full-screen victory menu synchronously with the death
signal, obscuring the visual payoff that the approved Boss GDD holds for three
seconds.

## Acceptance Criteria

- [x] Real Main Rat King defeat immediately plays the existing non-looping
  three-frame `death` animation and leaves its combat collision disabled.
- [x] GameFlow enters `victory_pending` for `3.0s`, locks player control and
  exposes deterministic remaining-time diagnostics.
- [x] Victory/reward and pause menus stay hidden throughout the pending window;
  Boss HP is hidden instead of switching to another active Main-scene Boss;
  existing reward grant, defeat flag and autosave timing remain unchanged.
- [x] The pending window ignores duplicate enemy-defeat and player-death
  requests without resetting the timer or emitting reward/victory twice.
- [x] At expiry, GameFlow enters `victory`, emits `victory_reached` once, hides
  Boss HP and shows the existing `Dash unlocked +50 Gears +5 SP` reward menu.
- [x] Focused GdUnit, bounded related regression, target smoke and Godot MCP
  verify timing, animation frames, unobscured death hold, delayed UI, clean
  logs and non-empty screenshots.

## Out Of Scope

- New visual/audio assets, death frames, shader, camera cutscene or slow motion.
- Reward value, save schema, Boss balance, phase, attack or arena changes.
- Ending, credits, Boss5, post-game or scene transition work.

## Test Evidence

- `tests/unit/gameplay/rat_king_victory_death_presentation_hold_test.gd`
- `tests/smoke/rat_king_victory_death_presentation_hold_smoke.gd`
- `production/qa/evidence/rat-king-victory-death-presentation-hold-2026-07-14.md`

**Status**: [x] Complete. Initial RED `report_1631` failed `1/1` case with five
expected contract failures; runtime refinement RED `report_1634` reproduced the
deferred phase animation replacing `death`. Focused GREEN `report_1635` passed
`1/1`; bounded related GREEN `report_1636` passed `47/47`. MCP visual review then
exposed the wrong Boss2 HUD during the hold: RED `report_1637`, final focused
GREEN `report_1638` `1/1`, and final HUD/reward related GREEN `report_1639`
`6/6`. Target smoke printed
`rat_king_victory_death_presentation_hold_smoke=passed`. Godot MCP final run
`r21623823-27` verified the real Main death hold, hidden Boss HUD, exact `3.0s`
boundary, delayed reward menu, two non-empty `1278x718` screenshots, three
info-only game rows, zero editor rows and a clean stop to `ready`.
