## Story 020: the real Cat Claw third hit receives a dedicated finisher profile.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const LIGHT_HITBOX_ID: StringName = &"cat_claw_light"

var scene: Node
var player: PlayerController
var combat: CombatComponent
var collision: CollisionComponent
var enemy: Node
var enemy_collision: CollisionComponent
var presentation: Node


func before_test() -> void:
	Input.action_release(&"attack")
	scene = MAIN_SCENE.instantiate()
	add_child(scene)
	player = scene.get_node("Player") as PlayerController
	combat = player.get_combat_component()
	collision = player.get_collision_component()
	enemy = scene.get_node("Enemy")
	enemy_collision = enemy.get_collision_component() as CollisionComponent
	presentation = scene.get_node("CombatPresentation")


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
	presentation = null


func test_cat_claw_stage_two_hit_uses_finisher_feedback_without_changing_gameplay() -> void:
	var enemy_start_hp: int = int(enemy.call("get_current_hp"))
	var energy_start: int = combat.get_cat_energy()

	assert_bool(player.request_attack()).is_true()
	combat.advance_attack_frames(4)
	assert_bool(player.request_attack()).is_true()
	combat.advance_attack_frames(4)
	assert_int(combat.get_combo_index()).is_equal(1)

	combat.advance_attack_frames(6)
	assert_bool(player.request_attack()).is_true()
	combat.advance_attack_frames(6)
	assert_int(combat.get_combo_index()).is_equal(2)
	assert_int(combat.get_attack_frame()).is_equal(0)

	combat.advance_attack_frames(10)
	assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_true()
	assert_str(String(player.get_node("Sprite").animation)).is_equal("attack_3")
	assert_int(player.get_node("Sprite").frame).is_equal(1)

	collision.process_detection_frame({
		LIGHT_HITBOX_ID: [enemy_collision.get_hurtbox()],
	})

	var metadata: Dictionary = scene.call("get_last_player_hit_metadata")
	var damage_snapshot: Dictionary = presentation.call("get_last_damage_number_snapshot")

	assert_str(String(metadata.get("weapon_id", &""))).is_equal("cat_claw")
	assert_str(String(metadata.get("attack_type", &""))).is_equal("light")
	assert_int(int(metadata.get("combo_index", -1))).is_equal(2)
	assert_int(int(metadata.get("combo_stage", -1))).is_equal(2)
	assert_bool(bool(metadata.get("is_crit", true))).is_false()
	assert_int(int(metadata.get("final_damage", -1))).is_equal(18)
	assert_int(int(enemy.call("get_current_hp"))).is_equal(enemy_start_hp - 18)
	assert_int(combat.get_cat_energy()).is_equal(energy_start + 12)

	assert_int(int(presentation.call("get_hitstop_frames_remaining"))).is_equal(5)
	assert_float(float(presentation.call("get_screen_shake_intensity"))).is_equal_approx(
		4.0,
		0.001
	)
	assert_int(int(presentation.call("get_screen_shake_frames_remaining"))).is_equal(5)
	assert_int(int(damage_snapshot.get("active_count", 0))).is_equal(1)
	assert_str(String(damage_snapshot.get("text", ""))).is_equal("18")
	assert_str(Color(damage_snapshot.get("color", Color.TRANSPARENT)).to_html(false)).is_equal(
		"f59e0b"
	)
	assert_int(int(damage_snapshot.get("font_size", 0))).is_equal(28)

	assert_bool(presentation.has_method("get_last_combo_finisher_snapshot")).is_true()
	if not presentation.has_method("get_last_combo_finisher_snapshot"):
		return
	var finisher_snapshot: Dictionary = presentation.call(
		"get_last_combo_finisher_snapshot"
	)
	assert_bool(bool(finisher_snapshot.get("visible", false))).is_true()
	assert_int(int(finisher_snapshot.get("active_count", 0))).is_equal(1)
	assert_str(String(finisher_snapshot.get("text", ""))).is_equal("终结")
	assert_str(Color(finisher_snapshot.get("color", Color.TRANSPARENT)).to_html(false)).is_equal(
		"f59e0b"
	)
	assert_float(float(finisher_snapshot.get("spark_scale_multiplier", 0.0))).is_equal_approx(
		1.5,
		0.001
	)


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer2D:
			var audio_player := child as AudioStreamPlayer2D
			audio_player.stop()
			audio_player.stream = null
