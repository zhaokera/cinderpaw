## Story151: Electro Bell T1-A purchase and single-slow pulse envelope.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const CAT_CLAW_T1A_SKILL_ID: StringName = &"cat_claw_t1a"
const CAT_CLAW_T1B_SKILL_ID: StringName = &"cat_claw_t1b"
const LONG_TAIL_T1A_SKILL_ID: StringName = &"long_tail_t1a"
const LONG_TAIL_T1B_SKILL_ID: StringName = &"long_tail_t1b"
const FISH_BONE_T1A_SKILL_ID: StringName = &"fish_bone_t1a"
const FISH_BONE_T1B_SKILL_ID: StringName = &"fish_bone_t1b"
const ELECTRO_BELL_T1A_SKILL_ID: StringName = &"electro_bell_t1a"
const ELECTRO_BELL_WEAPON_ID: StringName = &"electro_bell"
const ELECTRO_BELL_HITBOX_ID: StringName = &"electro_bell_light"
const BASE_SLOW_PERCENTAGE: float = 0.30
const BASE_SLOW_DURATION_SEC: float = 2.0
const PULSE_BONUS_PERCENTAGE: float = 0.15
const PULSE_TOTAL_PERCENTAGE: float = 0.45
const PULSE_DURATION_SEC: float = 0.5

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


func test_electro_bell_t1a_is_seventh_selectable_purchase_and_persists() -> void:
	var hud: Node = scene.get_node("HUD")
	scene.call("grant_skill_points", 2)
	scene.call("show_skill_tree_menu")

	var expected_order: Array[StringName] = [
		CAT_CLAW_T1A_SKILL_ID,
		CAT_CLAW_T1B_SKILL_ID,
		LONG_TAIL_T1A_SKILL_ID,
		LONG_TAIL_T1B_SKILL_ID,
		FISH_BONE_T1A_SKILL_ID,
		FISH_BONE_T1B_SKILL_ID,
		ELECTRO_BELL_T1A_SKILL_ID,
	]
	for index: int in range(expected_order.size()):
		assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
			String(expected_order[index])
		)
		if index < expected_order.size() - 1:
			assert_bool(bool(hud.call("select_next_skill_tree_entry"))).is_true()

	assert_str(String(hud.call("get_skill_unlock_button_text"))).is_equal("Learn Pulse Touch")
	assert_str(String(hud.call("get_menu_subtitle"))).contains("Electro Bell T1")
	assert_str(String(hud.call("get_menu_subtitle"))).contains("45%")
	assert_bool(bool(scene.call("try_unlock_skill", ELECTRO_BELL_T1A_SKILL_ID))).is_true()
	if not bool(scene.call("has_skill", ELECTRO_BELL_T1A_SKILL_ID)):
		return
	assert_bool(bool(scene.call("try_unlock_skill", ELECTRO_BELL_T1A_SKILL_ID))).is_false()
	assert_int(int(scene.call("get_skill_points"))).is_equal(1)

	var modifiers: Array = scene.call("get_skill_tree_modifiers", &"light_attack_1")
	var pulse_modifier: Dictionary = _find_modifier(modifiers, ELECTRO_BELL_T1A_SKILL_ID)
	assert_str(String(pulse_modifier.get("stat_key", ""))).is_equal("slow_percentage")
	assert_str(String(pulse_modifier.get("operation", ""))).is_equal("ADD")
	assert_float(float(pulse_modifier.get("value", 0.0))).is_equal_approx(
		PULSE_BONUS_PERCENTAGE,
		0.001
	)
	assert_float(float(pulse_modifier.get("duration_sec", 0.0))).is_equal_approx(
		PULSE_DURATION_SEC,
		0.001
	)

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var restored_scene: Node2D = MAIN_SCENE.instantiate() as Node2D
	add_child(restored_scene)
	restored_scene.call("restore_save_snapshot", snapshot)
	assert_bool(bool(restored_scene.call("has_skill", ELECTRO_BELL_T1A_SKILL_ID))).is_true()
	restored_scene.get_parent().remove_child(restored_scene)
	restored_scene.free()


