# Story 143: Central Tower Deep Lift Counterweight Ambush

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Combat / Traversal / Visual
> **Type**: Integration + Gameplay Runtime + Combat + Moving Platform + Frame Animation
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-12

## Context

**GDD**: `design/gdd/game-concept.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/player-abilities.md`,
`design/gdd/feline-combat.md`, `design/gdd/ai-framework.md`,
`design/gdd/health-death.md`, `design/gdd/death-respawn.md`,
`design/gdd/scene-management.md`, `design/art/art-bible.md`

**Quick Design**:
`design/quick-specs/central-tower-deep-lift-counterweight-ambush-2026-07-12.md`

**Requirements**: `TR-ai-003`, `TR-ai-007`, `TR-ai-008`, `TR-combat-004`,
`TR-combat-007`, `TR-respawn-001`, `TR-respawn-002`, `TR-respawn-005`,
`TR-respawn-006`, `TR-respawn-007`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0001, ADR-0002, ADR-0003, ADR-0004,
ADR-0005, ADR-0006, ADR-0007, ADR-0019, ADR-0021.

Story142 establishes the Deep Lift entrance and newest no-loss Roost. Story143
turns that endpoint into a player-visible motion/combat payoff without inferring
Boss4: one generated fourth viewport, one physics-synchronized moving platform,
one ordinary frame-animated Sentry, one durable clear, and one bounded upper
endpoint.

## Acceptance Criteria

- [x] `central_tower_threshold.tscn` expands to a bounded `5120x720` scene while
  preserving Story140-142 nodes, coordinates, state keys, first three viewport
  collisions, Roosts, combat, cache, hazard, entry, and return. Camera/right/top
  bounds match the fourth viewport.
- [x] A dedicated `CentralTowerDeepLiftController` owns the Story143 route gate,
  physics-synchronized `AnimatableBody2D`, markers, shutters, fall zone, Sentry
  lifecycle, objective, endpoint, attempt reset, durable state, feedback, and
  diagnostics. The parent adds only narrow adapters and state/objective routing.
- [x] Only `central_tower_cooling_shaft_traversed=true` unlocks lift activation;
  the Story141 cache remains optional. Activation requires the real player to
  stand on the lower platform and press established `interact`, then closes both
  shutters once without leaving the player below the departing platform.
- [x] The platform starts at center `(4380,590)`, pauses at `(4380,450)`, and
  docks at `(4380,290)`. Real physics frames move it and carry Cinderpaw with
  bounded relative offset through Godot 4.7's native CharacterBody2D platform
  contract; no direct player teleport or PlayerController modification is used.
- [x] `central_tower_counterweight_sentry` is entity `2703`, data-driven at
  `44` HP with a `24/5/24`-frame, `12`-damage, `120px/s` ram through shared
  Health/Collision/Combat/StatusEffect components. `idle`, `run`, `attack_tell`,
  `attack`, `hurt`, and `death` each use exactly three transparent `96x96`
  frames through `AnimatedSprite2D + SpriteFrames` and mandatory character paths.
- [x] The Sentry activates only at the lock stop after startup/travel/deploy
  grace. Its real hitbox damages the player once per attack, the established
  player attack path damages/defeats entity `2703`, and defeat visibly releases
  the lock stop before the platform continues to the upper landing.
- [x] Lethal fall or combat death before clear uses the existing Tower `1.5s`
  delay and Cooling Roost `(2740,552)` revive at 50% HP with 120 i-frames. An
  uncleared attempt restores lower platform, open shutters, full-HP Sentry,
  authored deployment, and cleared hitboxes/timers without changing abilities.
- [x] Sentry defeat is durable, including the player's death window. Retry and
  fresh restore keep the enemy defeated but return the lift to the lower dock as
  a callable direct ride, preventing a Cooling Roost soft lock below the lift.
- [x] Endpoint `central_tower_deep_lift_upper_endpoint` accepts one nearby
  activation only after a current ride docks and the Sentry is defeated. It
  persists `central_tower_deep_lift_ascended=true`, shows `Deep Lift Secured`,
  and restores without replaying activation, defeat, endpoint, audio, or VFX.
