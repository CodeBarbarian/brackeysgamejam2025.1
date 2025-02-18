@tool
class_name Deck extends Node2D

@export var deck_radius: int = 1000
@export var card_angle: float = -90
@export var angle_limit: float = 25
@export var max_card_spread_angle: float = 5

@onready var TestCard = $TestCard
@onready var DebugShape = $DebugShape

var player_deck: Array = []
var touched: Array = []
var current_selected_card_index: int = -1

func add_card(card: Node2D):
	player_deck.push_back(card)
	add_child(card)
	card.mouse_entered.connect(_handle_card_touched)
	card.mouse_exited.connect(_handle_card_untouched)
	reorder_cards()

func remove_card(index: int) -> Node2D:
	var removing_card = player_deck[index]
	player_deck.remove_at(index)
	touched.remove_at(touched.find(removing_card))
	remove_child(removing_card)
	reorder_cards()
	return removing_card
	
func reorder_cards():
	var card_spread = min(angle_limit / player_deck.size(), max_card_spread_angle)
	var current_angle = -(card_spread * (player_deck.size() -1))/2 - 90
	for card in player_deck:
		_card_transform_update(card, current_angle)
		current_angle += card_spread

func _card_transform_update(card: Node2D, angle_in_drag: float):
	card.set_position(get_card_position(angle_in_drag))
	card.set_rotation(deg_to_rad(angle_in_drag + 90))
	
func get_card_position(angle_in_degre: float) -> Vector2:
	var x: float = deck_radius * cos(deg_to_rad(angle_in_degre))
	var y: float = deck_radius * sin(deg_to_rad(angle_in_degre))

	return Vector2(x,y)
	
func _handle_card_touched(card: Card):
	touched.push_back(card)

func _handle_card_untouched(card: Card):
	touched.remove_at(touched.find(card))
	
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

func _input(event):
	if event.is_action_pressed("mouse_click") && current_selected_card_index >= 0:
		var card = remove_card(current_selected_card_index)
		card.queue_free() # just to prevent the memory leak that spawns from this code
		current_selected_card_index = -1
