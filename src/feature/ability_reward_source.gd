## Scene-local one-shot reward source for unlocking a player ability.
class_name AbilityRewardSource
extends Node2D

@export var reward_id: StringName = &""
@export var ability_id: StringName = &""
@export var world_flag_id: StringName = &""
@export var starts_available: bool = true
@export var claim_radius_px: float = 96.0
@export var prompt_radius_px: float = 192.0
@export var locked_prompt_text: String = "Locked"
@export var available_prompt_text: String = "Claim ability"
@export var claimed_prompt_text: String = "Echo claimed"

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D
@onready var _prompt_label: Label = get_node_or_null("PromptLabel") as Label
@onready var _interaction_area: Area2D = get_node_or_null("InteractionArea") as Area2D

var _claimed: bool = false
var _available: bool = true
var _prompt_provider: Node = null


func _ready() -> void:
	add_to_group("ability_reward_source")
	_available = starts_available
	_sync_claimed_state()


func get_reward_id() -> StringName:
	return reward_id


func get_ability_id() -> StringName:
	return ability_id


func get_world_flag_id() -> StringName:
	return world_flag_id


func get_visual_texture_path() -> String:
	if _visual == null or _visual.texture == null:
		return ""
	return _visual.texture.resource_path


func get_visual_modulate() -> Color:
	return _visual.modulate if _visual != null else Color.TRANSPARENT


func get_prompt_text() -> String:
	return _prompt_text()


func is_prompt_visible() -> bool:
	return _prompt_label != null and _prompt_label.visible


func is_claimed() -> bool:
	return _claimed


func is_available() -> bool:
	return _available


func is_claim_available() -> bool:
	return _available and not _claimed


func set_available(available: bool) -> void:
	_available = available
	_sync_claimed_state()


func set_claimed(claimed: bool) -> void:
	if _claimed == claimed:
		_sync_claimed_state()
		return
	_claimed = claimed
	_sync_claimed_state()


func set_prompt_provider(provider: Node) -> void:
	_prompt_provider = provider
	_sync_claimed_state()


func is_provider_in_reward_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	var provider_node := provider as Node2D
	return global_position.distance_to(provider_node.global_position) <= claim_radius_px


func try_claim(provider: Node = null) -> bool:
	if not is_claim_available():
		return false
	if provider != null and not is_provider_in_reward_range(provider):
		return false
	set_claimed(true)
	return true


func _sync_claimed_state() -> void:
	if _visual != null:
		if _claimed:
			_visual.modulate = Color(0.42, 0.48, 0.62, 0.35)
		elif _available:
			_visual.modulate = Color.WHITE
		else:
			_visual.modulate = Color(0.56, 0.62, 0.72, 0.48)
	if _prompt_label != null:
		_prompt_label.text = _prompt_text()
		_prompt_label.visible = is_claim_available() and _is_prompt_provider_in_range()
	if _interaction_area != null:
		_interaction_area.monitoring = is_claim_available()
		_interaction_area.monitorable = is_claim_available()


func _is_prompt_provider_in_range() -> bool:
	if not is_instance_valid(_prompt_provider) or not _prompt_provider is Node2D:
		return false
	var provider_node := _prompt_provider as Node2D
	var safe_prompt_radius_px: float = maxf(prompt_radius_px, claim_radius_px)
	return global_position.distance_to(provider_node.global_position) <= safe_prompt_radius_px


func _prompt_text() -> String:
	if _claimed:
		return claimed_prompt_text
	if _available:
		return available_prompt_text
	return locked_prompt_text
