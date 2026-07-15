## Owns Story144's Apex Roost, purge chase, lethal fall, and upper endpoint.
class_name CentralTowerApexPurgeController
extends Node2D

signal objective_changed(objective_text: String)

const ROUTE_WIDTH_PX: int = 6400
const TRIGGER_X: float = 5360.0
const PURGE_START: Vector2 = Vector2(5200.0, 360.0)
const PURGE_END_X: float = 6520.0
const ENDPOINT_POSITION: Vector2 = Vector2(6280.0, 296.0)
const ROOST_ID: StringName = &"central_tower_apex_roost"
const ROOST_SCENE_ID: StringName = &"area_05_central_tower"
const ROOST_SPAWN_POINT: StringName = &"apex_roost"
const HAZARD_ID: StringName = &"central_tower_apex_purge_wall"
const ENDPOINT_ID: StringName = &"central_tower_apex_approach_endpoint"
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_apex_conduit_1280x720.png"
)
const ROOST_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_apex_roost_256x256.png"
)
const SPINE_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_apex_magnetic_spine_256x512.png"
)
const EMITTER_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_apex_purge_emitter_256x384.png"
)
const BEACON_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_apex_beacon_256x384.png"
)
const PURGE_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "vfx_central_tower_apex_purge_wall_192x640.png"
)
const SAVE_TRIGGER_ADAPTER_SCRIPT: Script = preload(
	"res://src/feature/save_trigger_adapter.gd"
)
const PHASE_IDLE: StringName = &"idle"
const PHASE_WARNING: StringName = &"warning"
const PHASE_PURSUIT: StringName = &"pursuit"
const PHASE_COMPLETE: StringName = &"complete"

@export var warning_delay_sec: float = 0.75
@export var purge_speed_px_sec: float = 150.0

@onready var _background: Sprite2D = (
	get_node_or_null("../ApexConduitBackground") as Sprite2D
)
@onready var _roost: Node2D = get_node_or_null("ApexRoost") as Node2D
@onready var _roost_spawn: Marker2D = (
	get_node_or_null("ApexRoostSpawn") as Marker2D
)
@onready var _trigger: Area2D = get_node_or_null("PurgeTrigger") as Area2D
@onready var _emitter: Sprite2D = get_node_or_null("PurgeEmitter") as Sprite2D
@onready var _purge_wall: Area2D = get_node_or_null("PurgeWall") as Area2D
@onready var _purge_visual: Sprite2D = (
	get_node_or_null("PurgeWall/Visual") as Sprite2D
)
@onready var _fall_zone: Area2D = get_node_or_null("ApexFallZone") as Area2D
@onready var _endpoint: Node2D = get_node_or_null("ApexEndpoint") as Node2D
@onready var _roost_prompt: Label = (
	get_node_or_null("ApexRoost/PromptLabel") as Label
)
@onready var _endpoint_prompt: Label = (
	get_node_or_null("ApexEndpoint/PromptLabel") as Label
)
@onready var _spine_visual: Sprite2D = (
	get_node_or_null("../ApexMagneticSpine/Visual") as Sprite2D
)

var _route_unlocked: bool = false
var _roost_activated: bool = false
var _attempt_triggered: bool = false
var _approach_secured: bool = false
var _phase: StringName = PHASE_IDLE
var _phase_remaining_sec: float = 0.0
var _player: Node2D = null
var _scene_owner: Object = null
var _save_trigger_adapter: SaveTriggerAdapter = null
var _last_savepoint: Dictionary = {}
var _roost_feedback_count: int = 0
var _trigger_feedback_count: int = 0
var _endpoint_feedback_count: int = 0
var _purge_contact_count: int = 0
var _fall_accept_count: int = 0
var _autosave_request_count: int = 0
var _audio_request_count: int = 0
var _vfx_request_count: int = 0
var _last_autosave_context: Dictionary = {}
var _last_audio_event: Dictionary = {}
var _last_emitted_objective_text: String = ""


func _ready() -> void:
	_connect_roost_signal()
	_connect_route_triggers()
	_reset_attempt_runtime()
	_sync_state()


func _process(delta: float) -> void:
	if (
		_route_unlocked
		and _roost_activated
		and not _attempt_triggered
		and not _approach_secured
		and _player != null
		and _player.global_position.x >= TRIGGER_X
	):
		try_trigger(_player)
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
		_save_trigger_adapter.name = "CentralTowerApexSaveTriggerAdapter"
		add_child(_save_trigger_adapter)
	var snapshot_provider := Callable()
	if _scene_owner != null and _scene_owner.has_method("capture_save_snapshot"):
		snapshot_provider = Callable(_scene_owner, "capture_save_snapshot")
	_save_trigger_adapter.configure(save_system, snapshot_provider)
	return true


