## Owns Story140's bounded Threshold Guard encounter and seal state.
class_name CentralTowerThresholdGuardController
extends Node2D

signal objective_changed(objective_text: String)

const ACTIVATION_X: float = 420.0
const REAR_SEAL_X: float = 300.0
const INNER_SEAL_X: float = 1120.0
const GUARD_ENTITY_ID: int = 2701
const ENCOUNTER_ID: StringName = &"central_tower_threshold_guard_encounter"
const GUARD_SUMMON_ID: StringName = &"central_tower_threshold_guard"
const GUARD_FAMILY_ID: StringName = &"central_tower_threshold_guard"
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/central_tower_threshold_guard/"
	+ "central_tower_threshold_guard_sprite_frames.tres"
)
const SEAL_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_inner_seal_384x512.png"
)
const GUARD_DOCK_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_guard_dock_256x256.png"
)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

@onready var _rear_seal: StaticBody2D = get_node_or_null("RearSeal") as StaticBody2D
@onready var _inner_seal: StaticBody2D = get_node_or_null("InnerSeal") as StaticBody2D
@onready var _guard: CharacterBody2D = (
	get_node_or_null("CentralTowerThresholdGuard") as CharacterBody2D
)
@onready var _guard_dock: Sprite2D = get_node_or_null("GuardDock") as Sprite2D

var _activated: bool = false
var _defeated: bool = false
var _death_animation_pending: bool = false
var _player: Node2D = null
var _scene_owner: Object = null
var _activation_feedback_count: int = 0
var _defeat_feedback_count: int = 0
var _last_emitted_objective_text: String = ""
var _guard_start_position: Vector2 = Vector2.ZERO
var _guard_start_position_captured: bool = false


func _ready() -> void:
	_capture_guard_start_position()
	_connect_guard_signal()
	_sync_state()


func _process(_delta: float) -> void:
	if _player != null and not _activated and not _defeated:
		try_activate(_player)


## Injects the player and owning room adapters.
func configure_runtime(player: Node2D, scene_owner: Object) -> bool:
	_player = player
	_scene_owner = scene_owner
	_capture_guard_start_position()
	_configure_guard()
	_connect_guard_signal()
	_sync_state()
	return _player != null and _scene_owner != null


## Activates one attempt after the player crosses the safe threshold.
func try_activate(provider: Node = null) -> bool:
	if _activated or _defeated or not _is_live_guard():
		return false
	var activation_provider: Node = _player if provider == null else provider
	if (
		activation_provider == null
		or not activation_provider is Node2D
		or (activation_provider as Node2D).global_position.x < ACTIVATION_X
	):
		return false
	_activated = true
	_activation_feedback_count += 1
	_sync_state()
	_persist_owner_state()
	return true


func handles_target_id(target_id: int) -> bool:
	return target_id == GUARD_ENTITY_ID


## Routes player hit-confirm damage to the live guard HealthComponent.
func apply_damage(
	target_id: int,
	final_damage: int,
	metadata: Dictionary = {}
) -> bool:
	if (
		target_id != GUARD_ENTITY_ID
		or final_damage <= 0
		or not _activated
		or _defeated
		or _guard == null
		or not is_instance_valid(_guard)
		or not _guard.has_method("apply_damage")
	):
		return false
	_guard.call("apply_damage", final_damage, metadata)
	if (
		is_instance_valid(_guard)
		and _guard.has_method("get_current_hp")
		and int(_guard.call("get_current_hp")) <= 0
		and not _defeated
	):
		_on_guard_defeated()
	return true


## Supplies the guard's configured damage through its CombatComponent.
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
	var damage: int = _call_guard_int("get_attack_damage", 14)
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
		"damage_category": &"latch_thrust",
	}


func request_guard_attack() -> bool:
	return (
		_activated
		and not _defeated
		and _guard != null
		and is_instance_valid(_guard)
		and _guard.has_method("request_attack")
		and bool(_guard.call("request_attack"))
	)


## Resets only the failed live attempt; durable clear is never rolled back.
func reset_failed_attempt() -> bool:
	if _defeated:
		return false
	_activated = false
	_death_animation_pending = false
	if not _is_live_guard():
		_sync_state()
		_persist_owner_state()
		return false
	if _guard_start_position_captured:
		_guard.position = _guard_start_position
	if _guard.has_method("reset_for_encounter"):
		_guard.call("reset_for_encounter")
	_sync_state()
	_persist_owner_state()
	return true


func get_local_state() -> Dictionary:
	return {
		"central_tower_threshold_guard_activated": _activated,
		"central_tower_threshold_guard_defeated": _defeated,
	}


