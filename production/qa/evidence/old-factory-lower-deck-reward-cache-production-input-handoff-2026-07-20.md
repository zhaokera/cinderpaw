# QA Evidence: Old Factory Lower Deck Reward Cache Production-Input Handoff -- 2026-07-20

## Scope

Player Abilities Story179 connects the existing Lower Deck reward cache to the
Factory production `interact` path. It adds nearest-cache arbitration because
two independently claimable rewards have overlapping interaction ranges. Reward
data, persistence ownership, scene content and visuals remain unchanged.

## TDD Evidence

- Intentional RED `reports/report_2051/results.xml`: the Lower Deck suite ran
  four tests and the new case produced `9` expected failures. Fixed interaction
  priority claimed the Return Patrol reward, left the Lower Deck state false,
  showed the wrong feedback and kept the Parry gate unavailable and hidden.
- Focused GREEN `reports/report_2052/results.xml`: the Lower Deck suite passed
  `4/4`, with zero failures, errors, flaky cases, skips or orphans and exit code
  `0`.
- Related GREEN `reports/report_2053/results.xml`: four suites passed `8/8`,
  with zero failures, errors, flaky cases, skips or orphans and exit code `0`:
  `old_factory_lower_deck_skirmish_cache_test.gd`,
  `old_factory_overdrive_cache_input_priority_test.gd`,
  `old_factory_return_loop_real_input_test.gd`, and
  `old_factory_lower_deck_exit_ambush_test.gd`.
- A Godot 4.7 Factory headless smoke ran `180` frames and exited `0`. Startup and
  gameplay contained no project error. Shutdown reported four leaked ObjectDB
  instances and two resources still in use; these were cleanup diagnostics, not
  parse, script, invalid-call or missing-resource failures.
- No full suite was run; the changed surface is one Factory interaction router
  plus its focused overlap regression.

## Runtime Contract

- Initial Factory cache and deep-route endpoint retain their existing priority.
- The Lower Deck, Return Patrol and checkpoint Overdrive caches form the bounded
  late-route candidate set.
- Candidates must be available and have Cinderpaw inside their own reward range.
  The smallest global-position distance wins; only that cache's existing claim
  method executes.
- At the Lower Deck position, its distance is `0px`; the still-claimable Return
  Patrol cache is `84px` away and therefore remains untouched.
- A successful Lower Deck claim grants `10` gears, writes
  `factory_lower_deck_reward_cache_claimed=true`, shows exact claim feedback and
  makes the authored Parry gate available, visible and collision-blocking.
- The service lift is considered only after no progression cache accepts input.

## Godot MCP Runtime Evidence

- Session `cinderpaw@caa9`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.2`; accepted runs `r135737-1` and `r435019-2`.
- Both Return Patrol and Lower Deck caches were restored as defeated,
  independently claimable and unclaimed. Real MCP `interact` press/release was
  sent through the running game rather than calling a reward method.
- Run `r135737-1`, with Cinderpaw directly on the Lower Deck cache, observed:
  Lower Deck claimed; `gears=10`; source `old_factory_lower_deck_cache`; exact
  feedback; Return Patrol still unclaimed; Parry gate available, visible and
  blocking; service lift idle with no pending exit; persisted flag true.
- Run `r435019-2` repeated the contract from `90px` inside the Lower Deck range
  to capture the full feedback and gate in one frame. Input returned to released,
  game logs contained only MCP helper info, editor logs were empty, and stopping
  restored editor readiness.
- The accepted screenshot is opaque RGB `1278x718`, non-empty, and visibly
  contains `Lower Deck Cache Claimed +10 Gears`, `Parry the laser`, the still
  available Return Patrol reward and the idle service lift:
  `reports/visual/cinderpaw-mcp-old-factory-lower-deck-reward-input-20260720.png`.

## Infrastructure Interruption

- The previous editor session `cinderpaw@af5f` disappeared while an initial MCP
  probe was between input press and release. No Godot crash report, project parse
  error or runtime script error was present; the editor and port `8000` process
  had both terminated.
- Godot 4.7 was restarted on the same project, MCP session `cinderpaw@caa9`
  reported ready with plugin/server `3.0.2`, and both accepted runs repeated the
  complete contract cleanly. Evidence from the interrupted probe was discarded.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real rising-edge input claims Lower Deck cache | RED/GREEN; MCP runs `1`/`2` | PASS |
| Nearest overlapping reward wins | Focused/related GREEN; MCP state | PASS |
| Reward, feedback and persistence are exact | Focused GREEN; MCP diagnostics | PASS |
| Return cache remains unclaimed | Focused GREEN; MCP diagnostics | PASS |
| Parry gate is exposed and lift remains idle | Focused GREEN; MCP screenshot/logs | PASS |
| Godot 4.7 scene is visible and logs are clean | MCP run `2`; saved screenshot | PASS |
