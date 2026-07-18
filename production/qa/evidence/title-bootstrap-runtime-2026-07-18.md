# QA Evidence: Title Bootstrap Runtime

> **Story**: Scene Management 015
> **Date**: 2026-07-18
> **Engine**: Godot 4.7-stable
> **Godot AI MCP**: plugin/server 3.0.2

## Acceptance Summary

| Criterion | Evidence | Result |
| --- | --- | --- |
| Real title project boot | `project.godot` main scene and MCP title-only tree | PASS |
| No eager gameplay instance | `RuntimeSceneRoot` child count remained `0` before input | PASS |
| Generated title presentation | Imported opaque backdrop and separate six-frame Cinderpaw animation | PASS |
| Keyboard/controller focus | Explicit cyclic neighbors and physical D-pad navigation | PASS |
| Deferred New Game/Continue load | SceneManager commit precedes title hide and SaveSystem deserialize | PASS |
| Read-only save target preflight | SaveSystem regression proves no signal, deserialize, rewrite, or state mutation | PASS |
| Visible Godot runtime | Non-empty title and post-transition gameplay screenshots | PASS |
| Clean runtime | Info-only game log, zero editor rows, clean stop | PASS |

## Automated Evidence

- Intentional RED: `reports/report_1893`
  - The Story015 suite failed before the bootstrap scene, controller, project
    main-scene path, and read-only save query existed.
- Visual contract RED: `reports/report_1899`
  - The focused test rejected the pre-polish title composition before the
    generated character animation and final layout were connected.
- Focused GREEN: `reports/report_1901/results.xml`
  - Story015 passed `2/2`.
- Related GREEN: `reports/report_1902/results.xml`
  - HUDManager, SaveSystem Story002, and MainScene title/load handoff passed
    `33/33`.
- Final bounded gate: `reports/report_1909/results.xml`
  - Story015, HUDManager, SaveSystem Story002, MainScene handoff, SceneManager
    Story001, and runtime swap Story005 passed `48/48` across six suites.
  - Zero failures, errors, flaky, skipped, orphan, ObjectDB leak, or retained
    resource cases; process exit `0`.
  - MainScene fixture cleanup stops the global AudioSystem players it activates,
    preserving test isolation without changing runtime audio behavior.

## MCP Runtime Evidence

- Session: `cinderpaw@af5f`
- Godot: `4.7-stable (official)`
- Godot AI MCP: plugin/server `3.0.2`
- The editor opened `res://scenes/title_bootstrap.tscn`; scene inspection found
  `TitleCinderpaw` as `AnimatedSprite2D` with `title_idle` and six frames.
- With the existing local save, Continue received initial focus. Physical
  gamepad D-pad down moved focus to Load Game, D-pad up moved through Continue
  to New Game, and physical A activated New Game.
- Before activation, runtime diagnostics returned:
  - `current_scene=TitleBootstrap`
  - `RuntimeSceneRoot.child_count=0`
  - title animation `title_idle`, six frames, playing
  - menu bottom `684`, inside the `720px` safe viewport
  - cyclic focus contract `true`
- After New Game committed, the title surface was hidden and
  `RuntimeSceneRoot` contained exactly one child named `Main`.
- Final clean run: `r229527521-68`
  - Game log contained one info-only helper registration line.
  - Editor log contained zero rows after the acceptance baseline clear.
  - Stop returned `stopped=true` and restored editor readiness.
- Focused no-save tests separately verified New Game default focus and disabled
  Continue/Load behavior without modifying the user's real save slots.

## Generated Asset Evidence

- Background source:
  `assets/generated/source/cinderpaw_title_threshold_background_imagegen_20260718.png`
  - Retained exact generation prompt/metadata in the adjacent `.md` file.
  - Normalized runtime texture:
    `assets/ui/title/cinderpaw_title_threshold_background_1280x720.png`.
- Character source:
  `assets/characters/cinderpaw/source/cinderpaw_title_idle_sheet_imagegen_20260718.png`
  - Retained alpha intermediate and exact prompt/metadata.
  - Six transparent, consistently aligned `512x512` runtime frames live under
    `assets/characters/cinderpaw/title_idle/` with continuous names `000-005`.
  - `assets/characters/cinderpaw/cinderpaw_title_sprite_frames.tres` maps them
    to looping `title_idle` at `1.5 FPS`.
- Godot 4.7 imported every source/runtime PNG; asset spec, manifest, and entity
  inventory record the title bootstrap usage.

## Screenshots

- Title:
  `reports/visual/cinderpaw-mcp-title-bootstrap-runtime-20260718.png`
  - Dimensions: `1278x718`
  - Mean channel value: `0.106315` (non-empty)
  - SHA-256:
    `af8fc070c75c029ad1a8376ef01fd5a9abae01b5792198192d535bbeb8ae1200`
- New Game committed:
  `reports/visual/cinderpaw-mcp-title-new-game-transition-20260718.png`
  - Dimensions: `1278x718`
  - Mean channel value: `0.22392` (non-empty)
  - SHA-256:
    `d88cc27f14a33faa9bf9cd13f5da7a03b64640f6f66a0720f561a07ef17d7f37`
- Visual review: the title frame visibly contains the CINDERPAW brand, generated
  industrial wasteland backdrop, separate animated armored cat, and focused
  menu. No placeholder square, empty viewport, or cross-frame sprite artifact
  is visible. The transition frame shows live Main gameplay after commit.

## Scope Audit

- The Story changes project boot, title/HUD presentation, read-only save target
  lookup, and MainScene's same-target SceneManager handoff.
- It does not alter combat values, enemy AI, collision, rewards, progression,
  save schema, or area content.
- The broader complete-game objective remains active.
