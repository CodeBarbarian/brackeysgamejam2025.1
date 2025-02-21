extends Node2D

# Apply effects from a card to player, target, or enemies
func apply_effects(card, player, target, enemies):
	if !card or !player or !target:
		print("Error: Invalid parameters for apply_effects()")
		return
	
	if !card.has_method("set_card_values") or !card.has_method("_update_graphics"):
		print("Error: The card object is not properly initialized.")
		return
	
	if not "Effects" in card or card.Effects.is_empty():
		print("Error: Card has no effects defined")
		return
	
	for effect in card.Effects:
		match effect.get("type", ""):
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
				apply_armor(effect, player)
			"draw":
				draw_cards(effect, player)
			_:
				print("Unknown effect type:", effect.get("type", ""))

# ---------------------- EFFECT FUNCTIONS ----------------------

# Apply Damage Effect
func apply_damage(effect, target, enemies = null):
	var amount = effect.get("amount", 0)
	if effect.get("target", "") == "enemy":
		target.take_damage(amount)
	elif effect.get("target", "") == "all_enemies" and enemies:
		for enemy in enemies:
			enemy.take_damage(amount)

# Apply Status Effect (e.g., weaken, poison)
func apply_status_effect(effect, target):
	var status_type = effect.get("effect", "")
	var amount = effect.get("amount", 0)
	target.apply_status(status_type, amount)

# Apply Insta-Kill (Conditional)
func apply_insta_kill(effect, target):
	if effect.has("condition") and effect["condition"] == "target_hp <= 40":
		if target.get_health_percentage() <= 40:
			target.kill()

# Strip Armor from Target
func strip_armor(effect, target):
	target.remove_armor()

# Increase Player Max HP (Conditional on Enemy Death)
func update_max_hp(effect, player, target):
	if effect.has("condition") and effect["condition"] == "target_hp <= 0":
		if target.is_dead():
			var amount = effect.get("amount", 0)
			player.increase_max_hp(amount)

# Apply Armor to Player
func apply_armor(effect, player):
	var amount = effect.get("amount", 0)
	player.add_armor(amount)

# Draw Cards for Player
func draw_cards(effect, player):
	var amount = effect.get("amount", 0)
	player.draw_cards(amount)
