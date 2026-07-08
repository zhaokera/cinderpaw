# Old Factory Forward Pressure Aftershock Exhaust Pursuer Reward Cache Evidence

Date: 2026-07-09
Engine: Godot 4.7
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story088 adds a Story087-gated Old Factory forward-pressure
aftershock exhaust pursuer payoff cache in `factory_route_transition_shell.tscn`.

## Automated Tests

- RED: `reports/report_1195/` failed before Story088 diagnostics and claim APIs
  existed.
- Focused GREEN: `reports/report_1196/` passed Story088 `3/3`, including the
  live pursuer defeat-to-cache-unlock path.
- Related GREEN: `reports/report_1197/` passed Story088, Story087, Story086,
  Story085, Story084, Story083, Story074 exit relay, service-lift, no-loss
  respawn, Story068 no-replay, and Story071 reward-cache audio no-replay suites
  `26/26`.

## Headless Smoke

`reports/old_factory_forward_pressure_aftershock_exhaust_pursuer_reward_cache_smoke.log`
exited `0`. Keyword scan found no project script, parse, invalid-call,
invalid-access, missing-resource, resource-load, or shadowed-variable errors.

## MCP Runtime

Godot MCP launched `res://scenes/factory_route_transition_shell.tscn` with
helper live. Runtime probes used the live Story087 defeat path and confirmed:

- `FactoryLowerDeckForwardPressureAftershockExhaustPursuerRewardCache` exists.
- Before Story087 is cleared, the cache is present but hidden, unavailable, and
  non-claimable.
- Story087 pursuer activation succeeds after the Story086 crossed state.
- Applying lethal damage to entity `2131` succeeds.
- After the live pursuer defeat, the cache becomes visible, available, and
  claimable.
- Cache id/source:
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache`.
- Reward gears: `20`.
- Runtime texture:
  `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- Prompt text: `+20 Gears`.
- First claim returns `true`; duplicate claim returns `false`.
- Claim payload grants `20` gears with the Story088 cache id/source.
- Route feedback advances to
  `Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears`.
- Restored local state keeps Story088 claimed/non-claimable and preserves
  Story087 cleared, Story086 crossed, Story085 cleared, and Story084 claimed.
- Story074 exit-relay savepoint remains
  `old_factory_lower_deck_forward_pressure_exit_relay` /
  `lower_deck_forward_pressure_exit_relay`.
- `FactoryServiceLift` remains optional with prompt `Call lift`.
- Story068 clear-feedback spawn count remains `0`.
- Story071 reward-cache audio request count remains `0`.

Final logs:

- Game log: only `[godot_ai game_helper] registered mcp capture`.
- Editor log: empty.

Screenshot:

- MCP `editor_screenshot(source="game")` returned a non-empty `960x539`
  framebuffer with the reward cache visible in the Old Factory lower deck.

## Asset Pipeline

No new visual or audio assets were generated. Story088 reuses the existing
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
`design/assets/entity-inventory.md`, and the Story088 file. The AGENTS 2D frame
animation rule is not triggered because this Story adds an environment reward
prop, not a new player-visible character.
