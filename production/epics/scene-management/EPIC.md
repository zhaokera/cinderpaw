# Epic: Scene Management

> **Layer**: Feature
> **GDD**: design/gdd/scene-management.md
> **Architecture Module**: SceneManager
> **Status**: In Progress
> **Stories**: 8 stories tracked; future stories planned

## Overview

Implement the Feature-layer scene lifecycle boundary that downstream systems use
for deterministic scene IDs, spawn points, scene-local state, boss scene locks,
and async loading. The first production slice established the Autoload,
registry, and public API contract needed by Death & Respawn. Story002 closes the
player-facing title/continue/load save handoff against that logical
SceneManager baseline. Story003 adds the async request lifecycle, 1.5 second
transition timing gate, `ResourceLoader` completion, and 10 second timeout retry
with hub fallback. Story004 connects that lifecycle to a textured loading UI
shell. Story005 begins the real runtime scene-tree ownership path by
instantiating loaded `PackedScene` resources into a configured scene root.
Story006 closes the first memory-management slice by adding 3-second deferred
runtime unload, cached quick-return reuse, and max-two resident enforcement.
Story007 adds the fast-travel preload path: target scenes load behind a 2.0
second portal gate, reuse deferred cached runtime scenes when available, and
fall through the same timeout/runtime swap/deferred cache path as regular async
scene changes. Story008 connects BossConfig arena-change adapter requests to
playable MainScene arena mutation runtime nodes for Rat King phase transitions.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | SceneManager is the fifth global service after SaveSystem; AudioSystem remains an existing architecture debt outside Story001. | LOW |
| ADR-0007: Scene management architecture | SceneManager owns the registry, scene transition API, scene-state cache, Boss lock, and public signals. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-scene-001 | Scene registry maps `scene_id` to `{path, type, preload}`, with hub preloaded and resident. | ADR-0007 |
| TR-scene-002 | Async scene loading uses background loading plus 1-2 second transition animation. | ADR-0007; Story003 request lifecycle + timing gate; Story004 transition visual/loading UI shell |
| TR-scene-003 | Old scenes are deferred-unloaded after 3 seconds and no more than 2 scenes remain resident. | ADR-0007; Story005 keeps previous runtime scene reference after detach; Story006 deferred runtime unload/cache eviction |
| TR-scene-004 | Scene-local state persists through `get_local_state()` / `set_local_state()` and save serialization. | ADR-0007; local dictionary cache in Story001; runtime scene capture/restore in Story005 |
| TR-scene-005 | Boss arena locks scene switching during boss fights. | ADR-0007 |
| TR-scene-006 | Fast travel preloads target scenes during its portal animation. | ADR-0007; Story007 |
| TR-scene-007 | Scene loading stays under 2 seconds and memory under platform budgets. | ADR-0007; Story003 timing diagnostics partial; Story005 runtime swap seam; memory budget future |
| TR-scene-008 | Scene load timeout retries once, then fails back to hub. | ADR-0007; Story003 |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | SceneManager Registry + Public API Baseline | Integration | Complete | ADR-0001, ADR-0007 |
| 002 | Title/Continue/Load Runtime Handoff | Integration | Complete | ADR-0007, ADR-0021 |
| 003 | Async Load Request Lifecycle + Timeout Fallback | Integration | Complete | ADR-0007 |
| 004 | Transition Loading UI Shell | Integration | Complete | ADR-0007 |
| 005 | Runtime Scene-Tree Swap Ownership | Integration | Complete | ADR-0007 |
| 006 | Deferred Unload + Runtime Cache Eviction | Integration | Complete | ADR-0007 |
| 007 | Fast Travel Preload + Scene Change | Integration | Complete | ADR-0007 |
| 008 | Boss Arena Mutation Runtime | Integration | Complete | ADR-0007 |

## Definition of Done

This epic is complete when:
- SceneManager is registered as the Feature-layer scene service and exposes the
  public API expected by ADR-0007.
- Scene registry data is loaded through the project data pipeline and can name
  playable scene IDs and spawn points.
- Scene changes, boss locks, and scene-state serialization are deterministic
  and covered by GdUnit.
- Title, Continue, and Load Slot paths route through SceneManager before
  MainScene save snapshots are applied, and failure paths do not partially
  restore player/world/settings state.
- Async scene change requests use `ResourceLoader.load_threaded_request()`, wait
  for the 1.5 second transition gate before logical commit, emit a load-start
  signal for Presentation, and timeout after 10 seconds with one retry before
  hub fallback.
- Transition presentation uses image-generated texture assets and is driven by
  SceneManager load-start/changed/failed signals.
- Runtime scene-tree swaps instantiate loaded `PackedScene` resources into a
  configured SceneManager-owned root, detach the outgoing runtime scene, and
  preserve scene-local state through `get_local_state()` / `set_local_state()`.
- Runtime scene-tree swaps keep the outgoing scene as a 3-second deferred cache,
  reuse it for quick returns without another `ResourceLoader` request, and never
  keep more than current scene + one cached runtime scene resident.
- Fast travel requests preload their target scene during a 2.0 second portal
  gate, expose fast-travel metadata/signals, and preserve async timeout,
  runtime swap, and deferred cache behavior.
- Boss arena mutation requests from BossConfig create deterministic runtime
  obstacle/damage-zone nodes during Rat King phase transitions and clear them on
  boss death or arena reset.
- Later stories add loading audio fades and memory-budget verification.
- Godot CLI/GdUnit and Godot MCP verify the Autoload, runtime logs, and current
  scene visibility after SceneManager changes.

## Next Step

Continue SceneManager memory-budget verification and later arena polish stories:
electric leak contact damage, final arena VFX, and persistent boss arena mutation
save-state behavior.
