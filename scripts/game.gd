extends Node2D

signal turn_ended  # Signal to indicate turn switch

@onready var UserInterface = $UserInterface
@onready var UI = $UserInterface/UI
@onready var CardScene: PackedScene = preload("res://scenes/cards/card.tscn")
@onready var Deck: Deck = $Deck/Deck
@onready var EnemySpawner = $EnemySpawner
@onready var EffectHandler = $EffectHandler

@onready var Player: Player = $Player

var is_player_turn: bool = true
var turn_number: int = 1

var Round: int = 0
var RoundFinished = true
var card_data = []
var active_enemies = []
var selected_enemy: Enemy = null

func _on_end_round_button_pressed():
	print("[INFO] Player ended turn.")
	emit_signal("turn_ended")  # Emit signal for enemy turn
	if is_player_turn:
		end_player_turn()
	
## This needs to be fixed!
func _on_player_draw_cards(amount):
	if card_data.size() > 0:
		var random_card_data = card_data[randi() % card_data.size()]
		Deck.add_card(random_card_data)

func start_player_turn():
	is_player_turn = true
	turn_number += 1
	UI.update_ui_turn(turn_number)
	UI.show_message("Player's turn!")  # NEW MESSAGE
	
	Player.start_turn()  # Reset energy or resources

	for n in 5:  # Draw 5 new cards
		add_random_card()

func end_player_turn():
	is_player_turn = false  # Switch to enemy turn
	Deck.clear_hand()  # Remove all cards from the deck
	UI.show_message("Enemy's Turn!")
	# Let each enemy take an action
	for enemy in active_enemies:
		if enemy.has_method("take_turn"):
			enemy.take_turn(Player)  # Enemy attacks the player

	# Wait for enemies to finish their actions before switching turns
	await get_tree().create_timer(2.0).timeout  # Delay for animations
	start_player_turn()

## ----------------------------------------
## Load Character-Specific Deck
## ----------------------------------------
func _ready() -> void:
	match(Gamevars.CharacterSelection):
		1:
			load_card_data("res://files/lizard_card_data.json")  # Lizard Brute
		2:
			load_card_data("res://files/elf_card_data.json")  # Elf Druid/Wizard
		3:
			load_card_data("res://files/demon_card_data.json")  # Demon Rogue
	
	Player.draw_cards_requested.connect(_on_player_draw_cards)
	#turn_ended.connect(_on_enemy_turn)

## ----------------------------------------
## Load Card Data from JSON
## ----------------------------------------
func load_card_data(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json_result = JSON.parse_string(json_text)

		if typeof(json_result) == TYPE_ARRAY:
			card_data = json_result
		else:
			print("[ERROR] Expected an array but got ", typeof(json_result))

		file.close()
	else:
		print("[ERROR] Failed to open file: ", file_path)

## ----------------------------------------
## Get Pause Menu
## ----------------------------------------
func GetPauseMenu():
	var PauseMenuInstance = Config.PauseMenuScene.instantiate()
	UserInterface.add_child(PauseMenuInstance)

## ----------------------------------------
## Create Card Instance from JSON
## ----------------------------------------
func create_card_instance(card_info: Dictionary) -> Card:
	var card_instance = CardScene.instantiate() as Card
	var effects = card_info.get("effects", []).duplicate(true)

	card_instance.set_card_values(
		card_info.get("name", "Unnamed Card"),
		card_info.get("energy_cost", 1),
		card_info.get("description", ""),
		card_info.get("type", "attack"),
		effects
	)

	card_instance.debug_effects()
	return card_instance

## ----------------------------------------
## Add Random Card to Deck
## ----------------------------------------
func add_random_card():
	if card_data.size() > 0:
		var random_card_data = card_data[randi() % card_data.size()]
		Deck.add_card(random_card_data)

## ----------------------------------------
## Helper function for starting the first round
## ----------------------------------------
func StartFirstRound():
	var SelectedCharacter = Gamevars.CharacterSelection
	var CharacterData = Characters.GetCharacter(SelectedCharacter)
	
	UI.update_ui_character(CharacterData["name"])
	UI.update_ui_health(CharacterData["health"], CharacterData["health"])
	UI.update_ui_energy(CharacterData["base_energy"], CharacterData["base_energy"])

## ----------------------------------------
## On Enemy Selected
## ----------------------------------------
func _on_enemy_selected(enemy: Enemy):
	selected_enemy = enemy 
	print("[INFO] Targeting: " + enemy.name)

## ----------------------------------------
## Get Target Enemy (Fallback to First Enemy)
## ----------------------------------------
func get_target_enemy() -> Enemy:
	if selected_enemy and selected_enemy.current_hp > 0:
		return selected_enemy 
	elif active_enemies.size() > 0:
		return active_enemies[0]  
	return null

## ----------------------------------------
## Start Round
## ----------------------------------------
func _on_start_round_button_pressed() -> void:
	pass # This function has become redundant --- Remove?

## ----------------------------------------
## Draw Card Button
## ----------------------------------------
func _on_draw_card_button_pressed() -> void:
	add_random_card()

## ----------------------------------------
## Handle Input (Mouse Click to Play Card)
## ----------------------------------------
func _input(event):
	if event.is_action_pressed("mouse_click") and Deck.current_selected_card_index >= 0:
		var target = get_target_enemy()
		var card = Deck.player_deck[Deck.current_selected_card_index]
		
		if target:
			if Player.spend_energy(card.CardCost):
				Deck.play_card(Deck.current_selected_card_index, Player, target, active_enemies)
		else:
			print("[WARNING] No valid target selected.")

func _on_player_health_updated(current_hp: Variant, max_hp: Variant) -> void:
	UI.update_ui_health(current_hp, max_hp)

func _on_timer_timeout() -> void:
	if RoundFinished:
		StartFirstRound()
		Round += 1
		RoundFinished = false
		UI.update_ui_round(Round)
		UI.show_message("Player begins!")
		
		start_player_turn()
		# Spawn Enemies
		active_enemies = EnemySpawner.spawn_enemies()

func _on_player_energy_updated(current_energy: Variant, max_energy: Variant) -> void:
	UI.update_ui_energy(current_energy, max_energy)


func _on_player_armor_updated(amount: Variant) -> void:
	UI.update_ui_armor(amount)
