class_name Effect
extends Resource

@export var name: String = "Effect Name"  # e.g., "Bleed", "Strength"
@export var target: String = "player"  # "player", "enemy", "all_enemies"
@export var amount: int = 0  # Value of the effect (e.g., +5 Strength)
@export var duration: int = 0  # How many turns the effect lasts (0 = instant)
@export var condition: String = ""  # Optional condition (e.g., "if_enemy_stunned")

var applied = false  # Track if effect is applied

# Apply the effect to a target
func apply(target_entity):
	applied = true
	print("[INFO] Applying Effect: %s (%d) to %s" % [name, amount, target_entity.name])
	if target_entity.has_method("apply_status"):
		target_entity.apply_status(name, amount)

# Update effect each turn (if it's ongoing)
func update():
	if duration > 0:
		duration -= 1
		print("[INFO] %s effect updated. Remaining turns: %d" % [name, duration])
		if duration == 0:
			remove()

# Remove the effect when expired
func remove():
	applied = false
	print("[INFO] Removing Effect: %s" % name)
