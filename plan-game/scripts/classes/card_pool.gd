# scripts/classes/card_pool.gd
class_name CardPool
extends RefCounted

"""
Manages a pool of CardVisual instances for efficient memory usage and performance.
Provides object pooling to avoid frequent instantiation/destruction of card visuals.
"""

# Pool configuration
@export var initial_pool_size: int = 10
@export var max_pool_size: int = 100
@export var growth_increment: int = 5
@export var auto_cleanup_threshold: int = 50 # Start cleanup when unused pool exceeds this

# Pool state
var available_cards: Array[CardVisual] = []
var active_cards: Dictionary = {} # Card -> CardVisual mapping
var total_created: int = 0
var peak_usage: int = 0

# Parent node for card visuals (set by HandDisplay)
var parent_container: Control = null

# Signals for pool events
signal card_visual_created(card_visual: CardVisual)
signal card_visual_recycled(card_visual: CardVisual)
signal pool_expanded(new_size: int)
signal pool_cleaned_up(removed_count: int)

func _init(
	p_initial_size: int = 10,
	p_max_size: int = 100,
	p_growth_increment: int = 5
) -> void:
	"""
	Initialize the card pool with specified parameters.

	Args:
		p_initial_size: Number of CardVisuals to pre-create
		p_max_size: Maximum number of CardVisuals to pool
		p_growth_increment: How many cards to create when expanding
	"""
	initial_pool_size = max(1, p_initial_size)
	max_pool_size = max(initial_pool_size, p_max_size)
	growth_increment = max(1, p_growth_increment)

func initialize_pool(container: Control) -> void:
	"""
	Initialize the pool with a parent container for card visuals.

	Args:
		container: The Control node that will parent card visuals
	"""
	if not container:
		push_error("Cannot initialize CardPool with null container")
		return

	parent_container = container

	# Pre-create initial pool
	_expand_pool(initial_pool_size)

func get_card_visual(card: Card) -> CardVisual:
	"""
	Get a CardVisual instance for the specified card, either from pool or create new.

	Args:
		card: The Card data to display

	Returns:
		A CardVisual instance initialized with the card data
	"""
	if not card:
		push_error("Cannot create CardVisual for null card")
		return null

	if not parent_container:
		push_error("CardPool not initialized with parent container")
		return null

	var card_visual: CardVisual = null

	# Try to get from available pool
	if not available_cards.is_empty():
		card_visual = available_cards.pop_back()
	else:
		# Pool is empty, try to expand
		if total_created < max_pool_size:
			_expand_pool(growth_increment)
			if not available_cards.is_empty():
				card_visual = available_cards.pop_back()

		# If still no card available, create directly (exceeding pool limit)
		if not card_visual:
			card_visual = _create_card_visual()
			push_warning("CardPool exceeded max size, creating card directly")

	if not card_visual:
		push_error("Failed to create or retrieve CardVisual")
		return null

	# Initialize the card visual
	card_visual.initialize(card)
	card_visual.visible = true
	card_visual.modulate = Color.WHITE
	card_visual.position = Vector2.ZERO
	card_visual.rotation_degrees = 0.0
	card_visual.scale = Vector2.ONE

	# Add to parent and track as active
	if card_visual.get_parent() != parent_container:
		if card_visual.get_parent():
			card_visual.get_parent().remove_child(card_visual)
		parent_container.add_child(card_visual)

	active_cards[card] = card_visual

	# Update usage statistics
	peak_usage = max(peak_usage, active_cards.size())

	return card_visual

func return_card_visual(card: Card) -> void:
	"""
	Return a CardVisual to the pool for reuse.

	Args:
		card: The Card whose visual should be returned to the pool
	"""
	if not card or not card in active_cards:
		return

	var card_visual = active_cards[card]
	active_cards.erase(card)

	# Clean up the card visual for reuse
	_reset_card_visual(card_visual)

	# Remove from parent but keep the node alive
	if card_visual.get_parent():
		card_visual.get_parent().remove_child(card_visual)

	# Return to available pool if we have space
	if available_cards.size() < max_pool_size:
		available_cards.append(card_visual)
		card_visual_recycled.emit(card_visual)
	else:
		# Pool is full, dispose of the card visual
		card_visual.queue_free()
		total_created -= 1

	# Trigger cleanup if we have too many unused cards
	if available_cards.size() > auto_cleanup_threshold:
		_cleanup_excess_cards()

func get_card_visual_for_card(card: Card) -> CardVisual:
	"""
	Get the currently active CardVisual for a specific card.

	Args:
		card: The Card to find the visual for

	Returns:
		The CardVisual instance, or null if not found
	"""
	return active_cards.get(card, null)

func is_card_active(card: Card) -> bool:
	"""
	Check if a card currently has an active visual.

	Args:
		card: The Card to check

	Returns:
		True if the card has an active CardVisual
	"""
	return card in active_cards

func clear_all_active_cards() -> void:
	"""
	Return all active card visuals to the pool.
	"""
	var cards_to_return = active_cards.keys()
	for card in cards_to_return:
		return_card_visual(card)

