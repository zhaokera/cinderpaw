## Owns the Story137 Signal Roof combat, reward, and durable state.
class_name NeonSignalRoofEncounterController
extends Node2D

signal objective_changed(objective_text: String)

const ROUTE_WIDTH_PX: int = 2560
const ACTIVATION_X: float = 1650.0
const BACK_SEAL_X: float = 1540.0
const FORWARD_SEAL_X: float = 2440.0
const RIGHT_WALL_X: float = 2540.0
const CACHE_X: float = 2320.0
const SIGNAL_RAT_ENTITY_ID: int = 2601
const ENCOUNTER_ID: StringName = &"neon_signal_roof_ambush"
const SIGNAL_RAT_SUMMON_ID: StringName = &"neon_signal_rat"
const SIGNAL_CACHE_ID: StringName = &"neon_signal_roof_cache"
const SIGNAL_CACHE_REWARD_GEARS: int = 20
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "env_neon_signal_roof_1280x720.png"
)
const SEAL_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_signal_seal_256x384.png"
)
const CACHE_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_signal_cache_256x256.png"
)
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/neon_signal_rat/"
	+ "neon_signal_rat_sprite_frames.tres"
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
	get_node_or_null("../SignalRoofBackground") as Sprite2D
)
@onready var _back_seal: StaticBody2D = (
	get_node_or_null("BackSeal") as StaticBody2D
)
@onready var _forward_seal: StaticBody2D = (
	get_node_or_null("ForwardSeal") as StaticBody2D
)
@onready var _enemy: CharacterBody2D = (
	get_node_or_null("NeonSignalRat") as CharacterBody2D
)
@onready var _cache: FactoryCombatCache = (
	get_node_or_null("SignalCache") as FactoryCombatCache
)
@onready var _cache_prompt: Label = (
	get_node_or_null("SignalCache/PromptLabel") as Label
)

var _route_unlocked: bool = false
var _activated: bool = false
var _defeated: bool = false
var _cache_claimed: bool = false
var _death_animation_pending: bool = false
var _player: Node2D = null
var _scene_owner: Object = null
var _last_reward: Dictionary = {}
var _defeat_feedback_count: int = 0
var _reward_feedback_count: int = 0
var _last_emitted_objective_text: String = ""


func _ready() -> void:
	_connect_enemy_signal()
	_connect_cache_signal()
	_sync_state()


func _process(_delta: float) -> void:
	if _player != null and not _activated and not _defeated:
		try_activate(_player)
	_sync_cache_prompt_visibility()


## Injects the player and owning room adapters without widening child ownership.
func configure_runtime(player: Node2D, scene_owner: Object) -> bool:
	_player = player
	_scene_owner = scene_owner
	_configure_enemy()
	_connect_enemy_signal()
	_connect_cache_signal()
	_sync_state()
	return _player != null and _scene_owner != null


## Story136's high-roof traversal is the only encounter prerequisite.
func set_route_unlocked(unlocked: bool) -> void:
	_route_unlocked = unlocked
	_sync_state()


## Activates once after the player crosses the authored arena threshold.
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
	_persist_owner_state()
	return true


## Returns true when this controller owns the supplied combat entity id.
func handles_target_id(target_id: int) -> bool:
	return target_id == SIGNAL_RAT_ENTITY_ID


## Routes player hit-confirm damage to the live Signal Rat health adapter.
func apply_damage(
	target_id: int,
	final_damage: int,
	metadata: Dictionary = {}
) -> bool:
	if (
		target_id != SIGNAL_RAT_ENTITY_ID
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
		_on_signal_rat_defeated()
	return true


## Supplies the configured Signal Rat lunge damage through CombatComponent.
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
	var damage: int = _call_enemy_int("get_attack_damage", 11)
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
		"damage_category": &"electric_lunge",
	}


## Requests the readable lunge for deterministic tests and MCP probes.
func request_signal_rat_attack() -> bool:
	return (
		_activated
		and not _defeated
		and _enemy != null
		and is_instance_valid(_enemy)
		and _enemy.has_method("request_attack")
		and bool(_enemy.call("request_attack"))
	)


## Attempts the once-only post-combat cache claim.
func try_claim_cache(provider: Node = null) -> bool:
	if _cache == null or not _defeated or _cache_claimed:
		return false
	var claim_provider: Node = _player if provider == null else provider
	return _cache.try_claim(claim_provider)


