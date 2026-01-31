extends Upgrades_Class
class_name Upgrade_Crit_Mult_Class

@export var crit_mult_plus: float = 0
var button_label: = "xCrit"
var total_crit_mult_plus: float = 0

func apply_buy():
	total_crit_mult_plus += crit_mult_plus

func new_max_level(main: Node2D):
	main.crit_chance += 0.01
	main.starting_earn_per_second *= 1.05
	main.highlight_effect(main.earn_per_second_label, Color(0.0, 1.0, 0.0, 1.0), Color(1.0, 1.0, 1.0, 1.0))
	main.highlight_effect(main.crit_chance_label, Color(0.0, 1.0, 0.0, 1.0), Color(1.0, 1.0, 1.0, 1.0))

func reset():
	total_crit_mult_plus = 0
	is_max_level = false
	level = 0
	cost = default_cost
	level_count_slider.value = 0