func preload_cards(cards: Array[Card]) -> void:
	"""
	Preload CardVisuals for an array of cards to improve performance.

	Args:
		cards: Array of cards to preload visuals for
	"""
	# Ensure we have enough cards in the pool
	var needed_cards = cards.size()
	var available_count = available_cards.size()

	if available_count < needed_cards:
		var cards_to_create = min(needed_cards - available_count, max_pool_size - total_created)
		if cards_to_create > 0:
			_expand_pool(cards_to_create)

func cleanup_pool() -> void:
	"""
	Clean up unused cards from the pool to free memory.
	"""
	_cleanup_excess_cards()

func force_cleanup() -> void:
	"""
	Force cleanup of all unused cards in the pool.
	"""
	var removed_count = available_cards.size()

	for card_visual in available_cards:
		if is_instance_valid(card_visual):
			card_visual.queue_free()

	available_cards.clear()
	total_created = active_cards.size()

	if removed_count > 0:
		pool_cleaned_up.emit(removed_count)

func _create_card_visual() -> CardVisual:
	"""
	Create a new CardVisual instance.

	Returns:
		A new CardVisual instance
	"""
	var card_visual = CardVisual.new()
	card_visual.visible = false # Start invisible until needed
	total_created += 1

	card_visual_created.emit(card_visual)
	return card_visual

func _reset_card_visual(card_visual: CardVisual) -> void:
	"""
	Reset a CardVisual to clean state for reuse.

	Args:
		card_visual: The CardVisual to reset
	"""
	if not card_visual:
		return

	# Reset visual properties
	card_visual.visible = false
	card_visual.modulate = Color.WHITE
	card_visual.position = Vector2.ZERO
	card_visual.rotation_degrees = 0.0
	card_visual.scale = Vector2.ONE

	# Reset card data
	card_visual.card = null

	# Reset visual state
	card_visual.set_visual_state(CardVisual.VisualState.DEFAULT)
	card_visual.flipped = true # Back to default back-showing state
	card_visual.is_animating = false

	# Stop any active animations
	if card_visual.animation_player and card_visual.animation_player.is_playing():
		card_visual.animation_player.stop()

	# Disconnect any temporary signal connections
	# (In a full implementation, we'd track and clean these up)

func _expand_pool(count: int) -> void:
	"""
	Expand the pool by creating additional CardVisual instances.

	Args:
		count: Number of new CardVisuals to create
	"""
	var actual_count = min(count, max_pool_size - total_created)

	for i in range(actual_count):
		var card_visual = _create_card_visual()
		available_cards.append(card_visual)

	if actual_count > 0:
		pool_expanded.emit(available_cards.size())

func _cleanup_excess_cards() -> void:
	"""
	Clean up excess unused cards from the pool.
	"""
	var target_size = initial_pool_size * 2 # Keep reasonable buffer
	var excess_count = available_cards.size() - target_size

	if excess_count <= 0:
		return

	# Remove excess cards from the end of the array
	var removed_count = 0
	for i in range(excess_count):
		if available_cards.is_empty():
			break

		var card_visual = available_cards.pop_back()
		if is_instance_valid(card_visual):
			card_visual.queue_free()
			removed_count += 1
			total_created -= 1

	if removed_count > 0:
		pool_cleaned_up.emit(removed_count)

func get_pool_statistics() -> Dictionary:
	"""
	Get comprehensive pool statistics for monitoring and debugging.

	Returns:
		Dictionary containing pool metrics
	"""
	return {
		"initial_pool_size": initial_pool_size,
		"max_pool_size": max_pool_size,
		"growth_increment": growth_increment,
		"auto_cleanup_threshold": auto_cleanup_threshold,
		"total_created": total_created,
		"available_count": available_cards.size(),
		"active_count": active_cards.size(),
		"peak_usage": peak_usage,
		"pool_utilization": float(active_cards.size()) / float(max_pool_size) * 100.0,
		"memory_efficiency": float(active_cards.size()) / float(total_created) * 100.0 if total_created > 0 else 0.0
	}

func validate_pool_state() -> bool:
	"""
	Validate the current pool state for consistency.

	Returns:
		True if the pool state is valid
	"""
	# Check that total created matches tracked instances
	var tracked_total = available_cards.size() + active_cards.size()
	if tracked_total > total_created:
		push_error("Pool tracking inconsistent: tracked=%d > total_created=%d" % [tracked_total, total_created])
		return false

	# Check for null instances in available pool
	for card_visual in available_cards:
		if not is_instance_valid(card_visual):
			push_error("Invalid CardVisual found in available pool")
			return false

	# Check for null instances in active pool
	for card in active_cards:
		var card_visual = active_cards[card]
		if not is_instance_valid(card_visual):
			push_error("Invalid CardVisual found in active pool")
			return false

	# Check that active cards have proper parent
	if parent_container:
		for card_visual in active_cards.values():
			if card_visual.get_parent() != parent_container:
				push_warning("Active CardVisual has wrong parent: %s" % card_visual)

	return true

func _to_string() -> String:
	"""
	Convert card pool to string representation for debugging.

	Returns:
		String representation of the pool state
	"""
	return "[CardPool: %d active, %d available, %d total created]" % [
		active_cards.size(),
		available_cards.size(),
		total_created
	]
