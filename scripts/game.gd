extends Node2D

@onready var UserInterface = $UserInterface
@onready var UI = $UserInterface/UI
@onready var CardScene: PackedScene = preload("res://scenes/cards/card.tscn")
@onready var Deck: Deck = $Deck/Deck
@onready var Player: Player = $Player

var Round: int = 0
var Health: int = 0
var RoundFinished = true

func _ready() -> void:
	pass

func GetPauseMenu():
	var PauseMenuInstance = Config.PauseMenuScene.instantiate()
	UserInterface.add_child(PauseMenuInstance)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_pause_menu"):
		GetPauseMenu()

func AddCard():
	var RandomCard = CardScene.instantiate()
	Deck.add_card(RandomCard)

func _on_button_pressed() -> void:
	# Debug Function
	pass

func StartFirstRound():
	var SelectedCharacter = Gamevars.CharacterSelection
	var CharacterData = Characters.GetCharacter(SelectedCharacter)
	
	UI.update_ui_character(CharacterData['name'])
	UI.update_ui_health(CharacterData['health'], CharacterData['health'])
	UI.update_ui_energy(CharacterData['base_energy'], CharacterData['base_energy'])
	
func _on_start_round_button_pressed() -> void:
	if RoundFinished:
		StartFirstRound()
		Round += 1
		RoundFinished = false
		UI.update_ui_round(Round)
		for n in 5:
			AddCard()

func _on_draw_card_button_pressed() -> void:
	AddCard()
