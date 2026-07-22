# QA Evidence: Old Factory Lower Deck Progression Production-Input Handoff -- 2026-07-20

## Scope

Player Abilities Story183 connects the completed Story058-060 Lower Deck
progression endpoints to the real production `interact` rising edge. It changes
only input routing and deterministic candidate selection; existing endpoint,
combat, persistence, reward and service-lift contracts remain authoritative.

## TDD Evidence

- Intentional RED in the isolated implementation workstream exited `100` when
  real `Input.action_press("interact")` plus production `_process` did not open
  any Lower Deck progression endpoint.
- Focused integrating GREEN `reports/report_2077/results.xml` passed `2/2` with
  zero failures, errors, flaky cases, skips or orphans.
- Related GREEN `reports/report_2079/results.xml` passed six suites at `13/13`
  with all failure/error counters at zero: Story183 production handoff,
  pressure valve, steam sluice, deep bulkhead, Lower Deck reward cache and
  reward-before-service-lift priority.
- No full suite was run; the changed surface is the existing Factory production
  `interact` dispatcher and its bounded Lower Deck consumers.

## Runtime Contract

- `handle_factory_interact_input` keeps the established priority chain:
  Factory cache, deep-route endpoint, nearest available reward cache, nearest
  available Lower Deck progression endpoint, then service lift.
- Pressure valve and deep bulkhead retain their existing endpoint-owned range
  checks. Steam sluice retains Story059's one-way `x >= 1248` activation
  boundary rather than inventing a new radial contract.
- Candidate guards run before distance comparison. The nearest eligible target
  is invoked, while exact ties retain the authored valve-to-sluice-to-bulkhead
  order.
- The production `_process` rising-edge latch allows at most one call until
  `interact` is released; holding the action cannot cascade the route.
- Existing methods own all state changes, combat activation, objective refresh,
  persistence and presentation. The dispatcher does not duplicate them.

## Godot MCP Runtime Evidence

- Session `cinderpaw@36ea`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r13170960-9` (run token `9`).
- `res://scenes/factory_route_transition_shell.tscn` loaded from disk with
  helper status `live` and no launch errors. The runtime tree contained `894`
  nodes in the bounded query and explicitly exposed `Player`,
  `FactoryLowerDeckPressureValve`, `FactoryLowerDeckSteamSluiceHazard`,
  `FactoryLowerDeckDeepBulkhead`, their three guard enemies and
  `FactoryServiceLift`.
- A typed runtime probe moved the live player to `(1220, 400)` without eval or
  project-script error. Production input behavior itself is covered by the
  focused real-Input GdUnit test so the MCP run did not mutate progression
  state or persistence.
- Game logs contain only the Godot AI helper registration line. Editor logs
  contain zero rows. Stopping playback restored `readiness_after=ready`.
- Accepted screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-lower-deck-progression-interact-20260720.png`.
  It is a non-empty RGB `1278x718` PNG showing Cinderpaw in the live Old Factory
  production scene with authored environment, traversal geometry and enemy
  presentation. SHA-256:
  `8a8d56947634e4ad0bfd4bad940a9c48553110317200a95f2f8e7ecac2430a16`.

## Asset Use

- No new visual asset was needed. Story183 reconnects existing gameplay nodes
  and presentation. Story181 remains separately blocked on image2 connectivity
  for the pressure-valve authored animation.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real rising edges advance valve, sluice and bulkhead | Focused GREEN | PASS |
| Held input does not repeat and overlap chooses nearest once | Focused GREEN | PASS |
| Story058-060 contracts remain intact | Related GREEN | PASS |
| Rewards stay above progression and lift in priority | Related GREEN | PASS |
| Production Factory scene loads with all endpoint nodes | MCP runtime tree | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Run `r13170960-9`; logs; screenshot | PASS |
