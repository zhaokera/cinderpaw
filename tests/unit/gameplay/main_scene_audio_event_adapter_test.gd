## MainScene runtime wiring for gameplay audio event adapters.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ENEMY_HITBOX_ID: StringName = &"rat_king_claw"
const ATTACK_TELL_FRAMES: int = 8

var scene: Node2D


class FakeAudioSystem:
	extends RefCounted

	var load_started_calls: Array[Dictionary] = []
	var changed_calls: Array[Dictionary] = []
	var failed_calls: Array[Dictionary] = []
	var hit_events: Array[Dictionary] = []
	var damage_taken_events: Array[Dictionary] = []
	var dodge_events: Array[Dictionary] = []
	var parry_events: Array[Dictionary] = []
	var double_jump_events: Array[Dictionary] = []
	var focus_events: Array[Dictionary] = []
	var enemy_defeated_events: Array[Dictionary] = []
	var boss_phase_events: Array[Dictionary] = []
	var boss_encounter_started_events: Array[Dictionary] = []
	var boss_encounter_ended_events: Array[Dictionary] = []
	var weapon_attack_events: Array[Dictionary] = []
	var menu_opened_events: Array[Dictionary] = []
	var menu_closed_events: Array[Dictionary] = []
	var ui_save_events: Array[Dictionary] = []
	var ui_load_events: Array[Dictionary] = []

	func on_scene_load_started(
		scene_id: StringName,
		spawn_point: StringName,
		metadata: Dictionary
	) -> void:
		load_started_calls.append({
			"scene_id": scene_id,
			"spawn_point": spawn_point,
			"metadata": metadata.duplicate(true),
		})

	func on_scene_changed(old_scene: StringName, new_scene: StringName) -> void:
		changed_calls.append({
			"old_scene": old_scene,
			"new_scene": new_scene,
		})

	func on_scene_load_failed(scene_id: StringName, reason: StringName) -> void:
		failed_calls.append({
			"scene_id": scene_id,
			"reason": reason,
		})

	func on_hit_event(hit_data: Dictionary) -> bool:
		hit_events.append(hit_data.duplicate(true))
		return false

	func on_damage_taken_event(damage_data: Dictionary) -> bool:
		damage_taken_events.append(damage_data.duplicate(true))
		return false

	func on_dodge_event(_texture: Texture2D, world_position: Vector2, facing: float) -> bool:
		dodge_events.append({
			"position": world_position,
			"facing": facing,
		})
		return false

	func on_double_jump_event(_texture: Texture2D, world_position: Vector2, facing: float) -> bool:
		double_jump_events.append({
			"position": world_position,
			"facing": facing,
		})
		return false

	func on_parry_event(parry_data: Dictionary) -> bool:
		parry_events.append(parry_data.duplicate(true))
		return true

	func on_focus_mode_changed(entity_id: int, active: bool, metadata: Dictionary) -> bool:
		focus_events.append({
			"entity_id": entity_id,
			"active": active,
			"metadata": metadata.duplicate(true),
		})
		return false

	func on_enemy_defeated(metadata: Dictionary = {}) -> bool:
		enemy_defeated_events.append(metadata.duplicate(true))
		return false

	func on_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary) -> bool:
		boss_phase_events.append({
			"entity_id": entity_id,
			"phase": phase,
			"metadata": metadata.duplicate(true),
		})
		return false

	func on_boss_encounter_started(boss_id: StringName, metadata: Dictionary) -> bool:
		boss_encounter_started_events.append({
			"boss_id": boss_id,
			"metadata": metadata.duplicate(true),
		})
		return false

	func on_boss_encounter_ended(boss_id: StringName, metadata: Dictionary) -> void:
		boss_encounter_ended_events.append({
			"boss_id": boss_id,
			"metadata": metadata.duplicate(true),
		})

	func on_weapon_attack_event(attack_data: Dictionary) -> bool:
		weapon_attack_events.append(attack_data.duplicate(true))
		return false

	func on_menu_opened(metadata: Dictionary = {}) -> bool:
		menu_opened_events.append(metadata.duplicate(true))
		return true

	func on_menu_closed(metadata: Dictionary = {}) -> bool:
		menu_closed_events.append(metadata.duplicate(true))
		return true

	func on_ui_save(metadata: Dictionary = {}) -> bool:
		ui_save_events.append(metadata.duplicate(true))
		return true

	func on_ui_load(metadata: Dictionary = {}) -> bool:
		ui_load_events.append(metadata.duplicate(true))
		return true


