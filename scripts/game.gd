extends Node2D

@onready var UserInterface = $UserInterface
@onready var CardScene: PackedScene = preload("res://scenes/cards/card.tscn")
@onready var Deck: Deck = $Deck/Deck

var Round: int = 1


func GetPauseMenu():
	var PauseMenuInstance = Config.PauseMenuScene.instantiate()
	UserInterface.add_child(PauseMenuInstance)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_pause_menu"):
		GetPauseMenu()

func _on_button_pressed() -> void:
	var TestCard = CardScene.instantiate()
	Deck.add_card(TestCard)
