## Owns Story142's Cooling Shaft savepoint, hazard, fall, and endpoint state.
class_name CentralTowerCoolingShaftController
extends Node2D

signal objective_changed(objective_text: String)

const ROUTE_WIDTH_PX: int = 3840
const ROUTE_ACTIVATION_X: float = 2920.0
const GAP_START_X: float = 2920.0
const GAP_END_X: float = 3480.0
const ARC_X: float = 3220.0
const ENDPOINT_X: float = 3690.0
const RIGHT_WALL_X: float = 3860.0
const ROOST_ID: StringName = &"central_tower_cooling_shaft_roost"
const ROOST_SCENE_ID: StringName = &"area_05_central_tower"
const ROOST_SPAWN_POINT: StringName = &"cooling_shaft_roost"
const HAZARD_ID: StringName = &"central_tower_cooling_shaft_arc"
const ENDPOINT_ID: StringName = &"central_tower_cooling_shaft_endpoint"
const ARC_DAMAGE: int = 10
const ARC_CONTACT_COOLDOWN_SEC: float = 1.0
const GRACE_DURATION_SEC: float = 0.75
const WARNING_DURATION_SEC: float = 0.50
const ACTIVE_DURATION_SEC: float = 0.35
const SAFE_DURATION_SEC: float = 0.70
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_cooling_shaft_1280x720.png"
)
const ROOST_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_cooling_roost_256x256.png"
)
const SPINE_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_cooling_spine_256x512.png"
)
const PERCH_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_cooling_perch_384x128.png"
)
const ENDPOINT_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_deep_lift_beacon_256x384.png"
)
const ARC_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "vfx_central_tower_cooling_arc_512x160.png"
)
const CONTACT_SPARK_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "vfx_central_tower_cooling_contact_spark_192x192.png"
)
const CONTACT_SPARK_TEXTURE: Texture2D = preload(CONTACT_SPARK_TEXTURE_PATH)
const SAVE_TRIGGER_ADAPTER_SCRIPT: Script = preload(
	"res://src/feature/save_trigger_adapter.gd"
)

@onready var _background: Sprite2D = (
	get_node_or_null("../CoolingShaftBackground") as Sprite2D
)
@onready var _roost: Node2D = get_node_or_null("CoolingShaftRoost") as Node2D
@onready var _roost_spawn: Marker2D = (
	get_node_or_null("CoolingShaftRoostSpawn") as Marker2D
)
@onready var _fall_zone: Area2D = (
	get_node_or_null("CoolingShaftFallZone") as Area2D
)
@onready var _arc_hazard: Area2D = (
	get_node_or_null("CoolingShaftArcHazard") as Area2D
)
@onready var _arc_visual: Sprite2D = (
	get_node_or_null("CoolingShaftArcHazard/Visual") as Sprite2D
)
@onready var _endpoint: Node2D = (
	get_node_or_null("CoolingShaftEndpoint") as Node2D
)
@onready var _roost_prompt: Label = (
	get_node_or_null("CoolingShaftRoost/PromptLabel") as Label
)
@onready var _endpoint_prompt: Label = (
	get_node_or_null("CoolingShaftEndpoint/PromptLabel") as Label
)
@onready var _left_spine_visual: Sprite2D = (
	get_node_or_null("../CoolingShaftLeftSpine/Visual") as Sprite2D
)
@onready var _perch_visual: Sprite2D = (
	get_node_or_null("../CoolingShaftMidPerch/Visual") as Sprite2D
)

var _route_unlocked: bool = false
var _roost_activated: bool = false
var _activated: bool = false
var _traversed: bool = false
var _player: Node2D = null
var _scene_owner: Object = null
var _save_trigger_adapter: SaveTriggerAdapter = null
var _last_savepoint: Dictionary = {}
var _hazard_phase: StringName = &"idle"
var _hazard_remaining_sec: float = 0.0
var _arc_contact_cooldown_remaining_sec: float = 0.0
var _autosave_request_count: int = 0
var _audio_request_count: int = 0
var _roost_feedback_count: int = 0
var _fall_accept_count: int = 0
var _endpoint_feedback_count: int = 0
var _contact_spark_spawn_count: int = 0
var _last_autosave_context: Dictionary = {}
var _last_audio_event: Dictionary = {}
var _last_emitted_objective_text: String = ""
var _contact_spark: Sprite2D = null
var _contact_spark_elapsed_sec: float = 0.0


func _ready() -> void:
	_connect_roost_signal()
	_connect_route_triggers()
	_sync_state()


