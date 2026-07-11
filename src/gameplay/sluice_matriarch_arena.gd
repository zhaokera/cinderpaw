## Scene controller for the Story127 Sluice Matriarch arena handoff.
class_name SluiceMatriarchArena
extends Node2D

const SCENE_ID: StringName = &"boss_03_sluice_matriarch_arena"
const ENTRY_SPAWN_POINT: StringName = &"boss_entry"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_RETURN_SPAWN_POINT: StringName = &"tailrace_matriarch_gate_return"
const BOSS_ENTITY_ID: int = 2300
const BOSS_ID: StringName = &"boss_03_sluice_matriarch"
const BOSS_DISPLAY_NAME: String = "Sluice Matriarch"
const BOSS_DEFEATED_STATE_KEY: String = "boss_03_sluice_matriarch_defeated"
const PLAYER_LIGHT_DAMAGE: int = 12
const BOSS_PRESSURE_LUNGE_HITBOX_ID: StringName = &"sluice_matriarch_pressure_lunge"
const BOSS_PRESSURE_LUNGE_DAMAGE: int = 16
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/sluice_matriarch_arena/"
	+ "env_sluice_matriarch_arena_backdrop_1280x720.png"
)

@onready var _player: Node2D = get_node_or_null("Player") as Node2D
@onready var _entry_spawn: Marker2D = get_node_or_null("BossEntrySpawn") as Marker2D
@onready var _background: Sprite2D = get_node_or_null("Background") as Sprite2D
@onready var _return_route: Node = get_node_or_null("FactoryReturnRoute")
@onready var _objective_label: Label = get_node_or_null("ArenaObjectiveLabel") as Label
@onready var _boss: Node2D = get_node_or_null("SluiceMatriarchBoss") as Node2D
@onready var _hud: HUDManager = get_node_or_null("HUD") as HUDManager
@onready var _left_room_seal: StaticBody2D = (
	get_node_or_null("LeftRoomSeal") as StaticBody2D
)
@onready var _right_room_seal: StaticBody2D = (
	get_node_or_null("RightRoomSeal") as StaticBody2D
)

var _scene_manager: Object = null
var _return_transition_requested: bool = false
var _last_return_rejected_reason: StringName = &""
var _last_return_request: Dictionary = {}
var _boss_defeated: bool = false
var _last_player_hit_metadata: Dictionary = {}
var _last_boss_attack_metadata: Dictionary = {}
var _player_retry_pending: bool = false
var _player_death_count: int = 0
var _scene_manager_lock_owned: bool = false
var _weapon_component: WeaponComponent = null


func _ready() -> void:
	_align_player_to_entry_spawn()
	_setup_weapon_component()
	_setup_boss3_combat()
	_sync_boss3_combat_state()
	_sync_return_route()
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		configure_scene_manager_runtime(root_scene_manager)


func _process(_delta: float) -> void:
	_process_factory_return_contact()


func _exit_tree() -> void:
	_release_scene_lock()


func calculate_damage(
	_attack_type: StringName,
	weapon_id: StringName,
	_hit_frame: int,
	combo_index: int,
	_parry_timing: int,
	_attack_power: int,
	_enemy_defense: int,
	_skill_modifiers: Dictionary = {},
	_injected_damage_params: Dictionary = {},
	_data_manager: Object = null
) -> Dictionary:
	var damage: int = (
		BOSS_PRESSURE_LUNGE_DAMAGE
		if weapon_id == BOSS_PRESSURE_LUNGE_HITBOX_ID
		else PLAYER_LIGHT_DAMAGE
	)
	return {
		"final_damage": damage,
		"base_damage": damage,
		"attack_damage": float(damage),
		"reduction_factor": 1.0,
		"damage_multiplier": 1.0,
		"is_crit": false,
		"crit_type": &"none",
		"parry_type": &"none",
		"combo_stage": combo_index,
		"damage_category": &"scratch",
	}


func apply_damage(target_id: int, final_damage: int, metadata: Dictionary = {}) -> bool:
	if (
		target_id != BOSS_ENTITY_ID
		or _boss == null
		or not _boss.has_method("apply_damage")
		or final_damage <= 0
	):
		return false
	_boss.call("apply_damage", final_damage, metadata)
	return true


