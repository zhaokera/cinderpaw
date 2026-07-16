# Old Factory Steam Vent Motion Readability Evidence

> **Story**: Combat Presentation 033
> **Date**: 2026-07-16
> **Verdict**: PASS

## Delivered Contract

- All twenty-six Old Factory steam-vent hazard instances now use one shared
  `AnimatedSprite2D + SpriteFrames` presentation with generated `safe`,
  `warning`, and `active` loops.
- The eleven periodic vents reuse their existing gameplay phase clocks for
  presentation; no phase duration or activation window changed.
- Existing damage `8`, cooldown `1.0`, player filtering, collision metadata,
  hazard ids, transforms and static-visual diagnostics remain compatible.

## Automated Evidence

- RED `reports/report_1856/results.xml`: expected failure on the absent shared
  animation resource and static-only hazard nodes.
- First GREEN `reports/report_1857/results.xml`: the new contract passed except
  for hidden checkpoint playback, which exposed the required visibility sync.
- Focused GREEN `reports/report_1858/results.xml`: `1/1` passed.
- Final bounded GREEN `reports/report_1859/results.xml`: `10/10` passed across
  Story033, Story009 contact damage/cooldown, Story047 checkpoint gauntlet and
  Story069 phase traversal; exit code `0`.
- Fresh completion gate `reports/report_1860/report_1/results.xml`: the same
  four suites passed `10/10` with no errors, failures, flaky, skipped or orphan
  cases; exit code `0`.
- Image audit: all twelve runtime frames are transparent sRGBA `256x256` PNGs;
  each animation has four distinct textures and continuous `_000` to `_003`
  names.

## MCP Evidence

Session `cinderpaw@af5f`, Godot `4.7-stable`, Godot AI MCP `3.0.2`, clean run
`r164212247-51`:

- the actual `factory_route_transition_shell.tscn` opened and ran with no
  launch errors;
- the runtime tree contained `SteamAnimation` under every steam-vent hazard;
- the entrance vent remained a visible monitoring `Area2D` on layer/mask
  `16/12`, with damage `8`, cooldown `1.0` and its existing hazard id;
- its `SteamAnimation` used the shared resource, selected `active`, reported
  four looping frames at `10 FPS`, and advanced from frame `1` to `0` during a
  `180ms` sample;
- the hidden checkpoint vent remained invisible and non-monitoring on layer
  and mask `0/0`, with animation playback stopped;
- the non-empty `1278x718` screenshot showed Cinderpaw, the authored Factory
  environment, enemies and a visible active steam plume;
- game logs contained one diagnostic info row only, editor logs were empty,
  and stop restored editor readiness.

MCP verified runtime presentation and unchanged hazard diagnostics. Physical
contact damage/cooldown behavior is covered by the bounded Story009 regression,
not claimed as a separate MCP collision exercise.

## Asset Evidence

- Generated RGB contact sheet and retained alpha intermediate: `1254x1254`.
- Runtime preview: `1024x768`.
- Runtime: twelve transparent sRGBA `256x256` PNGs.
- Prompt and processing record:
  `assets/environment/old_factory_steam_vent/source/factory_steam_vent_motion_sheet_imagegen_20260716.md`.
- Asset spec:
  `design/assets/specs/old-factory-steam-vent-motion-readability.md`.
- Runtime screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-steam-vent-motion-20260716.png`.

## Scope Note

The legacy `Visual` node remains for earlier Story diagnostics while its static
sprite is hidden in favor of `SteamAnimation`. No scene collision shape,
position, scale, damage value, cooldown or encounter pacing was modified.
