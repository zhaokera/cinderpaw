# QA Evidence: Old Factory Relay-Forward Reward/Hatch Production-Input Handoff -- 2026-07-20

## Scope

Player Abilities Story188 connects Story066's existing relay-forward cache and
hatch to the Factory production interaction route. It also removes three stale
completed-endpoint prompts exposed by runtime visual review. Reward values,
hatch behavior, service-lift routing, persistence keys and assets are unchanged.

## TDD Evidence

- Canonical behavior RED `reports/report_2104/results.xml` ran one integrated
  case and failed for the intended missing production candidates. In the real
  three-way overlap, the cache stayed unclaimed and input fell through to the
  service lift.
- After input routing, focused `report_2107` passed `1/1` and related
  `report_2108` passed `11/11`.
- MCP visual inspection exposed stale prompts in sequence. `report_2109`
  isolated the completed breach-relay prompt; `report_2110` rejected an
  incorrect availability-only hypothesis; `report_2111` passed after prompt
  visibility also required an unactivated relay. `report_2113` and
  `report_2116` then isolated the pressure-valve and shortcut prompts.
- Final focused GREEN `reports/report_2117/results.xml` passed `1/1`.
- Final related GREEN `reports/report_2118/results.xml` passed `11/11` across
  Story188, Story066, Story179 nearest-cache arbitration, Story183 progression
  arbitration, Story187 movement and the overdrive cache/lift priority suite.
  Failures, errors, flaky cases, skips and orphans were all zero.
- Godot 4.7 loaded
  `res://scenes/factory_route_transition_shell.tscn` for `180` fixed frames and
  exited `0`. The retained log is
  `reports/old_factory_relay_forward_reward_hatch_production_input_handoff_smoke.log`;
  it contains no project parse, script, invalid-call/access or missing-resource
  error. Four ObjectDB instances and two retained resources match the existing
  Factory cleanup-only baseline.
- No full suite ran because the changed surface is one bounded production
  interaction handoff plus prompt visibility on three local endpoints.

## Runtime Contract

- The accepted overlap point `(1184,350)` is simultaneously inside the relay
  cache's `96px`, hatch's `112px` and service lift's `96px` ranges.
- First rising edge claims exactly `20` gears from
  `old_factory_lower_deck_relay_forward_cache`, reports
  `Relay Forward Cache Claimed +20 Gears`, and makes the hatch available without
  opening it or requesting a scene exit.
- Holding the same press for three additional production frames changes
  nothing. Release followed by a second rising edge opens the hatch, disables
  blocking collision and reports `Lower Deck Forward Hatch Opened`.
- Cache claimed and hatch opened persist through the existing local-state
  roundtrip. The post-relay enemy and steam hazard remain defeated/hidden.
- Completed breach relay, pressure valve and shortcut seal prompts remain
  hidden; the active hatch and optional lift prompts stay readable.

## Godot MCP Runtime Evidence

- Session `cinderpaw@36ea`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r26427122-28` (run token `28`).
- The custom disk scene launched cleanly with `autosave=false`, helper status
  `live`, `was_already_running=false` and no startup error. After the existing
  18 startup snap frames, a valid Story187-complete state was loaded while the
  Story066 cache and hatch remained unconsumed.
- The airborne overlap fixture disabled only Cinderpaw physics processing so
  gravity could not move it away before MCP delivered input. Production
  `_process()` and real `input_action(interact)` remained authoritative; no
  claim/open method was called directly.
- First-edge diagnostics confirmed the exact reward/source/feedback, unopened
  available hatch, all three range checks, no chain while held, hidden defeated
  encounter nodes, idle lift and empty pending scene.
- Second-edge diagnostics confirmed `opened=true`, `available=false`,
  `collision_blocking=false`, both local-state flags true, route feedback
  `Lower Deck Forward Hatch Opened`, idle lift and empty pending scene.
- Current-run game logs contain only the Godot AI helper registration info.
  Editor logs contain zero rows. Final input state was released and stopping
  playback restored editor readiness to `ready`.
- Accepted cache screenshot is a non-empty `1278x718` PNG showing Cinderpaw,
  the claimed cache, `Open forward hatch`, `Call lift` and no stale endpoint
  prompt. SHA-256:
  `5ea884f35732026ee282ab6faee524cacee143f780c21fd636f2847ef3f90e16`.
- Accepted hatch screenshot is a non-empty `1278x718` PNG showing Cinderpaw,
  `Hatch open`, `Call lift`, the opened-route feedback and no defeated enemy or
  stale endpoint prompt. SHA-256:
  `106f761950ac748b21e56e64f2f327d438069bad5db98e2966748de7217a0ac6`.

### Rejected Diagnostic Runs

- Run token `24` was rejected because gravity moved the airborne overlap
  fixture out of cache range before input delivery. Tokens `25-27` proved the
  interaction flow but were rejected after screenshots exposed the completed
  relay, pressure-valve and shortcut prompts in sequence. Those visual findings
  drove the focused RED/GREEN fixes before clean run token `28`; none was a
  project parse, scene-load or runtime-script error.

## Asset Use

No new image was generated. Existing imported and manifest-listed Cinderpaw,
reward cache, hatch, relay, service lift and Factory environment art were
reused. No player-visible placeholder rectangle or single-frame character was
introduced.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| First real input claims the nearest cache with exact reward | RED/GREEN; MCP run 28 | PASS |
| Held input cannot chain into hatch or lift | Focused test; MCP held frames | PASS |
| Second rising edge opens only the hatch | Related GREEN; MCP diagnostics | PASS |
| Collision and local-state persistence remain correct | Story066 + Story188 tests | PASS |
| Completed endpoint prompts do not obscure the active prompt | Visual RED/GREEN; screenshots | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Smoke; logs; two screenshots | PASS |
