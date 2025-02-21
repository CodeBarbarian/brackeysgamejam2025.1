@tool
class_name Player extends Node2D

signal health_updated(current_hp, max_hp)
signal action_chosen(enemy, action)

@export var max_hp: int = 60
@export var current_hp: int = 60
@export var armor: int = 0
@export var strength: int = 0  # ✅ Strength stat

var status_effects: Dictionary = {}

func draw_cards(amount: int):
	pass

func apply_status(effect_name: String, amount: int):
	pass

func modify_strength(amount: int):
	pass

func take_damage(amount: int):
	pass

func die():
	pass

func heal(amount: int):
	pass

func add_armor(amount: int):
	armor += amount

func remove_armor():
	armor = 0
