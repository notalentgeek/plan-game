# tests/unit/classes/solution_card_test.gd
extends Node

"""
Unit tests for the SolutionCard class.
Tests the specialized functionality of solution cards, including Ultimate cards.
"""

func _ready() -> void:
	"""
	Run all solution card tests when the scene is ready.
	"""
	print("Running SolutionCard tests...")

func test_solution_card_initialization() -> void:
	"""
	Test that a SolutionCard can be properly initialized with parameters.
	"""
	var solvable_problems: Array[String] = ["A", "B", "C"]
	var card = SolutionCard.new(
		"s1",
		"Renewable Energy",
		"Energy from renewable sources like solar, wind, etc.",
		"res://assets/cards/solution_cards/placeholder.png",
		solvable_problems,
		false
	)
	
	# Assert basic properties were set correctly
	assert(card.id == "s1", "Solution card ID was not set correctly")
	assert(card.card_name == "Renewable Energy", "Solution card name was not set correctly")
	assert(card.card_type == Card.CardType.SOLUTION, "Solution card type was not set correctly")
	
	# Assert solution-specific properties were set correctly
	assert(card.solvable_problems == solvable_problems, "Solution card solvable problems were not set correctly")
	assert(card.is_ultimate == false, "Solution card is_ultimate flag was not set correctly")

func test_ultimate_card_initialization() -> void:
	"""
	Test that an Ultimate card is properly initialized with the ULTIMATE card type.
	"""
	var card = SolutionCard.new(
		"su1",
		"Environmental Education",
		"Educating people about environmental issues.",
		"res://assets/cards/solution_cards/placeholder_ultimate.png",
		[],
		true
	)
	
	# Assert ultimate-specific properties were set correctly
	assert(card.card_type == Card.CardType.ULTIMATE, "Ultimate card type was not set correctly")
	assert(card.is_ultimate == true, "Ultimate card is_ultimate flag was not set correctly")

func test_can_solve_problem() -> void:
	"""
	Test the can_solve_problem method for regular solution cards.
	"""
	var card = SolutionCard.new("s1", "Renewable Energy", "", "", ["A", "C"], false)
	
	# Should solve problems in its list
	assert(card.can_solve_problem("A") == true, "Solution card should solve problem A")
	assert(card.can_solve_problem("C") == true, "Solution card should solve problem C")
	
	# Should not solve problems not in its list
	assert(card.can_solve_problem("B") == false, "Solution card should not solve problem B")
	assert(card.can_solve_problem("Z") == false, "Solution card should not solve problem Z")

func test_ultimate_can_solve_any_problem() -> void:
	"""
	Test that ultimate cards can solve any problem.
	"""
	var card = SolutionCard.new("su1", "Environmental Education", "", "", [], true)
	
	# Should solve any problem, regardless of letter code
	assert(card.can_solve_problem("A") == true, "Ultimate card should solve any problem")
	assert(card.can_solve_problem("Z") == true, "Ultimate card should solve any problem")
	assert(card.can_solve_problem("XYZ") == true, "Ultimate card should solve any problem")

func test_solution_card_to_string() -> void:
	"""
	Test the _to_string method for solution and ultimate cards.
	"""
	var solution = SolutionCard.new("s1", "Renewable Energy", "", "", ["A", "B"], false)
	var ultimate = SolutionCard.new("su1", "Environmental Education", "", "", [], true)
	
	var solution_string = solution.to_string()
	var ultimate_string = ultimate.to_string()
	
	# Check solution card string format
	assert(solution_string.contains("Solution Card"), "Solution card string should identify as solution")
	assert(solution_string.contains("Renewable Energy"), "Solution card string should include name")
	assert(solution_string.contains("[A, B]"), "Solution card string should include solvable problems")
	
	# Check ultimate card string format
	assert(ultimate_string.contains("Ultimate Card"), "Ultimate card string should identify as ultimate")
	assert(ultimate_string.contains("Environmental Education"), "Ultimate card string should include name")
