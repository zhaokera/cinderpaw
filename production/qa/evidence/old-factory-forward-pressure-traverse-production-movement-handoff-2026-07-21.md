# QA Evidence: Old Factory Forward Pressure Traverse Production Movement Handoff -- 2026-07-21

## Scope

Player Abilities Story190 connects Story069's existing forward-pressure
traversal to real Factory movement after Story189 secures the conduit. It also
raises the target steam presentation above nearby hatch/lift art. Story070,
hazard balance, persistence keys, optional lift routing, audio and assets are
unchanged.

## TDD Evidence

- Canonical RED `reports/report_2131/results.xml` ran one integrated case with
  real `move_right`. It failed 14 assertions because production movement
  crossed `x=1284` and `x=1328` while Story069 stayed idle, elapsed time stayed
  zero, the crossed flag was not persisted, and target steam effective `z=19`
  remained below hatch `z=25` and lift `z=24`.
- Final focused GREEN `reports/report_2132/results.xml` passed `1/1`.
- Final related GREEN `reports/report_2133/results.xml` passed `8/8` across
  Story190, Story069 traversal, Story189 forward conduit, Story068 clear
  feedback and Story070 counter-ambush. Failures, errors, flaky cases, skips
  and orphans were all zero.
- Godot 4.7 loaded
  `res://scenes/factory_route_transition_shell.tscn` for `180` fixed frames and
  exited `0`. The retained log is
  `reports/old_factory_forward_pressure_traverse_production_movement_handoff_smoke.log`;
  it contains no project parse, script, invalid-call/access, warning or error.
  Four ObjectDB instances and two retained resources remain the established
  Factory cleanup-only terminal baseline printed outside the retained log.
- No full suite ran because the changed surface is one bounded production
  movement handoff and one local visual-depth correction.

## Runtime Contract

- Valid prestate is Story189 complete: forward hatch opened, entity `2118`
  activated and defeated, traversal not crossed, Story070 inactive and lift
  idle. Upstream optional reward caches are marked claimed so stale prompts do
  not contaminate visual acceptance.
- Production order is forward conduit, then Story069 activate, advance by
  delta, and complete. Story070 remains outside this Story's production wiring.
- Traversal activates at inclusive player global `x=1284` and completes at
  inclusive `x=1328`; tests and MCP do not call either transition API directly.
- Phase contract is grace `[0,0.25)`, warning `[0.25,0.60)`, active
  `[0.60,1.00)`, safe `[1.00,1.45)`, then warning/active/safe repeat every
  `1.20` seconds.
- Steam hazard contract remains id
  `old_factory_lower_deck_forward_pressure_traverse`, damage `8`, cooldown
  `1.0`. Safe, warning and active each contain four frames.
- Steam renders at effective `z=26`, above hatch `z=25` and lift `z=24`.
- Active objective is `cross_forward_pressure_leak` /
  `Cross Forward Pressure Leak`; crossed objective is
  `forward_pressure_traverse_crossed` /
  `Forward Pressure Traverse Crossed`.
- After completion, the vent is hidden, non-monitoring and stopped. Story070
  is available but inactive/hidden, Story068 feedback remains unplayed, and
  the lift remains available but unactivated with prompt `Call lift`.

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r92604283-1` (run token `1`).
- The custom disk scene launched with `autosave=false`, helper status `live`,
  `was_already_running=false` and no startup error. MCP restored the valid
  Story189-complete local state and paused the tree before input delivery.
- MCP delivered real `input_action(move_right)` from `(1248,456)`. Production
  physics crossed the activation boundary at `(1284.6667,456)` and captured
  `active=true`, phase `grace`, elapsed `0.0167`, safe animation playing and
  the exact active objective. No activation API was invoked.
- Movement physics was frozen after activation while production `_process`
  continued. Diagnostics reached warning at elapsed `0.2667` and active at
  elapsed `0.6083`; active hazard monitoring/monitorability and collision were
  enabled, active animation was playing with four frames, and effective depth
  was `26`.
- A second real `move_right` press completed the traversal at
  `(1328.0002,456)` before Story070's `x=1336` activation boundary. The crossed
  flag persisted, vent contact/visibility/playback stopped, exact crossed
  objective appeared, and Story070 remained inactive with enemy/hazard hidden.
- Story068 feedback remained `played=false`, `visible=false`, `spawn_count=0`.
  The lift remained unactivated, no scene exit was requested, and its prompt
  remained `Call lift`.
- Input state was released. Current-run game logs contained only the game
  helper registration line, editor logs returned zero rows, and stopping
  playback restored editor readiness to `ready`.
- Both accepted screenshots are non-empty `1278x718` RGB PNGs showing
  Cinderpaw, the target pressure vent, screen-space objective and authored Old
  Factory environment:
  - warning SHA-256
    `16134defc5220cd255b0908ce6771fac5d8737ba6d391eae920f9bc5f25c99d5`
  - active SHA-256
    `dbae9390733d0e67b28c5755ab88bb3646a6ef9cd9b5952fa309cd803e07143f`

## Asset Use

No new image was generated. Existing imported and manifest-listed Cinderpaw,
four-frame steam, hatch, lift and Factory environment art were sufficient.
The steam resource remains
`assets/environment/old_factory_steam_vent/factory_steam_vent_sprite_frames.tres`;
its image-generation prompt and source remain recorded under the existing
asset pipeline. No player-visible placeholder rectangle or single-frame
character was added.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real movement activates Story069 at `x=1284` | RED/GREEN; MCP run 1 | PASS |
| Production delta advances the authored pressure phases | Focused/related GREEN; MCP timing | PASS |
| Steam animation, hazard and depth contracts remain exact | Related GREEN; MCP diagnostics; screenshots | PASS |
| Real movement completes and persists at `x=1328` | RED/GREEN; MCP run 1 | PASS |
| Story070/lift/clear-feedback boundaries remain unchanged | Related GREEN; MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Smoke; final logs; screenshots | PASS |
