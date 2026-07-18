# QA Evidence: New Game Scrap Roost Hunt Initiation -- 2026-07-19

## Scope

Scene Management Story016 changes only the New Game entry route. The title now
loads one bounded Scrap Roost initiation room where the player crosses a safe
movement/jump runway, defeats one existing Rat Minion and exits to Story017's
registered dodge trial. That room owns the later `main/default` Rat King
handoff. Continue and Load Slot keep their saved targets.

## Automated Evidence

- Intentional RED `reports/report_1945/results.xml`: the focused suite failed
  `1/1` only because the onboarding scene did not yet exist.
- `report_1946` was an intermediate implementation run. It exposed the expected
  unimported generated texture and insufficient successful attack attempts.
- `report_1947` was a bounded diagnostic run. It proved two early attacks were
  interrupted by the live Rat Minion hurt exchange; temporary diagnostics were
  removed and the acceptance attempt budget was adjusted without changing any
  production health, damage or timing value.
- Focused GREEN `reports/report_1948/results.xml`: Story016 passed `1/1` in about
  `6.6s` with zero failures, engine errors or orphans.
- Related GREEN `reports/report_1949/results.xml`: Story015 title bootstrap,
  physical-input player combo and Rat King Phase-I intro passed `5/5` with clean
  teardown.
- Post-review title-route `reports/report_1950/results.xml` passed `2/2` with no
  failures, errors or orphans. It confirms New Game uses the initiation scene
  while legacy saves without explicit scene metadata retain the `main/default`
  fallback.
- Current-route `reports/report_1958/results.xml` passed Story015-017 `4/4` with
  no failures, errors, flaky cases, skips or orphans. It confirms the initiation
  exit now targets `area_01_scrap_roost_dodge_trial/default`.
- No full suite or duplicate equivalent smoke script was run.

## Asset Generation And Import

- Built-in image generation produced a retained opaque `1672x941` Scrap Roost
  source without characters, enemies, UI, text or collision guides.
- `sips` normalized the runtime texture to exact `1280x720`; Godot 4.7 headless
  import completed successfully and generated the import sidecars.
- Exact prompt and processing record:
  `assets/environment/scrap_roost_hunt_initiation/source/scrap_roost_hunt_initiation_background_imagegen_20260719.md`.
- Runtime texture:
  `assets/environment/scrap_roost_hunt_initiation/scrap_roost_hunt_initiation_background_1280x720.png`.

## Godot MCP Runtime Evidence

- Session `cinderpaw@af5f`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.2`. Run `r281879257-82` (token `82`) is the isolated
  Story016 acceptance before Story017 was inserted; current full-route evidence
  is run `r284679113-84` (token `84`).
- The real title New Game button instantiated
  `/TitleBootstrap/RuntimeSceneRoot/ScrapRoostHuntInitiation`; runtime hierarchy
  contained Player, PracticeStep, imported Background, ExitGateBlocker, HUD,
  CombatPresentation and `OnboardingRat`, with no Rat King present.
- Physical input moved the player from `(150,456)` across the runway and reached
  jump apex `y=371.9429`. Enemy activation occurred after player `x=540.0322`.
- The live Rat Minion entered its run/tell behavior; its `attack_tell` resource
  reported three frames. A real dodge kept player HP `100 -> 100` through the
  incoming attack window.
- Real player attack input reduced enemy HP `24 -> 0`. The death animation,
  `enemy_defeated=true` and `exit_unlocked=true` were observed before the exit
  requested the Main handoff.
- In current run `84`, five real attack inputs completed the live Rat Minion
  defeat, unlocked the exit and committed the sole runtime child as
  `ScrapRoostDodgeTrial`. Completing Story017 then committed `Main`; Rat King was
  visible in Phase I, intro start/completion counts were both `1`, the
  non-looping intro had three frames over `0.75s`, and gameplay control was
  restored.
- The inline MCP screenshot was non-empty at `1278x718`. Manual inspection showed
  the generated industrial lane, separate AnimatedSprite2D Cinderpaw and Rat
  Minion, readable HUD and one background exit arch without a duplicate gate or
  overlapping UI.
- Final run `84` game log contained only the MCP helper plus `enemy_stats` and
  `boss_configs` DataManager info lines. Editor log contained `0` rows. MCP stop
  restored editor readiness to `ready`.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| New Game enters initiation before Rat King | Title regression; MCP runtime tree | PASS |
| Real movement and jump cross the safe runway | Focused GREEN; MCP physical input | PASS |
| One frame-animated ordinary enemy gates exit | Focused GREEN; MCP diagnostics | PASS |
| Real attack and dodge use production combat paths | Focused GREEN; MCP HP/runtime probes | PASS |
| Enemy defeat hands off to Story017, then Rat King Phase-I intro | Current-route GREEN; MCP async commits | PASS |
| Generated imported background, clean logs and visible runtime | Asset record; MCP runs `82` and `84` | PASS |
