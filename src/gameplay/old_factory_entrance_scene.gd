## Runtime wiring for the first Old Factory entrance combat room.
class_name OldFactoryEntranceScene
extends Node2D

const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_MUSIC_ID: StringName = &"mus_factory"
const FACTORY_AMBIENT_ID: StringName = &"amb_factory"
const FACTORY_AUDIO_FADE_SEC: float = 3.0
const FACTORY_PLAYER_LIGHT_DAMAGE: int = 12
const FACTORY_STEAM_DAMAGE_FALLBACK: int = 8
const FACTORY_STEAM_CONTACT_COOLDOWN_FALLBACK_SEC: float = 1.0
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")

@onready var _spawn: Marker2D = $FactoryGateEntrySpawn
@onready var _player: Node2D = $Player
@onready var _enemy: Node2D = $FactoryRatMinion
@onready var _cache: Node = $FactoryCombatCache
@onready var _steam_vent: Area2D = get_node_or_null("FactorySteamVentHazard") as Area2D

var _last_player_hit_metadata: Dictionary = {}
var _last_cache_reward: Dictionary = {}
var _last_hazard_damage: Dictionary = {}
var _encounter_cleared: bool = false
var _cache_claimed: bool = false
var _factory_hazard_elapsed_sec: float = 0.0
var _factory_hazard_contact_cooldowns: Dictionary = {}
var _weapon_component: WeaponComponent = null


func _ready() -> void:
	_setup_weapon_component()
	_align_player_to_spawn()
	_bind_enemy_to_player()
	_setup_factory_cache()
	_setup_factory_hazards()
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


## Returns whether the Factory entrance combat encounter has been cleared.
func is_encounter_cleared() -> bool:
	return _encounter_cleared


## Returns whether the Factory entrance combat cache was already claimed.
func is_factory_cache_claimed() -> bool:
	return _cache_claimed


## Attempts to claim the room-clear cache with the player or supplied provider.
func try_claim_factory_cache(provider: Node = null) -> bool:
	if not _encounter_cleared or _cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if not _cache.has_method("try_claim") or not bool(_cache.call("try_claim", claim_provider)):
		return false
	_cache_claimed = true
	_last_cache_reward = _get_cache_reward_payload()
	_update_route_label("Factory cache +10 Gears")
	return true


## Advances scene-local hazard time and applies sustained overlap ticks.
func advance_factory_hazard_time(delta_sec: float) -> void:
	_factory_hazard_elapsed_sec += maxf(0.0, delta_sec)
	_process_factory_hazard_overlaps()


## Applies steam vent contact damage to the player with per-target cooldown.
func apply_factory_steam_vent_contact(hazard: Area2D, target: Node) -> bool:
	if hazard == null or target == null or _player == null or not is_instance_valid(hazard):
		return false
	if target != _player:
		return false
	var hazard_id: StringName = _get_hazard_id(hazard)
	if hazard_id != &"old_factory_steam_vent":
		return false
	var target_id: int = PlayerController.PLAYER_ENTITY_ID
	var cooldown_key: String = _factory_hazard_cooldown_key(hazard_id, target_id)
	var next_allowed_sec: float = float(_factory_hazard_contact_cooldowns.get(cooldown_key, -1.0))
	if next_allowed_sec > _factory_hazard_elapsed_sec:
		return false
	var steam_damage: int = _get_hazard_damage(hazard)
	var hp_before: int = int(_player.call("get_current_hp")) if _player.has_method("get_current_hp") else 0
	var damage_data: Dictionary = {
		"damage": steam_damage,
		"final_damage": steam_damage,
		"hit_position": hazard.global_position,
		"is_crit": false,
		"source": hazard_id,
		"damage_type": &"steam",
		"scene_id": FACTORY_SCENE_ID,
		"target_id": target_id,
	}
	if _player.has_method("apply_damage"):
		_player.call("apply_damage", steam_damage, damage_data)
	var hp_after: int = int(_player.call("get_current_hp")) if _player.has_method("get_current_hp") else hp_before
	if hp_after >= hp_before:
		return false
	_last_hazard_damage = damage_data.duplicate(true)
	_factory_hazard_contact_cooldowns[cooldown_key] = (
		_factory_hazard_elapsed_sec + _get_hazard_cooldown_sec(hazard)
	)
	_update_route_label("Steam vent hit")
	return true


