# Story 168: Crown Warden ACT Complete Epilogue At Scrap Roost

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / UI / Save / Scene Flow
> **Type**: Integration + UI/Visual + Save/Scene Flow
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-16

## Context

**GDD**: `design/gdd/game-concept.md`, `design/gdd/hud-ui.md`,
`design/gdd/save-system.md`

**Requirements**: `TR-scene-004`, `TR-save-001`, `TR-save-006`,
`TR-hud-002`, `TR-hud-003`, `TR-hud-004`

**ADR Governing Implementation**: ADR-0001 input boundaries; ADR-0002 signal
communication; ADR-0003 data boundaries; ADR-0007 scene management; ADR-0010
presentation; ADR-0011 HUD/UI; ADR-0015 testing; ADR-0018 runtime integration;
ADR-0021 save integration.

Story148 deliberately ended at a hub-return acknowledgement. The current GDD
Tier 4 contract defines the degraded complete game as one hub, three areas,
three weapons and four Bosses. This Story adds the separately authored durable
ACT-complete payoff without inventing Boss5, credits or new narrative.

## Acceptance Criteria

- [x] Complete Boss4 defeat/reward/recall proof at `main / scrap_roost` starts
  one `2.5s` pending delay; incomplete proof does nothing.
- [x] The payoff uses a generated imported `1280x720` Scrap Roost backdrop and
  a focused ACT Complete panel with Continue Exploring and Return to Title.
- [x] Gameplay locks while the completion/title menu owns focus and unlocks
  after returning to exploration.
- [x] `four_boss_act_completion_seen` is set before one runtime autosave.
- [x] Seen saves never replay the payoff, and repeated sync/advance calls do
  not create duplicate autosaves.
- [x] Existing Rat King, Echo Guardian, Boss4 recall, HUD and scene-state
  behavior remain compatible.
- [x] Thin RED/GREEN, bounded related regression and Godot AI MCP 3.0.2 runtime
  acceptance pass with clean logs and a non-empty screenshot.

## Implementation Notes

- `MainScene` owns proof validation, delay, durable state and combined player
  input lock. `HUDManager` owns only the visual menu and action signals.
- The completion flag is written before `_trigger_runtime_autosave()` so a
  successful slot-0 save cannot replay the menu.
- Continue Exploring reuses the existing resume signal. Return to Title reuses
  the existing main-menu shell and keeps gameplay locked until that shell is
  left.
- No character or animation asset changed. The generated image is an opaque UI
  backdrop imported through the normal Godot asset pipeline.

## Test Evidence

- Initial RED: `reports/report_1846/results.xml`; the focused case failed on
  the missing Story168 API and presentation contract.
- Focused GREEN: `reports/report_1848/results.xml`, `3/3` passed.
- Final bounded related GREEN: `reports/report_1852/results.xml`, `29/29`
  passed across Story168, Story148 recall, sequential Boss handoff and HUD;
  exit code `0`. The existing GdUnit process-exit ObjectDB/resource cleanup
  messages remain after all cases pass.
- `reports/report_1849/results.xml` and `report_1850/results.xml` exposed a
  pre-existing stale title-load test: it expects same-main loads to use a scene
  request, while current `master` intentionally restores them in place. This
  Story does not touch that load-handoff implementation, so the stale suite is
  documented rather than folded into this bounded gate.
- Runtime evidence:
  `production/qa/evidence/crown-warden-four-boss-act-complete-2026-07-16.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
| --- | --- | --- |
| Complete proof and exact delay | Story168 focused test + MCP | PASS |
| One-shot persistence/autosave | Story168 focused test + MCP | PASS |
| Continue/title input lock | Story168 focused test + physical MCP Enter | PASS |
| Boss4 recall compatibility | Story148 related suite | PASS |
| Sequential Boss/HUD compatibility | Related suites | PASS |
| Generated visual and clean runtime | MCP run `r156712604-48` | PASS |

## Completion Notes

**Completed**: 2026-07-16

**Criteria**: 7/7 passing

**Deviation**: No fifth Boss, credits or new narrative was added. The payoff is
explicitly scoped to the GDD's degraded four-Boss Tier 4 completion contract.