## Captures only durable encounter and reward state.
func get_local_state() -> Dictionary:
	return {
		"neon_rooftops_signal_rat_encounter_activated": _activated,
		"neon_rooftops_signal_rat_defeated": _defeated,
		"neon_rooftops_signal_cache_claimed": _cache_claimed,
	}


## Restores active, cleared, or claimed state without replaying feedback.
func set_local_state(state: Dictionary) -> void:
	_death_animation_pending = false
	_cache_claimed = bool(state.get(
		"neon_rooftops_signal_cache_claimed",
		false
	))
	_defeated = bool(state.get(
		"neon_rooftops_signal_rat_defeated",
		_cache_claimed
	)) or _cache_claimed
	_activated = bool(state.get(
		"neon_rooftops_signal_rat_encounter_activated",
		_defeated
	)) or _defeated
	_last_reward = (
		{
			"cache_id": String(SIGNAL_CACHE_ID),
			"gears": SIGNAL_CACHE_REWARD_GEARS,
			"source": "neon_signal_roof",
		}
		if _cache_claimed
		else {}
	)
	_defeat_feedback_count = 0
	_reward_feedback_count = 0
	_sync_state()


## Returns whether the extended rooftop slice owns the shared objective.
func should_own_objective(provider: Node = null) -> bool:
	if not _route_unlocked:
		return false
	if _activated or _defeated or _cache_claimed:
		return true
	var objective_provider: Node = _player if provider == null else provider
	return (
		objective_provider is Node2D
		and (objective_provider as Node2D).global_position.x >= 1280.0
	)


func get_objective_text() -> String:
	if _cache_claimed:
		return "Signal Roof Secured"
	if _defeated:
		return "Claim Signal Cache +20 Gears"
	if _activated:
		return "Break Neon Signal Rat"
	if _route_unlocked:
		return "Reach Signal Roof"
	return "Climb the Neon Magnetic Tower"


func get_last_reward() -> Dictionary:
	return _last_reward.duplicate(true)


## Returns authored geometry, data, animation, combat, and reward state.
func get_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = _get_enemy_sprite()
	var frames: SpriteFrames = sprite.sprite_frames if sprite != null else null
	var attack_metadata: Dictionary = {}
	var config_diagnostics: Dictionary = {}
	if (
		_enemy != null
		and is_instance_valid(_enemy)
		and _enemy.has_method("get_current_enemy_attack_metadata")
	):
		attack_metadata = Dictionary(_enemy.call(
			"get_current_enemy_attack_metadata"
		)).duplicate(true)
	if (
		_enemy != null
		and is_instance_valid(_enemy)
		and _enemy.has_method("get_config_diagnostics")
	):
		config_diagnostics = Dictionary(_enemy.call(
			"get_config_diagnostics"
		)).duplicate(true)
	return {
		"route_width_px": ROUTE_WIDTH_PX,
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"background_texture_path": _get_texture_path(_background),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"seal_texture_path": _get_seal_texture_path(),
		"seal_expected_path": SEAL_TEXTURE_PATH,
		"cache_texture_path": (
			_cache.get_visual_texture_path() if _cache != null else ""
		),
		"cache_expected_path": CACHE_TEXTURE_PATH,
		"activation_x": ACTIVATION_X,
		"back_seal_x": _get_node_x(_back_seal, BACK_SEAL_X),
		"forward_seal_x": _get_node_x(_forward_seal, FORWARD_SEAL_X),
		"right_wall_x": RIGHT_WALL_X,
		"cache_x": _get_node_x(_cache, CACHE_X),
		"back_seal_blocking": _is_seal_blocking(_back_seal),
		"forward_seal_blocking": _is_seal_blocking(_forward_seal),
		"route_unlocked": _route_unlocked,
		"encounter_state": String(_get_encounter_state()),
		"encounter_activated": _activated,
		"signal_rat_defeated": _defeated,
		"enemy_entity_id": SIGNAL_RAT_ENTITY_ID,
		"enemy_family_id": _get_enemy_family_id(),
		"enemy_current_hp": _get_enemy_hp(false),
		"enemy_max_hp": _get_enemy_hp(true),
		"enemy_visible": _is_enemy_visible(),
		"enemy_has_target": _enemy_has_target(),
		"enemy_animation": String(sprite.animation) if sprite != null else "",
		"sprite_frames_path": frames.resource_path if frames != null else "",
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
		"config_diagnostics": config_diagnostics,
		"cache_available": _cache != null and _cache.is_available(),
		"cache_claimed": _cache_claimed,
		"last_reward": _last_reward.duplicate(true),
		"defeat_feedback_count": _defeat_feedback_count,
		"reward_feedback_count": _reward_feedback_count,
		"objective_text": get_objective_text(),
	}


