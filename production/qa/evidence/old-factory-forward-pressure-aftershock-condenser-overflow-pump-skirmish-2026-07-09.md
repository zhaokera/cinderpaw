# QA Evidence: Old Factory Forward Pressure Aftershock Condenser Overflow Pump Skirmish

Date: 2026-07-09
Engine: Godot 4.7-stable
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story099 extends the route beyond the Story098 aftershock
condenser outlet drip vent into a visible overflow pump combat pocket. The slice
adds a new image-generated transparent pump prop, reuses the imported Factory
Coil Rat `AnimatedSprite2D + SpriteFrames` character, and persists the cleared
state without replaying the Story095-098 condenser chain.

## Assets

New image generation was used for the aftershock condenser overflow pump prop:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_overflow_pump_imagegen_20260709.png`
- Alpha source:
  `assets/generated/source/old_factory_aftershock_condenser_overflow_pump_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_overflow_pump_imagegen_20260709.json`
- Runtime:
  `res://assets/environment/old_factory_aftershock_condenser_overflow_pump/env_old_factory_aftershock_condenser_overflow_pump_768.png`

Prompt summary: Old Factory aftershock condenser overflow pump for a side-view
cat action game, with a long horizontal blue-grey steel pump assembly, rusted
cylinders, gauges, cyan condenser lamps, copper piping, black pipe mouth, hazard
striping, soot, and a flat green chroma-key background for local alpha removal.

The enemy reuses the imported Factory Coil Rat frame animation resource at
`res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`.

## Automated Evidence

- Initial focused RED: `reports/report_1250/`
  - Failure captured missing Story099 asset/API/diagnostics before
    implementation.
- Focused GREEN: `reports/report_1252/`
  - `2/2` tests passed.
- Related GREEN: `reports/report_1253/`
  - `10/10` Story099 + Story098 + Story097 + Story096 + Story095 tests passed.
- Headless smoke:
  `reports/old_factory_aftershock_condenser_overflow_pump_skirmish_smoke.log`
  exited `0`.
  - Keyword scan found no project script/parse/invalid-call/access,
    missing-resource/resource-load, flushing-query, or in/out-signal
    state-change errors.
  - Godot emitted existing shutdown cleanup noise about resources still in use;
    no Story099 script or resource paths were present in that noise.

## MCP Evidence

Godot MCP session `cinderpaw@1014` reloaded
`res://scenes/factory_route_transition_shell.tscn` from disk and launched the
current scene. The live editor reported Godot `4.7-stable`, plugin `2.9.1`, and
server `2.9.1`; runtime helper status was live.

MCP verified:

- Editor scene contains
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPump` and
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpCoilRat`.
- The pump `Sprite2D` uses the generated runtime texture, starts hidden, and the
  route geometry extends to ground width `7040`, right wall x `7020`, and camera
  limit right `7040`.
- The Coil Rat is a reused `factory_coil_rat.gd` `CharacterBody2D` with entity
  id `2139`, family `factory_coil_rat`, and `factory_coil_rat_sprite_frames.tres`.
- Locked diagnostics before Story098 crossed reported unavailable, prop hidden,
  Coil Rat hidden, no target, and physics/process disabled.
- After setting Story098 crossed state, diagnostics reported available, prop
  visible, Coil Rat hidden, and route label `Outlet Drip Vent Crossed`.
- Activation at x `6540` advanced route feedback to
  `Clear Overflow Pump Skirmish`, showed the Coil Rat, assigned a target,
  enabled process/physics, and started `10` opening-grace frames.
- Frame diagnostics reported 3 frames each for `idle`, `run`, `attack_tell`,
  `attack`, `hurt`, and `death`.
- Applying `999` damage to entity `2139` persisted activated/defeated/cleared
  local-state flags, hid and disabled the Coil Rat, kept the generated prop
  visible, and advanced route feedback to `Overflow Pump Cleared`.
- Current-run game log contained only the Godot AI helper registration line, and
  `logs_read(source="editor", since_cursor=9)` returned no new editor errors.
- A non-empty `960x539` game screenshot showed the generated overflow pump prop
  and the preceding drip vent pocket.

## Verdict

PASS. Story099 adds a generated visible overflow pump combat pocket after the
drip vent traversal, gates it behind Story098 completion, reuses a proper
frame-animated Coil Rat instead of a block placeholder, persists clear state,
and keeps the lower-deck route moving as playable ACT content.
