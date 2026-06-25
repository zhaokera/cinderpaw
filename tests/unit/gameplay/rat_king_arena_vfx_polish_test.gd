## Rat King final arena VFX polish integration.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_BOSS_ID: StringName = &"boss_01_rat_king"
const EXPECTED_VFX_TEXTURE_PATHS: Dictionary = {
	"garbage_pile": [
		"res://assets/environment/rat_king_arena/vfx/arena_debris_dust.png",
	],
	"overturned_trash_can": [
		"res://assets/environment/rat_king_arena/vfx/arena_debris_dust.png",
	],
	"electric_leak": [
		"res://assets/environment/rat_king_arena/vfx/electric_leak_hazard_glow.png",
		"res://assets/environment/rat_king_arena/vfx/electric_leak_spark.png",
	],
}
const EXPECTED_VFX_ROLES: Dictionary = {
	"garbage_pile": [&"debris_dust"],
	"overturned_trash_can": [&"debris_dust"],
	"electric_leak": [&"hazard_glow", &"electric_spark"],
}

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_arena_mutations_spawn_generated_vfx_layers() -> void:
	_spawn_all_arena_mutations()

	for change_id: String in EXPECTED_VFX_TEXTURE_PATHS.keys():
		_assert_mutation_vfx_contract(_find_mutation(StringName(change_id)), StringName(change_id))


func test_electric_leak_has_hazard_glow_and_spark_roles() -> void:
	_spawn_all_arena_mutations()

	var electric_leak: Node = _find_mutation(&"electric_leak")
	_assert_mutation_vfx_contract(electric_leak, &"electric_leak")

	var vfx := electric_leak.get_node_or_null("Vfx") as Node2D
	if vfx == null:
		return
	assert_object(vfx.get_node_or_null("HazardGlow")).is_not_null()
	assert_object(vfx.get_node_or_null("ElectricSpark")).is_not_null()
	assert_str(String(vfx.get_meta(&"vfx_role", &""))).is_equal("electric_hazard")


func test_reapplying_arena_changes_does_not_duplicate_vfx_children() -> void:
	_spawn_all_arena_mutations()
	var initial_mutation_count: int = (scene.call("get_arena_mutation_nodes") as Array).size()
	var initial_counts: Dictionary = _collect_vfx_child_counts()

	_spawn_all_arena_mutations()

	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(
		initial_mutation_count
	)
	assert_dict(_collect_vfx_child_counts()).is_equal(initial_counts)


func test_cleanup_and_reapply_restores_vfx_layers() -> void:
	_spawn_all_arena_mutations()
	scene.call("cleanup_arena_mutations", RAT_KING_BOSS_ID)

	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(0)
	assert_int(_count_arena_vfx_nodes()).is_equal(0)

	scene.call("apply_arena_changes", RAT_KING_BOSS_ID, 3, [{
		"id": "electric_leak",
		"type": "damage_zone",
	}])

	_assert_mutation_vfx_contract(_find_mutation(&"electric_leak"), &"electric_leak")


func _spawn_all_arena_mutations() -> void:
	scene.call("apply_arena_changes", RAT_KING_BOSS_ID, 2, [{
		"id": "garbage_pile",
		"type": "obstacle",
	}])
	scene.call("apply_arena_changes", RAT_KING_BOSS_ID, 3, [{
		"id": "overturned_trash_can",
		"type": "obstacle",
	}, {
		"id": "electric_leak",
		"type": "damage_zone",
	}])


func _find_mutation(change_id: StringName) -> Node:
	var mutations: Array = scene.call("get_arena_mutation_nodes")
	for mutation: Node in mutations:
		if StringName(String(mutation.get_meta(&"change_id", &""))) == change_id:
			return mutation
	return null


