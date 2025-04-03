# tests/unit/classes/card_test.gd
extends Node

"""
Unit tests for the Card class.
Tests basic functionality of the Card class.
"""

func _ready() -> void:
	"""
	Run all card tests when the scene is ready.
	"""
	print("Running Card tests...")

	# Run each test function
	card_test_initialization()
	card_test_texture_loading()
	card_test_to_string()

	print("Card tests completed")

func card_test_initialization() -> void:
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
	assert(card.id == "test_id", "Card ID was not set correctly")
	assert(card.card_name == "Test Card", "Card name was not set correctly")
	assert(
		card.description == "This is a test card description.",
		"Card description was not set correctly"
	)
	assert(
		card.card_type == Card.CardType.PROBLEM,
		"Card type was not set correctly"
	)

	print("✓ Card initialization test passed")

func card_test_texture_loading() -> void:
	"""
	Test texture loading functionality.
	Note: This is a basic test; in a real test environment, you'd mock the
	resource loading.
	"""
	var card = Card.new()

	# Initially, texture should be null
	assert(card.get_texture() == null, "Initial texture should be null")

	print("✓ Card texture loading test passed")

func card_test_to_string() -> void:
	"""
	Test the _to_string method returns the expected format.
	"""
	var card = Card.new("test_id", "Test Card", "Description")
	var expected_string = "[Card: Test Card (test_id)]"

	assert(
		card.to_string() == expected_string,
		"Card string representation doesn't match expected format"
	)

	print("✓ Card to_string test passed")
