# Epic: Scene Management

> **Layer**: Feature
> **GDD**: design/gdd/scene-management.md
> **Architecture Module**: SceneManager
> **Status**: In Progress
> **Stories**: 15 stories tracked; future stories planned

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
Story009 turns the phase 3 `electric_leak` arena mutation into a real contact
damage hazard with ADR-0004 environment collision, player damage feedback, and
per boss/change/target cooldown. Story010 adds deterministic SceneManager
runtime memory-budget diagnostics, platform budget normalization, one-shot
over-budget warnings, and non-current deferred cache enforcement for
TR-scene-007. Story011 adds image-generated, texture-backed VFX layers to Rat
King phase 2/3 arena mutations so the final arena reads as destruction and
electric hazard instead of block-like collision fixtures. Story012 persists
active Rat King arena mutation descriptors through MainScene save/load snapshots
and SaveSystem slot handoff, then rebuilds collision, damage-zone, and VFX
runtime nodes on restore. Story013 removes the remaining visible placeholder
`Polygon2D` baseline from those mutation nodes so runtime presentation uses only
the generated `Sprite2D` prop textures and generated VFX layers. Story014 adds
phase-aware Rat King camera framing, deterministic release during the victory
hold, and explicit compatibility with the sequential Echo Guardian camera lock.
Story015 replaces direct-to-gameplay project boot with a persistent title
bootstrap, generated key art, six-frame Cinderpaw title animation, controller
focus navigation, and deferred save deserialization after SceneManager commit.

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
| TR-scene-004 | Scene-local state persists through `get_local_state()` / `set_local_state()` and save serialization. | ADR-0007; local dictionary cache in Story001; runtime scene capture/restore in Story005; boss arena mutation save-state persistence in Story012 |
| TR-scene-005 | Boss arena locks scene switching during boss fights. | ADR-0007 |
| TR-scene-006 | Fast travel preloads target scenes during its portal animation. | ADR-0007; Story007 |
| TR-scene-007 | Scene loading stays under 2 seconds and memory under platform budgets. | ADR-0007; Story003 timing diagnostics partial; Story005 runtime swap seam; Story010 deterministic memory-budget diagnostics/enforcement |
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
| 009 | Electric Leak Contact Damage | Integration | Complete | ADR-0007, ADR-0004, ADR-0019 |
| 010 | Scene Memory Budget Diagnostics | Logic / Performance | Complete | ADR-0007 |
| 011 | Rat King Final Arena VFX | Visual / Integration | Complete | ADR-0007 |
| 012 | Boss Arena Mutation Save-State Persistence | Integration | Complete | ADR-0007, ADR-0008, ADR-0021 |
| 013 | Rat King Arena Placeholder Visual Removal | Visual / Integration | Complete | ADR-0007, ADR-0004, ADR-0019 |
| 014 | Rat King Arena Camera Choreography | Visual / Integration | Complete | ADR-0007 |
| 015 | Title Bootstrap Runtime | Visual / Integration | Complete | ADR-0007, ADR-0021 |

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
- Project boot opens a persistent title bootstrap without instantiating
  gameplay first; generated opaque key art, a six-frame `AnimatedSprite2D`
  Cinderpaw, keyboard/controller focus, and post-commit save restoration are
  verified in the real Godot runtime.
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
- Phase 3 electric leak damage zones apply rate-limited player contact damage
  through existing health/presentation/audio routes and are verified through
  Godot MCP runtime probes.
- Rat King final arena mutations use image-generated texture-backed VFX layers
  for debris dust, electric hazard glow, and electric sparks, with manifest and
  MCP screenshot evidence.
- Active Rat King arena mutation state persists through MainScene save snapshots
  and SaveSystem slot load, restores Story008 collision/metadata, Story009
  electric leak hazard behavior, and Story011 VFX children without duplicating
  nodes, and clears for defeated/older-save states.
- Rat King arena mutations do not render visible `Polygon2D` or `ColorRect`
  placeholder blocks; the player-facing runtime layer uses generated `Sprite2D`
  prop textures and generated VFX while collision/damage shapes remain gameplay
  only.
- Rat King phases use progressively tighter MainScene camera profiles, restore
  the default framing on defeat, preserve CombatPresentation offset ownership,
  and yield cleanly to the Story156 Echo Guardian camera lock.
- SceneManager exposes deterministic runtime memory-budget diagnostics for
  mobile/PC/console budgets, emits one-shot over-budget warnings, and can evict
  non-current deferred runtime cache while preserving the current scene.
- Later stories add real platform memory profiler evidence, low-memory UI
  prompts, and optional shader arena polish.
- Godot CLI/GdUnit and Godot MCP verify the Autoload, runtime logs, and current
  scene visibility after SceneManager changes.

## Next Step

Continue later SceneManagement stories: real platform profiler evidence,
low-memory UI prompt routing, and optional shader arena polish.
