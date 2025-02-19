extends Node

# This script works as the stack of any card game.
# What should happen here? 
# When we play actions, we want them to happen as the stack is cleared.
# so?
# 1. Add items to the stack.
# 2. Resolve the stack when the 

# The stack for the current actions we have
@onready var CurrentStack: Array = []

# The stack for the next round of actions <- This will resolve first
@onready var NextTurnStack: Array = []
