## New Game onboarding slice: movement runway, one ordinary enemy, then Main.
extends Node2D

const ONBOARDING_SCENE_ID: StringName = &"area_01_scrap_roost_hunt"
const NEXT_SCENE_ID: StringName = &"area_01_scrap_roost_dodge_trial"
const NEXT_SPAWN_POINT: StringName = &"default"
const ENEMY_ENTITY_ID: int = 2101
const ENEMY_ACTIVATION_X: float = 500.0
const PLAYER_SPAWN_POSITION: Vector2 = Vector2(150.0, 456.0)
const ENEMY_SPAWN_POSITION: Vector2 = Vector2(820.0, 482.0)
const FALL_RESET_Y: float = 780.0
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")
const DAMAGE_ADAPTER_SCRIPT: Script = preload(
	"res://src/gameplay/runtime_damage_calculator_adapter.gd"
)
const RAT_MINION_SCENE: PackedScene = preload("res://src/gameplay/rat_minion.tscn")

@export var auto_configure_runtime_services: bool = true

@onready var _player: PlayerController = $Player
@onready var _camera: Camera2D = $Player/Camera2D
@onready var _hud: HUDManager = $HUD
@onready var _combat_presentation: CombatPresentation = $CombatPresentation
@onready var _hitstop_input_bridge: HitstopInputBridge = $HitstopInputBridge
@onready var _gate_blocker_shape: CollisionShape2D = $ExitGateBlocker/CollisionShape2D
@onready var _exit_gate: Sprite2D = $ExitGate
@onready var _exit_pulse: Sprite2D = $ExitGate/ExitPulse

var _scene_manager: Object = null
var _weapon_component: WeaponComponent = null
var _damage_adapter: Object = null
var _enemy: Node2D = null
var _safe_runway_crossed: bool = false
var _enemy_active: bool = false
var _enemy_defeated: bool = false
var _exit_unlocked: bool = false
var _transition_requested: bool = false
var _reset_pending: bool = false
var _elapsed_sec: float = 0.0


func _ready() -> void:
	_setup_player_combat()
	_spawn_enemy()
	_connect_runtime_signals()
	_combat_presentation.set_camera(_camera)
	_hitstop_input_bridge.configure(
		_combat_presentation,
		_player,
		get_node_or_null("/root/InputManager")
	)
	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.update_currency(0)
	_sync_exit_gate()
	if auto_configure_runtime_services:
		configure_scene_manager_runtime(get_node_or_null("/root/SceneManager"))


func _physics_process(delta: float) -> void:
	_elapsed_sec += maxf(delta, 0.0)
	_update_exit_pulse()
	if _transition_requested or _reset_pending:
		return
	if _player.global_position.y > FALL_RESET_Y:
		_reset_attempt()
		return
	if not _enemy_active and _player.global_position.x >= ENEMY_ACTIVATION_X:
		_activate_enemy()


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	if not _is_valid_scene_manager(scene_manager):
		_scene_manager = null
		return false
	_scene_manager = scene_manager
	return true


func apply_damage(target_id: int, final_damage: int, metadata: Dictionary = {}) -> bool:
	if (
		final_damage <= 0
		or not _enemy_active
		or _enemy_defeated
		or not is_instance_valid(_enemy)
		or not _enemy.has_method("get_entity_id")
		or int(_enemy.call("get_entity_id")) != target_id
	):
		return false
	_enemy.call("apply_damage", final_damage, metadata)
	return true


func get_onboarding_diagnostics() -> Dictionary:
	var enemy_sprite: AnimatedSprite2D = _get_enemy_sprite()
	var enemy_frames: SpriteFrames = enemy_sprite.sprite_frames if enemy_sprite != null else null
	return {
		"scene_id": String(ONBOARDING_SCENE_ID),
		"safe_runway_crossed": _safe_runway_crossed,
		"enemy_active": _enemy_active,
		"enemy_defeated": _enemy_defeated,
		"enemy_present": is_instance_valid(_enemy),
		"enemy_hp": (
			int(_enemy.call("get_current_hp"))
			if is_instance_valid(_enemy) and _enemy.has_method("get_current_hp")
			else 0
		),
		"enemy_animation": String(enemy_sprite.animation) if enemy_sprite != null else "",
		"enemy_animation_frame": enemy_sprite.frame if enemy_sprite != null else -1,
		"attack_tell_frames": (
			enemy_frames.get_frame_count(&"attack_tell")
			if enemy_frames != null and enemy_frames.has_animation(&"attack_tell")
			else 0
		),
		"exit_unlocked": _exit_unlocked,
		"transition_requested": _transition_requested,
		"rat_king_present": find_child("*RatKing*", true, false) != null,
		"player_position": _player.global_position,
	}


