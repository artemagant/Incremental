extends Node2D
class_name Main

#!TODO: Lock on upgrades, that costs too much
#!!TODO: Prestige system
#?TODO: Prestige upgrades

func print_game_data(): # Printing important data
	if not Data.game_data:
		Data.reset_data()
	print(JSON.stringify(Data.game_data, "\t", false, true), crit_chance)
var password
func cheats_password(pas: String):
	password = pas
func cheats(toggled: bool): # Increase earn for debugging 
	if password != null:
		return
	if toggled:
		timer_between_earning.wait_time = 0.1
		#earn_mult += 50
	else:
		timer_between_earning.wait_time = starting_time_between_earning
		#earn_mult -= 50
	update_data()
	update_counters()

var money_redactions := [
	"K",
	"M", 
	"B", 
	"T", 
	"Qa", 
	"Qi", 
	"Sx", 
	"Sp", 
	"Oc", 
	"No", 
	"De", 
	"Un", 
	"Du",
	"Td", 
	"qd", 
	"Qd", 
	"sd", 
	"Sd", 
	"Od", 
	"Nd", 
	"Vg", 
	"Uv", 
	"Dv", 
	"Tv", 
	"qv", 
	"Qv", 
	"sv", 
	"Sv", 
	"Ov", 
	"Nv", 
	"Tg", 
	"Ut", 
	"Dt", 
	"Tt", 
	"qt", 
	"Qt", 
	"st", 
	"St", 
	"Ot", 
	"Nt", 
	"Qt",
]

var earn_per_second: float
var starting_earn_per_second: = 1.0
var balance: = 0.0
var earn_mult: = 1.0
var starting_crit_chance: = 0.1
var crit_chance: float
var starting_crit_mult: = 1.1
var crit_mult: float
var starting_time_between_earning: = 1.0

@export_category("Labels")
@export var money_counter_label: Label
@export var earn_per_second_label: Label
@export var crit_chance_label: Label
@export var crit_mult_label: Label
@export var earn_mult_label: Label
@export_category("SFX")
@export var click_sound: AudioStreamPlayer2D
@export var clack_sound: AudioStreamPlayer2D
@export var earn_sound: AudioStreamPlayer2D
@export_category("Timer")
@export var timer_between_earning: Timer

func reset() -> void: # Reset game by button
	timer_between_earning.stop()
	Data.reset_data()
	$VBoxContainer/Cheats.button_pressed = false
	crit_chance = 0.1
	starting_crit_chance = 0.1
	balance = 0
	starting_earn_per_second = 1.0
	starting_crit_mult = 1.1
	earn_mult = 1.0
	for child in $Wrap.get_children():
		for upgrade in child.get_children():
			upgrade.reset()
			upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, money_format(upgrade.cost)]
	update_data()
	check_for_unlock()
	timer_between_earning.start()
func _ready() -> void:
	#Data.reset_data()
	print_game_data()
	Data.load_data()
	if not Data.game_data["balance"]:
		Data.game_data["balance"] = 0
	balance = Data.game_data.balance
	_setup()
	update_counters()
func _notification(what: int) -> void: # Save, then exitin
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Data.save_data()
func auto_saving() -> void: # Avtosaving
	Data.save_data()
	print_game_data()

var setup_earn: = false
var setup_crit: = false
var setup_crit_chance: = false
func _setup() -> void: # Setup
	setup_earn = setup_upgrades($Wrap/Upgrades_Earn, buy_upgrade, setup_earn)
	setup_crit = setup_upgrades($Wrap/Upgrades_Crit, buy_upgrade, setup_crit)
	setup_crit_chance = setup_upgrades($Wrap/Upgrades_Crit_Chance, buy_upgrade, setup_crit_chance)
	check_for_unlock()
func setup_upgrades(wrapper: Node, function: Callable, setuped: bool): # Setup upgrades
	if setuped:
		for upgrade in wrapper.get_children():
			upgrade.pressed.disconnect(function)
			upgrade.button_down.disconnect(button_sfx)
			upgrade.button_up.disconnect(button_sfx)
			upgrade.button_up.disconnect()
	for upgrade in wrapper.get_children():
		load_upgrade(upgrade)
		upgrade.pressed.connect(function.bind(upgrade))
		upgrade.button_down.connect(button_sfx.bind(click_sound))
		upgrade.button_up.connect(button_sfx.bind(clack_sound))
		upgrade.level_count_slider.max_value = upgrade.max_level
		print("%s: %s" %[upgrade.name, upgrade.level_count_slider.max_value])
	return true

func button_sfx(SFX: AudioStreamPlayer2D, minimum := 0.90, maximum := 1.10):
	SFX.pitch_scale = randf_range(minimum, maximum)
	SFX.play()


func load_upgrade(upgrade: Upgrades_Class) -> void: # Load upgrade from data
	# Go through every levels and apply the effect of buying 
	var key: = upgrade.get_key(upgrade)
	if not Data.game_data[key]:
		Data.game_data[key] = 0
	for level in Data.game_data[key]:
		upgrade.apply_buy(self)
		upgrade.level += 1
		upgrade.cost *= upgrade.cost_mult
		upgrade.level_count_slider.value += 1
	if upgrade.level >= upgrade.max_level:
		max_level(upgrade)
	else: 
		upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, money_format(upgrade.cost)]
	
	update_data()
	update_counters()

