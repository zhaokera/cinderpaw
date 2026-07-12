## Story140 destination: one bounded Central Tower threshold guard room.
class_name CentralTowerThresholdScene
extends Node2D

const SCENE_ID: StringName = &"area_05_central_tower"
const ENTRY_SPAWN_POINT: StringName = &"neon_rooftops_threshold_arrival"
const ROOFTOPS_SCENE_ID: StringName = &"area_05_neon_rooftops"
const ROOFTOPS_RETURN_SPAWN: StringName = &"central_tower_threshold_return"
const THRESHOLD_ROOST_ID: StringName = &"central_tower_threshold_roost"
const PLAYER_LIGHT_DAMAGE: int = 12
const TOWER_MUSIC_ID: StringName = &"mus_rooftop"
const TOWER_AMBIENT_ID: StringName = &"amb_rooftop"
const AUDIO_FADE_SEC: float = 0.8
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_threshold_1280x720.png"
)
const ROOST_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_threshold_roost_256x256.png"
)
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")

@onready var _background: Sprite2D = get_node_or_null("Background") as Sprite2D
@onready var _arrival_spawn: Marker2D = (
	get_node_or_null("NeonRooftopsThresholdArrival") as Marker2D
)
@onready var _threshold_roost: SavepointRuntime = (
	get_node_or_null("ThresholdRoost") as SavepointRuntime
)
@onready var _player: Node2D = get_node_or_null("Player") as Node2D
@onready var _camera: Camera2D = get_node_or_null("Player/Camera2D") as Camera2D
@onready var _return_route: Node2D = (
	get_node_or_null("NeonRooftopsReturnRoute") as Node2D
)
@onready var _return_prompt: Label = (
	get_node_or_null("NeonRooftopsReturnRoute/PromptLabel") as Label
)
@onready var _objective_label: Label = get_node_or_null("ObjectiveLabel") as Label
@onready var _hud: HUDManager = get_node_or_null("HUD") as HUDManager
@onready var _guard_controller: CentralTowerThresholdGuardController = (
	get_node_or_null("ThresholdGuardController")
	as CentralTowerThresholdGuardController
)
@onready var _game_flow: GameFlowController = (
	get_node_or_null("GameFlowController") as GameFlowController
)

var _scene_manager: Object = null
var _weapon_component: WeaponComponent = null
var _return_transition_requested: bool = false
var _last_return_rejected_reason: StringName = &""
var _last_return_request: Dictionary = {}
var _threshold_roost_activated: bool = false
var _last_discovered_savepoint: Dictionary = {}
var _last_player_hit_metadata: Dictionary = {}
var _audio_request_count: int = 0


func _ready() -> void:
	_align_player_to_arrival()
	_setup_weapon_component()
	_bind_player_combat_to_room()
	_setup_player_hud()
	_setup_guard_controller()
	_setup_threshold_roost()
	_setup_game_flow()
	_sync_return_route()
	_refresh_objective_text()
	_sync_objective_position()
	_request_threshold_audio()
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		configure_scene_manager_runtime(root_scene_manager)


func _process(delta: float) -> void:
	advance_central_tower_respawn_flow(delta)
	_sync_return_prompt_visibility()
	_refresh_objective_text()
	_sync_objective_position()
	if (
		not _return_transition_requested
		and Input.is_action_just_pressed(&"interact")
		and _is_provider_near_return(_player)
	):
		try_request_neon_rooftops_return(_player)


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_disconnect_scene_manager_failure_signal()
	_scene_manager = scene_manager
	if not _is_valid_scene_manager(_scene_manager):
		return false
	_connect_scene_manager_failure_signal()
	_apply_current_scene_manager_spawn_point()
	return true


func _connect_scene_manager_failure_signal() -> void:
	if _scene_manager == null or not _scene_manager.has_signal("on_scene_load_failed"):
		return
	var failed_signal: Signal = _scene_manager.get("on_scene_load_failed")
	if not failed_signal.is_connected(_on_scene_load_failed):
		failed_signal.connect(_on_scene_load_failed)


