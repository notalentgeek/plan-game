# tests/unit/classes/test_hand_display.gd
extends TestCase

"""
Unit tests for HandDisplay class.

Tests core functionality including card addition, removal, counting,
and bounds validation using the Arrange-Act-Assert pattern.
Includes comprehensive edge case coverage and integration testing.
"""

# Test fixture factory methods

func _create_test_problem_card(id_suffix: String = "default") -> ProblemCard:
	"""
	Create test ProblemCard with consistent properties.

	Args:
		id_suffix: Unique identifier suffix for card ID

	Returns:
		ProblemCard with predictable test properties
	"""
	return ProblemCard.new(
		"test_problem_" + id_suffix,
		"Test Problem Card " + id_suffix.capitalize(),
		"Test description for problem card " + id_suffix,
		"", # No texture path for unit testing
		id_suffix.to_upper().substr(0, 1), # First letter as problem code
		5 # Default severity level
	)

func _create_test_solution_card(id_suffix: String = "default", solves: Array[String] = []) -> SolutionCard:
	"""
	Create test SolutionCard with specified solving capability.

	Args:
		id_suffix: Unique identifier suffix for card ID
		solves: Array of problem letter codes this solution addresses

	Returns:
		SolutionCard with specified solving capability
	"""
	if solves.is_empty():
		solves = [id_suffix.to_upper().substr(0, 1)]

	return SolutionCard.new(
		"test_solution_" + id_suffix,
		"Test Solution Card " + id_suffix.capitalize(),
		"Test description for solution card " + id_suffix,
		"", # No texture path for unit testing
		solves,
		false # Not ultimate card
	)

func _create_fresh_hand_display() -> HandDisplay:
	"""
	Create clean HandDisplay instance with validated initial state.

	Returns:
		HandDisplay with guaranteed clean state
	"""
	var hand_display = HandDisplay.new()

	# Defensive validation of initial state
	assert_not_null(hand_display.cards, "Cards array must be initialized")
	assert_equal(hand_display.cards.size(), 0, "Cards array must start empty")

	return hand_display

# Test instantiation and basic structure

func test_hand_display_instantiation_creates_valid_instance() -> void:
	"""
	Validate HandDisplay instantiation with correct inheritance hierarchy.

	Verifies instance creation, type inheritance, and initial state configuration.
	"""
	# Arrange & Act
	var hand_display = _create_fresh_hand_display()

	# Assert - Type verification
	assert_not_null(hand_display, "HandDisplay instance must be created successfully")
	assert_true(hand_display is HandDisplay, "Instance must be HandDisplay type")
	assert_true(hand_display is Control, "HandDisplay must inherit from Control")

	# Assert - Initial state verification
	assert_not_null(hand_display.card_visuals, "Card visuals array must be initialized")
	assert_equal(hand_display.card_visuals.size(), 0, "Card visuals array must start empty")

	# Cleanup
	hand_display.queue_free()

# Test method signatures and interfaces

func test_add_card_method_signature_and_default_behavior() -> void:
	"""
	Validate add_card method signature and default behavior.

	Tests method existence, parameter acceptance, return type, and null handling.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()

	# Act & Assert - Method existence
	assert_true(
		hand_display.has_method("add_card"),
		"HandDisplay must expose add_card method"
	)

	# Act & Assert - Method behavior with null input
	var null_result = hand_display.add_card(null)
	assert_true(null_result is bool, "add_card must return boolean type")
	assert_equal(null_result, false, "add_card must reject null input")

	# Cleanup
	hand_display.queue_free()

func test_remove_card_method_signature_and_bounds_handling() -> void:
	"""
	Validate remove_card method signature and bounds checking.

	Tests method existence, return type consistency, and bounds validation.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()

	# Act & Assert - Method existence
	assert_true(
		hand_display.has_method("remove_card"),
		"HandDisplay must expose remove_card method"
	)

	# Act & Assert - Return type consistency
	var zero_result = hand_display.remove_card(0)
	var negative_result = hand_display.remove_card(-1)
	var large_result = hand_display.remove_card(999)

	assert_true(zero_result is bool, "remove_card must return boolean for index 0")
	assert_true(negative_result is bool, "remove_card must return boolean for negative index")
	assert_true(large_result is bool, "remove_card must return boolean for large index")

	# Act & Assert - Bounds checking behavior
	assert_equal(zero_result, false, "remove_card must reject index 0 on empty hand")
	assert_equal(negative_result, false, "remove_card must reject negative indices")
	assert_equal(large_result, false, "remove_card must reject out-of-bounds indices")

	# Cleanup
	hand_display.queue_free()

