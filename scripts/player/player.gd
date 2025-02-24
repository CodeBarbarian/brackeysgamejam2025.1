class_name Player extends Node2D

signal health_updated(current_hp, max_hp)
signal energy_updated(current_energy, max_energy)
signal draw_cards_requested(amount)
signal armor_updated(amount)
signal player_died
signal relic_triggered(relic_name)

@export var max_hp: int = 60
@export var current_hp: int = 60
@export var max_energy: int = 3
@export var current_energy: int = 3
@export var armor: int = 0
@export var strength: int = 0
@export var gold: int = 0

@onready var PlayerSprite: Sprite2D = $PlayerSprite

var status_effects: Dictionary = {}  
var relics: Dictionary = {}  

## Energy Management
func spend_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		emit_signal("energy_updated", current_energy, max_energy)
		return true
	return false


## Ready function
func _ready() -> void:
	var CharacterData = Characters.GetCharacter(Gamevars.CharacterSelection)
	max_hp = CharacterData["health"]
	current_hp = CharacterData["health"]
	max_energy = CharacterData["base_energy"]
	current_energy = max_energy

	var texture = load(CharacterData['image_path'])
	if texture:
		PlayerSprite.texture = texture

## Relic System
func add_relic(relic_name: String, level: int = 1):
	relics[relic_name] = level
	print("[INFO] Relic Added: " + relic_name + " (Level " + str(level) + ")")

## Remove relic
func remove_relic(relic_name: String):
	if relics.has(relic_name):
		relics.erase(relic_name)
		print("[INFO] Relic Removed: " + relic_name)

## Status Effects
func apply_status(effect_name: String, amount: int, permanent: bool = false):
	if status_effects.has(effect_name):
		status_effects[effect_name] += amount
	else:
		status_effects[effect_name] = amount

	print("[INFO] Player received status effect: " + effect_name + " (" + str(amount) + ")")

	if effect_name == "stun":
		print("[INFO] Player is stunned and will skip their next turn.")
	elif effect_name == "strength":
		modify_strength(amount)

## Modify Strength
func modify_strength(amount: int):
	strength += amount
	print("[INFO] Player strength changed by " + str(amount) + ". New strength: " + str(strength))

## Relic Logic
func apply_relics(trigger: String, target = null):
	for relic in relics.keys():
		var level = relics[relic]

		match relic:
			"Lethal Toxins":
				if trigger == "on_kill" and target and target.has_status("poison"):
					print("[RELIC] Lethal Toxins triggered! Explosion for " + str(target.max_hp) + " damage.")
					for enemy in get_parent().active_enemies:
						enemy.take_damage(target.max_hp)

				if trigger == "on_kill":
					if level >= 1:
						gold = max(0, gold - target.gold_drop)
					if level >= 2:
						decrease_max_hp(1)
					if level >= 3:
						apply_status("cripple", 2)

			"Pickpocketer":
				if trigger == "on_kill":
					var gold_gain = int(target.gold_drop * 1.15)
					gold += gold_gain
					print("[RELIC] Pickpocketer triggered! Gained " + str(gold_gain) + " gold.")

				if trigger == "after_turn" and level >= 1 and randf() < 0.5:
					discard_random_card()
				if trigger == "after_combat" and level >= 2 and randf() < 0.5:
					gold = int(gold * 0.8)
				if trigger == "after_combat" and level >= 3:
					gold = min(gold, 200)

			"Master of Stealth":
				if trigger == "on_damage" and randf() < 0.5:
					print("[RELIC] Master of Stealth triggered! Dodged attack.")
					return  
				
				if trigger == "on_start_combat" and level >= 1:
					apply_status("bleed", 1, true)
				if trigger == "on_start_combat" and level >= 2:
					print("[RELIC] Master of Stealth triggered! Cannot heal at resting-sites.")
				if trigger == "before_encounter" and level >= 3 and randf() < 0.5:
					print("[RELIC] Skipped encounter due to Master of Stealth!")

			"Potion Belt":
				if trigger == "on_use_potion":
					print("[RELIC] Potion Belt triggered! Extra potion capacity.")
				
				if trigger == "on_buy_potion" and level >= 1:
					print("[RELIC] Shopkeeper distrusts you. Cannot buy potions!")
				if trigger == "on_use_potion" and level >= 2 and randf() < 0.3:
					take_damage(3)
				if trigger == "on_start_combat" and level >= 3:
					remove_relic("Master of Stealth")

		emit_signal("relic_triggered", relic)

## Armor Handling
func add_armor(amount: int):
	armor += amount
	emit_signal("armor_updated", armor)

func remove_armor():
	armor = 0
	emit_signal("armor_updated", armor)

## Health Handling
# Handle player taking damage (Modified to accept attacker argument)
func take_damage(amount: int, attacker = null):
	var effective_damage = max(amount - armor, 0)
	armor = max(armor - amount, 0)  # Reduce armor first
	emit_signal("armor_updated", armor)

	current_hp = max(current_hp - effective_damage, 0)
	emit_signal("health_updated", current_hp, max_hp)

	# Apply relic effects if needed (e.g., "Master of Stealth" may prevent damage)
	apply_relics("on_damage", attacker)

	# Check if player is dead
	if is_dead():
		die()

func increase_max_hp(amount):
	max_hp += amount
	emit_signal("health_updated", current_hp, max_hp)

func heal(amount: int):
	current_hp = min(current_hp + amount, max_hp)
	apply_relics("on_heal")
	emit_signal("health_updated", current_hp, max_hp)

func decrease_max_hp(amount: int):
	max_hp = max(10, max_hp - amount)
	if current_hp > max_hp:
		current_hp = max_hp
	emit_signal("health_updated", current_hp, max_hp)

func is_dead() -> bool:
	return current_hp <= 0

func die():
	emit_signal("player_died")

## Turn management
func start_turn():
	apply_relics("on_start_turn")
	current_energy = max_energy
	emit_signal("energy_updated", current_energy, max_energy)
	draw_cards(5)

func end_turn():
	apply_relics("after_turn")

## Card Handling
func draw_cards(amount: int):
	emit_signal("draw_cards_requested", amount)

func discard_random_card():
	emit_signal("draw_cards_requested", -1)
