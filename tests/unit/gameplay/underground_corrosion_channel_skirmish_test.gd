## Player Abilities Story131: first playable Underground traversal/combat beat.
extends GdUnitTestSuite

const UNDERGROUND_SCENE_PATH: String = "res://scenes/areas/underground_passage.tscn"
const UNDERGROUND_BACKGROUND_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "env_underground_corrosion_channel_1280x720.png"
)
const CORROSIVE_RUNOFF_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "prop_underground_corrosive_runoff_512x160.png"
)
const SEAL_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "prop_underground_seal_gate_256x384.png"
)
const SALVAGE_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "prop_underground_salvage_cache_256x256.png"
)
const LEECH_SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/factory_sluice_leech/"
	+ "factory_sluice_leech_sprite_frames.tres"
)
const MIN_CORROSION_ROUTE_WIDTH_PX: int = 2560
const ENCOUNTER_ACTIVATION_X: float = 1450.0
const LEFT_ENTITY_ID: int = 2401
const RIGHT_ENTITY_ID: int = 2402
const HAZARD_DAMAGE: int = 8
const HAZARD_COOLDOWN_SEC: float = 1.0
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


func test_authored_corrosion_channel_combat_slice_contract() -> void:
	assert_bool(FileAccess.file_exists(UNDERGROUND_BACKGROUND_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CORROSIVE_RUNOFF_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SEAL_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SALVAGE_TEXTURE_PATH)).is_true()

	_assert_png_contract(UNDERGROUND_BACKGROUND_PATH, Vector2i(1280, 720), false)
	_assert_png_contract(CORROSIVE_RUNOFF_TEXTURE_PATH, Vector2i(512, 160), true)
	_assert_png_contract(SEAL_TEXTURE_PATH, Vector2i(256, 384), true)
	_assert_png_contract(SALVAGE_TEXTURE_PATH, Vector2i(256, 256), true)

	var scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method("get_underground_combat_diagnostics")).is_true()
	assert_that(scene.get_node_or_null("CorrosionChannelBackground")).is_not_null()
	assert_that(scene.get_node_or_null("CorrosiveRunoffHazard")).is_not_null()
	assert_that(scene.get_node_or_null("RunoffStepA")).is_not_null()
	assert_that(scene.get_node_or_null("RunoffStepB")).is_not_null()
	assert_that(scene.get_node_or_null("RunoffStepC")).is_not_null()
	assert_that(scene.get_node_or_null("EncounterBackSeal")).is_not_null()
	assert_that(scene.get_node_or_null("EncounterForwardSeal")).is_not_null()
	assert_that(scene.get_node_or_null("CorrosionLeechLeft")).is_not_null()
	assert_that(scene.get_node_or_null("CorrosionLeechRight")).is_not_null()
	assert_that(scene.get_node_or_null("CorrosionSalvageCache")).is_not_null()
	var camera: Camera2D = scene.get_node_or_null("Player/Camera2D") as Camera2D
	assert_that(camera).is_not_null()
	if camera != null:
		assert_int(camera.limit_left).is_equal(0)
		assert_int(camera.limit_right).is_greater_equal(MIN_CORROSION_ROUTE_WIDTH_PX)

	var frames: SpriteFrames = load(LEECH_SPRITE_FRAMES_PATH) as SpriteFrames
	assert_that(frames).is_not_null()
	if frames != null:
		for animation_name: StringName in REQUIRED_ANIMATIONS:
			assert_bool(frames.has_animation(animation_name)).is_true()
			assert_int(frames.get_frame_count(animation_name)).is_equal(3)

	if not scene.has_method("get_underground_combat_diagnostics"):
		return
	var diagnostics: Dictionary = scene.call("get_underground_combat_diagnostics")
	assert_int(int(diagnostics.get(
		"route_width_px",
		0
	))).is_greater_equal(MIN_CORROSION_ROUTE_WIDTH_PX)
	assert_int(int(diagnostics.get("stepping_platform_count", 0))).is_equal(3)
	assert_int(int(diagnostics.get("enemy_count", 0))).is_equal(2)
	assert_array(Array(diagnostics.get("enemy_entity_ids", []))).contains_exactly([
		LEFT_ENTITY_ID,
		RIGHT_ENTITY_ID,
	])
	assert_bool(bool(diagnostics.get("weapon_component_present", false))).is_true()
	assert_bool(
		float(diagnostics.get("back_seal_x", ENCOUNTER_ACTIVATION_X))
		<= ENCOUNTER_ACTIVATION_X - 64.0
	).is_true()
	assert_bool(
		float(diagnostics.get("forward_seal_x", 0.0))
		>= ENCOUNTER_ACTIVATION_X + 700.0
	).is_true()
	assert_str(String(diagnostics.get("encounter_state", ""))).is_equal("ready")
	assert_bool(bool(diagnostics.get("back_seal_blocking", true))).is_false()
	assert_bool(bool(diagnostics.get("forward_seal_blocking", false))).is_true()


