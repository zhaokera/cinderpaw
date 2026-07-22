# QA Evidence: Old Factory Forward Conduit Production Movement Handoff -- 2026-07-20

## Scope

Player Abilities Story189 connects Story067's existing forward-conduit ambush
to real Factory movement after Story188 opens the hatch. Runtime visual review
also moves the route objective into screen space and suppresses completed
prompts that obscured combat. Encounter balance, persistence keys, clear
feedback, service-lift routing and assets are unchanged.

## TDD Evidence

- Canonical behavior RED `reports/report_2124/report_1/results.xml` ran one
  integrated case. Real `move_right` crossed inclusive `x=1272`, but entity
  `2118` stayed inactive because production `_process()` did not call the
  Story067 API.
- `report_2120` exposed four enemy/hazard depth failures. `report_2121`
  narrowed the remaining assertion to the steam child's effective depth.
- MCP screenshot review exposed stale upstream prompts and an off-screen world
  `RouteLabel`. The corrected Story188 fixture removed the two cache prompts;
  `report_2128` then failed only for completed deep-route/hatch prompts and the
  missing screen-space route HUD.
- Final focused GREEN `reports/report_2129/results.xml` passed `1/1`.
- Final related GREEN `reports/report_2130/results.xml` passed `9/9` across
  Story189, Story067 activation/persistence, Story068 clear feedback, Story188
  input, Story187 movement and Story069 pressure traversal. Failures, errors,
  flaky cases, skips and orphans were all zero.
- Godot 4.7 loaded
  `res://scenes/factory_route_transition_shell.tscn` for `180` fixed frames and
  exited `0`. The retained log is
  `reports/old_factory_forward_conduit_production_movement_handoff_smoke.log`;
  it contains no project parse, script, invalid-call/access or missing-resource
  error. Four ObjectDB instances and two retained resources remain the existing
  Factory cleanup-only terminal baseline.
- No full suite ran because the changed surface is one bounded production
  movement handoff plus local route-prompt/HUD readability.

## Runtime Contract

- Valid prestate is Story188 complete: post-relay trial defeated, relay cache
  claimed, hatch open/non-blocking, conduit inactive and lift idle.
- Production order is post-relay trial, forward conduit, then later forward
  pressure content. The conduit activates at inclusive player global
  `x=1272`; tests and MCP do not call its activation API directly.
- Entity `2118` receives Cinderpaw as target, exposes six three-frame
  animations and starts with an opening grace total of `18`.
- Steam hazard contract remains id
  `old_factory_lower_deck_forward_conduit`, damage `8`, cooldown `1.0`; its
  four-frame `SteamAnimation` is visible and playing while active.
- Enemy and steam use effective `z=26`, above hatch `z=25` and lift `z=24`.
- Story068 feedback remains `played=false`, `visible=false`, `spawn_count=0`;
  Story069 traversal remains gated until conduit defeat.
- Objective is `clear_forward_conduit_ambush` / `Clear Forward Conduit Ambush`.
  `RouteHud/RouteLabel` is fixed at screen rect `(24,24,436,32)`. Claimed cache,
  completed deep-route and opened-hatch prompts are hidden during combat.

## Godot MCP Runtime Evidence

- Session `cinderpaw@36ea`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r29082530-31` (run token `31`).
- The custom disk scene launched with `autosave=false`, helper status `live`,
  `was_already_running=false` and no startup error. A valid Story188-complete
  local state was restored with all upstream reward caches claimed.
- MCP delivered real `input_action(move_right)` from `(1236,456)`. Production
  movement crossed `x=1272` and diagnostics captured `active=true`, target
  present, and enemy process/physics enabled before physics was frozen solely
  to stabilize the accepted screenshot. No activation API was invoked.
- Active-state diagnostics confirmed entity `2118`, six animations at three
  frames each, exact hazard values, active/visible four-frame steam, unchanged
  idle lift, opened non-blocking hatch, unplayed Story068 feedback and exact
  objective/HUD text.
- The first editor-log read contained one warning from the MCP probe variable
  name `ready`, which shadowed Node's signal inside the transient eval script.
  It did not originate in project code. The probe was corrected, debugger rows
  were cleared, the acceptance state was rechecked, editor logs returned zero
  rows and current-run game logs contained only helper registration info.
- Input was released and stopping playback restored editor readiness to
  `ready`.
- Accepted screenshot is a non-empty `1278x718` PNG showing the screen-space
  objective, Cinderpaw, animated Spark Rat, active steam, opened hatch and
  unchanged optional lift, without the stale cache/deep-route/hatch prompts.
  SHA-256:
  `8fb26f25fcc3827e66fd3ddb69ea677a524426451a3d14c95c07b1eba786ee9e`.

### Rejected Diagnostic Runs

- Run token `29` was rejected because an overly long capture delay let combat
  advance through death/reset before the screenshot. Token `30` proved real
  activation but its screenshot exposed two fixture-only unclaimed cache
  prompts, the completed deep-route/hatch prompts and the off-screen objective.
  Those findings drove the final visual RED/GREEN before clean run token `31`.

## Asset Use

No new image was generated. Existing imported and manifest-listed Cinderpaw,
Factory Spark Rat, steam, hatch, lift and Factory environment art were reused.
No player-visible placeholder rectangle or single-frame character was added.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real movement activates Story067 at `x=1272` | RED/GREEN; MCP run 31 | PASS |
| Entity, animation and hazard contracts remain exact | Related GREEN; MCP diagnostics | PASS |
| Combat renders above hatch/lift | Layer RED/GREEN; screenshot | PASS |
| Active objective stays on screen and stale prompts hide | Visual RED/GREEN; screenshot | PASS |
| Hatch/lift/clear-feedback boundaries remain unchanged | Related GREEN; MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Smoke; final logs; screenshot | PASS |
