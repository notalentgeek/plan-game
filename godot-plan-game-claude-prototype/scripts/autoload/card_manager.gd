# scripts/autoload/card_manager.gd
# Manages card interactions and game rules for the Plan card game
extends Node

signal card_played(player_id, card)
signal invalid_play(player_id, reason)

# Reference to the current problem card on the table
var current_problem_card: ProblemCard = null

func is_valid_solution(solution_card: SolutionCard) -> bool:
	"""
	Checks if the provided solution card can solve the current problem on the table.
	Returns true if valid, false otherwise.
	"""
	if current_problem_card == null:
		push_error("No problem card on the table")
		return false

	# Ultimate cards can solve any problem
	if solution_card.is_ultimate:
		return true

	# Check if the solution card can solve the current problem
	return solution_card.can_solve_problem(current_problem_card.letter_code)

func play_solution_card(player_id: int, solution_card: SolutionCard) -> bool:
	"""
	Attempts to play a solution card to solve the current problem.
	Returns true if successful, false otherwise.
	"""
	if not is_valid_solution(solution_card):
		invalid_play.emit(player_id, "Solution card does not solve the current problem")
		return false

	# Solution is valid, emit signal that card has been played
	card_played.emit(player_id, solution_card)

	# Note: The game logic will need to handle removing the card from
	# the player's hand and updating the game state
	return true

func play_problem_card(player_id: int, problem_card: ProblemCard) -> bool:
	"""
	Plays a problem card, setting it as the current problem on the table.
	Returns true if successful, false otherwise.
	"""
	# Set as the current problem
	current_problem_card = problem_card

	# Emit signal that card has been played
	card_played.emit(player_id, problem_card)

	# Note: The game logic will need to handle removing the card from
	# the player's hand and updating the game state
	return true

func play_multiple_problem_cards(player_id: int, problem_cards: Array[ProblemCard]) -> bool:
	"""
	Plays multiple identical problem cards at once as allowed by the rules.
	Returns true if successful, false otherwise.
	"""
	if problem_cards.size() <= 1:
		push_error("Multiple cards must be more than one")
		return false

	# Check if all cards are identical
	var first_card_id = problem_cards[0].id
	for card in problem_cards:
		if card.id != first_card_id:
			invalid_play.emit(player_id, "Multiple problem cards must be identical")
			return false

	# Play the last card as the current problem and remove all from hand
	current_problem_card = problem_cards[-1]

	# Emit signal for each card played
	for card in problem_cards:
		card_played.emit(player_id, card)

	return true

func can_play_multiple_problems(player: Object, has_ultimate: bool) -> bool:
	"""
	Checks if a player can play multiple problem cards based on game rules.
	According to the rules, a player can play two different problem cards simultaneously
	if they possess an ULTIMATE CARD.
	"""
	return has_ultimate

func reset_table() -> void:
	"""
	Clears the current problem card from the table.
	"""
	current_problem_card = null

func calculate_player_points(player_id: int, is_checkmate: bool, problem_cards_count: int) -> int:
	"""
	Calculates points for a player based on game rules.
	- Player who achieves CHECKMATE gets 5 points
	- Players are graded 3, 2, and 1 points based on having fewer problem cards
	"""
	if is_checkmate:
		return 5

	# Note: The actual point calculation for non-CHECKMATE players
	# should be done by comparing all players' problem card counts
	# This would typically be handled by the GameManager class
	return 0

func is_checkmate(player_problem_cards: int) -> bool:
	"""
	Determines if a player has achieved CHECKMATE status.
	A player achieves CHECKMATE when they play their last problem card.
	"""
	return player_problem_cards == 0
