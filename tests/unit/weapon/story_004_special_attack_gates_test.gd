## Story 004: Weapon special attack cooldown and cat-energy gates.
extends GdUnitTestSuite

const WEAPON_COMPONENT_PATH: String = "res://src/core/weapon_component.gd"
const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")

var data_manager
var combat
var weapons


func before_test() -> void:
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)
	combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(combat)
	var script: Script = load(WEAPON_COMPONENT_PATH)
	weapons = script.new()
	add_child(weapons)
	weapons.set_data_manager(data_manager)
	weapons.set_combat_adapter(combat)


func after_test() -> void:
	if is_instance_valid(weapons):
		if weapons.get_parent() != null:
			weapons.get_parent().remove_child(weapons)
		weapons.free()
	weapons = null
	if is_instance_valid(combat):
		if combat.get_parent() != null:
			combat.get_parent().remove_child(combat)
		combat.free()
	combat = null
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	data_manager = null


func test_each_weapon_exposes_special_id_cooldown_and_energy_cost() -> void:
	if not _assert_special_api_exists():
		return
	var expected: Array[Dictionary] = [
		{"index": 0, "weapon_id": "cat_claw", "attack_id": "gale_claw", "cooldown_sec": 8.0, "required_energy": 30},
		{"index": 1, "weapon_id": "long_tail", "attack_id": "whirlwind_slash", "cooldown_sec": 10.0, "required_energy": 40},
		{"index": 2, "weapon_id": "fish_bone", "attack_id": "earth_splitter", "cooldown_sec": 12.0, "required_energy": 50},
		{"index": 3, "weapon_id": "electro_bell", "attack_id": "em_pulse", "cooldown_sec": 15.0, "required_energy": 60},
	]

	for entry: Dictionary in expected:
		weapons.deserialize({"current_weapon_index": int(entry["index"])})
		var params: Dictionary = weapons.get_special_attack_parameters()

		assert_str(String(params["weapon_id"])).is_equal(String(entry["weapon_id"]))
		assert_str(String(params["attack_id"])).is_equal(String(entry["attack_id"]))
		assert_float(float(params["cooldown_sec"])).is_equal_approx(float(entry["cooldown_sec"]), 0.001)
		assert_int(int(params["required_energy"])).is_equal(int(entry["required_energy"]))


func test_insufficient_cat_energy_rejects_special_and_emits_required_energy() -> void:
	if not _assert_special_api_exists():
		return
	var started_events: Array[String] = []
	var insufficient_events: Array[int] = []
	var cooldown_events: Array[float] = []
	if not _connect_special_signals(started_events, insufficient_events, cooldown_events):
		return
	weapons.deserialize({"current_weapon_index": 3})

	assert_bool(weapons.request_special_attack()).is_false()

	assert_array(started_events).is_empty()
	assert_array(cooldown_events).is_empty()
	assert_array(insufficient_events).is_equal([60])
	assert_int(combat.get_cat_energy()).is_equal(0)
	assert_float(combat.get_special_cooldown_remaining(&"electro_bell")).is_equal(0.0)


func test_active_cooldown_rejects_special_and_emits_remaining_cooldown() -> void:
	if not _assert_special_api_exists():
		return
	var started_events: Array[String] = []
	var insufficient_events: Array[int] = []
	var cooldown_events: Array[float] = []
	if not _connect_special_signals(started_events, insufficient_events, cooldown_events):
		return
	_fill_energy_to_max()

	assert_bool(weapons.request_special_attack()).is_true()
	assert_bool(weapons.request_special_attack()).is_false()

	assert_array(started_events).is_equal(["gale_claw"])
	assert_array(insufficient_events).is_empty()
	assert_int(combat.get_cat_energy()).is_equal(70)
	assert_int(cooldown_events.size()).is_equal(1)
	assert_float(cooldown_events[0]).is_equal_approx(8.0, 0.001)


func test_passing_gates_consumes_cat_energy_starts_cooldown_and_emits_start_signal() -> void:
	if not _assert_special_api_exists():
		return
	var started_events: Array[String] = []
	var insufficient_events: Array[int] = []
	var cooldown_events: Array[float] = []
	if not _connect_special_signals(started_events, insufficient_events, cooldown_events):
		return
	_fill_energy_to_max()

	assert_bool(weapons.request_special_attack()).is_true()

	assert_array(started_events).is_equal(["gale_claw"])
	assert_array(insufficient_events).is_empty()
	assert_array(cooldown_events).is_empty()
	assert_int(combat.get_cat_energy()).is_equal(70)
	assert_float(combat.get_special_cooldown_remaining(&"cat_claw")).is_equal(8.0)


func _assert_special_api_exists() -> bool:
	var has_api: bool = (
		weapons.has_method("get_special_attack_parameters")
		and weapons.has_method("request_special_attack")
	)
	assert_bool(has_api).is_true()
	return has_api


func _connect_special_signals(
	started_events: Array[String],
	insufficient_events: Array[int],
	cooldown_events: Array[float]
) -> bool:
	var has_signals: bool = (
		weapons.has_signal("on_special_attack_started")
		and weapons.has_signal("on_insufficient_energy")
		and weapons.has_signal("on_special_cooldown")
	)
	assert_bool(has_signals).is_true()
	if not has_signals:
		return false
	weapons.on_special_attack_started.connect(func(attack_id: StringName) -> void:
		started_events.append(String(attack_id))
	)
	weapons.on_insufficient_energy.connect(func(required_energy: int) -> void:
		insufficient_events.append(required_energy)
	)
	weapons.on_special_cooldown.connect(func(remaining_sec: float) -> void:
		cooldown_events.append(remaining_sec)
	)
	return true


func _fill_energy_to_max() -> void:
	for _index in range(5):
		combat.add_cat_energy_for_event(&"perfect_parry")