## Injects the SceneManager adapter and reapplies the requested arena spawn.
func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	if _scene_manager != scene_manager:
		_release_scene_lock()
	_scene_manager = scene_manager
	if not _is_valid_scene_manager(_scene_manager):
		return false
	_apply_current_scene_manager_spawn_point()
	_sync_scene_lock()
	return true


## Requests the repeatable return route to the Tailrace gate once per scene visit.
func try_request_factory_return(provider: Node = null) -> bool:
	if _return_route == null or _return_transition_requested:
		_record_return_rejection(&"transition_already_requested")
		return false
	var request_provider: Node = _player if provider == null else provider
	if not _return_route.has_method("can_request_transition") \
			or not bool(_return_route.call("can_request_transition", request_provider)):
		_record_return_rejection(&"provider_out_of_range")
		return false
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		_record_return_rejection(&"scene_manager_missing")
		return false
	if scene_manager.has_method("is_loading") and bool(scene_manager.call("is_loading")):
		_record_return_rejection(&"scene_manager_loading")
		return false
	if scene_manager.has_method("is_scene_locked") \
			and bool(scene_manager.call("is_scene_locked")):
		_record_return_rejection(&"scene_locked")
		return false
	if scene_manager.has_method("has_scene") \
			and not bool(scene_manager.call("has_scene", FACTORY_SCENE_ID)):
		_record_return_rejection(&"unknown_scene")
		return false
	if not _ensure_runtime_scene_root(scene_manager):
		_record_return_rejection(&"runtime_root_unavailable")
		return false
	if not _request_scene_change(
		scene_manager,
		FACTORY_SCENE_ID,
		FACTORY_RETURN_SPAWN_POINT
	):
		_record_return_rejection(&"request_rejected")
		return false

	_return_transition_requested = true
	_last_return_rejected_reason = &""
	_last_return_request = {
		"scene_id": String(FACTORY_SCENE_ID),
		"spawn_point": String(FACTORY_RETURN_SPAWN_POINT),
		"pending_scene": _get_pending_scene(scene_manager),
		"pending_spawn_point": _get_pending_spawn_point(scene_manager),
	}
	_return_route.call("set_transition_requested", true)
	if _objective_label != null:
		_objective_label.text = "Returning to Tailrace Spillway"
	return true


## Captures only durable discovery; transition latches intentionally stay transient.
func get_local_state() -> Dictionary:
	return {
		"sluice_matriarch_arena_discovered": true,
		BOSS_DEFEATED_STATE_KEY: _boss_defeated,
	}


## Restores the reusable arena entry without carrying a stale request latch.
func set_local_state(state: Dictionary) -> void:
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_boss_defeated = bool(state.get(BOSS_DEFEATED_STATE_KEY, false))
	if _boss != null:
		if _boss_defeated and _boss.has_method("mark_defeated_from_progress"):
			_boss.call("mark_defeated_from_progress")
		elif not _boss_defeated and _boss.has_method("reset_encounter"):
			_boss.call("reset_encounter")
	_sync_boss3_combat_state()
	_sync_return_route()
	_align_player_to_entry_spawn()


## Returns deterministic scene, art, spawn, and transition evidence for tests/MCP.
func get_arena_handoff_diagnostics() -> Dictionary:
	var background_path: String = ""
	if _background != null and _background.texture != null:
		background_path = _background.texture.resource_path
	return {
		"scene_id": String(SCENE_ID),
		"background_texture_path": background_path,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"entry_spawn_position": (
			_entry_spawn.global_position if _entry_spawn != null else Vector2.ZERO
		),
		"return_route_present": _return_route != null,
		"return_route_available": (
			bool(_return_route.call("is_route_available"))
			if _return_route != null and _return_route.has_method("is_route_available")
			else false
		),
		"return_prompt_text": (
			String(_return_route.call("get_prompt_text"))
			if _return_route != null and _return_route.has_method("get_prompt_text")
			else ""
		),
		"return_target_scene_id": String(FACTORY_SCENE_ID),
		"return_spawn_point": String(FACTORY_RETURN_SPAWN_POINT),
		"return_transition_requested": _return_transition_requested,
		"return_rejected_reason": String(_last_return_rejected_reason),
		"last_return_request": _last_return_request.duplicate(true),
		"scene_manager_loading": _is_scene_manager_loading(),
		"scene_manager_locked": _is_scene_manager_locked(),
		"scene_manager_lock_owned": _scene_manager_lock_owned,
		"objective_text": _objective_label.text if _objective_label != null else "",
	}


