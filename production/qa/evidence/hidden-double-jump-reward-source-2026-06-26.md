# Hidden Double Jump Reward Source Evidence

Date: 2026-06-26

Story:
`production/epics/player-abilities/story-005-hidden-double-jump-reward-source.md`

## Scope

Implemented the GDD hidden-boss exploration path as a minimal player-visible
reward source: `HiddenDoubleJumpRewardSource` appears in `res://scenes/main.tscn`
as a generated transparent relic sprite. Claiming it once unlocks
`double_jump`, updates the existing Player/AbilityComponent and
`DoubleJumpExplorationGate` runtime path, records
`hidden_boss_echo_double_jump_claimed`, and persists through save/restore.

Out of scope remained full hidden-boss combat, secret-wall discovery, Boss2,
factory transition, minimap updates, and gate dissolve SFX/VFX.

## Generated Asset

- Source: `assets/generated/source/hidden_double_jump_reward_source_imagegen_20260626.png`
- Alpha source: `assets/generated/source/hidden_double_jump_reward_source_alpha_20260626.png`
- Runtime: `assets/environment/double_jump_reward/hidden_double_jump_reward_source.png`
- Import: `assets/environment/double_jump_reward/hidden_double_jump_reward_source.png.import`
- Runtime consumer: `scenes/main.tscn` -> `HiddenDoubleJumpRewardSource/Visual`

Prompt:

```text
Use case: stylized-concept
Asset type: pixel-art game prop sprite for a Godot 2D side-scroller metroidvania reward source
Primary request: Create a transparent-ready isolated sprite on a perfectly flat solid #00ff00 chroma-key background for background removal.
Subject: a cracked rusted vent pedestal holding a floating cat-eye gold wind core, subtle feline paw and sharp cat ear silhouette motifs, pale upward air spiral strokes, mystery purple outer glow, steel gray and rust orange scrap-metal base.
Style: sharp nearest-neighbor pixel art, limited palette, readable at 32x32 pixels, crisp silhouette, side-scroller pickup relic, wasteland feline theme.
Composition: centered subject with generous padding, no floor plane, no cast shadow, no contact shadow, no reflection.
Avoid: no text, no UI, no rectangle frame, no watermark, no realistic rendering, no anti-aliasing, no gradients or texture in the #00ff00 background, do not use #00ff00 anywhere in the subject.
```

Post-processing:

- Chroma-key removal used
  `${CODEX_HOME:-$HOME/.codex}/skills/.system/imagegen/scripts/remove_chroma_key.py`.
- Runtime PNG was cropped from the alpha source and resized to a transparent
  `256x256` nearest-neighbor sprite.
- Godot import ran via `godot --headless --path . --import --quit`.

## Automated Verification

- RED focused: `reports/report_624/`
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd --ignoreHeadlessMode`
  - Result: failed as expected because `HiddenDoubleJumpRewardSource` was
    missing from `scenes/main.tscn`.
- GREEN focused: `reports/report_626/`
  - Same command.
  - Result: `2/2`, `0` errors, `0` failures.
- Related regression: `reports/report_627/`
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd -a res://tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd -a res://tests/unit/gameplay/exploration_dash_gate_runtime_test.gd --ignoreHeadlessMode`
  - Result: `8/8`, `0` errors, `0` failures.
- Headless smoke:
  `reports/hidden_double_jump_reward_source_main_scene_smoke.log`
  - Command:
    `godot --headless --path . --quit-after 1`
  - Result: exit `0`; no script error, invalid call, parse error, missing node,
    missing resource, or resource-load keyword matches. The existing
    cleanup-time ObjectDB/resource warning remains.

## Godot MCP Runtime Evidence

Runtime scene: `res://scenes/main.tscn`

MCP screenshot:
`reports/visual/cinderpaw-mcp-hidden-double-jump-reward-source-20260626.png`

Visual setup probe:

```text
source_claimed=false
source_available=true
source_texture=res://assets/environment/double_jump_reward/hidden_double_jump_reward_source.png
gate_state=locked
player_sprite_class=AnimatedSprite2D
```

Claim/open probe:

```text
initial_gate_state=locked
initial_gate_blocking=true
in_range=true
claim_ok=true
repeat_claim_ok=false
source_claimed=true
source_available=false
player_has_double_jump=true
unlocked_abilities_after_claim=["double_jump"]
gate_state_after_claim=unlockable
gate_blocking_after_claim=true
snapshot_player_abilities=["double_jump"]
snapshot_world_flags={"hidden_boss_echo_double_jump_claimed": true}
activation_ok=true
gate_state_after_activation=unlocked
gate_blocking_after_activation=false
world_flags_after_activation={"area_03_factory_unlocked": true, "gate_double_jump_high_platform_unlocked": true, "hidden_boss_echo_double_jump_claimed": true}
player_sprite_class=AnimatedSprite2D
player_animation=jump
source_texture=res://assets/environment/double_jump_reward/hidden_double_jump_reward_source.png
```

Logs:

- Game log contained only game helper registration and DataManager domain loads.
- Editor log contained `0` entries.

## Result

Story005 acceptance criteria are covered. The game now has a visible hidden-boss
echo reward source for `double_jump`; the reward is no longer only test-driven
or manually unlocked.
