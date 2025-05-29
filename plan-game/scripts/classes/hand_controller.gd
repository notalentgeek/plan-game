# scripts/classes/hand_controller.gd
class_name HandController
extends Node

"""
Controller that mediates between HandDisplay and CardDatabase.
Provides clean separation between UI components and data sources.
"""

# Card type distribution for random selection
enum CardDistribution {
	RANDOM, # Completely random selection
	BALANCED, # Equal distribution of types
	PROBLEM_HEAVY, # More problem cards than solutions
	SOLUTION_HEAVY, # More solution cards than problems
	CUSTOM # User-defined ratios
}

# Configuration for card selection
@export var default_distribution: CardDistribution = CardDistribution.BALANCED
@export var custom_problem_ratio: float = 0.6
@export var custom_solution_ratio: float = 0.3
@export var custom_ultimate_ratio: float = 0.1

# Card management state
var loaded_cards: Array[Card] = []
var card_type_counts: Dictionary = {}
var last_selected_indices: Array[int] = []

# Database access validation
var database_accessible: bool = false

# Signals for card events
signal cards_loaded(cards: Array[Card])
signal card_added(card: Card)
signal card_removed(card: Card)
signal database_error(message: String)

func _ready() -> void:
	"""
	Initialize when added to scene tree.
	"""
	print("HandController: Initializing...")
	_validate_database_access()

func _init() -> void:
	"""
	Initialize for direct instantiation (when not in scene).
	"""
	print("HandController: Direct instantiation...")

func _validate_database_access() -> void:
	"""
	Validate that CardDatabase autoload is accessible.
	"""
	var db = get_node_or_null("/root/CardDatabase")
	if db:
		database_accessible = true
		print("HandController: CardDatabase access validated ✓")
	else:
		database_accessible = false
		push_error("HandController: CardDatabase not accessible")
		database_error.emit("CardDatabase autoload not available")

func load_random_cards(count: int, distribution: CardDistribution = CardDistribution.BALANCED) -> Array[Card]:
	"""
	Load a specified number of random cards from the database.

	Args:
		count: Number of cards to load
		distribution: Type distribution pattern to use

	Returns:
		Array of loaded Card instances
	"""
	if not database_accessible:
		push_error("CardDatabase not accessible")
		return []

	if count <= 0:
		return []

	var selected_cards: Array[Card] = []
	var db = get_node_or_null("/root/CardDatabase")

	if not db:
		push_error("CardDatabase not found")
		return []

	# Determine card type counts based on distribution
	var type_counts = _calculate_type_distribution(count, distribution)

	# Get cards of each type
	var problem_cards = _get_random_cards_of_type(Card.CardType.PROBLEM, type_counts.get("problem", 0))
	var solution_cards = _get_random_cards_of_type(Card.CardType.SOLUTION, type_counts.get("solution", 0))
	var ultimate_cards = _get_random_cards_of_type(Card.CardType.ULTIMATE, type_counts.get("ultimate", 0))

	# Combine all cards
	selected_cards.append_array(problem_cards)
	selected_cards.append_array(solution_cards)
	selected_cards.append_array(ultimate_cards)

	# Shuffle the final selection
	selected_cards.shuffle()

	# Store in loaded cards
	loaded_cards = selected_cards
	_update_card_type_counts()

	# Emit signal
	cards_loaded.emit(selected_cards.duplicate())

	print("HandController: Loaded %d cards with %s distribution" % [selected_cards.size(), CardDistribution.keys()[distribution]])
	return selected_cards

func add_random_card(distribution: CardDistribution = CardDistribution.RANDOM) -> Card:
	"""
	Add a single random card to the current hand.

	Args:
		distribution: Type distribution hint for selection

	Returns:
		The added Card instance, or null if failed
	"""
	if not database_accessible:
		push_error("CardDatabase not accessible")
		return null

	var new_card: Card = null

	# For single card addition, use simple random selection unless distribution is specified
	if distribution == CardDistribution.RANDOM:
		new_card = _get_completely_random_card()
	else:
		# Use distribution logic for single card
		var type_counts = _calculate_type_distribution(1, distribution)

		# Find which type to add based on distribution
		for card_type in type_counts:
			if type_counts[card_type] > 0:
				var card_type_enum = _string_to_card_type(card_type)
				var cards = _get_random_cards_of_type(card_type_enum, 1)
				if not cards.is_empty():
					new_card = cards[0]
					break

	if new_card:
		loaded_cards.append(new_card)
		_update_card_type_counts()
		card_added.emit(new_card)
		print("HandController: Added card - %s" % new_card.card_name)

	return new_card

func remove_card(card: Card) -> bool:
	"""
	Remove a specific card from the loaded cards.

	Args:
		card: The card to remove

	Returns:
		True if the card was successfully removed
	"""
	if not card:
		return false

	var index = loaded_cards.find(card)
	if index >= 0:
		loaded_cards.remove_at(index)
		_update_card_type_counts()
		card_removed.emit(card)
		print("HandController: Removed card - %s" % card.card_name)
		return true

	return false

