# Boss2 Run Frame Animation Runtime Evidence

Date: 2026-06-30
Story: `production/epics/player-abilities/story-025-boss2-run-frame-animation-runtime.md`

## Asset Generation

Mode: built-in image generation with local chroma-key removal.

Prompt summary:

```text
Create a 3-frame pixel-art run animation strip for Boss2 Echo Guardian, a
side-view cyber feline boss charging toward the player. Keep scrap-metal armor,
cat ears, clawed paws, glowing violet-gold echo core, glowing eye, aggressive
forward lean, three distinct run poses, consistent scale/baseline/anchor, and a
flat solid #00ff00 chroma-key background with no text, UI, shadows, scenery, or
extra frames.
```

Generated source retained:

- `assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_run_sheet_imagegen_20260626.png`
- `assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_run_sheet_alpha_20260626.png`

Runtime frames:

- `assets/characters/boss2_echo_guardian/run/boss2_echo_guardian_run_000.png`
- `assets/characters/boss2_echo_guardian/run/boss2_echo_guardian_run_001.png`
- `assets/characters/boss2_echo_guardian/run/boss2_echo_guardian_run_002.png`

Local validation confirmed all three runtime frames are `160x128` RGBA PNGs with
transparent corners. Visible green-edge residue was cleared before Godot import.

## Automated Evidence

- RED focused: `reports/report_791/`
  - `boss2_autonomous_pressure_runtime_test` failed because chase still played
    `idle` and lacked the `run` SpriteFrames animation.
- GREEN focused: `reports/report_796/`
  - `boss2_autonomous_pressure_runtime_test`: `6/6`.
- Boss2 asset/payoff regression: `reports/report_798/`
  - `boss2_double_jump_payoff_runtime_test`: `3/3`.
- Boss2 HUD regression: `reports/report_797/`
  - `boss2_hud_focus_runtime_test`: `4/4`.
- Boss2 telegraph regression rerun: `reports/report_799/`
  - `boss2_echo_guardian_telegraph_strike_test`: `4/4`.

## Import And Smoke

- `godot --headless --path . --import --quit` exited `0`.
- `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/boss2_run_frame_animation_runtime_main_scene_smoke.log` exited `0`.
- Smoke log keyword scan found no script, parse, invalid-call, missing-resource,
  or resource-load errors.

## Godot MCP Runtime Evidence

Godot MCP state:

- Godot version: `4.6.3-stable`.
- Scene: `res://scenes/main.tscn`.
- Runtime node: `/Main/Boss2EchoGuardian/Sprite`.
- Runtime type: `AnimatedSprite2D`.
- SpriteFrames path:
  `res://assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres`.

MCP probe confirmed:

- `run` animation exists, loops, and has 3 frames.
- `run` frame paths point to `res://assets/characters/boss2_echo_guardian/run/`.
- All `run` frame sizes are `160x128`.
- After one deterministic chase frame, Boss2 reports
  `behavior_phase="chase"`, `is_chasing=true`, `sprite.animation="run"`,
  `sprite.is_playing()=true`, `boss_x_delta=-3`, and `distance_delta=-3`.
- During sustained deterministic chase, an already advanced run frame
  (`frame=1`, `frame_progress=0.25`) remained at `frame=1` and
  `frame_progress=0.25` after 25 behavior frames, proving `_play_animation()`
  did not restart the run animation back to frame `0`.
- Startup returns to `sprite.animation="attack"` while `boss2_echo_swipe` is
  inactive.
- Active hit damages Player `100 -> 86`, and duplicate detection in the same
  active window preserves HP at `86`.
- Restored defeated flag reports `behavior_phase="defeated"`, `is_chasing=false`,
  `visible=false`, and leaves animation on `death` rather than `run`.
- After clearing the earlier eval-script error from the debugger, game log had
  only helper/DataManager info lines and editor log had no errors.

Screenshot evidence:

- `reports/visual/cinderpaw-mcp-boss2-run-frame-animation-runtime-20260626.png`
  is `1280x720` and nonblank, with Boss2 visible during chase/run.
