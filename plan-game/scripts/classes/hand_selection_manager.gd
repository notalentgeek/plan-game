# scripts/classes/hand_selection_manager.gd
class_name HandSelectionManager
extends RefCounted

"""
Manages card selection state and behavior within a hand display.
Handles selection limits, validation, and state consistency.
"""

# Selection mode enumeration
enum SelectionMode {
	SINGLE,      # Only one card can be selected at a time
	MULTIPLE,    # Multiple cards can be selected up to max_selections
	TOGGLE       # Cards can be toggled individually without deselecting others
}

# Selection state for individual cards
class CardSelectionState:
	var card_visual: CardVisual
	var card: Card
	var is_selected: bool = false
	var selection_timestamp: float = 0.0
	var selection_order: int = -1

	func _init(p_card_visual: CardVisual, p_card: Card):
		card_visual = p_card_visual
		card = p_card

# Configuration properties
@export var selection_mode: SelectionMode = SelectionMode.SINGLE
@export var max_selections: int = 1
@export var allow_deselection: bool = true
@export var maintain_selection_order: bool = true

# Selection state
var card_states: Dictionary = {}  # CardVisual -> CardSelectionState
var selected_cards: Array[CardVisual] = []
var selection_counter: int = 0

# Signals for selection events
signal card_selected(card_visual: CardVisual, card: Card)
signal card_deselected(card_visual: CardVisual, card: Card)
signal selection_changed(selected_cards: Array[CardVisual])
signal selection_limit_reached(max_selections: int)
signal selection_cleared()

func _init(
	p_selection_mode: SelectionMode = SelectionMode.SINGLE,
	p_max_selections: int = 1,
	p_allow_deselection: bool = true
) -> void:
	"""
	Initialize the selection manager with specified parameters.

	Args:
		p_selection_mode: How selection should behave
		p_max_selections: Maximum number of cards that can be selected
		p_allow_deselection: Whether selected cards can be deselected
	"""
	selection_mode = p_selection_mode
	max_selections = max(1, p_max_selections)
	allow_deselection = p_allow_deselection

func register_card(card_visual: CardVisual, card: Card) -> void:
	"""
	Register a card for selection management.

	Args:
		card_visual: The CardVisual instance
		card: The associated Card data
	"""
	if not card_visual or not card:
		push_error("Cannot register null CardVisual or Card")
		return

	if card_visual in card_states:
		push_warning("CardVisual already registered for selection: %s" % card_visual)
		return

	var state = CardSelectionState.new(card_visual, card)
	card_states[card_visual] = state

func unregister_card(card_visual: CardVisual) -> void:
	"""
	Unregister a card from selection management.

	Args:
		card_visual: The CardVisual instance to remove
	"""
	if not card_visual:
		return

	# If the card was selected, deselect it first
	if is_card_selected(card_visual):
		deselect_card(card_visual, false)  # Don't emit signals during cleanup

	# Remove from tracking
	if card_visual in card_states:
		card_states.erase(card_visual)

func select_card(card_visual: CardVisual, emit_signals: bool = true) -> bool:
	"""
	Attempt to select a card.

	Args:
		card_visual: The card to select
		emit_signals: Whether to emit selection signals

	Returns:
		True if the card was successfully selected
	"""
	if not card_visual or not card_visual in card_states:
		push_error("CardVisual not registered for selection")
		return false

	var state = card_states[card_visual]

	# Check if already selected
	if state.is_selected:
		if allow_deselection:
			return deselect_card(card_visual, emit_signals)
		return false

	# Check selection limits
	if selected_cards.size() >= max_selections:
		if selection_mode == SelectionMode.SINGLE:
			# Deselect current selection and select new card
			clear_selection(false)
		else:
			# Can't select more cards
			if emit_signals:
				selection_limit_reached.emit(max_selections)
			return false

	# Perform selection
	state.is_selected = true
	state.selection_timestamp = Time.get_time_dict_from_system()["unix"] as float

	if maintain_selection_order:
		state.selection_order = selection_counter
		selection_counter += 1

	selected_cards.append(card_visual)

	# Emit signals
	if emit_signals:
		card_selected.emit(card_visual, state.card)
		selection_changed.emit(selected_cards.duplicate())

	return true

func deselect_card(card_visual: CardVisual, emit_signals: bool = true) -> bool:
	"""
	Deselect a specific card.

	Args:
		card_visual: The card to deselect
		emit_signals: Whether to emit deselection signals

	Returns:
		True if the card was successfully deselected
	"""
	if not card_visual or not card_visual in card_states:
		return false

	var state = card_states[card_visual]

	if not state.is_selected:
		return false

	# Perform deselection
	state.is_selected = false
	state.selection_timestamp = 0.0
	state.selection_order = -1

	# Remove from selected cards array
	var index = selected_cards.find(card_visual)
	if index >= 0:
		selected_cards.remove_at(index)

	# Emit signals
	if emit_signals:
		card_deselected.emit(card_visual, state.card)
		selection_changed.emit(selected_cards.duplicate())

	return true

func toggle_card_selection(card_visual: CardVisual) -> bool:
	"""
	Toggle the selection state of a card.

	Args:
		card_visual: The card to toggle

	Returns:
		True if the card is now selected, false if deselected or failed
	"""
	if not card_visual or not card_visual in card_states:
		return false

	var state = card_states[card_visual]

	if state.is_selected:
		return not deselect_card(card_visual)  # Return true if still selected (deselection failed)
	else:
		return select_card(card_visual)

