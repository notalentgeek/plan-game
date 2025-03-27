# game_manager.gd
# Central controller for the Plan Card Game, managing game state and player turns
extends Node

# Game state enum
enum GameState {
	SETUP, # Setting up the game, dealing cards
	PLAYING, # Main gameplay
	ROUND_END, # End of a round, calculating scores
	GAME_END # End of the game, determining champion
}

# Signals
signal game_started()
signal player_turn_changed(player_id)
signal round_ended(scores)
signal game_ended(champion, final_scores)
signal card_dealt(player_id, card)

# References to card management systems
@onready var card_database = get_node("/root/CardDatabase")
@onready var card_manager = get_node("/root/CardManager")

# Game configuration
var min_players: int = 2
var max_players: int = 5
var cards_per_player: int = 5 # This will adjust based on number of players

# Game state variables
var current_state: int = GameState.SETUP
var current_player_index: int = 0
var current_round: int = 1
var players: Array = [] # Will hold Player objects
var player_scores: Dictionary = {} # Player ID to score mapping
var game_deck: Dictionary = {
	"problem": null, # Will be initialized with Deck instances
	"solution": null
}
var discard_pile: Array[Card] = []

## Built-in Methods

func _ready() -> void:
	# Connect signals from card manager
	card_manager.connect("card_played", Callable(self, "_on_card_played"))
	card_manager.connect("invalid_play", Callable(self, "_on_invalid_play"))

## Game Initialization

func initialize_game(player_count: int) -> bool:
	"""
	Initialize the game with the specified number of players.
	Returns true if initialization is successful, false otherwise.
	"""
	if player_count < min_players or player_count > max_players:
		push_error("Invalid number of players: %d (min: %d, max: %d)" % [player_count, min_players, max_players])
		return false

	# Reset game state
	current_state = GameState.SETUP
	current_round = 1
	current_player_index = 0
	players.clear()
	player_scores.clear()
	discard_pile.clear()

	# Adjust cards per player based on player count (higher player count = fewer cards per player)
	cards_per_player = 5 if player_count <= 3 else 4 if player_count == 4 else 3

	# Create player objects
	for i in range(player_count):
		var player = Player.new(i)
		players.append(player)
		player_scores[i] = 0

	# Get fresh decks
	game_deck["problem"] = card_database.get_fresh_problem_deck()
	game_deck["solution"] = card_database.get_fresh_solution_deck()

	return true

func start_game() -> void:
	"""
	Start the game after initialization.
	"""
	if current_state != GameState.SETUP:
		push_error("Cannot start game: game is not in setup state")
		return

	# Deal cards to players
	_deal_initial_cards()

	# Set initial problem card
	var initial_problem = game_deck["problem"].draw_card()
	card_manager.play_problem_card(-1, initial_problem) # -1 indicates system, not a player
	discard_pile.append(initial_problem)

	# Set game state to playing
	current_state = GameState.PLAYING

	# Start with the first player
	current_player_index = 0

	emit_signal("game_started")
	emit_signal("player_turn_changed", current_player_index)

## Game Flow Control

func next_turn() -> void:
	"""
	Advance to the next player's turn.
	"""
	if current_state != GameState.PLAYING:
		push_error("Cannot advance turn: game is not in playing state")
		return

	# Move to next player
	current_player_index = (current_player_index + 1) % players.size()

	emit_signal("player_turn_changed", current_player_index)

func end_round() -> void:
	"""
	End the current round and calculate scores.
	"""
	if current_state != GameState.PLAYING:
		push_error("Cannot end round: game is not in playing state")
		return

	current_state = GameState.ROUND_END

	# Calculate and update scores
	var round_scores = _calculate_round_scores()
	for player_id in round_scores:
		player_scores[player_id] += round_scores[player_id]

	emit_signal("round_ended", round_scores)

	# Check if game should end
	if _should_end_game():
		_end_game()
	else:
		# Prepare for next round
		_prepare_next_round()

func _prepare_next_round() -> void:
	"""
	Prepare the game for the next round.
	"""
	# Increment round counter
	current_round += 1

	# Reset table
	card_manager.reset_table()
	discard_pile.clear()

	# Get fresh decks
	game_deck["problem"] = card_database.get_fresh_problem_deck()
	game_deck["solution"] = card_database.get_fresh_solution_deck()

	# Clear player hands
	for player in players:
		player.clear_hand()

	# Deal new cards
	_deal_initial_cards()

	# Set initial problem card
	var initial_problem = game_deck["problem"].draw_card()
	card_manager.play_problem_card(-1, initial_problem)
	discard_pile.append(initial_problem)

	# Set game state to playing
	current_state = GameState.PLAYING

	# Start with the first player
	current_player_index = 0

	emit_signal("player_turn_changed", current_player_index)

func _end_game() -> void:
	"""
	End the game and determine the champion.
	"""
	current_state = GameState.GAME_END

	# Find player with highest score (the champion)
	var champion_id = -1
	var max_score = -1
	for player_id in player_scores:
		if player_scores[player_id] > max_score:
			max_score = player_scores[player_id]
			champion_id = player_id

	emit_signal("game_ended", champion_id, player_scores)

func _should_end_game() -> bool:
	"""
	Determine if the game should end after the current round.
	In this implementation, we use a fixed number of rounds (3),
	but this could be configurable or based on other criteria.
	"""
	# For simplicity, play a fixed number of rounds
	return current_round >= 3

## Player Actions

