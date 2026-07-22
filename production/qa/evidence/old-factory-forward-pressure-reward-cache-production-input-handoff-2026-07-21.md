# QA Evidence: Old Factory Forward Pressure Reward Cache Production Input Handoff -- 2026-07-21

## Scope

Player Abilities Story192 connects Story071's existing forward-pressure reward
cache and Story072 audio feedback to the real Factory `interact` rising edge.
It also proves the claim cannot chain into Story073 or the optional service
lift while the original press remains held.

## TDD Evidence

- Canonical RED `reports/report_2140/results.xml` contained one test case and
  failed only the expected `claimed=true` assertion because the production
  nearest-reward candidates omitted Story071.
- Initial focused GREEN `reports/report_2141/results.xml` passed `1/1` after the
  single candidate addition.
- Related run `reports/report_2142/results.xml` passed the Story192/071/072/191/
  073/188 chain and failed only an existing service-lift route-label diagnostic.
  Isolated `report_2143` reproduced that failure. Source tracing showed
  diagnostics reading nonexistent `RouteLabel` while production writes
  `RouteHud/RouteLabel`; `report_2144` passed both lift cases after correction.
- Final related GREEN `reports/report_2145/results.xml` passed seven suites at
  `13/13`, with zero failures, errors, flaky cases, skips or orphans.
- The strengthened final focused run `reports/report_2146/results.xml` passed
  `1/1`, including the exact Story073 boundary, fresh-instance restore, held
  movement into lift range and release/re-press re-arming.
- Godot 4.7 ran `res://scenes/factory_route_transition_shell.tscn` for `180`
  fixed frames and exited `0`. The retained log is
  `reports/old_factory_forward_pressure_reward_cache_production_input_handoff_smoke.log`.
  It contains no project parse/script/load/invalid-call failure; four leaked
  ObjectDB instances and two retained resources are the established
  cleanup-only Factory terminal baseline.
- No full suite ran because the changed surface is one reward candidate and one
  adjacent diagnostics path.

## Runtime Contract

- Valid prestate is Story191 complete: Story070 activated/defeated, Story071
  unclaimed, all earlier reward caches claimed, Story073 inactive/undefeated,
  and service lift idle.
- The real input route remains `_process()` rising edge ->
  `handle_factory_interact_input()` -> nearest available reward cache. Existing
  distance arbitration and stable tie order are unchanged.
- Cache center is `(1340,310)` with a `96px` claim radius. The acceptance
  position `(1352,310)` is both inside that radius and exactly on Story073's
  later movement boundary.
- A first edge records `gears=20`, exact cache/source id and
  `Forward Pressure Cache Claimed +20 Gears`; claim availability then becomes
  false.
- The fresh claim requests one event `reward_cache_claimed`, cue
  `sfx_door_unlock`, priority `90`, with `stream_found=true` at `(1340,310)`.
- At the end of the claim frame Story073 is available but inactive. Enemy and
  hazard stay hidden/non-processing/non-contacting. The lift remains idle.
- Moving to the lift while the same press is held does nothing. A release and a
  fresh edge can activate the lift normally, proving both no-chain and re-arm.
- Restore keeps the cache claimed/non-claimable with audio request count `0`,
  guard available/inactive and lift idle.

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r97358912-8` (run token `8`).
- The disk Factory scene launched with `autosave=false`, helper `live`, no
  startup errors and no already-running reuse. MCP restored the valid
  Story191-complete state, released `interact`, disabled player physics for the
  deterministic probe and placed Cinderpaw at `(1352,310)`.
- Pre-input diagnostics reported Story071 visible/available/claimable with
  prompt `+20 Gears`, audio count `0`, Story073 unavailable/inactive and lift
  unactivated with no exit request.
- MCP delivered real `input_action(interact)`. The next sample reported cache
  claimed/non-claimable, exact `gears=20` payload/source and route feedback,
  local persistence true, and audio count `1`.
- Runtime AudioSystem reported `reward_cache_claimed -> sfx_door_unlock`,
  priority `90`, `stream_found=true`, position `(1340,310)` and exact cache,
  source, gears, feedback-role and scene metadata.
- Story073 became available but stayed inactive; enemy remained hidden and its
  processing disabled, while the vent stayed hidden and non-contacting.
- With `interact` still held, MCP moved Cinderpaw to the real lift center
  `(1122,362)`. After multiple natural frames the lift was activation-ready but
  still unactivated with no exit request; reward/audio count remained `1` and
  Story073 remained inactive.
- Input was released. Current-run game logs contained only the helper
  registration line, editor logs returned zero rows, and stopping playback
  restored editor readiness to `ready`.
- The accepted screenshot is a non-empty `1278x718` RGB PNG showing Cinderpaw,
  the existing Factory reward/lift art and the screen-space
  `Forward Pressure Cache Claimed +20 Gears` feedback. SHA-256:
  `4dbd29fd4ebabf65b344fde5533ed50270a5c69dda8fecf59309b5801fe5f582`.

## Asset Use

No image was generated. Existing imported and manifest-listed Cinderpaw,
Story071 cache, forward hatch, service lift and Factory environment assets were
sufficient. The cache remains a static interactive prop; character animation
contracts remain satisfied by existing `AnimatedSprite2D + SpriteFrames`
resources.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real `interact` claims Story071 through production arbitration | RED/GREEN; MCP run 8 | PASS |
| Exact reward, feedback and once-only audio | Focused/related; MCP payload/AudioSystem | PASS |
| Claim at `x=1352` does not activate Story073 in the same frame | Focused GREEN; MCP guard diagnostics | PASS |
| Held input cannot chain into lift; release re-arms | Focused GREEN; MCP held-at-lift sample | PASS |
| Scene-local restore does not replay reward/audio | Focused GREEN | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean and visible | Smoke; logs; screenshot | PASS |
