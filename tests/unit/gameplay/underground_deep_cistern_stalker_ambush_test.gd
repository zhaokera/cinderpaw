## Player Abilities Story133: deep-cistern Stalker ACT encounter.
extends GdUnitTestSuite

const UNDERGROUND_SCENE_PATH: String = "res://scenes/areas/underground_passage.tscn"
const CHARACTER_SCENE_PATH: String = (
	"res://scenes/characters/underground_cistern_stalker.tscn"
)
const RUNTIME_SCENE_PATH: String = (
	"res://src/gameplay/underground_cistern_stalker.tscn"
)
const CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/underground_deep_cistern_ambush_controller.gd"
)
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/underground_cistern_stalker/"
	+ "underground_cistern_stalker_sprite_frames.tres"
)
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "env_underground_deep_cistern_1280x720.png"
)
const ENEMY_NODE_PATH: String = "DeepCisternAmbushController/CisternStalker"
const ROUTE_WIDTH_PX: int = 5120
const ACTIVATION_X: float = 4050.0
const BACK_SEAL_X: float = 3980.0
const FORWARD_SEAL_X: float = 4960.0
const STALKER_ENTITY_ID: int = 2501
const STALKER_MAX_HP: int = 48
const STALKER_ATTACK_STARTUP_FRAMES: int = 24
const STALKER_ATTACK_ACTIVE_FRAMES: int = 6
const STALKER_ATTACK_RECOVERY_FRAMES: int = 18
const STALKER_ATTACK_DAMAGE: int = 14
const STALKER_HITBOX_ID: StringName = &"underground_cistern_stalker_leap"
const FRAME_SIZE: Vector2i = Vector2i(96, 96)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_authored_route_character_and_frame_animation_contract() -> void:
	_assert_png_contract(BACKGROUND_TEXTURE_PATH, Vector2i(1280, 720), false)
	assert_bool(FileAccess.file_exists(CHARACTER_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(RUNTIME_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CONTROLLER_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SPRITE_FRAMES_PATH)).is_true()

	if DirAccess.dir_exists_absolute(
		ProjectSettings.globalize_path(
			"res://assets/characters/underground_cistern_stalker"
		)
	):
		for animation_name: StringName in REQUIRED_ANIMATIONS:
			for frame_index: int in range(3):
				_assert_png_contract(
					_frame_path(animation_name, frame_index),
					FRAME_SIZE,
					true
				)

	if FileAccess.file_exists(SPRITE_FRAMES_PATH):
		var frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
		assert_that(frames).is_not_null()
		if frames != null:
			for animation_name: StringName in REQUIRED_ANIMATIONS:
				assert_bool(frames.has_animation(animation_name)).is_true()
				assert_int(frames.get_frame_count(animation_name)).is_equal(3)

	var scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method(
		"get_underground_deep_cistern_diagnostics"
	)).is_true()
	if not scene.has_method("get_underground_deep_cistern_diagnostics"):
		return
	var diagnostics: Dictionary = scene.call(
		"get_underground_deep_cistern_diagnostics"
	)
	assert_int(int(diagnostics.get("route_width_px", 0))).is_equal(
		ROUTE_WIDTH_PX
	)
	assert_str(String(diagnostics.get("controller_script_path", ""))).is_equal(
		CONTROLLER_SCRIPT_PATH
	)
	assert_str(String(diagnostics.get("background_texture_path", ""))).is_equal(
		BACKGROUND_TEXTURE_PATH
	)
	assert_float(float(diagnostics.get("activation_x", 0.0))).is_equal_approx(
		ACTIVATION_X,
		0.01
	)
	assert_float(float(diagnostics.get("back_seal_x", 0.0))).is_equal_approx(
		BACK_SEAL_X,
		0.01
	)
	assert_float(float(diagnostics.get("forward_seal_x", 0.0))).is_equal_approx(
		FORWARD_SEAL_X,
		0.01
	)
	assert_float(float(diagnostics.get("right_wall_x", 0.0))).is_equal_approx(
		5100.0,
		0.01
	)
	assert_int(int(diagnostics.get("enemy_entity_id", 0))).is_equal(
		STALKER_ENTITY_ID
	)
	assert_str(String(diagnostics.get("enemy_family_id", ""))).is_equal(
		"underground_cistern_stalker"
	)
	assert_int(int(diagnostics.get("enemy_max_hp", 0))).is_equal(
		STALKER_MAX_HP
	)
	assert_int(int(diagnostics.get("attack_startup_frames", 0))).is_equal(
		STALKER_ATTACK_STARTUP_FRAMES
	)
	assert_int(int(diagnostics.get("attack_active_frames", 0))).is_equal(
		STALKER_ATTACK_ACTIVE_FRAMES
	)
	assert_int(int(diagnostics.get("attack_recovery_frames", 0))).is_equal(
		STALKER_ATTACK_RECOVERY_FRAMES
	)
	assert_int(int(diagnostics.get("attack_damage", 0))).is_equal(
		STALKER_ATTACK_DAMAGE
	)
	var camera: Camera2D = scene.get_node_or_null("Player/Camera2D") as Camera2D
	assert_that(camera).is_not_null()
	if camera != null:
		assert_int(camera.limit_right).is_equal(ROUTE_WIDTH_PX)
	assert_that(scene.get_node_or_null(ENEMY_NODE_PATH)).is_not_null()


