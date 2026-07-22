# Story 210: Old Factory Aftershock Exhaust Escape Production Combat Exit Hatch Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Dual Combat and Route Handoff
> **Type**: Integration + Visual/Feel + Production Combat
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story209 通过真实 breaker interaction 让 Story091 available，但保持双敌
inactive。Story210 将这个边界推进成可玩的双敌逃生战：新鲜右移启动夹击，
Spark/Coil 分别完成真实 bite，玩家通过真实轻攻击形成 partial/full clear，
两具 live death 都保留到 Story092 hatch 接管目标。

## Governing Sources

- GDD: player-abilities, exploration-ability-gating, feline-combat,
  collision-detection, scene-management
- Requirements: TR-scene-004, TR-explore-005, TR-combat-001, TR-respawn-002
- ADR: ADR-0002, ADR-0004, ADR-0005, ADR-0006, ADR-0007
- Dependencies unchanged: ADR-0018, ADR-0021

## Acceptance Criteria

- [x] Story090 已 cut 且 Story091 在帧开始 available 时，新的真实
  move_right 跨过 x 3112 才启动 entities 2134/2135；恢复、瞬移、静止和
  Story090 cut 同帧不能启动。
- [x] Opening staging 以 x 3112 为锚点：Spark x 3256、Coil x 2952、
  y 482，初始中心距 304px；玩家位于两者之间且双方至少保留 128px 横向空间。
- [x] Spark/Coil opening grace 保持 10/22 physics frames；不新增全局
  防重叠或战斗中强制分离系统。
- [x] 两敌继续使用 AnimatedSprite2D + SpriteFrames，已有
  idle/run/attack_tell/attack/hurt/death 多帧动画保持有效。
- [x] Spark 真实 bite 记录 attacker 2134、target 1、weapon
  factory_spark_rat_bite、damage 9；Coil 真实 bite 记录 attacker 2135、
  target 1、weapon factory_coil_rat_bite、damage 10。
- [x] 允许 direct damage 仅作 24 -> 12 非致死 setup；两个独立真实
  attack 经 cat_claw_light 分别击杀 2134 和 2135。
- [x] Partial clear 保留首个三帧 death 的 visible/process，关闭
  physics、target、body collision、bite hitbox 和 hurtbox；幸存敌人继续战斗，
  Story092 仍 hidden、non-interacting、non-blocking。
- [x] Full clear 保留两具 visible/processing live death，关闭双方所有战斗
  碰撞。Story092 变为 available/visible 但 unopened，interaction 和 closed
  blocker 开启，VFX count 保持 0，静止帧不会自动打开。
- [x] Completed-state restore 仍允许隐藏两敌，不重放 death 或 unlock VFX。
- [x] Thin TDD、bounded related、Factory smoke 与 Godot 4.7 /
  Godot AI MCP 3.0.4 真实运行、日志及非空截图验收通过。

## Out Of Scope

Story092 真实开舱交互、全局 enemy separation、AI 重构、新敌人、新角色或环境
素材、新音频/VFX、数值重平衡、SaveSystem schema、service lift、Rat King
Phase III 和后续 cooling duct gameplay。

## Asset Use

无需 image generation。复用现有 image-generated Cinderpaw、Factory Spark
Rat、Factory Coil Rat、Old Factory 环境、exit hatch 与 unlock spark；不修改
PNG、SpriteFrames、import、manifest 或 entity inventory。

## Verification Evidence

- Canonical RED: `reports/report_2270/results.xml`；review-refined RED:
  `reports/report_2271/results.xml`。两者均为 `1` 个 case、`5` 个预期
  failure，最终 RED 精确定位旧 `44px` staging 和 first-corpse
  full-clear visibility/process。
- Focused GREEN: `reports/report_2272/results.xml`，`1/1`。
- Related 首轮 `reports/report_2273/results.xml` 在 `6` 个 case 中只暴露
  `1` 条 Story091 旧的“完整清场立即隐藏首具尸体”断言；更新为 live-death
  契约后，focused `reports/report_2274/results.xml` 为 `2/2`，最终四 suite
  bounded related `reports/report_2275/results.xml` 为 `6/6`，零
  failure/error/flaky/skip/orphan。
- Factory `180` 帧 headless smoke
  `reports/old_factory_aftershock_exhaust_escape_skirmish_production_combat_exit_hatch_handoff_smoke.log`
  退出 `0`，项目错误关键字为空；未运行 full suite。
- Godot 4.7 / Godot AI MCP 3.0.4 accepted run `r142990853-69` 使用真实
  `move_right` 启动夹击，验证 `2952/3112/3256` 站位、`10/22` grace、
  Spark/Coil 真实 bite `9/10`，并用四次真实 `attack` 完成两组
  `24 -> 12 -> 0`。Partial/full death 均关闭战斗碰撞；完整清场时双尸体
  `death`、visible/process on，Story092 visible/interactive/blocking、
  `opened=false`、VFX count `0`，静止后仍未自动打开。
- Accepted game log 只有 helper registration info，editor log 为空，输入全部
  released；非空 RGB `1278x718` MCP 截图及本地截图：
  `reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-escape-skirmish-production-combat-exit-hatch-handoff-cleared-20260722.png`。

## Dependencies

- Depends on: Stories 090, 091, 092, 209.
- Unlocks: Story092 production movement/interact/open handoff.
