extends Node

var game_data := {
	"balance": 0,
	
	"+Earn_1": 0,
	"+Earn_2": 0,
	"+Earn_3": 0,
	"+Earn_4": 0,
	"+Earn_5": 0,
	
	"xCrit_1": 0,
	"xCrit_2": 0,
	"xCrit_3": 0,
	
	"%Crit_1": 0,
	"%Crit_2": 0,
}

var duplicate_game_data := game_data.duplicate(true)

const SAVE_PATH := "user://save.save"

func save_data():
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if save_file == null:
		push_error("Error: load save file - save() Data.gd")
		return
	
	var data = {
		"Data": game_data
	}
	var json_string = JSON.stringify(data)
	
	save_file.store_line(json_string)
	
	save_file.close()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if save_file == null:
		push_error("Error: load save file - load_data() Data.gd")
	
	var json_string = save_file.get_line()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Error: parsing JSON file - load_data() Data.gd")
	
	var data = json.data
	
	game_data = data.get("Data", duplicate_game_data)

func reset_data():
	game_data = duplicate_game_data
	save_data()