func set_local_state(state: Dictionary) -> void:
	_death_animation_pending = false
	_defeated = bool(state.get(
		"central_tower_threshold_guard_defeated",
		false
	))
	_activated = bool(state.get(
		"central_tower_threshold_guard_activated",
		_defeated
	)) or _defeated
	_activation_feedback_count = 0
	_defeat_feedback_count = 0
	_sync_state()


func get_objective_text() -> String:
	if _defeated:
		return "Central Tower Threshold Secured"
	if _activated:
		return "Break the Threshold Guard"
	return "Cross the Tower Threshold"


func get_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = _get_guard_sprite()
	var frames: SpriteFrames = sprite.sprite_frames if sprite != null else null
	var attack_metadata: Dictionary = {}
	var config_diagnostics: Dictionary = {}
	if _is_live_guard() and _guard.has_method("get_current_enemy_attack_metadata"):
		attack_metadata = Dictionary(_guard.call(
			"get_current_enemy_attack_metadata"
		)).duplicate(true)
	if _is_live_guard() and _guard.has_method("get_config_diagnostics"):
		config_diagnostics = Dictionary(_guard.call(
			"get_config_diagnostics"
		)).duplicate(true)
	return {
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"activation_x": ACTIVATION_X,
		"rear_seal_x": _node_x(_rear_seal, REAR_SEAL_X),
		"inner_seal_x": _node_x(_inner_seal, INNER_SEAL_X),
		"rear_seal_texture_path": _child_texture_path(_rear_seal, "Visual"),
		"inner_seal_texture_path": _child_texture_path(_inner_seal, "Visual"),
		"seal_expected_path": SEAL_TEXTURE_PATH,
		"guard_dock_texture_path": _texture_path(_guard_dock),
		"guard_dock_expected_path": GUARD_DOCK_TEXTURE_PATH,
		"encounter_state": String(_encounter_state()),
		"guard_activated": _activated,
		"guard_defeated": _defeated,
		"guard_entity_id": GUARD_ENTITY_ID,
		"guard_family_id": _guard_family_id(),
		"guard_current_hp": _guard_hp(false),
		"guard_max_hp": _guard_hp(true),
		"guard_position": _guard.position if _is_live_guard() else Vector2.ZERO,
		"guard_start_position": _guard_start_position,
		"guard_visible": _guard_visible(),
		"guard_has_target": _guard_has_target(),
		"guard_animation": String(sprite.animation) if sprite != null else "",
		"sprite_frames_path": frames.resource_path if frames != null else "",
		"sprite_frames_expected_path": SPRITE_FRAMES_PATH,
		"animation_frames": _animation_frame_counts(frames),
		"attack_startup_frames": _call_guard_int("get_attack_startup_frames", 0),
		"attack_active_frames": _call_guard_int("get_attack_active_frames", 0),
		"attack_recovery_frames": _call_guard_int("get_attack_recovery_frames", 0),
		"attack_damage": _call_guard_int("get_attack_damage", 0),
		"attack_active": (
			bool(_guard.call("is_enemy_attack_active"))
			if _is_live_guard() and _guard.has_method("is_enemy_attack_active")
			else false
		),
		"attack_metadata": attack_metadata,
		"config_diagnostics": config_diagnostics,
		"rear_seal_blocking": _seal_blocking(_rear_seal),
		"inner_seal_blocking": _seal_blocking(_inner_seal),
		"activation_feedback_count": _activation_feedback_count,
		"defeat_feedback_count": _defeat_feedback_count,
		"objective_text": get_objective_text(),
	}


func _configure_guard() -> void:
	if not _is_live_guard():
		return
	if _guard.has_method("configure_summon"):
		_guard.call(
			"configure_summon",
			ENCOUNTER_ID,
			GUARD_ENTITY_ID,
			GUARD_SUMMON_ID
		)
	if _guard.has_method("set_damage_calculator_adapter"):
		_guard.call("set_damage_calculator_adapter", self)


func _capture_guard_start_position() -> void:
	if _guard_start_position_captured or not _is_live_guard():
		return
	_guard_start_position = (
		_guard_dock.position if _guard_dock != null else _guard.position
	)
	_guard_start_position_captured = true


func _connect_guard_signal() -> void:
	if not _is_live_guard() or not _guard.has_signal("enemy_defeated"):
		return
	var defeated_signal: Signal = _guard.get("enemy_defeated")
	if not defeated_signal.is_connected(_on_guard_defeated):
		defeated_signal.connect(_on_guard_defeated)


func _on_guard_defeated() -> void:
	if _defeated:
		return
	_activated = true
	_defeated = true
	_death_animation_pending = true
	_defeat_feedback_count += 1
	_sync_state()
	_persist_owner_state()


