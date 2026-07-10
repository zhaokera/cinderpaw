# Smoke Test: Critical Paths

**Purpose**: Run these 10-15 checks in under 15 minutes before any QA hand-off.
**Run via**: `/smoke-check` (which reads this file)
**Update**: Add new entries when new core systems are implemented.

## Core Stability (always run)

1. Game launches to main menu without crash
2. New game / session can be started from the main menu
3. Main menu responds to all inputs without freezing

## Core Mechanic (update per sprint)

<!-- Add the primary mechanic for each sprint here as it is implemented -->
4. [Player can move, jump, and the camera follows correctly — update when player-movement is implemented]
5. [Player can attack and damage numbers appear — update when combat is implemented]
6. [Player can dodge with i-frames — update when dodge is implemented]
7. Old Factory service sluice exit hatch opens after the service sluice cache
   claim and persists opened state (`tests/smoke/old_factory_service_sluice_exit_hatch_smoke.gd`)
8. Old Factory service sluice tailrace relay activates after the tailrace
   ambush, records the savepoint, and respawns at the relay
   (`tests/smoke/old_factory_service_sluice_tailrace_relay_smoke.gd`)

## Data Integrity

9. Save game completes without error (once save system is implemented)
10. Load game restores correct state (once load system is implemented)

## Performance

11. No visible frame rate drops on target hardware (60fps target)
12. No memory growth over 5 minutes of play (once core loop is implemented)