func highlight_effect(target: Label, to_color: Color, start_color: Color) -> void: # Apply crit effect
	target.modulate = to_color
	await get_tree().create_timer(0.3).timeout
	target.modulate = start_color
func is_crit(chance: float) -> bool: # Check for crit
	return chance >= randf()

@onready var upgrades_earn: = $Wrap/Upgrades_Earn
func update_earn_per_second() -> void:
	var total_earn: = 0
	for upgrade in upgrades_earn.get_children():
		total_earn += upgrade.total_earn
	earn_per_second = (total_earn + starting_earn_per_second)
	update_counters()
@onready var upgrades_crit_mult: = $Wrap/Upgrades_Crit
func update_crit_mult() -> void:
	var total_mult: = 0.0
	for upgrade in upgrades_crit_mult.get_children():
		total_mult += upgrade.total_crit_mult_plus
	crit_mult = total_mult + starting_crit_mult
	update_counters()
@onready var upgrades_crit_chance: = $Wrap/Upgrades_Crit_Chance
func update_crit_chance() -> void:
	var total_chance: = 0.0
	for upgrade in upgrades_crit_chance.get_children():
		total_chance += upgrade.total_chance_plus
	crit_chance = total_chance + starting_crit_chance

func update_data() -> void:
	update_crit_chance()
	update_crit_mult()
	update_earn_per_second()

func check_for_unlock():
	if not Data.game_data["total_balance"]:
		Data.game_data["total_balance"] = 0
	for wrapper in $Wrap.get_children():
		for upgrade in wrapper.get_children():
			if upgrade.unlock_cost <= Data.game_data.total_balance:
				var tween = create_tween()
				tween.parallel().tween_property(upgrade.lock_icon, "modulate:a", 0.0, 0.5)
				await tween.finished
				upgrade.lock_icon.visible = false
				upgrade.lock_icon.modulate.a = 1.0

func add_money() -> void: # Add money to balance
	if not Data.game_data["total_balance"]:
		Data.game_data["total_balance"] = 0
	if is_crit(crit_chance): # Check for crit
		balance += earn_per_second * crit_mult * earn_mult
		Data.game_data.total_balance += earn_per_second * earn_mult
		highlight_effect(crit_chance_label, Color(1.0, 0.0, 0.255, 1.0), Color(1.0, 1.0, 1.0, 1.0))
	else:
		balance += earn_per_second * earn_mult
		Data.game_data.total_balance += earn_per_second * earn_mult
	check_for_unlock()
	if not Data.game_data["balance"]:
		Data.game_data["balance"] = 0
	Data.game_data.balance = balance
	button_sfx(earn_sound, 0.30, 0.65)
	update_counters()

func update_counters() -> void: # Update stats labels
	money_counter_label.text = "Money: %s" %money_format(balance)
	earn_per_second_label.text = "%s/sec(x%.2f)" %[money_format(earn_per_second), earn_mult]
	crit_chance_label.text = "%s%s" %[money_format(crit_chance*100), '%']
	crit_mult_label.text = "x%s" %money_format(crit_mult)
func money_format(money: float) -> String: # Convert int into metric system number (1000 - 1K, ETS)
	var min_money := 1000 # Minimum amount of converted int
	if money < min_money: # Check if can convert
		return "%.1f" %money if money >= 10 else "%.2f" %money
	var index := -1 # Index starts from -1, because first itaration adding 1
	while money >= min_money: # Convert 
		index += 1
		money /= 1000.0
	# Check if valid index
	if index >= money_redactions.size():
		return "inf"
	# Return
	var new_money = snapped(money, 0.01)
	return "%.1f%s" %[new_money, money_redactions[index]]
func delete_zero(num: float):
	return str(num).rstrip("0").rstrip(".")

func upgrades_cost(upgrade: Upgrades_Class) -> void: # Minus money from balance, then buying an upgrade
	if not Data.game_data["balance"]:
		Data.game_data["balance"] = 0
	balance -= upgrade.cost # Minus
	Data.game_data.balance = balance # Update data
	upgrade.level += 1 # Add level to the upgrade
	upgrade.cost *= upgrade.cost_mult # Increase cost
	upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, money_format(upgrade.cost)] # Change text
	upgrade.level_count_slider.value += 1
	var key: = "%s_%s" %[upgrade.button_label, upgrade.number] # Get key
	if not Data.game_data[key]:
		Data.game_data[key] = 0
	Data.game_data[key] = upgrade.level # Update data
	update_counters() # Update Counters
	Data.save_data()

func max_level(upgrade: Upgrades_Class):
	upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, "Max"]
	if not upgrade.is_max_level:
		upgrade.new_max_level(self)
	upgrade.is_max_level = true
	update_data()
func buy_upgrade(upgrade: Upgrades_Class) -> void: # Function to buy upgrades
	if balance >= upgrade.cost and upgrade.level < upgrade.max_level: # Check if can buy
		upgrade.apply_buy(self)
		upgrades_cost(upgrade)
	else:
		upgrade.text = "%s %s: %s" %[upgrade.button_label, upgrade.number, money_format(upgrade.cost)]
	if upgrade.level >= upgrade.max_level: # Check if max level
		max_level(upgrade)
	update_data()
