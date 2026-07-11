## Owns the Story133 deep-cistern Stalker arena and durable clear state.
class_name UndergroundDeepCisternAmbushController
extends Node2D

signal objective_changed(objective_text: String)

const ROUTE_WIDTH_PX: int = 5120
const ACTIVATION_X: float = 4050.0
const BACK_SEAL_X: float = 3980.0
const FORWARD_SEAL_X: float = 4960.0
const RIGHT_WALL_X: float = 5100.0
const STALKER_ENTITY_ID: int = 2501
const ENCOUNTER_ID: StringName = &"underground_deep_cistern_ambush"
const STALKER_SUMMON_ID: StringName = &"underground_cistern_stalker"
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "env_underground_deep_cistern_1280x720.png"
)
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/underground_cistern_stalker/"
	+ "underground_cistern_stalker_sprite_frames.tres"
)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

@onready var _background: Sprite2D = (
	get_node_or_null("../DeepCisternBackground") as Sprite2D
)
@onready var _back_seal: StaticBody2D = (
	get_node_or_null("BackSeal") as StaticBody2D
)
@onready var _forward_seal: StaticBody2D = (
	get_node_or_null("ForwardSeal") as StaticBody2D
)
@onready var _enemy: CharacterBody2D = (
	get_node_or_null("CisternStalker") as CharacterBody2D
)

var _route_unlocked: bool = false
var _activated: bool = false
var _defeated: bool = false
var _death_animation_pending: bool = false
var _player: Node2D = null
var _scene_owner: Object = null
var _last_emitted_objective_text: String = ""


func _ready() -> void:
	_connect_enemy_signal()
	_sync_state()


func _process(_delta: float) -> void:
	if _player != null and not _activated and not _defeated:
		try_activate(_player)


## Injects the player and parent room adapters without widening parent ownership.
func configure_runtime(player: Node2D, scene_owner: Object) -> bool:
	_player = player
	_scene_owner = scene_owner
	_configure_enemy()
	_connect_enemy_signal()
	_sync_state()
	return _player != null and _scene_owner != null


## Story132 traversal is the only prerequisite for entering the ambush.
func set_route_unlocked(unlocked: bool) -> void:
	_route_unlocked = unlocked
	_sync_state()


## Activates once after the player crosses the authored threshold.
func try_activate(provider: Node = null) -> bool:
	if not _route_unlocked or _activated or _defeated:
		return false
	var activation_provider: Node = _player if provider == null else provider
	if (
		activation_provider == null
		or not activation_provider is Node2D
		or (activation_provider as Node2D).global_position.x < ACTIVATION_X
	):
		return false
	_activated = true
	_sync_state()
	return true


## Returns true when this controller owns the supplied combat entity id.
func handles_target_id(target_id: int) -> bool:
	return target_id == STALKER_ENTITY_ID


## Routes player hit-confirm damage to the live Stalker health adapter.
func apply_damage(
	target_id: int,
	final_damage: int,
	metadata: Dictionary = {}
) -> bool:
	if (
		target_id != STALKER_ENTITY_ID
		or final_damage <= 0
		or not _activated
		or _defeated
		or _enemy == null
		or not is_instance_valid(_enemy)
		or not _enemy.has_method("apply_damage")
	):
		return false
	_enemy.call("apply_damage", final_damage, metadata)
	if (
		is_instance_valid(_enemy)
		and _enemy.has_method("get_current_hp")
		and int(_enemy.call("get_current_hp")) <= 0
		and not _defeated
	):
		_on_stalker_defeated()
	return true


## Supplies the Stalker's fixed leap damage through CombatComponent.
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
		"final_damage": UndergroundCisternStalker.STALKER_ATTACK_DAMAGE,
		"base_damage": UndergroundCisternStalker.STALKER_ATTACK_DAMAGE,
		"attack_damage": float(
			UndergroundCisternStalker.STALKER_ATTACK_DAMAGE
		),
		"reduction_factor": 1.0,
		"damage_multiplier": 1.0,
		"is_crit": false,
		"crit_type": &"none",
		"parry_type": &"none",
		"combo_stage": combo_index,
		"damage_category": &"leap",
	}


## Requests the readable leap attack for deterministic smoke and MCP probes.
func request_stalker_attack() -> bool:
	return (
		_activated
		and not _defeated
		and _enemy != null
		and is_instance_valid(_enemy)
		and _enemy.has_method("request_attack")
		and bool(_enemy.call("request_attack"))
	)


