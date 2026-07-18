# Story 035: Rat King Phase-I Authored Intro Frames

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual / Frame Animation
> **Estimate**: S
> **Manifest Version**: 2026-07-18
> **Last Updated**: 2026-07-18

## Context

**GDD**: `design/gdd/game-concept.md`, `design/gdd/boss-config.md`

**ADR Governing Implementation**: ADR-0010: Art and visual pipeline,
ADR-0011: Animation and presentation architecture

Rat King already exposes a three-frame `phase_1_intro` animation, but its three
runtime PNGs are byte-identical to the corresponding idle frames. The project
therefore satisfies a frame-count check without presenting a distinct Boss
entrance. This Story replaces only those three visual frames with an authored,
image-generated anticipation-to-threat sequence while preserving the existing
Boss state machine, animation name, timing, hitboxes, scale, and gameplay data.
It does not add or change the production trigger for that presentation state.

**Engine**: Godot 4.7 | **Risk**: LOW

## Acceptance Criteria

- [x] `phase_1_intro` remains a non-looping three-frame animation in the shared
  Rat King `SpriteFrames` resource; the production Boss controller and its
  existing idle/phase transitions remain unchanged.
- [x] The three runtime PNGs remain transparent `192x192` canvases under
  `assets/characters/rat_king/phase_1_intro/`, with continuous `000-002` names,
  one common baseline/anchor, and three distinct frame hashes.
- [x] Every intro frame differs from its corresponding idle frame and visibly
  reads as: shadowed anticipation, red core/eye ignition, then raised crown and
  forward threat.
- [x] Rat King identity, silhouette, armor, trash-can body, crown, facing, pixel
  density, and existing gameplay scale remain consistent; no background, UI,
  text, particles, shadow plate, or extra character is baked into the frames.
- [x] The generated source, exact prompt, alpha processing notes, frame hashes,
  asset specification, manifest entry, QA evidence, and Godot import sidecars
  are retained.
- [x] Focused/related GdUnit passes and Godot MCP verifies the real Main runtime
  plays `phase_1_intro` on `AnimatedSprite2D`, logs stay clean, and a non-empty
  screenshot shows a frame distinct from idle.

## Thin TDD / Verification

- RED: one asset-contract test rejects the current idle-identical intro and the
  missing generated source/prompt record.
- GREEN: replace only the three runtime frames, import them, and run the focused
  Story035 test plus existing Rat King animation/runtime contracts.
- Runtime: one MCP Main launch, one forced real intro playback probe, one
  screenshot, game/editor logs, and clean stop.

## Out of Scope

- Boss activation/onboarding flow, AI scheduling, transition duration, hitbox,
  damage, health, arena camera, phase 2/3 animations, attacks, audio, or VFX.
- Resizing the existing `192x192` Boss contract or redrawing other Rat King
  animation families.

## Dependencies

- Depends on: Combat Presentation Stories 014-015.
- Depends on: Boss Config Stories 007-009.
- Depends on: AGENTS.md Godot 2D frame-animation and image-generation rules.

## Completion Evidence

- Intentional RED `reports/report_1911`: the focused suite failed on the absent
  generated source/prompt and the three idle-identical runtime hashes.
- Focused GREEN `reports/report_1912`: Story035 passed `1/1` with no error,
  failure, flaky, skipped or orphan cases.
- Bounded related GREEN `reports/report_1914`: Story035 plus the existing Rat
  King character-animation and Main runtime contracts passed `8/8`; exit `0`
  with clean process teardown. The runtime-contract fixture now stops only the
  global audio players it starts during phase-transition assertions.
- Godot MCP 3.0.2 / Godot 4.7 run `r233397649-69` played the real Main-scene
  `/root/Main/Enemy/Sprite` from frame 0 to frame 1 over `0.36s`, reported
  `AnimatedSprite2D`, three frames, non-looping playback, all three imported
  texture paths and unique hashes, and a visible `192x192` frame.
- The MCP game log contained three info rows only; the editor error log was
  empty and stop restored readiness to `ready`.
- Non-empty `1278x718` screenshot:
  `reports/visual/cinderpaw-mcp-rat-king-phase-one-authored-intro-20260718.png`.
- Full evidence:
  `production/qa/evidence/rat-king-phase-one-authored-intro-2026-07-18.md`.
