# game.gd
# Main game scene for the Plan Card Game
extends Control

# References to managers
@onready var game_manager = get_node("/root/GameManager")
@onready var card_manager = get_node("/root/CardManager")
@onready var card_database = get_node("/root/CardDatabase")

# References to UI elements
@onready var table = $TableContainer/Table
@onready var player_containers = [
	$PlayersContainer/Player1Container,
	$PlayersContainer/Player2Container,
	$PlayersContainer/Player3Container,
	$PlayersContainer/Player4Container,
	$PlayersContainer/Player5Container
]
@onready var game_ui = $GameUI
@onready var current_problem_display = $TableContainer/CurrentProblemDisplay
@onready var turn_indicator = $TurnIndicator

# Card scene reference
var card_display_scene = preload("res://scenes/card/card_display.tscn")

# Game state variables
var active_player_id: int = 0
var selected_cards: Array[CardDisplay] = []
var solution_mode: bool = true # True when player needs to play solution, false when problem

func _ready() -> void:
	# Connect signals
	game_manager.connect("game_started", Callable(self, "_on_game_started"))
	game_manager.connect("player_turn_changed", Callable(self, "_on_player_turn_changed"))
	game_manager.connect("round_ended", Callable(self, "_on_round_ended"))
	game_manager.connect("game_ended", Callable(self, "_on_game_ended"))

	# Connect card manager signals
	card_manager.connect("card_played", Callable(self, "_on_card_played"))
	card_manager.connect("invalid_play", Callable(self, "_on_invalid_play"))

	# Initialize UI
	_init_ui()

	# Start the game
	game_manager.start_game()

## Game Flow Methods

func _init_ui() -> void:
	"""
	Initialize the game UI.
	"""
	# Hide unused player containers
	for i in range(player_containers.size()):
		player_containers[i].visible = i < game_manager.players.size()

	# Setup player names
	for i in range(game_manager.players.size()):
		var player_name = player_containers[i].get_node("PlayerNameLabel")
		player_name.text = game_manager.players[i].name

	# Setup action buttons
	game_ui.play_button.connect("pressed", Callable(self, "_on_play_button_pressed"))
	game_ui.skip_button.connect("pressed", Callable(self, "_on_skip_button_pressed"))
	game_ui.declare_button.connect("pressed", Callable(self, "_on_declare_button_pressed"))
	game_ui.menu_button.connect("pressed", Callable(self, "_on_menu_button_pressed"))

func _on_game_started() -> void:
	"""
	Handle game start event.
	"""
	# Display the initial problem card
	_update_problem_display()

	# Display player hands
	_update_player_hands()

	# Set initial turn
	_update_turn_indicator()

	# Set solution mode (first player plays solution)
	solution_mode = true
	_update_ui_mode()

func _on_player_turn_changed(player_id: int) -> void:
	"""
	Handle player turn change event.
	"""
	active_player_id = player_id

	# Clear selections
	_clear_selections()

	# Update turn indicator
	_update_turn_indicator()

	# Set solution mode (each player first plays solution)
	solution_mode = true
	_update_ui_mode()

func _on_round_ended(scores: Dictionary) -> void:
	"""
	Handle round end event.
	"""
	# Show scores dialog
	game_ui.show_round_scores(scores)

	# Update player hands for new round
	_update_player_hands()

	# Update problem display
	_update_problem_display()

func _on_game_ended(champion_id: int, final_scores: Dictionary) -> void:
	"""
	Handle game end event.
	"""
	# Show game over dialog with champion
	game_ui.show_game_over(champion_id, final_scores)

## Card Interaction Methods

func _on_card_clicked(card_display: CardDisplay) -> void:
	"""
	Handle card click event.
	"""
	if card_display.card_data.card_type == Card.CardType.PROBLEM and not solution_mode:
		# Selecting problem cards
		_handle_problem_card_selection(card_display)
	elif card_display.card_data.card_type != Card.CardType.PROBLEM and solution_mode:
		# Selecting solution cards
		_handle_solution_card_selection(card_display)

func _handle_problem_card_selection(card_display: CardDisplay) -> void:
	"""
	Handle problem card selection.
	"""
	# Check if card is already selected
	if card_display.is_selected:
		# Deselect the card
		card_display.select(false)
		selected_cards.erase(card_display)
	else:
		# If player has an ultimate card, allow multiple different problem cards
		var has_ultimate = game_manager.players[active_player_id].has_ultimate_card()

		if selected_cards.size() > 0 and not has_ultimate:
			# Only allow selecting identical problem cards
			var first_card = selected_cards[0].card_data
			if first_card.id != card_display.card_data.id:
				# Show error message
				game_ui.show_message("You can only play identical problem cards!")
				return

		# Select the card
		card_display.select(true)
		selected_cards.append(card_display)

	# Update Play button state
	game_ui.play_button.disabled = selected_cards.size() == 0

func _handle_solution_card_selection(card_display: CardDisplay) -> void:
	"""
	Handle solution card selection.
	"""
	# Clear previous selections
	for card in selected_cards:
		card.select(false)
	selected_cards.clear()

	# Select this card
	card_display.select(true)
	selected_cards.append(card_display)

	# Update Play button state
	game_ui.play_button.disabled = false

