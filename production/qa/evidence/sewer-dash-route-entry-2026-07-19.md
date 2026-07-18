# Sewer Dash Route Entry Evidence

## Scope

Scene Management Story020 turns Main's existing Dash gate into the registered
`area_02_sewer` route. The one-screen ACT room uses a real gap and animated
exhaust to reject a normal jump, accepts one real Dash crossing and returns to a
dedicated Main spawn without opening the later Double-Jump-gated Factory route.

## Asset Pipeline

- Built-in image generation final source:
  `assets/environment/sewer_dash_route/source/sewer_dash_route_background_imagegen_20260719.png`.
- Exact initial and three edit prompts:
  `assets/environment/sewer_dash_route/source/sewer_dash_route_background_imagegen_20260719.md`.
- Source: `1672x941`, opaque RGB.
- Runtime:
  `assets/environment/sewer_dash_route/sewer_dash_route_background_1280x720.png`,
  exact `1280x720`, opaque RGB.
- Processing: deterministic `sips` resize followed by a complete Godot 4.7
  editor import.
- Authored platform edges align the visible opening at `x=588..680` (`92px`).
  The existing four-frame Old Factory steam vent provides the separate visible
  active hazard; there is no invisible bridge or hidden low ceiling.

## Thin TDD

- Intentional RED `reports/report_1974/report_1/results.xml`: the single
  Story020 acceptance executed and failed only because the registered Sewer
  scene did not exist.
- `report_1975` is explicitly invalid evidence: assertions passed before the
  new PNG import completed, but Godot logged a missing Texture2D/import scene
  parse error.
- A full Godot 4.7 `--headless --editor --import` completed with exit `0` and
  registered both the background and new scripts.
- Focused GREEN `reports/report_1976/report_1/results.xml`: `1/1`, zero errors,
  failures, flaky cases, skips or orphans; exit `0`.
- Bounded related GREEN `reports/report_1977/report_1/results.xml`: Story020,
  Player Dash, Dash gate, SceneManager runtime swap, Factory round trip and
  AudioSystem passed six suites and `35/35` tests. Zero errors, failures, flaky
  cases, skips or orphans; exit `0`.
- Runtime-discovered regression RED `reports/report_1978/results.xml`: the new
  return-Gate assertion failed `false` versus `true`, proving Main synchronized
  Gate nodes before assigning the restored `world_flags`.
- Post-fix focused GREEN `reports/report_1979/results.xml`: the complete
  Story020 round trip passed `1/1`, zero errors, failures, flaky cases, skips or
  orphans and exit `0` after moving flag restoration before Gate sync.
- No full suite was run.

## MCP Runtime Acceptance

- Godot: `4.7-stable`; Godot AI MCP: `3.0.2`.
- Session: `cinderpaw@af5f`; accepted run: `r294836394-94`, token `94`.
- Two earlier probe runs were invalidated because the MCP diagnostic snippets
  guessed nonexistent read-only methods and parked the debugger. They were
  stopped, their diagnostic errors were cleared, and no project code was
  changed in response. Only run token `94` is acceptance evidence.
- A deterministic safe post-Rat-King state established the existing route
  precondition. Real `move_right` plus `dash` input changed Main's Dash gate
  from `unlockable` to open and committed `area_02_sewer/default` through the
  authored body-overlap entry.
- Sewer diagnostics proved the imported background path, `92px` real gap,
  Player Dash ability, three Dash frames and a playing four-frame `active`
  exhaust animation.
- Real movement plus physical `jump` contacted the exhaust and produced exactly
  one local reset with `last_reset_reason=exhaust`; no crossing or transition
  was recorded.
- The next physical Dash crossed once, set `dash_crossed=true`, kept reset count
  at one and changed the exhaust animation to `safe`.
- A non-empty `1278x718` screenshot showed Cinderpaw on the far steel landing,
  the open central drain, animated exhaust prop, circular hatch and unobstructed
  HUD.
- Real movement reached the exit and committed `main/sewer_return`. The returned
  Main Player position and `SewerReturnSpawn` were both `(900,456)`, distance
  `0px`; `area_02_sewer_unlocked` and `sewer_dash_route_crossed` were present.
- Current-run game logs contained only the MCP helper plus two DataManager info
  lines. Editor errors returned zero rows. Stop returned the editor to `ready`.
- Post-fix acceptance run `r295492330-95` (token `95`) restored Dash plus all
  route/Gate flags while Cinderpaw was `735px` from the Dash gate. The Gate was
  immediately `unlocked`, collision was disabled and the Sewer handoff reported
  the same state without requiring proximity. Game logs again had three info
  lines, editor errors were empty and stop returned `ready`.

## Result

PASS. Story020 supplies a visible, physically tested Dash route and deterministic
round trip while preserving the GDD's separate Double Jump requirement for the
later Sewer-to-Factory connection.
