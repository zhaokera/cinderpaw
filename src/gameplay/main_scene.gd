## Main playable scene wiring for the current vertical slice.
extends Node2D

@onready var _player: PlayerController = $Player
@onready var _enemy: SimpleEnemy = $Enemy
@onready var _hud = $HUD
@onready var _combat_presentation = $CombatPresentation
@onready var _game_flow = $GameFlowController

var _pause_menu_active: bool = false


func _ready() -> void:
	_game_flow.start_encounter(_player.global_position)
	_game_flow.respawn_requested.connect(_on_respawn_requested)
	_game_flow.victory_reached.connect(_on_victory_reached)
	_hud.menu_pause_requested.connect(_on_menu_pause_requested)
	_hud.menu_resume_requested.connect(_on_menu_resume_requested)
	_hud.menu_retry_requested.connect(_on_menu_retry_requested)
	_player.player_health_changed.connect(_on_player_health_changed)
	_player.player_died.connect(_on_player_died)
	_player.attack_landed.connect(_on_player_attack_landed)
	_enemy.enemy_health_changed.connect(_on_enemy_health_changed)
	_enemy.enemy_defeated.connect(_on_enemy_defeated)
	_combat_presentation.set_camera($Player/Camera2D)

	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.update_boss_hp(_enemy.get_current_hp(), _enemy.get_max_hp(), 1, "Shadow Beast")
	_hud.show_notification("Hunt the shadow beast", 2.0)


func _process(_delta: float) -> void:
	_player.set_control_locked(_game_flow.is_player_control_locked())


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_hp(current_hp, max_hp)


func _on_player_died() -> void:
	_game_flow.handle_player_death()
	_hud.show_notification("Cinderpaw falls - reviving", 1.5)


func _on_player_attack_landed(hit_data: Dictionary) -> void:
	_combat_presentation.on_hit_event(hit_data)


func _on_enemy_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_boss_hp(current_hp, max_hp, 1, "Shadow Beast")


func _on_enemy_defeated() -> void:
	_combat_presentation.on_kill_event(2, _enemy.global_position + Vector2(0, -24))
	_game_flow.handle_enemy_defeated()


func _on_respawn_requested(respawn_position: Vector2, revive_hp_percentage: float) -> void:
	_player.respawn_at(respawn_position, revive_hp_percentage)
	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.show_notification("Nine lives remain", 2.0)


func _on_victory_reached() -> void:
	_hud.hide_boss_hp()
	_hud.update_currency(25)
	_hud.show_notification("Shadow beast defeated", 3.0)
	_hud.show_retry_menu("Shadow beast defeated", "Retry the encounter or stay with your prize.")


func _on_menu_pause_requested() -> void:
	if _game_flow.get_flow_state() == &"victory":
		return
	_pause_menu_active = true
	get_tree().paused = true
	_hud.show_pause_menu()


func _on_menu_resume_requested() -> void:
	if _pause_menu_active:
		get_tree().paused = false
	_pause_menu_active = false
	_hud.hide_menu()


func _on_menu_retry_requested() -> void:
	_pause_menu_active = false
	get_tree().paused = false
	get_tree().reload_current_scene()