func get_boss3_combat_diagnostics() -> Dictionary:
	var boss_sprite: AnimatedSprite2D = (
		_boss.get_node_or_null("Sprite") as AnimatedSprite2D if _boss != null else null
	)
	var boss_panel: Control = (
		_hud.get_node_or_null("HudRoot/BossHudPanel") as Control if _hud != null else null
	)
	return {
		"boss_present": _boss != null,
		"boss_entity_id": (
			int(_boss.call("get_entity_id"))
			if _boss != null and _boss.has_method("get_entity_id")
			else -1
		),
		"boss_id": String(BOSS_ID),
		"boss_display_name": BOSS_DISPLAY_NAME,
		"boss_hp": (
			int(_boss.call("get_current_hp"))
			if _boss != null and _boss.has_method("get_current_hp")
			else 0
		),
		"boss_max_hp": (
			int(_boss.call("get_max_hp"))
			if _boss != null and _boss.has_method("get_max_hp")
			else 0
		),
		"boss_phase": (
			int(_boss.call("get_current_phase"))
			if _boss != null and _boss.has_method("get_current_phase")
			else 0
		),
		"boss_defeated": _boss_defeated,
		"boss_visible": _boss != null and _boss.visible,
		"boss_animation": String(boss_sprite.animation) if boss_sprite != null else "",
		"boss_hud_visible": boss_panel != null and boss_panel.visible,
		"boss_hud_label": _hud.get_boss_label_text() if _hud != null else "",
		"room_seals_enabled": _are_room_seals_enabled(),
		"left_room_seal_visible": (
			_left_room_seal != null and _left_room_seal.visible
		),
		"right_room_seal_visible": (
			_right_room_seal != null and _right_room_seal.visible
		),
		"return_route_available": (
			bool(_return_route.call("is_route_available"))
			if _return_route != null and _return_route.has_method("is_route_available")
			else false
		),
		"return_transition_requested": _return_transition_requested,
		"scene_manager_locked": _is_scene_manager_locked(),
		"scene_manager_lock_owned": _scene_manager_lock_owned,
		"last_player_hit_metadata": _last_player_hit_metadata.duplicate(true),
		"last_boss_attack_metadata": _last_boss_attack_metadata.duplicate(true),
		"player_retry_pending": _player_retry_pending,
		"player_death_count": _player_death_count,
	}


func _process_factory_return_contact() -> void:
	if (
		_player == null
		or _return_route == null
		or _return_transition_requested
		or not _return_route.has_method("is_provider_in_transition_range")
	):
		return
	if bool(_return_route.call("is_provider_in_transition_range", _player)):
		try_request_factory_return(_player)


func _sync_return_route() -> void:
	if _return_route == null:
		return
	if _return_route.has_method("set_route_available"):
		_return_route.call("set_route_available", _boss_defeated)
	if _return_route.has_method("set_transition_requested"):
		_return_route.call("set_transition_requested", _return_transition_requested)


func _setup_boss3_combat() -> void:
	if _player != null:
		if _player.has_method("set_target_health_adapter"):
			_player.call("set_target_health_adapter", self)
		if _player.has_method("set_damage_calculator_adapter"):
			_player.call("set_damage_calculator_adapter", self)
		if _player.has_method("set_weapon_component"):
			_player.call("set_weapon_component", _weapon_component)
		if _weapon_component != null:
			if _player.has_method("get_combat_component"):
				_weapon_component.set_combat_adapter(
					_player.call("get_combat_component")
				)
			if _player.has_method("get_collision_component"):
				_weapon_component.set_collision_adapter(
					_player.call("get_collision_component")
				)
		if _player.has_signal("attack_landed"):
			var player_attack_signal: Signal = _player.get("attack_landed")
			if not player_attack_signal.is_connected(_on_player_attack_landed):
				player_attack_signal.connect(_on_player_attack_landed)
		if _player.has_signal("player_health_changed"):
			var player_health_signal: Signal = _player.get("player_health_changed")
			if not player_health_signal.is_connected(_on_player_health_changed):
				player_health_signal.connect(_on_player_health_changed)
		if _player.has_signal("player_died"):
			var player_died_signal: Signal = _player.get("player_died")
			if not player_died_signal.is_connected(_on_player_died):
				player_died_signal.connect(_on_player_died)
	if _boss == null:
		return
	if _boss.has_method("set_attack_target"):
		_boss.call("set_attack_target", _player)
	if _boss.has_method("set_damage_calculator_adapter"):
		_boss.call("set_damage_calculator_adapter", self)
	if _boss.has_signal("boss_health_changed"):
		var health_signal: Signal = _boss.get("boss_health_changed")
		if not health_signal.is_connected(_on_boss3_health_changed):
			health_signal.connect(_on_boss3_health_changed)
	if _boss.has_signal("boss_defeated"):
		var defeated_signal: Signal = _boss.get("boss_defeated")
		if not defeated_signal.is_connected(_on_boss3_defeated):
			defeated_signal.connect(_on_boss3_defeated)
	if _boss.has_signal("enemy_attack_landed"):
		var attack_signal: Signal = _boss.get("enemy_attack_landed")
		if not attack_signal.is_connected(_on_boss3_attack_landed):
			attack_signal.connect(_on_boss3_attack_landed)
	if _boss.has_signal("on_boss_phase_transition_started"):
		var phase_signal: Signal = _boss.get("on_boss_phase_transition_started")
		if not phase_signal.is_connected(_on_boss3_phase_transition_started):
			phase_signal.connect(_on_boss3_phase_transition_started)