func test_get_card_count_method_signature_and_initial_state() -> void:
	"""
	Validate get_card_count method signature and initial state reporting.

	Tests method existence, return type, and initial state accuracy.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()

	# Act
	var result = hand_display.get_card_count()

	# Assert - Return type and initial value
	assert_true(typeof(result) == TYPE_INT, "get_card_count must return TYPE_INT")
	assert_equal(result, 0, "get_card_count must return 0 for empty hand")

	# Cleanup
	hand_display.queue_free()

# Test card addition functionality

func test_add_card_null_input_validation() -> void:
	"""
	Validate add_card rejects null input while preserving state.

	Tests null input handling, state preservation, and return value accuracy.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()
	var initial_count = hand_display.cards.size()

	# Act
	var result = hand_display.add_card(null)

	# Assert - Rejection behavior
	assert_equal(result, false, "add_card must return false for null input")
	assert_equal(
		hand_display.cards.size(),
		initial_count,
		"Cards array must remain unchanged after null rejection"
	)

	# Cleanup
	hand_display.queue_free()

func test_add_card_duplicate_prevention() -> void:
	"""
	Validate add_card prevents duplicate card additions.

	Tests successful first addition, duplicate detection, and state integrity.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()
	var test_card = _create_test_problem_card("duplicate_test")

	# Act - First addition (should succeed)
	var first_result = hand_display.add_card(test_card)

	# Assert - First addition success
	assert_equal(first_result, true, "First card addition must succeed")
	assert_equal(hand_display.cards.size(), 1, "Hand must contain exactly one card")
	assert_true(test_card in hand_display.cards, "Test card must exist in hand")

	# Act - Second addition attempt (should fail)
	var second_result = hand_display.add_card(test_card)

	# Assert - Duplicate rejection
	assert_equal(second_result, false, "Duplicate addition must be rejected")
	assert_equal(hand_display.cards.size(), 1, "Hand must still contain exactly one card")

	# Cleanup
	hand_display.queue_free()

func test_add_card_successful_addition_workflow() -> void:
	"""
	Validate successful card addition workflow with multiple cards.

	Tests multiple additions, return values, array state, and card ordering.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()
	var card1 = _create_test_problem_card("first")
	var card2 = _create_test_solution_card("second")

	# Act & Assert - Progressive additions
	var result1 = hand_display.add_card(card1)
	assert_equal(result1, true, "First valid addition must return true")
	assert_equal(hand_display.cards.size(), 1, "Hand must contain one card after first addition")

	var result2 = hand_display.add_card(card2)
	assert_equal(result2, true, "Second valid addition must return true")
	assert_equal(hand_display.cards.size(), 2, "Hand must contain two cards after second addition")

	# Assert - Card presence and ordering
	assert_true(card1 in hand_display.cards, "First card must exist in hand")
	assert_true(card2 in hand_display.cards, "Second card must exist in hand")
	assert_equal(hand_display.cards[0], card1, "First card must be at index 0")
	assert_equal(hand_display.cards[1], card2, "Second card must be at index 1")

	# Cleanup
	hand_display.queue_free()

# Test card count functionality

func test_get_card_count_accuracy_with_progressive_additions() -> void:
	"""
	Validate get_card_count accuracy as cards are progressively added.

	Tests empty state reporting, count progression, and integration with add_card.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()
	var cards = [
		_create_test_problem_card("count_1"),
		_create_test_problem_card("count_2"),
		_create_test_solution_card("count_3")
	]

	# Assert - Initial empty state
	assert_equal(hand_display.get_card_count(), 0, "Empty hand must report count of 0")

	# Act & Assert - Progressive count validation
	for i in range(cards.size()):
		hand_display.add_card(cards[i])
		var expected_count = i + 1
		assert_equal(
			hand_display.get_card_count(),
			expected_count,
			"Count must be %d after adding card %d" % [expected_count, i + 1]
		)

	# Assert - Final state consistency
	assert_equal(
		hand_display.get_card_count(),
		hand_display.cards.size(),
		"get_card_count must match actual array size"
	)

	# Cleanup
	hand_display.queue_free()

func test_add_card_and_count_integration() -> void:
	"""
	Integration test for add_card and get_card_count working together.

	Tests cross-method integration, state consistency, and real-world usage patterns.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()
	var integration_cards = [
		_create_test_problem_card("integration_1"),
		_create_test_solution_card("integration_2", ["I"])
	]

	# Act & Assert - Step-by-step integration validation
	assert_equal(hand_display.get_card_count(), 0, "Must start with count 0")

	var add_result1 = hand_display.add_card(integration_cards[0])
	assert_equal(add_result1, true, "First addition must succeed")
	assert_equal(hand_display.get_card_count(), 1, "Count must be 1 after first addition")

	var add_result2 = hand_display.add_card(integration_cards[1])
	assert_equal(add_result2, true, "Second addition must succeed")
	assert_equal(hand_display.get_card_count(), 2, "Count must be 2 after second addition")

	# Assert - Final integration state
	assert_equal(
		hand_display.cards.size(),
		hand_display.get_card_count(),
		"Array size must match count result"
	)

	# Cleanup
	hand_display.queue_free()

