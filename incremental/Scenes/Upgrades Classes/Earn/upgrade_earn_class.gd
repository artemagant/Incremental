extends Upgrades_Class
class_name Upgrade_Earn_Class

@export var earn: int = 0
var button_label: = "Earn"
var total_earn: = 0

func apply_buy():
	total_earn += earn

func new_max_level(main: Node2D):
	main.crit_chance += 0.01
	main.starting_crit_mult *= 1.05
	main.highlight_effect(main.crit_mult_label, Color(0.0, 1.0, 0.0, 1.0), Color(1.0, 1.0, 1.0, 1.0))
	main.highlight_effect(main.crit_chance_label, Color(0.0, 1.0, 0.0, 1.0), Color(1.0, 1.0, 1.0, 1.0))

func reset():
	total_earn = 0
	is_max_level = false
	level = 0
	cost = default_cost
	level_count_slider.value = 0
