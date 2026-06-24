# Epic: Scene Management

> **Layer**: Feature
> **GDD**: design/gdd/scene-management.md
> **Architecture Module**: SceneManager
> **Status**: In Progress
> **Stories**: 1 story ready; future stories planned

## Overview

Implement the Feature-layer scene lifecycle boundary that downstream systems use
for deterministic scene IDs, spawn points, scene-local state, boss scene locks,
and later async loading. The first production slice establishes the Autoload,
registry, and public API contract needed by Death & Respawn without pretending
the full transition animation, deferred unload, timeout, fast travel, or
cross-scene tree swap is complete.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | SceneManager is the fifth global service after SaveSystem; AudioSystem remains an existing architecture debt outside Story001. | LOW |
| ADR-0007: Scene management architecture | SceneManager owns the registry, scene transition API, scene-state cache, Boss lock, and public signals. | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-scene-001 | Scene registry maps `scene_id` to `{path, type, preload}`, with hub preloaded and resident. | ADR-0007 |
| TR-scene-002 | Async scene loading uses background loading plus 1-2 second transition animation. | ADR-0007; future story after API baseline |
| TR-scene-003 | Old scenes are deferred-unloaded after 3 seconds and no more than 2 scenes remain resident. | ADR-0007; future story |
| TR-scene-004 | Scene-local state persists through `get_local_state()` / `set_local_state()` and save serialization. | ADR-0007; local dictionary cache in Story001 |
| TR-scene-005 | Boss arena locks scene switching during boss fights. | ADR-0007 |
| TR-scene-006 | Fast travel preloads target scenes during its portal animation. | ADR-0007; future story |
| TR-scene-007 | Scene loading stays under 2 seconds and memory under platform budgets. | ADR-0007; future story |
| TR-scene-008 | Scene load timeout retries once, then fails back to hub. | ADR-0007; future story |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | SceneManager Registry + Public API Baseline | Integration | Complete | ADR-0001, ADR-0007 |

## Definition of Done

This epic is complete when:
- SceneManager is registered as the Feature-layer scene service and exposes the
  public API expected by ADR-0007.
- Scene registry data is loaded through the project data pipeline and can name
  playable scene IDs and spawn points.
- Scene changes, boss locks, and scene-state serialization are deterministic
  and covered by GdUnit.
- Later stories replace the logical baseline with real async ResourceLoader
  scene swaps, transition presentation, deferred unload/cache enforcement,
  timeout/retry handling, and fast travel.
- Godot CLI/GdUnit and Godot MCP verify the Autoload, runtime logs, and current
  scene visibility after SceneManager changes.

## Next Step

Death & Respawn Story 004 can now consume the logical SceneManager interface for
savepoint respawn selection. Full async scene-tree replacement remains a later
SceneManagement story.
