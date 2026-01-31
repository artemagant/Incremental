extends Button
class_name Upgrades_Class

@export var max_level: = 0
var is_max_level: = false
@export var cost: float = 0
@export var cost_mult: float = 0
@export var number: = 0
@export var level_count_slider: HSlider
var level: = 0
var default_cost: float
func _ready() -> void:
	default_cost = cost

func get_key(upgrade: Upgrades_Class) -> String:
	return "%s_%s" %[upgrade.button_label, number]