func _process(delta: float) -> void:
	if (
		_route_unlocked
		and _roost_activated
		and not _activated
		and _player != null
		and _player.global_position.x >= ROUTE_ACTIVATION_X
	):
		try_activate(_player)
	advance_time(delta)
	_sync_prompt_visibility()


## Injects the player, parent scene, and optional SaveSystem adapter.
func configure_runtime(
	player: Node2D,
	scene_owner: Object,
	save_system: Object = null
) -> bool:
	_player = player
	_scene_owner = scene_owner
	_connect_roost_signal()
	_connect_route_triggers()
	if save_system != null:
		configure_save_system_runtime(save_system)
	_sync_state()
	return _player != null and _scene_owner != null


## Configures slot-zero autosave through the shared SaveTriggerAdapter.
func configure_save_system_runtime(save_system: Object) -> bool:
	if (
		save_system == null
		or not is_instance_valid(save_system)
		or not save_system.has_method("auto_save")
	):
		return false
	if _save_trigger_adapter == null or not is_instance_valid(
		_save_trigger_adapter
	):
		_save_trigger_adapter = (
			SAVE_TRIGGER_ADAPTER_SCRIPT.new() as SaveTriggerAdapter
		)
		_save_trigger_adapter.name = "CentralTowerCoolingShaftSaveTriggerAdapter"
		add_child(_save_trigger_adapter)
	var snapshot_provider := Callable()
	if _scene_owner != null and _scene_owner.has_method("capture_save_snapshot"):
		snapshot_provider = Callable(_scene_owner, "capture_save_snapshot")
	_save_trigger_adapter.configure(save_system, snapshot_provider)
	return true


## Story141's Mantis defeat is the only route prerequisite.
func set_route_unlocked(unlocked: bool) -> void:
	_route_unlocked = unlocked
	if not _route_unlocked:
		_set_hazard_phase(&"idle", 0.0)
	_sync_state()


## Attempts the nearby one-shot Cooling Shaft Roost activation.
func try_activate_roost(provider: Node = null) -> bool:
	if not _route_unlocked or _roost_activated or _roost == null:
		return false
	var activation_provider: Node = _player if provider == null else provider
	if not _is_provider_near(_roost, activation_provider, 104.0):
		return false
	if (
		not _roost.has_method("try_activate")
		or not bool(_roost.call("try_activate", activation_provider))
	):
		return false
	return _roost_activated


## Starts the deterministic arc loop after the provider crosses the gap lip.
func try_activate(provider: Node = null) -> bool:
	if not _route_unlocked or not _roost_activated or _activated or _traversed:
		return false
	var activation_provider: Node = _player if provider == null else provider
	if (
		activation_provider == null
		or activation_provider != _player
		or not activation_provider is Node2D
		or (activation_provider as Node2D).global_position.x < ROUTE_ACTIVATION_X
	):
		return false
	_activated = true
	_set_hazard_phase(&"grace", GRACE_DURATION_SEC)
	_sync_state()
	_persist_owner_state()
	return true


## Advances arc phase timing and the per-target contact cooldown.
func advance_time(delta_sec: float) -> void:
	var safe_delta: float = maxf(0.0, delta_sec)
	_arc_contact_cooldown_remaining_sec = maxf(
		0.0,
		_arc_contact_cooldown_remaining_sec - safe_delta
	)
	_advance_contact_spark(safe_delta)
	if not _activated or _traversed or safe_delta <= 0.0:
		return
	var remaining_delta: float = safe_delta
	var transition_guard: int = 0
	while remaining_delta > 0.0 and transition_guard < 8:
		transition_guard += 1
		if _hazard_remaining_sec > remaining_delta:
			_hazard_remaining_sec -= remaining_delta
			remaining_delta = 0.0
			continue
		remaining_delta -= _hazard_remaining_sec
		_advance_hazard_phase()
	_sync_hazard_visual()


## Applies one active-phase electrical contact through the real player API.
func apply_arc_contact(target: Node = null) -> bool:
	var contact_target: Node = _player if target == null else target
	if (
		not _activated
		or _traversed
		or _hazard_phase != &"active"
		or _arc_contact_cooldown_remaining_sec > 0.0
		or contact_target == null
		or contact_target != _player
		or not contact_target.has_method("apply_damage")
		or not contact_target.has_method("get_current_hp")
	):
		return false
	var hp_before: int = int(contact_target.call("get_current_hp"))
	if hp_before <= 0:
		return false
	contact_target.call("apply_damage", ARC_DAMAGE, {
		"source": HAZARD_ID,
		"damage_type": &"electric",
		"scene_id": ROOST_SCENE_ID,
	})
	if int(contact_target.call("get_current_hp")) >= hp_before:
		return false
	_arc_contact_cooldown_remaining_sec = ARC_CONTACT_COOLDOWN_SEC
	_spawn_contact_spark((contact_target as Node2D).global_position)
	return true