## Captures only durable activation and clear state.
func get_local_state() -> Dictionary:
	return {
		"underground_deep_cistern_ambush_activated": _activated,
		"underground_deep_cistern_stalker_defeated": _defeated,
	}


## Restores the deterministic active or cleared arena without replay feedback.
func set_local_state(state: Dictionary) -> void:
	_death_animation_pending = false
	_defeated = bool(state.get(
		"underground_deep_cistern_stalker_defeated",
		false
	))
	_activated = bool(state.get(
		"underground_deep_cistern_ambush_activated",
		_defeated
	)) or _defeated
	_sync_state()


## Returns whether this deepest available slice owns the shared objective.
func should_own_objective(provider: Node = null) -> bool:
	if not _route_unlocked:
		return false
	if _activated or _defeated:
		return true
	var objective_provider: Node = _player if provider == null else provider
	return (
		objective_provider is Node2D
		and (objective_provider as Node2D).global_position.x >= 3840.0
	)


func get_objective_text() -> String:
	if _defeated:
		return "Deep Cistern Secured"
	if _activated:
		return "Break Cistern Stalker"
	if _route_unlocked:
		return "Enter Deep Cistern"
	return "Secure Recovery Cistern"


## Returns authored geometry, animation, AI, and live encounter state.
func get_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = _get_enemy_sprite()
	var frames: SpriteFrames = sprite.sprite_frames if sprite != null else null
	var attack_metadata: Dictionary = {}
	if (
		_enemy != null
		and is_instance_valid(_enemy)
		and _enemy.has_method("get_current_enemy_attack_metadata")
	):
		attack_metadata = Dictionary(_enemy.call(
			"get_current_enemy_attack_metadata"
		)).duplicate(true)
	return {
		"route_width_px": ROUTE_WIDTH_PX,
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"background_texture_path": _get_background_texture_path(),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"activation_x": ACTIVATION_X,
		"back_seal_x": _get_node_x(_back_seal, BACK_SEAL_X),
		"forward_seal_x": _get_node_x(_forward_seal, FORWARD_SEAL_X),
		"right_wall_x": RIGHT_WALL_X,
		"back_seal_blocking": _is_seal_blocking(_back_seal),
		"forward_seal_blocking": _is_seal_blocking(_forward_seal),
		"route_unlocked": _route_unlocked,
		"encounter_state": String(_get_encounter_state()),
		"encounter_activated": _activated,
		"stalker_defeated": _defeated,
		"enemy_entity_id": STALKER_ENTITY_ID,
		"enemy_family_id": _get_enemy_family_id(),
		"enemy_current_hp": _get_enemy_hp(false),
		"enemy_max_hp": _get_enemy_hp(true),
		"enemy_visible": _is_enemy_visible(),
		"enemy_has_target": _enemy_has_target(),
		"enemy_animation": String(sprite.animation) if sprite != null else "",
		"sprite_frames_path": (
			frames.resource_path if frames != null else ""
		),
		"sprite_frames_expected_path": SPRITE_FRAMES_PATH,
		"animation_frames": _get_animation_frame_counts(frames),
		"attack_startup_frames": _call_enemy_int(
			"get_attack_startup_frames",
			0
		),
		"attack_active_frames": _call_enemy_int(
			"get_attack_active_frames",
			0
		),
		"attack_recovery_frames": _call_enemy_int(
			"get_attack_recovery_frames",
			0
		),
		"attack_damage": _call_enemy_int("get_attack_damage", 0),
		"attack_active": (
			bool(_enemy.call("is_enemy_attack_active"))
			if _enemy != null
			and is_instance_valid(_enemy)
			and _enemy.has_method("is_enemy_attack_active")
			else false
		),
		"attack_metadata": attack_metadata,
		"objective_text": get_objective_text(),
	}


func _configure_enemy() -> void:
	if _enemy == null or not is_instance_valid(_enemy):
		return
	if _enemy.has_method("configure_summon"):
		_enemy.call(
			"configure_summon",
			ENCOUNTER_ID,
			STALKER_ENTITY_ID,
			STALKER_SUMMON_ID
		)
	if _enemy.has_method("set_damage_calculator_adapter"):
		_enemy.call("set_damage_calculator_adapter", self)


