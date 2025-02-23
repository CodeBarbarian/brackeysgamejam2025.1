extends Control

@onready var GameScene: PackedScene = preload("res://scenes/game.tscn")

func _on_continue_button_pressed() -> void:
	var game_scene = load(Gamevars.GameScenePath)
	get_tree().change_scene_to_packed(game_scene)


func _on_start_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(Config.StartMenuScene)
