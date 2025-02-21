class_name Deck extends Node2D

# Onready vars
@onready var TestCard = $TestCard
@onready var DebugShape = $DebugShape
@onready var player_card_limit: int = Gamevars.MaxPlayingCards
@onready var deck_radius: int = Gamevars.DeckRadius
@onready var card_angle: float = Gamevars.CardAngle
@onready var angle_limit: float = Gamevars.AngleLimit
@onready var max_card_spread_angle: float = Gamevars.MaxCardSpreadAngle
@onready var EffectHandler = $"../../EffectHandler"

var player_deck: Array = []
var touched: Array = []
var current_selected_card_index: int = -1

## Add Card to the Player Deck
func add_card(card: Node2D):
	if player_deck.size() < player_card_limit:
		player_deck.push_back(card)
		add_child(card)
		card.mouse_entered.connect(_handle_card_touched)
		card.mouse_exited.connect(_handle_card_untouched)
		reorder_cards()

func play_card(index: int, player, target, enemies):
	if index >= 0 and index < player_deck.size():
		var card = player_deck[index]
		EffectHandler.apply_effects(card, player, target, enemies)  
		remove_card(index)  

## Remove Card from the player deck
func remove_card(index: int) -> Node2D:
	var removing_card = player_deck[index]
	player_deck.remove_at(index)
	touched.remove_at(touched.find(removing_card))
	remove_child(removing_card)
	reorder_cards()
	return removing_card

## Reorder player deck
func reorder_cards():
	var card_spread = min(angle_limit / player_deck.size(), max_card_spread_angle)
	var current_angle = -(card_spread * (player_deck.size() -1))/2 - 90
	for card in player_deck:
		_card_transform_update(card, current_angle)
		current_angle += card_spread

## Helper function to transform the position and rotation compared to the collision shape and the other cards
func _card_transform_update(card: Node2D, angle_in_drag: float):
	card.set_position(get_card_position(angle_in_drag))
	card.set_rotation(deg_to_rad(angle_in_drag + 90))

## Get the card position
func get_card_position(angle_in_degre: float) -> Vector2:
	var x: float = deck_radius * cos(deg_to_rad(angle_in_degre))
	var y: float = deck_radius * sin(deg_to_rad(angle_in_degre))

	return Vector2(int(x),int(y))

func _handle_card_touched(card: Card):
	touched.push_back(card)

func _handle_card_untouched(card: Card):
	touched.remove_at(touched.find(card))
	
func load_card_data(file_path: String):
	pass

func _ready():
	pass
	
func _process(delta):
	for card in player_deck:
		current_selected_card_index = -1
		card.unhighlight()
		
	if !touched.is_empty():
		var highest_touched_index: int = -1
		
		for touched_card in touched:
			highest_touched_index = max(highest_touched_index, player_deck.find(touched_card))
		
		if highest_touched_index >= 0 && highest_touched_index < player_deck.size():
			player_deck[highest_touched_index].highlight()
			current_selected_card_index = highest_touched_index
	
	# This code is only for the tool logic, allowing us to see the changes directly
	# in the changes.
	if (DebugShape.shape as CircleShape2D).radius != deck_radius:
		(DebugShape.shape as CircleShape2D).set_radius(deck_radius)

	TestCard.set_position(get_card_position(card_angle))
	TestCard.set_rotation(-deg_to_rad(card_angle + 90))

#func _input(event):
#	if event.is_action_pressed("mouse_click") && current_selected_card_index >= 0:
#		var target = get_target_enemy()  # Get the enemy to target
#		if target:
#			play_card(current_selected_card_index, Player, target, active_enemies)  # Play the selected card
##		else:
#			print("No valid target selected.")  # Debug message if no target
