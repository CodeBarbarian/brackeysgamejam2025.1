extends Node

# Apply Effects from a Card to a Target
func apply_effects(card, player, target, enemies):
	if !card or !player or !target:
		print("[ERROR] Invalid parameters for apply_effects()")
		return

	if not "Effects" in card or not card.Effects or card.Effects.is_empty():
		print("[WARNING] Card '" + card.CardName + "' has no effects defined.")
		return  

	print("[INFO] Applying effects for card: " + card.CardName)

	for effect in card.Effects:
		var effect_type = effect.get("type", "")

		match effect_type:
			"damage":
				apply_damage(effect, player, target, enemies)  
			"status_effect":
				apply_status_effect(effect, player, target, enemies)
			"insta_kill":
				apply_insta_kill(effect, player, target)
			"strip_armor":
				strip_armor(effect, target)
			"update_max_hp":
				update_max_hp(effect, player, target)
			"armor":
				apply_armor(effect, player)
			"draw":
				draw_cards(effect, player)
			"heal":
				apply_heal(effect, player)
			"gold_bonus":
				modify_gold(effect, player)

	# Only apply relics to player (not target)
	player.apply_relics("after_effect")

	# UI updates
	player.emit_signal("health_updated", player.current_hp, player.max_hp)
	player.emit_signal("energy_updated", player.current_energy, player.max_energy)
	player.emit_signal("armor_updated", player.armor)

	target.emit_signal("health_updated", target.current_hp, target.max_hp)
	target.emit_signal("armor_updated", target.armor)


# Apply Damage to Enemy or All Enemies
func apply_damage(effect, player, target, enemies = null):
	var amount = effect.get("amount", 0)
	var target_type = effect.get("target", "")

	if target_type == "enemy":
		target.take_damage(amount)

		# Trigger relic effects **only if the target dies**
		if target.is_dead():
			player.apply_relics("on_kill", target)

	elif target_type == "all_enemies" and enemies:
		for enemy in enemies:
			enemy.take_damage(amount)

			# Trigger relic effects **only if an enemy dies**
			if enemy.is_dead():
				player.apply_relics("on_kill", enemy)


# Apply Status Effect (Bleed, Stun, Weaken, etc.)
func apply_status_effect(effect, player, target, enemies):
	var status_type = effect.get("effect", "")
	var amount = effect.get("amount", 0)
	var target_type = effect.get("target", "")

	if target_type == "enemy":
		target.apply_status(status_type, amount)
	elif target_type == "player":
		player.apply_status(status_type, amount)
	elif target_type == "all_enemies":
		for enemy in enemies:
			enemy.apply_status(status_type, amount)
	else:
		print("[WARNING] Invalid target type for status effect:", target_type)

# Instantly Kill Enemy if Condition is Met
# Instantly Kill Enemy if Condition is Met
func apply_insta_kill(effect, player, target):
	var condition = effect.get("condition", "")

	# Now checks the correct function
	if condition == "target_hp < 40" and target.get_health_percentage() < 40:
		print("[INFO] Insta-Killing", target.EnemyName)
		target.die()

		# Trigger relic effects on kill
		player.apply_relics("on_kill", target)



# Remove Armor from Target
func strip_armor(effect, target):
	target.remove_armor()

# Increase Player Max HP if Enemy is Killed
func update_max_hp(effect, player, target):
	var condition = effect.get("condition", "")
	var amount = effect.get("amount", 0)

	if condition == "target_hp <= 0" and target.is_dead():
		player.increase_max_hp(amount)

		# Apply relic effect for max HP gain
		player.apply_relics("on_max_hp_gain")

# Apply Armor to Player (Only the Player)
func apply_armor(effect, player):
	var amount = effect.get("amount", 0)
	player.add_armor(amount)

# Draw Cards for Player (Only the Player)
func draw_cards(effect, player):
	var amount = effect.get("amount", 0)
	player.draw_cards(amount)

# Heal the Player
func apply_heal(effect, player):
	var amount = effect.get("amount", 0)
	player.heal(amount)

# Modify Gold Amount
func modify_gold(effect, player):
	var amount = effect.get("amount", 0)
	player.modify_gold(amount)