func _setup_weapon_component() -> void:
	_weapon_component = get_node_or_null("WeaponComponent") as WeaponComponent
	if _weapon_component == null:
		_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
		_weapon_component.name = "WeaponComponent"
		add_child(_weapon_component)
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		_weapon_component.set_data_manager(root_data_manager)


func _sync_boss3_combat_state() -> void:
	if _boss != null and _boss_defeated \
			and _boss.has_method("mark_defeated_from_progress"):
		_boss.call("mark_defeated_from_progress")
	_set_room_seals_enabled(not _boss_defeated)
	_sync_return_route()
	_sync_scene_lock()
	if _hud != null:
		if _boss_defeated or _boss == null:
			_hud.hide_boss_hp()
		else:
			_hud.update_boss_hp(
				int(_boss.call("get_current_hp")),
				int(_boss.call("get_max_hp")),
				int(_boss.call("get_current_phase")),
				BOSS_DISPLAY_NAME
			)
		if _player != null:
			_hud.update_hp(
				int(_player.call("get_current_hp")),
				int(_player.call("get_max_hp"))
			)
	if _objective_label != null and not _return_transition_requested:
		_objective_label.text = (
			"Sluice Matriarch Defeated"
			if _boss_defeated
			else "Defeat Sluice Matriarch"
		)


func _set_room_seals_enabled(enabled: bool) -> void:
	for seal: StaticBody2D in [_left_room_seal, _right_room_seal]:
		if seal == null:
			continue
		seal.visible = enabled
		seal.collision_layer = 16 if enabled else 0
		var collision_shape: CollisionShape2D = (
			seal.get_node_or_null("CollisionShape2D") as CollisionShape2D
		)
		if collision_shape != null:
			collision_shape.disabled = not enabled


func _are_room_seals_enabled() -> bool:
	for seal: StaticBody2D in [_left_room_seal, _right_room_seal]:
		if seal == null or not seal.visible or seal.collision_layer == 0:
			return false
		var collision_shape: CollisionShape2D = (
			seal.get_node_or_null("CollisionShape2D") as CollisionShape2D
		)
		if collision_shape == null or collision_shape.disabled:
			return false
	return true


func _sync_scene_lock() -> void:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		return
	if _boss_defeated:
		_release_scene_lock()
		return
	if _scene_manager_lock_owned:
		return
	if scene_manager.has_method("is_scene_locked") \
			and bool(scene_manager.call("is_scene_locked")):
		return
	if scene_manager.has_method("lock_scene"):
		scene_manager.call("lock_scene")
		_scene_manager_lock_owned = true


func _release_scene_lock() -> void:
	if not _scene_manager_lock_owned:
		return
	if _scene_manager != null and is_instance_valid(_scene_manager) \
			and _scene_manager.has_method("unlock_scene"):
		_scene_manager.call("unlock_scene")
	_scene_manager_lock_owned = false


func _on_player_attack_landed(metadata: Dictionary) -> void:
	_last_player_hit_metadata = metadata.duplicate(true)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	if _hud != null:
		_hud.update_hp(current_hp, max_hp)


func _on_player_died(_death_metadata: Dictionary) -> void:
	if _boss_defeated or _player_retry_pending:
		return
	_player_retry_pending = true
	_player_death_count += 1
	call_deferred("_reset_active_boss3_encounter_after_player_death")


