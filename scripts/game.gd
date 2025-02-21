extends Node2D

@onready var UserInterface = $UserInterface
@onready var UI = $UserInterface/UI
@onready var CardScene: PackedScene = preload("res://scenes/cards/card.tscn")
@onready var Deck: Deck = $Deck/Deck
@onready var Player: Player = $Player
@onready var EnemySpawner = $EnemySpawner
@onready var EffectHandler = $EffectHandler

var Round: int = 0
var RoundFinished = true
var card_data = []
var active_enemies = []
var selected_enemy: Enemy = null

## ----------------------------------------
## Load Character-Specific Deck
## ----------------------------------------
func _ready() -> void:
	# This should really be based on the character selection.
	match(Gamevars.CharacterSelection):
		1:
			load_card_data("res://files/lizard_card_data.json") # Lizard Brute
		2:
			load_card_data("res://files/elf_card_data.json")  # Elf Druid/Wizard
		3:
			load_card_data("res://files/demon_card_data.json")  # Demon Rogue

## ----------------------------------------
## Load Card Data from JSON
## ----------------------------------------
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

## ----------------------------------------
##  Get Pause Menu
## ----------------------------------------
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
		card_info.get("type", "attack"),
		card_info.get("effect", []).duplicate(true)
	)
	return card_instance

func AddCard():
	if Deck.player_deck.size() < Deck.player_card_limit:
		if card_data.size() > 0:
			var random_card_data = card_data[randi() % card_data.size()]  # Select a random card
			var card_instance = create_card_instance(random_card_data)  # Create a card from JSON data
			Deck.add_card(card_instance)  # Add to deck
		
func play_card(index: int):
	var target = get_target_enemy()
	if target:
		Deck.play_card(index, Player, target, active_enemies)

func _on_button_pressed() -> void:
	# Debug Function
	pass

func StartFirstRound():
	var SelectedCharacter = Gamevars.CharacterSelection
	var CharacterData = Characters.GetCharacter(SelectedCharacter)
	
	UI.update_ui_character(CharacterData['name'])
	UI.update_ui_health(CharacterData['health'], CharacterData['health'])
	UI.update_ui_energy(CharacterData['base_energy'], CharacterData['base_energy'])
	
func _on_enemy_selected(enemy: Enemy):
	selected_enemy = enemy 
	print("Targeting: " + enemy.name)

func get_target_enemy() -> Enemy:
	if selected_enemy and selected_enemy.current_hp > 0:
		return selected_enemy 
	elif active_enemies.size() > 0:
		return active_enemies[0]  
	return null

func _on_start_round_button_pressed() -> void:
	if RoundFinished:
		StartFirstRound()
		Round += 1
		RoundFinished = false
		UI.update_ui_round(Round)
		for n in 5:
			AddCard()
		
		active_enemies = EnemySpawner.spawn_enemies()

func _on_draw_card_button_pressed() -> void:
	AddCard()

func _input(event):
	if event.is_action_pressed("mouse_click") and Deck.current_selected_card_index >= 0:
		var target = get_target_enemy()  # Get the selected enemy
		if target:
			Deck.play_card(Deck.current_selected_card_index, Player, target, active_enemies)  # ✅ Pass target
		else:
			print("No valid target selected.")  # Debug message if no target