## Story143's durable Deep Lift completion is the only prerequisite.
func set_route_unlocked(unlocked: bool) -> void:
	_route_unlocked = unlocked
	if not _route_unlocked and not _approach_secured:
		_reset_attempt_runtime()
	_sync_state()


## Attempts the nearby one-shot Apex Roost activation.
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


## Starts the current purge attempt after the player crosses the authored line.
func try_trigger(provider: Node = null) -> bool:
	if (
		not _route_unlocked
		or not _roost_activated
		or _attempt_triggered
		or _approach_secured
	):
		return false
	var trigger_provider: Node = _player if provider == null else provider
	if (
		trigger_provider == null
		or trigger_provider != _player
		or not trigger_provider is Node2D
		or (trigger_provider as Node2D).global_position.x < TRIGGER_X
	):
		return false
	_attempt_triggered = true
	_phase = PHASE_WARNING
	_phase_remaining_sec = maxf(0.01, warning_delay_sec)
	_trigger_feedback_count += 1
	_vfx_request_count += 1
	_request_purge_audio(&"purge_warning", &"sfx_parry_good")
	_sync_state()
	return true


## Advances warning timing and deterministic left-to-right purge motion.
func advance_time(delta_sec: float) -> void:
	if not _attempt_triggered or _approach_secured:
		return
	var remaining: float = maxf(0.0, delta_sec)
	if remaining <= 0.0:
		return
	if _phase == PHASE_WARNING:
		var consumed: float = minf(_phase_remaining_sec, remaining)
		_phase_remaining_sec -= consumed
		remaining -= consumed
		if _phase_remaining_sec <= 0.0:
			_phase = PHASE_PURSUIT
			_phase_remaining_sec = 0.0
			_sync_state()
	if _phase == PHASE_PURSUIT and remaining > 0.0 and _purge_wall != null:
		_purge_wall.position.x = minf(
			PURGE_END_X,
			_purge_wall.position.x + (maxf(1.0, purge_speed_px_sec) * remaining)
		)
	_sync_purge_visual()


## Applies lethal purge contact through the real player damage API.
func apply_purge_contact(target: Node = null) -> bool:
	var contact_target: Node = _player if target == null else target
	if (
		_phase != PHASE_PURSUIT
		or _approach_secured
		or contact_target == null
		or contact_target != _player
		or not contact_target.has_method("apply_damage")
		or not contact_target.has_method("get_current_hp")
		or int(contact_target.call("get_current_hp")) <= 0
	):
		return false
	var lethal_damage: int = (
		int(contact_target.call("get_max_hp"))
		if contact_target.has_method("get_max_hp")
		else int(contact_target.call("get_current_hp"))
	)
	contact_target.call("apply_damage", lethal_damage, {
		"source": HAZARD_ID,
		"damage_type": &"electric",
		"scene_id": ROOST_SCENE_ID,
	})
	if int(contact_target.call("get_current_hp")) > 0:
		return false
	_purge_contact_count += 1
	_vfx_request_count += 1
	return true


## Keeps the fifth viewport lethal after Roost activation to prevent softlocks.
func apply_fall(target: Node = null) -> bool:
	var fall_target: Node = _player if target == null else target
	if (
		not _route_unlocked
		or not _roost_activated
		or _approach_secured
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
		"source": &"central_tower_apex_fall",
		"damage_type": &"fall",
		"scene_id": ROOST_SCENE_ID,
	})
	if int(fall_target.call("get_current_hp")) > 0:
		return false
	_fall_accept_count += 1
	return true


## Secures the bounded approach after the current purge attempt has started.
func try_activate_endpoint(provider: Node = null) -> bool:
	if (
		not _route_unlocked
		or not _roost_activated
		or not _attempt_triggered
		or _approach_secured
	):
		return false
	var activation_provider: Node = _player if provider == null else provider
	if not _is_provider_near(_endpoint, activation_provider, 112.0):
		return false
	_approach_secured = true
	_phase = PHASE_COMPLETE
	_phase_remaining_sec = 0.0
	_endpoint_feedback_count += 1
	_vfx_request_count += 1
	_request_purge_audio(&"approach_secured", &"sfx_door_unlock")
	_sync_state()
	_persist_owner_state()
	return true


## Resets only attempt-local purge state while preserving durable outcomes.
func reset_failed_attempt() -> bool:
	if not _approach_secured:
		_reset_attempt_runtime()
	_sync_state()
	return true


func get_last_discovered_savepoint() -> Dictionary:
	return _last_savepoint.duplicate(true)