# Test card removal functionality

func test_remove_card_bounds_validation_comprehensive() -> void:
	"""
	Comprehensive validation of remove_card bounds checking behavior.

	Tests negative indices, empty hand bounds, populated hand bounds, and boundary conditions.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()

	# Test Case 1: Empty hand bounds checking
	var empty_tests = [
		{"index": - 1, "desc": "negative index on empty hand"},
		{"index": 0, "desc": "index 0 on empty hand"},
		{"index": 5, "desc": "positive index on empty hand"},
		{"index": 999, "desc": "large index on empty hand"}
	]

	for test_case in empty_tests:
		var result = hand_display.remove_card(test_case.index)
		assert_equal(
			result,
			false,
			"Must reject %s" % test_case.desc
		)

	# Test Case 2: Populated hand bounds checking
	var test_card = _create_test_problem_card("bounds_test")
	hand_display.add_card(test_card)

	var populated_tests = [
		{"index": - 1, "desc": "negative index on populated hand"},
		{"index": 1, "desc": "index 1 when only index 0 is valid"},
		{"index": 10, "desc": "large index on populated hand"}
	]

	for test_case in populated_tests:
		var result = hand_display.remove_card(test_case.index)
		assert_equal(
			result,
			false,
			"Must reject %s" % test_case.desc
		)

	# Assert - State preservation after all invalid attempts
	assert_equal(
		hand_display.cards.size(),
		1,
		"Hand must still contain original card after invalid removal attempts"
	)

	# Cleanup
	hand_display.queue_free()

# Test clear hand functionality

func test_clear_hand_method_existence() -> void:
	"""
	Validate clear_hand method exists and is callable.

	Tests method signature and basic callability. Implementation tests will be added when method logic is complete.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()

	# Act & Assert - Method existence
	assert_true(
		hand_display.has_method("clear_hand"),
		"HandDisplay must expose clear_hand method"
	)

	# Act - Method callability (should not crash)
	hand_display.clear_hand()

	# Note: Additional functionality tests will be added when implementation is complete

	# Cleanup
	hand_display.queue_free()

# Test comprehensive integration scenarios

