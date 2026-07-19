# Factory Arrival Encounter Staging Evidence

## Scope

- Story: `production/epics/scene-management/story-023-factory-arrival-encounter-staging.md`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Runtime script: `res://src/gameplay/old_factory_entrance_scene.gd`
- Engine: Godot 4.7 stable
- Godot AI MCP: 3.0.2

## Automated Evidence

| Gate | Result | Evidence |
|------|--------|----------|
| Intentional RED | Expected failure | `reports/report_1997/results.xml`: missing staging diagnostics and activation APIs |
| Focused GREEN | Pass `1/1` | `reports/report_1998/results.xml` |
| Historical contract isolation | Expected failure `2/14` | `reports/report_1999/results.xml`: only Story010/013 locked-visibility assertions |
| Initial related regression | Pass `19/19` | `reports/report_2000/results.xml` |
| Post-diagnostic focused verification | Pass `1/1` | `reports/report_2001/results.xml` |
| Review regression RED | Expected failure `7` assertions | `reports/report_2002/results.xml`: inactive/legacy Hurtboxes and lifecycle diagnostic |
| Hurtbox/lifecycle focused GREEN | Pass `4/4` | `reports/report_2003/results.xml` |
| Historical pre-activation hit isolation | Expected failure `1/22` | `reports/report_2004/results.xml` |
| Corrected combat-contract focused GREEN | Pass `4/4` | `reports/report_2005/results.xml` |
| Final related regression | Pass `22/22` | `reports/report_2006/results.xml` |

The final related run covered Story023, Factory entrance room clear and combat,
deep-route endpoint, Spark Rat staging/activation, route objective progression,
service lift handoff, Factory runtime roundtrip and the Sewer Double-Jump
Factory junction. No full suite was run.

## MCP Runtime Acceptance

Run `r335863042-105` launched
`res://scenes/factory_route_transition_shell.tscn` through Godot MCP.

Initial probe:

- Runtime root was `FactoryRouteTransitionShellScene`.
- Player spawned at `(216, 456)` with `100 HP` and frame-animated `idle`.
- Entrance Rat was visible with frame-animated `idle`, but had no target,
  physics processing or collision layer.
- Cache, deep guard, deep endpoint, Spark Rat and service lift parents were not
  visible in the scene tree.
- Route objective and label both read `Clear Factory Entrance`.
- The game framebuffer was non-empty at `1278x718` and contained the generated
  Factory environment, player, one entrance Rat and animated steam vent.

Real-input probe:

- MCP held and released `move_right`; the player crossed the pressure line.
- Entrance staging switched once to `entry_guard_activated=true`, target
  present, physics enabled and collision layer `2`.
- Steam contact reduced Player HP from `100` to `92` while the route label
  remained `Clear Factory Entrance`.
- A second non-empty screenshot showed the player and active entrance Rat with
  no future-stage prompt clutter.

Log gate:

- Game log: one MCP helper registration info line, no warnings or errors.
- Editor log: zero entries.
- Project stopped cleanly through MCP after acceptance.

Final clean reload `r337599831-107` repeated the initial staging probe after
the final diagnostics change. It confirmed all three future-stage prompt
labels were hidden in-tree, both visible character sprites were
`AnimatedSprite2D` instances playing `idle`, captured a non-empty `1278x718`
game framebuffer, recorded one helper info line and zero editor errors, and
stopped cleanly through MCP.

Post-review run `r338967041-108` verified the Hurtbox regression fix. Entry,
deep and Spark Rat collision components all reported `gone` on arrival. Real
MCP `move_right` crossed the authored `x=520` line and changed the entrance
Hurtbox to `normal` while enabling its target, physics and collision layer `2`;
the other stages remained hidden. Steam reduced Player HP to `92` while the
route label remained `Clear Factory Entrance`. The `1278x718` framebuffer was
non-empty, the game log contained one helper registration info line, the editor
log contained zero entries, and MCP stopped the project cleanly.

## Asset Decision

No new visual asset was generated. The pass reuses the existing image-generated
Factory backdrop, route shell, floor/platform props, cache, endpoint, lift and
steam VFX plus existing player and Rat `AnimatedSprite2D + SpriteFrames` assets.
