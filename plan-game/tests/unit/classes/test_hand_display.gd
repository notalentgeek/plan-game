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