func test_story132_gate_attack_tell_and_real_leap_damage() -> void:
	var scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method("try_activate_deep_cistern_ambush")).is_true()
	assert_bool(scene.has_method(
		"get_underground_deep_cistern_diagnostics"
	)).is_true()
	if not scene.has_method("try_activate_deep_cistern_ambush"):
		return
	var player: Node2D = scene.get_node_or_null("Player") as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.global_position.x = ACTIVATION_X
	assert_bool(bool(scene.call(
		"try_activate_deep_cistern_ambush",
		player
	))).is_false()

	scene.call("set_local_state", _story132_traversed_state())
	player.global_position.x = ACTIVATION_X - 1.0
	assert_bool(bool(scene.call(
		"try_activate_deep_cistern_ambush",
		player
	))).is_false()
	player.global_position.x = ACTIVATION_X
	assert_bool(bool(scene.call(
		"try_activate_deep_cistern_ambush",
		player
	))).is_true()
	assert_bool(bool(scene.call(
		"try_activate_deep_cistern_ambush",
		player
	))).is_false()
	await get_tree().process_frame

	var active: Dictionary = scene.call(
		"get_underground_deep_cistern_diagnostics"
	)
	assert_str(String(active.get("encounter_state", ""))).is_equal("active")
	assert_bool(bool(active.get("back_seal_blocking", false))).is_true()
	assert_bool(bool(active.get("forward_seal_blocking", false))).is_true()
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_str(String(active.get("objective_text", ""))).is_equal(
		"Break Cistern Stalker"
	)
	var old_endpoint_prompt: Label = scene.get_node_or_null(
		"RecoveryCisternController/DeepRouteEndpoint/PromptLabel"
	) as Label
	assert_that(old_endpoint_prompt).is_not_null()
	if old_endpoint_prompt != null:
		assert_bool(old_endpoint_prompt.visible).is_false()

	var enemy: CharacterBody2D = scene.get_node_or_null(
		ENEMY_NODE_PATH
	) as CharacterBody2D
	assert_that(enemy).is_not_null()
	if enemy == null:
		return
	enemy.set_physics_process(false)
	assert_bool(bool(enemy.call("request_attack"))).is_true()
	var sprite: AnimatedSprite2D = enemy.get_node_or_null(
		"Sprite"
	) as AnimatedSprite2D
	assert_that(sprite).is_not_null()
	if sprite != null:
		assert_str(String(sprite.animation)).is_equal("attack_tell")
	enemy.call("advance_attack_frames", STALKER_ATTACK_STARTUP_FRAMES - 1)
	assert_bool(bool(enemy.call("is_enemy_attack_active"))).is_false()
	enemy.call("advance_attack_frames", 1)
	assert_bool(bool(enemy.call("is_enemy_attack_active"))).is_true()
	assert_float(enemy.velocity.y).is_less(0.0)

	var hp_before: int = int(player.call("get_current_hp"))
	var enemy_collision: CollisionComponent = enemy.call(
		"get_collision_component"
	) as CollisionComponent
	var player_collision: CollisionComponent = player.call(
		"get_collision_component"
	) as CollisionComponent
	assert_that(enemy_collision).is_not_null()
	assert_that(player_collision).is_not_null()
	if enemy_collision == null or player_collision == null:
		return
	enemy_collision.process_detection_frame({
		STALKER_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(
		hp_before - STALKER_ATTACK_DAMAGE
	)
	enemy_collision.process_detection_frame({
		STALKER_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(
		hp_before - STALKER_ATTACK_DAMAGE
	)


func test_player_hit_clear_and_fresh_restore_are_deterministic() -> void:
	var scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method("try_activate_deep_cistern_ambush")).is_true()
	assert_bool(scene.has_method("apply_damage")).is_true()
	assert_bool(scene.has_method(
		"get_underground_deep_cistern_diagnostics"
	)).is_true()
	if not scene.has_method("try_activate_deep_cistern_ambush"):
		return
	scene.call("set_local_state", _story132_traversed_state())
	var player: Node2D = scene.get_node_or_null("Player") as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.global_position.x = ACTIVATION_X
	assert_bool(bool(scene.call(
		"try_activate_deep_cistern_ambush",
		player
	))).is_true()
	await get_tree().process_frame

	var enemy: Node = scene.get_node_or_null(ENEMY_NODE_PATH)
	assert_that(enemy).is_not_null()
	if enemy == null:
		return
	var hp_before: int = int(enemy.call("get_current_hp"))
	var player_collision: CollisionComponent = player.call(
		"get_collision_component"
	) as CollisionComponent
	var enemy_collision: CollisionComponent = enemy.call(
		"get_collision_component"
	) as CollisionComponent
	assert_that(player_collision).is_not_null()
	assert_that(enemy_collision).is_not_null()
	if player_collision == null or enemy_collision == null:
		return
	assert_bool(bool(player.call("request_attack"))).is_true()
	player_collision.process_detection_frame({
		&"cat_claw_light": [enemy_collision.get_hurtbox()],
	})
	assert_bool(int(enemy.call("get_current_hp")) < hp_before).is_true()
	var last_hit: Dictionary = scene.call("get_last_player_hit_metadata")
	assert_int(int(last_hit.get("target_id", -1))).is_equal(STALKER_ENTITY_ID)

	assert_bool(bool(scene.call("apply_damage", STALKER_ENTITY_ID, 999, {
		"source": &"story133_test_clear",
	}))).is_true()
	await get_tree().process_frame
	var cleared: Dictionary = scene.call(
		"get_underground_deep_cistern_diagnostics"
	)
	assert_str(String(cleared.get("encounter_state", ""))).is_equal("cleared")
	assert_bool(bool(cleared.get("enemy_visible", false))).is_true()
	assert_str(String(cleared.get("enemy_animation", ""))).is_equal("death")
	assert_bool(bool(cleared.get("back_seal_blocking", true))).is_false()
	assert_bool(bool(cleared.get("forward_seal_blocking", true))).is_false()
	assert_str(String(cleared.get("objective_text", ""))).is_equal(
		"Deep Cistern Secured"
	)
	await get_tree().create_timer(0.45).timeout
	var cleared_after_death: Dictionary = scene.call(
		"get_underground_deep_cistern_diagnostics"
	)
	assert_bool(bool(cleared_after_death.get(
		"enemy_visible",
		true
	))).is_false()

	var saved: Dictionary = scene.call("get_local_state")
	assert_bool(bool(saved.get(
		"underground_deep_cistern_ambush_activated",
		false
	))).is_true()
	assert_bool(bool(saved.get(
		"underground_deep_cistern_stalker_defeated",
		false
	))).is_true()

	var restored_scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(restored_scene).is_not_null()
	if restored_scene == null:
		return
	restored_scene.call("set_local_state", saved)
	await get_tree().process_frame
	var restored: Dictionary = restored_scene.call(
		"get_underground_deep_cistern_diagnostics"
	)
	assert_str(String(restored.get("encounter_state", ""))).is_equal("cleared")
	assert_bool(bool(restored.get("enemy_visible", true))).is_false()
	assert_bool(bool(restored.get("back_seal_blocking", true))).is_false()
	assert_bool(bool(restored.get("forward_seal_blocking", true))).is_false()
	var restored_player: Node2D = restored_scene.get_node_or_null(
		"Player"
	) as Node2D
	assert_that(restored_player).is_not_null()
	if restored_player != null:
		restored_player.global_position.x = ACTIVATION_X
		assert_bool(bool(restored_scene.call(
			"try_activate_deep_cistern_ambush",
			restored_player
		))).is_false()


func _story132_traversed_state() -> Dictionary:
	return {
		"underground_corrosion_channel_activated": true,
		"underground_corrosion_left_defeated": true,
		"underground_corrosion_right_defeated": true,
		"underground_corrosion_channel_cleared": true,
		"underground_corrosion_salvage_claimed": true,
		"underground_recovery_cistern_relay_activated": true,
		"underground_recovery_cistern_traversed": true,
		"unlocked_abilities": ["aerial_attack"],
	}


func _frame_path(animation_name: StringName, frame_index: int) -> String:
	return (
		"res://assets/characters/underground_cistern_stalker/%s/"
		% String(animation_name)
		+ "underground_cistern_stalker_%s_%03d.png"
		% [String(animation_name), frame_index]
	)


func _instantiate_scene(path: String) -> Node:
	if not FileAccess.file_exists(path):
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var instance: Node = packed.instantiate()
	add_child(instance)
	_spawned_nodes.append(instance)
	return instance


func _assert_png_contract(
	path: String,
	expected_size: Vector2i,
	alpha: bool
) -> void:
	assert_bool(FileAccess.file_exists(path)).is_true()
	if not FileAccess.file_exists(path):
		return
	var image := Image.new()
	var load_error: Error = image.load_png_from_buffer(
		FileAccess.get_file_as_bytes(path)
	)
	assert_int(load_error).is_equal(OK)
	if load_error != OK:
		return
	assert_int(image.get_width()).is_equal(expected_size.x)
	assert_int(image.get_height()).is_equal(expected_size.y)
	if alpha:
		assert_int(image.detect_alpha()).is_equal(Image.ALPHA_BLEND)
		assert_float(image.get_pixel(0, 0).a).is_less_equal(0.01)
		assert_float(image.get_pixel(
			expected_size.x - 1,
			expected_size.y - 1
		).a).is_less_equal(0.01)
	else:
		assert_int(image.detect_alpha()).is_equal(Image.ALPHA_NONE)


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
