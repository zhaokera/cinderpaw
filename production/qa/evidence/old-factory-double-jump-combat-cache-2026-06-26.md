# QA Evidence: Old Factory Double Jump Combat Cache

Date: 2026-06-26
Story: `production/epics/player-abilities/story-008-old-factory-double-jump-combat-cache.md`

## Scope

Story008 adds a small ACT-visible reward loop inside the existing Old Factory
entrance room: a Double Jump-height upper platform with an image-generated
combat cache. The cache starts locked while the Factory Rat Minion is alive,
unlocks when the room is cleared, grants a deterministic `+10 Gears` payload
once, and persists clear/claimed state through `OldFactoryEntranceScene`
scene-local state.

Out of scope remains unchanged: no new enemy family, no deeper multi-room Old
Factory layout, no Boss2, no new ability, and no SaveSystem schema rewrite.

## Asset Evidence

Runtime asset:

- `res://assets/environment/old_factory_combat_cache/factory_combat_cache.png`

Source assets:

- `assets/generated/source/factory_combat_cache_imagegen_20260626.png`
- `assets/generated/source/factory_combat_cache_alpha_20260626.png`

Generation prompt summary:

- Pixel-art 2D side-scroller Old Factory combat cache prop.
- Rusted lockbox / loot cache with cat-paw latch and glowing cat-eye gold core.
- Cool blue factory rim light, restrained rust-orange wear, no characters, no
  UI, no text.
- Generated on a flat `#00ff00` chroma-key background, then alpha-matted with
  local chroma-key removal and cropped/resized to a transparent 256x256 runtime
  PNG.

Import evidence:

- `godot --headless --path . --import --quit`
- Godot import registered `FactoryCombatCache` and refreshed generated cache
  PNG import metadata.

Manifest evidence:

- `design/assets/asset-manifest.md` records `factory_combat_cache`.
- `design/assets/entity-inventory.md` records `Old Factory Combat Cache`.

## Automated Test Evidence

RED:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd --ignoreHeadlessMode -rd res://reports -c`
- Result: `reports/report_648/` failed as expected because the factory scene had
  no generated cache texture, `FactoryCachePlatform`, `FactoryCombatCache`,
  room-clear API, or local scene state API.

GREEN focused:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd --ignoreHeadlessMode -rd res://reports -c`
- Result: `reports/report_650/` passed `3/3`.

Related regression:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd -a res://tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd -a res://tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd -a res://tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd --ignoreHeadlessMode -rd res://reports -c`
- Result: `reports/report_651/` passed `23/23`.
- Note: The process still reported existing cleanup-time ObjectDB/resource
  messages at exit; test cases and runtime logs were clean.

## Headless Smoke Evidence

Commands:

- `godot --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --quit-after 2 --log-file reports/old_factory_double_jump_combat_cache_factory_scene_smoke.log`
- `godot --headless --path . --scene res://scenes/main.tscn --quit-after 2 --log-file reports/old_factory_double_jump_combat_cache_main_scene_smoke.log`

Result:

- Both commands exited `0`.
- Keyword scans found no script parse, invalid call, missing resource, or
  resource-load errors in the smoke logs.
- Known cleanup-time ObjectDB/resource messages remain limited to process exit.

## Godot MCP Runtime Evidence

Scene:

- `res://scenes/factory_route_transition_shell.tscn`

Runtime tree evidence:

- Root scene: `FactoryRouteTransitionShellScene`
- Scene id: `area_03_factory`
- New nodes visible in runtime tree:
  - `FactoryCachePlatform`
  - `FactoryCombatCache`
  - `FactoryCombatCache/Visual`
  - `FactoryCombatCache/PromptLabel`
  - `FactoryCombatCache/InteractionArea`

Runtime probe evidence:

- `Player/Sprite`: `AnimatedSprite2D`
- `FactoryRatMinion/Sprite`: `AnimatedSprite2D`
- Rat Minion frame counts: `idle=3`, `run=3`, `attack=3`
- Cache texture:
  `res://assets/environment/old_factory_combat_cache/factory_combat_cache.png`
- Initial cache state:
  - `encounter_cleared=false`
  - `cache_available=false`
  - `cache_claim_available=false`
  - `claim_before_clear=false`
- After `FactoryRatMinion.kill_summon()`:
  - `encounter_cleared=true`
  - `cache_available=true`
  - `cache_claim_available=true`
- After moving player to cache and claiming:
  - `claim_ok=true`
  - `duplicate_claim=false`
  - `cache_claimed=true`
  - `last_cache_reward={"cache_id":"old_factory_entrance_cache","gears":10,"source":"old_factory_combat_cache"}`
  - `get_local_state()` captures `encounter_cleared=true` and
    `factory_cache_claimed=true`

MCP logs:

- Final `logs_read(source="all")` returned plugin/game info lines only.
- No game/editor script errors, invalid calls, missing resources, or runtime
  errors were reported after the successful fresh probe.

Screenshot:

- `reports/visual/cinderpaw-mcp-old-factory-double-jump-combat-cache-20260626.png`
- The screenshot is 1280x720 and shows the generated Factory cache, upper
  platform position, Cinderpaw, and the Old Factory backdrop.

## Verdict

PASS. Story008 satisfies the focused ACT-visible slice requirements: it adds a
non-placeholder generated reward prop, a Double Jump-height platform, a
clear-to-claim combat loop, deterministic once-only payload behavior, local
state persistence, and MCP runtime verification.
