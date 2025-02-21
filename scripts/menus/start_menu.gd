extends Control

@onready var game_title_label: Label = %GameTitleLabel
@onready var studio_label: Label = %StudioLabel
@onready var version_label: Label = %VersionLabel
@onready var Sprite = $ParallaxBackground/ParallaxLayer/Clouds

@export var ScrollSpeed = 15

func _ready():
	game_title_label.text = Config.get_game_title()
	studio_label.text = Config.get_author_studio()
	version_label.text = Config.get_game_version()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(Config.CharacterSelectionMenuScene)

func _on_option_button_pressed() -> void:
	get_tree().change_scene_to_packed(Config.OptionsMenuScene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
		#Sprite.region_rect.position += delta * Vector2(ScrollSpeed, ScrollSpeed)
		#if Sprite.region_rect.position >= Vector2(64,64) :
			#Sprite.region_rect.position = Vector2.ZERO
	pass
