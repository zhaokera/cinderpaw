# QA Evidence: Old Factory Forward Pressure Counter-Ambush Production Movement Handoff -- 2026-07-21

## Scope

Player Abilities Story191 connects Story070's existing forward-pressure
counter-ambush to real Factory movement after Story190 crosses the pressure
traverse. It also makes the authored steam vent fair and functional: visible
during the 18-frame opening grace, contact-active afterward, and routed through
the shared Factory steam damage/cooldown path.

## TDD Evidence

- Initial integration RED `reports/report_2134/report_1/results.xml` captured missing
  production activation and visual-depth behavior. The test was then bounded so
  a missing activation could not cascade through downstream assertions.
- Hazard refinement RED `reports/report_2137/results.xml` contained three test
  cases and failed two intended assertions in the real-movement case: the vent
  was already contact-active during opening grace and no grace diagnostic
  existed. It had zero errors, flaky cases, skips and orphans.
- Final focused GREEN `reports/report_2138/results.xml` passed `3/3`, covering
  real movement, the exact inclusive boundary, opening safety, post-grace `8`
  damage and the `1.0` second cooldown.
- Final related GREEN `reports/report_2139/results.xml` passed `10/10` across
  Story191, Story070, Story190/069, Story071 reward cache and the following exit
  guard. Failures, errors, flaky cases, skips and orphans were all zero.
- Godot 4.7 loaded
  `res://scenes/factory_route_transition_shell.tscn` for `180` fixed frames and
  exited `0`. The retained log is
  `reports/old_factory_forward_pressure_counter_ambush_production_movement_handoff_smoke.log`;
  it contains no project parse, script, invalid-call/access, warning or error.
  Four ObjectDB instances and two retained resources remain the established
  Factory cleanup-only terminal baseline printed outside the retained log.
- No full suite ran because the changed surface is one bounded production
  handoff and its local hazard collision/damage path.

## Runtime Contract

- Valid prestate is Story190 complete: Story069 crossed, entity `2118`
  activated/defeated, counter-ambush inactive, Story071 unclaimed, exit guard
  inactive and the service lift idle.
- Production order remains Story069 activate/advance/complete, then Story070
  activation. The Story070 boundary is inclusive player global `x=1336`.
- Entity `2119` uses
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`;
  its six required gameplay animations each contain three frames.
- Activation starts both enemy opening pacing and a scene-local 18-frame vent
  safety counter. The vent is visible and its four-frame `active` animation is
  playing during this window, while monitoring, collision layer/mask and shape
  remain disabled.
- At grace `0`, the vent becomes contact-active. Its exact id is
  `old_factory_lower_deck_forward_pressure_counter_ambush`, damage is `8`, and
  per-target cooldown is `1.0` second.
- Active objective is `survive_forward_pressure_ambush` /
  `Survive Forward Pressure Ambush`. Enemy and steam render at effective
  `z=26`, above forward hatch `z=25` and lift `z=24`.
- Story071 reward cache remains unavailable, hidden, unclaimable and unclaimed;
  no reward audio request occurs. The exit guard remains unavailable/inactive
  and hidden. The lift remains available but unactivated, with no exit request.

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r95391117-5` (run token `5`).
- The custom disk scene launched with `autosave=false`, helper status `live`,
  `was_already_running=false` and no startup errors. MCP restored the valid
  Story190-complete local state and placed Cinderpaw at `(1335.9,456)` while
  paused.
- MCP delivered real `input_action(move_right)`. Production physics moved
  Cinderpaw to `(1337.5667,456)` and activated Story070 without calling its
  activation API.
- The immediate paused sample reported entity `2119` visible and processing
  with a target, exact six-state frame counts, `hazard_visible=true`,
  `hazard_grace_frames=6`, `hazard_active=false`, active steam playing, exact
  objective and HP `100`.
- After releasing input, zeroing velocity and resuming for `300ms`, the sample
  reported grace `0`, `hazard_active=true` and HP `92`. `last_hazard_damage`
  recorded damage/final damage `8`, type `steam`, target id `1` and the exact
  Story070 hazard id. Focused tests separately prove immediate retry rejection,
  rejection at `0.99s`, and acceptance at `1.0s`.
- Story071 and exit-guard diagnostics remained locked; service lift remained
  unactivated with no exit request. Enemy and steam effective depth were `26`,
  above hatch `25` and lift `24`.
- Current-run game logs contained only the helper registration line. Editor
  logs returned zero rows. Input was released and stopping playback restored
  editor readiness to `ready`.
- The accepted screenshot is a non-empty `1278x718`, 8-bit RGB PNG showing the
  screen-space objective, Cinderpaw, animated Spark Rat, active steam and the
  authored Old Factory environment. SHA-256:
  `6876a00b9070069d01b97d045a81e6499e3fdf6ae4943dde083fbfea3fe85876`.

## Asset Use

No new image was generated. Existing imported and manifest-listed Cinderpaw,
Factory Spark Rat, four-frame steam, hatch, lift and environment assets were
sufficient. Existing image-generation source records remain authoritative; no
player-visible placeholder rectangle or single-frame character was added.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real movement activates Story070 at inclusive `x=1336` | RED/GREEN; MCP run 5 | PASS |
| Opening steam is visible but non-contacting for 18 frames | Refinement RED/GREEN; MCP opening sample | PASS |
| Live steam deals `8` damage and honors `1.0s` cooldown | Focused GREEN; MCP HP/damage source | PASS |
| Entity animations, objective and depth are readable | Related GREEN; MCP diagnostics; screenshot | PASS |
| Story071, exit guard and lift do not advance early | Related GREEN; MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Smoke; final logs; screenshot | PASS |
