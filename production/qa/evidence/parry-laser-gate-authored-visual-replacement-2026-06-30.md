# QA Evidence: Parry Laser Gate Authored Visual Replacement

Date: 2026-06-30

Story:
`production/epics/player-abilities/story-027-parry-laser-gate-authored-visual-replacement.md`

## Scope

This slice replaces the player-visible Parry Laser gate placeholder art in
`res://scenes/main.tscn`. Story019 made the gate playable but reused
`res://assets/environment/rat_king_arena/electric_leak.png`; Story027 gives
`ParryLaserExplorationGate/Visual` a dedicated authored marker while preserving
the existing parry unlock, collision blocking, and save-state behavior.

## Generated Asset Pipeline

Source prompt summary:

- Pixel-art side-scroller parry laser gate marker, transparent background,
  scrap-metal vertical emitter frame, cyan laser barrier bars, glowing cat-eye
  gold parry core, signal-red locked accents, Central Tower tech silhouette
  cues, readable at 256x256, no text, no ground, clean alpha edges.

Source and runtime files:

- Source PNG:
  `assets/generated/source/parry_laser_gate_marker_imagegen_20260630.png`
- Source metadata:
  `assets/generated/source/parry_laser_gate_marker_imagegen_20260630.json`
- Runtime PNG:
  `assets/environment/parry_laser_gate/parry_laser_gate_marker.png`
- Godot import:
  `assets/environment/parry_laser_gate/parry_laser_gate_marker.png.import`

Asset checks:

- Runtime PNG is 256x256.
- Corner alpha is transparent; nontransparent content bbox is inside the frame.
- Runtime file was imported with
  `/opt/homebrew/bin/godot --headless --path . --import --quit`.
- `scenes/main.tscn` references the new `parry_laser_gate_marker.png`
  ExtResource for `ParryLaserExplorationGate/Visual`.

## Automated Tests

- RED focused: `reports/report_827/`
  - Command: `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_parry_laser_gate_runtime_test.gd --ignoreHeadlessMode`
  - Result: exit `100`, expected failure because
    `ParryLaserExplorationGate/Visual` still used
    `res://assets/environment/rat_king_arena/electric_leak.png`, the new PNG
    and `.import` files did not exist, the old texture size was `256x181`, and
    the visual still had `rotation=1.5708`.
- GREEN focused: `reports/report_828/`
  - Same focused command.
  - Result: exit `0`, `5/5` passing. Existing Godot process-exit
    ObjectDB/resource cleanup warnings appeared after the GdUnit result; the
    suite itself had `0` errors and `0` failures.
- Related regression: `reports/report_829/`
  - Suites: Parry Laser gate runtime and main-scene visual contract.
  - Result: exit `0`, `9/9` passing. Existing cleanup-time warnings appeared
    after the GdUnit result; the suites themselves had `0` errors and
    `0` failures.

## Headless Smoke

- Main scene:
  - Command: `/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/parry_laser_gate_authored_visual_replacement_main_scene_smoke.log`
  - Result: exit `0`.
- Log keyword scan:
  - `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Invalid access|Resource file not found|Failed loading resource|missing resource|Cannot open|ERROR:" reports/parry_laser_gate_authored_visual_replacement_main_scene_smoke.log`
  - Result: no matches.

## Godot MCP Runtime

MCP evidence:

- Runtime tree confirmed `/Main/ParryLaserExplorationGate` exists.
- Runtime tree confirmed `/Main/ParryLaserExplorationGate/Visual` is
  `Sprite2D`.
- Runtime probe confirmed the visual texture path is
  `res://assets/environment/parry_laser_gate/parry_laser_gate_marker.png`.
- Runtime probe confirmed the visual is not using
  `res://assets/environment/rat_king_arena/electric_leak.png`.
- Runtime probe confirmed the visual texture size is `256x256` and rotation is
  `0.0`.
- Runtime probe confirmed `/Main/Player/Sprite` is `AnimatedSprite2D`,
  `parry` exists, and `parry` frame count is `3`.
- Runtime probe confirmed the gate still starts `unlockable`, blocks collision
  before use, and unlocks after placing Cinderpaw in range and calling
  `request_parry()`.
- MCP logs contained only game helper/DataManager info lines.
- Runtime screenshot was written to
  `reports/visual/cinderpaw-mcp-parry-laser-gate-authored-visual-replacement-20260630.png`;
  screenshot is nonblank and shows the authored Parry Laser gate in the main
  runtime scene.

## Acceptance Mapping

| Acceptance item | Evidence | Status |
| --- | --- | --- |
| Dedicated Parry Laser texture replaces electric-leak reuse | RED `report_827`, GREEN `report_828`, MCP probe | PASS |
| Runtime PNG/import/size/rotation contract | `report_828`, import, MCP probe | PASS |
| Story019 unlock/save behavior preserved | `report_828`, MCP probe | PASS |
| Generated source/runtime assets are documented | Asset manifest, this evidence doc | PASS |
| Main scene runs under MCP with clean logs and nonblank screenshot | Headless smoke, MCP logs, MCP screenshot | PASS |
