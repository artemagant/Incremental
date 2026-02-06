extends Upgrades_Class
class_name Upgrade_Earn_Class

@export var earn: int = 0
var button_label: = "+Earn"
var total_earn: = 0

func _ready() -> void:
	if number == 1:
		unlock_cost = 0

func apply_buy(main: Main):
	total_earn += earn
	main.highlight_effect(main.earn_per_second_label, Data.GREEN, Data.WHITE)

func new_max_level(main: Main):
	main.starting_crit_chance += 0.005
	main.starting_crit_mult *= 1.05
	main.highlight_effect(main.crit_mult_label, Data.ORANGE, Data.WHITE)
	main.highlight_effect(main.crit_chance_label, Data.ORANGE, Data.WHITE)

func reset():
	total_earn = 0
	is_max_level = false
	level = 0
	cost = default_cost
	level_count_slider.value = 0