func _assert_mutation_vfx_contract(mutation: Node, change_id: StringName) -> void:
	assert_object(mutation).is_not_null()
	if mutation == null:
		return
	_assert_original_mutation_contract_still_present(mutation, change_id)
	var vfx := mutation.get_node_or_null("Vfx") as Node2D
	assert_object(vfx).is_not_null()
	if vfx == null:
		return
	assert_bool(vfx.visible).is_true()
	assert_str(String(vfx.get_meta(&"change_id", &""))).is_equal(String(change_id))
	assert_str(String(vfx.get_meta(&"asset_source", &""))).is_equal("image_generation")

	var expected_paths: Array = Array(EXPECTED_VFX_TEXTURE_PATHS[String(change_id)])
	var expected_roles: Array = Array(EXPECTED_VFX_ROLES[String(change_id)])
	var texture_paths: Array[String] = []
	var roles: Array[StringName] = []
	for child: Node in vfx.get_children():
		if not child is Sprite2D:
			continue
		var sprite := child as Sprite2D
		var role := StringName(String(sprite.get_meta(&"vfx_role", &"")))
		roles.append(role)
		assert_bool(sprite.visible).is_true()
		assert_int(sprite.z_index).is_greater_equal(2)
		assert_str(String(sprite.get_meta(&"change_id", &""))).is_equal(String(change_id))
		assert_str(String(sprite.get_meta(&"asset_source", &""))).is_equal("image_generation")
		assert_object(sprite.texture).is_not_null()
		if sprite.texture == null:
			continue
		assert_int(sprite.texture.get_width()).is_greater(0)
		assert_int(sprite.texture.get_height()).is_greater(0)
		texture_paths.append(sprite.texture.resource_path)
		assert_bool(
			sprite.texture.resource_path.begins_with(
				"res://assets/environment/rat_king_arena/vfx/"
			)
		).is_true()

	assert_int(texture_paths.size()).is_greater_equal(expected_paths.size())
	for expected_path: String in expected_paths:
		assert_bool(FileAccess.file_exists(expected_path)).is_true()
		assert_array(texture_paths).contains(expected_path)
	for expected_role: StringName in expected_roles:
		assert_array(roles).contains(expected_role)


func _assert_original_mutation_contract_still_present(
	mutation: Node,
	change_id: StringName
) -> void:
	assert_object(mutation.get_node_or_null("CollisionShape2D")).is_not_null()
	assert_bool(mutation.get_node_or_null("Visual") is Polygon2D).is_true()
	assert_bool(mutation.get_node_or_null("Sprite") is Sprite2D).is_true()
	if change_id == &"electric_leak":
		assert_bool(mutation is Area2D).is_true()
		if mutation is Area2D:
			var damage_zone := mutation as Area2D
			assert_int(damage_zone.collision_layer).is_equal(
				CollisionComponent.COLLISION_LAYER_ENVIRONMENT
			)
			assert_int(damage_zone.collision_mask).is_equal(
				CollisionComponent.COLLISION_MASK_ENVIRONMENT
			)
			assert_bool(damage_zone.monitoring).is_true()
			assert_bool(damage_zone.monitorable).is_false()
	else:
		assert_bool(mutation is StaticBody2D).is_true()


func _collect_vfx_child_counts() -> Dictionary:
	var counts: Dictionary = {}
	for mutation: Node in scene.call("get_arena_mutation_nodes"):
		var change_id: String = String(mutation.get_meta(&"change_id", &""))
		var vfx := mutation.get_node_or_null("Vfx") as Node2D
		counts[change_id] = 0 if vfx == null else vfx.get_child_count()
	return counts


func _count_arena_vfx_nodes() -> int:
	var container := scene.get_node_or_null("ArenaMutations") as Node
	if container == null:
		return 0
	return _count_named_nodes(container, "Vfx")


func _count_named_nodes(root: Node, target_name: String) -> int:
	var count: int = 1 if root.name == target_name else 0
	for child: Node in root.get_children():
		count += _count_named_nodes(child, target_name)
	return count