func test_complete_hand_management_workflow() -> void:
	"""
	End-to-end integration test covering complete hand management workflow.

	Tests empty hand start, multiple card additions, count tracking, mixed operations, and state consistency.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()
	var workflow_cards = [
		_create_test_problem_card("workflow_1"),
		_create_test_solution_card("workflow_2"),
		_create_test_problem_card("workflow_3")
	]

	# Phase 1: Initial state validation
	assert_equal(hand_display.get_card_count(), 0, "Workflow must start with empty hand")

	# Phase 2: Progressive card addition with validation
	for i in range(workflow_cards.size()):
		# Add card
		var add_result = hand_display.add_card(workflow_cards[i])
		assert_equal(add_result, true, "Card %d addition must succeed" % (i + 1))

		# Validate count progression
		var expected_count = i + 1
		assert_equal(
			hand_display.get_card_count(),
			expected_count,
			"Count must be %d after adding card %d" % [expected_count, i + 1]
		)

		# Validate card presence
		assert_true(
			workflow_cards[i] in hand_display.cards,
			"Card %d must exist in hand" % (i + 1)
		)

	# Phase 3: Invalid operation validation (should not affect state)
	var initial_final_count = hand_display.get_card_count()

	# Test invalid additions
	var null_add = hand_display.add_card(null)
	var duplicate_add = hand_display.add_card(workflow_cards[0])

	assert_equal(null_add, false, "Null addition must be rejected")
	assert_equal(duplicate_add, false, "Duplicate addition must be rejected")
	assert_equal(
		hand_display.get_card_count(),
		initial_final_count,
		"Invalid operations must not change hand count"
	)

	# Test invalid removals
	var invalid_removal = hand_display.remove_card(-1)
	var out_of_bounds_removal = hand_display.remove_card(999)

	assert_equal(invalid_removal, false, "Invalid index removal must be rejected")
	assert_equal(out_of_bounds_removal, false, "Out-of-bounds removal must be rejected")
	assert_equal(
		hand_display.get_card_count(),
		initial_final_count,
		"Invalid removals must not change hand count"
	)

	# Phase 4: Final state validation
	assert_equal(
		hand_display.cards.size(),
		workflow_cards.size(),
		"Final hand size must match expected card count"
	)

	for card in workflow_cards:
		assert_true(
			card in hand_display.cards,
			"All workflow cards must remain in hand"
		)

	# Cleanup
	hand_display.queue_free()

func test_remove_card_invalid_index() -> void:
	"""
	Test that remove_card rejects invalid indices and preserves array state.

	Validates negative indices, out-of-bounds indices, and state preservation.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()

	# Test negative index rejection on empty hand
	var negative_result = hand_display.remove_card(-1)
	assert_equal(negative_result, false, "Must reject negative index")
	assert_equal(hand_display.cards.size(), 0, "Array must remain unchanged after negative index")

	# Test out-of-bounds index rejection on empty hand
	var out_of_bounds_result = hand_display.remove_card(0)
	assert_equal(out_of_bounds_result, false, "Must reject index 0 on empty hand")
	assert_equal(hand_display.cards.size(), 0, "Array must remain unchanged after out-of-bounds index")

	# Add a test card to verify populated hand bounds checking
	var test_card = _create_test_problem_card("invalid_index_test")
	hand_display.add_card(test_card)
	var initial_size = hand_display.cards.size()

	# Test out-of-bounds index rejection on populated hand
	var populated_bounds_result = hand_display.remove_card(1)
	assert_equal(populated_bounds_result, false, "Must reject index 1 when only index 0 is valid")
	assert_equal(hand_display.cards.size(), initial_size, "Array must remain unchanged after invalid bounds")
	assert_true(test_card in hand_display.cards, "Test card must still exist after invalid removal")

	# Cleanup
	hand_display.queue_free()

func test_remove_card_updates_count() -> void:
	"""
	Test that removing cards decreases count correctly.

	Validates integration between remove_card and get_card_count methods.
	"""
	# Arrange - Create hand display and multiple test cards
	var hand_display = _create_fresh_hand_display()
	var test_cards = [
		_create_test_problem_card("count_test_1"),
		_create_test_problem_card("count_test_2"),
		_create_test_solution_card("count_test_3")
	]

	# Add multiple cards to establish initial state
	for card in test_cards:
		hand_display.add_card(card)

	var initial_count = hand_display.get_card_count()
	assert_equal(initial_count, 3, "Should start with 3 cards")

	# Act - Remove one card from the middle (index 1)
	var removal_result = hand_display.remove_card(1)

	# Assert - Verify removal was successful
	assert_equal(removal_result, true, "Removal should return true for valid index")

	# Assert - Verify count decreased by exactly one
	var final_count = hand_display.get_card_count()
	assert_equal(final_count, 2, "Count should be 2 after removing one card")
	assert_equal(final_count, initial_count - 1, "Count should decrease by exactly 1")

	# Assert - Verify array size matches count
	assert_equal(hand_display.cards.size(), final_count, "Array size should match count result")

	# Assert - Verify specific card was removed (card at index 1)
	var remaining_cards = hand_display.cards
	assert_true(test_cards[0] in remaining_cards, "First card should still exist")
	assert_equal(remaining_cards[0], test_cards[0], "First card should be at index 0")
	assert_true(test_cards[2] in remaining_cards, "Third card should still exist")
	assert_equal(remaining_cards[1], test_cards[2], "Third card should now be at index 1")

	# Assert - Verify removed card is no longer present
	assert_equal(test_cards[1] in remaining_cards, false, "Removed card should no longer exist in hand")

	# Additional validation - Test removing another card
	var second_removal = hand_display.remove_card(0)
	assert_equal(second_removal, true, "Second removal should succeed")
	assert_equal(hand_display.get_card_count(), 1, "Count should be 1 after second removal")

	# Final validation - Test removing last card
	var final_removal = hand_display.remove_card(0)
	assert_equal(final_removal, true, "Final removal should succeed")
	assert_equal(hand_display.get_card_count(), 0, "Count should be 0 after removing all cards")
	assert_true(hand_display.cards.is_empty(), "Cards array should be empty")

	# Cleanup
	hand_display.queue_free()

