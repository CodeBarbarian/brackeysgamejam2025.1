extends Node2D

@onready var UserInterface = $UserInterface
@onready var UI = $UserInterface/UI
@onready var CardScene: PackedScene = preload("res://scenes/cards/card.tscn")
@onready var Deck: Deck = $Deck/Deck
@onready var Player: Player = $Player

var Round: int = 0
var Health: int = 0
var RoundFinished = true
var card_data = []

func _ready() -> void:
	# This should really be based on the character selection.
	load_card_data("res://files/lizard_card_data.json")

func load_card_data(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json_result = JSON.parse_string(json_text)

		# Ensure the result is a valid array
		if typeof(json_result) == TYPE_ARRAY:
			card_data = json_result  #
		else:
			print("Error: Expected an array but got ", typeof(json_result))

		file.close()
	else:
		print("Failed to open file: ", file_path)

func GetPauseMenu():
	var PauseMenuInstance = Config.PauseMenuScene.instantiate()
	UserInterface.add_child(PauseMenuInstance)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_pause_menu"):
		GetPauseMenu()

func create_card_instance(card_info: Dictionary) -> Card:
	var card_instance = CardScene.instantiate() as Card
	card_instance.set_card_values(
		card_info.get("name", "Unnamed Card"),
		card_info.get("energy_cost", 1),
		card_info.get("description", ""),
		card_info.get("type", "attack")
	)
	return card_instance

func AddCard():
	if Deck.player_deck.size() < Deck.player_card_limit:
		if card_data.size() > 0:
			var random_card_data = card_data[randi() % card_data.size()]  # Select a random card
			var card_instance = create_card_instance(random_card_data)  # Create a card from JSON data
			Deck.add_card(card_instance)  # Add to deck
		

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
