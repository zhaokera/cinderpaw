# QA Evidence: Old Factory Lower Deck Skirmish Production-Input Handoff -- 2026-07-19

## Scope

Story177 connects the existing Story053 Lower Deck skirmish activation API to
the production Old Factory frame loop. The change is limited to one runtime
caller and one regression test; encounter content, art, combat, rewards,
persistence and service-lift behavior are unchanged.

## Automated Evidence

| Run | Scope | Result |
|-----|-------|--------|
| `reports/report_2029/results.xml` | Intentional RED, Lower Deck focused suite | The new production-path case produced seven expected assertion failures because `_process()` did not activate the authored encounter. |
| `reports/report_2032/results.xml` | Focused GREEN | `3/3` passed; `0` failures, `0` errors, `0` skipped and `0` flaky. |
| `reports/report_2033/results.xml` | Checkpoint overdrive duo + Story026 input priority + Lower Deck | `8/8` passed across three suites; `0` failures, `0` errors, `0` skipped and `0` flaky. |

No full suite was run. The bounded related set covers the prerequisite encounter,
the overlapping lift interaction changed immediately before this Story, and the
complete Story053 activation/reward/persistence contract.

## Production-Path Contract

- The test restores the real post-overdrive-clear local state and leaves the
  Lower Deck encounter inactive.
- It places the real Factory player one pixel past the existing diagnostic
  `activation_x`, invokes only the production `_process(0.0)` path, and never
  calls `try_activate_factory_lower_deck_skirmish()` directly.
- GREEN proves that the existing callee activates the actor, target, process,
  physics, pressure hazard and route objective while preserving the optional
  lift prompt.
- Existing Story053 tests continue to prove that the pre-overdrive state stays
  locked and that defeat, reward claim, duplicate rejection and local-state
  restoration remain intact.

## Godot MCP Runtime Evidence

- Session: `cinderpaw@af5f`; Godot `4.7-stable (official)`; Godot AI MCP
  `3.0.2`; accepted run `r356346134-118` (token `118`).
- The clean run was seeded after scene readiness with the overdrive duo cleared,
  Lower Deck inactive, Cinderpaw at approximately `(748, 450)`, and activation
  boundary `x=780`.
- A real `move_right` action held for `240ms` moved Cinderpaw to approximately
  `(795.9, 455.9)`. Immediate diagnostics then reported the Lower Deck active,
  entity `2108` visible and targeted with process/physics enabled, and the
  steam-pressure hazard active.
- Route diagnostics reported objective `clear_lower_deck_skirmish`, incomplete,
  with label `Clear Lower Deck Skirmish`. Service-lift diagnostics remained
  `Call lift`, `activated=false`, `exit_requested=false`; SceneManager had no
  pending load.
- The Spark Rat SpriteFrames diagnostics reported three frames for each of
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`.
- The inline MCP screenshot was non-empty at `1278x718` and visibly contained
  the generated Old Factory environment, Cinderpaw, the Lower Deck Spark Rat
  and the active hazard without a blank scene or blocking UI overlap.
- Final game logs contained only the MCP helper registration. Editor logs had
  `0` rows. `project_manage(stop)` succeeded and editor readiness returned to
  `ready` with the project no longer playing.

## Asset Pipeline

No visual asset was added or changed. Story177 reuses the image-generated Old
Factory environment and Story053's existing animated Factory Spark Rat and
reward-cache assets, so no image-generation prompt or manifest update applies.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real movement crosses the existing boundary and activates through production `_process()` | Intentional RED/GREEN; MCP real-input run | PASS |
| Existing prerequisite and persistence contract remains intact | Focused and related GREEN | PASS |
| Enemy, six animations, hazard and objective activate | Focused GREEN; MCP diagnostics | PASS |
| Lift stays optional and no scene transition is requested | Related GREEN; MCP diagnostics | PASS |
| Visible runtime, clean logs and editor recovery | MCP run `r356346134-118` | PASS |