func _disconnect_scene_manager_failure_signal() -> void:
	if (
		_scene_manager == null
		or not is_instance_valid(_scene_manager)
		or not _scene_manager.has_signal("on_scene_load_failed")
	):
		return
	var failed_signal: Signal = _scene_manager.get("on_scene_load_failed")
	if failed_signal.is_connected(_on_scene_load_failed):
		failed_signal.disconnect(_on_scene_load_failed)


func _on_scene_load_failed(scene_id: StringName, reason: StringName) -> void:
	if scene_id != ROOFTOPS_SCENE_ID or not _return_transition_requested:
		return
	_return_transition_requested = false
	_record_return_rejection(reason if reason != &"" else &"load_failed")
	_last_return_request["load_failed_reason"] = String(reason)
	_sync_return_route()
	_refresh_objective_text()


func try_activate_threshold_guard(provider: Node = null) -> bool:
	if _guard_controller == null:
		return false
	return _guard_controller.try_activate(provider)


func request_threshold_guard_attack() -> bool:
	return (
		_guard_controller != null
		and _guard_controller.request_guard_attack()
	)


## Advances the existing death delay and revive protection deterministically.
func advance_central_tower_respawn_flow(delta_sec: float) -> void:
	if _game_flow == null:
		return
	_game_flow.advance_time(delta_sec)
	if _player != null and _player.has_method("set_control_locked"):
		_player.call(
			"set_control_locked",
			_is_room_player_control_locked()
		)


func apply_damage(
	target_id: int,
	final_damage: int,
	metadata: Dictionary = {}
) -> bool:
	return (
		_guard_controller != null
		and _guard_controller.handles_target_id(target_id)
		and _guard_controller.apply_damage(target_id, final_damage, metadata)
	)


## Supplies deterministic player scratch damage through the shared combat chain.
func calculate_damage(
	_attack_type: StringName,
	_weapon_id: StringName,
	_hit_frame: int,
	combo_index: int,
	_parry_timing: int,
	_attack_power: int,
	_enemy_defense: int,
	_skill_modifiers: Dictionary = {},
	_injected_damage_params: Dictionary = {},
	_data_manager: Object = null
) -> Dictionary:
	return {
		"final_damage": PLAYER_LIGHT_DAMAGE,
		"base_damage": PLAYER_LIGHT_DAMAGE,
		"attack_damage": float(PLAYER_LIGHT_DAMAGE),
		"reduction_factor": 1.0,
		"damage_multiplier": 1.0,
		"is_crit": false,
		"crit_type": &"none",
		"parry_type": &"none",
		"combo_stage": combo_index,
		"damage_category": &"scratch",
	}


func get_last_player_hit_metadata() -> Dictionary:
	return _last_player_hit_metadata.duplicate(true)


## Returns to the secured outer threshold in Neon Rooftops.
func try_request_neon_rooftops_return(provider: Node = null) -> bool:
	if _return_route == null or _return_transition_requested:
		_record_return_rejection(&"transition_already_requested")
		return false
	var request_provider: Node = _player if provider == null else provider
	if (
		not _return_route.has_method("can_request_transition")
		or not bool(_return_route.call("can_request_transition", request_provider))
	):
		_record_return_rejection(&"provider_out_of_range")
		return false
	if not _can_use_scene_manager_for(ROOFTOPS_SCENE_ID):
		return false
	if not _ensure_runtime_scene_root():
		_record_return_rejection(&"runtime_root_unavailable")
		return false
	if not _persist_progress():
		_record_return_rejection(&"state_persist_failed")
		return false
	if not _request_scene_change(ROOFTOPS_SCENE_ID, ROOFTOPS_RETURN_SPAWN):
		_record_return_rejection(&"request_rejected")
		return false
	_return_transition_requested = true
	_last_return_rejected_reason = &""
	_last_return_request = {
		"scene_id": String(ROOFTOPS_SCENE_ID),
		"spawn_point": String(ROOFTOPS_RETURN_SPAWN),
		"pending_scene": _get_pending_scene(),
		"pending_spawn_point": _get_pending_spawn_point(),
	}
	_sync_return_route()
	_refresh_objective_text()
	return true


