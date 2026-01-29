extends Node2D

#func _process(delta: float) -> void:
#	print(balance)

var earn_per_second: float= 1
var balance: = 0

@onready var money_counter_node:Label = $Label_Money_Counter
@onready var timer_beatwen_earning:Timer = $Timer_Beatwen_Earning
@onready var earn_per_second_label: Label = $CenterContainer/Label_Earn_Per_Second

func _ready() -> void:
	var temp_balance = balance
	balance = 0
	for upgrade in $Upgrades_Earn.get_children():
		buy_upgrade_earn(upgrade)
		upgrade.pressed.connect(buy_upgrade_earn.bind(upgrade))
	balance = temp_balance
	temp_balance = 0
	update_counters()
	start_earning()
	

func add_money() -> void:
	balance += int(earn_per_second)
	update_counters()
func update_counters() -> void:
	money_counter_node.text = "Money: %s" %int(balance)
	earn_per_second_label.text = "%s/sec" %int(earn_per_second)
func start_earning()->void:
	await timer_beatwen_earning.timeout
	add_money()
	start_earning()


func buy_upgrade_earn(Upgrade: Upgrade_Earn_Class) -> void:
	if balance >= int(Upgrade.cost):
		earn_per_second += Upgrade.earn
		balance -= int(Upgrade.cost)
		Upgrade.cost *= Upgrade.cost_mult
		Upgrade.text = "%s %s: %s" %[Upgrade.button_label, Upgrade.number, int(Upgrade.cost)]
		update_counters()
	else:
		Upgrade.text = "%s %s: %s" %[Upgrade.button_label, Upgrade.number, int(Upgrade.cost)]
