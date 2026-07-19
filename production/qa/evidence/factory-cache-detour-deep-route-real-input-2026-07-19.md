# Factory Cache Detour and Deep Route Real-Input Evidence

## Scope

- Story: `production/epics/scene-management/story-024-factory-cache-detour-deep-route-real-input.md`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Runtime script: `res://src/gameplay/old_factory_entrance_scene.gd`
- Engine: Godot 4.7 stable
- Godot AI MCP: 3.0.2

## Automated Evidence

| Gate | Result | Evidence |
|------|--------|----------|
| Initial Story RED | Expected failure `2/2` | `reports/report_2007/results.xml`: production interaction route absent |
| Initial focused GREEN | Pass `2/2` | `reports/report_2008/results.xml` |
| Historical assumption isolation | Expected failures | `reports/report_2009/results.xml`: manual deep-guard and Spark activation assumptions |
| Corrected fixture GREEN | Pass `8/8` | `reports/report_2010/results.xml` |
| Initial related regression | Pass `16/16` | `reports/report_2011/results.xml` |
| Abstract-action RED | Expected failure | `reports/report_2012/report_1/results.xml`: direct method tests passed previously, but abstract `interact` was not consumed |
| Headless scheduling probe | Expected fixture failure | `reports/report_2013/report_1/results.xml`: action edge had to be sampled in the same deterministic process step |
| Focused action GREEN | Pass `2/2` | `reports/report_2015/report_1/results.xml` |
| Final related regression | Pass `16/16` | `reports/report_2016/report_1/results.xml` |

The final related run covered the Story024 real-input loop, Story023 arrival
staging, entrance room clear/cache persistence, deep-guard pacing, route
objective handoff and Spark Rat encounter. It reported zero errors, failures,
flaky cases, skips or orphan nodes. No full suite was run.

## MCP Runtime Acceptance

Final run `r342477752-112` launched
`res://scenes/factory_route_transition_shell.tscn` through Godot MCP.

Optional cache probe:

- Scene-local state was seeded to the cleared entrance state without claiming
  the cache.
- The cache at `(1040, 286)` was available while the deep guard remained inert.
- MCP pressed the production `interact` action. The cache changed to claimed,
  became unavailable and recorded exactly `+10 Gears` from
  `old_factory_combat_cache`.

Commitment and gate probe:

- MCP held `move_right`; crossing `x=1184` automatically activated the deep
  guard with a player target, physics processing and combat collision.
- Before endpoint activation, the bulkhead at `(1520, 350)` was visible and
  physically blocking.
- After guard defeat, MCP pressed the production `interact` action at the
  endpoint. `deep_route_cleared` became true and the bulkhead became hidden and
  non-blocking.
- MCP held `move_right` again; crossing `x=1600` automatically activated the
  Spark Rat with target and physics enabled.

Presentation and log gate:

- Player `Sprite` was an `AnimatedSprite2D` playing `idle`.
- Spark Rat `Sprite` was an `AnimatedSprite2D` playing its three-frame `run`
  animation; diagnostics confirmed at least three frames for every authored
  Spark Rat gameplay animation.
- The `1278x718` game framebuffer was non-empty and showed the generated
  Factory environment, Player, active Spark Rat and the opened route.
- Game log contained one MCP helper registration info line and no warning or
  error. Editor log contained zero entries.
- MCP stopped the project cleanly after acceptance.

## Asset Decision

No new visual asset was generated. The slice reuses the existing
image-generated Factory environment, cache, endpoint, platform and deep
bulkhead texture plus the existing player, Rat and Spark Rat
`AnimatedSprite2D + SpriteFrames` assets.
