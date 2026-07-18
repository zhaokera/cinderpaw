# QA Evidence: Echo Guardian Secondary Attack Playable Loop -- 2026-07-18

## Scope

Story175 adds a deterministic fixed-location `echo_pounce` after the existing
Echo Guardian swipe. It preserves the opening swipe, Boss health, cooldown,
phase threshold, chase, defeat hold, Double Jump reward, persistence, HUD,
audio and scene handoff.

## Automated Evidence

- Intentional RED: `reports/report_1936/results.xml` failed the new Story175
  test `1/1` on the absent secondary-attack diagnostics API, with no engine
  errors.
- First implementation run `reports/report_1937/results.xml` correctly exposed
  a `24`-damage result instead of the authored `12`: the global combat rules
  double `heavy` attacks. Boss2 data and fallback were corrected to `light` so
  the new electric pounce uses its authored damage without changing the shared
  damage formula.
- Focused GREEN: `reports/report_1938/results.xml` passed `1/1` with `0`
  failures, errors, skipped or flaky tests.
- Bounded related regression: `reports/report_1939/results.xml` passed the new
  Story175 acceptance, existing Boss2 swipe/defeat flow and Echo Guardian death
  hold suites `6/6`, with `0` failures, errors, skipped or flaky tests.
- Fresh pre-push gate `reports/report_1940/results.xml` repeated the same three
  suites at `6/6`, with `0` failures, errors, skipped, flaky tests or GdUnit
  orphans. After the reporters finalized, Godot printed the project's known
  shutdown-only ObjectDB/resource-retention diagnostics.
- Godot 4.7 headless import completed with exit `0`. The targeted real-Main
  smoke `tests/smoke/echo_guardian_secondary_attack_playable_loop_smoke.gd`
  completed with exit `0` and printed startup, active and recovery diagnostics;
  it retained the same known shutdown-only cleanup diagnostics.

## Asset Generation And Import

- Exact image-generation prompts, identity reference, generated sources,
  alpha intermediates, processing, hashes and runtime paths are retained in
  `assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_echo_pounce_imagegen_20260718.json`.
- Runtime `echo_pounce_tell`, `echo_pounce`, and `echo_pounce_recovery` each
  contain three continuous transparent `160x128` PNG frames under the required
  character animation directories.
- Godot imported all source, alpha and runtime textures. The existing Boss2
  `AnimatedSprite2D + SpriteFrames` surface mounts the three non-looping
  animations at `10`, `30`, and `12 FPS`.

## Godot MCP Runtime Evidence

- Session `cinderpaw@af5f`; Godot `4.7-stable`; Godot AI MCP plugin/server
  `3.0.2`; custom Main run `r270691445-77` (run token `77`).
- Startup diagnostics proved the opening swipe, Phase II pounce selection,
  loaded combat/config data, Focus timing `21/6/15`, animation
  `echo_pounce_tell`, three frames per new animation, locked landing X `592`,
  visible landing marker and both attack hitboxes inactive.
- The player was moved to X `712` after lock. Active state still landed the
  Boss at X `592`, selected animation `echo_pounce`, enabled only
  `boss2_echo_pounce`, and hid the marker.
- Live CollisionComponent detection applied `12` damage once and `0` on the
  second detection frame. Metadata reported final damage `12` and hitbox/
  weapon id `boss2_echo_pounce`.
- Recovery selected `echo_pounce_recovery`, reported three frames and closed
  the pounce hitbox. The next scheduled pattern remained `echo_swipe`.
- MCP returned no run errors. The game log contained only the helper and two
  DataManager load lines, editor logs contained `0` rows, and stop restored
  editor readiness.
- The MCP game-framebuffer screenshot was non-empty at `1278x718` and visibly
  showed the generated pounce tell, player, fixed red landing marker and Boss2
  Phase II HUD without overlap.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Deterministic swipe/pounce alternation | Story175 test; smoke; MCP pattern probes | PASS |
| Locked and clamped landing position | Story175 test; MCP player-move probe | PASS |
| Data-driven Phase I/II and Focus timing | JSON/schema; Story175 test; MCP diagnostics | PASS |
| One `12`-damage active window | Story175 real collision; MCP live collision | PASS |
| Three generated animations with stable frames | Asset record; GdUnit; MCP SpriteFrames probe | PASS |
| Existing swipe, defeat and reward behavior preserved | Final `6/6` related regression | PASS |
| Godot 4.7 / MCP 3.0.2 clean visible runtime | Run token `77`, logs and screenshot | PASS |
