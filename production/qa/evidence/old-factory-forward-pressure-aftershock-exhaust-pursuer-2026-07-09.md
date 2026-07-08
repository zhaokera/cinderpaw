# QA Evidence: Old Factory Forward Pressure Aftershock Exhaust Pursuer

Date: 2026-07-09
Story: `production/epics/player-abilities/story-087-old-factory-lower-deck-forward-pressure-aftershock-exhaust-pursuer.md`
Engine: Godot 4.7
Godot AI MCP: 2.9.1

## Scope

Story087 adds a compact ACT pursuit beat after Story086. Once
`factory_lower_deck_forward_pressure_aftershock_exhaust_crossed=true`, crossing
x `2552.0` activates
`FactoryLowerDeckForwardPressureAftershockExhaustPursuerCoilRat` as entity
`2131`. The pursuer assigns Cinderpaw as target, enables process/physics,
starts `10` opening-grace frames, uses the existing Factory Coil Rat
`AnimatedSprite2D + SpriteFrames` frame contract, persists activation/defeat/
cleared flags, and advances route feedback from
`Purge Aftershock Exhaust Pursuer` to `Forward Pressure Exhaust Pursuer Cleared`.

## Asset Pipeline

No new visual or audio assets were generated for this Story. Story087 reuses
the existing image-generated Factory Coil Rat frame-animation asset:

- Runtime SpriteFrames:
  `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- Runtime character scene:
  `res://scenes/characters/factory_coil_rat.tscn`
- Runtime gameplay scene:
  `res://src/gameplay/factory_coil_rat.tscn`
- Source:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_sprite_sheet_imagegen_20260708.png`
- Alpha source:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_sprite_sheet_alpha_20260708.png`

Reuse is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and the Story087 file.

## Automated Evidence

- RED focused: `reports/report_1191/`
  - Expected failure before Story087 diagnostics/activation APIs and scene node
    existed.
- Focused GREEN: `reports/report_1192/`
  - `old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_test.gd`
  - Passed `2/2`.
- Related GREEN: `reports/report_1193/`
  - Covered Story087 plus Story086, Story085, Story084, Story083, Story074
    relay, service-lift scene-manager exit, no-loss respawn, Story068
    no-replay, and Story071 reward-cache audio no-replay contracts.
  - Passed `23/23`.
- Headless smoke:
  `reports/old_factory_forward_pressure_aftershock_exhaust_pursuer_smoke.log`
  - Exit code `0`.
  - Project error keyword scan found no script/parse/invalid-call/access,
    missing-resource, resource-load, or shadowed-variable errors.

## MCP Runtime Evidence

Godot MCP session `cinderpaw@3094` reported Godot `4.7-stable (official)`,
`plugin_version=2.9.1`, `server_version=2.9.1`, readiness `ready`, and play
state `stopped` after verification.

Final runtime probe confirmed:

- Scene `res://scenes/factory_route_transition_shell.tscn` loads.
- `FactoryLowerDeckForwardPressureAftershockExhaustPursuerCoilRat` exists as
  `CharacterBody2D`.
- Child `Sprite` exists as `AnimatedSprite2D`.
- Story086 crossed state makes the pursuer available.
- Player at x `2556.0` activates entity `2131`.
- Encounter id:
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer`.
- SpriteFrames path:
  `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`.
- Animation frame counts:
  `idle=3`, `run=3`, `attack_tell=3`, `attack=3`, `hurt=3`, `death=3`.
- Runtime state: `coil_visible=true`, `coil_has_target=true`,
  `coil_physics_enabled=true`, `coil_process_enabled=true`.
- Pacing: `pacing_state=opening_grace`,
  `opening_grace_total_frames=10`, `coil_opening_grace_frames=10`.
- Route label: `Purge Aftershock Exhaust Pursuer`.
- MCP game screenshot was non-empty (`960x539`) and showed the active Coil Rat
  pursuer in the lower-deck route.
- Final game log contained only the helper registration line; final editor log
  was empty.

## Notes

The first MCP eval probe used an eval-only GDScript snippet that triggered a
Godot 4.7 Variant-inference warning as a debugger break. The game was stopped,
logs were cleared, and the final typed eval probe above completed with clean
game/editor logs. No project file reported a parser/runtime error.
