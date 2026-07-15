## Combat Presentation Story025: Crown Warden death holds before its payoff.
extends GdUnitTestSuite

const ARENA_SCENE: PackedScene = preload(
	"res://scenes/bosses/crown_warden_arena.tscn"
)
const ARENA_SCENE_ID: StringName = &"boss_04_crown_warden_arena"
const BOSS_ENTITY_ID: int = 2400
const DEFEATED_KEY: String = "boss_04_crown_warden_defeated"
const HOLD_SEC: float = 2.0


class FakeSceneManager:
	extends RefCounted

	var locked: bool = false
	var states: Dictionary = {}

	func request_scene_change(_scene_id: StringName, _spawn: StringName) -> bool:
		return not locked

	func has_scene(_scene_id: StringName) -> bool:
		return false

	func is_scene_locked() -> bool:
		return locked

	func lock_scene() -> void:
		locked = true

	func unlock_scene() -> void:
		locked = false

	func set_scene_state(scene_id: StringName, state: Dictionary) -> bool:
		states[String(scene_id)] = state.duplicate(true)
		return true


var _arena: Node
var _boss: Node
var _presentation: CombatPresentation
var _input_manager: Node
var _scene_manager: FakeSceneManager


func before_test() -> void:
	Input.action_release(&"attack")
	get_tree().paused = false
	_input_manager = get_node("/root/InputManager")
	_input_manager.call("clear_buffer")
	_input_manager.call("notify_animation_lock", 0)
	_arena = ARENA_SCENE.instantiate()
	add_child(_arena)
	_arena.set_process(false)
	_boss = _arena.get_node("CrownWardenBoss")
	_boss.call("set_autonomous_attacks_enabled", false)
	_presentation = _arena.get_node("CombatPresentation") as CombatPresentation
	_scene_manager = FakeSceneManager.new()
	assert_bool(bool(_arena.call(
		"configure_scene_manager_runtime",
		_scene_manager
	))).is_true()


func after_test() -> void:
	get_tree().paused = false
	Input.action_release(&"attack")
	if _input_manager != null:
		_input_manager.call("clear_buffer")
		_input_manager.call("notify_animation_lock", 0)
	_stop_runtime_audio_players()
	if is_instance_valid(_arena):
		if _arena.get_parent() != null:
			_arena.get_parent().remove_child(_arena)
		_arena.free()
	_arena = null
	_boss = null
	_presentation = null
	_input_manager = null
	_scene_manager = null


