# Control Manifest

> **Engine**: Godot 4.6.3
> **Last Updated**: 2026-06-21
> **Manifest Version**: 2026-06-21
> **ADRs Covered**: ADR-0001, ADR-0002, ADR-0003, ADR-0004, ADR-0005, ADR-0006, ADR-0007
> **Status**: Active — regenerate with `/create-control-manifest update` when ADRs change

This manifest is a programmer's quick-reference extracted from all Accepted ADRs,
technical preferences, and engine reference docs. For the reasoning behind each
rule, see the referenced ADR.

---

## Foundation Layer Rules

*Applies to: DataManager, InputManager, AudioSystem, SaveSystem, SceneManager Autoloads; DamageCalculator static class*

### Required Patterns

- **5 Autoloads only**: DataManager (#1), InputManager (#2), AudioSystem (#3), SaveSystem (#4), SceneManager (#5) — initialized in this exact order — source: ADR-0001
- **DamageCalculator is `class_name` static utility**, NOT an Autoload — source: ADR-0001
- **Core layer systems are scene components** (HealthComponent, CombatComponent, AIComponent, CollisionComponent) mounted on entity nodes, NOT Autoloads — source: ADR-0001
- **Foundation layer must contain zero game logic** — DataManager and InputManager must not reference Core systems — source: ADR-0001
- **ISerializable is `@abstract`** class with `serialize() -> Dictionary` and `deserialize(data: Dictionary) -> void` — source: ADR-0001
- **Signal naming**: `on_[noun]_[past_participle]` (e.g., `on_hp_changed`, `on_death`) — source: ADR-0002
- **Signal payload ≤3 fields**: pass directly as parameters; >3 fields: use `class_name` data class — source: ADR-0002
- **Signal emission order**: state change → conditional signals → terminal signal (`on_death` always fires last) — source: ADR-0002
- **Signal connect**: use `signal.connect(callable)` typed syntax, never string-based — source: ADR-0002
- **DataManager states**: BOOTING → READY → RELOADING → ERROR (4-state machine) — source: ADR-0003
- **JSON is source data format**, Resource is engine bridge layer — source: ADR-0003
- **SchemaValidator**: 3-level failure handling (1st fail → default values, hot-reload fail → keep old cache, manifest fail → ERROR state) — source: ADR-0003
- **HotReloader**: 1-second file timestamp polling, Debug builds only — source: ADR-0003
- **TuningKnobRegistry**: centralized knob management, 3-tier value priority (debug panel > JSON file > registered default) — source: ADR-0003
- **Data versioning**: `_meta.version` field (MAJOR.MINOR), chained migration (1.0→1.1→1.2) — source: ADR-0003
- **Standard data consumer contract**: `_ready()` fetches domain + connects `on_domain_changed` + `get_entry()` returns null → graceful degradation — source: ADR-0003

### Forbidden Approaches

- **Never use EventBus / centralized event bus** — Godot native signals are sufficient, no indirection needed — source: ADR-0002
- **Never use string-based `connect("signal", obj, "method")`** — use typed `signal.connect(callable)` — source: ADR-0002
- **Never use untyped Dictionary as signal payload** when >3 fields — use `class_name` data class — source: ADR-0002
- **Never use Resource (.tres) as source data format** — JSON is source, Resource is bridge — source: ADR-0003
- **Never bypass SchemaValidator** — all loaded data must be validated — source: ADR-0003
- **Never put game logic in DataManager or InputManager** — Foundation layer has zero game knowledge — source: ADR-0001
- **Never add more than 5 Autoloads** — if a system needs global access, reconsider architecture first — source: ADR-0001

### Performance Guardrails

- **DataManager hot-reload polling**: <0.1ms/frame — source: ADR-0003
- **Signal emission overhead**: <0.1ms/frame — source: ADR-0002
- **Autoload initialization total**: <1 second (all 5 Autoloads) — source: ADR-0001

### Engine API Constraints

- **FileAccess.store_* returns bool** (4.4 change) — handle return value, don't assume void — source: VERSION.md
- **@abstract available** (4.5) — use for ISerializable interface — source: ADR-0001
- **Required parameters/return values** (4.6) — nullable values no longer implicitly allowed; all typed parameters must be satisfied — source: VERSION.md

---

## Core Layer Rules

*Applies to: HealthComponent, CombatComponent, CollisionComponent, AIComponent, WeaponStyleManager, StatusEffectManager, PlayerAbilityManager*

### Required Patterns

- **Area2D + CollisionShape2D** for hitbox/hurtbox detection — source: ADR-0004
- **Multiple Hitboxes per entity** (default `monitoring=false`, activate during attack) + **1 Hurtbox per entity** (3 states: normal/shrunk/gone) — source: ADR-0004
- **5 collision layers**: player_attack / enemy_attack / player_hurt / enemy_hurt / environment — source: ADR-0004
- **Frame-level detection in `_physics_process`** — iterate all active hitboxes vs hurtboxes each frame — source: ADR-0004
- **HitboxArea class** with `mark_hit(target_id)` / `has_hit(target_id)` / `clear_hits()` — prevents duplicate hits — source: ADR-0004
- **`on_hit_confirmed` signal** carries `HitEvent` payload (attacker_id, target_id, hitbox_id, hit_position, hit_frame, attack_metadata) — source: ADR-0004
- **6-state combat state machine**: IDLE / ATTACKING / DODGING / PARRYING / HIT_STUN / CHARGING — implemented via enum + match — source: ADR-0005
- **State transitions in `_physics_process`** — source: ADR-0005
- **3-segment combo chain**: combo_index 0→1→2, 300ms timeout — source: ADR-0005
- **Dodge i-frames**: active during frames 3-10 (8 frames ≈ 133ms invincibility) — source: ADR-0005
- **Parry window**: 18 frames total (PERFECT=0-6 / GOOD=7-12 / LATE=13-18) — source: ADR-0005
- **Cat energy**: max 100, no decay, 10 seconds out-of-combat → reset to 0 — source: ADR-0005
- **AnimationPlayer drives combat animations**, not AnimationTree — source: ADR-0005
- **6-state AI behavior machine**: IDLE / PATROL / CHASE / ATTACK / FLEE / STUN — enum + match — source: ADR-0006
- **RayCast2D for perception** (line-of-sight + angle/distance calculation) — source: ADR-0006
- **Attack patterns are data-driven**: loaded from DataManager `enemy_stats` domain — source: ADR-0006
- **3-phase attack execution**: startup → active → recovery — source: ADR-0006
- **`get_active_enemy_count()` static counter** — updated on state enter/exit — source: ADR-0006
- **Focus mode integration**: AI listens `on_focus_mode_changed` → appends `windup_extension_frames` (default +6) — source: ADR-0006

### Forbidden Approaches

- **Never use PhysicsBody for hit detection** — use Area2D only — source: ADR-0004
- **Never use NavigationAgent2D for AI pathfinding** — levels are hand-designed; use RayCast2D perception — source: ADR-0006
- **Never use AnimationTree for combat state management** — use enum + match with AnimationPlayer — source: ADR-0005
- **Never use State Pattern (class-per-state) for combat FSM** — enum + match is simpler and sufficient — source: ADR-0005
- **Never skip `mark_hit()` duplicate check** — without it, one attack can hit the same target multiple times — source: ADR-0004
- **Never call Foundation layer from Core layer directly** — Core listens to Foundation via signals — source: ADR-0001

### Performance Guardrails

- **Collision detection**: <3ms/frame — source: ADR-0004
- **Combat state transitions**: <0.1ms/frame — source: ADR-0005
- **AI decisions**: <1ms/frame per entity — source: ADR-0006

### Engine API Constraints

- **Area2D `monitoring` property** — must be explicitly set to false by default, activated only during attack frames — source: ADR-0004
- **AnimationPlayer** — use `play()` / `stop()` / `seek()`, NOT deprecated `playback_active` / `method_call_mode` — source: deprecated-apis.md
- **`bone_pose_updated` signal deprecated** — use `skeleton_updated` instead (4.3+) — source: deprecated-apis.md
- **RayCast2D** — verify `is_colliding()` before accessing `get_collider()` — source: ADR-0006

---

## Feature Layer Rules

*Applies to: SaveSystem, SceneManager, Death&Respawn, Exploration Gating, Charm/Equipment, NPC Dialogue, Map, Skill Tree*

### Required Patterns

- **Asynchronous scene loading**: `ResourceLoader.load_threaded_request()` + transition animation (1.5s cat warrior animation) masks load time — source: ADR-0007
- **Deferred unload**: scene removed from tree but reference kept for 3 seconds (quick return avoids reload) — source: ADR-0007
- **Max 2 simultaneous cached scenes** — source: ADR-0007
- **Scene state persistence**: `get_local_state()` / `set_local_state()` protocol + ISerializable — source: ADR-0007
- **Boss battle scene lock**: `lock_scene()` / `unlock_scene()` prevents scene switching during boss fights — source: ADR-0007
- **Scene registry**: `scene_id → {path, type, preload}` mapping — hub scenes preloaded and resident — source: ADR-0007
- **Fast travel**: preloads target scene during 2-second portal animation — source: ADR-0007

### Forbidden Approaches

- **Never switch scenes synchronously** — always use async loading with transition animation — source: ADR-0007
- **Never keep more than 2 scenes cached** — memory constraint — source: ADR-0007

### Performance Guardrails

- **Scene loading**: <2 seconds — source: ADR-0007
- **Scene load timeout**: 10 seconds → retry once → fail → return to hub — source: ADR-0007
- **Memory peak**: <1GB (mobile) / <2GB (PC) — source: ADR-0007

### Engine API Constraints

- **`ResourceLoader.load_threaded_request`** — verify API signature for Godot 4.6.3 before use — source: ADR-0007
- **`SceneTree.change_scene_to_packed`** — preferred over deprecated `change_scene()` — source: deprecated-apis.md

---

## Presentation Layer Rules

*Applies to: HUD/UI, Combat Presentation (hitstop, screen shake, particles, afterimages), Audio*

### Required Patterns

- **AudioSystem is Autoload #3** — manages 5 audio buses (Master/Music/SFX/Ambient/UI) — source: ADR-0001
- **`play_sfx(sfx_id, position, volume_db)` / `play_music(music_id, fade_in_sec)`** — source: ADR-0001
- **Presentation layer NEVER calls upward** — consumes Core/Feature data via signals only — source: architecture.md Layer Rules

### Forbidden Approaches

- **Never call Core/Feature systems directly from Presentation** — signal consumption only — source: architecture.md Layer Rules

### Performance Guardrails

- **AudioSystem max 16 simultaneous SFX** — priority-sorted, lowest dropped on overflow — source: ADR-0001

### Engine API Constraints

- **UI dual-focus system (4.6)**: mouse/touch focus ≠ keyboard/gamepad focus — must test both input paths for all menus — source: VERSION.md, QQ-01
- **`grab_focus()` only affects keyboard/gamepad focus** in 4.6 — source: VERSION.md

---

## Global Rules (All Layers)

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | PascalCase | `PlayerController` |
| Variables/functions | snake_case | `move_speed` |
| Signals/Events | snake_case past tense | `health_changed` |
| Files | snake_case matching class | `player_controller.gd` |
| Scenes/Prefabs | PascalCase matching root node | `PlayerController.tscn` |
| Constants | UPPER_SNAKE_CASE | `MAX_HEALTH` |

Source: `.claude/docs/technical-preferences.md`

### Performance Budgets

| Target | Value |
|--------|-------|
| Framerate | 60 fps |
| Frame budget | 16.6 ms |
| Draw calls | 200-300 |
| Memory ceiling | 2 GB (PC), 1 GB (mobile), 4 GB (console) |

Source: `.claude/docs/technical-preferences.md`

### Approved Libraries / Addons

- **GdUnit4** — approved test framework for Godot 4 — source: technical-preferences.md

### Forbidden APIs (Godot 4.6.3)

These APIs are deprecated or have breaking changes. **Do not use.**

**Deprecated Nodes/Classes:**
| Deprecated | Replacement | Since |
|-----------|-------------|-------|
| `TileMap` | `TileMapLayer` | 4.3 |
| `VisibilityNotifier2D/3D` | `VisibleOnScreenNotifier2D/3D` | 4.0 |
| `YSort` | `Node2D.y_sort_enabled` | 4.0 |
| `Navigation2D/3D` | `NavigationServer2D/3D` | 4.0 |
| `EditorSceneFormatImporterFBX` | `EditorSceneFormatImporterFBX2GLTF` | 4.3 |

**Deprecated Methods/Properties:**
| Deprecated | Replacement | Since |
|-----------|-------------|-------|
| `yield()` | `await signal` | 4.0 |
| `connect("signal", obj, "method")` | `signal.connect(callable)` | 4.0 |
| `instance()` | `instantiate()` | 4.0 |
| `get_world()` | `get_world_3d()` | 4.0 |
| `OS.get_ticks_msec()` | `Time.get_ticks_msec()` | 4.0 |
| `duplicate()` (nested resources) | `duplicate_deep()` | 4.5 |
| `AnimationPlayer.method_call_mode` | `AnimationMixer.callback_mode_method` | 4.3 |
| `AnimationPlayer.playback_active` | `AnimationMixer.active` | 4.3 |

**Deprecated Patterns:**
| Pattern | Replacement | Reason |
|---------|-------------|--------|
| String-based `connect()` | Typed signal connection | Type safety |
| `$NodePath` in `_process()` | `@onready var` cached reference | Performance |
| Untyped `Array`/`Dictionary` | `Array[Type]`, typed variables | Compiler optimization |
| Shader `Texture2D` | `Texture` base type | 4.4 change |
| Manual viewport post-processing chain | `Compositor` + `CompositorEffect` | Structured post-processing (4.3+) |
| GodotPhysics3D for new projects | Jolt Physics 3D | 4.6 default |

Source: `docs/engine-reference/godot/deprecated-apis.md`

### Cross-Cutting Constraints

- **Layer communication**: Upper layers may call lower layers directly; lower layers NEVER call upper layers; same-layer systems communicate via signals — source: architecture.md
- **Type safety**: All variables, parameters, and return values must be typed — use `Array[Type]` not bare `Array` — source: ADR-0002, deprecated patterns
- **`@onready` for node references**: Always cache node references with `@onready var`, never look up in `_process()` — source: deprecated patterns
- **Data-driven gameplay values**: All balance values must be external config (JSON), never hardcoded — source: coding-standards.md
- **ISerializable for persistence**: Any system that needs save/load must implement ISerializable — source: ADR-0001
- **Signal data contracts**: All cross-system signals must define payload types in ADR-0002 — source: ADR-0002
- **No Autoload for game entities**: Player, enemies, NPCs are scene nodes, never Autoloads — source: ADR-0001
- **Component pattern**: Core layer systems are Components (HealthComponent, CombatComponent, etc.) attached to entity nodes — supports multiple instances with data isolation — source: ADR-0001
- **Testability**: All public methods must be unit-testable (dependency injection over singletons) — source: coding-standards.md
- **Doc comments**: All public APIs must have doc comments — source: coding-standards.md
