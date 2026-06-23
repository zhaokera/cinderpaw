## Schema 验证结果数据类。
##
## 包含验证是否通过和所有错误信息。
## ADR-0003: 数据管理架构
class_name ValidationResult

## 验证是否通过（无错误）
var is_valid: bool = true

## 验证错误列表，格式: "domain_name.entry_id.field_name: 错误描述"
var errors: Array[String] = []


func _init() -> void:
	pass


## 添加一条验证错误，同时将 is_valid 设为 false。
func add_error(message: String) -> void:
	errors.append(message)
	is_valid = false
