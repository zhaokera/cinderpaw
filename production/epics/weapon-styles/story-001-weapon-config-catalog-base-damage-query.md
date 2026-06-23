# Story 001: Weapon Config Catalog + Base Damage Query

> **Epic**: Weapon Styles
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/weapon-styles.md`
**Requirement**: `TR-weapon-001`, `TR-weapon-004`

**ADR Governing Implementation**: ADR-0016: Weapon styles architecture;
ADR-0003: Data management
**ADR Decision Summary**: Weapon data is JSON source data loaded through
DataManager into a typed WeaponConfig bridge. WeaponComponent owns current weapon
and level queries while remaining a Core scene component.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Pure GDScript Resource and Node classes; verify typed arrays
and required return values through headless tests.

**Control Manifest Rules (Core)**:
- Required: Core systems are scene components, not Autoloads.
- Required: Data source is JSON validated by SchemaValidator.
- Forbidden: Do not put visual/audio/UI behavior in WeaponComponent.
- Guardrail: Core component queries must be testable without full scenes.

## Acceptance Criteria

- [x] `WeaponComponent` instantiates without a full Player scene.
- [x] `data/weapons/weapon_configs.json` defines exactly four weapon entries:
  `cat_claw`, `long_tail`, `fish_bone`, and `electro_bell`.
- [x] Each weapon exposes display name, style, damage range, attack speed, attack
  range, combo multipliers, upgrade damage table, special id, cooldown,
  special multiplier, special mechanism, and hitbox data.
- [x] The weapon configs validate through `data/schemas/weapon_configs.schema.json`.
- [x] Default current weapon is `cat_claw` and its level-1 base damage is 10.
- [x] Given Cat Claw is set to level 3, querying base damage returns 14.

## Implementation Notes

Create `src/core/weapon_config.gd`, `src/core/weapon_component.gd`,
`data/weapons/weapon_configs.json`, and `data/schemas/weapon_configs.schema.json`.
Register the `weapon_configs` domain in `data/manifest.json`.

Use existing canonical weapon ids from `damage_params.json` and CombatComponent:
`cat_claw`, `long_tail`, `fish_bone`, `electro_bell`.

## Out of Scope

- Story 002: mutable upgrade flow and serialization payloads.
- Story 003: weapon swap timing and CombatComponent reset hooks.
- Story 004: special attack execution and cat-energy gates.
- Stories 005-008: weapon-specific hit callbacks.

## QA Test Cases

- **AC-1**: Component construction.
  - Given: a new WeaponComponent.
  - When: it is added to a test tree.
  - Then: it loads configs and defaults to Cat Claw.

- **AC-2**: Data/schema validation.
  - Given: project weapon config data and schema.
  - When: SchemaValidator validates the domain.
  - Then: validation succeeds and the manifest registers `weapon_configs`.

- **AC-3**: Catalog completeness.
  - Given: the weapon catalog.
  - When: weapon ids are queried.
  - Then: exactly four canonical weapon ids are returned in swap order.

- **AC-4**: Cat Claw damage query.
  - Given: Cat Claw is set to level 3.
  - When: effective base damage is queried.
  - Then: the result is 14.

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/weapon/story_001_weapon_config_catalog_test.gd` must exist
  and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Component construction | `tests/unit/weapon/story_001_weapon_config_catalog_test.gd::test_weapon_component_and_config_scripts_exist` | COVERED |
| AC-2: Data/schema validation and manifest registration | `tests/unit/weapon/story_001_weapon_config_catalog_test.gd::test_weapon_config_data_validates_and_manifest_registers_domain` | COVERED |
| AC-3: Four weapon ids in swap order | `tests/unit/weapon/story_001_weapon_config_catalog_test.gd::test_catalog_defines_four_weapons_in_swap_order` | COVERED |
| AC-4: Weapon GDD metadata exposed | `tests/unit/weapon/story_001_weapon_config_catalog_test.gd::test_weapon_configs_expose_gdd_metadata` | COVERED |
| AC-5: Cat Claw level-3 damage query | `tests/unit/weapon/story_001_weapon_config_catalog_test.gd::test_default_weapon_and_cat_claw_level_three_damage_query` | COVERED |

## Dependencies

- Depends on: Data Manager Complete, Damage Calculator Complete,
  Feline Combat Complete.
- Unlocks: Story 002 Weapon Upgrade State + Serialization Prep.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 passing
**Deviations**: None. Canonical ids follow existing CombatComponent and
`damage_params.json`: `cat_claw`, `long_tail`, `fish_bone`, `electro_bell`.

**Implementation**:
- Added `src/core/weapon_config.gd` as a typed Resource bridge for weapon JSON.
- Added `src/core/weapon_component.gd` as a Core scene component with catalog,
  current-weapon, attack-parameter, and base-damage queries.
- Added `data/weapons/weapon_configs.json` and
  `data/schemas/weapon_configs.schema.json`.
- Registered `weapon_configs` as a preloaded DataManager domain.

**Test Evidence**:
- RED: `reports/report_274/` failed because WeaponComponent and WeaponConfig did
  not exist.
- GREEN: `reports/report_276/` Story001 suite 5/5 passing.
- Weapon suite: `reports/report_277/` 5/5 passing.
- Regression: `reports/report_278/` full `tests/unit` suite 284/284 passing.

**Runtime Evidence**:
- `reports/weapon_story001_project_boot.log`
- `reports/weapon_story001_main_scene_smoke.log`
- Both commands exited 0 and logs show `[godot_ai game_helper] registered mcp capture`
  with no `ERROR`, `SCRIPT ERROR`, `Invalid call`, `Parse Error`, or `WARNING`
  matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed.
- Related source, data, schema, tests, and Story/Epic docs have no trailing whitespace.
- Related source and tests have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0003,
ADR-0016, Control Manifest Core/Data rules, TR-weapon-001, TR-weapon-004, and
Story001 acceptance criteria. Full specialist sub-agent gates were not spawned
because the active Codex multi-agent tool policy requires an explicit user
request for delegation.
