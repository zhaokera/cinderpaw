# QA Evidence: Old Factory Entrance Combat Slice

Date: 2026-06-26
Story: `production/epics/player-abilities/story-007-old-factory-entrance-combat-slice.md`
Scene: `res://scenes/factory_route_transition_shell.tscn`

## Scope

Story007 upgrades the Double Jump-gated `area_03_factory` route destination
from a minimal shell into the first playable Old Factory entrance combat room.
It covers generated environment art, safe spawn/collision, visible Cinderpaw,
visible animated Rat Minion combat object, SceneManager runtime swap, and
factory music/ambient cue routing.

Out of scope: full Old Factory map, Boss2, hidden boss, savepoints, minimap,
new enemies, new character frames, or SceneManager architecture changes.

## Asset Evidence

| Asset | Runtime Path | Source | Notes |
|-------|--------------|--------|-------|
| Old Factory entrance backdrop | `res://assets/environment/old_factory_entrance_combat/old_factory_entrance_room_backdrop.png` | `assets/generated/source/old_factory_entrance_room_backdrop_imagegen_20260626.png` | Image-generated opaque 1280x720 pixel-art factory entrance backdrop, cropped/resized from source and imported through Godot. |
| Factory route shell prop | `res://assets/environment/factory_route_transition/factory_route_transition_shell.png` | `assets/generated/source/factory_route_transition_shell_imagegen_20260626.png` | Existing Story006 generated transparent doorway prop reused as the left entrance focus. |
| Rat Minion frames | `res://assets/characters/rat_minion/rat_minion_sprite_frames.tres` | `assets/characters/rat_minion/source/rat_minion_sprite_sheet_imagegen_20260625.png` | Existing 3-frame-per-state `AnimatedSprite2D + SpriteFrames` enemy used for the room's combat object. |

Image generation prompt for the new backdrop:

```text
1280x720 pixel-art 2D side-scroller old factory entrance combat room backdrop, abandoned industrial doorway interior, cracked concrete floor with a clear flat playable lane around y=500, rusted steel rear wall, welded plates, exposed pipes, broken vents, warning stripes, cool blue factory shadows with restrained rust-orange panels and small cat-eye gold rim lights, readable left entrance area for a separate doorway sprite, empty center-right combat space, no characters, no enemies, no UI text, no signs with readable lettering, no explosions, no full level map, no 3D render, no blur, no watermark
```

## Automated Evidence

- RED focused: `reports/report_637/` failed as expected because the registered
  factory destination lacked `Background`, generated backdrop asset, player
  instance, collision structure, and combat object.
- GREEN focused: `reports/report_646/` passed `4/4` with `0` orphan nodes for
  `tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd`,
  including the runtime damage assertion that player attack reduces the Factory
  Rat Minion HP.
- Related regression: `reports/report_647/` passed `55/55`, `0` failures, `0`
  errors, `0` skipped across Old Factory entrance, Factory route shell,
  SceneManager swap/preload, Double Jump reward/gate, MainScene attack chain,
  Rat King summon runtime, scene transition UI, and AudioSystem cue tests.
- Godot import: `godot --headless --path . --import --quit` exited `0` and
  imported `old_factory_entrance_room_backdrop.png` plus source PNG.
- Headless smoke:
  - `reports/old_factory_entrance_combat_slice_factory_scene_smoke.log` exited
    `0`.
  - `reports/old_factory_entrance_combat_slice_main_scene_smoke.log` exited
    `0`.
  - Keyword scans found no script parse, invalid call, missing resource, or
    load failure messages. Known cleanup-time ObjectDB/resource messages remain
    limited to process exit.

## MCP Runtime Evidence

Godot MCP was connected to Godot `4.6.3-stable`. Runtime validation covered both
the main-scene route transition and a clean Factory scene combat probe.

- SceneManager reached `area_03_factory` / `factory_gate_entry`.
- Runtime root became `FactoryRouteTransitionShellScene` with
  `metadata/scene_id == "area_03_factory"`.
- `Background` uses
  `res://assets/environment/old_factory_entrance_combat/old_factory_entrance_room_backdrop.png`.
- `Player/Sprite` and `FactoryRatMinion/Sprite` are visible `AnimatedSprite2D`
  instances.
- Rat Minion `SpriteFrames` has `idle`, `run`, `attack`, `hurt`, and `death`
  with at least 3 frames.
- A clean Factory runtime attack reduced Rat Minion HP from `24` to `12`;
  recorded hit metadata had `final_damage == 12` and `target_id == 2100`.
- `AudioSystem` resolved `mus_factory` and `amb_factory`.
- Game/editor logs showed no new script errors, missing resources, or invalid
  calls.
- Screenshot is nonblank and shows Old Factory entrance background, player, and
  combat object.

Screenshot:
`reports/visual/cinderpaw-mcp-old-factory-entrance-combat-slice-20260626.png`

## Result

PASS. Story007 satisfies the Old Factory entrance combat-slice acceptance
criteria. Full Old Factory layout, Boss2, hidden boss, savepoints, minimap, and
new enemy family remain out of scope.
