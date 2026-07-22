# QA Evidence: Old Factory Breach Corridor Production Movement Handoff -- 2026-07-20

## Scope

Player Abilities Story185 connects the complete Story061 Breach Corridor
ambush to the real Factory production `_process()` path. Cinderpaw crossing the
authored `1256/1264` boundaries now starts the front guard and rear pincer in
order. A screenshot-driven follow-up raises the active combat presentation
above overlapping Lower Deck endpoint visuals without changing combat,
persistence, service-lift or asset contracts.

## TDD Evidence

- Canonical RED `reports/report_2083/report_1/results.xml` ran one case and
  produced exactly one expected failure: after Cinderpaw crossed `x=1256`,
  production `_process()` left `active=false`. Errors, flaky cases, skips and
  orphans were zero.
- Initial focused GREEN `reports/report_2084/report_1/results.xml` passed the
  production movement case `1/1` after the two existing activation APIs were
  connected in front-before-rear order.
- MCP visual inspection then showed true-visible breach nodes behind `z=24`
  endpoint art. Rendering RED `reports/report_2086/report_1/results.xml` ran
  two cases and recorded one expected layer failure (`Player z=20`, required
  greater than `24`).
- Final focused GREEN `reports/report_2087/report_1/results.xml` passed `2/2`.
- Final related GREEN `reports/report_2088/report_1/results.xml` passed `8/8`
  across Story185, Story061 Breach Corridor, Story060 deep-bulkhead gate and
  Story183 progression interact. Failures, errors, flaky cases, skips and
  orphans were all zero.
- Godot 4.7 loaded
  `res://scenes/factory_route_transition_shell.tscn` for `180` fixed frames and
  exited `0`. The retained log is
  `reports/old_factory_breach_corridor_production_movement_handoff_smoke.log`;
  it contains no project parse, script, invalid-call/access, missing-resource
  or resource-load error. The terminal emitted only the established
  cleanup-time ObjectDB/resource notices after exit.
- No full suite ran because the changed surface is the two Story061 production
  calls and four local scene layers.

## Runtime Contract

- `_process()` keeps the corridor inactive at `x=1255`.
- At `x=1257`, it activates front entity `2115`, assigns the player target,
  enables physics/process and the steam hazard, and refreshes the objective to
  `Clear Breach Corridor Ambush`.
- At `x=1265`, it activates rear entity `2116`, assigns the player target and
  refreshes the objective to `Survive Breach Pincer`.
- Front activation is called before rear activation each frame. This preserves
  the pincer when movement or dodge crosses the `8px` boundary gap in one
  frame.
- Existing Story061 defeat and local-state round-trip behavior remains owned
  by the original APIs and passed unchanged.
- Cinderpaw and both breach Spark Rats render at `z=26`; the breach steam root
  renders at `z=25`; deep bulkhead and service lift roots remain `z=24`; their
  endpoint prompt labels remain at effective `z=28`.

## Godot MCP Runtime Evidence

- Session `cinderpaw@36ea`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r17664088-14` (run token `14`).
- The custom disk scene launched with `autosave=false`, helper status `live`
  and no launch error. A straight-line typed probe loaded a valid
  post-bulkhead local snapshot, moved the real `Player`, and called only the
  production `_process()` path at `1255`, `1257` and `1265`; it did not call
  either breach activation API directly.
- Accepted diagnostics:
  - outside `active=false`;
  - front `active/visible/target/physics=true`, entity `2115`, objective
    `Clear Breach Corridor Ambush`;
  - rear `activated/visible/target/physics=true`, entity `2116`, objective
    `Survive Breach Pincer`;
  - both Spark Rats expose `idle/run/attack_tell/attack/hurt/death=3` frames;
  - steam is visible/active, playing `active` with `4` frames;
  - service lift is available, not activated, has no exit request and reports
    `Call lift`;
  - accepted layers are player/front/rear `26` and hazard root `25`.
- Current-run game logs contain only the Godot AI helper registration info.
  Editor logs contain zero rows. Stopping playback restored readiness to
  `ready`.
- Accepted screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-breach-corridor-production-movement-handoff-20260720.png`.
  It is a non-empty RGB `1278x718` PNG, manually inspected to show
  `Survive Breach Pincer`, Cinderpaw, both Spark Rats and active steam above
  the endpoint art. SHA-256:
  `8f2d6f5cfd8acc6a7ac0113d974abe086d039d3f3275ca3eb73385e7b5ca310d`.

## Asset Use

- No new visual asset was generated because the complete required presentation
  already exists and is imported.
- Reused image-generated content: the post-bulkhead background and Factory
  Spark Rat six-state SpriteFrames.
- Reused animated environment content: the Factory steam vent active/safe/
  warning SpriteFrames. No placeholder rectangle or static character was added.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real movement starts front and rear stages | RED/GREEN; MCP `1255/1257/1265` probe | PASS |
| Existing targets, hazard and objectives remain correct | Story061 related GREEN; MCP diagnostics | PASS |
| Combat presentation is not hidden behind endpoints | Layer RED/GREEN; inspected screenshot | PASS |
| Frame-animation rules remain satisfied | Story061 related GREEN; MCP frame counts | PASS |
| Service lift remains optional and unchanged | Story060/061 GREEN; MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Run `r17664088-14`; logs; screenshot | PASS |
