## Player Abilities Story 009: Old Factory steam vent hazard route runtime contract.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_STEAM_VENT_NAME: String = "FactorySteamVentHazard"
const FACTORY_STEAM_VENT_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_ENEMY_NAME: String = "FactoryRatMinion"
const EXPECTED_STEAM_DAMAGE: int = 8
const EXPECTED_STEAM_COOLDOWN_SEC: float = 1.0
const MIN_CHARACTER_ANIMATION_FRAMES: int = 3

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


func test_factory_room_contains_generated_steam_vent_hazard_without_placeholder_art() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_str(String(destination.get_meta("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_bool(FileAccess.file_exists(FACTORY_STEAM_VENT_TEXTURE_PATH)).is_true()
	assert_bool(_has_visible_placeholder_shape(destination)).is_false()

	var hazard: Area2D = destination.get_node_or_null(FACTORY_STEAM_VENT_NAME) as Area2D
	assert_that(hazard).is_not_null()
	if hazard == null:
		return
	assert_int(hazard.collision_layer).is_equal(CollisionComponent.COLLISION_LAYER_ENVIRONMENT)
	assert_int(hazard.collision_mask).is_equal(CollisionComponent.COLLISION_MASK_ENVIRONMENT)
	assert_bool(hazard.monitoring).is_true()
	assert_bool(hazard.monitorable).is_false()
	assert_that(hazard.get_node_or_null("CollisionShape2D")).is_not_null()
	assert_bool(hazard.has_method("get_hazard_id")).is_true()
	assert_bool(hazard.has_method("get_visual_texture_path")).is_true()
	assert_str(String(hazard.call("get_hazard_id"))).is_equal("old_factory_steam_vent")
	assert_str(String(hazard.call("get_visual_texture_path"))).is_equal(
		FACTORY_STEAM_VENT_TEXTURE_PATH
	)


func test_steam_vent_contact_damages_player_and_respects_cooldown() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("apply_factory_steam_vent_contact")).is_true()
	assert_bool(destination.has_method("advance_factory_hazard_time")).is_true()
	var hazard: Area2D = destination.get_node_or_null(FACTORY_STEAM_VENT_NAME) as Area2D
	var player: Node = destination.get_node_or_null(FACTORY_PLAYER_NAME)
	assert_that(hazard).is_not_null()
	assert_that(player).is_not_null()
	if hazard == null or player == null:
		return

	var start_hp: int = int(player.call("get_current_hp"))
	assert_bool(bool(destination.call("apply_factory_steam_vent_contact", hazard, player))).is_true()
	var hp_after_first_contact: int = int(player.call("get_current_hp"))
	assert_int(start_hp - hp_after_first_contact).is_equal(EXPECTED_STEAM_DAMAGE)

	assert_bool(bool(destination.call("apply_factory_steam_vent_contact", hazard, player))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_after_first_contact)

	destination.call("advance_factory_hazard_time", EXPECTED_STEAM_COOLDOWN_SEC)
	assert_bool(bool(destination.call("apply_factory_steam_vent_contact", hazard, player))).is_true()
	assert_int(start_hp - int(player.call("get_current_hp"))).is_equal(EXPECTED_STEAM_DAMAGE * 2)


func test_steam_vent_sustained_overlap_ticks_after_cooldown_and_ignores_enemy() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("apply_factory_steam_vent_contact")).is_true()
	assert_bool(destination.has_method("get_factory_hazard_diagnostics")).is_true()
	var hazard: Area2D = destination.get_node_or_null(FACTORY_STEAM_VENT_NAME) as Area2D
	var enemy: Node = destination.get_node_or_null(FACTORY_ENEMY_NAME)
	var player: Node = destination.get_node_or_null(FACTORY_PLAYER_NAME)
	assert_that(hazard).is_not_null()
	assert_that(enemy).is_not_null()
	assert_that(player).is_not_null()
	if hazard == null or enemy == null or player == null:
		return

	assert_bool(bool(destination.call("apply_factory_steam_vent_contact", hazard, enemy))).is_false()
	assert_bool(bool(destination.call("apply_factory_steam_vent_contact", hazard, player))).is_true()
	var hp_after_first_contact: int = int(player.call("get_current_hp"))
	var collision: CollisionComponent = player.call("get_collision_component") as CollisionComponent
	assert_that(collision).is_not_null()
	if collision == null:
		return
	var hurtbox: Area2D = collision.get_hurtbox()
	assert_that(hurtbox).is_not_null()
	if hurtbox == null:
		return

	hazard.global_position = hurtbox.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	destination.call("advance_factory_hazard_time", EXPECTED_STEAM_COOLDOWN_SEC)
	assert_int(hp_after_first_contact - int(player.call("get_current_hp"))).is_equal(
		EXPECTED_STEAM_DAMAGE
	)

	var diagnostics: Dictionary = destination.call("get_factory_hazard_diagnostics")
	assert_bool(bool(diagnostics.get("steam_vent_present", false))).is_true()
	assert_int(int(diagnostics.get("steam_damage", 0))).is_equal(EXPECTED_STEAM_DAMAGE)
	assert_str(String(diagnostics.get("steam_vent_texture_path", ""))).is_equal(
		FACTORY_STEAM_VENT_TEXTURE_PATH
	)
	var last_damage: Dictionary = Dictionary(diagnostics.get("last_hazard_damage", {}))
	assert_str(String(last_damage.get("source", &""))).is_equal("old_factory_steam_vent")
	assert_str(String(last_damage.get("damage_type", &""))).is_equal("steam")
	assert_int(int(last_damage.get("damage", 0))).is_equal(EXPECTED_STEAM_DAMAGE)


func test_factory_hazard_route_preserves_visible_character_frame_animation_rules() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	_assert_character_animation_contract(destination, FACTORY_PLAYER_NAME, [&"idle", &"run", &"jump"])
	_assert_character_animation_contract(destination, FACTORY_ENEMY_NAME, [&"idle", &"run", &"attack"])


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var destination: Node = packed.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _assert_character_animation_contract(
	root: Node,
	character_name: String,
	required_animations: Array[StringName]
) -> void:
	var sprite: AnimatedSprite2D = root.get_node_or_null("%s/Sprite" % character_name) as AnimatedSprite2D
	assert_that(sprite).is_not_null()
	if sprite == null:
		return
	assert_bool(sprite.visible).is_true()
	assert_that(sprite.sprite_frames).is_not_null()
	if sprite.sprite_frames == null:
		return
	for animation_name: StringName in required_animations:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		if not sprite.sprite_frames.has_animation(animation_name):
			continue
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)


func _has_visible_placeholder_shape(root: Node) -> bool:
	if root is ColorRect and (root as ColorRect).visible:
		return true
	if root is Polygon2D and (root as Polygon2D).visible:
		return true
	for child: Node in root.get_children():
		if _has_visible_placeholder_shape(child):
			return true
	return false


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		if child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
