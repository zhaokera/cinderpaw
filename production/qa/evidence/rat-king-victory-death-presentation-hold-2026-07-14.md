# Rat King Victory Death Presentation Hold Evidence

## Scope

Combat Presentation Story017 closes the visible handoff between Rat King death
and the existing reward menu. It reuses the approved image-generated Rat King
`death` frames and existing reward UI/audio; no new visual asset was required.

## Implementation

- `GameFlowController` enters `victory_pending` for exactly `3.0s`, locks player
  control and emits `victory_reached` only when the hold expires.
- Main blocks pause-menu interruption during `victory_pending`.
- Rat King ignores deferred phase-transition presentation callbacks after
  entering `DEAD`, so a lethal phase-threshold hit cannot replace `death` with
  `phase_2_rebuild` or `phase_3_overload`.
- Reward grant, progression flag and autosave remain immediate and idempotent;
  only the full-screen reward menu is delayed.

## TDD And Smoke

- Initial RED: `reports/report_1631/report_1/results.xml`, `1` case with `5`
  expected failures for the missing hold contract.
- Runtime refinement RED: `reports/report_1634/results.xml`, `1` expected failure
  reproducing `phase_2_rebuild` replacing `death` on the next process frame.
- Focused GREEN: `reports/report_1635/results.xml`, `1/1` passed.
- Bounded related GREEN: `reports/report_1636/results.xml`, `47/47` passed across
  Story017, GameFlow, reward, Rat King runtime/animation and CombatPresentation.
- MCP visual refinement RED: `reports/report_1637/report_1/results.xml`, `1`
  expected failure proving the Rat King hold displayed the unrelated Boss2 HUD.
- Final focused GREEN: `reports/report_1638/report_1/results.xml`, `1/1` passed.
- Final HUD/reward related GREEN: `reports/report_1639/report_1/results.xml`,
  `6/6` passed across Story017, Rat King rewards and Boss2 HUD focus.
- Target smoke: `reports/rat_king_victory_death_presentation_hold_smoke.log`
  printed `rat_king_victory_death_presentation_hold_smoke=passed` with `death`,
  `3` frames, zero active hitboxes, gone hurtbox, immediate `50/5/dash` reward,
  hidden menu and `3.0s` remaining.

No full suite was run; the Story has a bounded shared-flow blast radius and the
focused plus related set covers the changed contract.

## Godot MCP Runtime

Session `cinderpaw@d40a`, Godot `4.7-stable`, project plugin/server `2.9.2`.
Final clean run `r21623823-27` started `res://scenes/main.tscn` with helper live
and `current_run_errors=[]`.

Death-hold probe after one real process frame returned:

- Rat King HP `300 -> 0`, animation `death`, `3` death frames.
- Active hitboxes `0`, hurtbox `gone`.
- Flow `victory_pending`, control locked, remaining `3.0s`.
- Reward menu hidden while currency/SP/ability were already `50/5/dash`.
- Boss HUD hidden instead of switching to the unrelated active Echo Guardian.

At `2.99s`, flow remained `victory_pending`, remaining time was `0.01s`, and
the menu was hidden. Duplicate defeat plus player-death requests did not reset
the hold. Advancing another `0.02s` produced `victory`, remaining `0.0s`, title
`Rat King defeated`, and the existing Dash/+50 Gears/+5 SP reward subtitle.

Final run logs contained three info-only helper/DataManager rows, editor logs
contained zero rows, and stopping returned editor readiness to `ready`.

An exploratory run 25 was discarded after a temporary probe called a nonexistent
HUD diagnostic method. The game was stopped, debugger/error buffers were
cleared, and all acceptance evidence above was recreated in clean run 26; no
project file was involved in that probe error.

## Visual Evidence

- `reports/visual/cinderpaw-mcp-rat-king-victory-death-hold-20260714.png`
  (`1278x718`, SHA-256
`53fde162983e50fbfcf8c60bbdf3116d1d9a78e0f73d6d1c28920e80eca25478`):
  Rat King death remains visible and the reward menu is absent.
- `reports/visual/cinderpaw-mcp-rat-king-victory-reward-menu-20260714.png`
  (`1278x718`, SHA-256
`45a281522197eb7a9ac61d7cfc31f300eaa2a99d604028e818323d98df2a7d94`):
  the reward menu appears only after hold expiry.

Both captures were decoded from MCP `editor_screenshot(source="game")`, checked
as non-empty PNG files and visually inspected.
