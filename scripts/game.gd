extends Node2D

@onready var UI: CanvasLayer = %UI

func GetPauseMenu():
	var PauseMenuInstance = Config.PauseMenuScene.instantiate()
	UI.add_child(PauseMenuInstance)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_pause_menu"):
		GetPauseMenu()