func play_solution_card(player_id: int, card_index: int) -> bool:
	"""
	Play a solution card from a player's hand.
	Returns true if successful, false otherwise.
	"""
	if current_state != GameState.PLAYING:
		push_error("Cannot play card: game is not in playing state")
		return false

	if player_id != current_player_index:
		push_error("Cannot play card: not player's turn")
		return false

	var player = players[player_id]
	var card = player.get_card_at(card_index)

	if card == null or card.card_type != Card.CardType.SOLUTION:
		push_error("Invalid card selection")
		return false

	if card_manager.play_solution_card(player_id, card):
		player.remove_card(card_index)
		discard_pile.append(card)
		return true

	return false

func play_problem_card(player_id: int, card_index: int) -> bool:
	"""
	Play a problem card from a player's hand.
	Returns true if successful, false otherwise.
	"""
	if current_state != GameState.PLAYING:
		push_error("Cannot play card: game is not in playing state")
		return false

	if player_id != current_player_index:
		push_error("Cannot play card: not player's turn")
		return false

	var player = players[player_id]
	var card = player.get_card_at(card_index)

	if card == null or card.card_type != Card.CardType.PROBLEM:
		push_error("Invalid card selection")
		return false

	if card_manager.play_problem_card(player_id, card):
		player.remove_card(card_index)
		discard_pile.append(card)

		# Check for CHECKMATE
		if player.count_problem_cards() == 0:
			# Player has no more problem cards, they've achieved CHECKMATE
			end_round()
		else:
			# Move to next player's turn
			next_turn()

		return true

	return false

func play_multiple_problem_cards(player_id: int, card_indices: Array[int]) -> bool:
	"""
	Play multiple identical problem cards from a player's hand.
	Returns true if successful, false otherwise.
	"""
	if current_state != GameState.PLAYING:
		push_error("Cannot play cards: game is not in playing state")
		return false

	if player_id != current_player_index:
		push_error("Cannot play cards: not player's turn")
		return false

	var player = players[player_id]
	var cards = []

	# Collect cards to play
	for index in card_indices:
		var card = player.get_card_at(index)
		if card == null or card.card_type != Card.CardType.PROBLEM:
			push_error("Invalid card selection")
			return false
		cards.append(card)

	if card_manager.play_multiple_problem_cards(player_id, cards):
		# Remove cards from player's hand in reverse order to avoid index shifting
		for index in card_indices.duplicate():
			card_indices.sort()
			card_indices.reverse()

		for index in card_indices:
			player.remove_card(index)
			discard_pile.append(cards.pop_front())

		# Check for CHECKMATE
		if player.count_problem_cards() == 0:
			# Player has no more problem cards, they've achieved CHECKMATE
			end_round()
		else:
			# Move to next player's turn
			next_turn()

		return true

	return false

func declare_potential_checkmate(player_id: int) -> bool:
	"""
	Player declares that they only have solution cards left and will CHECKMATE in the next turn.
	Returns true if the declaration is valid, false otherwise.
	"""
	if current_state != GameState.PLAYING:
		push_error("Cannot declare CHECKMATE: game is not in playing state")
		return false

	if player_id != current_player_index:
		push_error("Cannot declare CHECKMATE: not player's turn")
		return false

	var player = players[player_id]

	# Check if player actually has no problem cards
	if player.count_problem_cards() > 0:
		push_error("Cannot declare CHECKMATE: player still has problem cards")
		return false

	# The declaration is valid, but no action is needed yet
	# In the next turn, if they play their last solution card successfully,
	# they will achieve CHECKMATE

	next_turn()
	return true

## Helper Methods

func _deal_initial_cards() -> void:
	"""
	Deal the initial cards to all players.
	"""
	# First, ensure all players have the required number of cards
	for player in players:
		for i in range(cards_per_player):
			var problem_card = game_deck["problem"].draw_card()
			if problem_card:
				player.add_card(problem_card)
				emit_signal("card_dealt", player.id, problem_card)

			var solution_card = game_deck["solution"].draw_card()
			if solution_card:
				player.add_card(solution_card)
				emit_signal("card_dealt", player.id, solution_card)

func _calculate_round_scores() -> Dictionary:
	"""
	Calculate scores for the current round.
	Returns a dictionary mapping player IDs to their scores for this round.
	"""
	var round_scores = {}
	var checkmate_player_id = -1
	var problem_card_counts = {}

	# Find the player who achieved CHECKMATE
	for i in range(players.size()):
		var player = players[i]
		if player.count_problem_cards() == 0:
			checkmate_player_id = player.id
			round_scores[player.id] = 5 # CHECKMATE is worth 5 points
			break

	# Calculate the number of problem cards remaining for each player
	for player in players:
		if player.id != checkmate_player_id:
			problem_card_counts[player.id] = player.count_problem_cards()

	# Sort players by problem card count (ascending)
	var sorted_players = problem_card_counts.keys()
	sorted_players.sort_custom(func(a, b): return problem_card_counts[a] < problem_card_counts[b])

	# Assign points based on ranking (3, 2, 1 points)
	var points = 3
	for player_id in sorted_players:
		if points > 0:
			round_scores[player_id] = points
			points -= 1
		else:
			round_scores[player_id] = 0

	return round_scores

## Signal Handlers

func _on_card_played(player_id: int, card: Card) -> void:
	# Handle any effects or state changes when a card is played
	pass

func _on_invalid_play(player_id: int, reason: String) -> void:
	# Handle invalid card plays, possibly notify the UI
	push_warning("Invalid play by player %d: %s" % [player_id, reason])