func _sync_state() -> void:
	if _defeated and _death_animation_pending:
		_hold_guard_death_animation()
	else:
		_set_guard_active(_activated and not _defeated)
	var encounter_blocking: bool = _activated and not _defeated
	_set_seal_blocking(_rear_seal, encounter_blocking)
	_set_seal_blocking(_inner_seal, encounter_blocking)
	_emit_objective_if_changed()


func _hold_guard_death_animation() -> void:
	if not _is_live_guard():
		return
	if _guard.has_method("set_attack_target"):
		_guard.call("set_attack_target", null)
	_guard.visible = true
	_guard.process_mode = Node.PROCESS_MODE_INHERIT
	_guard.set_physics_process(false)
	_guard.collision_layer = 0
	_guard.collision_mask = 0


func _set_guard_active(active: bool) -> void:
	if not _is_live_guard():
		return
	var was_active: bool = (
		_guard.visible and _guard.process_mode != Node.PROCESS_MODE_DISABLED
	)
	if active:
		_guard.visible = true
		_guard.process_mode = Node.PROCESS_MODE_INHERIT
		_guard.set_physics_process(true)
		_guard.collision_layer = 2
		_guard.collision_mask = 17
		if _guard.has_method("set_attack_target"):
			_guard.call("set_attack_target", _player)
		if not was_active and _guard.has_method("begin_pacing"):
			_guard.call("begin_pacing", 24)
		return
	if _guard.has_method("set_attack_target"):
		_guard.call("set_attack_target", null)
	_guard.set_physics_process(false)
	_guard.process_mode = Node.PROCESS_MODE_DISABLED
	_guard.collision_layer = 0
	_guard.collision_mask = 0
	_guard.visible = false


func _set_seal_blocking(seal: StaticBody2D, blocking: bool) -> void:
	if seal == null:
		return
	seal.visible = blocking
	seal.collision_layer = 16 if blocking else 0
	seal.collision_mask = 0
	var shape: CollisionShape2D = seal.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	if shape != null:
		shape.set_deferred("disabled", not blocking)


func _emit_objective_if_changed() -> void:
	var objective_text: String = get_objective_text()
	if objective_text == _last_emitted_objective_text:
		return
	_last_emitted_objective_text = objective_text
	objective_changed.emit(objective_text)


func _persist_owner_state() -> void:
	if (
		_scene_owner != null
		and is_instance_valid(_scene_owner)
		and _scene_owner.has_method("persist_central_tower_threshold_progress")
	):
		_scene_owner.call("persist_central_tower_threshold_progress")


func _encounter_state() -> StringName:
	if _defeated:
		return &"cleared"
	if _activated:
		return &"active"
	return &"ready"


func _get_guard_sprite() -> AnimatedSprite2D:
	return (
		_guard.get_node_or_null("Sprite") as AnimatedSprite2D
		if _is_live_guard()
		else null
	)


func _guard_family_id() -> String:
	if _is_live_guard() and _guard.has_method("get_enemy_family_id"):
		return String(_guard.call("get_enemy_family_id"))
	return String(GUARD_FAMILY_ID)


func _guard_hp(maximum: bool) -> int:
	var method_name: StringName = &"get_max_hp" if maximum else &"get_current_hp"
	return _call_guard_int(method_name, 48 if maximum else 0)


func _call_guard_int(method_name: StringName, fallback: int) -> int:
	if not _is_live_guard() or not _guard.has_method(method_name):
		return fallback
	return int(_guard.call(method_name))


func _guard_visible() -> bool:
	return _is_live_guard() and _guard.visible


func _guard_has_target() -> bool:
	return (
		_is_live_guard()
		and _guard.has_method("has_attack_target")
		and bool(_guard.call("has_attack_target"))
	)


func _seal_blocking(seal: StaticBody2D) -> bool:
	if seal == null:
		return false
	var shape: CollisionShape2D = seal.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	return seal.visible and seal.collision_layer != 0 and shape != null and not shape.disabled


func _animation_frame_counts(frames: SpriteFrames) -> Dictionary:
	var counts: Dictionary = {}
	if frames == null:
		return counts
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		counts[String(animation_name)] = (
			frames.get_frame_count(animation_name)
			if frames.has_animation(animation_name)
			else 0
		)
	return counts


func _node_x(node: Node2D, fallback: float) -> float:
	return node.global_position.x if node != null else fallback


func _child_texture_path(parent: Node, child_name: String) -> String:
	if parent == null:
		return ""
	return _texture_path(parent.get_node_or_null(child_name) as Sprite2D)


func _texture_path(sprite: Sprite2D) -> String:
	return (
		sprite.texture.resource_path
		if sprite != null and sprite.texture != null
		else ""
	)


func _is_live_guard() -> bool:
	return _guard != null and is_instance_valid(_guard)
