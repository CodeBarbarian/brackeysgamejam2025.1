extends Node2D

class_name Enemy

signal health_updated(current_hp, max_hp)
signal action_chosen(enemy, action)

@onready var HealthBar: ProgressBar = $HealthBar
@onready var HealthBarLabel: Label = $HealthBarLabel

@export var EnemyName: String = "Enemy"
@export var max_hp: int = 30
@export var current_hp: int = 30
@export var armor: int = 0

## Basic Enemy Actions
func take_damage(amount: int):
	var effective_damage = max(amount - armor, 0)
	armor = max(armor - amount, 0)
	current_hp = max(current_hp - effective_damage, 0)
	emit_signal("health_updated", current_hp, max_hp)
	if current_hp <= 0:
		die()

func heal(amount: int):
	current_hp = min(current_hp + amount, max_hp)
	emit_signal("health_updated", current_hp, max_hp)

func add_armor(amount: int):
	armor += amount

func remove_armor():
	armor = 0

## Enemy AI (Choose Random Action)
func take_turn(player: Player):
	var actions = ["attack", "defend", "status_effect"]
	var chosen_action = actions[randi() % actions.size()]
	
	emit_signal("action_chosen", self, chosen_action)

	match chosen_action:
		"attack":
			player.take_damage(5)
		"defend":
			add_armor(3)
		"status_effect":
			player.apply_status("weaken", 1)

func die():
	print(name + " has died!")
	queue_free()
