extends Node2D

# Apply Effects from a Card to a Target
func apply_effects(card, player, target, enemies):
	if !card or !player or !target:
		print("[ERROR] Invalid parameters for apply_effects()")
		return

	# Ensure the card has the Effects array
	if not "Effects" in card or not card.Effects or card.Effects.is_empty():
		print("[WARNING] Card '" + card.CardName + "' has no effects defined.")
		return  

	print("[INFO] Applying effects for card: " + card.CardName)

	# Loop through all effects on the card
	for effect in card.Effects:
		var effect_type = effect.get("type", "")

		match effect_type:
			"damage":
				apply_damage(effect, target, enemies)
			"status_effect":
				apply_status_effect(effect, target)
			"insta_kill":
				apply_insta_kill(effect, target)
			"strip_armor":
				strip_armor(effect, target)
			"update_max_hp":
				update_max_hp(effect, player, target)
			"armor":
				apply_armor(effect, player) # Only applies to player
			"draw":
				draw_cards(effect, player) # Only applies to player
			_:
				print("[WARNING] Unknown effect type:", effect_type)

# Effect Functions

# Apply Damage to Enemy or All Enemies
func apply_damage(effect, target, enemies = null):
	var amount = effect.get("amount", 0)
	var target_type = effect.get("target", "")

	if target_type == "enemy":
		print("[INFO] Dealing " + str(amount) + " damage to " + target.name)
		target.take_damage(amount)
	elif target_type == "all_enemies" and enemies:
		print("[INFO] Dealing " + str(amount) + " damage to ALL enemies")
		for enemy in enemies:
			enemy.take_damage(amount)

# Apply Status Effect (Bleed, Stun, Weaken, etc.)
func apply_status_effect(effect, target):
	var status_type = effect.get("effect", "")
	var amount = effect.get("amount", 0)

	if target.has_method("apply_status"):
		print("[INFO] Applying Status Effect: " + status_type + " (" + str(amount) + ") to " + target.name)
		target.apply_status(status_type, amount)
	else:
		print("[ERROR] Target '" + target.name + "' cannot receive status effects!")

# Instantly Kill Enemy if Condition is Met
func apply_insta_kill(effect, target):
	var condition = effect.get("condition", "")
	if condition == "target_hp <= 40" and target.get_health_percentage() <= 40:
		print("[INFO] Insta-Killing " + target.name)
		target.die()

# Remove Armor from Target
func strip_armor(effect, target):
	if target.has_method("remove_armor"):
		print("[INFO] Stripping armor from " + target.name)
		target.remove_armor()
	else:
		print("[ERROR] Target '" + target.name + "' has no armor to strip!")

# Increase Player Max HP if Enemy is Killed
func update_max_hp(effect, player, target):
	var condition = effect.get("condition", "")
	var amount = effect.get("amount", 0)

	if condition == "target_hp <= 0" and target.is_dead():
		print("[INFO] Increasing Player Max HP by " + str(amount))
		player.increase_max_hp(amount)

# Apply Armor to Player (Only the Player)
func apply_armor(effect, player):
	var amount = effect.get("amount", 0)

	if player.has_method("add_armor"):
		print("[INFO] Adding " + str(amount) + " armor to Player")
		player.add_armor(amount)
	else:
		print("[ERROR] Player cannot receive armor!")

# Draw Cards for Player (Only the Player)
func draw_cards(effect, player):
	var amount = effect.get("amount", 0)

	if player.has_method("draw_cards"):
		print("[INFO] Drawing " + str(amount) + " cards for Player")
		player.draw_cards(amount)
	else:
		print("[ERROR] Player cannot draw cards!")
