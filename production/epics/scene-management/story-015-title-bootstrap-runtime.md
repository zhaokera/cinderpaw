# Story 015: Title Bootstrap Runtime

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Presentation / Feature Integration
> **Type**: Visual / Integration
> **Estimate**: M
> **Manifest Version**: 2026-07-18
> **Last Updated**: 2026-07-18

## Context

**GDD**: `design/gdd/scene-management.md`
**Requirements**: `TR-scene-001`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0007: Scene management architecture,
ADR-0021: Save system architecture

Story002 completed the New Game, Continue, and Load Slot handoff inside
`MainScene`, but explicitly left a real `TitleScene` and project boot replacement
out of scope. The shipped project therefore still starts live Rat King gameplay
before the player chooses an entry path. This Story adds a lightweight persistent
bootstrap that owns title presentation while SceneManager continues to own async
runtime scene loading.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] `project.godot` boots `scenes/title_bootstrap.tscn`; no player, enemy, Boss,
  or gameplay scene is instantiated before an entry action is accepted.
- [x] The first viewport presents the `Cinderpaw` brand over an opaque generated
  `1280x720` title key art, with New Game focused when no save exists, Continue
  focused when a save exists, and keyboard/controller focus navigation available.
- [x] The title character is a separate visible `AnimatedSprite2D` backed by a
  six-frame `SpriteFrames` `title_idle`; no character is baked into the backdrop.
- [x] New Game requests `main/default` through SceneManager, keeps the title
  surface visible during the transition, and hides it only after the runtime
  scene change commits.
- [x] Continue chooses the first existing slot in deterministic order `0,1,2,3`,
  reads its target without deserializing live systems, and requests the saved
  scene/spawn through SceneManager.
- [x] Continue and selected Load Slot call `SaveSystem.load_game(slot)` only after
  the target runtime scene has entered the SceneManager-owned runtime root.
- [x] Continue and Load Game are disabled with a clear reason when no save exists;
  Settings returns to the title menu and Exit closes the desktop build.
- [x] A missing/corrupt save or rejected/failed scene request leaves the title
  visible, restores button focus, and presents load-failure feedback.
- [x] Generated source, exact prompt, normalized runtime texture, import status,
  asset manifest entry, QA evidence, and a non-empty MCP screenshot are retained.

## Implementation Notes

- Keep `TitleBootstrap` outside `RuntimeSceneRoot` so it survives the async swap
  long enough to commit Continue/Load deserialization and report failures.
- Add a read-only SaveSystem snapshot query for target resolution. It must not
  mutate `_last_loaded_data`, emit load signals, deserialize registered systems,
  or rewrite migration data.
- Reuse `HUDManager` menu, settings, save-slot, focus, and transition surfaces.
  Title mode hides gameplay-only HUD chrome and leaves notification/menu layers
  available.
- Do not copy MainScene save-restore rules into Presentation. The bootstrap only
  resolves `{scene_id, spawn_point}` and lets SaveSystem deserialize after the
  target runtime is live.

## Thin TDD / Verification

- RED: one focused boot/runtime contract test fails before the bootstrap scene,
  controller, and read-only save query exist.
- GREEN: focused Story015 tests plus the smallest SceneManager/SaveSystem/HUD
  regression needed by the changed contracts.
- Runtime: focused tests cover the no-save disabled state. Godot MCP starts the
  real project main scene with the existing save, confirms title-only startup,
  tests physical gamepad navigation/A-button activation, confirms `MainScene`
  under `RuntimeSceneRoot`, checks clean logs, and captures non-empty title and
  gameplay screenshots.

## Out of Scope

- Save-slot deletion, timestamp sorting, profile selection, cloud saves, or a
  cinematic intro.
- Replacing the in-game pause/main-menu shell already owned by MainScene.
- Refactoring every existing area scene's save payload in this Story.

## Dependencies

- Depends on: Scene Management Stories 002-005.
- Depends on: Save System Stories 001-005.
- Depends on: HUD/UI Story 005 and Scene Management Story004 transition UI.

## Test Evidence

- Intentional RED: `reports/report_1893` failed before the project main scene,
  title bootstrap controller, and read-only save preflight existed. Visual
  contract RED `reports/report_1899` caught the pre-polish title composition.
- Focused GREEN: `reports/report_1901` passed Story015 `2/2`.
- Related GREEN: `reports/report_1902` passed HUD, SaveSystem, and MainScene
  regressions `33/33`.
- Final bounded gate: `reports/report_1909/results.xml` passed six suites and
  `48/48` cases with zero failures, errors, flaky, skipped, orphan, or process
  teardown leak cases.
- Godot 4.7 / Godot AI MCP 3.0.2 run token 66 verified physical D-pad/A input,
  deferred New Game transition, and exactly one `Main` child under
  `RuntimeSceneRoot`. Final clean title run `r229527521-68` verified title-only
  startup, a six-frame playing `AnimatedSprite2D`, non-empty `1278x718`
  evidence, info-only game output, zero editor log rows, and clean stop.
- Detailed evidence:
  `production/qa/evidence/title-bootstrap-runtime-2026-07-18.md`.
