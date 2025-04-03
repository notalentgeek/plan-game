# tests/unit/classes/problem_card_test.gd
extends TestCase

"""
Unit tests for the ProblemCard class.
Tests the specialized functionality of problem cards.
"""

func test_problem_card_initialization() -> void:
	"""
	Test that a ProblemCard can be properly initialized with parameters.
	"""
	var card = ProblemCard.new(
		"p1",
		"Climate Change",
		"Rising global temperatures leading to extreme weather events.",
		"res://assets/cards/problem_cards/placeholder.png",
		"A",
		10
	)

	# Assert basic properties were set correctly
	assert_equal(card.id, "p1", "Problem card ID was not set correctly")
	assert_equal(
		card.card_name,
		"Climate Change",
		"Problem card name was not set correctly"
	)
	assert_equal(
		card.card_type,
		Card.CardType.PROBLEM,
		"Problem card type was not set correctly"
	)

	# Assert problem-specific properties were set correctly
	assert_equal(
		card.letter_code,
		"A",
		"Problem card letter code was not set correctly"
	)
	assert_equal(
		card.severity_index,
		10,
		"Problem card severity index was not set correctly"
	)

func test_problem_card_to_string() -> void:
	"""
	Test the _to_string method returns the expected format with
	problem-specific information.
	"""
	var card = ProblemCard.new("p1", "Climate Change", "Description", "", "A", 10)
	var expected_string = "[Problem Card: Climate Change (p1) - Letter: A, Index: 10]"

	assert_equal(
		card.to_string(),
		expected_string,
		"Problem card string representation doesn't match expected format"
	)

func test_problem_card_inheritance() -> void:
	"""
	Test that a ProblemCard properly inherits from Card.
	"""
	var card = ProblemCard.new()

	# Check that it's both a ProblemCard and a Card
	assert_true(card is ProblemCard, "Object is not a ProblemCard")
	assert_true(card is Card, "ProblemCard is not inheriting from Card")

	# Check that Card methods are available
	assert_true(
		card.has_method("get_texture"),
		"Card method not available on ProblemCard"
	)
