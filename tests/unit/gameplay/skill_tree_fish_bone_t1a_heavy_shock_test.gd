## Story150: Fish Bone T1-A purchase, persistence and heavy-hit micro-knockback.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const CAT_CLAW_T1A_SKILL_ID: StringName = &"cat_claw_t1a"
const CAT_CLAW_T1B_SKILL_ID: StringName = &"cat_claw_t1b"
const LONG_TAIL_T1A_SKILL_ID: StringName = &"long_tail_t1a"
const LONG_TAIL_T1B_SKILL_ID: StringName = &"long_tail_t1b"
const FISH_BONE_T1A_SKILL_ID: StringName = &"fish_bone_t1a"
const FISH_BONE_WEAPON_ID: StringName = &"fish_bone"
const FISH_BONE_HEAVY_HITBOX_ID: StringName = &"fish_bone_heavy"
const HEAVY_ATTACK_ACTION: StringName = &"heavy_attack"
const RAT_KING_BOSS_ID: StringName = &"boss_01_rat_king"
const RAT_MINION_SUMMON_ID: StringName = &"summon_minion"
const KNOCKBACK_DISTANCE_PX: float = 8.0
const MIN_CHARGE_SEC: float = 0.5
const TARGET_TEST_HP: int = 100

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	_stop_runtime_audio_players()
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_fish_bone_t1a_is_fifth_selectable_purchase_and_persists() -> void:
	var hud: Node = scene.get_node("HUD")
	scene.call("grant_skill_points", 2)
	scene.call("show_skill_tree_menu")

	assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
		String(CAT_CLAW_T1A_SKILL_ID)
	)
	assert_bool(bool(hud.call("select_next_skill_tree_entry"))).is_true()
	assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
		String(CAT_CLAW_T1B_SKILL_ID)
	)
	assert_bool(bool(hud.call("select_next_skill_tree_entry"))).is_true()
	assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
		String(LONG_TAIL_T1A_SKILL_ID)
	)
	assert_bool(bool(hud.call("select_next_skill_tree_entry"))).is_true()
	assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
		String(LONG_TAIL_T1B_SKILL_ID)
	)
	assert_bool(bool(hud.call("select_next_skill_tree_entry"))).is_true()
	assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
		String(FISH_BONE_T1A_SKILL_ID)
	)
	assert_str(String(hud.call("get_skill_unlock_button_text"))).is_equal("Learn Heavy Shock")
	assert_str(String(hud.call("get_menu_subtitle"))).contains("Fish Bone T1")
	assert_str(String(hud.call("get_menu_subtitle"))).contains("back by 8px")

	assert_bool(bool(scene.call("try_unlock_skill", FISH_BONE_T1A_SKILL_ID))).is_true()
	if not bool(scene.call("has_skill", FISH_BONE_T1A_SKILL_ID)):
		return
	assert_bool(bool(scene.call("try_unlock_skill", FISH_BONE_T1A_SKILL_ID))).is_false()
	assert_int(int(scene.call("get_skill_points"))).is_equal(1)
	var modifiers: Array = scene.call("get_skill_tree_modifiers", HEAVY_ATTACK_ACTION)
	assert_int(modifiers.size()).is_equal(1)
	if modifiers.is_empty():
		return
	assert_str(String(Dictionary(modifiers[0]).get("stat_key", ""))).is_equal(
		"knockback_distance"
	)
	assert_float(float(Dictionary(modifiers[0]).get("value", 0.0))).is_equal_approx(
		KNOCKBACK_DISTANCE_PX,
		0.001
	)

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var restored_scene: Node2D = MAIN_SCENE.instantiate() as Node2D
	add_child(restored_scene)
	restored_scene.call("restore_save_snapshot", snapshot)
	assert_bool(bool(restored_scene.call("has_skill", FISH_BONE_T1A_SKILL_ID))).is_true()
	assert_bool(bool(restored_scene.call("has_skill", CAT_CLAW_T1A_SKILL_ID))).is_false()
	assert_bool(bool(restored_scene.call("has_skill", LONG_TAIL_T1A_SKILL_ID))).is_false()
	restored_scene.get_parent().remove_child(restored_scene)
	restored_scene.free()


