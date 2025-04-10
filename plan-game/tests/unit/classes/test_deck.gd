# tests/unit/classes/deck_test.gd
extends TestCase

"""
Unit tests for the Deck class.
Validates deck management functionality and edge cases.
"""

# Test cards for deck operations
var test_problem_card_1: ProblemCard
var test_problem_card_2: ProblemCard
var test_solution_card: SolutionCard

# Setup method that runs before each test
func setup() -> void:
	"""
	Prepare test environment by creating test cards.
	"""
	# Create test cards
	test_problem_card_1 = ProblemCard.new(
		"prob_01",
		"Climate Change",
		"Global warming issue",
		"",
		"A",
		8
	)
	test_problem_card_2 = ProblemCard.new(
		"prob_02",
		"Water Pollution",
		"Ocean contamination",
		"",
		"B",
		7
	)
	test_solution_card = SolutionCard.new(
		"sol_01",
		"Renewable Energy",
		"Sustainable power solution",
		"",
		["A"],
		false
	)

func test_deck_initialization() -> void:
	"""
	Test deck initialization with various parameters.
	"""
	var default_deck = Deck.new()
	assert_equal(default_deck.size(), 0, "Default deck should be empty")
	assert_true(!default_deck.is_empty() == false, "is_empty() should return true for empty deck")

	var pre_populated_deck = Deck.new([test_problem_card_1, test_problem_card_2])
	assert_equal(pre_populated_deck.size(), 2, "Pre-populated deck should have 2 cards")

func test_deck_add_card() -> void:
	"""
	Test adding individual cards to the deck.
	"""
	var deck = Deck.new()

	# Add first card
	assert_true(deck.add_card(test_problem_card_1), "First card should be added successfully")
	assert_equal(deck.size(), 1, "Deck size should be 1 after adding a card")

	# Verify top card
	assert_equal(deck.peek_top_card(), test_problem_card_1, "Top card should match added card")

func test_deck_add_multiple_cards() -> void:
	"""
	Test adding multiple cards to the deck.
	"""
	var deck = Deck.new()
	var cards_to_add: Array[Card] = [
		test_problem_card_1,
		test_problem_card_2,
		test_solution_card
	]

	var added_count = deck.add_cards(cards_to_add)
	assert_equal(added_count, 3, "All cards should be added successfully")
	assert_equal(deck.size(), 3, "Deck size should match number of added cards")

func test_deck_draw_card() -> void:
	"""
	Test drawing cards and deck emptying behavior.
	"""
	var deck = Deck.new([
		test_problem_card_1,
		test_problem_card_2,
		test_solution_card
	])

	var first_card = deck.draw_card()
	assert_equal(first_card, test_problem_card_1, "First drawn card should match first added card")
	assert_equal(deck.size(), 2, "Deck size should decrease after drawing")

	# Draw remaining cards
	deck.draw_card()
	deck.draw_card()

	assert_true(deck.is_empty(), "Deck should be empty after drawing all cards")
	assert_null(deck.draw_card(), "Drawing from empty deck should return null")

func test_deck_shuffle() -> void:
	"""
	Test deck shuffling functionality.
	Note: Due to randomness, we can't assert exact order,
	but we can check that the shuffle doesn't change the size.
	"""
	var deck = Deck.new([
		test_problem_card_1,
		test_problem_card_2,
		test_solution_card
	])

	var original_size = deck.size()
	deck.shuffle()

	assert_equal(deck.size(), original_size, "Shuffling should not change deck size")

func test_deck_unique_cards() -> void:
	"""
	Test unique cards constraint.
	"""
	var deck = Deck.new([], -1, true) # -1 for unlimited, true for unique

	assert_true(deck.add_card(test_problem_card_1), "First unique card should be added")
	assert_true(!deck.add_card(test_problem_card_1), "Duplicate card should not be added")

func test_deck_max_cards_limit() -> void:
	"""
	Test maximum card limit constraint.
	"""
	var deck = Deck.new([], 2) # Max 2 cards

	assert_true(deck.add_card(test_problem_card_1), "First card should be added")
	assert_true(deck.add_card(test_problem_card_2), "Second card should be added")
	assert_true(!deck.add_card(test_solution_card), "Third card should not be added")
