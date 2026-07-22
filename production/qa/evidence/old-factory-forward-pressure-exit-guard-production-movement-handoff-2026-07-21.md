# QA Evidence: Old Factory Forward Pressure Exit Guard Production Movement Handoff -- 2026-07-21

## Scope

Player Abilities Story193 connects Story073's authored exit guard to the full
production sequence: real Story071 cache claim at `x=1352`, held-input safety,
release and real forward movement into visible combat.

## TDD Evidence

- `reports/report_2147/results.xml`: canonical integration RED, `0/1`; real
  movement crossed `x=1352` but production did not activate entity `2120`.
- `reports/report_2148/results.xml`: initial focused GREEN for a restored
  cache-claimed state. Parallel QA then found this did not cover the real
  exact-boundary claim-to-movement sequence.
- `reports/report_2151/results.xml`: strengthened RED, `0/1`; real `interact`
  claimed at `x=1352`, held stationary input stayed safe, but subsequent real
  `move_right` still could not activate because the previous x equaled the
  boundary.
- `reports/report_2152/results.xml`: movement behavior reached GREEN and exposed
  one stale test-only audio-count expectation after the setup changed from
  restore to a real claim.
- `reports/report_2153/results.xml`: final focused GREEN, `1/1`.
- `reports/report_2154/results.xml`: final bounded related GREEN, five suites
  and `9/9`, zero failures, errors, flaky cases, skips or orphans. It covers
  Stories 191, 192, 073, 074 and 193.
- Godot 4.7 ran `res://scenes/factory_route_transition_shell.tscn` for `180`
  fixed frames and exited `0`. The retained log is
  `reports/old_factory_forward_pressure_exit_guard_production_movement_handoff_smoke.log`;
  its four leaked ObjectDB instances and two retained resources are the
  established Factory exit cleanup baseline.
- No full suite ran because the changed surface is one production movement
  handoff plus two scene z values.

## Runtime Contract

- `_process()` captures whether Story073 was available at frame start before
  handling the `interact` rising edge.
- A claim at `x=1352` therefore records the exact Story071 reward and audio but
  leaves Story073 available/inactive. Remaining stationary while the press is
  held does not activate the encounter.
- Production tracks previous player x. Activation requires rightward movement
  into or away from the inclusive `x=1352` boundary, so continuing right from
  the exact claim position works without permitting a stationary chain.
- Entity `2120` uses six existing three-frame Spark Rat animations and begins
  with 18-frame, idle, non-attacking enemy pacing.
- Story073's approved vent contract remains immediate: visible/contact-active,
  four-frame `active` steam, hazard id
  `old_factory_lower_deck_forward_pressure_exit_guard`, damage `8`, cooldown
  `1.0s`.
- Active objective is `clear_forward_pressure_exit_guard` /
  `Clear Forward Pressure Exit Guard`. Enemy and steam effective depth are
  `26`, above hatch `25` and lift `24`.
- Story074 relay remains unavailable, hidden, non-monitoring, collision-disabled
  and unactivated. Service lift remains unactivated with no exit request.

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r99624813-11` (run token `11`).
- The custom disk scene launched with `autosave=false`, helper `live`, no
  startup errors and no already-running reuse. Inputs were explicitly released
  before the probe.
- MCP restored the valid Story191-complete state, disabled player physics and
  placed Cinderpaw at `(1352,310)`. Pre-input diagnostics showed Story071
  claimable, Story073 unavailable/inactive, Story074 locked and lift idle.
- Real `input_action(interact)` claimed Story071 once. Diagnostics reported
  `gears=20`, exact cache/source and feedback, one
  `reward_cache_claimed -> sfx_door_unlock` request at `(1340,310)`, Story073
  available but inactive, and hidden/non-contacting enemy/vent while the action
  remained held.
- MCP released `interact`, placed Cinderpaw at `(1352,456)`, restored player
  physics and sent real `input_action(move_right)`. Production movement reached
  `(1388.6667,456)` and activated entity `2120` without calling its activation
  API.
- The active sample reported enemy visible/processing/targeted, all six
  animation counts `3`, opening pacing with attack inactive, visible/contacting
  steam on four-frame `active`, exact hazard values and exact HUD objective.
- Depth diagnostics were enemy `26`, steam effective `26`, hatch `25`, lift
  `24`. The screenshot visibly keeps Cinderpaw, Spark Rat and steam silhouettes
  readable without hatch/lift occlusion.
- Story074 relay stayed unavailable/hidden/non-monitoring/unactivated; lift
  stayed idle with no exit request.
- Current-run game logs contained only the helper registration line. Editor
  logs returned zero rows. Input was released and stop restored editor
  readiness to `ready`.
- Screenshot is a non-empty `1278x718`, 8-bit RGB PNG. SHA-256:
  `1f30ca675be9ef2037d2ec2180bd59f1a787cafaaabfcd0b1541e759bed4b4bf`.

## Asset Use

No image was generated. Existing imported and manifest-listed Cinderpaw,
Factory Spark Rat, four-frame steam, cache, hatch, lift and Factory environment
assets were sufficient. Existing image-generation source records remain
authoritative; no manifest or import-path change was required.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real claim at `x=1352` cannot chain while stationary | Strengthened RED/GREEN; MCP run 11 | PASS |
| Real forward movement from the same boundary activates Story073 | Focused/related; MCP run 11 | PASS |
| Entity animations, pacing, vent and HUD match Story073 | Related; MCP diagnostics | PASS |
| Combat renders above hatch/lift without incoherent overlap | Scene contract; MCP screenshot | PASS |
| Story074 relay and lift do not advance early | Related; MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Smoke; final logs; screenshot | PASS |