func test_unlocked_fish_bone_heavy_moves_target_once_and_reuses_contact_wave() -> void:
	var player: Node = scene.get_node("Player")
	var enemy: CharacterBody2D = _spawn_live_rat_minion()
	assert_object(enemy).is_not_null()
	if enemy == null:
		return
	var player_collision: CollisionComponent = player.call("get_collision_component")
	var enemy_collision: CollisionComponent = enemy.call("get_collision_component")
	var presentation: Node = scene.get_node("CombatPresentation")

	scene.call("grant_skill_points", 1)
	assert_bool(bool(scene.call("try_unlock_skill", FISH_BONE_T1A_SKILL_ID))).is_true()
	scene.call("set_current_weapon_id", FISH_BONE_WEAPON_ID)
	var start_x: float = enemy.global_position.x

	assert_bool(bool(player.call("request_heavy_attack_press"))).is_true()
	player.call("advance_heavy_charge_time", MIN_CHARGE_SEC)
	assert_bool(bool(player.call("request_heavy_attack_release"))).is_true()
	var hitbox: Area2D = player_collision.call("get_hitbox", FISH_BONE_HEAVY_HITBOX_ID)
	var attack_metadata: Dictionary = hitbox.call("get_attack_metadata")
	assert_float(float(attack_metadata.get("skill_knockback_px", 0.0))).is_equal_approx(
		KNOCKBACK_DISTANCE_PX,
		0.001
	)
	assert_float(float(attack_metadata.get("knockback_direction", 0.0))).is_equal_approx(
		1.0,
		0.001
	)
	assert_int(int(presentation.call("get_weapon_vfx_snapshot", FISH_BONE_WEAPON_ID).get(
		"count",
		0
	))).is_equal(1)

	var overlaps: Dictionary = {
		FISH_BONE_HEAVY_HITBOX_ID: [enemy_collision.call("get_hurtbox")],
	}
	player_collision.call("process_detection_frame", overlaps)
	assert_float(enemy.global_position.x - start_x).is_equal_approx(KNOCKBACK_DISTANCE_PX, 0.001)
	var hit_metadata: Dictionary = scene.call("get_last_player_hit_metadata")
	assert_bool(bool(hit_metadata.get("knockback_attempted", false))).is_true()
	assert_bool(bool(hit_metadata.get("knockback_applied", false))).is_true()
	assert_float(float(hit_metadata.get("knockback_requested_px", 0.0))).is_equal_approx(
		KNOCKBACK_DISTANCE_PX,
		0.001
	)
	assert_float(float(hit_metadata.get("knockback_applied_px", 0.0))).is_equal_approx(
		KNOCKBACK_DISTANCE_PX,
		0.001
	)
	assert_bool(bool(hit_metadata.get("knockback_blocked", true))).is_false()
	assert_int(int(enemy.call("get_current_hp"))).is_greater(0)
	assert_int(int(presentation.call("get_weapon_vfx_snapshot", FISH_BONE_WEAPON_ID).get(
		"count",
		0
	))).is_equal(2)

	player_collision.call("process_detection_frame", overlaps)
	assert_float(enemy.global_position.x - start_x).is_equal_approx(KNOCKBACK_DISTANCE_PX, 0.001)


