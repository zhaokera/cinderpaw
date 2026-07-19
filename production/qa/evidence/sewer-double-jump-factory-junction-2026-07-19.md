# Sewer Double-Jump Factory Junction Evidence

## Scope

Scene Management Story022 adds the first real Sewer-to-Factory junction. The
low return remains intact, Dash cannot substitute for Double Jump, and the
accepted high-route handoff preserves abilities, prior Sewer progress and Gears.

## Asset Pipeline

- No new visual file was generated. The junction deliberately reuses four
  already imported image-generation outputs documented in
  `design/assets/specs/sewer-double-jump-factory-junction.md`.
- Godot scene inspection found `SewerFactoryHighPlatform` with authored
  `StaticBody2D` collision, `SewerFactoryDoubleJumpGate`,
  `SewerFactoryRouteShell`, and the production Player `AnimatedSprite2D`.
- Runtime diagnostics resolved the exact expected texture paths for the
  platform, claw marker and Factory pipe shell.

## Thin TDD

- Intentional RED `reports/report_1985/report_1/results.xml`: `1/1` executed and
  failed only because `get_sewer_factory_junction_diagnostics()` did not exist.
- Focused GREEN `reports/report_1989/report_1/results.xml`: the physical Dash
  rejection, real Double Jump acceptance, one-shot handoff, state transfer and
  cold restore passed `1/1`, with zero errors/failures/flaky/skips/orphans.
- Final related GREEN `reports/report_1994/results.xml`: Story020,
  Story021, Double Jump, Boss2 handoff, Factory shell/return and Story022 passed
  eight suites and `13/13` cases, with zero errors/failures/flaky/skips/orphans
  and exit `0`.
- GdUnit printed its existing process-exit resource-leak warning after the
  successful summary. No full suite was run.
- Post-review checks `reports/report_1995/results.xml` and
  `reports/report_1996/results.xml` each passed `1/1` after stale roundtrip test
  helpers were removed and Factory state writes moved behind request acceptance.

## MCP Runtime Acceptance

- Godot `4.7-stable`; Godot AI MCP `3.0.2`; session `cinderpaw@af5f`.
- Visual run `r330692286-102` (token `102`) started the real Sewer scene,
  configured cleared Story020/021 state with Dash, Double Jump and `22 Gears`,
  drove `move_right` plus two separate real `jump` action presses and captured
  the junction screenshot.
- Before input, diagnostics reported `gate_state=unlockable`,
  `route_available=false`, `platform_top_y=350`, all expected textures present
  and currency `22`.
- After input and SceneManager processing, saved Sewer state reported
  `sewer_factory_high_platform_unlocked=true` and
  `sewer_factory_route_reached=true`; Main carried the same reached flag.
  Factory state contained `basic_attack`, `jump`, `dodge`, `dash`,
  `double_jump`, `parry` and currency `22`.
- The non-empty `1278x718` screenshot visibly showed Cinderpaw, the generated
  pressure chamber, elevated factory platform, circular pipe entrance, upward
  claw marker, `Double Jump to Factory` prompt and unobstructed HUD.
- Final post-review run `r332238403-103` (token `103`) repeated the real inputs
  after the transaction-order correction and returned the same unlocked/reached
  state, ability set and `22 Gears`.
- Two earlier runs were invalidated and cleared because MCP diagnostic snippets
  used mixed indentation and then queried a removed custom-scene root. Those
  debugger breaks did not originate in project scripts. The final run's game
  log contained only three initialization info lines; editor errors returned
  zero rows. Stop returned the editor to `ready`.

## Result

PASS. The Sewer now provides the GDD-required physical Double-Jump payoff and
owns first Factory entry, while Main remains only a post-service-lift shortcut.