class ImmediateMenuSaveSystem:
	extends Node

	var manual_save_calls: int = 0
	var load_game_calls: int = 0

	func register_serializable(_system: Object, _save_key: StringName) -> bool:
		return true

	func unregister_serializable(_save_key: StringName) -> bool:
		return true

	func manual_save(_slot: int, _player_state: Dictionary = {}, _world_state: Dictionary = {}, _settings: Dictionary = {}) -> bool:
		manual_save_calls += 1
		return true

	func load_game(_slot: int) -> bool:
		load_game_calls += 1
		return true

	func get_last_loaded_data() -> Dictionary:
		return {
			"player_state": {},
			"world_state": {},
			"settings": {},
		}


class FakeSceneOnlyAudioSystem:
	extends RefCounted

	var load_started_calls: Array[Dictionary] = []

	func on_scene_load_started(
		scene_id: StringName,
		spawn_point: StringName,
		metadata: Dictionary
	) -> void:
		load_started_calls.append({
			"scene_id": scene_id,
			"spawn_point": spawn_point,
			"metadata": metadata.duplicate(true),
		})


class FakeStalePendingSceneManager:
	extends RefCounted

	var request_scene_change_calls: int = 0

	func get_current_scene() -> StringName:
		return &"area_03_factory"

	func is_loading() -> bool:
		return true

	func get_pending_scene() -> StringName:
		return &"area_02_sewer"

	func has_scene(_scene_id: StringName) -> bool:
		return true

	func is_scene_locked() -> bool:
		return false

	func request_scene_change(_scene_id: StringName, _spawn_point: StringName) -> bool:
		request_scene_change_calls += 1
		return false

	func get_scene_config(_scene_id: StringName) -> Dictionary:
		return {
			"default_spawn": "main_spawn",
		}


class FakeBossPhaseSource:
	extends RefCounted

	signal on_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary)

	func emit_phase() -> void:
		on_boss_phase_transition_started.emit(2, 3, {
			"display_name": "垃圾桶鼠王",
			"world_position": Vector2(320, 360),
		})


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_player_attack_and_weapon_start_events_route_to_audio_system() -> void:
	var audio_system: FakeAudioSystem = _configure_fake_audio_system()
	var player: Node = scene.get_node("Player")
	var enemy: Node = scene.get_node("Enemy")
	var player_collision: CollisionComponent = player.call("get_collision_component") as CollisionComponent
	var enemy_collision: CollisionComponent = enemy.call("get_collision_component") as CollisionComponent

	assert_bool(bool(player.call("request_attack"))).is_true()
	assert_int(audio_system.weapon_attack_events.size()).is_equal(1)
	if audio_system.weapon_attack_events.size() != 1:
		return
	assert_str(String(audio_system.weapon_attack_events[0].get("weapon_id", &""))).is_equal("cat_claw")

	player_collision.process_detection_frame({
		&"cat_claw_light": [enemy_collision.get_hurtbox()],
	})

	assert_int(audio_system.hit_events.size()).is_equal(1)
	if audio_system.hit_events.size() != 1:
		return
	var hit_event: Dictionary = audio_system.hit_events[0]
	assert_str(String(hit_event.get("weapon_id", &""))).is_equal("cat_claw")
	assert_bool(int(hit_event.get("final_damage", 0)) > 0).is_true()
	assert_bool(hit_event.has("hit_position")).is_true()


