## Tuning knob metadata and resolved runtime values.
##
## Owned by DataManager's internal TuningKnobRegistry.
class_name TuningKnobEntry
extends RefCounted

var id: StringName
var type: StringName
var default_value: Variant
var min_value: Variant
var max_value: Variant
var domain: StringName
var current_value: Variant
var json_value: Variant
var debug_override: Variant
var has_json_value: bool = false
var has_debug_override: bool = false