func test_locked_fish_bone_heavy_does_not_move_target_or_spawn_contact_wave() -> void:
	var player: Node = scene.get_node("Player")
	var enemy: CharacterBody2D = _spawn_live_rat_minion()
	assert_object(enemy).is_not_null()
	if enemy == null:
		return
	var player_collision: CollisionComponent = player.call("get_collision_component")
	var enemy_collision: CollisionComponent = enemy.call("get_collision_component")
	var presentation: Node = scene.get_node("CombatPresentation")
	scene.call("set_current_weapon_id", FISH_BONE_WEAPON_ID)
	var start_x: float = enemy.global_position.x

	assert_bool(bool(player.call("request_heavy_attack_press"))).is_true()
	player.call("advance_heavy_charge_time", MIN_CHARGE_SEC)
	assert_bool(bool(player.call("request_heavy_attack_release"))).is_true()
	var hitbox: Area2D = player_collision.call("get_hitbox", FISH_BONE_HEAVY_HITBOX_ID)
	var attack_metadata: Dictionary = hitbox.call("get_attack_metadata")
	assert_float(float(attack_metadata.get("skill_knockback_px", 0.0))).is_equal_approx(0.0, 0.001)

	player_collision.call("process_detection_frame", {
		FISH_BONE_HEAVY_HITBOX_ID: [enemy_collision.call("get_hurtbox")],
	})
	assert_float(enemy.global_position.x - start_x).is_equal_approx(0.0, 0.001)
	var hit_metadata: Dictionary = scene.call("get_last_player_hit_metadata")
	assert_bool(bool(hit_metadata.get("knockback_attempted", false))).is_false()
	assert_int(int(presentation.call("get_weapon_vfx_snapshot", FISH_BONE_WEAPON_ID).get(
		"count",
		0
	))).is_equal(1)


func test_target_collision_clips_wall_knockback_and_preserves_direction() -> void:
	var enemy: CharacterBody2D = _spawn_live_rat_minion()
	assert_object(enemy).is_not_null()
	if enemy == null:
		return
	enemy.set_physics_process(false)
	var enemy_collision: CollisionComponent = enemy.call("get_collision_component")

	enemy.global_position.x = 1224.0
	var blocked_result: Dictionary = enemy_collision.apply_horizontal_knockback(
		KNOCKBACK_DISTANCE_PX,
		1.0
	)
	assert_bool(bool(blocked_result.get("knockback_attempted", false))).is_true()
	assert_bool(bool(blocked_result.get("knockback_applied", false))).is_true()
	assert_bool(bool(blocked_result.get("knockback_blocked", false))).is_true()
	assert_float(float(blocked_result.get("knockback_applied_px", 0.0))).is_greater(0.0)
	assert_float(float(blocked_result.get("knockback_applied_px", 0.0))).is_less(
		KNOCKBACK_DISTANCE_PX
	)

	enemy.global_position.x = 1000.0
	var open_result: Dictionary = enemy_collision.apply_horizontal_knockback(
		KNOCKBACK_DISTANCE_PX,
		-1.0
	)
	assert_float(float(open_result.get("knockback_direction", 0.0))).is_equal_approx(-1.0, 0.001)
	assert_float(float(open_result.get("knockback_applied_px", 0.0))).is_equal_approx(
		KNOCKBACK_DISTANCE_PX,
		0.001
	)
	assert_bool(bool(open_result.get("knockback_blocked", true))).is_false()


func _spawn_live_rat_minion() -> CharacterBody2D:
	if not bool(scene.call("request_summon", RAT_KING_BOSS_ID, RAT_MINION_SUMMON_ID)):
		return null
	var minions: Array = scene.call("get_summoned_minion_nodes")
	if minions.size() != 1:
		return null
	var minion: CharacterBody2D = minions[0] as CharacterBody2D
	if minion == null:
		return null
	var health: HealthComponent = minion.get_node_or_null("HealthComponent") as HealthComponent
	if health == null:
		return null
	health.configure(
		int(minion.call("get_entity_id")),
		TARGET_TEST_HP,
		TARGET_TEST_HP,
		0,
		0,
		false
	)
	return minion


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		elif child is AudioStreamPlayer2D:
			var audio_player := child as AudioStreamPlayer2D
			audio_player.stop()
			audio_player.stream = null