func test_enemy_damage_and_player_dodge_events_route_to_audio_system() -> void:
	var audio_system: FakeAudioSystem = _configure_fake_audio_system()
	var player: Node = scene.get_node("Player")
	var enemy: Node = scene.get_node("Enemy")

	_land_enemy_attack(enemy, player)

	assert_int(audio_system.damage_taken_events.size()).is_equal(1)
	if audio_system.damage_taken_events.size() != 1:
		return
	var damage_event: Dictionary = audio_system.damage_taken_events[0]
	assert_int(int(damage_event.get("damage", 0))).is_equal(12)
	assert_str(String(damage_event.get("source", &""))).is_equal("rat_king_claw")
	assert_bool(damage_event.has("hit_position")).is_true()

	assert_bool(bool(player.call("request_dodge"))).is_true()
	assert_int(audio_system.dodge_events.size()).is_equal(1)
	if audio_system.dodge_events.size() != 1:
		return
	assert_vector(audio_system.dodge_events[0].get("position", Vector2.ZERO)).is_equal(
		player.get_node("Sprite").global_position
	)


func test_focus_enemy_defeat_and_boss_phase_events_route_to_audio_system() -> void:
	var audio_system: FakeAudioSystem = _configure_fake_audio_system()
	var player: Node = scene.get_node("Player")
	var health: Node = player.get_node("HealthComponent")
	var focus_signal: Signal = health.get("on_focus_mode_changed")

	focus_signal.emit(1, true, {
		"hp_percentage": 0.25,
	})

	assert_int(audio_system.focus_events.size()).is_equal(1)
	if audio_system.focus_events.size() != 1:
		return
	assert_bool(bool(audio_system.focus_events[0].get("active", false))).is_true()

	scene.call("_on_enemy_defeated")

	assert_int(audio_system.enemy_defeated_events.size()).is_equal(1)
	if audio_system.enemy_defeated_events.size() != 1:
		return
	assert_bool(audio_system.enemy_defeated_events[0].has("position")).is_true()

	var phase_source := FakeBossPhaseSource.new()
	assert_bool(bool(scene.call("register_boss_phase_transition_source", phase_source))).is_true()
	phase_source.emit_phase()

	assert_int(audio_system.boss_phase_events.size()).is_equal(1)
	if audio_system.boss_phase_events.size() != 1:
		return
	assert_int(int(audio_system.boss_phase_events[0].get("phase", 0))).is_equal(3)
	assert_vector(Dictionary(audio_system.boss_phase_events[0].get("metadata", {})).get(
		"world_position",
		Vector2.ZERO
	)).is_equal(Vector2(320, 360))


func test_rat_king_boss_music_start_and_end_events_route_to_audio_system() -> void:
	var audio_system: FakeAudioSystem = _configure_fake_audio_system()

	assert_int(audio_system.boss_encounter_started_events.size()).is_equal(1)
	if audio_system.boss_encounter_started_events.size() != 1:
		return
	var start_event: Dictionary = audio_system.boss_encounter_started_events[0]
	assert_str(String(start_event.get("boss_id", &""))).is_equal("boss_01_rat_king")
	var start_metadata: Dictionary = Dictionary(start_event.get("metadata", {}))
	assert_int(int(start_metadata.get("phase", 0))).is_equal(1)
	assert_str(String(start_metadata.get("display_name", ""))).is_equal("垃圾桶鼠王")
	assert_bool(start_metadata.has("world_position")).is_true()

	scene.call("_on_enemy_defeated")

	assert_int(audio_system.boss_encounter_ended_events.size()).is_equal(1)
	if audio_system.boss_encounter_ended_events.size() != 1:
		return
	var end_event: Dictionary = audio_system.boss_encounter_ended_events[0]
	assert_str(String(end_event.get("boss_id", &""))).is_equal("boss_01_rat_king")
	var end_metadata: Dictionary = Dictionary(end_event.get("metadata", {}))
	assert_str(String(end_metadata.get("reason", &""))).is_equal("defeated")


