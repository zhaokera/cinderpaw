## Feline Combat Story010: playable grounded heavy-charge runtime integration.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const HEAVY_CHARGE_ANIMATION: StringName = &"heavy_charge"
const HEAVY_ATTACK_ANIMATION: StringName = &"heavy_attack"
const MIN_CHARGE_SEC: float = 0.5
const MAX_CHARGE_SEC: float = 1.5
const MID_CHARGE_SEC: float = 1.0
const MID_CHARGE_RATIO: float = MID_CHARGE_SEC / MAX_CHARGE_SEC
const MID_DAMAGE_MULTIPLIER: float = 1.6

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


func test_mid_charge_release_activates_heavy_hitbox_damage_hud_and_feedback() -> void:
	if not _assert_runtime_heavy_contract():
		return
	var player: Node = scene.get_node("Player")
	var hud: Node = scene.get_node("HUD")
	var enemy: Node = scene.get_node("Enemy")
	var collision: Node = player.call("get_collision_component")
	var enemy_collision: Node = enemy.call("get_collision_component")
	var presentation: Node = scene.get_node("CombatPresentation")
	scene.call("set_current_weapon_id", &"fish_bone")

	assert_bool(bool(player.call("request_heavy_attack_press"))).is_true()
	var charging: Dictionary = player.call("get_heavy_attack_diagnostics")
	var charge_hud: Dictionary = hud.call("get_heavy_charge_snapshot")
	assert_bool(bool(charging.get("charging", false))).is_true()
	assert_str(String(charging.get("animation", ""))).is_equal(String(HEAVY_CHARGE_ANIMATION))
	assert_bool(bool(charge_hud.get("visible", false))).is_true()

	player.call("advance_heavy_charge_time", MID_CHARGE_SEC)
	charging = player.call("get_heavy_attack_diagnostics")
	charge_hud = hud.call("get_heavy_charge_snapshot")
	assert_float(float(charging.get("charge_ratio", 0.0))).is_equal_approx(
		MID_CHARGE_RATIO,
		0.001
	)
	assert_float(float(charge_hud.get("value", 0.0))).is_equal_approx(
		MID_CHARGE_RATIO * 100.0,
		0.01
	)

	assert_bool(bool(player.call("request_heavy_attack_release"))).is_true()
	var hitbox: Area2D = collision.call("get_hitbox", &"fish_bone_heavy") as Area2D
	assert_object(hitbox).is_not_null()
	assert_bool(collision.call("is_hitbox_active", &"fish_bone_heavy")).is_true()
	var attack_metadata: Dictionary = hitbox.call("get_attack_metadata")
	assert_str(String(attack_metadata.get("attack_type", ""))).is_equal("heavy")
	assert_float(float(attack_metadata.get("charge_seconds", 0.0))).is_equal_approx(
		MID_CHARGE_SEC,
		0.001
	)
	assert_float(float(attack_metadata.get("charge_ratio", 0.0))).is_equal_approx(
		MID_CHARGE_RATIO,
		0.001
	)
	assert_float(float(attack_metadata.get("charge_multiplier", 0.0))).is_equal_approx(
		MID_DAMAGE_MULTIPLIER,
		0.001
	)
	assert_float(float(Dictionary(attack_metadata.get("skill_modifiers", {})).get(
		"attack_type_multiplier",
		0.0
	))).is_equal_approx(MID_DAMAGE_MULTIPLIER, 0.001)
	assert_str(String(player.call("get_heavy_attack_diagnostics").get(
		"animation",
		""
	))).is_equal(String(HEAVY_ATTACK_ANIMATION))
	assert_bool(bool(hud.call("get_heavy_charge_snapshot").get("visible", true))).is_false()
	assert_int(int(presentation.call("get_screen_shake_frames_remaining"))).is_equal(4)

	collision.call("process_detection_frame", {
		&"fish_bone_heavy": [enemy_collision.call("get_hurtbox")],
	})
	var hit_metadata: Dictionary = scene.call("get_last_player_hit_metadata")
	assert_str(String(hit_metadata.get("attack_type", ""))).is_equal("heavy")
	assert_bool(int(hit_metadata.get("final_damage", 0)) > 0).is_true()
	assert_float(float(hit_metadata.get("attack_damage", 0.0))).is_greater(
		float(hit_metadata.get("base_damage", 0))
	)