## Captures only durable Story144 state.
func get_local_state() -> Dictionary:
	return {
		"central_tower_apex_roost_activated": _roost_activated,
		"central_tower_apex_last_savepoint": _last_savepoint.duplicate(true),
		"central_tower_apex_approach_secured": _approach_secured,
	}


## Restores durable state without replaying autosave, audio, VFX, or feedback.
func set_local_state(state: Dictionary) -> void:
	_roost_activated = bool(state.get(
		"central_tower_apex_roost_activated",
		false
	))
	_approach_secured = bool(state.get(
		"central_tower_apex_approach_secured",
		false
	))
	if _approach_secured:
		_roost_activated = true
	_last_savepoint = Dictionary(state.get(
		"central_tower_apex_last_savepoint",
		{}
	)).duplicate(true)
	if _roost_activated and _last_savepoint.is_empty():
		_last_savepoint = _build_roost_snapshot()
	_roost_feedback_count = 0
	_trigger_feedback_count = 0
	_endpoint_feedback_count = 0
	_purge_contact_count = 0
	_fall_accept_count = 0
	_autosave_request_count = 0
	_audio_request_count = 0
	_vfx_request_count = 0
	_last_autosave_context.clear()
	_last_audio_event.clear()
	_reset_attempt_runtime()
	if _approach_secured:
		_phase = PHASE_COMPLETE
	_sync_state()


## Aligns the player to the authored Apex Roost marker.
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
	if _roost_activated or _attempt_triggered or _approach_secured:
		return true
	var objective_provider: Node = _player if provider == null else provider
	return (
		objective_provider is Node2D
		and (objective_provider as Node2D).global_position.x >= 5120.0
	)


func get_objective_text() -> String:
	if _approach_secured:
		return "Apex Approach Secured"
	if _attempt_triggered:
		return "Outrun Purge Wall"
	if _roost_activated:
		return "Cross Apex Conduit"
	return "Activate Apex Roost"


## Returns authored assets, geometry, savepoint, and purge diagnostics.
func get_diagnostics() -> Dictionary:
	return {
		"route_width_px": ROUTE_WIDTH_PX,
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"background_texture_path": _get_sprite_texture_path(_background),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"roost_texture_path": _get_child_sprite_texture_path(_roost, "Visual"),
		"roost_expected_path": ROOST_TEXTURE_PATH,
		"spine_texture_path": _get_sprite_texture_path(_spine_visual),
		"spine_expected_path": SPINE_TEXTURE_PATH,
		"emitter_texture_path": _get_sprite_texture_path(_emitter),
		"emitter_expected_path": EMITTER_TEXTURE_PATH,
		"beacon_texture_path": _get_child_sprite_texture_path(_endpoint, "Visual"),
		"beacon_expected_path": BEACON_TEXTURE_PATH,
		"purge_texture_path": _get_sprite_texture_path(_purge_visual),
		"purge_expected_path": PURGE_TEXTURE_PATH,
		"route_unlocked": _route_unlocked,
		"roost_id": String(ROOST_ID),
		"roost_spawn_point": String(ROOST_SPAWN_POINT),
		"roost_spawn_position": (
			_roost_spawn.global_position if _roost_spawn != null else Vector2.ZERO
		),
		"trigger_x": TRIGGER_X,
		"hazard_id": String(HAZARD_ID),
		"warning_delay_sec": warning_delay_sec,
		"purge_speed_px_sec": purge_speed_px_sec,
		"purge_start": PURGE_START,
		"purge_position": (
			_purge_wall.position if _purge_wall != null else Vector2.ZERO
		),
		"phase": String(_phase),
		"phase_remaining_sec": _phase_remaining_sec,
		"purge_active": _phase == PHASE_PURSUIT and not _approach_secured,
		"attempt_triggered": _attempt_triggered,
		"roost_activated": _roost_activated,
		"approach_secured": _approach_secured,
		"endpoint_id": String(ENDPOINT_ID),
		"endpoint_position": ENDPOINT_POSITION,
		"objective_text": get_objective_text(),
		"last_savepoint": _last_savepoint.duplicate(true),
		"roost_feedback_count": _roost_feedback_count,
		"trigger_feedback_count": _trigger_feedback_count,
		"endpoint_feedback_count": _endpoint_feedback_count,
		"purge_contact_count": _purge_contact_count,
		"fall_accept_count": _fall_accept_count,
		"autosave_request_count": _autosave_request_count,
		"audio_request_count": _audio_request_count,
		"vfx_request_count": _vfx_request_count,
		"last_autosave_context": _last_autosave_context.duplicate(true),
		"last_audio_event": _last_audio_event.duplicate(true),
		"roost_vfx": _get_roost_vfx_snapshot(),
	}


