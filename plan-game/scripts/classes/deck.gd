# scripts/classes/deck.gd
class_name Deck
extends Resource

"""
Manages a collection of cards in the PLAN card game.
Provides functionality for card manipulation, drawing, and deck operations.
"""

# Signal to notify when deck state changes
signal deck_changed(current_size)
signal deck_emptied

# Internal card collection
var _cards: Array[Card] = []

# Optional deck configuration
var max_cards: int = -1 # -1 means no limit
var unique_cards: bool = false # Enforce unique cards in the deck

func _init(
		p_cards = [], # Remove the type constraint
		p_max_cards: int = -1,
		p_unique_cards: bool = false
) -> void:
	"""
	Initialize the deck with optional parameters.

	Args:
		p_cards: Initial collection of cards (any Card subclass)
		p_max_cards: Maximum number of cards allowed in the deck (-1 for unlimited)
		p_unique_cards: Enforce unique cards in the deck
	"""
	max_cards = p_max_cards
	unique_cards = p_unique_cards

	# Add initial cards with validation
	for card in p_cards:
		if card is Card:
			add_card(card)
		else:
			push_error("Non-Card object provided to Deck constructor")

func add_card(card: Card) -> bool:
	"""
	Add a single card to the deck with validation.

	Args:
		card: Card to be added

	Returns:
		Whether the card was successfully added
	"""
	# Check maximum card limit
	if max_cards != -1 and _cards.size() >= max_cards:
		push_warning("Deck is at maximum capacity. Cannot add more cards.")
		return false

	# Check for unique cards if enabled
	if unique_cards and _cards.has(card):
		push_warning("Unique cards only. Card already exists in deck.")
		return false

	_cards.append(card)
	emit_signal("deck_changed", _cards.size())
	return true

func add_cards(cards: Array[Card]) -> int:
	"""
	Add multiple cards to the deck.

	Args:
		cards: Array of cards to be added

	Returns:
		Number of cards successfully added
	"""
	var added_count = 0
	for card in cards:
		if add_card(card):
			added_count += 1
	return added_count

func remove_card(index: int) -> Card:
	"""
	Remove and return a card at a specific index.

	Args:
		index: Index of the card to remove

	Returns:
		Removed card, or null if index is invalid
	"""
	if index < 0 or index >= _cards.size():
		push_warning("Invalid card index for removal.")
		return null

	var removed_card = _cards.pop_at(index)
	emit_signal("deck_changed", _cards.size())

	if _cards.is_empty():
		emit_signal("deck_emptied")

	return removed_card

func draw_card() -> Card:
	"""
	Draw the top card from the deck.

	Returns:
		Top card, or null if deck is empty
	"""
	if _cards.is_empty():
		push_warning("Cannot draw from an empty deck.")
		return null

	var drawn_card = _cards.pop_front()
	emit_signal("deck_changed", _cards.size())

	if _cards.is_empty():
		emit_signal("deck_emptied")

	return drawn_card

func shuffle() -> void:
	"""
	Randomize the order of cards in the deck.
	Uses Godot's built-in shuffle method with randomization.
	"""
	randomize() # Ensure random seed is set
	_cards.shuffle()
	emit_signal("deck_changed", _cards.size())

func peek_top_card() -> Card:
	"""
	View the top card without removing it.

	Returns:
		Top card, or null if deck is empty
	"""
	return _cards.front() if !_cards.is_empty() else null

func size() -> int:
	"""
	Get the current number of cards in the deck.

	Returns:
		Number of cards in the deck
	"""
	return _cards.size()

func is_empty() -> bool:
	"""
	Check if the deck is empty.

	Returns:
		True if no cards remain, false otherwise
	"""
	return _cards.is_empty()

func clear() -> void:
	"""
	Remove all cards from the deck.
	"""
	_cards.clear()
	emit_signal("deck_changed", 0)
	emit_signal("deck_emptied")

func get_cards() -> Array[Card]:
	"""
	Get a copy of all cards in the deck.

	Returns:
		A copy of the deck's card collection
	"""
	return _cards.duplicate()

func _to_string() -> String:
	"""
	Generate a string representation of the deck.

	Returns:
		A string describing the deck's current state
	"""
	return "[Deck: %d cards (Max: %d, Unique: %s)]" % [
		_cards.size(),
		str(max_cards) if max_cards != -1 else "Unlimited",
		"Yes" if unique_cards else "No"
	]
