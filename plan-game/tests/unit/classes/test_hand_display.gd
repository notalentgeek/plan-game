# tests/unit/classes/test_hand_display.gd
extends TestCase

"""
Unit tests for HandDisplay class.
Tests core functionality of hand management and display.
"""

func test_hand_display_instantiation() -> void:
	"""
	Test that HandDisplay can be instantiated without errors.
	Validates basic class structure and inheritance hierarchy.
	"""
	# Create HandDisplay instance
	var hand_display = HandDisplay.new()

	# Verify instance is created
	assert_not_null(hand_display, "HandDisplay instance should be created")

	# Verify it's the correct type
	assert_true(hand_display is HandDisplay, "Instance should be HandDisplay type")
	assert_true(hand_display is Control, "HandDisplay should inherit from Control")

	# Verify initial properties are set correctly
	assert_not_null(hand_display.cards, "Cards array should be initialized")
	assert_equal(hand_display.cards.size(), 0, "Cards array should start empty")

	assert_not_null(hand_display.card_visuals, "Card visuals array should be initialized")
	assert_equal(hand_display.card_visuals.size(), 0, "Card visuals array should start empty")

	# Clean up
	hand_display.queue_free()

func test_add_card_method_exists() -> void:
	"""
	Test that add_card method exists and is callable.
	Task 2.3.1: Verify add_card method signature and basic behavior.
	"""
	# Create HandDisplay instance
	var hand_display = HandDisplay.new()

	# Verify method exists
	assert_true(
		hand_display.has_method("add_card"),
		"HandDisplay should have add_card method"
	)

	# Verify method is callable by attempting to call it
	# This should not crash and should return false (default stub behavior)
	var result = hand_display.add_card(null)

	# Verify method returns expected type (boolean)
	assert_true(
		result is bool,
		"add_card method should return boolean value"
	)

	# Verify default stub behavior (returns false)
	assert_equal(
		result,
		false,
		"add_card stub should return false by default"
	)

	# Clean up
	hand_display.queue_free()

func test_add_card_returns_bool() -> void:
	"""
	Test that add_card returns boolean value with correct functional behavior.
	Task 2.3.2: Verify add_card return type with various input scenarios.
	"""
	# Create HandDisplay instance
	var hand_display = HandDisplay.new()

	# Create a test card for the method call
	var test_card = ProblemCard.new(
		"test_id",
		"Test Card",
		"Test description",
		"", # No texture path
		"T",
		5
	)

	# Call add_card method
	var result = hand_display.add_card(test_card)

	# Verify return value is boolean type
	assert_true(
		result is bool,
		"add_card should return boolean value"
	)

	# Verify functional behavior returns true for valid addition
	assert_equal(
		result,
		true,
		"add_card should return true for successful addition"
	)

	# Test with null card as well
	var null_result = hand_display.add_card(null)
	assert_true(
		null_result is bool,
		"add_card should return boolean even with null input"
	)
	assert_equal(
		null_result,
		false,
		"add_card should return false for null input"
	)

	# Clean up
	hand_display.queue_free()

func test_remove_card_method_exists() -> void:
	"""
	Test that remove_card method exists and is callable with integer parameter.
	Task 2.3.3: Verify remove_card method signature and parameter handling.
	"""
	# Create HandDisplay instance
	var hand_display = HandDisplay.new()

	# Verify method exists
	assert_true(
		hand_display.has_method("remove_card"),
		"HandDisplay should have remove_card method"
	)

	# Test method is callable with integer parameter
	# This should not crash and should return false (default stub behavior)
	var result = hand_display.remove_card(0)

	# Verify method returns expected type (boolean)
	assert_true(
		result is bool,
		"remove_card method should return boolean value"
	)

	# Verify default stub behavior (returns false)
	assert_equal(
		result,
		false,
		"remove_card stub should return false by default"
	)

	# Test with different integer values
	var negative_result = hand_display.remove_card(-1)
	assert_true(
		negative_result is bool,
		"remove_card should return boolean for negative index"
	)
	assert_equal(
		negative_result,
		false,
		"remove_card should return false for negative index in stub"
	)

	var large_result = hand_display.remove_card(999)
	assert_true(
		large_result is bool,
		"remove_card should return boolean for large index"
	)
	assert_equal(
		large_result,
		false,
		"remove_card should return false for large index in stub"
	)

	# Clean up
	hand_display.queue_free()

