# QA Evidence: Old Factory Deep Bulkhead Guard Production Movement Handoff -- 2026-07-20

## Scope

Player Abilities Story186 connects the complete Story060 Deep Bulkhead Guard
to real Factory movement. It also fixes two live route defects found during
review: the closed gate blocked its own activation line before the encounter,
and the opened gate retained a stale prompt. Existing entity, combat, pacing,
persistence, service-lift and asset contracts remain authoritative.

## TDD Evidence

- Canonical RED `reports/report_2089/report_1/results.xml` ran one case and
  produced exactly one expected failure: production `_process()` left the
  guard inactive after the player crossed the authored boundary.
- After production wiring, `reports/report_2090/report_1/results.xml` exposed
  the next expected failure: guard `z=20` was not above bulkhead `z=24`.
- The expanded same-case RED `reports/report_2095/report_1/results.xml` proved
  that the inactive gate blocker was enabled before the player could reach
  `x=1252`.
- Story060 prompt RED `reports/report_2097/report_1/results.xml` proved the
  opened bulkhead still displayed its prompt.
- Story186 focused GREEN `reports/report_2096/report_1/results.xml` passed
  `1/1`; prompt GREEN `reports/report_2098/report_1/results.xml` passed `2/2`.
- Final related GREEN `reports/report_2099/report_1/results.xml` passed `9/9`
  across Story186, Story060, Story183, Story185 and Story059. Failures, errors,
  flaky cases, skips and orphans were all zero.
- Godot 4.7 loaded
  `res://scenes/factory_route_transition_shell.tscn` for `180` fixed frames and
  exited `0`. The retained log is
  `reports/old_factory_deep_bulkhead_guard_production_movement_handoff_smoke.log`;
  it contains no project parse, script, invalid-call/access, missing-resource
  or resource-load error. Only the established cleanup-time ObjectDB/resource
  notices appeared after exit.
- No full suite ran because the changed surface is one production handoff, one
  local blocker condition, one scene layer and a default-off endpoint option.

## Runtime Contract

- With Steam Sluice defeated, `x=1251` leaves entity `2114` inactive and
  invisible, with no target or processing. The visible bulkhead is nonblocking
  and the objective remains `Steam Sluice Cleared`.
- At inclusive boundary `x=1252`, production `_process()` activates entity
  `2114`, enables target/physics/process, starts the 18-frame opening grace and
  changes the objective to `Clear Deep Bulkhead Guard`.
- The blocker turns on only after guard activation. It remains on after defeat
  until the bulkhead opens, then turns off.
- Opening the bulkhead now hides its prompt through the instance-only
  `hide_prompt_when_activated=true` setting.
- The guard uses six three-frame animations. Its `z=26` layer is above both
  bulkhead and service lift at `z=24`; prompt children remain above combat.
- The service lift stays available, unactivated, has no exit request and
  reports `Call lift`.

## Godot MCP Runtime Evidence

- Session `cinderpaw@36ea`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r20325904-18` (run token `18`).
- The custom disk scene launched with `autosave=false`, helper status `live`
  and no launch error.
- The MCP fixture first advanced the scene's existing 18 return-checkpoint
  startup snap frames, then loaded the valid Steam-Sluice-cleared snapshot and
  placed Cinderpaw at `x=1210`. Pre-input diagnostics showed guard inactive,
  blocker disabled and objective `Steam Sluice Cleared`.
- MCP sent the production `move_right` action for `0.35s`. Cinderpaw reached
  `x=1253.33`; no guard activation API was called. Accepted diagnostics showed:
  - entity `2114` active, visible, targeted, physics/process enabled;
  - current pacing `attack_tell` after the opening grace, with inactive hit;
  - `idle/run/attack_tell/attack/hurt/death=3` frames;
  - blocker enabled only after activation;
  - objective `Clear Deep Bulkhead Guard`;
  - service lift available/not activated/no exit/`Call lift`;
  - player and guard at `z=26`, bulkhead at `z=24`.
- Current-run game logs contain only the Godot AI helper registration info.
  Editor logs contain zero rows. Stopping playback restored readiness to
  `ready`.
- Accepted screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-deep-bulkhead-guard-production-movement-handoff-20260720.png`.
  It is a non-empty RGB `1278x718` PNG, manually inspected to show
  `Clear Deep Bulkhead Guard`, Cinderpaw, the animated guard, service lift and
  closed bulkhead without the guard being hidden by endpoint art. SHA-256:
  `0a2b2eb5a5286e1da92b2a18fdbd2de3b88278826df8b60c401e46adf11dc1de`.

## Asset Use

- No new visual asset was generated because all required production art and
  animation already exist and are imported.
- Reused image-generated content includes the Factory Spark Rat SpriteFrames,
  Deep Bulkhead, Service Lift and Old Factory environment.
- No placeholder rectangle or static player-visible character was introduced.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real player input reaches and activates entity 2114 | MCP `1210 -> 1253.33`; production RED/GREEN | PASS |
| Gate cannot block its own activation boundary | Blocker RED/GREEN; MCP pre-input state | PASS |
| Target, pacing, objective and frames remain correct | Focused/related GREEN; MCP diagnostics | PASS |
| Guard remains visible over gate/lift art | Layer RED/GREEN; inspected screenshot | PASS |
| Opened gate hides its stale prompt | Story060 prompt RED/GREEN | PASS |
| Service lift remains optional and unchanged | Related GREEN; MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Run `r20325904-18`; logs; screenshot | PASS |
