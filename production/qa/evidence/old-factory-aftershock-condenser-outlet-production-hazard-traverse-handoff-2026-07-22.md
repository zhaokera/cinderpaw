# QA Evidence: Old Factory Aftershock Condenser Outlet Production Hazard Traverse Handoff

**Story**: Player Abilities Story216

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify that Story096 activates from real movement, advances its existing steam
cycle through the Factory production loop, damages a physical player overlap,
persists outlet crossing, and reveals Story097 without silently starting it.

No hazard value, visual/audio asset, SaveSystem schema, enemy behavior or
Story097 combat was added.

## TDD Evidence

- `reports/report_2308/results.xml`: canonical RED, `1` case with `9` expected
  failures. Production time remained in `grace`, the real steam overlap did not
  damage, and Story097 accepted a stale/no-input position.
- `reports/report_2310/results.xml`: final focused GREEN, `1/1`.
- `reports/report_2312/results.xml`: final bounded related GREEN, `4/4` across
  Story215, Story096 and Story216; zero failure/error/flaky/skip/orphan.
- Exploratory `reports/report_2311/results.xml` included all of Story097 and
  exposed its older immediate-hide death assertions against the current live
  death-frame presentation. The two unrelated assertions were not changed or
  used as this Story's gate; Story216's canonical directly covers the modified
  Story097 activation handoff.
- Full suite was intentionally not run.

## Smoke Evidence

`reports/old_factory_aftershock_condenser_outlet_production_hazard_traverse_handoff_smoke.log`
completed `180` fixed-FPS frames and exited `0`. The project log contained no
parse/script error, invalid call/access, missing resource or resource-load
error. Godot's existing ObjectDB/resource cleanup messages remained
stdout-only.

## MCP Runtime Evidence

Final accepted session/run: `cinderpaw@1b14` / `r153467824-10`.

- Story095 was restored active with Story096 idle and Story097 unavailable.
  Real `move_right` advanced Cinderpaw from x `4548.0` to `4681.3384` and
  observed `idle`, `grace`, `warning`, then `active` through natural runtime
  frames.
- The real outlet `Area2D` overlap applied one steam hit: HP `100 -> 92`, source
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet`, damage
  type `steam`.
- Continued real movement crossed Story096. State persisted activated/crossed,
  hazard contact disabled, HP remained `92`, and route feedback became
  `Aftershock Condenser Outlet Crossed`.
- A no-input x `5224.0` probe left Story097 available/visible but inactive.
  Entity `2138` stayed hidden, untargeted and without process/physics.
- Inputs `move_right/move_left/interact/attack/dodge` were false at acceptance.
  Game log contained only the game-helper info row; editor log was empty. The
  project stopped with editor readiness `ready`.

## Visual Evidence

Non-empty RGB PNG, `1278x718`, SHA-256
`3df3002759b56a57318ef2b35376defb347cbd7a4b8a08992e8864ac9c87dbd8`:

`reports/visual/cinderpaw-mcp-aftershock-condenser-outlet-production-hazard-traverse-active-20260722.png`

The capture shows the generated outlet machinery, high active steam plume and
Cinderpaw inside the contact zone with route feedback
`Cross Aftershock Condenser Outlet`. MCP diagnostics provide the exact HP and
damage metadata that are not rendered numerically in this camera view.

## Asset Review

No image generation was needed. The Story reuses the registered generated
outlet, animated steam vent and Cinderpaw SpriteFrames. The clamp/outlet visual
join and Spark Rat attack-tell baseline remain Story097 production-readability
checks rather than blockers for this outlet traversal.