func test_remove_card_success() -> void:
	"""
	Test successful card removal from hand array.

	Validates that remove_card() successfully removes a card from the array
	and that the removed card is no longer present in the collection.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()
	var test_card = _create_test_problem_card("success_removal")

	# Add card to establish initial state
	var add_result = hand_display.add_card(test_card)
	assert_equal(add_result, true, "Card addition must succeed for test setup")
	assert_equal(hand_display.cards.size(), 1, "Hand must contain exactly one card")
	assert_true(test_card in hand_display.cards, "Test card must exist in hand initially")

	# Act - Remove the card by index
	var removal_result = hand_display.remove_card(0)

	# Assert - Verify successful removal
	assert_equal(removal_result, true, "remove_card must return true for valid index")

	# Assert - Verify card no longer in array
	assert_equal(test_card in hand_display.cards, false, "Removed card must no longer exist in hand")

	# Assert - Verify array state after removal
	assert_equal(hand_display.cards.size(), 0, "Hand must be empty after removing only card")
	assert_true(hand_display.cards.is_empty(), "Cards array must be empty after successful removal")

	# Cleanup
	hand_display.queue_free()

func test_remove_card_from_empty_hand() -> void:
	"""
	Test that removing from empty hand is handled safely.

	Validates that remove_card() gracefully handles empty hand scenarios
	without errors and returns false appropriately.
	"""
	# Arrange - Start with empty hand
	var hand_display = _create_fresh_hand_display()

	# Verify initial empty state
	assert_equal(hand_display.cards.size(), 0, "Hand must start empty for test")
	assert_equal(hand_display.get_card_count(), 0, "Card count must be 0 for empty hand")
	assert_true(hand_display.cards.is_empty(), "Cards array must be empty initially")

	# Act - Attempt to remove card from empty hand
	var removal_result = hand_display.remove_card(0)

	# Assert - Verify safe failure
	assert_equal(removal_result, false, "Empty hand removal must return false")

	# Assert - Verify no errors or state corruption
	assert_equal(hand_display.cards.size(), 0, "Hand must remain empty after failed removal")
	assert_equal(hand_display.get_card_count(), 0, "Card count must remain 0 after failed removal")
	assert_true(hand_display.cards.is_empty(), "Cards array must remain empty after failed removal")

	# Additional edge case validation - test multiple indices
	var negative_removal = hand_display.remove_card(-1)
	var large_removal = hand_display.remove_card(999)

	assert_equal(negative_removal, false, "Negative index on empty hand must return false")
	assert_equal(large_removal, false, "Large index on empty hand must return false")

	# Final state verification - ensure no corruption occurred
	assert_equal(hand_display.cards.size(), 0, "Hand must still be empty after all removal attempts")

	# Cleanup
	hand_display.queue_free()

func test_remove_card_last_remaining() -> void:
	"""
	Test that removing the last remaining card works correctly.

	Validates that remove_card() properly handles the edge case of removing
	the final card from a hand, leaving it in a clean empty state.
	"""
	# Arrange - Add single card to hand
	var hand_display = _create_fresh_hand_display()
	var test_card = _create_test_problem_card("last_remaining")

	# Establish initial single-card state
	var add_result = hand_display.add_card(test_card)
	assert_equal(add_result, true, "Card addition must succeed for test setup")
	assert_equal(hand_display.cards.size(), 1, "Hand must contain exactly one card initially")
	assert_equal(hand_display.get_card_count(), 1, "Card count must be 1 initially")
	assert_true(test_card in hand_display.cards, "Test card must exist in hand initially")

	# Act - Remove the only card
	var removal_result = hand_display.remove_card(0)

	# Assert - Verify successful removal
	assert_equal(removal_result, true, "Last card removal must return true")

	# Assert - Verify hand becomes properly empty
	assert_equal(hand_display.cards.size(), 0, "Hand must be empty after removing last card")
	assert_equal(hand_display.get_card_count(), 0, "Card count must be 0 after removing last card")
	assert_true(hand_display.cards.is_empty(), "Cards array must be empty after removing last card")

	# Assert - Verify removed card is no longer present
	assert_equal(test_card in hand_display.cards, false, "Removed card must no longer exist in hand")

	# Edge case validation - verify empty hand behavior after last card removal
	var subsequent_removal = hand_display.remove_card(0)
	assert_equal(subsequent_removal, false, "Removal from now-empty hand must return false")
	assert_equal(hand_display.cards.size(), 0, "Hand must remain empty after failed subsequent removal")

	# Final state verification - confirm clean empty state
	assert_equal(hand_display.get_card_count(), 0, "Final card count must be 0")
	assert_true(hand_display.cards.is_empty(), "Final cards array must be empty")

	# Cleanup
	hand_display.queue_free()

func test_clear_hand_empties_array() -> void:
	"""
	Test that clear_hand empties the cards array.

	Validates that clear_hand() properly removes all cards from the array,
	leaving it in a clean empty state.
	"""
	# Arrange - Add multiple cards to hand
	var hand_display = _create_fresh_hand_display()
	var test_cards = [
		_create_test_problem_card("clear_test_1"),
		_create_test_solution_card("clear_test_2"),
		_create_test_problem_card("clear_test_3")
	]

	# Add all test cards to establish populated state
	for card in test_cards:
		var add_result = hand_display.add_card(card)
		assert_equal(add_result, true, "Card addition must succeed for test setup")

	# Verify initial populated state
	assert_equal(hand_display.cards.size(), 3, "Hand must contain 3 cards before clearing")
	assert_equal(hand_display.get_card_count(), 3, "Card count must be 3 before clearing")

	# Verify all cards are present
	for card in test_cards:
		assert_true(card in hand_display.cards, "All test cards must exist in hand before clearing")

	# Act - Call clear_hand
	hand_display.clear_hand()

	# Assert - Verify array becomes empty after clear
	assert_equal(hand_display.cards.size(), 0, "Cards array must be empty after clear_hand")
	assert_true(hand_display.cards.is_empty(), "Cards array must report empty after clear_hand")

	# Assert - Verify all cards are removed
	for card in test_cards:
		assert_equal(card in hand_display.cards, false, "No test cards must exist in hand after clearing")

	# Assert - Verify count integration
	assert_equal(hand_display.get_card_count(), 0, "Card count must be 0 after clearing")

	# Additional validation - verify array is ready for new additions
	var new_card = _create_test_problem_card("post_clear")
	var add_after_clear = hand_display.add_card(new_card)
	assert_equal(add_after_clear, true, "Array must accept new cards after clearing")
	assert_equal(hand_display.cards.size(), 1, "Array must contain new card after post-clear addition")

	# Cleanup
	hand_display.queue_free()

func test_clear_hand_resets_count() -> void:
	"""
	Test that clear_hand resets card count to 0.

	Validates that clear_hand() properly resets the card count to zero,
	ensuring integration between clear_hand and get_card_count methods.
	"""
	# Arrange - Add multiple cards to hand
	var hand_display = _create_fresh_hand_display()
	var test_cards = [
		_create_test_problem_card("count_reset_1"),
		_create_test_solution_card("count_reset_2", ["C"]),
		_create_test_problem_card("count_reset_3"),
		_create_test_solution_card("count_reset_4", ["D"])
	]

	# Add all test cards to establish populated state
	for card in test_cards:
		var add_result = hand_display.add_card(card)
		assert_equal(add_result, true, "Card addition must succeed for test setup")

	# Verify initial populated count
	var initial_count = hand_display.get_card_count()
	assert_equal(initial_count, 4, "Hand must contain 4 cards before clearing")
	assert_equal(hand_display.cards.size(), initial_count, "Array size must match count before clearing")

	# Act - Call clear_hand
	hand_display.clear_hand()

	# Assert - Verify card count becomes 0 after clear
	var final_count = hand_display.get_card_count()
	assert_equal(final_count, 0, "Card count must be 0 after clear_hand")

	# Assert - Verify integration between clear and count works
	assert_equal(hand_display.cards.size(), final_count, "Array size must match count after clearing")
	assert_equal(hand_display.cards.size(), 0, "Array size must be 0 after clearing")

	# Additional validation - verify count progression from populated to empty
	assert_equal(final_count, initial_count - 4, "Count must decrease by exactly 4 (from 4 to 0)")
	assert_not_equal(final_count, initial_count, "Final count must be different from initial count")

	# Edge case validation - verify count remains 0 after multiple clear calls
	hand_display.clear_hand()
	var second_clear_count = hand_display.get_card_count()
	assert_equal(second_clear_count, 0, "Count must remain 0 after second clear_hand call")

	# Integration validation - verify count works correctly after clearing
	var post_clear_card = _create_test_problem_card("post_clear_count")
	hand_display.add_card(post_clear_card)
	var post_add_count = hand_display.get_card_count()
	assert_equal(post_add_count, 1, "Count must be 1 after adding card to cleared hand")

	# Cleanup
	hand_display.queue_free()

func test_calculate_fan_positions_method_existence_and_accessibility() -> void:
	"""
	Validate _calculate_fan_positions method exists and is accessible.

	Tests method existence, callable interface, and return type consistency
	following the established testing patterns for private calculation methods.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()

	# Act & Assert - Method existence verification
	assert_true(
		hand_display.has_method("_calculate_fan_positions"),
		"HandDisplay must expose _calculate_fan_positions method"
	)

	# Act & Assert - Method accessibility and return type
	var result = hand_display._calculate_fan_positions()
	assert_not_null(result, "_calculate_fan_positions must return non-null value")
	assert_true(result is Array, "_calculate_fan_positions must return Array type")

	# Act & Assert - Default behavior validation
	assert_equal(result.size(), 0, "_calculate_fan_positions must return empty array by default")
	assert_true(result.is_empty(), "Default return array must be empty")

	# Cleanup
	hand_display.queue_free()

