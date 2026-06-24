# Story 009: Runtime Enemy Attack + Shadow Beast Frame Animation

> **Epic**: Feline Combat
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration / Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/feline-combat.md`, `design/gdd/collision-detection.md`,
`design/gdd/health-death.md`, `design/gdd/combat-presentation.md`
**Requirements**: `TR-combat-006`, `TR-collision-005`, `TR-health-001`,
enemy readability gaps from `design/assets/entity-inventory.md`

**ADR Governing Implementation**: ADR-0002: Signal communication; ADR-0004:
Collision detection architecture; ADR-0005: Combat state machine architecture

Story 008 made the player attack path use Core Combat/Collision/Health/Weapon
components. The vertical slice still lacks reciprocal combat pressure: the
runtime enemy patrols and deals only prototype contact damage. It also still
uses a static `Sprite2D` visual, which makes the game read as a prototype even
after Cinderpaw gained frame animation.

## Acceptance Criteria

- [x] `SimpleEnemy` can start a deterministic attack sequence with
  `attack_tell -> attack -> recovery` timing and cooldown.
- [x] Enemy attack activates a Core `CollisionComponent` hitbox that can damage
  the runtime player through `HealthComponent`, not prototype contact damage.
- [x] Duplicate-hit tracking prevents the same enemy hitbox activation from
  damaging the player twice.
- [x] Runtime enemy hit metadata reaches MainScene/CombatPresentation for
  hit feedback without making Core call Presentation directly.
- [x] Enemy visual node named `Sprite` is an `AnimatedSprite2D` backed by
  `SpriteFrames`, not a static `Sprite2D`.
- [x] Shadow Beast frames are image-generated, transparent, same-size,
  continuously named PNGs under
  `assets/characters/shadow_beast/<animation>/`.
- [x] `scenes/characters/shadow_beast.tscn` and
  `src/characters/shadow_beast.gd` exist and provide at least `idle`, `patrol`,
  `attack_tell`, `attack`, `hurt`, and `death` animations.
- [x] Godot MCP runs `res://scenes/main.tscn`, verifies enemy attack damage,
  SpriteFrames state, logs, and captures nonblank runtime screenshots.

## Out of Scope

- Full AI attack pattern scheduling beyond the current one-enemy runtime slice.
- New enemy types, summoned minions, boss-specific phase logic, or arena changes.
- Animation-frame-authored hitbox timing beyond deterministic tell/active/recovery
  constants in `SimpleEnemy`.
- Audio.

## Test Evidence

**Required evidence**:
- `tests/unit/gameplay/simple_enemy_character_animation_test.gd`
- `tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd`

**GREEN evidence**:
- `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd --ignoreHeadlessMode`
  - Result: `5/5` passing, exit `0`.
- Focused regression:
  `story_007_hit_confirmation_focus_damage_metadata_test.gd`,
  `main_scene_player_attack_core_chain_test.gd`,
  `simple_enemy_character_animation_test.gd`, and
  `main_scene_enemy_attack_core_chain_test.gd`
  - Result: `12/12` passing, exit `0`.

**MCP runtime evidence**:
- Session: `cinderpaw@c1b2`
- Scene: `res://scenes/main.tscn`
- Probe: `request_attack = true`, enemy `$Sprite = AnimatedSprite2D`,
  `sprite_animation = attack`, `active_after_tell = true`, player HP
  `100 -> 88`, `final_damage = 12`, damage numbers `0 -> 1`.
- Logs: game log contained only the Godot AI helper registration line; editor
  log returned `0` error lines after clearing.
- Screenshot:
  `reports/visual/cinderpaw-mcp-enemy-attack-animation-runtime-20260624.png`

**Status**: [x] RED/GREEN + MCP runtime evidence complete

## Dependencies

- Depends on: Feline Combat Story 008 Runtime Player Attack Core Chain.
- Unlocks: reciprocal combat pressure, richer enemy AI scheduling, enemy attack
  telegraph tuning, and boss/minion runtime readability.