func test_get_card_count_returns_int() -> void:
	"""
	Test that get_card_count method returns an integer value.
	Task 2.3.4: Validate return type and default value of get_card_count.
	"""
	# Arrange - Create HandDisplay instance
	var hand_display = HandDisplay.new()

	# Act - Call get_card_count method
	var result = hand_display.get_card_count()

	# Assert - Verify return type is integer
	assert_true(typeof(result) == TYPE_INT, "get_card_count should return TYPE_INT")

	# Assert - Verify default return value is 0
	assert_equal(result, 0, "get_card_count should return 0 for empty hand")

	# Clean up
	hand_display.queue_free()

func test_add_card_null_rejection() -> void:
	"""
	Test that add_card method properly rejects null cards.
	Task 3.1.3: Verify null validation and array state preservation.
	"""
	# Arrange - Create HandDisplay instance
	var hand_display = HandDisplay.new()

	# Verify initial state
	assert_equal(hand_display.cards.size(), 0, "Cards array should start empty")

	# Act - Call add_card with null parameter
	var result = hand_display.add_card(null)

	# Assert - Verify method returns false for null input
	assert_equal(result, false, "add_card should return false for null card")

	# Assert - Verify cards array remains unchanged
	assert_equal(hand_display.cards.size(), 0, "Cards array should remain empty after null rejection")

	# Clean up
	hand_display.queue_free()

func test_add_card_duplicate_rejection() -> void:
	"""
	Test that add_card method properly rejects duplicate cards.
	Task 3.2.3: Verify duplicate prevention and array state integrity.
	"""
	# Arrange - Create HandDisplay instance and test card
	var hand_display = HandDisplay.new()
	var test_card = ProblemCard.new(
		"test_duplicate",
		"Duplicate Test Card",
		"Test card for duplicate rejection testing",
		"", # No texture path
		"D",
		3
	)

	# Verify initial state
	assert_equal(hand_display.cards.size(), 0, "Cards array should start empty")

	# Act - Add same card twice
	var first_result = hand_display.add_card(test_card)
	var second_result = hand_display.add_card(test_card)

	# Assert - Verify first addition succeeds (functional behavior)
	assert_equal(first_result, true, "First add_card should return true (successful addition)")

	# Assert - Verify second addition returns false (duplicate rejection)
	assert_equal(second_result, false, "Second add_card should return false for duplicate")

	# Assert - Verify array contains exactly one card
	assert_equal(hand_display.cards.size(), 1, "Cards array should contain exactly one card after duplicate rejection")

	# Assert - Verify the card exists in the array
	assert_true(test_card in hand_display.cards, "Test card should exist in cards array")

	# Clean up
	hand_display.queue_free()

func test_add_card_success() -> void:
	"""
	Test that add_card successfully adds valid cards to the array.
	Task 3.3.3: Verify successful card addition and array state.
	"""
	# Arrange - Create HandDisplay instance and test card
	var hand_display = HandDisplay.new()
	var test_card = ProblemCard.new(
		"test_success",
		"Success Test Card",
		"Test card for successful addition verification",
		"", # No texture path
		"S",
		4
	)

	# Verify initial state
	assert_equal(hand_display.cards.size(), 0, "Cards array should start empty")

	# Act - Add card to hand
	hand_display.add_card(test_card)

	# Assert - Verify card was added successfully
	assert_equal(hand_display.cards.size(), 1, "Cards array should contain one card after addition")

	# Assert - Verify the specific card exists in array
	assert_true(test_card in hand_display.cards, "Test card should exist in cards array")

	# Assert - Verify the card is at expected position
	assert_equal(hand_display.cards[0], test_card, "Test card should be at index 0")

	# Clean up
	hand_display.queue_free()

func test_add_card_returns_true_on_success() -> void:
	"""
	Test that add_card returns true when successfully adding valid cards.
	Task 3.3.4: Verify return value accurately indicates successful addition.
	"""
	# Arrange - Create HandDisplay instance and test cards
	var hand_display = HandDisplay.new()
	var test_card1 = ProblemCard.new(
		"test_return_1",
		"Return Test Card 1",
		"First card for return value testing",
		"", # No texture path
		"R",
		6
	)
	var test_card2 = SolutionCard.new(
		"test_return_2",
		"Return Test Card 2",
		"Second card for return value testing",
		"", # No texture path
		["R"], # Solves problem R
		false # Not ultimate
	)

	# Act & Assert - Test first card addition
	var result1 = hand_display.add_card(test_card1)
	assert_equal(result1, true, "add_card should return true for first valid card")

	# Act & Assert - Test second card addition
	var result2 = hand_display.add_card(test_card2)
	assert_equal(result2, true, "add_card should return true for second valid card")

	# Verify final state - both cards should be in hand
	assert_equal(hand_display.cards.size(), 2, "Hand should contain 2 cards after successful additions")
	assert_true(test_card1 in hand_display.cards, "First card should exist in hand")
	assert_true(test_card2 in hand_display.cards, "Second card should exist in hand")

	# Clean up
	hand_display.queue_free()