## Captures scene-local state for SceneManager runtime swap persistence.
func get_local_state() -> Dictionary:
	return {
		"encounter_cleared": _encounter_cleared,
		"factory_cache_claimed": _cache_claimed,
		"last_cache_reward": _last_cache_reward.duplicate(true),
		"last_hazard_damage": _last_hazard_damage.duplicate(true),
	}


## Restores scene-local state from SceneManager runtime swap persistence.
func set_local_state(state: Dictionary) -> void:
	_encounter_cleared = bool(state.get("encounter_cleared", false))
	_cache_claimed = bool(state.get("factory_cache_claimed", false))
	var reward_variant: Variant = state.get("last_cache_reward", {})
	_last_cache_reward = (
		(reward_variant as Dictionary).duplicate(true)
		if reward_variant is Dictionary
		else {}
	)
	var hazard_variant: Variant = state.get("last_hazard_damage", {})
	_last_hazard_damage = (
		(hazard_variant as Dictionary).duplicate(true)
		if hazard_variant is Dictionary
		else {}
	)
	_sync_room_clear_state()


## Returns deterministic room-clear/cache diagnostics for tests and MCP probes.
func get_factory_room_clear_diagnostics() -> Dictionary:
	return {
		"encounter_cleared": _encounter_cleared,
		"cache_present": _cache != null,
		"cache_id": String(_cache.call("get_cache_id")) if _cache != null and _cache.has_method("get_cache_id") else "",
		"cache_available": bool(_cache.call("is_available")) if _cache != null and _cache.has_method("is_available") else false,
		"cache_claim_available": bool(_cache.call("is_claim_available")) if _cache != null and _cache.has_method("is_claim_available") else false,
		"cache_claimed": _cache_claimed,
		"cache_texture_path": (
			String(_cache.call("get_visual_texture_path"))
			if _cache != null and _cache.has_method("get_visual_texture_path")
			else ""
		),
		"has_cache_platform": get_node_or_null("FactoryCachePlatform/CollisionShape2D") != null,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"cache_position": _cache.global_position if _cache != null else Vector2.ZERO,
		"last_cache_reward": _last_cache_reward.duplicate(true),
	}


## Returns deterministic steam vent hazard diagnostics for tests and MCP probes.
func get_factory_hazard_diagnostics() -> Dictionary:
	return {
		"steam_vent_present": _steam_vent != null,
		"steam_vent_id": String(_get_hazard_id(_steam_vent)),
		"steam_damage": _get_hazard_damage(_steam_vent),
		"steam_cooldown_sec": _get_hazard_cooldown_sec(_steam_vent),
		"steam_vent_texture_path": (
			String(_steam_vent.call("get_visual_texture_path"))
			if _steam_vent != null and _steam_vent.has_method("get_visual_texture_path")
			else ""
		),
		"steam_vent_layer": _steam_vent.collision_layer if _steam_vent != null else 0,
		"steam_vent_mask": _steam_vent.collision_mask if _steam_vent != null else 0,
		"last_hazard_damage": _last_hazard_damage.duplicate(true),
	}


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
		"room_clear": get_factory_room_clear_diagnostics(),
		"hazards": get_factory_hazard_diagnostics(),
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
	if _enemy.has_signal("enemy_defeated"):
		var defeated_signal: Signal = _enemy.get("enemy_defeated")
		if not defeated_signal.is_connected(_on_factory_enemy_defeated):
			defeated_signal.connect(_on_factory_enemy_defeated)


func _setup_factory_cache() -> void:
	_sync_room_clear_state()
	if _cache == null or not _cache.has_signal("cache_claimed"):
		return
	var claimed_signal: Signal = _cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_cache_claimed):
		claimed_signal.connect(_on_factory_cache_claimed)


