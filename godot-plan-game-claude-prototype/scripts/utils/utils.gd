# utils.gd
# Utility functions for the Plan Card Game
class_name Utils
extends Node

## Card Utilities

static func get_card_type_name(type: int) -> String:
	"""
	Convert a card type enum value to a readable string.
	"""
	match type:
		Card.CardType.PROBLEM:
			return "Problem"
		Card.CardType.SOLUTION:
			return "Solution"
		Card.CardType.ULTIMATE:
			return "Ultimate"
		_:
			return "Unknown"

static func get_card_color(card: Card) -> Color:
	"""
	Get the appropriate color for a card based on its type.
	"""
	match card.card_type:
		Card.CardType.PROBLEM:
			return Color(0.9, 0.3, 0.3, 1.0) # Red for problems
		Card.CardType.SOLUTION:
			return Color(0.3, 0.7, 0.3, 1.0) # Green for solutions
		Card.CardType.ULTIMATE:
			return Color(0.9, 0.7, 0.1, 1.0) # Gold for ultimate cards
		_:
			return Color(0.5, 0.5, 0.5, 1.0) # Gray for unknown

## Array Utilities

static func filter_cards_by_type(cards: Array[Card], type: int) -> Array[Card]:
	"""
	Filter an array of cards by type.
	"""
	var filtered: Array[Card] = []
	for card in cards:
		if card.card_type == type:
			filtered.append(card)
	return filtered

static func find_card_by_id(cards: Array[Card], id: String) -> Card:
	"""
	Find a card with the specified ID in an array of cards.
	Returns the card or null if not found.
	"""
	for card in cards:
		if card.id == id:
			return card
	return null

## Game State Utilities

static func format_score_display(scores: Dictionary) -> String:
	"""
	Format a dictionary of scores for display.
	"""
	var result = ""
	var keys = scores.keys()
	keys.sort()

	for player_id in keys:
		result += "Player %d: %d points\n" % [player_id + 1, scores[player_id]]

	return result

static func get_time_formatted(seconds: int) -> String:
	"""
	Format time in seconds to MM:SS format.
	"""
	var minutes = seconds / 60
	var remaining_seconds = seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]

## Misc Utilities

static func truncate_text(text: String, max_length: int) -> String:
	"""
	Truncate text to a maximum length, adding ellipsis if needed.
	"""
	if text.length() <= max_length:
		return text
	return text.substr(0, max_length - 3) + "..."

static func get_random_id() -> String:
	"""
	Generate a random ID string.
	"""
	randomize()
	return str(randi() % 100000000).pad_zeros(8)
