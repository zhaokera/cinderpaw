## Story 167: Cinderpaw light hitboxes follow authored combo contact frames.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const STAGE_TIMINGS: Array[Dictionary] = [
	{"startup_frames": 4, "active_frames": 4},
	{"startup_frames": 6, "active_frames": 6},
	{"startup_frames": 10, "active_frames": 10},
]

var scene: Node
var player: PlayerController
var combat: CombatComponent
var collision: CollisionComponent
var enemy: Node
var enemy_collision: CollisionComponent


func before_test() -> void:
	Input.action_release(&"attack")
	scene = MAIN_SCENE.instantiate()
	add_child(scene)
	player = scene.get_node("Player") as PlayerController
	combat = player.get_combat_component()
	collision = player.get_collision_component()
	enemy = scene.get_node("Enemy")
	enemy_collision = enemy.get_collision_component() as CollisionComponent


func after_test() -> void:
	Input.action_release(&"attack")
	_stop_runtime_audio_players()
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null
	player = null
	combat = null
	collision = null
	enemy = null
	enemy_collision = null


func test_three_stage_combo_activates_only_during_each_authored_contact_window() -> void:
	assert_bool(player.request_attack()).is_true()

	for stage: int in range(STAGE_TIMINGS.size()):
		var timing: Dictionary = STAGE_TIMINGS[stage]
		var startup_frames: int = int(timing["startup_frames"])
		var active_frames: int = int(timing["active_frames"])

		assert_int(combat.get_combo_index()).is_equal(stage)
		assert_int(combat.get_attack_frame()).is_equal(0)
		assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_false()

		assert_bool(await _wait_for_attack_frame(startup_frames - 1)).is_true()
		assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_false()
		assert_int(player.get_node("Sprite").frame).is_equal(0)

		assert_bool(await _wait_for_attack_frame(startup_frames)).is_true()
		assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_true()
		assert_int(player.get_node("Sprite").frame).is_equal(1)
		assert_int(int(
			collision.get_hitbox(LIGHT_HITBOX_ID).get_attack_metadata().get(
				"combo_index",
				-1
			)
		)).is_equal(stage)

		var diagnostics: Dictionary = player.get_light_combo_diagnostics()
		assert_bool(bool(diagnostics.get("hitbox_active", false))).is_true()
		assert_bool(bool(diagnostics.get("hitbox_pending", true))).is_false()
		assert_int(int(diagnostics.get("hitbox_active_start_frame", -1))).is_equal(
			startup_frames
		)
		assert_int(int(diagnostics.get("hitbox_active_frames", -1))).is_equal(
			active_frames
		)

		if stage < STAGE_TIMINGS.size() - 1:
			assert_bool(player.request_attack()).is_true()
			assert_int(combat.get_combo_index()).is_equal(stage)
			assert_bool(bool(
				player.get_light_combo_diagnostics().get("chain_queued", false)
			)).is_true()
			assert_bool(await _wait_for_combo_stage(stage + 1)).is_true()
			assert_int(combat.get_attack_frame()).is_equal(0)
			assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_false()
		else:
			assert_bool(await _wait_for_attack_frame(
				startup_frames + active_frames
			)).is_true()
			assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_false()
			assert_int(player.get_node("Sprite").frame).is_equal(2)


func test_stage_zero_window_preserves_damage_energy_and_duplicate_suppression() -> void:
	var enemy_start_hp: int = int(enemy.call("get_current_hp"))
	var energy_start: int = combat.get_cat_energy()

	assert_bool(player.request_attack()).is_true()
	assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_false()
	assert_bool(await _wait_for_attack_frame(4)).is_true()
	assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_true()

	collision.process_detection_frame({
		LIGHT_HITBOX_ID: [enemy_collision.get_hurtbox()],
	})
	var metadata: Dictionary = scene.call("get_last_player_hit_metadata")
	var hp_after_first_hit: int = int(enemy.call("get_current_hp"))

	assert_int(int(metadata.get("final_damage", -1))).is_equal(10)
	assert_int(hp_after_first_hit).is_equal(enemy_start_hp - 10)
	assert_int(combat.get_cat_energy()).is_equal(energy_start + 5)
	assert_int(int(combat.get_battle_stats().get("hits_landed", 0))).is_equal(1)

	collision.process_detection_frame({
		LIGHT_HITBOX_ID: [enemy_collision.get_hurtbox()],
	})
	assert_int(int(enemy.call("get_current_hp"))).is_equal(hp_after_first_hit)
	assert_int(combat.get_cat_energy()).is_equal(energy_start + 5)
	assert_int(int(combat.get_battle_stats().get("hits_landed", 0))).is_equal(1)


func test_contact_callback_synchronizes_the_authored_visual_contact_frame() -> void:
	assert_bool(player.request_attack()).is_true()
	combat.advance_attack_frames(4)

	assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_true()
	assert_int(player.get_node("Sprite").frame).is_equal(1)


func _wait_for_attack_frame(target_frame: int, max_frames: int = 60) -> bool:
	for _frame: int in range(max_frames):
		if combat.get_attack_frame() >= target_frame:
			return true
		await get_tree().physics_frame
	return false


func _wait_for_combo_stage(target_stage: int, max_frames: int = 60) -> bool:
	for _frame: int in range(max_frames):
		if combat.get_combo_index() == target_stage and combat.get_attack_frame() == 0:
			return true
		await get_tree().physics_frame
	return false


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer2D:
			var audio_player := child as AudioStreamPlayer2D
			audio_player.stop()
			audio_player.stream = null