func test_early_release_and_dodge_cancel_do_not_create_heavy_hitbox() -> void:
	if not _assert_runtime_heavy_contract():
		return
	var player: Node = scene.get_node("Player")
	var hud: Node = scene.get_node("HUD")
	var collision: Node = player.call("get_collision_component")

	assert_bool(bool(player.call("request_heavy_attack_press"))).is_true()
	player.call("advance_heavy_charge_time", MIN_CHARGE_SEC - 0.01)
	assert_bool(bool(player.call("request_heavy_attack_release"))).is_false()
	assert_bool(collision.call("is_hitbox_active", &"cat_claw_heavy")).is_false()
	assert_bool(bool(hud.call("get_heavy_charge_snapshot").get("visible", true))).is_false()

	assert_bool(bool(player.call("request_heavy_attack_press"))).is_true()
	player.call("advance_heavy_charge_time", 0.75)
	assert_bool(bool(player.call("request_dodge"))).is_true()
	assert_bool(bool(player.call("get_heavy_attack_diagnostics").get("charging", true))).is_false()
	assert_bool(collision.call("is_hitbox_active", &"cat_claw_heavy")).is_false()
	assert_bool(bool(hud.call("get_heavy_charge_snapshot").get("visible", true))).is_false()


func test_damage_interrupts_runtime_charge_into_core_hit_stun() -> void:
	if not _assert_runtime_heavy_contract():
		return
	var player: Node = scene.get_node("Player")
	var hud: Node = scene.get_node("HUD")
	var combat: Node = player.call("get_combat_component")
	var collision: Node = player.call("get_collision_component")

	assert_bool(bool(player.call("request_heavy_attack_press"))).is_true()
	player.call("advance_heavy_charge_time", 0.75)
	player.call("apply_damage", 1, {"source": &"story010_test"})

	assert_int(int(combat.call("get_current_state"))).is_equal(
		CombatComponent.CombatState.HIT_STUN
	)
	assert_bool(bool(player.call("get_heavy_attack_diagnostics").get("charging", true))).is_false()
	assert_bool(collision.call("is_hitbox_active", &"cat_claw_heavy")).is_false()
	assert_bool(bool(hud.call("get_heavy_charge_snapshot").get("visible", true))).is_false()


func test_cinderpaw_heavy_animations_use_three_consistent_frames_each() -> void:
	var player: Node = scene.get_node("Player")
	var sprite: AnimatedSprite2D = player.get_node("Sprite") as AnimatedSprite2D
	assert_object(sprite).is_not_null()
	assert_bool(sprite.sprite_frames.has_animation(HEAVY_CHARGE_ANIMATION)).is_true()
	assert_bool(sprite.sprite_frames.has_animation(HEAVY_ATTACK_ANIMATION)).is_true()
	assert_int(sprite.sprite_frames.get_frame_count(HEAVY_CHARGE_ANIMATION)).is_greater_equal(3)
	assert_int(sprite.sprite_frames.get_frame_count(HEAVY_ATTACK_ANIMATION)).is_greater_equal(3)
	var expected_size: Vector2i = Vector2i.ZERO
	for animation_name: StringName in [HEAVY_CHARGE_ANIMATION, HEAVY_ATTACK_ANIMATION]:
		for frame_index: int in range(sprite.sprite_frames.get_frame_count(animation_name)):
			var texture: Texture2D = sprite.sprite_frames.get_frame_texture(
				animation_name,
				frame_index
			)
			assert_object(texture).is_not_null()
			if expected_size == Vector2i.ZERO:
				expected_size = texture.get_size()
			assert_vector(Vector2(texture.get_size())).is_equal(Vector2(expected_size))


func _assert_runtime_heavy_contract() -> bool:
	var player: Node = scene.get_node("Player")
	var hud: Node = scene.get_node("HUD")
	var has_contract: bool = (
		player.has_method("request_heavy_attack_press")
		and player.has_method("request_heavy_attack_release")
		and player.has_method("advance_heavy_charge_time")
		and player.has_method("get_heavy_attack_diagnostics")
		and hud.has_method("get_heavy_charge_snapshot")
	)
	assert_bool(has_contract).is_true()
	return has_contract


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer2D:
			var audio_player := child as AudioStreamPlayer2D
			audio_player.stop()
			audio_player.stream = null