func clear_selection(emit_signals: bool = true) -> void:
	"""
	Clear all selected cards.

	Args:
		emit_signals: Whether to emit deselection signals
	"""
	var previously_selected = selected_cards.duplicate()

	# Deselect all cards
	for card_visual in previously_selected:
		deselect_card(card_visual, false)  # Don't emit individual signals

	# Emit batch signal
	if emit_signals and not previously_selected.is_empty():
		selection_cleared.emit()
		selection_changed.emit([])

func select_cards(card_visuals: Array[CardVisual], emit_signals: bool = true) -> Array[CardVisual]:
	"""
	Attempt to select multiple cards.

	Args:
		card_visuals: Array of cards to select
		emit_signals: Whether to emit selection signals

	Returns:
		Array of successfully selected cards
	"""
	var successfully_selected: Array[CardVisual] = []

	for card_visual in card_visuals:
		if select_card(card_visual, false):  # Don't emit individual signals
			successfully_selected.append(card_visual)

		# Stop if we've reached the selection limit
		if selected_cards.size() >= max_selections:
			break

	# Emit batch signal
	if emit_signals and not successfully_selected.is_empty():
		selection_changed.emit(selected_cards.duplicate())

	return successfully_selected

func is_card_selected(card_visual: CardVisual) -> bool:
	"""
	Check if a specific card is selected.

	Args:
		card_visual: The card to check

	Returns:
		True if the card is currently selected
	"""
	if not card_visual or not card_visual in card_states:
		return false

	return card_states[card_visual].is_selected

func get_selected_cards() -> Array[CardVisual]:
	"""
	Get all currently selected cards.

	Returns:
		Array of selected CardVisual instances
	"""
	return selected_cards.duplicate()

func get_selected_cards_ordered() -> Array[CardVisual]:
	"""
	Get selected cards in order of selection.

	Returns:
		Array of selected CardVisual instances ordered by selection time
	"""
	if not maintain_selection_order:
		return get_selected_cards()

	var ordered_cards: Array[CardVisual] = []
	var states_with_order: Array[Dictionary] = []

	# Collect states with selection order
	for card_visual in selected_cards:
		if card_visual in card_states:
			var state = card_states[card_visual]
			states_with_order.append({
				"card_visual": card_visual,
				"selection_order": state.selection_order
			})

	# Sort by selection order
	states_with_order.sort_custom(func(a, b): return a.selection_order < b.selection_order)

	# Extract sorted card visuals
	for state_data in states_with_order:
		ordered_cards.append(state_data.card_visual)

	return ordered_cards

func get_selected_card_data() -> Array[Card]:
	"""
	Get the Card data for all selected cards.

	Returns:
		Array of selected Card instances
	"""
	var card_data: Array[Card] = []

	for card_visual in selected_cards:
		if card_visual in card_states:
			card_data.append(card_states[card_visual].card)

	return card_data

func get_selection_count() -> int:
	"""
	Get the number of currently selected cards.

	Returns:
		Number of selected cards
	"""
	return selected_cards.size()

func can_select_more() -> bool:
	"""
	Check if more cards can be selected.

	Returns:
		True if selection limit has not been reached
	"""
	return selected_cards.size() < max_selections

func get_remaining_selections() -> int:
	"""
	Get the number of additional cards that can be selected.

	Returns:
		Number of additional selections allowed
	"""
	return max(0, max_selections - selected_cards.size())

func set_selection_mode(new_mode: SelectionMode, new_max_selections: int = -1) -> void:
	"""
	Change the selection mode and optionally the maximum selections.

	Args:
		new_mode: The new selection mode
		new_max_selections: New maximum selections (-1 to keep current)
	"""
	var previous_mode = selection_mode
	selection_mode = new_mode

	if new_max_selections > 0:
		max_selections = new_max_selections

	# Adjust current selection if it exceeds new limits
	if selected_cards.size() > max_selections:
		# Keep the most recently selected cards
		var cards_to_deselect = selected_cards.slice(0, selected_cards.size() - max_selections)
		for card_visual in cards_to_deselect:
			deselect_card(card_visual, false)

		selection_changed.emit(selected_cards.duplicate())

func validate_selection_state() -> bool:
	"""
	Validate the current selection state for consistency.

	Returns:
		True if the selection state is valid
	"""
	# Check that all selected cards are registered
	for card_visual in selected_cards:
		if not card_visual in card_states:
			push_error("Selected card not registered: %s" % card_visual)
			return false

		if not card_states[card_visual].is_selected:
			push_error("Card in selected list but state shows unselected: %s" % card_visual)
			return false

	# Check that selection count doesn't exceed limit
	if selected_cards.size() > max_selections:
		push_error("Selection count exceeds limit: %d > %d" % [selected_cards.size(), max_selections])
		return false

	# Check for duplicate selections
	var unique_cards = {}
	for card_visual in selected_cards:
		if card_visual in unique_cards:
			push_error("Duplicate card in selection: %s" % card_visual)
			return false
		unique_cards[card_visual] = true

	return true

func get_selection_info() -> Dictionary:
	"""
	Get comprehensive selection information for debugging.

	Returns:
		Dictionary containing selection state and configuration
	"""
	return {
		"selection_mode": SelectionMode.keys()[selection_mode],
		"max_selections": max_selections,
		"allow_deselection": allow_deselection,
		"maintain_selection_order": maintain_selection_order,
		"registered_cards": card_states.size(),
		"selected_count": selected_cards.size(),
		"remaining_selections": get_remaining_selections(),
		"can_select_more": can_select_more(),
		"is_valid": validate_selection_state()
	}

func _to_string() -> String:
	"""
	Convert selection manager to string representation for debugging.

	Returns:
		String representation of the selection state
	"""
	return "[HandSelectionManager: %s, %d/%d selected, %d registered]" % [
		SelectionMode.keys()[selection_mode],
		selected_cards.size(),
		max_selections,
		card_states.size()
	]