func test_calculate_fan_positions_returns_array_type() -> void:
	"""
	Validate _calculate_fan_positions returns proper Array type.

	Tests return type validation, type safety compliance, and interface consistency
	following the established testing patterns for method return type verification.
	"""
	# Arrange
	var hand_display = _create_fresh_hand_display()

	# Act - Call the method to get return value
	var result = hand_display._calculate_fan_positions()

	# Assert - Return type validation
	assert_not_null(result, "_calculate_fan_positions must return non-null value")
	assert_true(result is Array, "_calculate_fan_positions must return Array type")

	# Assert - Type safety confirmation
	assert_true(typeof(result) == TYPE_ARRAY, "_calculate_fan_positions must return TYPE_ARRAY")

	# Assert - Interface consistency validation
	var second_call = hand_display._calculate_fan_positions()
	assert_true(second_call is Array, "Multiple calls must consistently return Array type")
	assert_true(typeof(second_call) == TYPE_ARRAY, "Type consistency must be maintained across calls")

	# Cleanup
	hand_display.queue_free()

func test_fan_positions_empty_hand() -> void:
	"""
	Validate _calculate_fan_positions returns empty array for empty hand.

	Tests empty hand edge case handling, ensuring method returns empty position
	array when no cards are present in the hand display.
	"""
	# Arrange - Start with empty hand
	var hand_display = _create_fresh_hand_display()

	# Verify initial empty state
	assert_equal(hand_display.cards.size(), 0, "Hand must start empty for test")
	assert_true(hand_display.cards.is_empty(), "Cards array must be empty initially")
	assert_equal(hand_display.get_card_count(), 0, "Card count must be 0 for empty hand")

	# Act - Call _calculate_fan_positions on empty hand
	var result = hand_display._calculate_fan_positions()

	# Assert - Verify empty array returned
	assert_not_null(result, "_calculate_fan_positions must return non-null value")
	assert_true(result is Array, "_calculate_fan_positions must return Array type")
	assert_equal(result.size(), 0, "Empty hand must return empty position array")
	assert_true(result.is_empty(), "Position array must be empty for empty hand")

	# Assert - Verify return type consistency
	assert_true(typeof(result) == TYPE_ARRAY, "Return type must be TYPE_ARRAY")

	# Cleanup
	hand_display.queue_free()

