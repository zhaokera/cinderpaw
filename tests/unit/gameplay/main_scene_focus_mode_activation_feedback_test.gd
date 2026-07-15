## Story154 acceptance coverage for the real Main low-HP focus transition.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const FOCUS_TEXTURE_PATH: String = (
	"res://assets/generated/combat_focus_mode_edge_flash_overlay.png"
)

var scene: Node2D


class FakeAudioSystem:
	extends RefCounted

	var focus_events: Array[Dictionary] = []

	func on_scene_load_started(
		_scene_id: StringName,
		_spawn_point: StringName,
		_metadata: Dictionary
	) -> void:
		pass

	func on_focus_mode_changed(entity_id: int, active: bool, metadata: Dictionary) -> bool:
		focus_events.append({
			"entity_id": entity_id,
			"active": active,
			"metadata": metadata.duplicate(true),
		})
		return true


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_real_main_focus_entry_shows_gold_edge_overlay_and_routes_audio_once() -> void:
	var presentation: Node = scene.get_node("CombatPresentation")
	assert_bool(presentation.has_method("get_focus_mode_activation_diagnostics")).is_true()
	assert_bool(presentation.has_method("get_active_focus_mode_overlay_count")).is_true()
	if (
		not presentation.has_method("get_focus_mode_activation_diagnostics")
		or not presentation.has_method("get_active_focus_mode_overlay_count")
	):
		return

	var audio_system := FakeAudioSystem.new()
	assert_bool(bool(scene.call("configure_audio_system_runtime", audio_system))).is_true()
	var health: HealthComponent = scene.get_node("Player/HealthComponent") as HealthComponent
	assert_object(health).is_not_null()
	if health == null:
		return
	health.set_active_enemy_count(1)
	health.apply_damage(75, {"source": &"story154_test"})

	assert_bool(health.is_focus_mode_active()).is_true()
	assert_int(int(presentation.call("get_active_focus_mode_overlay_count"))).is_equal(1)
	var diagnostics: Dictionary = Dictionary(
		presentation.call("get_focus_mode_activation_diagnostics")
	)
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_str(String(diagnostics.get("node_name", ""))).is_equal(
		"FocusModeActivationOverlay"
	)
	assert_str(String(diagnostics.get("node_type", ""))).is_equal("TextureRect")
	assert_str(String(diagnostics.get("texture_path", ""))).is_equal(FOCUS_TEXTURE_PATH)
	assert_str(String(diagnostics.get("edge_color", ""))).is_equal("ecc94b")
	assert_float(float(diagnostics.get("duration_sec", 0.0))).is_equal_approx(0.3, 0.001)
	assert_float(float(diagnostics.get("remaining_sec", 0.0))).is_equal_approx(0.3, 0.001)
	assert_float(float(diagnostics.get("alpha", 0.0))).is_equal_approx(1.0, 0.001)
	assert_vector(diagnostics.get("size", Vector2.ZERO)).is_equal(Vector2(1280, 720))

	assert_int(audio_system.focus_events.size()).is_equal(1)
	if audio_system.focus_events.size() == 1:
		var event: Dictionary = audio_system.focus_events[0]
		assert_bool(bool(event.get("active", false))).is_true()
		var metadata: Dictionary = Dictionary(event.get("metadata", {}))
		assert_str(String(metadata.get("edge_flash_color", ""))).is_equal("#ECC94B")
		assert_float(float(metadata.get("edge_flash_duration_sec", 0.0))).is_equal_approx(
			0.3,
			0.001
		)

	presentation.call("advance_time", 0.15)
	diagnostics = Dictionary(presentation.call("get_focus_mode_activation_diagnostics"))
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_float(float(diagnostics.get("alpha", 0.0))).is_equal_approx(0.5, 0.001)

	presentation.call("advance_time", 0.15)
	assert_int(int(presentation.call("get_active_focus_mode_overlay_count"))).is_equal(0)
	diagnostics = Dictionary(presentation.call("get_focus_mode_activation_diagnostics"))
	assert_bool(bool(diagnostics.get("visible", true))).is_false()
	assert_float(float(diagnostics.get("alpha", 1.0))).is_equal_approx(0.0, 0.001)

	health.heal(10)
	assert_bool(health.is_focus_mode_active()).is_false()
	assert_int(audio_system.focus_events.size()).is_equal(2)
	assert_bool(bool(audio_system.focus_events[1].get("active", true))).is_false()
	assert_int(int(presentation.call("get_active_focus_mode_overlay_count"))).is_equal(0)
