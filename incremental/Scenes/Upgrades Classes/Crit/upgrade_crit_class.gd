extends Upgrades_Class
class_name Upgrade_Crit_Mult_Class

@export var crit_mult_plus: float = 0
var button_label: = "xCrit"
var total_crit_mult_plus: float = 0

func apply_buy(main: Main):
	total_crit_mult_plus += crit_mult_plus
	main.highlight_effect(main.crit_mult_label, Data.GREEN, Data.WHITE)

func new_max_level(main: Main):
	main.starting_crit_chance += 0.005
	main.earn_mult *= 1.05
	main.highlight_effect(main.earn_per_second_label, Data.ORANGE, Data.WHITE)
	main.highlight_effect(main.crit_chance_label, Data.ORANGE, Data.WHITE)

func reset():
	total_crit_mult_plus = 0
	is_max_level = false
	level = 0
	cost = default_cost
	level_count_slider.value = 0
