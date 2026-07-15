# Story 153: Main Scene Autosave Paw Stamp Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Presentation / Save Integration
> **Type**: Integration + UI + Audio/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/save-system.md`, `design/gdd/hud-ui.md`

**Requirements**: `TR-save-006`, `TR-hud-001`, `TR-hud-004`, `TR-hud-005`

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0002
signal communication; ADR-0011 UI focus management; ADR-0013 pixel-art
rendering; ADR-0015 accessibility; ADR-0021 save system.

Story152 completed the first live Main minimap. The next bounded player-visible
gap is the Save GDD's explicit autosave confirmation: a cat-paw stamp in the
upper-right HUD cluster that remains readable for 1.5 seconds. Main already
writes slot 0 at savepoints, Boss defeats and ability rewards, but those writes
have no dedicated visual confirmation and only manual saves route the existing
`ui_save` cue. This slice closes that feedback loop without adding a save owner
or changing persistence data.

## Acceptance Criteria

- [x] `HUDManager` mounts one stable `AutosavePawStamp` `TextureRect` in the
  upper-right HUD cluster and keeps it hidden until an autosave dispatch is
  accepted.
- [x] The stamp reuses a single-paw region from the existing image-generated
  `scene_transition_paw_spinner` source rather than introducing placeholder art
  or a second generated asset for the same motif.
- [x] Accepted Main autosaves show the stamp at full opacity, keep it opaque for
  the first `1.0s`, fade through the final `0.5s`, and hide at exactly `1.5s`.
  A new accepted autosave restarts the lifecycle from full opacity.
- [x] The stamp scales with HUD scale `0.5-1.5`, stays inside the authored
  `1280x720` HUD bounds, and does not overlap currency, minimap, boss, player,
  weapon or heavy-charge panels at maximum scale.
- [x] Every accepted Main autosave routes exactly one existing `ui_save` event
  with slot `0`, autosave reason and duplicated context metadata. A rejected
  autosave shows no stamp and routes no save cue.
- [x] Existing savepoint discovery notification, slot-0 payload, boss/ability
  autosave triggers, manual-save feedback and save schema remain unchanged.
- [x] Focused GdUnit, bounded HUD/save/audio regression, target smoke and Godot
  MCP verify the real savepoint trigger, lifecycle, audio metadata, live HUD
  node, non-overlap, non-empty gameplay capture and clean logs.

## Out of Scope

- New save slots, save schema, retry queues, backup behavior, cloud saves,
  manual-save menu cards or loading-screen animation.
- Replacing the current `ui_save.wav` with final cat-meow plus writing Foley;
  this slice routes the already imported baseline cue and leaves final audio
  replacement in the audio-production backlog.
- Savepoint world VFX, fast travel, additional minimaps, Boss polish, new
  character frames or any change to `AnimatedSprite2D` state contracts.

## Implementation Notes

- Keep timing deterministic in `HUDManager.advance_time()`; do not create a
  Tween or a second process owner.
- Use an `AtlasTexture` region over the existing generated spinner so the stamp
  reads as one paw while retaining the original imported source and manifest
  provenance.
- Main owns autosave event routing because it already owns the
  `SaveTriggerAdapter` handoff. HUD remains presentation-only and receives no
  SaveSystem dependency.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/main_scene_autosave_paw_stamp_feedback_test.gd`
- Existing HUD, Main savepoint, autosave adapter and Main audio adapter tests
- `tests/smoke/main_scene_autosave_paw_stamp_feedback_smoke.gd`
- Godot MCP evidence under
  `production/qa/evidence/main-scene-autosave-paw-stamp-feedback-2026-07-14.md`

**Status**: [x] Complete. RED `report_1597` captured the missing contract;
focused GREEN `report_1603` passed `2/2`; bounded related GREEN `report_1602`
passed `41/41`; target smoke passed. Godot `4.7-stable` / MCP `2.9.2` run
`r14231021-14` verified the real Main savepoint autosave, `ui_save` metadata,
`AtlasTexture` node, exact fade lifecycle, a non-empty `1278x718` capture and
clean game/editor logs.