## Called by the guard controller after activation, reset, or defeat.
func persist_central_tower_threshold_progress() -> bool:
	if not _is_valid_scene_manager(_scene_manager):
		return false
	return _persist_progress()


func get_local_state() -> Dictionary:
	var state: Dictionary = {
		"central_tower_threshold_roost_activated": _threshold_roost_activated,
		"central_tower_threshold_last_savepoint": (
			_last_discovered_savepoint.duplicate(true)
		),
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}
	if _guard_controller != null:
		state.merge(_guard_controller.get_local_state(), true)
	return state


func set_local_state(state: Dictionary) -> void:
	_threshold_roost_activated = bool(state.get(
		"central_tower_threshold_roost_activated",
		_threshold_roost_activated
	)) or _threshold_roost_activated
	var savepoint_value: Variant = state.get(
		"central_tower_threshold_last_savepoint",
		_last_discovered_savepoint
	)
	if savepoint_value is Dictionary:
		_last_discovered_savepoint = Dictionary(savepoint_value).duplicate(true)
	if _threshold_roost_activated and _last_discovered_savepoint.is_empty():
		_last_discovered_savepoint = _build_threshold_roost_state()
	_restore_player_unlocked_abilities(state)
	if _guard_controller != null:
		_guard_controller.set_local_state(state)
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_last_player_hit_metadata.clear()
	_sync_return_route()
	_refresh_objective_text()
	_apply_current_scene_manager_spawn_point()


func capture_no_loss_state() -> Dictionary:
	return get_local_state()


func restore_no_loss_state(snapshot: Dictionary) -> void:
	var restored_snapshot: Dictionary = snapshot.duplicate(true)
	var cleared_after_snapshot: bool = (
		_guard_controller != null
		and bool(_guard_controller.get_local_state().get(
			"central_tower_threshold_guard_defeated",
			false
		))
	)
	if cleared_after_snapshot:
		restored_snapshot["central_tower_threshold_guard_activated"] = true
		restored_snapshot["central_tower_threshold_guard_defeated"] = true
	set_local_state(restored_snapshot)
	if (
		_guard_controller != null
		and not bool(_guard_controller.get_local_state().get(
			"central_tower_threshold_guard_defeated",
			false
		))
	):
		_guard_controller.reset_failed_attempt()
	_persist_progress()


func get_last_discovered_savepoint() -> Dictionary:
	return _last_discovered_savepoint.duplicate(true)


func get_central_tower_threshold_diagnostics() -> Dictionary:
	var diagnostics: Dictionary = (
		_guard_controller.get_diagnostics()
		if _guard_controller != null
		else {
			"controller_present": false,
			"encounter_state": "missing",
		}
	)
	diagnostics.merge({
		"scene_id": String(SCENE_ID),
		"scene_size_px": Vector2i(1280, 720),
		"background_texture_path": _texture_path(_background),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"threshold_roost_texture_path": _savepoint_texture_path(),
		"threshold_roost_expected_path": ROOST_TEXTURE_PATH,
		"threshold_roost_activated": _threshold_roost_activated,
		"last_discovered_savepoint": _last_discovered_savepoint.duplicate(true),
		"arrival_spawn_position": (
			_arrival_spawn.global_position
			if _arrival_spawn != null
			else Vector2.ZERO
		),
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"return_target_scene_id": String(ROOFTOPS_SCENE_ID),
		"return_spawn_point": String(ROOFTOPS_RETURN_SPAWN),
		"return_transition_requested": _return_transition_requested,
		"last_return_rejected_reason": String(_last_return_rejected_reason),
		"last_return_request": _last_return_request.duplicate(true),
		"objective_text": _objective_label.text if _objective_label != null else "",
		"flow_state": String(_game_flow.get_flow_state()) if _game_flow != null else "",
		"player_control_locked": _is_room_player_control_locked(),
		"music_id": String(TOWER_MUSIC_ID),
		"ambient_id": String(TOWER_AMBIENT_ID),
		"audio_request_count": _audio_request_count,
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}, true)
	return diagnostics


