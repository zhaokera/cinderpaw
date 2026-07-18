# QA Evidence: Scrap Roost Dodge Trial -- 2026-07-19

## Scope

Scene Management Story017 completes the GDD's first three-room onboarding curve.
Story016's ordinary-enemy exit now enters a standalone Scrap Roost exhaust room;
only a real active-phase dodge unlocks its exit to Story018's registered Rat
King approach. Story018 then owns the existing `main/scrap_roost` flow. No
enemy, reward, savepoint or explicit tutorial UI was added here.

## Automated Evidence

- Intentional RED `reports/report_1951/results.xml`: focused Story017 failed
  `1/1` only because `scrap_roost_dodge_trial.tscn` did not yet exist.
- `report_1952` was an intermediate implementation run: the scene loaded, but
  the initial staging budget did not reach the authored dodge position.
- `report_1953` was a bounded diagnostic run. It measured player `x=526.667`
  after 120 frames, proving the issue was the test budget rather than production
  movement. Temporary diagnostics were removed.
- Initial focused GREEN `reports/report_1954/results.xml`: the successful real
  dodge path passed `1/1` with zero failures, engine errors or orphans.
- Post-review RED `reports/report_1956/results.xml`: the new no-dodge boundary
  did not reach the hazard before its 18-frame active window closed. Player run
  acceleration and authored geometry showed the test needed a closer safe
  staging point plus synchronization to a new active sequence; production logic
  was unchanged.
- Final focused GREEN `reports/report_1957/results.xml`: Story017 passed `1/1` in
  about `7.0s`; walking into a fresh active sequence applied `100 -> 92`, left
  the exit locked, and the next real dodge retained `92 -> 92` before unlocking.
- Final bounded related GREEN `reports/report_1958/results.xml`: Story015 title
  route, Story016 initiation and Story017 dodge trial passed `4/4` with zero
  failures, errors, flaky cases, skips or orphans.
- Current route regression `reports/report_1966/report_1/results.xml` passed
  Story015-018 `5/5`, including Story017's updated request to
  `area_01_scrap_roost_rat_king_approach/default`.
- No full suite or duplicate smoke script was run.

## Asset Generation And Import

- Built-in image generation (`gpt-image-2` path) produced a retained opaque
  `1672x941` Scrap Roost exhaust chamber without characters, enemies, UI, text,
  baked steam, collision guides or a closed exit leaf.
- `sips` normalized the runtime texture to exact opaque RGB `1280x720`; Godot
  4.7 import completed successfully and generated the import sidecars.
- Exact prompt and processing record:
  `assets/environment/scrap_roost_dodge_trial/source/scrap_roost_dodge_trial_background_imagegen_20260719.md`.
- Runtime texture:
  `assets/environment/scrap_roost_dodge_trial/scrap_roost_dodge_trial_background_1280x720.png`.
- Runtime steam reuses
  `assets/environment/old_factory_steam_vent/factory_steam_vent_sprite_frames.tres`;
  no replacement animation was generated.

## Godot MCP Runtime Evidence

- Session `cinderpaw@af5f`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.2`; accepted run `r284679113-84` (token `84`).
- The real title New Game button instantiated Story016. Physical input crossed
  its runway by `408.264px`, reached an `84px` jump rise, activated the Rat
  Minion, defeated it with five real attacks and committed
  `ScrapRoostDodgeTrial` through SceneManager.
- The Story017 runtime tree contained the imported Background, production
  Player `AnimatedSprite2D`, DodgeExhaust, HUD, CombatPresentation, locked exit
  and no Rat King. The player staged at `x=581.667` with full HP.
- During the live active phase, SteamAnimation reported `animation=active`,
  `playing=true`; `safe`, `warning` and `active` each reported four frames.
- Real `move_right + dodge` began left of the hazard at `x=585.000`, overlapped
  it at `x=625.223`, retained HP `100 -> 100`, matched active/dodge sequence
  `35`, set `dodge_overlap_confirmed=true`, changed the phase to `crossed` and
  unlocked the exit.
- At that revision, the asynchronous exit committed `Main`. Rat King was visible in Phase I;
  intro start/completion counts were both `1`, its non-looping three-frame intro
  lasted `0.75s`, game flow returned to `playing`, and player control unlocked.
- The inline screenshot was non-empty at `1278x718`. Manual inspection showed
  the generated chamber, separate animated Cinderpaw and active white steam
  plume, readable hazard spacing, open right route and HUD without overlap.
- Final game log contained only the MCP helper plus `enemy_stats` and
  `boss_configs` DataManager info lines. Editor log contained `0` rows. MCP stop
  restored editor readiness to `ready`.

## Discarded Instrumentation Run

- Run token `83` was invalidated after an MCP `game_eval` script exceeded the
  tool's eight-second execution limit. The temporary injected coroutine later
  lost its SceneTree and produced two `gdscript://` helper-script errors; no
  project source path was involved.
- The run was stopped, logs were cleared and the journey was repeated as bounded
  short input segments in token `84`. The accepted run stayed helper-live, had
  zero editor errors and stopped cleanly.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Story016 enters registered third room before Rat King | Related GREEN; MCP runtime tree | PASS |
| Existing four-frame steam animation telegraphs live phases | Focused GREEN; MCP animation diagnostics | PASS |
| Only real active-overlap dodge unlocks exit | Focused GREEN; MCP HP/sequence/overlap probes | PASS |
| Exit commits the registered Story018 approach | Current route GREEN; Story018 MCP target load | PASS |
| Generated imported background, clean logs and visible runtime | Asset record; MCP run `84` | PASS |
