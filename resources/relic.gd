class_name Relic extends Resource

@export var name: String = "Unnamed Relic"
@export var description: String = ""
@export var relic_type: String = "passive"  # Can be "passive", "triggered"
@export var effects: Array = []  # List of effects (same format as cards)
@export var negative_effects: Array = []  # List of negative effects
@export var conditions: Array = []  # Conditions that must be met to trigger the relic

func activate_effects(player, enemies = []):
	for effect in effects:
		apply_effect(effect, player, enemies)

	# Apply negative effects if conditions are met
	for negative_effect in negative_effects:
		if check_conditions(player, enemies):
			apply_effect(negative_effect, player, enemies)

func apply_effect(effect, player, enemies):
	var effect_type = effect.get("type", "")
	match effect_type:
		"damage":
			player.take_damage(effect.get("amount", 0))
		"status_effect":
			player.apply_status(effect.get("effect", ""), effect.get("amount", 0))
		"gain_energy":
			player.gain_energy(effect.get("amount", 0))
		"gold_bonus":
			player.modify_gold(effect.get("amount", 0))
		"draw":
			player.draw_cards(effect.get("amount", 0))

func check_conditions(player, enemy = null):
	for condition in conditions:
		match condition:
			"kill_with_poison":
				if enemy and enemy.is_dead() and "poison" in enemy.status_effects:
					return true
			"start_of_combat":
				return true
			"on_turn_start":
				return true
	return false