func _setup_weapon_component() -> void:
	_weapon_component = get_node_or_null("WeaponComponent") as WeaponComponent
	if _weapon_component == null:
		_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
		_weapon_component.name = "WeaponComponent"
		add_child(_weapon_component)
	var data_manager: Node = get_node_or_null("/root/DataManager")
	if data_manager != null:
		_weapon_component.set_data_manager(data_manager)


func _bind_player_combat_to_room() -> void:
	if _player == null:
		return
	if _player.has_method("set_target_health_adapter"):
		_player.call("set_target_health_adapter", self)
	if _player.has_method("set_damage_calculator_adapter"):
		_player.call("set_damage_calculator_adapter", self)
	if _player.has_method("set_weapon_component"):
		_player.call("set_weapon_component", _weapon_component)
	if _weapon_component != null:
		if _player.has_method("get_combat_component"):
			_weapon_component.set_combat_adapter(_player.call("get_combat_component"))
		if _player.has_method("get_collision_component"):
			_weapon_component.set_collision_adapter(_player.call(
				"get_collision_component"
			))
	if _player.has_signal("attack_landed"):
		var attack_signal: Signal = _player.get("attack_landed")
		if not attack_signal.is_connected(_on_player_attack_landed):
			attack_signal.connect(_on_player_attack_landed)


func _on_player_attack_landed(metadata: Dictionary) -> void:
	_last_player_hit_metadata = metadata.duplicate(true)


func _setup_guard_controller() -> void:
	if _guard_controller == null:
		return
	if not _guard_controller.objective_changed.is_connected(
		_on_guard_objective_changed
	):
		_guard_controller.objective_changed.connect(_on_guard_objective_changed)
	_guard_controller.configure_runtime(_player, self)


func _on_guard_objective_changed(_objective_text: String) -> void:
	_refresh_objective_text()


func _setup_threshold_roost() -> void:
	if _threshold_roost == null:
		return
	if not _threshold_roost.savepoint_activated.is_connected(
		_on_threshold_roost_activated
	):
		_threshold_roost.savepoint_activated.connect(_on_threshold_roost_activated)
	call_deferred("_activate_threshold_roost_on_first_entry")


func _activate_threshold_roost_on_first_entry() -> void:
	if _threshold_roost_activated or _threshold_roost == null:
		return
	_threshold_roost.try_activate(_player)


func _on_threshold_roost_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	if savepoint_id != THRESHOLD_ROOST_ID or scene_id != SCENE_ID:
		return
	_threshold_roost_activated = true
	_last_discovered_savepoint = context.duplicate(true)
	var respawn_position: Vector2 = (
		_arrival_spawn.global_position
		if _arrival_spawn != null
		else world_position
	)
	_last_discovered_savepoint["id"] = String(savepoint_id)
	_last_discovered_savepoint["scene_id"] = String(scene_id)
	_last_discovered_savepoint["spawn_point"] = String(spawn_point)
	_last_discovered_savepoint["position"] = {
		"x": respawn_position.x,
		"y": respawn_position.y,
	}
	_persist_progress()


func _setup_game_flow() -> void:
	if _game_flow == null or _arrival_spawn == null:
		return
	_game_flow.set_process(false)
	_game_flow.start_encounter(_arrival_spawn.global_position)
	_game_flow.configure_clan_base_respawn(
		SCENE_ID,
		ENTRY_SPAWN_POINT,
		_arrival_spawn.global_position
	)
	_game_flow.set_savepoint_adapter(self)
	_game_flow.set_no_loss_state_adapter(self)
	if not _game_flow.respawn_requested.is_connected(_on_respawn_requested):
		_game_flow.respawn_requested.connect(_on_respawn_requested)
	if _player != null and _player.has_signal("player_died"):
		var death_signal: Signal = _player.get("player_died")
		if not death_signal.is_connected(_on_player_died):
			death_signal.connect(_on_player_died)


func _on_player_died(_metadata: Dictionary) -> void:
	if _game_flow == null:
		return
	_game_flow.handle_player_death()
	if _player != null and _player.has_method("set_control_locked"):
		_player.call("set_control_locked", true)


func _on_respawn_requested(
	respawn_position: Vector2,
	revive_hp_percentage: float
) -> void:
	if _player != null and _player.has_method("respawn_at"):
		_player.call("respawn_at", respawn_position, revive_hp_percentage)
	if _hud != null and _player != null:
		_hud.update_hp(
			int(_player.call("get_current_hp")),
			int(_player.call("get_max_hp"))
		)


