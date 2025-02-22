class_name Player extends Node2D

signal health_updated(current_hp, max_hp)
signal energy_updated(current_energy, max_energy)  # Signal for UI updates
signal draw_cards_requested(amount)
signal armor_updated(amount)
signal player_died

@export var max_hp: int = 60
@export var current_hp: int = 60
@export var max_energy: int = 3
@export var current_energy: int = 3
@export var armor: int = 0
@export var strength: int = 0

var status_effects: Dictionary = {}

func spend_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		emit_signal("energy_updated", current_energy, max_energy)  # Emit signal for UI updates
		return true
	return false  # Not enough energy

func _ready() -> void:
	# Load character-specific stats
	var CharacterData = Characters.GetCharacter(Gamevars.CharacterSelection)
	max_hp = CharacterData["health"]
	current_hp = CharacterData["health"]
	max_energy = CharacterData["base_energy"]
	current_energy = max_energy

	#emit_signal("health_updated", current_hp, max_hp)
	#emit_signal("energy_updated", current_energy, max_energy)

# Draw cards at the start of the player's turn
func draw_cards(amount: int):
	print("[DEBUG] Player requesting to draw " + str(amount) + " cards")
	emit_signal("draw_cards_requested", amount)  # Emit signal instead of calling Deck directly

# Apply a status effect like "stun" or "strength"
func apply_status(effect_name: String, amount: int):
	if status_effects.has(effect_name):
		status_effects[effect_name] += amount
	else:
		status_effects[effect_name] = amount

	print("[INFO] Player received status effect: " + effect_name + " (" + str(amount) + ")")

	# If stunned, the player skips their next turn
	if effect_name == "stun":
		print("[INFO] Player is stunned and will skip their next turn.")
	if effect_name == "strength":
		modify_strength(amount)

# Modify player's strength stat
func modify_strength(amount: int):
	strength += amount
	print("[INFO] Player strength changed by " + str(amount) + ". New strength: " + str(strength))

# Handle player taking damage
func take_damage(amount: int):
	var effective_damage = max(amount - armor, 0)
	armor = max(armor - amount, 0)  # Reduce armor first
	emit_signal("armor_updated", armor)
	current_hp = max(current_hp - effective_damage, 0)
	emit_signal("health_updated", current_hp, max_hp)

	# Check if player is dead
	if is_dead():
		die()

# Check if the player is dead
func is_dead() -> bool:
	return current_hp <= 0

# Handle player death
func die():
	emit_signal("player_died")

# Heal the player
func heal(amount: int):
	current_hp = min(current_hp + amount, max_hp)
	emit_signal("health_updated", current_hp, max_hp)
	print("[INFO] Player healed " + str(amount) + " HP.")

# Add armor to the player
func add_armor(amount: int):
	armor += amount
	emit_signal("armor_updated", amount)
	print("[INFO] Player gained " + str(amount) + " armor. Current armor: " + str(armor))

# Remove all armor
func strip_armor():
	armor = 0
	emit_signal("armor_updated", armor)
	print("[INFO] Player lost all armor.")

# Start the player's turn (regains energy and draws cards)
func start_turn():
	if status_effects.has("stun") and status_effects["stun"] > 0:
		print("[INFO] Player is stunned and skips their turn.")
		status_effects["stun"] -= 1  # Reduce stun duration
		return

	print("[INFO] Player's turn started!")
	current_energy = max_energy  # Restore energy
	emit_signal("energy_updated", current_energy, max_energy)
	draw_cards(5)  # Draw 2 cards at the start of turn

# End the player's turn
func end_turn():
	print("[INFO] Player's turn ended. Enemy turn starts!")
	emit_signal("action_chosen")  # Signals the game to switch to enemy turn
