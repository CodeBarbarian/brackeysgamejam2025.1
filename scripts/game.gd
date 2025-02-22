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

var Round: int = 1
var RoundFinished = true
var card_data = []
var active_enemies = []
var selected_enemy: Enemy = null

## Player end turn
func _on_end_round_button_pressed():
	if is_player_turn:
		emit_signal("turn_ended")  # Emit signal for enemy turn
		end_player_turn()
	
## This needs to be fixed!
## BUG: We have a problem when drawing multiple cards, this function needs obvious refinement.
func _on_player_draw_cards(amount):
	if card_data.size() > 0:
		var random_card_data = card_data[randi() % card_data.size()]	
		Deck.add_card(random_card_data)

## This function is used to start the player turn
func start_player_turn():
	is_player_turn = true
	turn_number += 1
	UI.update_ui_turn(turn_number)
	UI.show_message("Player's turn!")  # NEW MESSAGE
	
	Player.start_turn()  # Reset energy or resources

	for n in 5:  # Draw 5 new cards
		add_random_card()

func all_enemies_defeated() -> bool:
	for enemy in active_enemies:
		if !enemy.is_dead():
			return false  # At least one enemy is still alive
	return true  # All enemies are dead


## BUG: Enemys turn show up, before starting new round... Easy fix... just fix it
func end_player_turn():
	is_player_turn = false  # Switch to enemy turn
	Deck.clear_hand()  # Remove all cards from the deck
	
	
	active_enemies = active_enemies.filter(func(enemy): return is_instance_valid(enemy) and not enemy.is_dead())
	
	if active_enemies.is_empty():
		start_new_round()
		return
	
	for enemy in active_enemies:
		if enemy.has_method("take_turn"):
			UI.show_message("Enemy's Turn!")
			enemy.take_turn(Player)
	
	# Wait for enemies to finish their actions before switching turns
	await get_tree().create_timer(2.0).timeout  # Delay for animations
	
	if all_enemies_defeated():
		start_new_round()
	else:
		start_player_turn()

func _on_enemy_action(message: String):
	UI.show_message(message)

func start_new_round():
	if !all_enemies_defeated():
		return
	
	Round += 1
	UI.update_ui_round(Round)
	UI.show_message("Round " + str(Round) + " begins!")

	active_enemies = active_enemies.filter(func(enemy): return is_instance_valid(enemy))

	# Clear defeated enemies
	EnemySpawner.clear_enemies()
	active_enemies.clear()
	
	if Round % 5 == 0:
		active_enemies = EnemySpawner.spawn_boss()
	else:
		# Spawn new enemies
		active_enemies = EnemySpawner.spawn_enemies()
		
	for enemy in active_enemies:
		if enemy.has_signal("enemy_action"):
			enemy.enemy_action.connect(_on_enemy_action)

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
	# Needs to be connecting when we actually have an active enemy --> Moving to the start first round!
	#for enemy in active_enemies:
		#enemy.enemy_action.connect(_on_enemy_action)


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
	# Check if the selected enemy is still valid
	if is_instance_valid(selected_enemy) and selected_enemy.current_hp > 0:
		return selected_enemy 
	
	# Filter out invalid enemies before selecting the first one
	active_enemies = active_enemies.filter(func(enemy): return is_instance_valid(enemy) and enemy.current_hp > 0)
	
	# Return the first valid enemy if available
	if active_enemies.size() > 0:
		return active_enemies[0]  

	return null  # No valid target available

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
		if active_enemies.is_empty():
			UI.show_message("No enemies to attack!")
			return
			
		var card = Deck.player_deck[Deck.current_selected_card_index]
		if not Player.spend_energy(card.CardCost):
			UI.show_message("Not enough energy!")
			return  # Stop execution if not enough energy
		
		var target = get_target_enemy()
		if target:
			Deck.play_card(Deck.current_selected_card_index, Player, target, active_enemies)
		else:
			UI.show_message("No valid target selected!")
	if event.is_action_pressed("action_pause_menu"):
		GetPauseMenu()

func _on_player_health_updated(current_hp: Variant, max_hp: Variant) -> void:
	UI.update_ui_health(current_hp, max_hp)

func _on_timer_timeout() -> void:
	if RoundFinished:
		StartFirstRound()
		if Round > 1:
			Round += 1
		RoundFinished = false
		UI.update_ui_round(Round)
		UI.show_message("Player begins!")
		
		# Spawn Enemies
		active_enemies = EnemySpawner.spawn_enemies()
		
		for enemy in active_enemies:
			if enemy.has_signal("enemy_action"):
				enemy.enemy_action.connect(_on_enemy_action)
				
		start_player_turn()

func _on_player_energy_updated(current_energy: Variant, max_energy: Variant) -> void:
	UI.update_ui_energy(current_energy, max_energy)

func _on_player_armor_updated(amount: Variant) -> void:
	UI.update_ui_armor(amount)

## Take us to the game over screen!
func _on_player_player_died() -> void:
	UI.show_message("GAME OVER! You Died!")
	await get_tree().create_timer(2.5).timeout  

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_pause_menu"):
		GetPauseMenu()