func _is_room_player_control_locked() -> bool:
	return _game_flow != null and _game_flow.get_flow_state() == &"dying"


func _setup_player_hud() -> void:
	if _player == null or _hud == null:
		return
	if _player.has_signal("player_health_changed"):
		var health_signal: Signal = _player.get("player_health_changed")
		if not health_signal.is_connected(_on_player_health_changed):
			health_signal.connect(_on_player_health_changed)
	if _player.has_method("get_current_hp") and _player.has_method("get_max_hp"):
		_hud.update_hp(
			int(_player.call("get_current_hp")),
			int(_player.call("get_max_hp"))
		)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	if _hud != null:
		_hud.update_hp(current_hp, max_hp)


func _sync_return_route() -> void:
	if _return_route == null:
		return
	if _return_route.has_method("set_route_available"):
		_return_route.call("set_route_available", true)
	if _return_route.has_method("set_transition_requested"):
		_return_route.call(
			"set_transition_requested",
			_return_transition_requested
		)
	_sync_return_prompt_visibility()


func _sync_return_prompt_visibility() -> void:
	if _return_prompt != null:
		_return_prompt.visible = (
			not _return_transition_requested
			and _is_provider_near_return(_player)
		)


func _refresh_objective_text() -> void:
	if _objective_label == null:
		return
	if _return_transition_requested:
		_objective_label.text = "Returning to Neon Rooftops"
	elif _guard_controller != null:
		_objective_label.text = _guard_controller.get_objective_text()
	else:
		_objective_label.text = "Cross the Tower Threshold"


func _sync_objective_position() -> void:
	if _objective_label == null or _camera == null or not _camera.is_inside_tree():
		return
	_objective_label.position = (
		_camera.get_screen_center_position() + Vector2(-250.0, -288.0)
	)


func _request_threshold_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("play_music"):
		audio_system.call("play_music", TOWER_MUSIC_ID, AUDIO_FADE_SEC)
		_audio_request_count += 1
	if audio_system.has_method("play_ambient"):
		audio_system.call("play_ambient", TOWER_AMBIENT_ID, AUDIO_FADE_SEC)
		_audio_request_count += 1


func _align_player_to_arrival() -> bool:
	if _player == null or _arrival_spawn == null:
		return false
	_player.global_position = _arrival_spawn.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func _apply_current_scene_manager_spawn_point() -> void:
	if not _is_valid_scene_manager(_scene_manager):
		_align_player_to_arrival()
		return
	if _scene_manager.has_method("get_current_scene") and StringName(
		_scene_manager.call("get_current_scene")
	) != SCENE_ID:
		return
	var spawn_point: StringName = ENTRY_SPAWN_POINT
	if _scene_manager.has_method("get_current_spawn_point"):
		spawn_point = StringName(_scene_manager.call("get_current_spawn_point"))
	if spawn_point in [ENTRY_SPAWN_POINT, &"default"]:
		_align_player_to_arrival()


func _build_threshold_roost_state() -> Dictionary:
	var spawn_position: Vector2 = (
		_arrival_spawn.global_position
		if _arrival_spawn != null
		else (_threshold_roost.global_position if _threshold_roost != null else Vector2.ZERO)
	)
	return {
		"id": String(THRESHOLD_ROOST_ID),
		"scene_id": String(SCENE_ID),
		"spawn_point": String(ENTRY_SPAWN_POINT),
		"display_name": "Threshold Roost",
		"position": {"x": spawn_position.x, "y": spawn_position.y},
	}


func _is_provider_near_return(provider: Node) -> bool:
	return (
		_return_route != null
		and provider != null
		and _return_route.has_method("is_provider_in_transition_range")
		and bool(_return_route.call("is_provider_in_transition_range", provider))
	)


func _persist_progress() -> bool:
	if (
		not _is_valid_scene_manager(_scene_manager)
		or not _scene_manager.has_method("set_scene_state")
	):
		return false
	var persisted: bool = bool(_scene_manager.call(
		"set_scene_state",
		SCENE_ID,
		get_local_state()
	))
	return _merge_player_abilities_into_scene_state(ROOFTOPS_SCENE_ID) and persisted


