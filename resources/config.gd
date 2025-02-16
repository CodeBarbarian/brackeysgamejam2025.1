extends Node

# ===== Primary Game Details ===== 
@onready var GameTitle = "Mojo World" # We need to figure out a name
@onready var Author = "CEFM" # Maybe we should have a team name, right now it is just the first letter of our nickname's 
@onready var Version = "0.0.1"
@onready var Candidate = "alpha"

# ==== Scene Config ====
# IMPORTANT: We do not preload all scenes, only UI's that are used
# If we decide to make any UI "Flashy", this method must not be used
# The game scenes, should be loaded by the game itself, not be the UI
@onready var StartMenuScene = preload("res://scenes/menus/start_menu.tscn")
@onready var OptionsMenuScene = preload("res://scenes/menus/options_menu.tscn")
@onready var PauseMenuScene = preload("res://scenes/menus/pause_menu.tscn")
@onready var CharacterSelectionMenuScene = preload("res://scenes/menus/character_selection_menu.tscn")

# Preload the Game Scene
@onready var GameScene = preload("res://scenes/game.tscn")

# ==== Helper Functions ====
func get_game_title():
	return GameTitle

func get_author_studio():
	return "Developed by " + str(Author)

func get_game_version():
	return "Running version " + str(Version) + "-" + str(Candidate)
