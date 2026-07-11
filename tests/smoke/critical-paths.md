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
9. Old Factory service sluice tailrace relay runoff activates after the relay,
   uses active-only steam contact, crosses the post-relay pocket, and persists
   crossed state
   (`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_smoke.gd`)
10. Old Factory service sluice tailrace relay runoff pincer activates after
    Story120, reveals frame-animated Spark/Coil Rats, requires both defeats,
    and persists cleared state
    (`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_smoke.gd`)
11. Old Factory service sluice tailrace relay runoff pincer reward cache appears
    only after the pincer is cleared, claims once for `+20 Gears`, and persists
    claimed state
    (`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke.gd`)
12. Old Factory service sluice tailrace relay runoff pincer exit hatch appears
    after the pincer reward cache is claimed, opens once, clears collision, and
    persists opened state
    (`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke.gd`)
13. Old Factory service sluice tailrace relay runoff pincer exit spillway
    activates after the exit hatch opens, uses active-only steam contact,
    crosses the short spillway pocket, and persists crossed state
    (`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.gd`)
14. Old Factory tailrace exit Sluice Leech appears only after the spillway is
    crossed, telegraphs for 18 frames, lunges through the shared hitbox path,
    and persists its cleared state
    (`tests/smoke/old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke.gd`)
15. Old Factory Sluice Leech clear unlocks the Matriarch route, SceneManager
    enters the authored Boss3 arena at `boss_entry`, and the return route
    restores Factory at `tailrace_matriarch_gate_return` without losing the
    leech clear or carrying a stale transition latch
    (`tests/smoke/old_factory_tailrace_sluice_matriarch_arena_handoff_smoke.gd`)
16. Sluice Matriarch starts with Boss HUD and room seals active, telegraphs and
    lands the pressure lunge through the shared hitbox chain, enters phase two,
    and opens the persistent return route on defeat
    (`tests/smoke/sluice_matriarch_playable_boss3_core_smoke.gd`)
17. Boss3 defeat reveals and persists the `aerial_attack` reward; airborne
    attack input drives the three-frame downward strike, lands shared damage,
    grants eight cat energy, bounces, and restores one air-jump use
    (`tests/smoke/sluice_matriarch_aerial_attack_reward_payoff_smoke.gd`)
18. The Factory tailrace floor unlocks only from a nearby real aerial attack,
    persists open, swaps into the authored Underground Passage, and returns to
    the exact Factory breach marker with `aerial_attack` intact
    (`tests/smoke/factory_aerial_breach_underground_passage_handoff_smoke.gd`)
19. The Underground corrosion channel crosses a generated runoff hazard, closes
    both generated seals around two frame-animated Sluice Leeches, accepts a
    real Core attack, opens on dual defeat, claims one salvage reward, and
    restores the claimed state after Factory return and Underground re-entry
    (`tests/smoke/underground_corrosion_channel_skirmish_smoke.gd`)
20. The Underground recovery cistern activates a generated savepoint, restores
    full HP and autosaves once, revives a lethal fall at 50% HP, secures the
    far-side endpoint, and preserves relay/route state through Factory return
    and Underground re-entry
    (`tests/smoke/underground_recovery_cistern_savepoint_traverse_smoke.gd`)

## Data Integrity

21. Save game completes without error (once save system is implemented)
22. Load game restores correct state (once load system is implemented)

## Performance

23. No visible frame rate drops on target hardware (60fps target)
24. No memory growth over 5 minutes of play (once core loop is implemented)
