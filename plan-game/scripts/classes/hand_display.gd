# scripts/classes/hand_display.gd
class_name HandDisplay
extends Control

"""
HandDisplay manages the visual arrangement and interaction of cards in a player's hand.

This component handles:
- Card positioning in fan layout
- Card selection and visual feedback
- Hand management operations (add, remove, clear)
- Integration with CardVisual components

Designed for mobile-first interaction with touch and mouse input support.
Part of the PLAN Card Game educational system.
"""

# Card data storage
var cards: Array[Card] = []
var card_visuals: Array[CardVisual] = []

func _ready() -> void:
	"""
	Initialize the HandDisplay component when added to the scene.
	"""
	pass

func add_card(card: Card) -> bool:
	"""
	Add a card to the hand display.

	Args:
		card: The Card instance to add to the hand

	Returns:
		bool: True if card was added successfully, false otherwise
	"""
	# Null validation - reject invalid input
	if not card:
		return false

	# Duplicate prevention - reject cards already in hand
	if card in cards:
		return false

	# Add card to the hand array
	cards.append(card)

	# Return success for valid addition
	return true

func remove_card(index: int) -> bool:
	"""
	Remove a card from the hand at the specified index.

	Args:
		index: The index of the card to remove (0-based)

	Returns:
		bool: True if removal was successful, false if invalid index
	"""
	# Bounds validation - reject invalid indices
	if index < 0 or index >= cards.size():
		return false

	# Remove card at specified index
	cards.remove_at(index)

	# Return success for valid removal
	return true

func get_card_count() -> int:
	"""
	Get the number of cards currently in the hand display.

	Returns:
		The number of cards in the hand
	"""
	return cards.size()

func clear_hand() -> void:
	"""
	Clear all cards from the hand display.
	"""
	cards.clear()

func _calculate_fan_positions() -> Array[Vector2]:
	"""
	Calculate fan positions for cards in the hand display.

	Returns:
		Array[Vector2]: Array of positions for each card in fan layout
	"""
	# Array to store calculated positions
	var positions: Array[Vector2] = []

	# Handle empty cards case
	if cards.is_empty():
		return []

	# Handle single card case
	if cards.size() == 1:
		return [Vector2(400, 300)]

	# Handle multiple cards case
	for i in range(cards.size()):
		# Calculate angle for this card position (placeholder)
		var angle = i * 0.1
		# Calculate and append position for this card
		positions.append(Vector2(400 + i * 50, 300))

	return positions
