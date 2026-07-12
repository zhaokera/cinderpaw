# Story 144: Central Tower Apex Conduit Purge Run

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Traversal / Save-Respawn / Visual
> **Type**: Integration + Gameplay Runtime + Environmental Hazard + Save/Respawn + Visual
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-12

## Context

**GDD**: `design/gdd/game-concept.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/player-abilities.md`,
`design/gdd/health-death.md`, `design/gdd/death-respawn.md`,
`design/gdd/scene-management.md`, `design/art/art-bible.md`

**Quick Design**:
`design/quick-specs/central-tower-apex-conduit-purge-run-2026-07-12.md`

**Requirements**: `TR-respawn-001`, `TR-respawn-002`, `TR-respawn-005`,
`TR-respawn-006`, `TR-respawn-007`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0001, ADR-0002, ADR-0003, ADR-0004,
ADR-0005, ADR-0007, ADR-0018, ADR-0019, ADR-0021.

Story143 把 Cinderpaw 送到 Deep Lift 上层。Story144 在不猜测 Boss4 的前提下，
把这个端点接成玩家可见、可失败、可重试的 ACT 追逐：一个公平 Roost、一个有
预警的移动净化墙、利用已有移动能力的第五视口，以及一个耐久的 Apex Approach
终点。

## Acceptance Criteria

- [x] `central_tower_threshold.tscn` 扩展为有边界的 `6400x720` 场景，新增第五
  背景、入口/下层/上层/终点平台、磁性脊柱、坠落区、Roost、净化墙和终点；
  Story140-143 节点、坐标、碰撞、状态和玩法保持不变。Camera/right/top 边界
  与第五视口一致。
- [x] 独立 `CentralTowerApexPurgeController` 持有 Story144 门槛、Roost、
  trigger、`0.75s` 警告、`150px/s` 净化墙、坠落、终点、尝试重置、耐久状态、
  objective、feedback 和 diagnostics；父场景只提供窄适配与状态/目标路由。
- [x] 只有 `central_tower_deep_lift_ascended=true` 才开放本路线。玩家靠近
  `(5260,252)` 激活 `central_tower_apex_roost` 后只触发一次 full heal、autosave、
  audio/VFX，并将其设为 Tower 最新复活点。
- [x] 玩家在已激活 Roost 的前提下越过 x `5360` 才启动当前尝试；净化墙先保持
  在 x `5200` 完成警告，再以确定速度向右移动。未完成/未解锁/未激活 Roost 时
  不启动，完成后永久禁用。
- [x] 净化墙真实接触和底部坠落通过玩家 `apply_damage` 造成致死结果，并进入
  既有 Tower `1.5s` 死亡节拍；复活为 50% HP、120 i-frames、位置
  `(5260,252)`，能力列表完全不变。
- [x] 未完成死亡会保留 Apex Roost 和 Story140-143 的耐久结果，但重置 trigger、
  警告、净化墙位置、接触计数和当前追逐反馈，允许立即重试且不会软锁。
- [x] `central_tower_apex_approach_endpoint` 只在当前尝试已启动且玩家靠近
  `(6280,296)` 时接受一次交互；持久化 `central_tower_apex_approach_secured=true`，
  关闭危险并显示 `Apex Approach Secured`。
- [x] fresh restore 恢复 Apex Roost、最新复活点和完成状态，保留精确能力与
  Story140-143 状态，且 activation/trigger/contact/endpoint/autosave/audio/VFX
  反馈计数全部归零、不重放。
- [x] image generation 生成第五背景、Apex Roost、磁性脊柱、净化发射器、终点
  信标和净化墙；运行时尺寸/alpha、source、prompt、alpha、preview、asset spec、
  manifest 和 inventory 记录完整，不含占位方块、文字、角色或 Boss arena 构图。
- [x] 一个三用例 focused RED/GREEN、Story143 相关回归、一个 target smoke 和
  一次 Godot MCP 实玩验收覆盖真实移动触发、Roost、净化墙推进、致死复活、终点、
  持久化、素材可见性、非空截图与当前运行日志；不要求 full suite。

## Stable Contract

| Contract | Value |
|----------|-------|
| Scene | `area_05_central_tower` / `central_tower_threshold.tscn` |
| Scene size | `6400x720` |
| Prerequisite | `central_tower_deep_lift_ascended` |
| Controller | `CentralTowerApexPurgeController` |
| Roost / spawn | `central_tower_apex_roost` / `(5260,252)` |
| Purge start / speed | x `5200` / `150px/s` after `0.75s` warning |
| Endpoint | `central_tower_apex_approach_endpoint` / `(6280,296)` |
| Durable completion | `central_tower_apex_approach_secured` |

## Test Evidence Contract