- [x] The generated background, strict six-cell transparent prop/VFX set, and
  strict `3x6` Sentry source meet exact dimensions/import/alpha/anchor contracts,
  retain source/prompt/alpha/preview records, and contain no visible placeholder,
  baked actor/text, magenta spill, or Boss-arena composition.
- [x] One focused RED/GREEN suite, Story141-142 adjacent regression, one target
  smoke, and one final Godot MCP run verify real platform carry, combat, death/
  retry, persistence, animation, generated assets, screenshot, and current-run
  logs. No full suite is required.

## Stable Contract

| Contract | Value |
|----------|-------|
| Scene | `area_05_central_tower` / `central_tower_threshold.tscn` |
| Scene size | `5120x720` |
| Prerequisite | `central_tower_cooling_shaft_traversed` |
| Controller | `CentralTowerDeepLiftController` |
| Sentry | entity `2703` / `central_tower_counterweight_sentry` |
| Sentry clear | `central_tower_counterweight_sentry_defeated` |
| Endpoint | `central_tower_deep_lift_upper_endpoint` |
| Durable completion | `central_tower_deep_lift_ascended` |

## Test Evidence Contract

- Focused suite:
  `tests/unit/gameplay/central_tower_deep_lift_counterweight_ambush_test.gd`
  - Authored fourth-viewport assets, geometry, data, platform, and frame contract.
  - Story142 gate, real physics carry, Sentry attack/player damage, and player
    attack/Sentry damage.
  - Uncleared death reset, death-window durable clear, callable retry ride,
    endpoint, exact abilities, and fresh restore without replay.
- Headless smoke:
  `tests/smoke/central_tower_deep_lift_counterweight_ambush_smoke.gd`; starts
  from Story142 completion and executes only the new lift/death/combat/endpoint
  loop.
- MCP evidence:
  `production/qa/evidence/central-tower-deep-lift-counterweight-ambush-2026-07-12.md`.

## Implementation and Verification

- `CentralTowerDeepLiftController`、实体 `2703`、第四视口碰撞与生成素材已接入
  `area_05_central_tower`；Sentry 六个可见状态均由三帧
  `AnimatedSprite2D + SpriteFrames` 驱动。
- 最终 focused GREEN 为 `report_1520` 的 `3/3`；MCP 发现并修复 Story142
  完成后重试路线的坠落软锁后，`report_1521` 对 Story142-143 通过 `6/6`。
- 目标 smoke 通过；Godot MCP Run `73` 使用真实 `E`、移动与 `J` 输入验证升降台
  携带和玩家攻击，Sentry HP 从 `44` 降至 `32`，当前运行错误与游标后编辑器错误均为空。
- 完整证据见
  `production/qa/evidence/central-tower-deep-lift-counterweight-ambush-2026-07-12.md`
  和对应 Run `73` JSON。

## Out Of Scope

- Boss4 identity, data, arena, phases, reward, music, narrative, or ending.
- New scene id/handoff, fifth viewport, savepoint, ability, reward cache, NPC,
  dialogue, minimap, fast travel, secret room, or reusable platform framework.
- Shared PlayerController, GameFlow, SaveSystem, SceneManager, Ability, Combat,
  Collision, AI, or animation-resource refactors.
- Rebalancing Story139-142 or replaying their complete routes during target QA.

## Dependencies

- Depends on: Story142 Central Tower Cooling Shaft Roost Traverse. Complete.
- Unlocks: a future authored upper-Tower route or Boss approach contract; no
  Boss identity or encounter is implied.

## Completion Notes

**Completed**: 2026-07-12
**Criteria**: 11/11 passing
**Deviations**: None; the MCP-discovered Story142 retry soft lock was fixed and
covered by `report_1521` before closure. Fresh closure regression
`report_1522` passed Story142-143 `6/6`.
**Test Evidence**: Focused and adjacent GdUnit reports, target headless smoke,
Run73 machine evidence, and generated-art gameplay screenshot are retained in
`production/qa/evidence/central-tower-deep-lift-counterweight-ambush-2026-07-12.md`.
**Code Review**: Bounded implementation and integration review complete.
