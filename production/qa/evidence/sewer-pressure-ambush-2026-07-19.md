# Sewer Pressure Ambush Evidence

## Scope

Scene Management Story021 adds a second player-facing Sewer room after the Dash
landing: one pressure-warning combat lock, one production Sluice Leech, one
defeat-gated cache and a persisted return state. Factory remains locked behind
the separate Double Jump requirement.

## Asset Pipeline

- Built-in generation source:
  `assets/environment/sewer_pressure_chamber/source/sewer_pressure_chamber_background_imagegen_20260719.png`.
- Exact prompt:
  `assets/environment/sewer_pressure_chamber/source/sewer_pressure_chamber_background_imagegen_20260719.md`.
- Source: opaque RGB `1672x941`; runtime: exact opaque RGB `1280x720` at
  `assets/environment/sewer_pressure_chamber/sewer_pressure_chamber_background_1280x720.png`.
- Godot 4.7 headless editor import exited `0`. Player, collision, seal, cache,
  pressure animation and enemy remain separate nodes.
- Reused Sluice Leech provides six gameplay animations with three transparent
  common-anchor frames each; the steam vent provides four-frame `safe`,
  `warning` and `active` loops.

## Thin TDD

- Intentional RED `reports/report_1981/report_1/results.xml`: `1/1` executed,
  zero errors and one expected failure at the absent Story021 diagnostics API.
- Focused GREEN `reports/report_1982/report_1/results.xml`: real movement,
  production attack hits, defeat, cache claim, Main state transfer and cold
  restore passed `1/1` in about `9.4s`, with zero errors/failures/flaky/skips/
  orphans and exit `0`.
- Related GREEN `reports/report_1983/report_1/results.xml`: existing Sewer Dash
  round trip plus Factory high-platform route passed `4/4`, zero test errors,
  failures, flaky cases, skips or orphans and exit `0`.
- Fresh pre-commit `reports/report_1984/report_1/results.xml`: the new Story021
  acceptance plus both bounded regressions passed `5/5`, zero test errors,
  failures, flaky cases, skips or orphans and exit `0`.
- No full suite was run.

## MCP Runtime Acceptance

- Godot `4.7-stable`; Godot AI MCP client/server `3.0.2`; session
  `cinderpaw@af5f`.
- Runtime probe `98` used real `move_right` to enter the pressure chamber and
  real `attack` actions for two `12`-damage production hit confirmations. The
  leech reached zero HP, kill feedback counted once, pressure changed to `safe`,
  the seal opened and real movement claimed `15 Gears` (`7 -> 22`). It exposed
  one unused-variable editor warning, which was fixed before acceptance.
- Two earlier probe runs were invalidated by diagnostic-snippet mistakes during
  debugger inspection; neither error came from project gameplay code. They were
  stopped and cleared before the final run.
- Final post-fix acceptance `r297957500-99` (token `99`) cold-restored
  `encounter_state=cleared`, `active_enemy_count=0`, `room_seal_blocking=false`,
  `reward_claimed=true`, `reward_claim_count=1`, `currency=22` and
  `player_has_double_jump=false`. Hidden restored enemy SpriteFrames still
  reported all six required animations at three frames each.
- Its non-empty `1278x718` screenshot visibly showed the generated pressure
  chamber, Cinderpaw, claimed cache, safe back-pressure vent and `Gears 22`
  without placeholder blocks or overlapping UI.
- Current-run game logs contained only the MCP helper registration info line;
  editor errors returned zero rows. Stop returned the editor to `ready`.

## Result

PASS. The Sewer now has a compact ACT combat/reward payoff with persistent
state and frame animation while preserving the Double-Jump-gated Factory
boundary.
