extends Upgrades_Class
class_name Upgrade_Crit_Chance_Class


@export var chance_plus: = 0.0
var button_label: = "%Crit"
var total_chance_plus: = 0.0

func apply_buy(main: Main):
	total_chance_plus += chance_plus
	main.highlight_effect(main.crit_chance_label, Data.GREEN, Data.WHITE)

func new_max_level(main: Main):
	main.starting_crit_mult *= 1.05
	main.earn_mult *= 1.05
	main.highlight_effect(main.earn_per_second_label, Data.ORANGE, Data.WHITE)
	main.highlight_effect(main.crit_mult_label, Data.ORANGE, Data.WHITE)

func reset():
	total_chance_plus = 0
	is_max_level = false
	level = 0
	cost = default_cost
	level_count_slider.value = 0