func _reset_attempt_runtime() -> void:
	_attempt_triggered = false
	_phase = PHASE_IDLE
	_phase_remaining_sec = 0.0
	_purge_contact_count = 0
	if _purge_wall != null:
		_purge_wall.position = PURGE_START


func _sync_state() -> void:
	if _roost != null:
		_roost.visible = _route_unlocked
		_set_interaction_enabled(
			_roost,
			_route_unlocked and not _roost_activated
		)
	if _emitter != null:
		_emitter.visible = _route_unlocked
	if _trigger != null:
		_set_area_monitoring(
			_trigger,
			_route_unlocked
			and _roost_activated
			and not _attempt_triggered
			and not _approach_secured
		)
	if _fall_zone != null:
		_set_area_monitoring(
			_fall_zone,
			_route_unlocked and _roost_activated and not _approach_secured
		)
	if _purge_wall != null:
		_set_area_monitoring(
			_purge_wall,
			_phase == PHASE_PURSUIT and not _approach_secured
		)
	if _endpoint != null:
		_endpoint.visible = _route_unlocked
		_set_interaction_enabled(
			_endpoint,
			_route_unlocked and _attempt_triggered and not _approach_secured
		)
	_sync_purge_visual()
	_sync_prompt_visibility()
	_emit_objective_if_changed()


func _sync_purge_visual() -> void:
	if _purge_visual == null:
		return
	_purge_visual.visible = (
		_attempt_triggered and not _approach_secured
	)
	_purge_visual.modulate = (
		Color(1.0, 0.58, 0.24, 0.55)
		if _phase == PHASE_WARNING
		else Color(1.0, 1.0, 1.0, 0.94)
	)


func _sync_prompt_visibility() -> void:
	if _roost_prompt != null:
		_roost_prompt.text = (
			"Apex Roost Online"
			if _roost_activated
			else "Activate Apex Roost"
		)
		_roost_prompt.visible = (
			_route_unlocked and _is_provider_near(_roost, _player, 192.0)
		)
	if _endpoint_prompt != null:
		_endpoint_prompt.text = (
			"Apex Approach Secured"
			if _approach_secured
			else (
				"Secure Apex Approach"
				if _attempt_triggered
				else "Outrun Purge Wall"
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
	if _trigger != null and not _trigger.body_entered.is_connected(
		_on_trigger_body_entered
	):
		_trigger.body_entered.connect(_on_trigger_body_entered)
	if _purge_wall != null and not _purge_wall.body_entered.is_connected(
		_on_purge_wall_body_entered
	):
		_purge_wall.body_entered.connect(_on_purge_wall_body_entered)
	if _fall_zone != null and not _fall_zone.body_entered.is_connected(
		_on_fall_zone_body_entered
	):
		_fall_zone.body_entered.connect(_on_fall_zone_body_entered)


func _on_trigger_body_entered(body: Node2D) -> void:
	if body == _player:
		try_trigger(body)


func _on_purge_wall_body_entered(body: Node2D) -> void:
	if body == _player:
		apply_purge_contact(body)


func _on_fall_zone_body_entered(body: Node2D) -> void:
	if body == _player:
		apply_fall(body)


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
	_vfx_request_count += 1
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
		"metadata": metadata.duplicate(true),
	}
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("on_savepoint_activated"):
		audio_system.call(
			"on_savepoint_activated",
			ROOST_ID,
			ROOST_SCENE_ID,
			ROOST_SPAWN_POINT,
			world_position,
			metadata
		)


func _request_purge_audio(event_id: StringName, sfx_id: StringName) -> void:
	_audio_request_count += 1
	var audio_position: Vector2 = (
		_purge_wall.global_position if _purge_wall != null else PURGE_START
	)
	_last_audio_event = {
		"event_id": event_id,
		"sfx_id": sfx_id,
		"position": audio_position,
	}
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("play_sfx"):
		audio_system.call("play_sfx", sfx_id, audio_position, 0.0, 0.0, 90)


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
		"display_name": "Apex Roost",
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


func _set_interaction_enabled(interaction_owner: Node, enabled: bool) -> void:
	if interaction_owner == null:
		return
	var area: Area2D = interaction_owner.get_node_or_null(
		"InteractionArea"
	) as Area2D
	if area != null:
		_set_area_monitoring(area, enabled)
	var shape: CollisionShape2D = interaction_owner.get_node_or_null(
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


func _get_child_sprite_texture_path(sprite_owner: Node, path: String) -> String:
	if sprite_owner == null:
		return ""
	return _get_sprite_texture_path(
		sprite_owner.get_node_or_null(path) as Sprite2D
	)


func _get_sprite_texture_path(sprite: Sprite2D) -> String:
	return (
		sprite.texture.resource_path
		if sprite != null and sprite.texture != null
		else ""
	)