func _on_play_button_pressed() -> void:
	"""
	Handle play button pressed.
	"""
	if selected_cards.size() == 0:
		return

	var player = game_manager.players[active_player_id]
	var success = false

	if solution_mode:
		# Playing a solution card
		var card_index = player.hand.find(selected_cards[0].card_data)
		success = game_manager.play_solution_card(active_player_id, card_index)

		if success:
			# Switch to problem mode
			solution_mode = false
			_update_ui_mode()
	else:
		# Playing problem card(s)
		var card_indices = []
		for card_display in selected_cards:
			card_indices.append(player.hand.find(card_display.card_data))

		if card_indices.size() == 1:
			success = game_manager.play_problem_card(active_player_id, card_indices[0])
		else:
			success = game_manager.play_multiple_problem_cards(active_player_id, card_indices)

	if success:
		# Update UI
		_update_player_hands()
		_update_problem_display()
		_clear_selections()
	else:
		game_ui.show_message("Invalid play!")

func _on_skip_button_pressed() -> void:
	"""
	Handle skip button pressed.
	"""
	if not solution_mode:
		# Cannot skip playing a problem card
		game_ui.show_message("You must play a problem card!")
		return

	# Skip to problem mode if allowed
	var player = game_manager.players[active_player_id]

	# Check if player has a valid solution
	var has_valid_solution = false
	for card in player.hand:
		if card.card_type != Card.CardType.PROBLEM:
			var solution_card = card as SolutionCard
			if card_manager.is_valid_solution(solution_card):
				has_valid_solution = true
				break

	if has_valid_solution:
		game_ui.show_message("You have a valid solution card!")
		return

	# Player has no valid solution, allow skip
	solution_mode = false
	_update_ui_mode()
	_clear_selections()
	game_ui.show_message("No valid solution cards. Play a problem card.")

func _on_declare_button_pressed() -> void:
	"""
	Handle declare button pressed.
	"""
	var player = game_manager.players[active_player_id]

	if player.count_problem_cards() > 0:
		game_ui.show_message("You still have problem cards left!")
		return

	if game_manager.declare_potential_checkmate(active_player_id):
		game_ui.show_message("CHECKMATE declared for next turn!")
	else:
		game_ui.show_message("Failed to declare CHECKMATE!")

func _on_menu_button_pressed() -> void:
	"""
	Handle menu button pressed.
	"""
	# Show confirmation dialog
	game_ui.show_confirm_menu()

func _on_card_played(player_id: int, card: Card) -> void:
	"""
	Handle card played event.
	"""
	# Update problem display if it's a problem card
	if card and card.card_type == Card.CardType.PROBLEM:
		_update_problem_display()

func _on_invalid_play(player_id: int, reason: String) -> void:
	"""
	Handle invalid play event.
	"""
	game_ui.show_message(reason)

## UI Update Methods

func _update_problem_display() -> void:
	"""
	Update the current problem card display.
	"""
	# Clear existing display
	for child in current_problem_display.get_children():
		child.queue_free()

	# Create new card display
	if card_manager.current_problem_card:
		var card_display = card_display_scene.instantiate()
		current_problem_display.add_child(card_display)
		card_display.set_card(card_manager.current_problem_card)
		card_display.set_selectable(false)

func _update_player_hands() -> void:
	print("Updating player hands")
	for i in range(game_manager.players.size()):
		var player = game_manager.players[i]
		var hand_container = player_containers[i].get_node("HandContainer")

		print("Player %d has %d cards in hand" % [i, player.hand.size()])

		# Clear existing cards
		for child in hand_container.get_children():
			child.queue_free()

		# Add cards
		for card in player.hand:
			print("Adding card: %s" % card.card_name)
			var card_display = card_display_scene.instantiate()
			hand_container.add_child(card_display)
			card_display.set_card(card)

			# Only make cards selectable for active player
			card_display.set_selectable(i == active_player_id)

			# Connect signal for active player's cards
			if i == active_player_id:
				card_display.connect("card_clicked", _on_card_clicked)

func _update_turn_indicator() -> void:
	"""
	Update the turn indicator to show whose turn it is.
	"""
	turn_indicator.text = "Player %d's Turn" % (active_player_id + 1)

func _update_ui_mode() -> void:
	"""
	Update UI based on current mode (solution or problem).
	"""
	var mode_text = "Play Solution" if solution_mode else "Play Problem"
	game_ui.set_mode_text(mode_text)

	# Skip button is only available in solution mode
	game_ui.skip_button.disabled = !solution_mode

	# Declare button is only available if player has no problem cards
	var player = game_manager.players[active_player_id]
	game_ui.declare_button.disabled = player.count_problem_cards() > 0

func _clear_selections() -> void:
	"""
	Clear all selected cards.
	"""
	for card in selected_cards:
		card.select(false)
	selected_cards.clear()

	# Disable play button
	game_ui.play_button.disabled = true
