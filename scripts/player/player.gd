extends Node2D

class_name Player

signal health_updated(current_hp, max_hp)
signal energy_updated(current_energy, max_energy)

@export var max_hp: int = 60
@export var current_hp: int = 60
@export var max_energy: int = 3
@export var current_energy: int = 3
@export var armor: int = 0

## Update Health
func take_damage(amount: int):
	var effective_damage = max(amount - armor, 0)
	armor = max(armor - amount, 0)  # Reduce armor first
	current_hp = max(current_hp - effective_damage, 0)
	emit_signal("health_updated", current_hp, max_hp)
	if current_hp <= 0:
		die()

func heal(amount: int):
	current_hp = min(current_hp + amount, max_hp)
	emit_signal("health_updated", current_hp, max_hp)

func increase_max_hp(amount: int):
	max_hp += amount
	emit_signal("health_updated", current_hp, max_hp)

## Energy Management
func spend_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		emit_signal("energy_updated", current_energy, max_energy)
		return true
	return false

func regain_energy(amount: int):
	current_energy = min(current_energy + amount, max_energy)
	emit_signal("energy_updated", current_energy, max_energy)

func start_new_turn():
	current_energy = max_energy
	emit_signal("energy_updated", current_energy, max_energy)

## Armor Management
func add_armor(amount: int):
	armor += amount

func remove_armor():
	armor = 0

## Death Handling
func die():
	print("Player has died! Game Over.")
