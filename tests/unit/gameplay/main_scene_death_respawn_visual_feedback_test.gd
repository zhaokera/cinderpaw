## Death & Respawn Story008 acceptance coverage for the real Main flow.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const DEATH_WISP_TEXTURE_PATH: String = (
	"res://assets/generated/combat_player_death_soul_wisp.png"
)
const REVIVE_HALO_TEXTURE_PATH: String = (
	"res://assets/generated/combat_player_revive_halo.png"
)

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


func test_real_main_death_greys_out_then_respawn_fades_and_spawns_halo() -> void:
	var presentation: Node = scene.get_node("CombatPresentation")
	assert_bool(presentation.has_method("get_player_death_feedback_diagnostics")).is_true()
	assert_bool(presentation.has_method("get_active_player_death_wisp_count")).is_true()
	assert_bool(presentation.has_method("get_active_player_revive_halo_count")).is_true()
	if (
		not presentation.has_method("get_player_death_feedback_diagnostics")
		or not presentation.has_method("get_active_player_death_wisp_count")
		or not presentation.has_method("get_active_player_revive_halo_count")
	):
		return

	var player: PlayerController = scene.get_node("Player") as PlayerController
	var flow: GameFlowController = (
		scene.get_node("GameFlowController") as GameFlowController
	)
	flow.set_scene_transition_adapter(null)
	var sprite: AnimatedSprite2D = player.get_node("Sprite") as AnimatedSprite2D
	var death_position: Vector2 = player.global_position
	player.apply_damage(player.get_current_hp(), {
		"source": &"story008_main_death_test",
	})

	assert_str(String(flow.get_flow_state())).is_equal("dying")
	assert_str(String(sprite.animation)).is_equal("death")
	assert_bool(sprite.sprite_frames.has_animation(&"death")).is_true()
	assert_int(sprite.sprite_frames.get_frame_count(&"death")).is_equal(3)
	assert_int(int(presentation.call("get_active_player_death_wisp_count"))).is_equal(8)
	var diagnostics: Dictionary = Dictionary(
		presentation.call("get_player_death_feedback_diagnostics")
	)
	_assert_death_overlay_contract(diagnostics, &"death_fade_in", 0.0)
	assert_str(String(diagnostics.get("death_wisp_texture_path", ""))).is_equal(
		DEATH_WISP_TEXTURE_PATH
	)
	assert_vector(diagnostics.get("death_world_position", Vector2.ZERO)).is_equal(
		death_position
	)
	var feedback_layer: CanvasLayer = presentation.get_node(
		"PlayerDeathFeedbackLayer"
	) as CanvasLayer
	var vfx_layer: CanvasLayer = presentation.get_node_or_null(
		"PlayerDeathVfxLayer"
	) as CanvasLayer
	assert_object(vfx_layer).is_not_null()
	if vfx_layer != null:
		assert_int(vfx_layer.layer).is_greater(feedback_layer.layer)
		assert_object(vfx_layer.get_node_or_null("PlayerDeathSoulWisp00")).is_not_null()

	_advance_death_flow(presentation, flow, 0.25)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	_assert_death_overlay_contract(diagnostics, &"death_fade_in", 0.5)

	_advance_death_flow(presentation, flow, 0.25)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	_assert_death_overlay_contract(diagnostics, &"death_hold", 1.0)

	_advance_death_flow(presentation, flow, 1.0)
	assert_str(String(flow.get_flow_state())).is_equal("revived")
	assert_str(String(sprite.animation)).is_equal("revive")
	assert_bool(sprite.sprite_frames.has_animation(&"revive")).is_true()
	assert_int(sprite.sprite_frames.get_frame_count(&"revive")).is_equal(3)
	assert_bool(player.is_respawn_visual_active()).is_true()
	assert_int(player.get_current_hp()).is_equal(50)
	assert_int(int(presentation.call("get_active_player_death_wisp_count"))).is_equal(0)
	assert_int(int(presentation.call("get_active_player_revive_halo_count"))).is_equal(1)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	_assert_death_overlay_contract(diagnostics, &"revive_fade_out", 1.0)
	assert_str(String(diagnostics.get("revive_halo_texture_path", ""))).is_equal(
		REVIVE_HALO_TEXTURE_PATH
	)
	assert_vector(diagnostics.get("revive_world_position", Vector2.ZERO)).is_equal(
		player.global_position
	)
	if vfx_layer != null:
		assert_object(vfx_layer.get_node_or_null("PlayerReviveHalo")).is_not_null()

	_advance_death_flow(presentation, flow, 0.25)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	_assert_death_overlay_contract(diagnostics, &"revive_fade_out", 0.5)

	_advance_death_flow(presentation, flow, 0.25)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	assert_bool(bool(diagnostics.get("overlay_visible", true))).is_false()
	assert_float(float(diagnostics.get("grayscale_amount", 1.0))).is_equal_approx(
		0.0,
		0.001
	)
	assert_int(int(presentation.call("get_active_player_revive_halo_count"))).is_equal(1)

	_advance_death_flow(presentation, flow, 0.5)
	assert_int(int(presentation.call("get_active_player_revive_halo_count"))).is_equal(0)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	assert_str(String(diagnostics.get("phase", ""))).is_equal("idle")


func _assert_death_overlay_contract(
	diagnostics: Dictionary,
	expected_phase: StringName,
	expected_grayscale: float
) -> void:
	assert_bool(bool(diagnostics.get("overlay_visible", false))).is_true()
	assert_str(String(diagnostics.get("phase", ""))).is_equal(String(expected_phase))
	assert_str(String(diagnostics.get("layer_name", ""))).is_equal(
		"PlayerDeathFeedbackLayer"
	)
	assert_str(String(diagnostics.get("overlay_name", ""))).is_equal(
		"PlayerDeathGrayscale"
	)
	assert_str(String(diagnostics.get("overlay_type", ""))).is_equal("ColorRect")
	assert_str(String(diagnostics.get("material_type", ""))).is_equal("ShaderMaterial")
	assert_vector(diagnostics.get("overlay_size", Vector2.ZERO)).is_equal(
		Vector2(1280, 720)
	)
	assert_float(float(diagnostics.get("grayscale_amount", -1.0))).is_equal_approx(
		expected_grayscale,
		0.001
	)


func _advance_death_flow(
	presentation: Node,
	flow: GameFlowController,
	delta_sec: float
) -> void:
	presentation.call("advance_time", delta_sec)
	flow.advance_time(delta_sec)