## Keeps the shaft lethal after completion so Roost retries cannot fall forever.
func apply_fall(target: Node = null) -> bool:
	var fall_target: Node = _player if target == null else target
	if (
		not _route_unlocked
		or not _roost_activated
		or not _activated
		or fall_target == null
		or fall_target != _player
		or not fall_target.has_method("apply_damage")
		or not fall_target.has_method("get_current_hp")
		or int(fall_target.call("get_current_hp")) <= 0
	):
		return false
	var lethal_damage: int = (
		int(fall_target.call("get_max_hp"))
		if fall_target.has_method("get_max_hp")
		else int(fall_target.call("get_current_hp"))
	)
	fall_target.call("apply_damage", lethal_damage, {
		"source": &"central_tower_cooling_shaft_fall",
		"damage_type": &"fall",
		"scene_id": ROOST_SCENE_ID,
	})
	if int(fall_target.call("get_current_hp")) > 0:
		return false
	_fall_accept_count += 1
	return true


## Records the far-side endpoint exactly once after route activation.
func try_activate_endpoint(provider: Node = null) -> bool:
	if not _route_unlocked or not _activated or _traversed:
		return false
	var activation_provider: Node = _player if provider == null else provider
	if not _is_provider_near(_endpoint, activation_provider, 112.0):
		return false
	_traversed = true
	_endpoint_feedback_count += 1
	_set_hazard_phase(&"idle", 0.0)
	_sync_state()
	_persist_owner_state()
	return true


## Returns the latest valid savepoint for the parent GameFlow controller.
func get_last_discovered_savepoint() -> Dictionary:
	return _last_savepoint.duplicate(true)


## Captures only durable Story142 state.
func get_local_state() -> Dictionary:
	return {
		"central_tower_cooling_shaft_roost_activated": _roost_activated,
		"central_tower_cooling_shaft_activated": _activated,
		"central_tower_cooling_shaft_traversed": _traversed,
		"central_tower_cooling_shaft_last_savepoint": (
			_last_savepoint.duplicate(true)
		),
	}


## Restores durable state without replaying one-shot feedback.
func set_local_state(state: Dictionary) -> void:
	_roost_activated = bool(state.get(
		"central_tower_cooling_shaft_roost_activated",
		false
	))
	_activated = bool(state.get(
		"central_tower_cooling_shaft_activated",
		false
	))
	_traversed = bool(state.get(
		"central_tower_cooling_shaft_traversed",
		false
	))
	if _traversed:
		_activated = true
	if _activated:
		_roost_activated = true
	_last_savepoint = Dictionary(state.get(
		"central_tower_cooling_shaft_last_savepoint",
		{}
	)).duplicate(true)
	if _roost_activated and _last_savepoint.is_empty():
		_last_savepoint = _build_roost_snapshot()
	_arc_contact_cooldown_remaining_sec = 0.0
	_clear_contact_spark()
	_set_hazard_phase(
		&"grace" if _activated and not _traversed else &"idle",
		GRACE_DURATION_SEC if _activated and not _traversed else 0.0
	)
	_sync_state()


## Aligns the player to the authored Cooling Shaft Roost marker.
func align_player_to_roost() -> bool:
	if _player == null or _roost_spawn == null:
		return false
	_player.global_position = _roost_spawn.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func should_own_objective(provider: Node = null) -> bool:
	if not _route_unlocked:
		return false
	if _roost_activated or _activated or _traversed:
		return true
	var objective_provider: Node = _player if provider == null else provider
	return (
		objective_provider is Node2D
		and (objective_provider as Node2D).global_position.x >= 2520.0
	)


func get_objective_text() -> String:
	if _traversed:
		return "Cooling Shaft Secured"
	if _activated:
		return "Cross Cooling Shaft"
	if _roost_activated:
		return "Enter Cooling Shaft"
	return "Activate Cooling Shaft Roost"


