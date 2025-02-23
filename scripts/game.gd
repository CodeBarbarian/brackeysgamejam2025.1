extends Node2D

signal turn_ended  # Signal to indicate turn switch

@onready var UserInterface = $UserInterface
@onready var UI = $UserInterface/UI
@onready var CardScene: PackedScene = preload("res://scenes/cards/card.tscn")
@onready var Deck: Deck = $Deck/Deck
@onready var EnemySpawner = $EnemySpawner
@onready var EffectHandler = $EffectHandler
@onready var Player: Player = $Player
@onready var Background: CanvasLayer = $Background

var is_player_turn: bool = true
var turn_number: int = 0

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
	
## Player Draw Cards
func _on_player_draw_cards(amount):
	for n in amount:
		add_random_card()

## Start player turn
func start_player_turn():
	print("[DEBUG] Starting player turn...")
	is_player_turn = true
	turn_number += 1
	UI.update_ui_turn(turn_number)
	UI.show_message("Player's turn!")

	# Refresh player UI immediately
	UI.update_ui_health(Player.current_hp, Player.max_hp)
	UI.update_ui_energy(Player.current_energy, Player.max_energy)
	UI.update_ui_armor(Player.armor)

	Player.start_turn()  # Reset energy or resources

	# Ensure deck is cleared before refilling
	Deck.clear_hand()
	await get_tree().process_frame  # Ensures deck clears before refilling

	# Forcefully add new cards and ensure visibility
	for n in 5:
		add_random_card()

	# Debugging output
	print("[DEBUG] Player turn started. Deck count: ", Deck.get_child_count())


func all_enemies_defeated() -> bool:
	for enemy in active_enemies:
		if !enemy.is_dead():
			return false  # At least one enemy is still alive
	return true  # All enemies are dead
	
func end_player_turn():
	is_player_turn = false
	Deck.clear_hand()

	active_enemies = active_enemies.filter(func(enemy): return is_instance_valid(enemy) and not enemy.is_dead())

	if active_enemies.is_empty():
		print("[DEBUG] No enemies remaining, starting a new round...")
		start_new_round()
		return

	for enemy in active_enemies:
		if enemy.has_method("take_turn"):
			UI.show_message("Enemy's Turn!")
			enemy.take_turn(Player)

	await get_tree().create_timer(2.0).timeout

	if all_enemies_defeated():
		print("[DEBUG] All enemies defeated. Restarting new round...")
		start_new_round()
	else:
		print("[DEBUG] Resuming player turn...")
		start_player_turn()
func _on_enemy_action(message: String):
	UI.show_message(message)
	
func respawn_saved_enemies():
	print("[INFO] Respawning saved enemies...")
	active_enemies.clear()

	for enemy_data in Gamevars.load_enemy_state():
		var enemy = preload("res://scenes/enemy/enemy.tscn").instantiate()

		EnemySpawner.add_child(enemy)
		print("[DEBUG] Added restored enemy to EnemySpawner.")

		enemy.restore_state(enemy_data)

		enemy.enemy_action.connect(_on_enemy_action)
		enemy.armor_updated.connect(_on_enemy_armor_updated)
		enemy.health_updated.connect(_on_enemy_health_updated)

		await get_tree().process_frame
		enemy.emit_signal("health_updated", enemy.current_hp, enemy.max_hp)
		enemy.emit_signal("armor_updated", enemy.armor)

		active_enemies.append(enemy)
		print("[DEBUG] Enemy fully restored and linked to EnemySpawner.")

	print("[INFO] Respawn complete! UI should now update.")


func restore_round():
	if Gamevars.CurrentRound > 1:
		Round = Gamevars.CurrentRound
	elif Round == 1:
		Round = 1  # Default to round 1 if no saved data
	#else:
		#Round += 1  # Prevent Round from being locked


func start_new_round():
	print("[INFO] Starting new round... Current active enemies: ", active_enemies.size())

	restore_round()
	Round += 1  # Ensure round is properly updated
	UI.update_ui_round(Round)

	await EnemySpawner.clear_enemies()
	print("[DEBUG] Enemy list cleared. Remaining count: ", active_enemies.size())

	if !Gamevars.SavedEnemies.is_empty():
		active_enemies = await respawn_saved_enemies()
	else:
		print("[DEBUG] Checking for boss spawn, Current Round: ", Round)
		print("[DEBUG] Spawning normal enemies for Round: " + str(Round))
		active_enemies = await EnemySpawner.spawn_enemies()

	print("[INFO] New round started. Enemies spawned: ", active_enemies.size())

	# Ensure UI updates by forcing a refresh for each enemy
	for enemy in active_enemies:
		if enemy.has_signal("health_updated"):
			enemy.health_updated.connect(_on_enemy_health_updated)
		if enemy.has_signal("armor_updated"):
			enemy.armor_updated.connect(_on_enemy_armor_updated)

		await get_tree().process_frame  # Ensure UI updates before starting turn
		enemy.emit_signal("health_updated", enemy.current_hp, enemy.max_hp)
		enemy.emit_signal("armor_updated", enemy.armor)

	await get_tree().process_frame  # Ensures enemies are fully initialized before starting turn
	start_player_turn()


func _on_enemy_armor_updated(current: Variant):
	UI.update_ui_enemy_armor(current)

func _on_enemy_health_updated(current: Variant, max_hp: Variant):
	UI.update_ui_enemy_health(current, max_hp)

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
			load_card_data("res://files/rogue_card_data.json")  # Demon Rogue
	
	Player.draw_cards_requested.connect(_on_player_draw_cards)
	
	Background._update_background()


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

func _process(delta: float) -> void:
	if Input.is_action_pressed("action_pause_menu"):
		print("PAUSE MENU CALLED!")
		GetPauseMenu()

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
		UI.update_ui_round(Round)  # UI should update but NOT increment the round
		UI.show_message("Player begins!")

		if !Gamevars.SavedEnemies.is_empty():
			print("[DEBUG] Restoring saved enemies instead of spawning new ones.")
			await respawn_saved_enemies()
		else:
			print("[DEBUG] No saved enemies found, spawning new ones.")
			active_enemies = await EnemySpawner.spawn_enemies()

		RoundFinished = false  # Prevents multiple increments

		await get_tree().process_frame  
		start_player_turn()


func _on_player_energy_updated(current_energy: Variant, max_energy: Variant) -> void:
	UI.update_ui_energy(current_energy, max_energy)

func _on_player_armor_updated(amount: Variant) -> void:
	UI.update_ui_armor(amount)

func _on_player_player_died():
	Gamevars.CurrentRound = Round
	Gamevars.save_enemy_state(active_enemies)

	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_packed(Config.GameOverScene)

	if is_instance_valid(UI):
		UI.update_ui_enemy_health(0, 1)
		UI.update_ui_enemy_armor(0)
	else:
		print("[WARNING] UI reference is invalid after restart!")

	print("[INFO] UI reset after game over. Ready for new game.")