func test_real_attack_clear_cache_and_fresh_restore_are_deterministic() -> void:
	var scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method("try_activate_corrosion_channel_encounter")).is_true()
	assert_bool(scene.has_method("get_underground_combat_diagnostics")).is_true()
	assert_bool(scene.has_method("get_last_player_hit_metadata")).is_true()
	assert_bool(scene.has_method("apply_damage")).is_true()
	assert_bool(scene.has_method("try_claim_corrosion_salvage")).is_true()
	if not scene.has_method("try_activate_corrosion_channel_encounter"):
		return
	var player: Node2D = scene.get_node_or_null("Player") as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.global_position.x = ENCOUNTER_ACTIVATION_X - 1.0
	assert_bool(bool(scene.call(
		"try_activate_corrosion_channel_encounter",
		player
	))).is_false()
	player.global_position.x = ENCOUNTER_ACTIVATION_X
	assert_bool(bool(scene.call(
		"try_activate_corrosion_channel_encounter",
		player
	))).is_true()
	assert_bool(bool(scene.call(
		"try_activate_corrosion_channel_encounter",
		player
	))).is_false()
	await get_tree().process_frame

	var active: Dictionary = scene.call("get_underground_combat_diagnostics")
	assert_str(String(active.get("encounter_state", ""))).is_equal("active")
	assert_int(int(active.get("active_enemy_count", 0))).is_equal(2)
	assert_bool(bool(active.get("back_seal_blocking", false))).is_true()
	assert_bool(bool(active.get("forward_seal_blocking", false))).is_true()
	assert_bool(bool(active.get("cache_prompt_visible", true))).is_false()
	assert_str(String(active.get("objective_text", ""))).is_equal(
		"Clear Corrosion Channel"
	)

	var left_enemy: Node = scene.get_node_or_null("CorrosionLeechLeft")
	assert_that(left_enemy).is_not_null()
	if left_enemy == null:
		return
	var enemy_hp_before: int = int(left_enemy.call("get_current_hp"))
	var player_collision: Object = player.call("get_collision_component")
	var enemy_collision: Object = left_enemy.call("get_collision_component")
	assert_bool(bool(player.call("request_attack"))).is_true()
	player_collision.call("process_detection_frame", {
		&"cat_claw_light": [enemy_collision.call("get_hurtbox")],
	})
	assert_bool(int(left_enemy.call("get_current_hp")) < enemy_hp_before).is_true()
	var last_hit: Dictionary = scene.call("get_last_player_hit_metadata")
	assert_int(int(last_hit.get("target_id", -1))).is_equal(LEFT_ENTITY_ID)

	assert_bool(bool(scene.call("apply_damage", LEFT_ENTITY_ID, 999, {
		"source": &"story131_test",
	}))).is_true()
	assert_bool(bool(scene.call("apply_damage", RIGHT_ENTITY_ID, 999, {
		"source": &"story131_test",
	}))).is_true()
	await get_tree().process_frame
	var cleared: Dictionary = scene.call("get_underground_combat_diagnostics")
	assert_str(String(cleared.get("encounter_state", ""))).is_equal("cleared")
	assert_int(int(cleared.get("active_enemy_count", -1))).is_equal(0)
	assert_bool(bool(cleared.get("back_seal_blocking", true))).is_false()
	assert_bool(bool(cleared.get("forward_seal_blocking", true))).is_false()
	assert_bool(bool(cleared.get("cache_available", false))).is_true()
	assert_str(String(cleared.get("objective_text", ""))).is_equal(
		"Claim Underground Salvage"
	)
	assert_bool(bool(scene.call("try_claim_corrosion_salvage", player))).is_false()
	assert_bool(bool(scene.call("try_claim_corrosion_salvage"))).is_false()

	var cache: Node2D = scene.get_node_or_null("CorrosionSalvageCache") as Node2D
	assert_that(cache).is_not_null()
	if cache == null:
		return
	player.global_position = cache.global_position
	assert_bool(bool(scene.call("try_claim_corrosion_salvage", player))).is_true()
	assert_bool(bool(scene.call("try_claim_corrosion_salvage", player))).is_false()
	var claimed: Dictionary = scene.call("get_underground_combat_diagnostics")
	assert_bool(bool(claimed.get("cache_claimed", false))).is_true()
	assert_int(int(Dictionary(claimed.get("last_reward", {})).get("gears", 0))).is_equal(20)
	assert_str(String(claimed.get("objective_text", ""))).is_equal(
		"Corrosion Channel Secured"
	)

	var saved: Dictionary = scene.call("get_local_state")
	assert_bool(bool(saved.get("underground_corrosion_channel_activated", false))).is_true()
	assert_bool(bool(saved.get("underground_corrosion_left_defeated", false))).is_true()
	assert_bool(bool(saved.get("underground_corrosion_right_defeated", false))).is_true()
	assert_bool(bool(saved.get("underground_corrosion_channel_cleared", false))).is_true()
	assert_bool(bool(saved.get("underground_corrosion_salvage_claimed", false))).is_true()

	var restored_scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	restored_scene.call("set_local_state", saved)
	await get_tree().process_frame
	var restored: Dictionary = restored_scene.call("get_underground_combat_diagnostics")
	assert_str(String(restored.get("encounter_state", ""))).is_equal("claimed")
	assert_int(int(restored.get("active_enemy_count", -1))).is_equal(0)
	assert_bool(bool(restored.get("back_seal_blocking", true))).is_false()
	assert_bool(bool(restored.get("forward_seal_blocking", true))).is_false()
	assert_bool(bool(restored.get("cache_claimed", false))).is_true()
	assert_str(String(restored.get("objective_text", ""))).is_equal(
		"Corrosion Channel Secured"
	)