## Returns authored geometry, assets, savepoint, and hazard diagnostics.
func get_diagnostics() -> Dictionary:
	return {
		"route_width_px": ROUTE_WIDTH_PX,
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"background_texture_path": _get_sprite_texture_path(_background),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"roost_texture_path": _get_child_sprite_texture_path(_roost, "Visual"),
		"roost_expected_path": ROOST_TEXTURE_PATH,
		"spine_texture_path": _get_sprite_texture_path(_left_spine_visual),
		"spine_expected_path": SPINE_TEXTURE_PATH,
		"perch_texture_path": _get_sprite_texture_path(_perch_visual),
		"perch_expected_path": PERCH_TEXTURE_PATH,
		"endpoint_texture_path": _get_child_sprite_texture_path(
			_endpoint,
			"Visual"
		),
		"endpoint_expected_path": ENDPOINT_TEXTURE_PATH,
		"arc_texture_path": _get_sprite_texture_path(_arc_visual),
		"arc_expected_path": ARC_TEXTURE_PATH,
		"contact_spark_expected_path": CONTACT_SPARK_TEXTURE_PATH,
		"route_activation_x": ROUTE_ACTIVATION_X,
		"gap_start_x": GAP_START_X,
		"gap_end_x": GAP_END_X,
		"arc_x": ARC_X,
		"endpoint_x": ENDPOINT_X,
		"right_wall_x": RIGHT_WALL_X,
		"route_unlocked": _route_unlocked,
		"roost_id": String(ROOST_ID),
		"roost_scene_id": String(ROOST_SCENE_ID),
		"roost_spawn_point": String(ROOST_SPAWN_POINT),
		"hazard_id": String(HAZARD_ID),
		"hazard_damage": ARC_DAMAGE,
		"hazard_contact_cooldown_sec": ARC_CONTACT_COOLDOWN_SEC,
		"hazard_phase": String(_hazard_phase),
		"hazard_remaining_sec": _hazard_remaining_sec,
		"hazard_timing": {
			"grace_sec": GRACE_DURATION_SEC,
			"warning_sec": WARNING_DURATION_SEC,
			"active_sec": ACTIVE_DURATION_SEC,
			"safe_sec": SAFE_DURATION_SEC,
		},
		"roost_activated": _roost_activated,
		"activated": _activated,
		"traversed": _traversed,
		"endpoint_id": String(ENDPOINT_ID),
		"objective_text": get_objective_text(),
		"last_savepoint": _last_savepoint.duplicate(true),
		"autosave_request_count": _autosave_request_count,
		"audio_request_count": _audio_request_count,
		"roost_feedback_count": _roost_feedback_count,
		"fall_accept_count": _fall_accept_count,
		"endpoint_feedback_count": _endpoint_feedback_count,
		"contact_spark_spawn_count": _contact_spark_spawn_count,
		"last_autosave_context": _last_autosave_context.duplicate(true),
		"last_audio_event": _last_audio_event.duplicate(true),
		"roost_vfx": _get_roost_vfx_snapshot(),
	}


func _advance_hazard_phase() -> void:
	match _hazard_phase:
		&"grace":
			_set_hazard_phase(&"warning", WARNING_DURATION_SEC)
		&"warning":
			_set_hazard_phase(&"active", ACTIVE_DURATION_SEC)
		&"active":
			_set_hazard_phase(&"safe", SAFE_DURATION_SEC)
		&"safe":
			_set_hazard_phase(&"warning", WARNING_DURATION_SEC)
		_:
			_set_hazard_phase(&"grace", GRACE_DURATION_SEC)


func _set_hazard_phase(phase: StringName, duration_sec: float) -> void:
	_hazard_phase = phase
	_hazard_remaining_sec = maxf(0.0, duration_sec)
	_sync_hazard_visual()


func _sync_state() -> void:
	if _roost != null:
		_roost.visible = _route_unlocked
		_set_interaction_enabled(
			_roost,
			_route_unlocked and not _roost_activated
		)
	if _endpoint != null:
		_endpoint.visible = _route_unlocked
		_set_interaction_enabled(
			_endpoint,
			_route_unlocked and _activated and not _traversed
		)
	if _fall_zone != null:
		_set_area_monitoring(
			_fall_zone,
			_route_unlocked and _activated
		)
	if _arc_hazard != null:
		_set_area_monitoring(
			_arc_hazard,
			_route_unlocked and _activated and not _traversed
		)
	_sync_hazard_visual()
	_sync_prompt_visibility()
	_emit_objective_if_changed()