func _connect_enemy_signal() -> void:
	if (
		_enemy == null
		or not is_instance_valid(_enemy)
		or not _enemy.has_signal("enemy_defeated")
	):
		return
	var defeated_signal: Signal = _enemy.get("enemy_defeated")
	if not defeated_signal.is_connected(_on_stalker_defeated):
		defeated_signal.connect(_on_stalker_defeated)


func _on_stalker_defeated() -> void:
	_activated = true
	_defeated = true
	_death_animation_pending = true
	_sync_state()


func _sync_state() -> void:
	if _defeated and _death_animation_pending:
		_hold_enemy_death_animation()
	else:
		_set_enemy_active(_activated and not _defeated)
	_set_seal_blocking(
		_back_seal,
		(not _route_unlocked) or (_activated and not _defeated)
	)
	_set_seal_blocking(_forward_seal, not _defeated)
	_emit_objective_if_changed()


func _hold_enemy_death_animation() -> void:
	if _enemy == null or not is_instance_valid(_enemy):
		return
	if _enemy.has_method("set_attack_target"):
		_enemy.call("set_attack_target", null)
	_enemy.visible = true
	_enemy.process_mode = Node.PROCESS_MODE_INHERIT
	_enemy.set_physics_process(false)
	_enemy.collision_layer = 0
	_enemy.collision_mask = 0


func _set_enemy_active(active: bool) -> void:
	if _enemy == null or not is_instance_valid(_enemy):
		return
	var was_active: bool = (
		_enemy.visible and _enemy.process_mode != Node.PROCESS_MODE_DISABLED
	)
	if active:
		_enemy.visible = true
		_enemy.process_mode = Node.PROCESS_MODE_INHERIT
		_enemy.set_physics_process(true)
		_enemy.collision_layer = 2
		_enemy.collision_mask = 17
		if _enemy.has_method("set_attack_target"):
			_enemy.call("set_attack_target", _player)
		if not was_active and _enemy.has_method("begin_pacing"):
			_enemy.call("begin_pacing", 24)
		return
	if _enemy.has_method("set_attack_target"):
		_enemy.call("set_attack_target", null)
	_enemy.set_physics_process(false)
	_enemy.process_mode = Node.PROCESS_MODE_DISABLED
	_enemy.collision_layer = 0
	_enemy.collision_mask = 0
	_enemy.visible = false


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


func _get_encounter_state() -> StringName:
	if _defeated:
		return &"cleared"
	if _activated:
		return &"active"
	if _route_unlocked:
		return &"ready"
	return &"locked"


func _get_enemy_sprite() -> AnimatedSprite2D:
	if _enemy == null or not is_instance_valid(_enemy):
		return null
	return _enemy.get_node_or_null("Sprite") as AnimatedSprite2D


func _get_enemy_family_id() -> String:
	if (
		_enemy != null
		and is_instance_valid(_enemy)
		and _enemy.has_method("get_enemy_family_id")
	):
		return String(_enemy.call("get_enemy_family_id"))
	return "underground_cistern_stalker"


func _get_enemy_hp(maximum: bool) -> int:
	var method_name: StringName = &"get_max_hp" if maximum else &"get_current_hp"
	return _call_enemy_int(method_name, 48 if maximum else 0)


func _call_enemy_int(method_name: StringName, fallback: int) -> int:
	if (
		_enemy == null
		or not is_instance_valid(_enemy)
		or not _enemy.has_method(method_name)
	):
		return fallback
	return int(_enemy.call(method_name))


func _enemy_has_target() -> bool:
	return (
		_enemy != null
		and is_instance_valid(_enemy)
		and _enemy.has_method("has_attack_target")
		and bool(_enemy.call("has_attack_target"))
	)


func _is_enemy_visible() -> bool:
	return (
		_enemy != null
		and is_instance_valid(_enemy)
		and _enemy.visible
		and _enemy.process_mode != Node.PROCESS_MODE_DISABLED
	)


func _get_animation_frame_counts(frames: SpriteFrames) -> Dictionary:
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


func _get_background_texture_path() -> String:
	if _background == null or _background.texture == null:
		return ""
	return _background.texture.resource_path


func _get_node_x(node: Node2D, fallback: float) -> float:
	return node.global_position.x if node != null else fallback


func _is_seal_blocking(seal: StaticBody2D) -> bool:
	if seal == null:
		return false
	var shape: CollisionShape2D = seal.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	return (
		seal.visible
		and seal.collision_layer == 16
		and shape != null
		and not shape.disabled
	)