func _setup_factory_hazards() -> void:
	if _steam_vent == null:
		return
	var area_entered_callback := Callable(self, "_on_factory_hazard_area_entered").bind(_steam_vent)
	if not _steam_vent.area_entered.is_connected(area_entered_callback):
		_steam_vent.area_entered.connect(area_entered_callback)
	var body_entered_callback := Callable(self, "_on_factory_hazard_body_entered").bind(_steam_vent)
	if not _steam_vent.body_entered.is_connected(body_entered_callback):
		_steam_vent.body_entered.connect(body_entered_callback)


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


func _on_factory_enemy_defeated() -> void:
	_encounter_cleared = true
	_sync_room_clear_state()
	_update_route_label("Factory cache unlocked")


func _on_factory_cache_claimed(_cache_id: StringName, reward: Dictionary) -> void:
	_cache_claimed = true
	_last_cache_reward = reward.duplicate(true)


func _on_factory_hazard_area_entered(area: Area2D, hazard: Area2D) -> void:
	var target: Node = _resolve_factory_hazard_target_from_area(area)
	if target != null:
		apply_factory_steam_vent_contact(hazard, target)


func _on_factory_hazard_body_entered(body: Node2D, hazard: Area2D) -> void:
	if body == _player:
		apply_factory_steam_vent_contact(hazard, _player)


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


func _sync_room_clear_state() -> void:
	if _cache != null:
		if _cache.has_method("set_available"):
			_cache.call("set_available", _encounter_cleared)
		if _cache.has_method("set_claimed"):
			_cache.call("set_claimed", _cache_claimed)
	if _encounter_cleared:
		_update_route_label("Factory cache available" if not _cache_claimed else "Factory cache claimed")
	if _enemy != null and _encounter_cleared and _cache_claimed:
		_enemy.visible = false
		_enemy.set_physics_process(false)
		_enemy.set_process(false)
		_enemy.set_deferred("collision_layer", 0)
		_enemy.set_deferred("collision_mask", 0)


func _update_route_label(text_value: String) -> void:
	var route_label := get_node_or_null("RouteLabel") as Label
	if route_label == null:
		return
	route_label.text = text_value
	route_label.visible = true


func _get_cache_reward_payload() -> Dictionary:
	if _cache == null or not _cache.has_method("get_reward_payload"):
		return {}
	var reward_variant: Variant = _cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _process_factory_hazard_overlaps() -> void:
	if _steam_vent == null:
		return
	for area: Area2D in _steam_vent.get_overlapping_areas():
		var target: Node = _resolve_factory_hazard_target_from_area(area)
		if target != null:
			apply_factory_steam_vent_contact(_steam_vent, target)
	for body: Node2D in _steam_vent.get_overlapping_bodies():
		if body == _player:
			apply_factory_steam_vent_contact(_steam_vent, _player)


func _resolve_factory_hazard_target_from_area(area: Area2D) -> Node:
	if area == null:
		return null
	var parent: Node = area.get_parent()
	if parent == _player:
		return _player
	if parent != null and parent.has_method("get_entity_id") \
			and int(parent.call("get_entity_id")) == PlayerController.PLAYER_ENTITY_ID:
		return _player
	return null


func _get_hazard_id(hazard: Area2D) -> StringName:
	if hazard != null and hazard.has_method("get_hazard_id"):
		return StringName(String(hazard.call("get_hazard_id")))
	return &""


func _get_hazard_damage(hazard: Area2D) -> int:
	if hazard != null and hazard.has_method("get_damage"):
		return int(hazard.call("get_damage"))
	return FACTORY_STEAM_DAMAGE_FALLBACK


func _get_hazard_cooldown_sec(hazard: Area2D) -> float:
	if hazard != null and hazard.has_method("get_contact_cooldown_sec"):
		return float(hazard.call("get_contact_cooldown_sec"))
	return FACTORY_STEAM_CONTACT_COOLDOWN_FALLBACK_SEC


func _factory_hazard_cooldown_key(hazard_id: StringName, target_id: int) -> String:
	return "%s:%d" % [String(hazard_id), target_id]