func _sync_hazard_visual() -> void:
	if _arc_visual == null:
		return
	_arc_visual.visible = _hazard_phase in [&"warning", &"active"]
	_arc_visual.modulate = (
		Color(1.0, 0.68, 0.24, 0.46)
		if _hazard_phase == &"warning"
		else Color(0.72, 0.96, 1.0, 1.0)
	)


func _sync_prompt_visibility() -> void:
	if _roost_prompt != null:
		_roost_prompt.text = (
			"Cooling Shaft Roost Online"
			if _roost_activated
			else "Activate Cooling Shaft Roost"
		)
		_roost_prompt.visible = (
			_route_unlocked and _is_provider_near(_roost, _player, 192.0)
		)
	if _endpoint_prompt != null:
		_endpoint_prompt.text = (
			"Cooling Shaft Secured"
			if _traversed
			else (
				"Secure Deep Lift"
				if _activated
				else "Activate Cooling Shaft Roost"
			)
		)
		_endpoint_prompt.visible = (
			_route_unlocked and _is_provider_near(_endpoint, _player, 192.0)
		)


func _connect_roost_signal() -> void:
	if _roost == null or not _roost.has_signal("savepoint_activated"):
		return
	var activated_signal: Signal = _roost.get("savepoint_activated")
	if not activated_signal.is_connected(_on_roost_activated):
		activated_signal.connect(_on_roost_activated)


func _connect_route_triggers() -> void:
	if _fall_zone != null and not _fall_zone.body_entered.is_connected(
		_on_fall_zone_body_entered
	):
		_fall_zone.body_entered.connect(_on_fall_zone_body_entered)
	if _arc_hazard != null and not _arc_hazard.body_entered.is_connected(
		_on_arc_hazard_body_entered
	):
		_arc_hazard.body_entered.connect(_on_arc_hazard_body_entered)
	if _endpoint == null:
		return
	var endpoint_area: Area2D = (
		_endpoint.get_node_or_null("InteractionArea") as Area2D
	)
	if endpoint_area != null and not endpoint_area.body_entered.is_connected(
		_on_endpoint_body_entered
	):
		endpoint_area.body_entered.connect(_on_endpoint_body_entered)


func _on_fall_zone_body_entered(body: Node2D) -> void:
	if body == _player:
		apply_fall(body)


func _on_arc_hazard_body_entered(body: Node2D) -> void:
	if body == _player:
		apply_arc_contact(body)


func _on_endpoint_body_entered(body: Node2D) -> void:
	if body == _player:
		try_activate_endpoint(body)


func _on_roost_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	if (
		not _route_unlocked
		or _roost_activated
		or savepoint_id != ROOST_ID
		or scene_id != ROOST_SCENE_ID
		or spawn_point != ROOST_SPAWN_POINT
	):
		return
	_roost_activated = true
	_roost_feedback_count += 1
	_last_savepoint = context.duplicate(true)
	var respawn_position: Vector2 = (
		_roost_spawn.global_position if _roost_spawn != null else world_position
	)
	_last_savepoint["id"] = String(savepoint_id)
	_last_savepoint["savepoint_id"] = String(savepoint_id)
	_last_savepoint["scene_id"] = String(scene_id)
	_last_savepoint["spawn_point"] = String(spawn_point)
	_last_savepoint["position"] = {
		"x": respawn_position.x,
		"y": respawn_position.y,
	}
	if _player != null and _player.has_method("restore_at_savepoint"):
		_player.call("restore_at_savepoint")
	_request_savepoint_audio(world_position, context)
	_trigger_savepoint_autosave(context)
	_sync_state()
	_persist_owner_state()


func _trigger_savepoint_autosave(context: Dictionary) -> void:
	if _save_trigger_adapter == null or not is_instance_valid(
		_save_trigger_adapter
	):
		return
	var save_context: Dictionary = context.duplicate(true)
	save_context["savepoint_id"] = String(ROOST_ID)
	save_context["scene_id"] = String(ROOST_SCENE_ID)
	save_context["spawn_point"] = String(ROOST_SPAWN_POINT)
	if not _save_trigger_adapter.trigger_auto_save(&"savepoint", save_context):
		return
	_autosave_request_count += 1
	_last_autosave_context = save_context


