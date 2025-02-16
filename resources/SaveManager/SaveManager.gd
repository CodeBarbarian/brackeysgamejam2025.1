extends Node

var json = JSON.new()
var path = "user://game_data.json"
var data = {}

@onready var ResetSave = true # Development = true

func Write_Save(content):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json.stringify(content))
	file.close()
	file = null

func Read_Save():
	var file = FileAccess.open(path, FileAccess.READ)
	var content = json.parse_string(file.get_as_text())
	return content
	
func Create_New_Save_File():
	var file = FileAccess.open("res://files/default_save.json", FileAccess.READ)
	var content = json.parse_string(file.get_as_text())
	data = content
	Write_Save(content)

func _ready():
	if ResetSave:
		if !FileAccess.file_exists(path):
			Create_New_Save_File()
		else:
			var Dir = DirAccess.remove_absolute(path)
			Create_New_Save_File()
	else:
		if !FileAccess.file_exists(path):
			Create_New_Save_File()
			print("[SaveManager] Savefile does not exist, creating a savefile")
		else:
			print("[SaveManager] Savefile exist, no action")
