# QA Evidence: Old Factory Coil Aftershock Production Combat Reward Handoff -- 2026-07-21

## Scope

Player Abilities Story204 connects Story083/084 to production movement,
player-combat and interact input. It also closes the adjacent Story085
dual-enemy death-presentation regression discovered by the bounded downstream
check. No new assets, economy system or SaveSystem schema were introduced.

## TDD And Regression Evidence

- `reports/report_2222/results.xml`: canonical RED, `0/1`; the sole failure was
  the real interact claim because Story084 was missing from production
  nearest-cache arbitration.
- `reports/report_2223/results.xml`: focused GREEN, `1/1`.
- `reports/report_2224/results.xml`: initial bounded related, five suites `8/8`.
- `reports/report_2225/results.xml`: Story085 downstream check, `2/3`; the second
  defeat callback hid the first death presentation.
- `reports/report_2227/results.xml`: clean death-presentation RED with zero
  errors and two expected first-corpse visible/process failures.
- `reports/report_2228/results.xml`: Story085 focused GREEN, `3/3`.
- `reports/report_2229/results.xml`: final six-suite bounded related GREEN,
  `11/11`, zero failure/error/flaky/skip/orphan. Coverage includes Story204,
  Story083, Story084, Story202, Story192 and Story085.
- Factory `180`-frame headless smoke exited `0`; log:
  `reports/old_factory_coil_aftershock_production_combat_reward_handoff_smoke.log`.
  No project script, parse, invalid-call or resource-load error was found. The
  `4 ObjectDB / 2 resources` shutdown diagnostic matches the established Factory
  baseline.
- No full suite was run; verification remained bounded to the changed path.

## Production Contract

- Fresh real forward movement at/after `x=2144` activates entity `2128` with
  `24 HP`, `normal` hurtbox, target, process/physics, opening grace `8`, and HUD
  `Contain Coil Aftershock`.
- Canonical automation uses direct damage only for nonlethal `24 -> 12` setup.
  The lethal `12 -> 0` hit is a real `Input.attack` through
  Combat/Weapon/Collision with `cat_claw_light`.
- Defeat immediately persists clear, disables combat capability and keeps the
  three-frame `death` sprite visible/process. Story084 cache unlocks in the same
  handoff and does not wait for the corpse fade.
- Production `Input.interact` selects Story084 through nearest-cache
  arbitration, persists exactly one `gears=20` payload and exact feedback, and
  ignores held/repeated input after claim.
- Story085 becomes available but remains inactive. Service lift, scene exit and
  Story071 cache audio remain untouched.
- Story085 callbacks now synchronize only a surviving partner. Partial defeat
  keeps one death presentation and one live combatant; full clear keeps both
  deaths visible/process while physics, target and hurtbox stay disabled.
  Restored completed state still hides both.

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`.
- Accepted Story204 run `r126495992-46` (`run token 46`) launched the custom
  Factory scene with `autosave=false`. Real `move_right` activated entity
  `2128`; a direct nonlethal setup followed by real directional
  `Input.attack` produced target `2128`, hitbox `cat_claw_light`, damage `12`
  and HP `0`.
- In that death window entity `2128` was visible/process with animation
  `death`, while physics/target/hurtbox were disabled. Story084 cache was
  already visible/claimable with `+20 Gears`.
- Real `Input.interact` claimed the exact Story084 source once. State persisted
  claimed, held input did not duplicate, Story085 was available/inactive,
  Story071 audio count stayed `0`, and lift/exit remained inactive.
- The run returned non-empty RGB `1278x718` death/cache and claim-feedback
  screenshots. Game log contained only helper registration; editor log was
  empty; inputs were released and the game stopped cleanly.
- Accepted Story085 maintenance run `r127439409-49` (`run token 49`) confirmed
  first death visible/process with the survivor active, then both `death`
  animations visible/process after full clear. Both had physics/targets off and
  hurtbox `gone`; HUD was
  `Forward Pressure Aftershock Exit Skirmish Cleared`.
- The maintenance screenshot was non-empty RGB `1278x718`. Game log again
  contained only helper registration, editor log was empty, and editor state
  returned to ready. A prior diagnostic probe warning caused by the temporary
  variable name `ready` was cleared and excluded from the accepted run.

## Asset Use

No image generation was required. Existing registered image-generated assets
for Cinderpaw, Factory Coil Rat, Factory Spark Rat, the reward cache and Factory
environment were reused. No runtime asset or asset-governance file changed.

## Residual Risks

- The cache contract produces and persists the established `gears=20` reward
  payload but does not mutate a global wallet. Economy crediting should be
  implemented consistently for all Factory caches in a separate slice.
- Story085 still lacks a production real-movement/real-combat handoff test;
  Story204 only repairs its shared death-presentation behavior.
- The shared RatMinion death hold/fade and asset silhouette remain broader
  presentation concerns; this Story does not retime or redraw them.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Fresh real movement activates 2128 | Story204 canonical; MCP real movement | PASS |
| Real lethal attack clears Story083 | Story204 canonical; MCP real attack | PASS |
| Death presentation remains readable | Related GREEN; MCP runtime | PASS |
| Cache unlock is immediate | Story083/084 tests; MCP death window | PASS |
| Real interact claims once | Story204 canonical; MCP real interact | PASS |
| Story085 available but not auto-active | Canonical; MCP diagnostics | PASS |
| Story085 dual deaths remain visible/noncombat | Story085 GREEN; MCP runtime | PASS |
| Godot 4.7 / MCP 3.0.4 logs and screenshot | Smoke; accepted runs | PASS |