func _setup_player_combat() -> void:
	_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
	_weapon_component.name = "WeaponComponent"
	add_child(_weapon_component)
	var data_manager: Node = get_node_or_null("/root/DataManager")
	if data_manager != null:
		_weapon_component.set_data_manager(data_manager)
	_damage_adapter = DAMAGE_ADAPTER_SCRIPT.new(data_manager)
	_player.set_damage_calculator_adapter(_damage_adapter)
	_player.set_target_health_adapter(self)
	_player.set_weapon_component(_weapon_component)
	_weapon_component.set_combat_adapter(_player.get_combat_component())
	_weapon_component.set_collision_adapter(_player.get_collision_component())


func _spawn_enemy() -> void:
	_enemy = RAT_MINION_SCENE.instantiate() as Node2D
	if _enemy == null:
		return
	_enemy.name = "OnboardingRat"
	_enemy.position = ENEMY_SPAWN_POSITION
	add_child(_enemy)
	_enemy.call("configure_summon", ONBOARDING_SCENE_ID, ENEMY_ENTITY_ID, &"initiation_rat")
	_enemy.call("set_damage_calculator_adapter", _damage_adapter)
	_enemy.call("set_attack_target", null)
	_enemy.set_physics_process(false)
	_enemy.connect("enemy_defeated", _on_enemy_defeated)
	_enemy.connect("enemy_attack_landed", _on_enemy_attack_landed)


func _connect_runtime_signals() -> void:
	_player.player_health_changed.connect(_on_player_health_changed)
	_player.player_died.connect(_on_player_died)
	_player.attack_landed.connect(_on_player_attack_landed)
	$ExitArea.body_entered.connect(_on_exit_area_body_entered)


func _activate_enemy() -> void:
	if _enemy_active or _enemy_defeated or not is_instance_valid(_enemy):
		return
	_safe_runway_crossed = true
	_enemy_active = true
	_enemy.call("set_attack_target", _player)
	_enemy.set_physics_process(true)


func _on_enemy_defeated() -> void:
	_enemy_active = false
	_enemy_defeated = true
	_exit_unlocked = true
	_sync_exit_gate()
	_combat_presentation.on_kill_event(ENEMY_ENTITY_ID, _enemy.global_position)


func _on_enemy_attack_landed(damage: int, hit_position: Vector2, is_crit: bool) -> void:
	_combat_presentation.on_hit_event({
		"source": &"rat_minion_bite",
		"damage": damage,
		"final_damage": damage,
		"hit_position": hit_position,
		"is_crit": is_crit,
		"show_damage_number": true,
	})


func _on_player_attack_landed(metadata: Dictionary) -> void:
	var presentation_data: Dictionary = metadata.duplicate(true)
	presentation_data["show_damage_number"] = true
	_combat_presentation.on_hit_event(presentation_data)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_hp(current_hp, max_hp)


func _on_player_died(_metadata: Dictionary) -> void:
	if _reset_pending:
		return
	_reset_pending = true
	_player.set_control_locked(true)
	if is_instance_valid(_enemy):
		_enemy.set_physics_process(false)
	await get_tree().create_timer(0.7).timeout
	if is_inside_tree():
		_reset_attempt()


func _reset_attempt() -> void:
	_remove_enemy_immediately()
	_safe_runway_crossed = false
	_enemy_active = false
	_enemy_defeated = false
	_exit_unlocked = false
	_transition_requested = false
	_player.respawn_at(PLAYER_SPAWN_POSITION, 1.0)
	_player.set_control_locked(false)
	_spawn_enemy()
	_reset_pending = false
	_sync_exit_gate()


func _remove_enemy_immediately() -> void:
	if not is_instance_valid(_enemy):
		_enemy = null
		return
	if _enemy.get_parent() != null:
		_enemy.get_parent().remove_child(_enemy)
	_enemy.free()
	_enemy = null


func _on_exit_area_body_entered(body: Node2D) -> void:
	if body == _player and _exit_unlocked:
		_request_main_handoff()


func _request_main_handoff() -> bool:
	if _transition_requested or not _is_valid_scene_manager(_scene_manager):
		return false
	if not bool(_scene_manager.call("has_scene", NEXT_SCENE_ID)):
		return false
	var accepted: bool = bool(
		_scene_manager.call("request_scene_change", NEXT_SCENE_ID, NEXT_SPAWN_POINT)
	)
	_transition_requested = accepted
	if accepted:
		_player.set_control_locked(true)
	return accepted


func _sync_exit_gate() -> void:
	_gate_blocker_shape.set_deferred("disabled", _exit_unlocked)
	_exit_gate.visible = _exit_unlocked
	_exit_gate.modulate = Color(1.0, 0.82, 0.42, 0.28)
	_exit_pulse.visible = _exit_unlocked


func _update_exit_pulse() -> void:
	if not _exit_pulse.visible:
		return
	var pulse_alpha: float = 0.12 + 0.1 * (0.5 + 0.5 * sin(_elapsed_sec * 5.0))
	_exit_pulse.modulate.a = pulse_alpha


func _get_enemy_sprite() -> AnimatedSprite2D:
	if not is_instance_valid(_enemy):
		return null
	return _enemy.get_node_or_null("Sprite") as AnimatedSprite2D


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and scene_manager.has_method("has_scene")
		and scene_manager.has_method("request_scene_change")
	)
