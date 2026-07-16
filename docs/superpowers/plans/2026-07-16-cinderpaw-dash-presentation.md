# Cinderpaw Dedicated Dash Presentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give a successful Cinderpaw Dash a dedicated two-afterimage trail,
authored speed-line burst, and separate wind SFX while preserving Dodge.

**Architecture:** Keep `PlayerController.dash_started` as the Core boundary.
MainScene routes it to new Presentation-only `on_dash_event` methods in
CombatPresentation and AudioSystem. Dash VFX use their own diagnostics and
lifecycle bucket; the generated texture and deterministic audio cue enter the
existing Godot import pipelines.

**Tech Stack:** Godot 4.7, GDScript, GdUnit4, built-in image generation,
44.1 kHz mono PCM16 WAV, Godot AI MCP 3.0.2.

---

### Task 1: Freeze The Presentation Contract

**Files:**
- Modify: `design/gdd/combat-presentation.md`
- Create: `design/assets/specs/cinderpaw-dedicated-dash-presentation.md`

- [x] Specify two decreasing-alpha afterimages at 20/40 px behind the player,
  `10/60s` lifetime, one world-space speed-line burst with `6/60s` lifetime,
  and a separate non-looping `sfx_dash` wind cue.
- [x] Keep Dash gameplay values, Dodge, Parry, camera, hitstop, gates, save and
  HUD explicitly out of scope.

### Task 2: Write One Meaningful RED

**Files:**
- Create: `tests/unit/gameplay/main_scene_player_dash_presentation_test.gd`

- [x] Instantiate Main, unlock and request the real Dash, then assert a
  dedicated Main route, two Dash afterimages, one textured speed-line burst,
  deterministic expiry, and `dash/sfx_dash` audio metadata.
- [x] Assert Dodge-specific counts are zero during the Dash sample.
- [x] Run only the new suite and verify failure because the current Main route
  still calls `on_dodge_event` twice.

Run:
```bash
'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/main_scene_player_dash_presentation_test.gd \
  --ignoreHeadlessMode -rd res://reports -c
```

### Task 3: Generate And Import Presentation Assets

**Files:**
- Create: `assets/generated/combat_dash_speed_lines.png`
- Create: `assets/generated/source/combat_dash_speed_lines_imagegen_20260716.png`
- Create: `assets/generated/source/combat_dash_speed_lines_alpha_20260716.png`
- Create: `assets/generated/source/combat_dash_speed_lines_imagegen_20260716.md`
- Create: `assets/audio/sfx/sfx_dash.wav`
- Create: `assets/audio/source/generate_dash_wind_sfx.py`
- Create: `assets/audio/source/dash_wind_sfx_generation_20260716.json`

- [x] Use built-in image generation with a flat magenta key to author a sparse,
  right-facing cool-white/cyan pixel speed-line burst with no character,
  background, glow, text or enemy-warning red.
- [x] Hard-alpha and Nearest-normalize it to a transparent `192x64` PNG.
- [x] Generate a deterministic 44.1 kHz mono PCM16 `sfx_dash.wav`, around
  `0.20s`, with a faster air-only whoosh distinct from `sfx_dodge.wav`.
- [x] Run Godot `--import --quit` once and validate both imported resources.

### Task 4: Add Dedicated Presentation Routing

**Files:**
- Modify: `src/gameplay/main_scene.gd`
- Modify: `src/presentation/combat_presentation.gd`
- Modify: `src/presentation/audio_system.gd`
- Modify: `tests/unit/presentation/audio_system_test.gd`
- Modify: `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`

- [x] Add `CombatPresentation.on_dash_event` with two `mode=dash`
  afterimages and one independent speed-line lifecycle bucket included in the
  existing 200-particle cap.
- [x] Add focused diagnostic getters for Dash afterimages and speed lines.
- [x] Add `AudioSystem.on_dash_event`, register `sfx_dash`, and preserve
  `on_dodge_event -> sfx_dodge` unchanged.
- [x] Change only Main's Dash handler to dispatch the new methods.
- [x] Run the new GREEN, then the new suite plus Dash runtime, Main Dodge
  afterimage, AudioSystem and Main audio adapter suites.

### Task 5: Runtime Acceptance And Traceability

**Files:**
- Create: `production/epics/combat-presentation/story-031-cinderpaw-dash-afterimage-speed-line-wind-feedback.md`
- Create: `production/qa/evidence/cinderpaw-dash-afterimage-speed-line-wind-feedback-2026-07-16.md`
- Modify: `design/assets/asset-manifest.md`
- Modify: `production/epics/combat-presentation/EPIC.md`
- Modify: `production/epics/index.md`
- Modify: `production/session-state/active.md`

- [x] In one MCP run, use real Dash input and verify animation, `620 px/s`,
  exactly two Dash afterimages, one visible speed-line texture, `sfx_dash`, a
  non-empty screenshot, lifecycle cleanup and unchanged three-image Dodge.
- [x] Read game/editor logs, restore pause/input, clean stop to `ready`.
- [x] Record RED/GREEN, asset generation, audio limitations, MCP evidence and
  any remaining manual listening requirement.
- [ ] Stage only Story031 files, run `git diff --cached --check`, commit and push.
