extends Node2D

# TODO: new_upgrade_upgrade (earn upgrades need increase where power every level, that wote in 8 line

#func _process(_delta: float) -> void:
	#print()

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


func _ready() -> void:
	Data.load_data()
	Data.reset_data()
	balance = Data.game_data.balance
	setup_upgrades_earn()
	update_counters()
	start_earning()
var setup = false
func setup_upgrades_earn():
	if setup:
		return
	var temp_balance = balance
	balance = 0
	for upgrade in $Upgrades_Earn.get_children():
		load_earn_upgrades(upgrade)
		buy_upgrade_earn(upgrade)
		upgrade.pressed.connect(buy_upgrade_earn.bind(upgrade))
	balance = temp_balance
	temp_balance = 0
	setup = true


func new_upgrade_upgrade(_upgrade: Upgrade_Earn_Class):
	pass

func load_earn_upgrades(upgrade: Upgrade_Earn_Class):
	var key = "Upgrade_earn_%s" %upgrade.number
	for level in range(Data.game_data[key]):
		earn_per_second += upgrade.earn
		upgrade.total_earn += upgrade.earn
		upgrade.level += 1
		upgrade.cost *= upgrade.cost_mult
		upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, int(upgrade.cost)]
	update_counters()

func crit_effect(target: Label, to_color: Color, start_color: Color):
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


func buy_upgrade_earn(upgrade: Upgrade_Earn_Class) -> void:
	if balance >= int(upgrade.cost) and upgrade.level < upgrade.max_level:
		earn_per_second += upgrade.earn
		upgrade.total_earn += upgrade.earn
		balance -= int(upgrade.cost)
		Data.game_data.balance = balance
		upgrade.level += 1
		upgrade.cost *= upgrade.cost_mult
		upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, int(upgrade.cost)]
		var key = "Upgrade_earn_%s" %upgrade.number
		Data.game_data[key] = upgrade.level
		Data.save_data()
		update_counters()
	else:
		upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, int(upgrade.cost)]