func test_menu_open_close_save_and_load_route_to_audio_system() -> void:
	var audio_system: FakeAudioSystem = _configure_fake_audio_system()
	var hud: Node = scene.get_node("HUD")

	hud.emit_signal("menu_pause_requested")

	assert_int(audio_system.menu_opened_events.size()).is_equal(1)
	if audio_system.menu_opened_events.size() != 1:
		return
	assert_str(String(audio_system.menu_opened_events[0].get("menu_mode", &""))).is_equal("pause")

	hud.emit_signal("menu_resume_requested")

	assert_int(audio_system.menu_closed_events.size()).is_equal(1)
	if audio_system.menu_closed_events.size() != 1:
		return
	assert_str(String(audio_system.menu_closed_events[0].get("reason", &""))).is_equal("resume")

	var save_system := ImmediateMenuSaveSystem.new()
	add_child(save_system)
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()

	hud.emit_signal("menu_save_slot_requested", 1)
	assert_int(save_system.manual_save_calls).is_equal(1)
	assert_int(audio_system.ui_save_events.size()).is_equal(1)
	if audio_system.ui_save_events.size() != 1:
		save_system.queue_free()
		return
	assert_int(int(audio_system.ui_save_events[0].get("slot", 0))).is_equal(1)

	hud.emit_signal("menu_load_slot_requested", 1)
	assert_int(save_system.load_game_calls).is_equal(1)
	assert_int(audio_system.ui_load_events.size()).is_equal(1)
	if audio_system.ui_load_events.size() != 1:
		save_system.queue_free()
		return
	assert_int(int(audio_system.ui_load_events[0].get("slot", 0))).is_equal(1)

	save_system.queue_free()


func test_menu_load_main_snapshot_routes_audio_despite_stale_pending_scene_manager() -> void:
	var audio_system: FakeAudioSystem = _configure_fake_audio_system()
	var save_system := ImmediateMenuSaveSystem.new()
	var scene_manager := FakeStalePendingSceneManager.new()
	add_child(save_system)
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()

	var hud: Node = scene.get_node("HUD")
	hud.emit_signal("menu_load_slot_requested", 1)

	assert_int(save_system.load_game_calls).is_equal(1)
	assert_int(scene_manager.request_scene_change_calls).is_equal(0)
	assert_int(audio_system.ui_load_events.size()).is_equal(1)
	if audio_system.ui_load_events.size() != 1:
		save_system.queue_free()
		return
	assert_int(int(audio_system.ui_load_events[0].get("slot", 0))).is_equal(1)
	save_system.queue_free()


func test_incomplete_audio_system_does_not_block_existing_gameplay_presentation() -> void:
	var audio_system := FakeSceneOnlyAudioSystem.new()
	assert_bool(bool(scene.call("configure_audio_system_runtime", audio_system))).is_true()
	var player: Node = scene.get_node("Player")
	var combat_presentation: Node = scene.get_node("CombatPresentation")

	scene.call("_on_enemy_attack_landed", 12, Vector2(96, 120), false)

	assert_int(int(combat_presentation.call("get_active_damage_number_count"))).is_equal(1)
	assert_int(int(combat_presentation.call("get_active_spark_count"))).is_between(5, 8)

	assert_bool(bool(player.call("request_dodge"))).is_true()
	assert_int(int(combat_presentation.call("get_active_afterimage_count"))).is_equal(3)


func test_player_double_jump_event_routes_to_presentation_and_audio_system() -> void:
	var audio_system: FakeAudioSystem = _configure_fake_audio_system()
	var player: Node = scene.get_node("Player")
	var combat_presentation: Node = scene.get_node("CombatPresentation")

	assert_bool(combat_presentation.has_method("get_active_double_jump_vfx_count")).is_true()
	if not combat_presentation.has_method("get_active_double_jump_vfx_count"):
		return

	scene.call("unlock_ability", &"double_jump")
	assert_bool(bool(player.call("has_ability", &"double_jump"))).is_true()
	player.call("set_airborne", true)
	assert_bool(bool(player.call("request_double_jump"))).is_true()

	assert_int(int(combat_presentation.call("get_active_double_jump_vfx_count"))).is_equal(3)
	assert_int(audio_system.double_jump_events.size()).is_equal(1)
	if audio_system.double_jump_events.size() != 1:
		return
	assert_vector(audio_system.double_jump_events[0].get("position", Vector2.ZERO)).is_equal(
		player.get_node("Sprite").global_position
	)