func test_crown_warden_death_holds_locked_arena_before_reward_payoff() -> void:
	assert_bool(_arena.has_method(
		"get_boss4_death_presentation_diagnostics"
	)).is_true()
	assert_bool(_arena.has_method("advance_boss4_death_presentation")).is_true()
	if (
		not _arena.has_method("get_boss4_death_presentation_diagnostics")
		or not _arena.has_method("advance_boss4_death_presentation")
	):
		return

	assert_bool(bool(_arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		int(_boss.call("get_current_hp")),
		{"source": &"story025_crown_warden_death_hold"}
	))).is_true()

	var holding: Dictionary = _arena.call(
		"get_boss4_death_presentation_diagnostics"
	)
	_assert_holding_contract(holding)
	assert_bool(bool(Dictionary(_arena.call("get_local_state")).get(
		DEFEATED_KEY,
		false
	))).is_true()
	assert_bool(bool(Dictionary(_scene_manager.states.get(
		String(ARENA_SCENE_ID),
		{}
	)).get(DEFEATED_KEY, false))).override_failure_message(
		"Durable Boss4 defeat must persist before the transient hold ends"
	).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(6)
	assert_int(_presentation.get_active_debris_count()).is_equal(18)

	assert_bool(bool(_input_manager.call(
		"accept_action",
		&"attack",
		Time.get_ticks_msec() - 1,
		&"kbm"
	))).is_true()
	while _presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame
	var buffered_result: Dictionary = _arena.call(
		"get_last_buffered_input_result"
	)
	assert_str(String(buffered_result.get("action_id", &""))).is_equal("attack")
	assert_bool(bool(buffered_result.get("accepted", true))).override_failure_message(
		"Buffered attack must not pierce the Boss4 victory control lock"
	).is_false()
	assert_int(int(buffered_result.get("dispatch_count", 0))).is_equal(1)
	assert_str(String(_input_manager.call("get_input_state"))).is_equal("direct")
	assert_int(int(_input_manager.call("get_buffered_action_count"))).is_equal(0)

	assert_bool(bool(_arena.call(
		"advance_boss4_death_presentation",
		0.5
	))).is_false()
	var before_duplicate: Dictionary = _arena.call(
		"get_boss4_death_presentation_diagnostics"
	)
	_arena.call("_on_boss4_defeated")
	var after_duplicate: Dictionary = _arena.call(
		"get_boss4_death_presentation_diagnostics"
	)
	assert_float(float(after_duplicate.get("remaining_sec", -1.0))).is_equal_approx(
		float(before_duplicate.get("remaining_sec", -2.0)),
		0.001
	)
	assert_int(int(after_duplicate.get("reveal_vfx_spawn_count", -1))).is_equal(0)

	assert_bool(bool(_arena.call(
		"advance_boss4_death_presentation",
		HOLD_SEC - 0.51
	))).is_false()
	assert_bool(bool(_arena.call(
		"advance_boss4_death_presentation",
		0.02
	))).is_true()
	var completed: Dictionary = _arena.call(
		"get_boss4_death_presentation_diagnostics"
	)
	assert_bool(bool(completed.get("pending", true))).is_false()
	assert_float(float(completed.get("remaining_sec", -1.0))).is_equal_approx(
		0.0,
		0.001
	)
	assert_bool(bool(completed.get("reward_visible", false))).is_true()
	assert_bool(bool(completed.get("reward_available", false))).is_true()
	assert_bool(bool(completed.get("room_seals_enabled", true))).is_false()
	assert_bool(bool(completed.get("return_route_available", false))).is_true()
	assert_bool(bool(completed.get("scene_manager_locked", true))).is_false()
	assert_bool(bool(completed.get("player_control_locked", true))).is_false()
	assert_int(int(completed.get("reveal_vfx_spawn_count", 0))).is_equal(1)

	_arena.call("set_local_state", {
		DEFEATED_KEY: true,
		"boss_04_wall_climb_reward_claimed": false,
		"unlocked_abilities": [],
	})
	var restored: Dictionary = _arena.call(
		"get_boss4_death_presentation_diagnostics"
	)
	assert_bool(bool(restored.get("pending", true))).is_false()
	assert_bool(bool(restored.get("reward_available", false))).is_true()
	assert_bool(bool(restored.get("player_control_locked", true))).is_false()
	assert_int(int(restored.get("reveal_vfx_spawn_count", -1))).is_equal(0)


func _assert_holding_contract(diagnostics: Dictionary) -> void:
	assert_bool(bool(diagnostics.get("pending", false))).is_true()
	assert_float(float(diagnostics.get("remaining_sec", -1.0))).is_equal_approx(
		HOLD_SEC,
		0.001
	)
	assert_bool(bool(diagnostics.get("boss_defeated", false))).is_true()
	assert_bool(bool(diagnostics.get("boss_visible", false))).is_true()
	assert_str(String(diagnostics.get("animation", ""))).is_equal("death")
	assert_int(int(diagnostics.get("death_frame_count", 0))).is_equal(3)
	assert_int(int(diagnostics.get("active_hitbox_count", -1))).is_equal(0)
	assert_bool(bool(diagnostics.get("reward_visible", true))).is_false()
	assert_bool(bool(diagnostics.get("reward_available", true))).is_false()
	assert_bool(bool(diagnostics.get("room_seals_enabled", false))).is_true()
	assert_bool(bool(diagnostics.get("return_route_available", true))).is_false()
	assert_bool(bool(diagnostics.get("recall_route_available", true))).is_false()
	assert_bool(bool(diagnostics.get("scene_manager_locked", false))).is_true()
	assert_bool(bool(diagnostics.get("player_control_locked", false))).is_true()
	assert_int(int(diagnostics.get("reveal_vfx_spawn_count", -1))).is_equal(0)


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("stop_music"):
		audio_system.call("stop_music", 0.0)
	if audio_system.has_method("stop_ambient"):
		audio_system.call("stop_ambient", 0.0)
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
