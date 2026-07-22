# QA Evidence: Old Factory Post-Relay Production Movement Handoff -- 2026-07-20

## Scope

Player Abilities Story187 connects the complete Story065 relay-forward combat
trial to real Factory movement. The change is intentionally bounded to one
production activation call and the two combat presentation layers. Existing
entity, pacing, hazard, objective, reward/hatch, lift, persistence and asset
contracts remain authoritative.

## TDD Evidence

- Canonical RED `reports/report_2100/report_1/results.xml` ran one case and
  produced exactly one expected failure: production `_process()` left the
  post-relay trial inactive at the authored boundary.
- After production wiring, `reports/report_2101/report_1/results.xml` proved the
  behavior was active and exposed exactly four expected layer failures: the
  Spark Rat at `z=20` and steam-hazard root at `z=18` were not above the relay
  and service lift at `z=24`.
- Focused GREEN `reports/report_2102/report_1/results.xml` passed `1/1` with
  zero failures, errors, flaky cases, skips or orphans.
- Final related GREEN `reports/report_2103/results.xml` passed `11/11` across
  Story187, Story065 combat feedback, Story066 reward/hatch, breach-relay
  feedback and Story185 breach movement. Failures, errors, flaky cases, skips
  and orphans were all zero.
- Godot 4.7 loaded
  `res://scenes/factory_route_transition_shell.tscn` for `180` fixed frames and
  exited `0`. The retained log is
  `reports/old_factory_post_relay_production_movement_handoff_smoke.log`; it
  contains no project parse, script, invalid-call/access, missing-resource or
  resource-load error. Four ObjectDB instances and two resources reported at
  process teardown match the established Old Factory cleanup-only baseline.
- No full suite ran because the changed surface is one bounded production
  handoff and two scene layers.

## Runtime Contract

- With the breach relay secured, `x=1231` leaves the trial, entity `2117` and
  steam hazard inactive. The objective remains `Lower Deck Relay Secured`.
- At inclusive boundary `x=1232`, production `_process()` activates entity
  `2117`, enables target/physics/process, starts the 18-frame opening grace and
  changes the objective to `Clear Relay Forward Trial`.
- The Spark Rat retains six three-frame animations. The active dynamic steam
  animation retains four frames, hazard ID
  `old_factory_lower_deck_post_relay_trial`, `8` damage and `1.0s` cooldown.
- Activation remains latched if enemy collision pushes the player back below
  the boundary. The enemy body prevents walking through the encounter and
  still permits attack or retreat.
- Story066 reward cache and forward hatch remain hidden, unavailable and
  locked until the trial is cleared. The service lift remains available,
  unactivated, without an exit request and reports `Call lift`.
- Cinderpaw and the Spark Rat use `z=26`; the hazard root uses `z=25` with a
  runtime steam child at `z=1`; relay and lift art use `z=24`.

## Godot MCP Runtime Evidence

- Session `cinderpaw@36ea`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r22399497-22` (run token `22`).
- The custom disk scene launched cleanly with `autosave=false`, helper status
  `live`, `was_already_running=false` and no launch error.
- After advancing the existing 18 return-checkpoint startup snap frames, the
  fixture loaded a valid breach-relay-secured snapshot and placed Cinderpaw at
  `x=1218`, `y=456`, `HP=100`. Pre-input diagnostics showed trial/entity/hazard
  inactive, objective `Lower Deck Relay Secured`, reward/hatch hidden and lift
  available with `Call lift`.
- MCP sent only the production `move_right` action, first for `0.24s`; no
  post-relay activation API was called. The trial activated, the authored steam
  contact immediately changed HP from `100` to `92`, and entity collision
  pushed Cinderpaw back below the boundary while the activation remained
  latched. Further real movement confirmed the enemy as a physical combat
  gate; a final real `move_left` action separated the actors for inspection.
- Accepted diagnostics showed entity `2117` active, visible, targeted and
  physics/process enabled; `run` playing; all six animation states at three
  frames; opening grace total `18`; hazard active/visible with the expected ID,
  damage and cooldown; root-child `SteamAnimation` playing its four-frame
  active animation; objective `Clear Relay Forward Trial`; Story066 content
  locked; and the lift unchanged. Final player HP remained nonfatal at `75`.
- Current-run game logs contain only the Godot AI helper registration info.
  Editor logs contain zero rows. Stopping playback restored readiness to
  `ready`.
- Accepted screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-post-relay-production-movement-handoff-20260720.png`.
  It is a non-empty RGB `1278x718` PNG, manually inspected to show the clear
  objective, Cinderpaw, animated Spark Rat, active steam columns, Repair
  Savepoint/Relay and `Call lift`, with Story066 reward/hatch hidden. SHA-256:
  `993ea5975bec1c4c6d3cee7ac73e9a7dcfbb3f9a12a2f69c9a9e6e90d468a012`.

### Rejected Diagnostic Runs

- The first launch reported `was_already_running=true`; it was stopped and not
  accepted as Story187 evidence.
- Run token `21` was discarded after two probe-only node-path assumptions
  produced editor evaluation errors. Inspection established that the dynamic
  node is the hazard-root child `SteamAnimation` and that the relay node is
  `FactoryLowerDeckBreachRelaySavepoint`. Playback and logs were reset before
  clean run token `22`; neither error was a project scene or script failure.

## Asset Use

- No new visual asset was generated because all required production art and
  animation already exist, are imported and are recorded in the asset
  manifest.
- Reused image-generated content includes the Factory Spark Rat SpriteFrames,
  Old Factory steam-vent SpriteFrames, service lift, relay and environment.
- No placeholder rectangle or static player-visible character was introduced.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real movement reaches the inclusive boundary and activates entity 2117 | Production RED/GREEN; clean MCP real input | PASS |
| Target, pacing, frame animation and objective remain correct | Focused/related GREEN; MCP diagnostics | PASS |
| Steam hazard is active, animated and uses authored contact behavior | Related GREEN; MCP HP `100 -> 92`; screenshot | PASS |
| Enemy collision forms a combat gate without clearing activation | MCP real movement and retreat diagnostics | PASS |
| Reward/hatch stay locked and lift stays optional | Related GREEN; MCP diagnostics | PASS |
| Actors and steam remain visible above relay/lift art | Layer RED/GREEN; inspected screenshot | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Run `r22399497-22`; logs; screenshot | PASS |
