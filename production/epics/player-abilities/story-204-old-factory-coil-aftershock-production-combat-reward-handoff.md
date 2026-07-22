# Story 204: Old Factory Coil Aftershock Production Combat Reward Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat and Reward Handoff
> **Type**: Integration + Gameplay Runtime + Production Combat + Production Input + Reward
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story202/203 make the Story082 pincer playable and readable, while Story083 and
Story084 already define the follow-up Coil Rat and once-only reward cache. This
Story closes the production path between those contracts: a fresh forward move
starts entity `2128`, a real player attack clears it, and a real `interact`
claims the immediately unlocked cache without calling test-only activation or
claim APIs for the player-facing transitions.

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/feline-combat.md`,
`design/gdd/health-death.md`, `design/gdd/collision-detection.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-combat-001`, `TR-combat-004`, `TR-scene-004`,
`TR-explore-005`, `TR-respawn-002`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management; ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] With Story082 cleared, entity `2128` remains inactive until a fresh real
  `move_right` advances the player and reaches activation x `2144`.
- [x] Activation restores entity `2128` visible/targeted process and physics,
  `normal` hurtbox, `24 HP`, opening grace `8`, and HUD
  `Contain Coil Aftershock`.
- [x] A real `Input.attack` activates `cat_claw_light` and can deliver the lethal
  hit through production Combat/Weapon/Collision routing; the canonical test
  uses direct damage only for deterministic nonlethal `24 -> 12` setup.
- [x] Defeat persists Story083 clear and immediately removes physics, body
  collision, target and hurtbox while preserving visible/process three-frame
  `death` presentation.
- [x] Story084 cache becomes visible and claimable immediately on defeat rather
  than waiting for the death animation, and shows `+20 Gears`.
- [x] A fresh real `Input.interact` claims the Story084 cache through production
  nearest-cache arbitration. Held or repeated input cannot duplicate the
  once-only `gears=20` payload, feedback or persistence.
- [x] Cache claim makes Story085 available but does not auto-activate it, replay
  Story071 cache audio, activate the service lift, or request a scene exit.
- [x] Story085 partial/full defeat preserves both existing RatMinion death
  presentations while disabling combat capability; restored completed state
  keeps those enemies hidden.
- [x] No visual or audio assets are added. Existing image-generated Cinderpaw,
  Factory Coil Rat, reward cache and Factory environment remain in use.
- [x] Thin RED/GREEN, six-suite bounded regression, Factory smoke, and Godot
  4.7 / Godot AI MCP 3.0.4 runtime/log/screenshot acceptance pass.

## Out Of Scope

Global wallet/currency mutation beyond the established Factory reward payload,
new enemy or cache art, new audio, RatMinion shared timing changes, Story085
production movement/combat, Story086 production handoff, SaveSystem schema,
service-lift routing, map expansion, Boss2 and broader Factory route cleanup.

## Implementation Notes

- `_try_claim_nearest_factory_progression_reward_cache()` includes Story084's
  cache and existing claim method, preserving the stable nearest-distance and
  rising-edge input contracts.
- Story083 activation, combat, death and cache unlock continue to use existing
  production nodes and APIs; no duplicate encounter or reward implementation is
  introduced.
- Story085 defeat callbacks now prepare only the defeated enemy for death and
  synchronize only a surviving partner. This avoids a second callback hiding
  the first corpse while retaining restore-time full-state synchronization.
- The established Factory reward contract persists a `gears=20` payload and
  exact source/feedback. Global economy crediting remains a separate slice.

## Asset Use

No image generation was required. The Story reuses the registered
image-generated Factory Coil Rat `AnimatedSprite2D + SpriteFrames`, Cinderpaw,
reward cache and Factory environment. No PNG, SpriteFrames, source/import,
manifest or entity-inventory files changed.

## Verification Evidence

- Canonical RED `reports/report_2222/results.xml` failed `0/1` only at the real
  `interact` claim, proving Story084 was absent from production reward
  arbitration after real movement/combat/death already succeeded.
- Focused GREEN `reports/report_2223/results.xml` passed `1/1`; initial bounded
  related `reports/report_2224/results.xml` passed five suites `8/8`.
- Downstream Story085 check `reports/report_2225/results.xml` exposed inconsistent
  dual-death visibility. Clean behavior RED `reports/report_2227/results.xml`
  failed only the first corpse visible/process assertions; focused GREEN
  `reports/report_2228/results.xml` passed `3/3`.
- Final bounded related `reports/report_2229/results.xml` passed six suites and
  `11/11` tests with zero failure, error, flaky, skip or orphan. No full suite
  was run.
- Godot 4.7 Factory `180`-frame headless smoke exited `0`; log:
  `reports/old_factory_coil_aftershock_production_combat_reward_handoff_smoke.log`.
  Shutdown retained the established `4 ObjectDB / 2 resources` baseline and no
  project script/parse/resource error.
- Godot MCP 3.0.4 accepted Story204 run `r126495992-46` used real movement, real
  lethal attack and real interact to activate `2128`, clear it during visible
  `death`, claim the cache once, and leave Story085 available/inactive.
- Accepted downstream run `r127439409-49` confirmed both Story085 death sprites
  visible/process with physics/target/hurtbox disabled. Its non-empty RGB
  `1278x718` screenshot showed the Factory scene and clear HUD; game log had only
  helper registration and editor log was empty. The editor returned to ready.
- Full evidence:
  `production/qa/evidence/old-factory-coil-aftershock-production-combat-reward-handoff-2026-07-21.md`.

**Status**: [x] Complete.

## Dependencies

- Depends on: Stories 082, 083, 084, 192, 202 and 203.
- Unlocks: Story085 production movement/combat and Story086 handoff.
