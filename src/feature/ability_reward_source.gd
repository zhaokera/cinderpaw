## Scene-local one-shot reward source for unlocking a player ability.
class_name AbilityRewardSource
extends Node2D

@export var reward_id: StringName = &""
@export var ability_id: StringName = &""
@export var world_flag_id: StringName = &""
@export var claim_radius_px: float = 96.0
@export var available_prompt_text: String = "Claim ability"
@export var claimed_prompt_text: String = "Echo claimed"

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D
@onready var _prompt_label: Label = get_node_or_null("PromptLabel") as Label
@onready var _interaction_area: Area2D = get_node_or_null("InteractionArea") as Area2D

var _claimed: bool = false


func _ready() -> void:
	add_to_group("ability_reward_source")
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


func is_claimed() -> bool:
	return _claimed


func is_claim_available() -> bool:
	return not _claimed


func set_claimed(claimed: bool) -> void:
	if _claimed == claimed:
		_sync_claimed_state()
		return
	_claimed = claimed
	_sync_claimed_state()


func is_provider_in_reward_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	var provider_node := provider as Node2D
	return global_position.distance_to(provider_node.global_position) <= claim_radius_px


func try_claim(provider: Node = null) -> bool:
	if _claimed:
		return false
	if provider != null and not is_provider_in_reward_range(provider):
		return false
	set_claimed(true)
	return true


func _sync_claimed_state() -> void:
	if _visual != null:
		_visual.modulate = Color(0.42, 0.48, 0.62, 0.35) if _claimed else Color.WHITE
	if _prompt_label != null:
		_prompt_label.text = claimed_prompt_text if _claimed else available_prompt_text
		_prompt_label.visible = not _claimed
	if _interaction_area != null:
		_interaction_area.monitoring = not _claimed
		_interaction_area.monitorable = not _claimed