func _configure_enemy() -> void:
	if _enemy == null or not is_instance_valid(_enemy):
		return
	if _enemy.has_method("configure_summon"):
		_enemy.call(
			"configure_summon",
			ENCOUNTER_ID,
			SIGNAL_RAT_ENTITY_ID,
			SIGNAL_RAT_SUMMON_ID
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
	if not defeated_signal.is_connected(_on_signal_rat_defeated):
		defeated_signal.connect(_on_signal_rat_defeated)


func _connect_cache_signal() -> void:
	if _cache == null:
		return
	if not _cache.cache_claimed.is_connected(_on_signal_cache_claimed):
		_cache.cache_claimed.connect(_on_signal_cache_claimed)


func _on_signal_rat_defeated() -> void:
	if _defeated:
		return
	_activated = true
	_defeated = true
	_death_animation_pending = true
	_defeat_feedback_count += 1
	_request_enemy_defeat_audio()
	_sync_state()
	_persist_owner_state()


func _on_signal_cache_claimed(
	cache_id: StringName,
	reward: Dictionary
) -> void:
	if cache_id != SIGNAL_CACHE_ID or _cache_claimed:
		return
	_cache_claimed = true
	_last_reward = reward.duplicate(true)
	_reward_feedback_count += 1
	_request_reward_audio(cache_id, reward)
	_sync_state()
	_persist_owner_state()


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
	if _cache != null:
		_cache.visible = _defeated
		_cache.set_available(_defeated)
		_cache.set_claimed(_cache_claimed)
	_sync_cache_prompt_visibility()
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
			_enemy.call("begin_pacing", 20)
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


func _sync_cache_prompt_visibility() -> void:
	if _cache_prompt == null or _cache == null:
		return
	_cache_prompt.visible = (
		_defeated
		and not _cache_claimed
		and _player != null
		and _cache.is_provider_in_reward_range(_player)
	)


func _emit_objective_if_changed() -> void:
	var objective_text: String = get_objective_text()
	if objective_text == _last_emitted_objective_text:
		return
	_last_emitted_objective_text = objective_text
	objective_changed.emit(objective_text)


func _request_enemy_defeat_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null or not audio_system.has_method("on_enemy_defeated"):
		return
	audio_system.call("on_enemy_defeated", {
		"enemy_id": String(SIGNAL_RAT_SUMMON_ID),
		"entity_id": SIGNAL_RAT_ENTITY_ID,
		"world_position": _enemy.global_position if (
			_enemy != null and is_instance_valid(_enemy)
		) else Vector2(ACTIVATION_X, 520.0),
	})


func _request_reward_audio(
	cache_id: StringName,
	reward: Dictionary
) -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if (
		audio_system == null
		or not audio_system.has_method("on_reward_cache_claimed")
	):
		return
	audio_system.call(
		"on_reward_cache_claimed",
		cache_id,
		reward,
		_cache.global_position if _cache != null else Vector2(CACHE_X, 520.0),
		{"scene_id": &"area_05_neon_rooftops"}
	)


func _persist_owner_state() -> void:
	if (
		_scene_owner != null
		and _scene_owner.has_method("persist_signal_roof_progress")
	):
		_scene_owner.call("persist_signal_roof_progress")


func _get_encounter_state() -> StringName:
	if _cache_claimed:
		return &"claimed"
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
	return "neon_signal_rat"


func _get_enemy_hp(maximum: bool) -> int:
	var method_name: StringName = &"get_max_hp" if maximum else &"get_current_hp"
	return _call_enemy_int(method_name, 36 if maximum else 0)


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


func _get_texture_path(sprite: Sprite2D) -> String:
	if sprite == null or sprite.texture == null:
		return ""
	return sprite.texture.resource_path


func _get_seal_texture_path() -> String:
	if _back_seal == null:
		return ""
	var visual: Sprite2D = _back_seal.get_node_or_null("Visual") as Sprite2D
	return _get_texture_path(visual)


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