func test_player_perfect_parry_resolve_routes_to_presentation_and_audio_system() -> void:
	var audio_system: FakeAudioSystem = _configure_fake_audio_system()
	var player: Node = scene.get_node("Player")
	var combat: CombatComponent = player.call("get_combat_component") as CombatComponent
	var combat_presentation: Node = scene.get_node("CombatPresentation")

	assert_that(combat).is_not_null()
	assert_bool(combat_presentation.has_method("get_active_flash_count")).is_true()
	assert_bool(combat_presentation.has_method("get_active_parry_spark_count")).is_true()
	if (
		combat == null
		or not combat_presentation.has_method("get_active_flash_count")
		or not combat_presentation.has_method("get_active_parry_spark_count")
	):
		return

	assert_bool(bool(player.call("request_parry"))).is_true()
	var metadata: Dictionary = combat.resolve_parry_result()

	assert_bool(bool(metadata.get("is_success", false))).is_true()
	assert_str(String(metadata.get("parry_type", &""))).is_equal("perfect")
	assert_int(int(combat_presentation.call("get_active_flash_count"))).is_equal(1)
	assert_int(int(combat_presentation.call("get_active_parry_spark_count"))).is_between(20, 25)
	assert_int(audio_system.parry_events.size()).is_equal(1)
	if audio_system.parry_events.size() != 1:
		return
	var event: Dictionary = audio_system.parry_events[0]
	assert_str(String(event.get("parry_type", &""))).is_equal("perfect")
	assert_bool(bool(event.get("is_success", false))).is_true()
	assert_vector(event.get("position", Vector2.ZERO)).is_equal(
		player.get_node("Sprite").global_position
	)
	assert_str(String(event.get("source", &""))).is_equal("player_parry")


func test_player_good_parry_resolve_routes_without_perfect_visual_burst() -> void:
	var audio_system: FakeAudioSystem = _configure_fake_audio_system()
	var player: Node = scene.get_node("Player")
	var combat: CombatComponent = player.call("get_combat_component") as CombatComponent
	var combat_presentation: Node = scene.get_node("CombatPresentation")

	assert_that(combat).is_not_null()
	assert_bool(combat_presentation.has_method("get_active_flash_count")).is_true()
	assert_bool(combat_presentation.has_method("get_active_parry_spark_count")).is_true()
	if (
		combat == null
		or not combat_presentation.has_method("get_active_flash_count")
		or not combat_presentation.has_method("get_active_parry_spark_count")
	):
		return

	assert_bool(bool(player.call("request_parry"))).is_true()
	combat.advance_parry_frames(7)
	var good_metadata: Dictionary = combat.resolve_parry_result()

	assert_bool(bool(good_metadata.get("is_success", false))).is_true()
	assert_str(String(good_metadata.get("parry_type", &""))).is_equal("good")
	assert_int(int(combat_presentation.call("get_active_flash_count"))).is_equal(0)
	assert_int(int(combat_presentation.call("get_active_parry_spark_count"))).is_equal(0)
	assert_int(audio_system.parry_events.size()).is_equal(1)
	assert_str(String(audio_system.parry_events[0].get("parry_type", &""))).is_equal("good")
	assert_vector(audio_system.parry_events[0].get("position", Vector2.ZERO)).is_equal(
		player.get_node("Sprite").global_position
	)


func _configure_fake_audio_system() -> FakeAudioSystem:
	var audio_system := FakeAudioSystem.new()
	assert_bool(bool(scene.call("configure_audio_system_runtime", audio_system))).is_true()
	return audio_system


func _land_enemy_attack(enemy: Node, player: Node) -> void:
	var attack_started: bool = false
	if enemy.has_method("request_attack_pattern"):
		attack_started = bool(enemy.call("request_attack_pattern", &"claw_swipe"))
	else:
		attack_started = bool(enemy.call("request_attack"))
	assert_bool(attack_started).is_true()
	enemy.call("advance_attack_frames", _enemy_startup_frames(enemy))
	var enemy_collision: CollisionComponent = enemy.call("get_collision_component") as CollisionComponent
	var player_collision: CollisionComponent = player.call("get_collision_component") as CollisionComponent
	enemy_collision.process_detection_frame({
		ENEMY_HITBOX_ID: [player_collision.get_hurtbox()],
	})


func _enemy_startup_frames(enemy: Node) -> int:
	if enemy.has_method("get_current_attack_startup_frames"):
		return int(enemy.call("get_current_attack_startup_frames"))
	return ATTACK_TELL_FRAMES