func _request_savepoint_audio(
	world_position: Vector2,
	context: Dictionary
) -> void:
	var metadata: Dictionary = context.duplicate(true)
	metadata["feedback_role"] = &"savepoint_activation"
	metadata["source"] = ROOST_ID
	metadata["world_position"] = world_position
	_audio_request_count += 1
	_last_audio_event = {
		"event_id": &"savepoint_activated",
		"sfx_id": &"sfx_door_unlock",
		"position": world_position,
		"priority": 90,
		"metadata": metadata.duplicate(true),
	}
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null or not audio_system.has_method(
		"on_savepoint_activated"
	):
		return
	audio_system.call(
		"on_savepoint_activated",
		ROOST_ID,
		ROOST_SCENE_ID,
		ROOST_SPAWN_POINT,
		world_position,
		metadata
	)


func _persist_owner_state() -> void:
	if (
		_scene_owner != null
		and _scene_owner.has_method("persist_central_tower_threshold_progress")
	):
		_scene_owner.call("persist_central_tower_threshold_progress")


func _emit_objective_if_changed() -> void:
	var objective_text: String = get_objective_text()
	if objective_text == _last_emitted_objective_text:
		return
	_last_emitted_objective_text = objective_text
	objective_changed.emit(objective_text)


func _build_roost_snapshot() -> Dictionary:
	var spawn_position: Vector2 = (
		_roost_spawn.global_position
		if _roost_spawn != null
		else (_roost.global_position if _roost != null else Vector2.ZERO)
	)
	return {
		"id": String(ROOST_ID),
		"savepoint_id": String(ROOST_ID),
		"scene_id": String(ROOST_SCENE_ID),
		"spawn_point": String(ROOST_SPAWN_POINT),
		"display_name": "Cooling Shaft Roost",
		"position": {
			"x": spawn_position.x,
			"y": spawn_position.y,
		},
	}


func _get_roost_vfx_snapshot() -> Dictionary:
	if _roost != null and _roost.has_method("get_activation_vfx_snapshot"):
		return Dictionary(_roost.call(
			"get_activation_vfx_snapshot"
		)).duplicate(true)
	return {}


func _spawn_contact_spark(world_position: Vector2) -> void:
	_clear_contact_spark()
	_contact_spark = Sprite2D.new()
	_contact_spark.name = "CoolingArcContactSpark"
	_contact_spark.texture = CONTACT_SPARK_TEXTURE
	_contact_spark.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_contact_spark.global_position = world_position
	_contact_spark.z_index = 28
	_contact_spark.set_meta(&"asset_source", "image_generation")
	_contact_spark.set_meta(&"vfx_role", "cooling_arc_contact")
	add_child(_contact_spark)
	_contact_spark_elapsed_sec = 0.0
	_contact_spark_spawn_count += 1


func _advance_contact_spark(delta_sec: float) -> void:
	if _contact_spark == null or not is_instance_valid(_contact_spark):
		return
	_contact_spark_elapsed_sec += delta_sec
	var progress: float = clampf(_contact_spark_elapsed_sec / 0.24, 0.0, 1.0)
	_contact_spark.modulate.a = 1.0 - progress
	_contact_spark.scale = Vector2.ONE * (0.72 + (0.18 * progress))
	if progress >= 1.0:
		_clear_contact_spark()


func _clear_contact_spark() -> void:
	if _contact_spark != null and is_instance_valid(_contact_spark):
		if _contact_spark.get_parent() == self:
			remove_child(_contact_spark)
		_contact_spark.free()
	_contact_spark = null
	_contact_spark_elapsed_sec = 0.0


func _set_interaction_enabled(owner: Node, enabled: bool) -> void:
	if owner == null:
		return
	var area: Area2D = owner.get_node_or_null("InteractionArea") as Area2D
	if area != null:
		_set_area_monitoring(area, enabled)
	var shape: CollisionShape2D = owner.get_node_or_null(
		"InteractionArea/CollisionShape2D"
	) as CollisionShape2D
	if shape != null:
		shape.set_deferred("disabled", not enabled)


func _set_area_monitoring(area: Area2D, enabled: bool) -> void:
	if area == null:
		return
	area.set_deferred("monitoring", enabled)
	area.set_deferred("monitorable", enabled)


func _is_provider_near(
	target: Node2D,
	provider: Node,
	radius_px: float
) -> bool:
	return (
		target != null
		and provider != null
		and provider is Node2D
		and target.global_position.distance_to(
			(provider as Node2D).global_position
		) <= radius_px
	)


func _get_child_sprite_texture_path(owner: Node, path: String) -> String:
	if owner == null:
		return ""
	return _get_sprite_texture_path(owner.get_node_or_null(path) as Sprite2D)


func _get_sprite_texture_path(sprite: Sprite2D) -> String:
	return (
		sprite.texture.resource_path
		if sprite != null and sprite.texture != null
		else ""
	)