func remove_cards(cards: Array[Card]) -> int:
	"""
	Remove multiple cards from the loaded cards.

	Args:
		cards: Array of cards to remove

	Returns:
		Number of cards successfully removed
	"""
	var removed_count = 0

	for card in cards:
		if remove_card(card):
			removed_count += 1

	return removed_count

func clear_loaded_cards() -> void:
	"""
	Clear all currently loaded cards.
	"""
	loaded_cards.clear()
	card_type_counts.clear()
	last_selected_indices.clear()
	print("HandController: Cleared all loaded cards")

func get_loaded_cards() -> Array[Card]:
	"""
	Get all currently loaded cards.

	Returns:
		Array of loaded Card instances
	"""
	return loaded_cards.duplicate()

func get_card_by_id(card_id: String) -> Card:
	"""
	Get a specific card by its ID from the database.

	Args:
		card_id: The ID of the card to retrieve

	Returns:
		The Card instance, or null if not found
	"""
	if not database_accessible:
		return null

	var db = get_node_or_null("/root/CardDatabase")
	if not db:
		return null

	return db.get_card_by_id(card_id)

func get_cards_by_type(card_type: Card.CardType) -> Array[Card]:
	"""
	Get all cards of a specific type from the database.

	Args:
		card_type: The type of cards to retrieve

	Returns:
		Array of Card instances of the specified type
	"""
	if not database_accessible:
		return []

	var db = get_node_or_null("/root/CardDatabase")
	if not db:
		return []

	# Use the CardDatabase helper method that already handles type conversion
	return db.get_cards_by_type(card_type)

func shuffle_loaded_cards() -> void:
	"""
	Shuffle the order of currently loaded cards.
	"""
	loaded_cards.shuffle()
	print("HandController: Shuffled loaded cards")

func get_card_type_distribution() -> Dictionary:
	"""
	Get the current distribution of card types in loaded cards.

	Returns:
		Dictionary with type counts and percentages
	"""
	var total = loaded_cards.size()
	if total == 0:
		return {}

	var distribution = {}
	for type_name in card_type_counts:
		var count = card_type_counts[type_name]
		distribution[type_name] = {
			"count": count,
			"percentage": (float(count) / float(total)) * 100.0
		}

	return distribution

func _calculate_type_distribution(total_count: int, distribution: CardDistribution) -> Dictionary:
	"""
	Calculate how many cards of each type to select.

	Args:
		total_count: Total number of cards to distribute
		distribution: Distribution pattern to use

	Returns:
		Dictionary with problem, solution, and ultimate counts
	"""
	var type_counts = {"problem": 0, "solution": 0, "ultimate": 0}

	match distribution:
		CardDistribution.RANDOM:
			# Completely random - we'll pick randomly from all types
			type_counts["problem"] = total_count # Will be filtered in _get_completely_random_card

		CardDistribution.BALANCED:
			# Try to balance problem and solution cards, few ultimate
			var ultimate_count = max(1, total_count / 10) if total_count >= 10 else 0
			var remaining = total_count - ultimate_count
			var problem_count = remaining / 2
			var solution_count = remaining - problem_count

			type_counts["problem"] = problem_count
			type_counts["solution"] = solution_count
			type_counts["ultimate"] = ultimate_count

		CardDistribution.PROBLEM_HEAVY:
			# More problems than solutions
			var ultimate_count = max(1, total_count / 15) if total_count >= 15 else 0
			var remaining = total_count - ultimate_count
			var problem_count = int(remaining * 0.7) # 70% of remaining
			var solution_count = remaining - problem_count

			type_counts["problem"] = problem_count
			type_counts["solution"] = solution_count
			type_counts["ultimate"] = ultimate_count

		CardDistribution.SOLUTION_HEAVY:
			# More solutions than problems
			var ultimate_count = max(1, total_count / 12) if total_count >= 12 else 0
			var remaining = total_count - ultimate_count
			var solution_count = int(remaining * 0.7) # 70% of remaining
			var problem_count = remaining - solution_count

			type_counts["problem"] = problem_count
			type_counts["solution"] = solution_count
			type_counts["ultimate"] = ultimate_count

		CardDistribution.CUSTOM:
			# Use custom ratios
			var problem_count = int(total_count * custom_problem_ratio)
			var solution_count = int(total_count * custom_solution_ratio)
			var ultimate_count = int(total_count * custom_ultimate_ratio)

			# Adjust if total doesn't match due to rounding
			var calculated_total = problem_count + solution_count + ultimate_count
			if calculated_total < total_count:
				problem_count += total_count - calculated_total

			type_counts["problem"] = problem_count
			type_counts["solution"] = solution_count
			type_counts["ultimate"] = ultimate_count

	return type_counts

