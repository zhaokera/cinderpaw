## Story 001: Weapon config catalog and base damage query.
extends GdUnitTestSuite

const WEAPON_COMPONENT_PATH: String = "res://src/core/weapon_component.gd"
const WEAPON_CONFIG_PATH: String = "res://src/core/weapon_config.gd"
const WEAPON_CONFIGS_PATH: String = "res://data/weapons/weapon_configs.json"
const WEAPON_SCHEMA_PATH: String = "res://data/schemas/weapon_configs.schema.json"
const MANIFEST_PATH: String = "res://data/manifest.json"
const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")
const SCHEMA_VALIDATOR_SCRIPT: Script = preload("res://src/foundation/schema_validator.gd")

var data_manager
var weapons


func before_test() -> void:
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)
	var script: Script = load(WEAPON_COMPONENT_PATH)
	if script != null:
		weapons = script.new()
		add_child(weapons)
		if weapons.has_method("set_data_manager"):
			weapons.set_data_manager(data_manager)


func after_test() -> void:
	if is_instance_valid(weapons):
		if weapons.get_parent() != null:
			weapons.get_parent().remove_child(weapons)
		weapons.free()
	weapons = null
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	data_manager = null


func test_weapon_component_and_config_scripts_exist() -> void:
	assert_that(load(WEAPON_COMPONENT_PATH)).override_failure_message(
		"WeaponComponent script must exist at %s" % WEAPON_COMPONENT_PATH
	).is_not_null()
	assert_that(load(WEAPON_CONFIG_PATH)).override_failure_message(
		"WeaponConfig script must exist at %s" % WEAPON_CONFIG_PATH
	).is_not_null()


func test_weapon_config_data_validates_and_manifest_registers_domain() -> void:
	var data: Dictionary = _load_json(WEAPON_CONFIGS_PATH)
	var schema: Dictionary = _load_json(WEAPON_SCHEMA_PATH)
	var manifest: Dictionary = _load_json(MANIFEST_PATH)
	var result: Variant = SCHEMA_VALIDATOR_SCRIPT.validate("weapon_configs", data, schema)

	assert_bool(result.is_valid).is_true()
	assert_array(_manifest_domain_names(manifest)).contains("weapon_configs")
	assert_dict(data.get("entries", {})).contains_keys([
		"cat_claw",
		"long_tail",
		"fish_bone",
		"electro_bell",
	])


func test_catalog_defines_four_weapons_in_swap_order() -> void:
	if not _assert_component_exists():
		return
	var expected: Array[String] = ["cat_claw", "long_tail", "fish_bone", "electro_bell"]

	assert_array(_stringify_ids(weapons.get_weapon_ids())).is_equal(expected)


func test_weapon_configs_expose_gdd_metadata() -> void:
	if not _assert_component_exists():
		return
	var cat_claw: Resource = weapons.get_weapon_config(&"cat_claw")
	var long_tail: Resource = weapons.get_weapon_config(&"long_tail")
	var fish_bone: Resource = weapons.get_weapon_config(&"fish_bone")
	var electro_bell: Resource = weapons.get_weapon_config(&"electro_bell")

	assert_str(String(cat_claw.weapon_id)).is_equal("cat_claw")
	assert_str(cat_claw.display_name).is_equal("猫爪")
	assert_str(String(cat_claw.style)).is_equal("counter")
	assert_int(cat_claw.base_damage_range.x).is_equal(10)
	assert_int(cat_claw.base_damage_range.y).is_equal(18)
	assert_float(cat_claw.attack_speed).is_equal_approx(1.5, 0.001)
	assert_float(cat_claw.attack_range).is_equal_approx(1.0, 0.001)
	assert_array(cat_claw.upgrade_damage_table).is_equal([10, 12, 14, 16, 18])
	assert_array(cat_claw.combo_multipliers).is_equal([1.0, 1.2, 1.8])
	assert_str(String(long_tail.special_mechanism["type"])).is_equal("multi_target")
	assert_str(String(fish_bone.special_mechanism["type"])).is_equal("shield_break")
	assert_str(String(electro_bell.special_mechanism["status_effect_id"])).is_equal("slow")


func test_default_weapon_and_cat_claw_level_three_damage_query() -> void:
	if not _assert_component_exists():
		return

	assert_str(String(weapons.get_current_weapon().weapon_id)).is_equal("cat_claw")
	assert_int(weapons.get_effective_base_damage()).is_equal(10)

	assert_bool(weapons.set_weapon_level(&"cat_claw", 2)).is_true()

	assert_int(weapons.get_weapon_level(&"cat_claw")).is_equal(2)
	assert_int(weapons.get_effective_base_damage()).is_equal(14)


func _assert_component_exists() -> bool:
	assert_that(weapons).override_failure_message(
		"WeaponComponent script must exist at %s" % WEAPON_COMPONENT_PATH
	).is_not_null()
	return weapons != null


func _stringify_ids(ids: Array) -> Array[String]:
	var result: Array[String] = []
	for id: Variant in ids:
		result.append(String(id))
	return result


func _manifest_domain_names(manifest: Dictionary) -> Array[String]:
	var names: Array[String] = []
	for domain: Variant in manifest.get("domains", []):
		if domain is Dictionary:
			names.append(String((domain as Dictionary).get("name", "")))
	return names


func _load_json(path: String) -> Dictionary:
	assert_bool(FileAccess.file_exists(path)).override_failure_message(
		"Missing JSON file: %s" % path
	).is_true()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_bool(parsed is Dictionary).override_failure_message(
		"Invalid JSON object: %s" % path
	).is_true()
	return parsed as Dictionary
