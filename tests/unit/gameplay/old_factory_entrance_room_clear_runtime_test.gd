## Player Abilities Story 008: Old Factory room clear cache runtime contract.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_CACHE_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_combat_cache/factory_combat_cache.png"
)
const FACTORY_CACHE_NAME: String = "FactoryCombatCache"
const FACTORY_CACHE_PLATFORM_NAME: String = "FactoryCachePlatform"
const FACTORY_ENEMY_NAME: String = "FactoryRatMinion"
const FACTORY_PLAYER_NAME: String = "Player"
const MIN_DOUBLE_JUMP_ROUTE_DELTA_Y: float = 96.0

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


func test_factory_entrance_has_double_jump_cache_platform_and_generated_cache_prop() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_str(String(destination.get_meta("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_bool(FileAccess.file_exists(FACTORY_CACHE_TEXTURE_PATH)).is_true()
	assert_bool(_has_visible_placeholder_shape(destination)).is_false()

	var platform: StaticBody2D = destination.get_node_or_null(
		FACTORY_CACHE_PLATFORM_NAME
	) as StaticBody2D
	assert_that(platform).is_not_null()
	assert_that(destination.get_node_or_null("%s/CollisionShape2D" % FACTORY_CACHE_PLATFORM_NAME)).is_not_null()

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var cache: Node2D = destination.get_node_or_null(FACTORY_CACHE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(cache).is_not_null()
	if player == null or cache == null:
		return
	assert_float(player.global_position.y - cache.global_position.y).is_greater_equal(
		MIN_DOUBLE_JUMP_ROUTE_DELTA_Y
	)
	assert_bool(cache.visible).is_true()
	assert_bool(cache.has_method("get_cache_id")).is_true()
	assert_bool(cache.has_method("get_visual_texture_path")).is_true()
	assert_str(String(cache.call("get_cache_id"))).is_equal("old_factory_entrance_cache")
	assert_str(String(cache.call("get_visual_texture_path"))).is_equal(FACTORY_CACHE_TEXTURE_PATH)


func test_factory_cache_unlocks_after_enemy_defeat_and_claims_once() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var enemy: Node = destination.get_node_or_null(FACTORY_ENEMY_NAME)
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var cache: Node2D = destination.get_node_or_null(FACTORY_CACHE_NAME) as Node2D
	assert_that(enemy).is_not_null()
	assert_that(player).is_not_null()
	assert_that(cache).is_not_null()
	if enemy == null or player == null or cache == null:
		return

	assert_bool(destination.has_method("is_encounter_cleared")).is_true()
	assert_bool(destination.has_method("try_claim_factory_cache")).is_true()
	assert_bool(destination.has_method("get_factory_room_clear_diagnostics")).is_true()
	assert_bool(bool(destination.call("is_encounter_cleared"))).is_false()
	assert_bool(bool(cache.call("is_claim_available"))).is_false()
	assert_bool(bool(destination.call("try_claim_factory_cache", player))).is_false()

	if enemy.has_method("kill_summon"):
		enemy.call("kill_summon", &"unit_test_room_clear")
	else:
		enemy.call("apply_damage", int(enemy.call("get_current_hp")), {})
	await get_tree().process_frame

	assert_bool(bool(destination.call("is_encounter_cleared"))).is_true()
	assert_bool(bool(cache.call("is_claim_available"))).is_true()
	player.global_position = cache.global_position
	assert_bool(bool(destination.call("try_claim_factory_cache", player))).is_true()
	assert_bool(bool(destination.call("try_claim_factory_cache", player))).is_false()

	var diagnostics: Dictionary = destination.call("get_factory_room_clear_diagnostics")
	var reward: Dictionary = Dictionary(diagnostics.get("last_cache_reward", {}))
	assert_bool(bool(diagnostics.get("cache_claimed", false))).is_true()
	assert_str(String(reward.get("cache_id", ""))).is_equal("old_factory_entrance_cache")
	assert_int(int(reward.get("gears", 0))).is_equal(10)


func test_factory_cache_state_restores_room_clear_and_claimed_state() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("set_local_state")).is_true()
	assert_bool(destination.has_method("get_local_state")).is_true()
	destination.call("set_local_state", {
		"encounter_cleared": true,
		"factory_cache_claimed": true,
		"last_cache_reward": {
			"cache_id": "old_factory_entrance_cache",
			"gears": 10,
		},
	})

	var cache: Node = destination.get_node_or_null(FACTORY_CACHE_NAME)
	assert_that(cache).is_not_null()
	if cache == null:
		return
	assert_bool(bool(destination.call("is_encounter_cleared"))).is_true()
	assert_bool(bool(cache.call("is_claimed"))).is_true()
	assert_bool(bool(cache.call("is_claim_available"))).is_false()
	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(local_state.has("encounter_cleared")).is_true()
	assert_bool(local_state.has("factory_cache_claimed")).is_true()
	assert_bool(bool(local_state.get("encounter_cleared", false))).is_true()
	assert_bool(bool(local_state.get("factory_cache_claimed", false))).is_true()


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
