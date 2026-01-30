extends Node2D

# TODO: new_upgrade_upgrade (earn upgrades need increase where power every level, that wote in 8 line
# TODO: more content

func print_game_data():
	print(JSON.stringify(Data.game_data, "\t"))
	await get_tree().create_timer(0.5).timeout
	print_game_data()

var upgrades_upgrades := [10, 25, 50, 100]

var earn_per_second: float= 1
var balance: = 0
var crit_chance: = 1.0
var crit_mult: = 1.1

@onready var money_counter_label:Label = $Stats/Label_Money_Counter
@onready var earn_per_second_label: Label = $Stats/Label_Earn_Per_Second
@onready var crit_chance_label: Label = $Stats/Crit_Info_Chance
@onready var crit_mult_label: Label = $Stats/Crit_Info_Mult

@onready var timer_beatwen_earning:Timer = $Timer_Beatwen_Earning

func reset():
	Data.reset_data()
	earn_per_second = 1.0
	crit_chance = 1.0
	crit_mult = 1.1
	balance = 0
	for upgrade in $Upgrades_Earn.get_children():
		upgrade.level = 0
		upgrade.cost = upgrade.defoult_cost
		upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, int(upgrade.cost)]
	for upgrade in $Upgrade_Crit.get_children():
		upgrade.level = 0
		upgrade.cost = upgrade.defoult_cost
		upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, int(upgrade.cost)]
	update_counters()
func _ready() -> void:
	print_game_data()
	Data.load_data()
	balance = Data.game_data.balance
	_setup()
	update_counters()
	start_earning()
func _setup():
	setup_upgrades_earn()
	setup_upgrades_crit_mult()
var setup = false
var setup_crit = false
func setup_upgrades_earn() -> void:
	if setup:
		for upgrade in $Upgrades_Earn.get_children():
			upgrade.pressed.disconnect(buy_upgrade_earn)
	var temp_balance = balance
	balance = 0
	for upgrade in $Upgrades_Earn.get_children():
		load_earn_upgrades(upgrade)
		buy_upgrade_earn(upgrade)
		upgrade.pressed.connect(buy_upgrade_earn.bind(upgrade))
	balance = temp_balance
	temp_balance = 0
	setup = true
func setup_upgrades_crit_mult() -> void:
	if setup_crit:
		for upgrade in $Upgrade_Crit.get_children():
			upgrade.pressed.disconnect(buy_upgrade_crit_mult)
	var temp_balance = balance
	balance = 0
	for upgrade in $Upgrade_Crit.get_children():
		load_crit_mult_upgrades(upgrade)
		buy_upgrade_crit_mult(upgrade)
		upgrade.pressed.connect(buy_upgrade_crit_mult.bind(upgrade))
	balance = temp_balance
	temp_balance = 0
	setup_crit = true


func new_upgrade_upgrade(_upgrade: Upgrade_Earn_Class) -> void:
	pass

func load_earn_upgrades(upgrade: Upgrade_Earn_Class) -> void:
	var key = "Earn_%s" %upgrade.number
	for level in range(Data.game_data[key]):
		earn_per_second += upgrade.earn
		upgrade.total_earn += upgrade.earn
		upgrade.level += 1
		upgrade.cost *= upgrade.cost_mult
	upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, int(upgrade.cost)]
	update_counters()
func load_crit_mult_upgrades(upgrade: Upgrade_Crit_Mult_Class) -> void:
	var key = "xCrit_%s" %upgrade.number
	for level in range(Data.game_data[key]):
		crit_mult += upgrade.crit_mult_plus
		upgrade.level += 1
		upgrade.cost *= upgrade.cost_mult
	upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, int(upgrade.cost)]
	update_counters()

func crit_effect(target: Label, to_color: Color, start_color: Color) -> void:
	target.modulate = to_color
	await get_tree().create_timer(0.3).timeout
	target.modulate = start_color
func crit(chance) -> bool:
	var rand = randf()
	if chance >= rand:
		return true
	return false
func add_money() -> void:
	if crit(crit_chance):
		balance += int(earn_per_second * crit_mult)
		crit_effect(crit_chance_label, Color(1.0, 0.0, 0.255, 1.0), Color(1.0, 1.0, 1.0, 1.0))
	else:
		balance += int(earn_per_second)
	Data.game_data.balance = balance
	Data.save_data()
	update_counters()
func update_counters() -> void:
	money_counter_label.text = "Money: %s" %int(balance)
	earn_per_second_label.text = "%s/sec" %int(earn_per_second)
	crit_chance_label.text = "%.1f%s" %[crit_chance*100, "%"]
	crit_mult_label.text = "x%.2f" %crit_mult
func start_earning()->void:
	await timer_beatwen_earning.timeout
	add_money()
	start_earning()


func upgrades_cost(upgrade: Upgrades_Class) -> void:
	balance -= int(upgrade.cost)
	Data.game_data.balance = balance
	upgrade.level += 1
	upgrade.cost *= upgrade.cost_mult
	upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, int(upgrade.cost)]
	var key = "%s_%s" %[upgrade.button_label, upgrade.number]
	Data.game_data[key] = upgrade.level
	Data.save_data()
	update_counters()
func buy_upgrade_earn(upgrade: Upgrade_Earn_Class) -> void:
	if balance >= int(upgrade.cost) and upgrade.level < upgrade.max_level:
		earn_per_second += upgrade.earn
		upgrade.total_earn += upgrade.earn
		upgrades_cost(upgrade)
	else:
		if balance < int(upgrade.cost):
			upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, int(upgrade.cost)]
	if upgrade.level >= upgrade.max_level:
		upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, "Max"]
func buy_upgrade_crit_mult(upgrade: Upgrade_Crit_Mult_Class) -> void:
	if balance >= int(upgrade.cost) and upgrade.level < upgrade.max_level:
		crit_mult += upgrade.crit_mult_plus
		upgrades_cost(upgrade)
	else:
		if balance < int(upgrade.cost):
			upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, int(upgrade.cost)]
	if upgrade.level >= upgrade.max_level:
		upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, "Max"]
