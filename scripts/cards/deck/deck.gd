@tool
class_name Deck extends Node2D

# Onready vars
@onready var TestCard = $TestCard
@onready var DebugShape = $DebugShape
@onready var player_card_limit: int = Gamevars.MaxPlayingCards
@export var deck_radius: int = 1000
@export var card_angle: float = -90
@onready var angle_limit: float = Gamevars.AngleLimit
@onready var max_card_spread_angle: float = Gamevars.MaxCardSpreadAngle
@onready var EffectHandler = $"../../EffectHandler"
@onready var CardScene: PackedScene = preload("res://scenes/cards/card.tscn")

var player_deck: Array = []
var touched: Array = []
var current_selected_card_index: int = -1


func create_card_instance(card_info: Dictionary) -> Card:
	var card_instance = CardScene.instantiate() as Card
	
	var effects = []
	if "effects" in card_info and typeof(card_info["effects"]) == TYPE_ARRAY:
		effects = card_info["effects"].duplicate(true)
	
	## There should be a comment here.
	var image_path = null
	match(Gamevars.CharacterSelection):
		1:
			# Get image path from card_info (default to a placeholder if missing)
			image_path = "res://assets/cards/lizard/" + card_info.get("image_name", "default.png")
		2:
			image_path = "res://assets/cards/lizard/" + card_info.get("image_name", "default.png")	
		3:
			image_path = "res://assets/cards/rogue/" + card_info.get("image_name", "default.png")
		_:
			image_path = "res://assets/cards/lizard/" + card_info.get("image_name", "default.png")
	card_instance.set_card_values(
		card_info.get("name", "Unnamed Card"),
		card_info.get("energy_cost", 1),
		card_info.get("description", ""),
		card_info.get("type", "attack"),
		image_path,
		effects
	)

	return card_instance

func clear_hand():
	while player_deck.size() > 0:
		var card = player_deck.pop_back()  # Remove the last card in the list
		remove_child(card)  # Remove it from the scene
		card.queue_free()  # Free memory
	reorder_cards()  # Update the layout after clearing

## Add Card to the Player Deck
func add_card(card_info: Dictionary):
	if player_deck.size() < player_card_limit:
		var card_instance = create_card_instance(card_info)  # Create card
		player_deck.push_back(card_instance) 
		add_child(card_instance) 
		card_instance.mouse_entered.connect(_handle_card_touched)
		card_instance.mouse_exited.connect(_handle_card_untouched)
		reorder_cards()

func play_card(index: int, player, target, enemies):
	if index >= 0 and index < player_deck.size():
		var card = player_deck[index]


		print("[DEBUG] Playing card: " + card.CardName)
		print("[DEBUG] Effects applied: " + str(card.Effects))

		if card.Effects.is_empty():
			print("[WARNING] No effects found in card!")

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
	var card_spread = min(angle_limit / player_deck.size() * 1.3, max_card_spread_angle)
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