func test_corrosive_runoff_damage_uses_per_target_cooldown() -> void:
	var scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method("apply_corrosive_runoff_contact")).is_true()
	assert_bool(scene.has_method("advance_corrosive_runoff_time")).is_true()
	assert_bool(scene.has_method("get_underground_combat_diagnostics")).is_true()
	if not scene.has_method("apply_corrosive_runoff_contact"):
		return
	var player: Node = scene.get_node_or_null("Player")
	var hazard: Area2D = scene.get_node_or_null("CorrosiveRunoffHazard") as Area2D
	assert_that(player).is_not_null()
	assert_that(hazard).is_not_null()
	if player == null or hazard == null:
		return
	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(scene.call("apply_corrosive_runoff_contact", hazard, player))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - HAZARD_DAMAGE)
	assert_bool(bool(scene.call("apply_corrosive_runoff_contact", hazard, player))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - HAZARD_DAMAGE)
	scene.call("advance_corrosive_runoff_time", HAZARD_COOLDOWN_SEC + 0.01)
	assert_bool(bool(scene.call("apply_corrosive_runoff_contact", hazard, player))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - HAZARD_DAMAGE * 2)
	var diagnostics: Dictionary = scene.call("get_underground_combat_diagnostics")
	assert_int(int(diagnostics.get("hazard_accepted_contacts", 0))).is_equal(2)
	assert_float(float(diagnostics.get("hazard_contact_cooldown_sec", 0.0))).is_equal_approx(
		HAZARD_COOLDOWN_SEC,
		0.001
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


func _assert_png_contract(path: String, expected_size: Vector2i, alpha: bool) -> void:
	var image: Image = _load_png(path)
	assert_that(image).is_not_null()
	if image == null:
		return
	assert_int(image.get_width()).is_equal(expected_size.x)
	assert_int(image.get_height()).is_equal(expected_size.y)
	if alpha:
		assert_int(image.detect_alpha()).is_equal(Image.ALPHA_BLEND)
	else:
		assert_int(image.detect_alpha()).is_equal(Image.ALPHA_NONE)


func _load_png(path: String) -> Image:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
		return null
	return image


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
