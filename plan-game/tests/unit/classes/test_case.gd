# tests/unit/classes/card_test.gd
extends TestCase

"""
Unit tests for the Card class.
Tests basic functionality of the Card class.
"""

# Optional setup method that runs before each test
func setup() -> void:
	# Initialize anything needed for tests
	pass

# Optional teardown method that runs after each test
func teardown() -> void:
	# Clean up after tests
	pass

func test_card_initialization() -> void:
	"""
	Test that a Card can be properly initialized with parameters.
	"""
	var card = Card.new(
		"test_id",
		"Test Card",
		"This is a test card description.",
		Card.CardType.PROBLEM,
		""
	)

	# Assert properties were set correctly
	assert_equal(card.id, "test_id", "Card ID was not set correctly")
	assert_equal(card.card_name, "Test Card", "Card name was not set correctly")
	assert_equal(
		card.description,
		"This is a test card description.",
		"Card description was not set correctly"
	)
	assert_equal(
		card.card_type,
		Card.CardType.PROBLEM,
		"Card type was not set correctly"
	)

func test_card_texture_loading() -> void:
	"""
	Test texture loading functionality.
	Note: This is a basic test; in a real test environment, you'd mock the
	resource loading.
	"""
	var card = Card.new()

	# Initially, texture should be null
	assert_null(card.get_texture(), "Initial texture should be null")

func test_card_to_string() -> void:
	"""
	Test the _to_string method returns the expected format.
	"""
	var card = Card.new("test_id", "Test Card", "Description")
	var expected_string = "[Card: Test Card (test_id)]"

	assert_equal(
		card.to_string(),
		expected_string,
		"Card string representation doesn't match expected format"
	)
