# tests/unit/classes/problem_card_test.gd
extends Node

"""
Unit tests for the ProblemCard class.
Tests the specialized functionality of problem cards.
"""

func _ready() -> void:
	"""
	Run all problem card tests when the scene is ready.
	"""
	print("Running ProblemCard tests...")

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
	assert(card.id == "p1", "Problem card ID was not set correctly")
	assert(card.card_name == "Climate Change", "Problem card name was not set correctly")
	assert(card.card_type == Card.CardType.PROBLEM, "Problem card type was not set correctly")
	
	# Assert problem-specific properties were set correctly
	assert(card.letter_code == "A", "Problem card letter code was not set correctly")
	assert(card.severity_index == 10, "Problem card severity index was not set correctly")

func test_problem_card_to_string() -> void:
	"""
	Test the _to_string method returns the expected format with problem-specific information.
	"""
	var card = ProblemCard.new("p1", "Climate Change", "Description", "", "A", 10)
	var expected_string = "[Problem Card: Climate Change (p1) - Letter: A, Index: 10]"
	
	assert(card.to_string() == expected_string, "Problem card string representation doesn't match expected format")

func test_problem_card_inheritance() -> void:
	"""
	Test that a ProblemCard properly inherits from Card.
	"""
	var card = ProblemCard.new()
	
	# Check that it's both a ProblemCard and a Card
	assert(card is ProblemCard, "Object is not a ProblemCard")
	assert(card is Card, "ProblemCard is not inheriting from Card")
	
	# Check that Card methods are available
	assert(card.has_method("get_texture"), "Card method not available on ProblemCard")
