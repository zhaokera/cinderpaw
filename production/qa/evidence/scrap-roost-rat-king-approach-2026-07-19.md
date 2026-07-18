# QA Evidence: Scrap Roost Rat King Approach -- 2026-07-19

## Scope

Scene Management Story018 adds the first bounded ACT encounter after the
three-room onboarding route. Story017 now enters a generated Scrap Roost gate
approach containing one existing Shadow Beast. Defeat opens the route to
`main/scrap_roost`, where the existing savepoint and Rat King Phase-I intro take
over. No new enemy family, reward, dialogue, tutorial UI or Boss tuning was
added.

## Automated Evidence

- Intentional RED `reports/report_1959/report_1/results.xml`: focused Story018
  failed `1/1` only because the new scene did not exist.
- `report_1960` was an import-boundary diagnostic: the generated runtime PNG had
  not yet been imported by Godot. A Godot 4.7 headless editor import resolved it.
- `report_1961` loaded the complete scene and exposed that the test stopped at
  `46.9979px`, about one pixel outside the real Cat Claw/Shadow Beast overlap.
- `reports/report_1962/report_1/results.xml` and `report_1963` measured the
  production attack geometry and narrowed only the test helper to `<=40px`;
  gameplay code and hitbox range were unchanged.
- Focused GREEN `reports/report_1964/report_1/results.xml`: Story018 passed
  `1/1` with zero errors, failures, flaky cases, skips or orphans.
- Related GREEN `reports/report_1965/report_1/results.xml`: Story015-018 and the
  Main Scrap Roost savepoint runtime passed `8/8` with zero assertion failures.
- Final route gate `reports/report_1966/report_1/results.xml`: Story015 title,
  Story016 movement/combat, Story017 real dodge and Story018 real attack clear
  passed `5/5` with zero errors, failures, flaky cases, skips or orphans; exit
  code was `0` and no teardown leak was reported.
- No full suite or duplicate smoke script was run.

## Asset Generation And Import

- Built-in image generation produced a retained opaque RGB `1672x941` Scrap
  Roost gate approach without player, foreground enemy, UI, text, collision
  guides or runtime seal effects.
- `sips` normalized the runtime plate to exact opaque RGB `1280x720`; Godot 4.7
  import completed successfully and generated the import sidecars.
- Exact prompt and processing record:
  `assets/environment/scrap_roost_rat_king_approach/source/scrap_roost_rat_king_approach_background_imagegen_20260719.md`.
- Runtime texture:
  `assets/environment/scrap_roost_rat_king_approach/scrap_roost_rat_king_approach_background_1280x720.png`.
- Shadow Beast animation reuses the existing image-generated SpriteFrames; no
  character frame was copied into or baked onto the background.

## Godot MCP Runtime Evidence

- Session `cinderpaw@af5f`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.2`; accepted run `r288970422-90` (token `90`).
- Custom-scene launch loaded `ScrapRoostRatKingApproach` with Background,
  production Player, Shadow Beast, HUD, CombatPresentation, locked ExitArea and
  separate gate seal. The runtime tree contained `65` nodes and no Rat King.
- Diagnostics reported `idle`, `patrol`, `attack_tell`, `attack`, `hurt` and
  `death` at three frames each. A live attack request entered `attack_tell` and
  the screenshot showed the separate signal-red outlined Shadow Beast.
- A real physical `J` key attack at `35px` spacing routed through the production
  combat chain and reduced Shadow Beast HP `30 -> 20`, with the three-frame
  `hurt` state visible in diagnostics. The remaining `20` HP was cleared through
  Story018's normal target damage boundary as a deterministic MCP probe; death
  set `enemy_defeated=true`, `exit_unlocked=true` and removed the red seal.
- MCP custom-scene mode bypasses TitleBootstrap's normal runtime-root setup, so
  the probe explicitly configured the current scene as SceneManager's runtime
  node before crossing the exit. Physical right movement then committed
  `main/scrap_roost` and instantiated runtime node `Main`.
- Main reported discovered savepoint `{id=scrap_roost, scene_id=main,
  spawn_point=scrap_roost, position=(210,432)}`. Rat King was visible in Phase
  I; its non-looping three-frame intro completed once, game flow was `playing`
  and player control was unlocked.
- Approach and Main screenshots were both non-empty at `1278x718`. Manual
  inspection showed the generated gate environment, separate animated actors,
  readable red tell, then the Scrap Roost savepoint and Rat King HUD without
  incoherent UI overlap. Gate unlock was verified through runtime diagnostics.
- Final game log contained only the MCP helper plus `enemy_stats` and
  `boss_configs` DataManager info lines. Editor log contained `0` rows. MCP stop
  restored editor readiness to `ready`.

## Discarded Probe Runs

- Tokens `85-89` were exploratory input/eval runs and are not acceptance
  evidence. They included timing drift while driving Story017, two malformed
  temporary `gdscript://` eval expressions and a custom-scene runtime-root
  polling mistake. No error referenced project source.
- Each paused run was stopped and its debugger/log state cleared. Token `90`
  repeated the bounded acceptance with valid one-line probes, fixed waits, clean
  logs and a clean stop.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Story017 enters registered approach before Rat King | Route GREEN; MCP runtime tree | PASS |
| Existing Shadow Beast exposes six readable three-frame states | Focused GREEN; MCP diagnostics/screenshot | PASS |
| Real attack damage defeats enemy and opens gate | Focused/final GREEN; MCP real hit plus damage-boundary probe | PASS |
| Exit commits Main at Scrap Roost savepoint | Related/final GREEN; MCP SceneManager runtime swap | PASS |
| Generated imported background, clean logs and visible runtime | Asset record; MCP run `90` | PASS |
