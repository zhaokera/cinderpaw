# QA Evidence: Old Factory Forward Pressure Aftershock Condenser Outlet Clamp Ambush

Date: 2026-07-09
Engine: Godot 4.7-stable
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story097 extends the route beyond the Story096 aftershock
condenser outlet into a short outlet clamp combat pocket. The slice adds a
new image-generated clamp prop, reuses the existing image-generated Factory
Spark Rat `AnimatedSprite2D + SpriteFrames` character, and persists the clear
state without replaying the Story094-096 condenser chain.

## Assets

New image generation was used for the outlet clamp prop:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_clamp_imagegen_20260709.png`
- Alpha source:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_clamp_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_clamp_imagegen_20260709.json`
- Runtime:
  `res://assets/environment/old_factory_aftershock_condenser_outlet_clamp/env_old_factory_aftershock_condenser_outlet_clamp_256.png`

Prompt summary: compact Old Factory aftershock condenser outlet clamp junction
for a side-view cat action game, with gunmetal pipe collar, copper locking
bands, cracked ceramic insulators, cyan condenser gauges, broken clamp jaws,
oil stains, and a flat green chroma-key background for local alpha removal.

The ambush enemy reuses the imported Factory Spark Rat frame animation asset at
`res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.

## Automated Evidence

- Initial focused RED: `reports/report_1240/`
  - Failure captured missing Story097 asset/API/diagnostics before
    implementation.
- Final focused RED after runtime texture size adjustment: `reports/report_1241/`
  - Failure captured the same missing Story097 implementation against the final
    expected `256x256` runtime prop.
- Focused GREEN: `reports/report_1242/`
  - `2/2` tests passed.
- Related GREEN: `reports/report_1243/`
  - `18/18` Story097 + Story096 + Story095 + Story094 + Story093 + Story092 +
    respawn regression tests passed.
- Headless smoke:
  `reports/old_factory_aftershock_condenser_outlet_clamp_ambush_smoke.log`
  exited `0`.
  - Keyword scan found no project script/parse/invalid-call/access/
    missing-resource/resource-load errors.
  - Godot emitted existing shutdown cleanup noise about leaked
    ObjectDB/resource instances after `--quit-after`; no Story097 script or
    resource paths were present in that noise.

## MCP Evidence

Godot MCP session `cinderpaw@1014` reloaded
`res://scenes/factory_route_transition_shell.tscn` from disk and launched the
current scene. Runtime helper status was live.

MCP verified:

- Editor scene contains
  `FactoryLowerDeckForwardPressureAftershockCondenserOutletClamp` and
  `FactoryLowerDeckForwardPressureAftershockCondenserOutletClampSparkRat`.
- Runtime activation after Story096 crossing reported `activated=true`,
  `active=true`, route label `Clear Outlet Clamp Ambush`, generated texture path
  mounted on the clamp `Sprite2D`, ground width `5760`, right wall x `5740`,
  and player camera limit right `5760`.
- The active Spark Rat was visible, had the player target, used entity id
  `2138`, and exposed Factory Spark Rat SpriteFrames at
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- SpriteFrames contained `3` frames each for `idle`, `run`, `attack_tell`,
  `attack`, `hurt`, and `death`.
- Applying damage to entity `2138` returned `true`, cleared the ambush, hid the
  Spark Rat, advanced route feedback to `Outlet Clamp Ambush Cleared`, and
  persisted activated/defeated/cleared local-state flags.
- Restoring cleared local state kept the clamp ambush cleared, rejected duplicate
  activation, preserved Story096 outlet crossed state with contact disabled,
  preserved Story095 savepoint activation, preserved Story094 landing clear,
  and kept the service lift prompt as `Call lift`.
- Final game log contained only the Godot AI helper registration line, and
  `logs_read(source="editor", since_cursor=9)` returned no new editor errors.
- A non-empty `960x539` game screenshot showed the generated clamp prop, player,
  and active Spark Rat in the outlet clamp pocket.

## Verdict

PASS. Story097 adds a generated visible clamp prop and a real frame-animated
Spark Rat ambush after the aftershock condenser outlet, gates it behind Story096
completion, persists defeat state, and keeps the lower-deck route moving as
playable ACT content.