func _reset_active_boss3_encounter_after_player_death() -> void:
	_player_retry_pending = false
	if _boss_defeated:
		return
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_last_boss_attack_metadata.clear()
	if _boss != null and _boss.has_method("reset_encounter"):
		_boss.call("reset_encounter")
	if _player != null and _entry_spawn != null and _player.has_method("respawn_at"):
		_player.call("respawn_at", _entry_spawn.global_position, 1.0)
	_sync_boss3_combat_state()


func _on_boss3_health_changed(current_hp: int, max_hp: int) -> void:
	if _hud == null or _boss_defeated or _boss == null:
		return
	_hud.update_boss_hp(
		current_hp,
		max_hp,
		int(_boss.call("get_current_phase")),
		BOSS_DISPLAY_NAME
	)


func _on_boss3_defeated() -> void:
	_boss_defeated = true
	_sync_boss3_combat_state()


func _on_boss3_phase_transition_started(
	_entity_id: int,
	_phase: int,
	_metadata: Dictionary
) -> void:
	if _boss == null or _boss_defeated:
		return
	_on_boss3_health_changed(
		int(_boss.call("get_current_hp")),
		int(_boss.call("get_max_hp"))
	)


func _on_boss3_attack_landed(
	damage: int,
	hit_position: Vector2,
	is_crit: bool
) -> void:
	_last_boss_attack_metadata = {
		"damage": damage,
		"hit_position": hit_position,
		"is_crit": is_crit,
		"source": BOSS_ID,
	}


func _align_player_to_entry_spawn() -> bool:
	if _player == null or _entry_spawn == null:
		return false
	_player.global_position = _entry_spawn.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func _apply_current_scene_manager_spawn_point() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null or not scene_manager.has_method("get_current_scene"):
		return false
	if StringName(scene_manager.call("get_current_scene")) != SCENE_ID:
		return false
	if not scene_manager.has_method("get_current_spawn_point"):
		return false
	var spawn_point: StringName = StringName(scene_manager.call("get_current_spawn_point"))
	if spawn_point != ENTRY_SPAWN_POINT:
		return false
	return _align_player_to_entry_spawn()


func _resolve_scene_manager_for_runtime() -> Object:
	if _is_valid_scene_manager(_scene_manager):
		return _scene_manager
	if not is_inside_tree():
		return null
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		_scene_manager = root_scene_manager
		return _scene_manager
	return null


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and (
			scene_manager.has_method("request_scene_change")
			or scene_manager.has_method("change_scene")
		)
	)


func _ensure_runtime_scene_root(scene_manager: Object) -> bool:
	if not scene_manager.has_method("configure_runtime_scene_root"):
		return true
	if scene_manager.has_method("is_runtime_scene_swap_enabled") \
			and bool(scene_manager.call("is_runtime_scene_swap_enabled")):
		return true
	if not is_inside_tree() or get_parent() == null:
		return false
	return bool(scene_manager.call("configure_runtime_scene_root", get_parent(), self))


func _request_scene_change(
	scene_manager: Object,
	scene_id: StringName,
	spawn_point: StringName
) -> bool:
	if scene_manager.has_method("request_scene_change"):
		return bool(scene_manager.call("request_scene_change", scene_id, spawn_point))
	if scene_manager.has_method("change_scene"):
		return bool(scene_manager.call("change_scene", scene_id, spawn_point))
	return false


func _record_return_rejection(reason: StringName) -> void:
	_last_return_rejected_reason = reason
	_last_return_request.clear()


func _is_scene_manager_loading() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	return (
		bool(scene_manager.call("is_loading"))
		if scene_manager != null and scene_manager.has_method("is_loading")
		else false
	)


func _is_scene_manager_locked() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	return (
		bool(scene_manager.call("is_scene_locked"))
		if scene_manager != null and scene_manager.has_method("is_scene_locked")
		else false
	)


func _get_pending_scene(scene_manager: Object) -> String:
	return (
		String(scene_manager.call("get_pending_scene"))
		if scene_manager.has_method("get_pending_scene")
		else ""
	)


func _get_pending_spawn_point(scene_manager: Object) -> String:
	return (
		String(scene_manager.call("get_pending_spawn_point"))
		if scene_manager.has_method("get_pending_spawn_point")
		else ""
	)
