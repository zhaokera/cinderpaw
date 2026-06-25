## Runtime wiring for the first Old Factory entrance combat room.
class_name OldFactoryEntranceScene
extends Node2D

const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_MUSIC_ID: StringName = &"mus_factory"
const FACTORY_AMBIENT_ID: StringName = &"amb_factory"
const FACTORY_AUDIO_FADE_SEC: float = 3.0
const FACTORY_PLAYER_LIGHT_DAMAGE: int = 12
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")

@onready var _spawn: Marker2D = $FactoryGateEntrySpawn
@onready var _player: Node2D = $Player
@onready var _enemy: Node2D = $FactoryRatMinion

var _last_player_hit_metadata: Dictionary = {}
var _weapon_component: WeaponComponent = null


func _ready() -> void:
	_setup_weapon_component()
	_align_player_to_spawn()
	_bind_enemy_to_player()
	_bind_player_combat_to_room()
	_request_factory_audio()


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
		"final_damage": FACTORY_PLAYER_LIGHT_DAMAGE,
		"base_damage": FACTORY_PLAYER_LIGHT_DAMAGE,
		"attack_damage": float(FACTORY_PLAYER_LIGHT_DAMAGE),
		"reduction_factor": 1.0,
		"damage_multiplier": 1.0,
		"is_crit": false,
		"crit_type": &"none",
		"parry_type": &"none",
		"combo_stage": combo_index,
		"damage_category": &"scratch",
	}


func apply_damage(target_id: int, final_damage: int, metadata: Dictionary = {}) -> bool:
	if _enemy == null or not _enemy.has_method("get_entity_id"):
		return false
	if int(_enemy.call("get_entity_id")) != target_id:
		return false
	if not _enemy.has_method("apply_damage"):
		return false
	_enemy.call("apply_damage", final_damage, metadata)
	return true


func get_last_player_hit_metadata() -> Dictionary:
	return _last_player_hit_metadata.duplicate(true)


func get_factory_entrance_diagnostics() -> Dictionary:
	var backdrop := get_node_or_null("Background") as TextureRect
	var enemy_sprite := get_node_or_null("FactoryRatMinion/Sprite") as AnimatedSprite2D
	return {
		"scene_id": String(get_meta("scene_id", String(FACTORY_SCENE_ID))),
		"has_spawn": _spawn != null,
		"has_player": _player != null,
		"has_enemy": _enemy != null,
		"backdrop_texture_path": (
			backdrop.texture.resource_path
			if backdrop != null and backdrop.texture != null
			else ""
		),
		"enemy_sprite_frames_path": (
			enemy_sprite.sprite_frames.resource_path
			if enemy_sprite != null and enemy_sprite.sprite_frames != null
			else ""
		),
		"last_player_hit_metadata": get_last_player_hit_metadata(),
	}


func _align_player_to_spawn() -> void:
	if _spawn == null or _player == null:
		return
	_player.global_position = _spawn.global_position


func _bind_enemy_to_player() -> void:
	if _enemy == null or _player == null:
		return
	if _enemy.has_method("set_attack_target"):
		_enemy.call("set_attack_target", _player)
	if _enemy.has_method("configure_summon"):
		_enemy.call("configure_summon", &"old_factory_entrance", 2100, &"factory_patrol")


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
			_weapon_component.set_collision_adapter(_player.call("get_collision_component"))
	if _player.has_signal("attack_landed"):
		var attack_signal: Signal = _player.get("attack_landed")
		if not attack_signal.is_connected(_on_player_attack_landed):
			attack_signal.connect(_on_player_attack_landed)


func _on_player_attack_landed(metadata: Dictionary) -> void:
	_last_player_hit_metadata = metadata.duplicate(true)


func _setup_weapon_component() -> void:
	_weapon_component = get_node_or_null("WeaponComponent") as WeaponComponent
	if _weapon_component == null:
		_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
		_weapon_component.name = "WeaponComponent"
		add_child(_weapon_component)
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		_weapon_component.set_data_manager(root_data_manager)


func _request_factory_audio() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("play_music"):
		audio_system.call("play_music", FACTORY_MUSIC_ID, FACTORY_AUDIO_FADE_SEC)
	if audio_system.has_method("play_ambient"):
		audio_system.call("play_ambient", FACTORY_AMBIENT_ID, FACTORY_AUDIO_FADE_SEC)