func _merge_player_abilities_into_scene_state(scene_id: StringName) -> bool:
	if (
		_scene_manager.has_method("has_scene")
		and not bool(_scene_manager.call("has_scene", scene_id))
	):
		return false
	var state: Dictionary = {}
	if _scene_manager.has_method("get_scene_state"):
		state = Dictionary(_scene_manager.call("get_scene_state", scene_id)).duplicate(true)
	var abilities: Array = Array(state.get("unlocked_abilities", []))
	for ability_id: String in _get_player_unlocked_ability_strings():
		if not abilities.has(ability_id):
			abilities.append(ability_id)
	state["unlocked_abilities"] = abilities
	return bool(_scene_manager.call("set_scene_state", scene_id, state))


func _can_use_scene_manager_for(scene_id: StringName) -> bool:
	if not _is_valid_scene_manager(_scene_manager):
		_record_return_rejection(&"scene_manager_missing")
		return false
	if _scene_manager.has_method("is_loading") and bool(
		_scene_manager.call("is_loading")
	):
		_record_return_rejection(&"scene_manager_loading")
		return false
	if _scene_manager.has_method("is_scene_locked") and bool(
		_scene_manager.call("is_scene_locked")
	):
		_record_return_rejection(&"scene_locked")
		return false
	if _scene_manager.has_method("has_scene") and not bool(
		_scene_manager.call("has_scene", scene_id)
	):
		_record_return_rejection(&"unknown_scene")
		return false
	return true


func _ensure_runtime_scene_root() -> bool:
	if not _scene_manager.has_method("configure_runtime_scene_root"):
		return true
	if _scene_manager.has_method("is_runtime_scene_swap_enabled") and bool(
		_scene_manager.call("is_runtime_scene_swap_enabled")
	):
		return true
	return bool(_scene_manager.call(
		"configure_runtime_scene_root",
		get_parent(),
		self
	))


func _request_scene_change(scene_id: StringName, spawn_point: StringName) -> bool:
	if _scene_manager.has_method("request_scene_change"):
		return bool(_scene_manager.call(
			"request_scene_change",
			scene_id,
			spawn_point
		))
	if _scene_manager.has_method("change_scene"):
		return bool(_scene_manager.call("change_scene", scene_id, spawn_point))
	return false


func _get_player_unlocked_ability_strings() -> Array[String]:
	var unlocked: Array[String] = []
	if _player == null or not _player.has_method("get_unlocked_abilities"):
		return unlocked
	var values: Variant = _player.call("get_unlocked_abilities")
	if not values is Array:
		return unlocked
	for value: Variant in values:
		var ability_id: String = String(value)
		if not unlocked.has(ability_id):
			unlocked.append(ability_id)
	return unlocked


func _restore_player_unlocked_abilities(state: Dictionary) -> void:
	if _player == null or not _player.has_method("set_unlocked_abilities"):
		return
	_player.call(
		"set_unlocked_abilities",
		Array(state.get(
			"unlocked_abilities",
			_get_player_unlocked_ability_strings()
		))
	)


func _savepoint_texture_path() -> String:
	return (
		_threshold_roost.get_visual_texture_path()
		if _threshold_roost != null
		else ""
	)


func _texture_path(sprite: Sprite2D) -> String:
	return (
		sprite.texture.resource_path
		if sprite != null and sprite.texture != null
		else ""
	)


func _record_return_rejection(reason: StringName) -> void:
	_last_return_rejected_reason = reason


func _get_pending_scene() -> String:
	return (
		String(_scene_manager.call("get_pending_scene"))
		if _scene_manager.has_method("get_pending_scene")
		else ""
	)


func _get_pending_spawn_point() -> String:
	return (
		String(_scene_manager.call("get_pending_spawn_point"))
		if _scene_manager.has_method("get_pending_spawn_point")
		else ""
	)


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and (
			scene_manager.has_method("request_scene_change")
			or scene_manager.has_method("change_scene")
		)
	)
