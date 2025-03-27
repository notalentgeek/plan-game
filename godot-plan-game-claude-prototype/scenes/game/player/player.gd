# player.gd
# Represents a player in the Plan Card Game
class_name Player
extends Resource

# Basic player properties
var id: int
var name: String = ""

# Player's hand of cards
var hand: Array[Card] = []

func _init(p_id: int, p_name: String = "") -> void:
	id = p_id
	name = p_name if not p_name.is_empty() else "Player %d" % (id + 1)

## Card Management Methods

func add_card(card: Card) -> void:
	"""
	Add a card to the player's hand.
	"""
	hand.append(card)

func remove_card(index: int) -> Card:
	"""
	Remove a card from the player's hand by index.
	Returns the removed card or null if index is invalid.
	"""
	if index >= 0 and index < hand.size():
		var card = hand[index]
		hand.remove_at(index)
		return card
	return null

func get_card_at(index: int) -> Card:
	"""
	Get the card at the specified index without removing it.
	Returns the card or null if index is invalid.
	"""
	if index >= 0 and index < hand.size():
		return hand[index]
	return null

func has_card(card_id: String) -> bool:
	"""
	Check if the player has a card with the specified ID.
	"""
	for card in hand:
		if card.id == card_id:
			return true
	return false

func clear_hand() -> void:
	"""
	Remove all cards from the player's hand.
	"""
	hand.clear()

func hand_size() -> int:
	"""
	Get the number of cards in the player's hand.
	"""
	return hand.size()

## Card Counting Methods

func count_problem_cards() -> int:
	"""
	Count the number of problem cards in the player's hand.
	"""
	var count = 0
	for card in hand:
		if card.card_type == Card.CardType.PROBLEM:
			count += 1
	return count

func count_solution_cards() -> int:
	"""
	Count the number of solution cards in the player's hand.
	"""
	var count = 0
	for card in hand:
		if card.card_type == Card.CardType.SOLUTION or card.card_type == Card.CardType.ULTIMATE:
			count += 1
	return count

func has_ultimate_card() -> bool:
	"""
	Check if the player has an ultimate card.
	"""
	for card in hand:
		if card.card_type == Card.CardType.ULTIMATE:
			return true
	return false

func get_problem_cards() -> Array[Card]:
	"""
	Get all problem cards in the player's hand.
	"""
	var problems: Array[Card] = []
	for card in hand:
		if card.card_type == Card.CardType.PROBLEM:
			problems.append(card)
	return problems

func get_solution_cards() -> Array[Card]:
	"""
	Get all solution cards in the player's hand.
	"""
	var solutions: Array[Card] = []
	for card in hand:
		if card.card_type == Card.CardType.SOLUTION or card.card_type == Card.CardType.ULTIMATE:
			solutions.append(card)
	return solutions

## Utility Methods

func get_identical_problem_cards() -> Dictionary:
	"""
	Group identical problem cards in the player's hand.
	Returns a dictionary mapping card IDs to arrays of card indices.
	"""
	var groups = {}

	for i in range(hand.size()):
		var card = hand[i]
		if card.card_type == Card.CardType.PROBLEM:
			if not groups.has(card.id):
				groups[card.id] = []
			groups[card.id].append(i)

	# Filter out groups with only one card
	var result = {}
	for id in groups:
		if groups[id].size() > 1:
			result[id] = groups[id]

	return result

func _to_string() -> String:
	return "[Player %d: %s - %d cards]" % [id, name, hand.size()]