func test_unlocked_first_light_hit_uses_one_45_to_30_percent_slow_envelope() -> void:
	var player: Node = scene.get_node("Player")
	var enemy: Node = scene.get_node("Enemy")
	var player_collision: CollisionComponent = player.call("get_collision_component")
	var enemy_collision: CollisionComponent = enemy.call("get_collision_component")
	var status: StatusEffectComponent = enemy.call("get_status_effect_component")
	var presentation: Node = scene.get_node("CombatPresentation")

	scene.call("grant_skill_points", 1)
	assert_bool(bool(scene.call("try_unlock_skill", ELECTRO_BELL_T1A_SKILL_ID))).is_true()
	if not bool(scene.call("has_skill", ELECTRO_BELL_T1A_SKILL_ID)):
		return
	scene.call("set_current_weapon_id", ELECTRO_BELL_WEAPON_ID)
	assert_bool(bool(player.call("request_attack"))).is_true()
	var hitbox: Area2D = player_collision.call("get_hitbox", ELECTRO_BELL_HITBOX_ID)
	var attack_metadata: Dictionary = hitbox.call("get_attack_metadata")
	var pulse_profile: Dictionary = Dictionary(
		Dictionary(attack_metadata.get("skill_modifiers", {})).get("slow_pulse", {})
	)
	assert_float(float(pulse_profile.get("bonus_percentage", 0.0))).is_equal_approx(
		PULSE_BONUS_PERCENTAGE,
		0.001
	)
	assert_float(float(pulse_profile.get("duration_sec", 0.0))).is_equal_approx(
		PULSE_DURATION_SEC,
		0.001
	)

	player_collision.call("process_detection_frame", {
		ELECTRO_BELL_HITBOX_ID: [enemy_collision.call("get_hurtbox")],
	})
	var hit_metadata: Dictionary = scene.call("get_last_player_hit_metadata")
	assert_bool(bool(hit_metadata.get("slow_pulse_applied", false))).is_true()
	assert_float(float(hit_metadata.get("slow_pulse_total_percentage", 0.0))).is_equal_approx(
		PULSE_TOTAL_PERCENTAGE,
		0.001
	)
	assert_int(status.get_active_effects().size()).is_equal(1)
	assert_float(status.get_movement_modifier()).is_equal_approx(0.55, 0.001)
	assert_float(status.get_remaining_duration(&"slow")).is_equal_approx(
		BASE_SLOW_DURATION_SEC,
		0.001
	)
	assert_int(int(presentation.call("get_weapon_vfx_snapshot", ELECTRO_BELL_WEAPON_ID).get(
		"count",
		0
	))).is_equal(9)

	status.advance_time(PULSE_DURATION_SEC)
	assert_float(status.get_movement_modifier()).is_equal_approx(0.70, 0.001)
	assert_float(status.get_remaining_duration(&"slow")).is_equal_approx(1.5, 0.001)
	status.advance_time(1.5)
	assert_bool(status.has_status(&"slow")).is_false()
	assert_float(status.get_movement_modifier()).is_equal_approx(1.0, 0.001)


func test_locked_first_hit_and_unlocked_second_hit_keep_baseline_without_pulse() -> void:
	var player: Node = scene.get_node("Player")
	var enemy: Node = scene.get_node("Enemy")
	var combat: CombatComponent = player.call("get_combat_component")
	var player_collision: CollisionComponent = player.call("get_collision_component")
	var enemy_collision: CollisionComponent = enemy.call("get_collision_component")
	var status: StatusEffectComponent = enemy.call("get_status_effect_component")
	var presentation: Node = scene.get_node("CombatPresentation")
	scene.call("set_current_weapon_id", ELECTRO_BELL_WEAPON_ID)

	assert_bool(bool(player.call("request_attack"))).is_true()
	var hitbox: Area2D = player_collision.call("get_hitbox", ELECTRO_BELL_HITBOX_ID)
	player_collision.call("process_detection_frame", {
		ELECTRO_BELL_HITBOX_ID: [enemy_collision.call("get_hurtbox")],
	})
	var locked_metadata: Dictionary = scene.call("get_last_player_hit_metadata")
	assert_bool(bool(locked_metadata.get("slow_pulse_applied", false))).is_false()
	assert_float(status.get_movement_modifier()).is_equal_approx(
		1.0 - BASE_SLOW_PERCENTAGE,
		0.001
	)
	assert_float(status.get_remaining_duration(&"slow")).is_equal_approx(
		BASE_SLOW_DURATION_SEC,
		0.001
	)
	assert_int(status.get_active_effects().size()).is_equal(1)
	assert_int(int(presentation.call("get_weapon_vfx_snapshot", ELECTRO_BELL_WEAPON_ID).get(
		"count",
		0
	))).is_equal(6)

	status.clear_all_effects()
	presentation.call("advance_time", 0.41)
	scene.call("grant_skill_points", 1)
	assert_bool(bool(scene.call("try_unlock_skill", ELECTRO_BELL_T1A_SKILL_ID))).is_true()
	if not bool(scene.call("has_skill", ELECTRO_BELL_T1A_SKILL_ID)):
		return
	combat.advance_attack_frames(4)
	assert_bool(bool(player.call("request_attack"))).is_true()
	var second_metadata: Dictionary = hitbox.call("get_attack_metadata")
	assert_int(int(second_metadata.get("combo_index", -1))).is_equal(1)
	assert_dict(Dictionary(
		Dictionary(second_metadata.get("skill_modifiers", {})).get("slow_pulse", {})
	)).is_empty()
	player_collision.call("process_detection_frame", {
		ELECTRO_BELL_HITBOX_ID: [enemy_collision.call("get_hurtbox")],
	})
	var second_hit_metadata: Dictionary = scene.call("get_last_player_hit_metadata")
	assert_bool(bool(second_hit_metadata.get("slow_pulse_applied", false))).is_false()
	assert_float(status.get_movement_modifier()).is_equal_approx(0.70, 0.001)
	assert_int(status.get_active_effects().size()).is_equal(1)
	assert_int(int(presentation.call("get_weapon_vfx_snapshot", ELECTRO_BELL_WEAPON_ID).get(
		"count",
		0
	))).is_equal(6)


func _find_modifier(modifiers: Array, skill_id: StringName) -> Dictionary:
	for raw_modifier: Variant in modifiers:
		if not raw_modifier is Dictionary:
			continue
		var modifier: Dictionary = raw_modifier as Dictionary
		if StringName(String(modifier.get("skill_id", ""))) == skill_id:
			return modifier
	return {}


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
			var positional_audio_player := child as AudioStreamPlayer2D
			positional_audio_player.stop()
			positional_audio_player.stream = null