- Focused suite:
  `tests/unit/gameplay/central_tower_apex_conduit_purge_run_test.gd`
  - Generated assets, fifth-viewport geometry, scene bounds and controller contract.
  - Story143 gate, Roost/autosave, trigger warning, deterministic wall movement and lethal contact.
  - Death/revive reset, exact abilities, endpoint and fresh restore without feedback replay.
- Headless smoke:
  `tests/smoke/central_tower_apex_conduit_purge_run_smoke.gd`; starts from Story143
  completion and executes only the new Roost/purge/death/endpoint loop.
- MCP evidence:
  `production/qa/evidence/central-tower-apex-conduit-purge-run-2026-07-12.md`.

## Out Of Scope

- Boss4 identity, data, arena, phases, reward, music, narrative, ending, or scene handoff.
- New enemy, character, SpriteFrames, ability, weapon, Charm, reward cache, NPC,
  dialogue, minimap, fast travel, or secret room.
- Shared PlayerController, GameFlow, SaveSystem, SceneManager, Ability, Combat,
  Collision, AI, or animation-resource refactors.
- Rebalancing Story139-143 or replaying the full Tower route during target QA.

## Dependencies

- Depends on: Story143 Central Tower Deep Lift Counterweight Ambush. Complete.
- Unlocks: an authored Boss4 approach/handoff or another approved upper-Tower
  continuation; no Boss identity or encounter is implied.

## Implementation

- `CentralTowerApexPurgeController` owns the Story143 gate, Apex Roost,
  warning/pursuit phases, deterministic moving wall, lethal fall, retry reset,
  durable endpoint, objective routing and diagnostics. The parent Tower scene
  exposes narrow adapters and merges durable state into the existing save and
  no-loss respawn flow.
- `central_tower_threshold.tscn` is now a bounded `6400x720` five-viewport scene
  with authored collision for the entry deck, lower catwalk, magnetic spine,
  upper catwalk, endpoint deck, trigger and fall zone.
- Built-in image generation supplied the fifth background and five runtime
  props/VFX. Source, exact prompts, alpha intermediate, asset spec, manifest,
  inventory and QA evidence are retained in the project asset pipeline.

## Test-Criterion Traceability

| AC | Evidence | Status |
|----|----------|--------|
| 1. Fifth viewport and old route preservation | focused case 1; Story143-144 related regression | COVERED |
| 2. Dedicated controller and narrow parent adapters | focused cases 1-2; integrator source review | COVERED |
| 3. Story143 gate and one-shot Roost/autosave | focused case 2 | COVERED |
| 4. Trigger, warning and deterministic wall movement | focused case 2; MCP Run74/75 | COVERED |
| 5. Wall/fall death, 50% revive and 120 i-frames | focused cases 2-3; target smoke | COVERED |
| 6. Durable Roost plus attempt-local reset | focused case 3; target smoke | COVERED |
| 7. One-shot endpoint and danger shutdown | focused case 3; target smoke | COVERED |
| 8. Fresh restore without replay | focused case 3; target smoke | COVERED |
| 9. Generated-asset pipeline and visible result | focused case 1; asset spec/manifest/inventory; MCP screenshot | COVERED |
| 10. Bounded automated and MCP validation | RED `report_1523`; GREEN `report_1528`; related `report_1529`; smoke; MCP Run75 | COVERED |

## Verification

- Expected RED: `reports/report_1523/results.xml`, exit `100` before production
  implementation and assets existed.
- Fresh focused GREEN: `reports/report_1528/report_1/results.xml`, `3/3`,
  `0` error, `0` failure, `0` skipped, exit `0`.
- Fresh Story143-144 related GREEN:
  `reports/report_1529/report_1/results.xml`, `6/6`, `0` error, `0` failure,
  `0` skipped, exit `0`.
- Target smoke: exit `0`,
  `central_tower_apex_conduit_purge_run_smoke=passed`.
- Godot AI MCP `2.9.1` / Godot `4.7-stable` final Run75 returned
  `current_run_errors=[]`, added no editor rows after cursor `8`, inspected live
  Cinderpaw `AnimatedSprite2D`, and captured the non-empty generated-art frame
  recorded in
  `production/qa/evidence/central-tower-apex-conduit-purge-run-2026-07-12.md`.

## Completion Notes

**Completed**: 2026-07-12

**Verdict**: COMPLETE WITH NOTES

**Criteria**: 10/10 passing; no deferred acceptance criteria.

**Deviations**: None from the approved quick spec. Boss4 remains explicitly out
of scope.

**Test Evidence**: Integration-focused GdUnit, adjacent regression, target
headless smoke and Godot MCP visual/runtime evidence are present at the paths
above.

**Code Review**: Integrator review completed and found one missing direct fall
assertion; coverage was added and all bounded checks rerun. Two requested
read-only full-review agents failed before reading files because the backend
rewrote their effort to unsupported `max`, so no independent-agent approval is
claimed.