func test_fan_positions_single_card() -> void:
	"""
	Validate _calculate_fan_positions returns center position for single card.

	Tests single card positioning logic, ensuring method returns exactly one
	position at center coordinates when hand contains one card.
	"""
	# Arrange - Add single card to hand
	var hand_display = _create_fresh_hand_display()
	var test_card = _create_test_problem_card("single_position")

	# Add card and verify single card state
	var add_result = hand_display.add_card(test_card)
	assert_equal(add_result, true, "Card addition must succeed for test setup")
	assert_equal(hand_display.cards.size(), 1, "Hand must contain exactly one card")
	assert_equal(hand_display.get_card_count(), 1, "Card count must be 1 for single card")
	assert_true(test_card in hand_display.cards, "Test card must exist in hand")

	# Act - Call _calculate_fan_positions on single card hand
	var result = hand_display._calculate_fan_positions()

	# Assert - Verify single position returned
	assert_not_null(result, "_calculate_fan_positions must return non-null value")
	assert_true(result is Array, "_calculate_fan_positions must return Array type")
	assert_equal(result.size(), 1, "Single card must return exactly one position")
	assert_equal(result.is_empty(), false, "Position array must not be empty for single card")

	# Assert - Verify center position coordinates
	var position = result[0]
	assert_not_null(position, "Position must not be null")
	assert_true(position is Vector2, "Position must be Vector2 type")
	assert_equal(position.x, 400, "Single card X position must be 400 (center)")
	assert_equal(position.y, 300, "Single card Y position must be 300 (center)")

	# Assert - Verify position is reasonable
	assert_true(position.x > 0, "X position must be positive")
	assert_true(position.y > 0, "Y position must be positive")
	assert_true(position.x < 1000, "X position must be reasonable for display")
	assert_true(position.y < 800, "Y position must be reasonable for display")

	# Assert - Verify type consistency
	assert_true(typeof(result) == TYPE_ARRAY, "Return type must be TYPE_ARRAY")
	assert_true(typeof(position) == TYPE_VECTOR2, "Position type must be TYPE_VECTOR2")

	# Cleanup
	hand_display.queue_free()

