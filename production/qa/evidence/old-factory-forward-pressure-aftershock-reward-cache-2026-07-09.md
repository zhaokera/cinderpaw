# Old Factory Forward Pressure Aftershock Reward Cache Evidence

Date: 2026-07-09
Engine: Godot 4.7
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story084 adds a Story083-gated Old Factory forward-pressure
aftershock payoff cache in `factory_route_transition_shell.tscn`.

## Automated Tests

- RED: `reports/report_1172/` failed before Story084 diagnostics and claim APIs
  existed.
- Live-path RED: `reports/report_1178/` failed after adding coverage for the
  real Story083 Coil Aftershock defeat path; the cache stayed locked because
  the defeat handler did not sync the Story084 cache state.
- Focused GREEN: `reports/report_1179/` passed Story084 `3/3`, including the
  live defeat-to-cache-unlock path.
- Initial related GREEN: `reports/report_1176/` passed Story084, Story083,
  Story071 audio no-replay, service-lift exit, and no-loss respawn suites
  `10/10`.
- Expanded related GREEN: `reports/report_1180/` passed Story084, Story083
  through Story074, Story071 audio no-replay, service-lift exit, and no-loss
  respawn suites `29/29`.

## Headless Smoke

`reports/old_factory_forward_pressure_aftershock_reward_cache_smoke.log` exited
`0`. Keyword scan found no project script, parse, invalid-call,
invalid-access, missing-resource, or resource-load errors.

## MCP Runtime

Godot MCP launched `res://scenes/factory_route_transition_shell.tscn` with
helper live. Runtime probes used the live Story083 defeat path and confirmed:

- `FactoryLowerDeckForwardPressureAftershockRewardCache` exists.
- Story083 Coil Aftershock activates successfully.
- Applying lethal damage to entity `2128` succeeds.
- Before claim, the cache becomes visible, available, and claimable after the
  live aftershock defeat.
- Cache id/source:
  `old_factory_lower_deck_forward_pressure_aftershock_reward_cache`.
- Runtime texture:
  `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- Prompt text: `+20 Gears`.
- First claim returns `true`; duplicate claim returns `false`.
- Claim payload grants `20` gears with the Story084 cache id/source.
- Route feedback advances from `Forward Pressure Coil Aftershock Cleared` to
  `Forward Pressure Aftershock Cache Claimed +20 Gears`.
- Story074 exit-relay savepoint remains
  `old_factory_lower_deck_forward_pressure_exit_relay` /
  `lower_deck_forward_pressure_exit_relay`.
- `FactoryServiceLift` remains optional with prompt `Call lift`.

Final logs:

- Game log: only `[godot_ai game_helper] registered mcp capture`.
- Editor log: empty.

Screenshot:

- MCP `editor_screenshot(source="game")` returned a non-empty `960x539`
  framebuffer with Cinderpaw and the reward cache visible in the Old Factory
  lower deck.

## Asset Pipeline

No new visual or audio assets were generated. Story084 reuses the existing
imported image-generated lower-deck cache prop:

- Runtime texture:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`
- Image generation source:
  `assets/generated/source/old_factory_lower_deck_skirmish_cache_imagegen_20260701.png`
- Alpha source:
  `assets/generated/source/old_factory_lower_deck_skirmish_cache_alpha_20260701.png`
- Metadata:
  `assets/generated/source/old_factory_lower_deck_skirmish_cache_imagegen_20260701.json`

Reuse is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and the Story084 file.