func _get_random_cards_of_type(card_type: Card.CardType, count: int) -> Array[Card]:
	"""
	Get random cards of a specific type from the database.

	Args:
		card_type: The type of cards to select
		count: Number of cards to select

	Returns:
		Array of selected Card instances
	"""
	if count <= 0 or not database_accessible:
		return []

	var available_cards = get_cards_by_type(card_type)
	if available_cards.is_empty():
		push_warning("No cards available of type: %s" % Card.CardType.keys()[card_type])
		return []

	# Shuffle and take the requested count
	available_cards.shuffle()
	var selected_count = min(count, available_cards.size())

	return available_cards.slice(0, selected_count)

func _get_completely_random_card() -> Card:
	"""
	Get a completely random card from any type in the database.

	Returns:
		A random Card instance, or null if none available
	"""
	if not database_accessible:
		return null

	var db = get_node_or_null("/root/CardDatabase")
	if not db:
		return null

	# Get all cards from all types using the helper method
	var all_cards: Array[Card] = []
	all_cards.append_array(db.get_cards_by_type(Card.CardType.PROBLEM))
	all_cards.append_array(db.get_cards_by_type(Card.CardType.SOLUTION))
	all_cards.append_array(db.get_cards_by_type(Card.CardType.ULTIMATE))

	if all_cards.is_empty():
		return null

	return all_cards[randi() % all_cards.size()]

func _string_to_card_type(type_string: String) -> Card.CardType:
	"""
	Convert string representation to CardType enum.

	Args:
		type_string: String representation of card type

	Returns:
		Corresponding CardType enum value
	"""
	match type_string.to_lower():
		"problem":
			return Card.CardType.PROBLEM
		"solution":
			return Card.CardType.SOLUTION
		"ultimate":
			return Card.CardType.ULTIMATE
		_:
			return Card.CardType.PROBLEM

func _update_card_type_counts() -> void:
	"""
	Update the internal card type count tracking.
	"""
	card_type_counts.clear()

	for card in loaded_cards:
		var type_name = Card.CardType.keys()[card.card_type].to_lower()
		card_type_counts[type_name] = card_type_counts.get(type_name, 0) + 1

func validate_controller_state() -> bool:
	"""
	Validate the current controller state for consistency.

	Returns:
		True if the controller state is valid
	"""
	# Check database connection
	if not database_accessible:
		push_error("CardDatabase not accessible")
		return false

	# Check loaded cards are valid
	for card in loaded_cards:
		if not card:
			push_error("Null card found in loaded_cards")
			return false

	# Check type counts match loaded cards
	var calculated_counts = {}
	for card in loaded_cards:
		var type_name = Card.CardType.keys()[card.card_type].to_lower()
		calculated_counts[type_name] = calculated_counts.get(type_name, 0) + 1

	for type_name in card_type_counts:
		if card_type_counts[type_name] != calculated_counts.get(type_name, 0):
			push_error("Card type count mismatch for %s: tracked=%d, actual=%d" % [
				type_name, card_type_counts[type_name], calculated_counts.get(type_name, 0)
			])
			return false

	return true

func get_controller_info() -> Dictionary:
	"""
	Get comprehensive controller information for debugging.

	Returns:
		Dictionary containing controller state and statistics
	"""
	return {
		"default_distribution": CardDistribution.keys()[default_distribution],
		"database_accessible": database_accessible,
		"loaded_cards_count": loaded_cards.size(),
		"card_type_counts": card_type_counts.duplicate(),
		"type_distribution": get_card_type_distribution(),
		"is_valid": validate_controller_state()
	}

# Test methods for validation
func test_basic_operations() -> void:
	"""
	Test basic database operations.
	"""
	if not database_accessible:
		print("✗ Cannot test operations - CardDatabase not accessible")
		return

	print("HandController: Testing basic operations...")

	var db = get_node_or_null("/root/CardDatabase")
	if not db:
		print("✗ Database node not found")
		return

	# Test card retrieval methods using the helper method
	var problem_cards = db.get_cards_by_type(Card.CardType.PROBLEM)
	var solution_cards = db.get_cards_by_type(Card.CardType.SOLUTION)
	var ultimate_cards = db.get_cards_by_type(Card.CardType.ULTIMATE)

	print("✓ Problem cards: %d" % problem_cards.size())
	print("✓ Solution cards: %d" % solution_cards.size())
	print("✓ Ultimate cards: %d" % ultimate_cards.size())

	# Test random card loading
	var test_cards = load_random_cards(5, CardDistribution.BALANCED)
	print("✓ Loaded %d random cards" % test_cards.size())

	# Test card addition
	var added_card = add_random_card()
	if added_card:
		print("✓ Added random card: %s" % added_card.card_name)

	print("✓ Basic operations test completed")

func _to_string() -> String:
	"""
	Convert hand controller to string representation for debugging.

	Returns:
		String representation of the controller state
	"""
	return "[HandController: %d loaded, %s distribution, DB accessible: %s]" % [
		loaded_cards.size(),
		CardDistribution.keys()[default_distribution],
		database_accessible
	]
