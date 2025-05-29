# tests/unit/classes/test_card_database.gd
extends TestCase

var card_database: CardDatabase

func setup() -> void:
	# Get reference to the singleton instead of creating new instance
	card_database = get_node("/root/CardDatabase")
	if not card_database._cards_initialized:
		card_database.initialize_cards()

func teardown() -> void:
	card_database = null

func test_problem_card_initialization() -> void:
	# Test that all 18 problem cards were initialized
	var problem_cards = card_database.get_all_problem_cards()
	assert_equal(problem_cards.size(), 18, "Should initialize 18 problem cards")

	# Test that all letter codes A through R are present
	var letter_codes = []
	for card in problem_cards:
		letter_codes.append(card.letter_code)

	for letter in CardDatabase.PROBLEM_CODES:
		assert_true(letter in letter_codes, "Problem letter code " + letter + " should be present")

func test_solution_card_initialization() -> void:
	# Test that all 17 solution cards were initialized (15 regular + 2 ultimate)
	var solution_cards = card_database.get_all_solution_cards()
	assert_equal(solution_cards.size(), 17, "Should initialize 17 solution cards")

	# Test that 2 ultimate cards were created
	var ultimate_cards = card_database.get_ultimate_solution_cards()
	assert_equal(ultimate_cards.size(), 2, "Should initialize 2 ultimate solution cards")

func test_get_card_by_id() -> void:
	# Test retrieving a problem card
	var problem_card = card_database.get_card_by_id("p_a")
	assert_true(problem_card != null, "Should retrieve problem card by ID")
	assert_equal(problem_card.card_name, "Air Pollution", "Retrieved card should have correct name")

	# Test retrieving a solution card
	var solution_card = card_database.get_card_by_id("s_01")
	assert_true(solution_card != null, "Should retrieve solution card by ID")
	assert_equal(solution_card.card_name, "Renewable Energy", "Retrieved card should have correct name")

	# Test retrieving non-existent card
	var nonexistent_card = card_database.get_card_by_id("invalid_id")
	assert_true(nonexistent_card == null, "Should return null for non-existent card ID")

func test_get_solution_cards_for_problem() -> void:
	# Test retrieving solutions for problem "D" (Climate Change)
	var solutions = card_database.get_solution_cards_for_problem("D")
	assert_true(solutions.size() >= 2, "Should retrieve at least 2 solutions for Climate Change")

	# Test that ultimate cards are included in solutions
	var all_ultimate_cards = card_database.get_ultimate_solution_cards()
	for ultimate_card in all_ultimate_cards:
		assert_true(ultimate_card in solutions, "Ultimate solution should solve any problem")

func test_create_decks() -> void:
	# Test creating problem deck
	var problem_deck = card_database.create_problem_deck()
	assert_equal(problem_deck.size(), 18, "Problem deck should contain 18 cards")

	# Test creating solution deck - FIX: Use get_all_solution_cards() to include ultimate cards
	var all_solution_cards = card_database.get_all_solution_cards()
	assert_equal(all_solution_cards.size(), 17, "Should have 17 total solution cards (15 regular + 2 ultimate)")

	# Test the actual create_solution_deck method separately
	var regular_solution_deck = card_database.create_solution_deck()
	assert_equal(regular_solution_deck.size(), 15, "Regular solution deck should contain 15 cards (excluding ultimate)")
