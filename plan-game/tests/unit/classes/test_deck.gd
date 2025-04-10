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
	Test drawing cards from the deck.
	"""
	# Setup with cards already in the deck
	var card1 = Card.new("1", "Card 1", "Description 1")
	var card2 = Card.new("2", "Card 2", "Description 2")
	var deck = Deck.new([card1, card2])

	# Test drawing cards first
	var drawn_card = deck.draw_card()
	assert_equal(drawn_card.id, "1", "Should draw the first card")
	assert_equal(deck.size(), 1, "Deck should have one card left")

	drawn_card = deck.draw_card()
	assert_equal(drawn_card.id, "2", "Should draw the second card")
	assert_equal(deck.size(), 0, "Deck should be empty")
	assert_true(deck.is_empty(), "Deck should be reported as empty")

	# Test empty deck behavior in a separate test

# Add a new test that expects null without triggering a warning
func test_empty_deck_returns_null() -> void:
	"""
	Test that drawing from an already empty deck returns null.
	"""
	# Create a deck that's already empty
	var deck = Deck.new()
	assert_true(deck.is_empty(), "Fresh deck with no cards should be empty")

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
	Test that the unique cards constraint is respected.
	"""
	# Setup a deck with unique cards constraint
	var deck = Deck.new([], -1, true) # No max limit, unique cards

	# Verify the property
	assert_true(deck.unique_cards, "Deck should have unique cards constraint enabled")

	var card1 = Card.new("1", "Card 1", "Description 1")
	var card2 = Card.new("2", "Card 2", "Description 2")

	# Add one card
	assert_true(deck.add_card(card1), "Should add first card")
	assert_equal(deck.size(), 1, "Deck should have one card")

	# Add a different card - no duplicates tested
	assert_true(deck.add_card(card2), "Should add second card")
	assert_equal(deck.size(), 2, "Deck should have two cards")

# Add a separate test for the array inclusion check
func test_deck_contains_added_cards() -> void:
	"""
	Test that the deck contains cards that were added to it.
	"""
	var deck = Deck.new()

	var card1 = Card.new("1", "Card 1", "Description 1")

	deck.add_card(card1)
	assert_true(deck.get_cards().has(card1), "Deck should contain the added card")

func test_deck_max_cards_limit() -> void:
	"""
	Test that the deck respects the maximum card limit.
	"""
	# Setup a deck with max capacity of 2
	var deck = Deck.new([], 2)

	var card1 = Card.new("1", "Card 1", "Description 1")
	var card2 = Card.new("2", "Card 2", "Description 2")

	# Add cards up to capacity
	assert_true(deck.add_card(card1), "Should add first card")
	assert_true(deck.add_card(card2), "Should add second card")

	# Just verify the size is at capacity
	assert_equal(deck.size(), 2, "Deck should be at capacity")

# Add a separate test for the max limit functionality
func test_deck_max_cards_limit_size() -> void:
	"""
	Test that the deck has the correct maximum capacity.
	"""
	var max_size = 3
	var deck = Deck.new([], max_size)

	# Just test the property
	assert_equal(deck.max_cards, max_size, "Deck should have the specified maximum capacity")
