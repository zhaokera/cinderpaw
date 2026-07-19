# Main Factory Return Checkpoint Reentry Evidence

## Scope

- Story:
  `production/epics/scene-management/story-027-main-factory-return-checkpoint-reentry.md`
- Main runtime: `res://src/gameplay/main_scene.gd`
- Factory runtime: `res://src/gameplay/old_factory_entrance_scene.gd`
- Focused tests:
  `res://tests/unit/gameplay/factory_route_return_prompt_test.gd` and
  `res://tests/unit/gameplay/old_factory_return_checkpoint_test.gd`
- Engine: Godot 4.7 stable
- Godot AI MCP: 3.0.2

## Automated Evidence

| Gate | Result | Evidence |
|------|--------|----------|
| Main route RED | Three cases, two expected failures | `reports/report_2034/results.xml`: diagnostics and request still used `factory_gate_entry` |
| Main route GREEN | Pass `3/3` | `reports/report_2035/results.xml` |
| Deeper-checkpoint RED | Eight cases, two expected failures | `reports/report_2037/results.xml`: old checkpoint activation replaced the deeper id and spawn |
| Deeper-checkpoint GREEN | Pass `8/8` | `reports/report_2038/results.xml` |
| Final related regression | Pass `17/17` across five suites | `reports/report_2039/results.xml` |

The final related run covered Main route selection, the runtime roundtrip,
Factory checkpoint behavior, Scrap Roost return-hub state and the registered
Factory transition shell. It reported zero errors, failures, flaky cases,
skips or orphan nodes. No full suite was run.

## MCP Runtime Acceptance

Final accepted run `r360343098-123` (token `123`) launched
`res://scenes/main.tscn` through session `cinderpaw@af5f`.

Main route and real-input probe:

- MCP seeded the complete `main/scrap_roost` service-lift return contract,
  `factory_return_checkpoint_activated=true`, and the canonical
  `old_factory_return_checkpoint` scene-state snapshot.
- Main diagnostics reported an available route, prompt
  `Return to Factory Route`, target `area_03_factory` and spawn
  `return_checkpoint`.
- Cinderpaw began at `(925, 456)`, `113.318px` from the route shell and outside
  its authored `112px` radius.
- MCP pressed the production `move_right` action. The Player controller moved
  Cinderpaw to `(939, 456)` and `108.522px` from the shell; Main then exposed
  exactly one pending `area_03_factory/return_checkpoint` request.
- MCP released `move_right` before advancing the load, and input-state readback
  confirmed the action was no longer pressed.

Factory commit and presentation probe:

- SceneManager committed current scene `area_03_factory` and current spawn
  `return_checkpoint`.
- The runtime Factory scene contained `FactoryReturnCheckpoint`; diagnostics
  reported it present, visible, activated and bound to spawn
  `return_checkpoint`.
- Spawn application placed Cinderpaw on the checkpoint anchor. After live
  gravity settled the character onto the floor, its x position remained
  aligned within `0.071px` of the checkpoint and visibly inside the device's
  gameplay footprint.
- The Factory route label read `Returned to Factory Savepoint`, and the scene
  state retained the canonical checkpoint id, scene and spawn.
- The game screenshot was a non-empty `1278x718` PNG showing the generated Old
  Factory environment, Cinderpaw and the repaired savepoint without a blank
  frame or blocking UI overlap.

Log gate:

- Game log for the accepted run contained only MCP helper registration and two
  DataManager load info lines.
- Editor log contained zero rows; no project warning, script error, parse error
  or runtime error was present.
- MCP stopped the project cleanly and editor readiness returned to `ready`.

## Deeper Checkpoint Protection

The new regression restores
`old_factory_lower_deck_breach_relay/lower_deck_breach_relay`, then emits the
older return-checkpoint activation. The scene still marks the repair checkpoint
activated but preserves the deeper id, scene and spawn. This prevents Main
reentry from silently degrading later death-respawn progress.

## Asset Decision

No visual asset was added or changed. Story027 is a scene-state routing fix and
reuses the existing image-generated Factory environment/savepoint plus existing
`AnimatedSprite2D + SpriteFrames` characters. A separate visual Story should
generate and import at least three aligned transparent frames for each
service-lift state: `arrive`, `docked_idle` and `depart`.