func test_get_card_count_empty() -> void:
	"""
	Test that get_card_count returns 0 for empty hand.
	Task 4.1.2: Verify card count is 0 for empty hand.
	"""
	# Arrange - Create empty HandDisplay instance
	var hand_display = HandDisplay.new()
	
	# Verify initial state is empty
	assert_equal(hand_display.cards.size(), 0, "Cards array should start empty")
	
	# Act - Call get_card_count method
	var result = hand_display.get_card_count()
	
	# Assert - Verify result is 0 for empty hand
	assert_equal(result, 0, "get_card_count should return 0 for empty hand")
	
	# Assert - Verify return type is still integer
	assert_true(typeof(result) == TYPE_INT, "get_card_count should return TYPE_INT")
	
	# Clean up
	hand_display.queue_free()

func test_get_card_count_with_cards() -> void:
	"""
	Test that get_card_count accurately reflects number of added cards.
	Task 4.1.3: Verify card count matches number of added cards.
	"""
	# Arrange - Create HandDisplay instance and test cards
	var hand_display = HandDisplay.new()
	var test_card1 = ProblemCard.new(
		"count_test_1",
		"Count Test Card 1",
		"First card for counting test",
		"", # No texture path
		"C",
		2
	)
	var test_card2 = ProblemCard.new(
		"count_test_2", 
		"Count Test Card 2",
		"Second card for counting test",
		"", # No texture path
		"D",
		4
	)
	var test_card3 = SolutionCard.new(
		"count_test_3",
		"Count Test Card 3", 
		"Third card for counting test",
		"", # No texture path
		["C", "D"], # Solves problems C and D
		false # Not ultimate
	)
	
	# Verify initial empty state
	assert_equal(hand_display.get_card_count(), 0, "Should start with count of 0")
	
	# Act & Assert - Test progressive card addition
	# Add first card
	hand_display.add_card(test_card1)
	assert_equal(hand_display.get_card_count(), 1, "Count should be 1 after adding first card")
	
	# Add second card
	hand_display.add_card(test_card2)
	assert_equal(hand_display.get_card_count(), 2, "Count should be 2 after adding second card")
	
	# Add third card
	hand_display.add_card(test_card3)
	assert_equal(hand_display.get_card_count(), 3, "Count should be 3 after adding third card")
	
	# Verify final state matches expected count
	assert_equal(hand_display.cards.size(), 3, "Cards array should contain 3 cards")
	assert_equal(hand_display.get_card_count(), hand_display.cards.size(), "get_card_count should match cards array size")
	
	# Clean up
	hand_display.queue_free()
	
func test_add_card_updates_count() -> void:
	"""
	Integration test to verify adding cards updates count correctly.
	Task 4.2.1: Verify integration between add_card and get_card_count methods.
	"""
	# Arrange - Create HandDisplay instance and test cards
	var hand_display = HandDisplay.new()
	var test_card1 = ProblemCard.new(
		"integration_test_1",
		"Integration Test Card 1",
		"First card for add/count integration testing",
		"", # No texture path
		"I",
		1
	)
	var test_card2 = SolutionCard.new(
		"integration_test_2",
		"Integration Test Card 2", 
		"Second card for add/count integration testing",
		"", # No texture path
		["I"], # Solves problem I
		false # Not ultimate
	)
	
	# Step 1: Start with empty hand - verify initial state
	assert_equal(hand_display.get_card_count(), 0, "Should start with count of 0")
	
	# Step 2: Add first card and check count increases
	var add_result1 = hand_display.add_card(test_card1)
	
	# Verify addition was successful
	assert_equal(add_result1, true, "First card addition should succeed")
	
	# Verify count increased correctly
	assert_equal(hand_display.get_card_count(), 1, "Count should be 1 after adding first card")
	
	# Step 3: Add second card and verify count updates again
	var add_result2 = hand_display.add_card(test_card2)
	
	# Verify second addition was successful
	assert_equal(add_result2, true, "Second card addition should succeed")
	
	# Verify count increased correctly again
	assert_equal(hand_display.get_card_count(), 2, "Count should be 2 after adding second card")
	
	# Integration validation - verify both methods work together correctly
	assert_equal(hand_display.cards.size(), hand_display.get_card_count(), "Array size should match get_card_count result")
	
	# Verify both cards are actually present
	assert_true(test_card1 in hand_display.cards, "First card should exist in hand")
	assert_true(test_card2 in hand_display.cards, "Second card should exist in hand")
	
	# Clean up
	hand_display.queue_free()