func test_fan_positions_multiple_cards() -> void:
	"""
	Test that multiple cards return correct number of positions.
	Verifies that position count matches card count for multiple cards.
	"""
	# Arrange - Create fresh hand display instance
	var hand_display = _create_fresh_hand_display()

	# Add multiple cards to hand (3 cards for testing)
	var card1 = ProblemCard.new("test_1", "Test Card 1", "Description 1", "", "A", 1)
	var card2 = ProblemCard.new("test_2", "Test Card 2", "Description 2", "", "B", 2)
	var card3 = ProblemCard.new("test_3", "Test Card 3", "Description 3", "", "C", 3)

	hand_display.add_card(card1)
	hand_display.add_card(card2)
	hand_display.add_card(card3)

	# Call _calculate_fan_positions to get position array
	var positions = hand_display._calculate_fan_positions()

	# Verify array size matches card count
	assert_equal(positions.size(), 3, "Position count should match card count (3)")
	assert_equal(positions.size(), hand_display.get_card_count(), "Position count should match hand card count")

	# Verify all positions are Vector2 instances
	for i in range(positions.size()):
		assert_true(positions[i] is Vector2, "Position " + str(i) + " should be Vector2")

	# Verify positions are unique (no duplicate positions)
	assert_true(positions[0] != positions[1], "Card 0 and 1 should have different positions")
	assert_true(positions[1] != positions[2], "Card 1 and 2 should have different positions")
	assert_true(positions[0] != positions[2], "Card 0 and 2 should have different positions")

	# Cleanup
	hand_display.queue_free()

func test_fan_positions_different_for_each_card() -> void:
	"""
	Create test to verify each card gets unique position.
	Validates that positioning algorithm assigns different positions to each card.
	"""
	# Arrange - Create fresh hand display instance
	var hand_display = _create_fresh_hand_display()

	# Add multiple cards to hand (4 cards for comprehensive testing)
	var card1 = _create_test_problem_card("unique_pos_1")
	var card2 = _create_test_problem_card("unique_pos_2")
	var card3 = _create_test_solution_card("unique_pos_3")
	var card4 = _create_test_solution_card("unique_pos_4")

	hand_display.add_card(card1)
	hand_display.add_card(card2)
	hand_display.add_card(card3)
	hand_display.add_card(card4)

	# Act - Get position array from positioning algorithm
	var positions = hand_display._calculate_fan_positions()

	# Assert - Verify all positions are different (comprehensive uniqueness check)
	for i in range(positions.size()):
		for j in range(i + 1, positions.size()):
			var pos_i = positions[i]
			var pos_j = positions[j]
			assert_true(
				pos_i != pos_j,
				"Position %d (%s) must be different from position %d (%s)" % [i, str(pos_i), j, str(pos_j)]
			)

			# Additional validation - verify no coordinate overlap
			var x_different = pos_i.x != pos_j.x
			var y_different = pos_i.y != pos_j.y
			assert_true(
				x_different or y_different,
				"Cards %d and %d must not have identical coordinates" % [i, j]
			)

	# Assert - Verify positioning algorithm works (basic positioning validation)
	assert_equal(positions.size(), 4, "Must have exactly 4 positions for 4 cards")

	# Verify all positions are valid Vector2 instances
	for i in range(positions.size()):
		assert_true(positions[i] is Vector2, "Position %d must be Vector2 type" % i)
		assert_true(typeof(positions[i]) == TYPE_VECTOR2, "Position %d must be TYPE_VECTOR2" % i)

	# Verify positions are reasonable (within expected display bounds)
	for i in range(positions.size()):
		var pos = positions[i]
		assert_true(pos.x >= 0, "Position %d X coordinate must be non-negative" % i)
		assert_true(pos.y >= 0, "Position %d Y coordinate must be non-negative" % i)
		assert_true(pos.x <= 1000, "Position %d X coordinate must be within display bounds" % i)
		assert_true(pos.y <= 800, "Position %d Y coordinate must be within display bounds" % i)

	# Cleanup
	hand_display.queue_free()
