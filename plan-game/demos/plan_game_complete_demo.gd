# demos/plan_game_complete_demo.gd
extends Node2D
"""
Complete PLAN Card Game Demo
Implements core rules from the official rulebook:
- Players must play solution cards to solve problems
- After playing a solution, player must play a new problem
- Game continues until a player runs out of problem cards
- Includes proper turn flow and validation
"""

# Game State
enum GamePhase {
	WAITING_FOR_SOLUTION,  # A problem is on the table, need solution
	WAITING_FOR_PROBLEM,   # No problem on table, need to play one
	GAME_OVER             # Someone achieved CHECKMATE
}

var current_phase: GamePhase = GamePhase.WAITING_FOR_PROBLEM
var table_problem: Card = null
var players: Array[Dictionary] = []  # Each player has: name, cards, score
var current_player_index: int = 0
var game_round: int = 1

# Visual Components
var table_visual: CardVisual = null
var player_hand_visuals: Array[CardVisual] = []
var ui_container: Control
var info_label: RichTextLabel
var phase_label: Label
var player_label: Label
var message_label: Label
var message_timer: Timer

# Layout Constants
const TABLE_POSITION := Vector2(640, 250)
const HAND_Y_POSITION := 500
const CARD_SPACING := 110
const CARD_SCALE := 0.6

func _ready() -> void:
	print("Starting PLAN Card Game Complete Demo")
	_setup_ui()
	_setup_game()
	_start_new_round()

func _setup_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 1)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	# UI Container
	ui_container = Control.new()
	add_child(ui_container)

	# Game Info Panel
	var info_panel = Panel.new()
	info_panel.size = Vector2(350, 200)
	info_panel.position = Vector2(20, 20)
	ui_container.add_child(info_panel)

	info_label = RichTextLabel.new()
	info_label.size = Vector2(330, 180)
	info_label.position = Vector2(10, 10)
	info_label.add_theme_font_size_override("font_size", 14)
	info_panel.add_child(info_label)

	# Phase Indicator
	phase_label = Label.new()
	phase_label.position = Vector2(640, 100)
	phase_label.add_theme_font_size_override("font_size", 24)
	phase_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	phase_label.anchor_left = 0.5
	ui_container.add_child(phase_label)

	# Current Player
	player_label = Label.new()
	player_label.position = Vector2(640, 140)
	player_label.add_theme_font_size_override("font_size", 20)
	player_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	player_label.anchor_left = 0.5
	ui_container.add_child(player_label)

	# Message Display
	message_label = Label.new()
	message_label.position = Vector2(640, 400)
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	message_label.anchor_left = 0.5
	message_label.modulate.a = 0
	ui_container.add_child(message_label)

	# Message Timer
	message_timer = Timer.new()
	message_timer.one_shot = true
	message_timer.timeout.connect(_hide_message)
	add_child(message_timer)

	# Instructions
	var instructions = Label.new()
	instructions.text = "Click cards to play them | R: New Round | N: Next Turn | ESC: Quit"
	instructions.position = Vector2(20, 680)
	instructions.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	ui_container.add_child(instructions)

	# Table Label
	var table_label = Label.new()
	table_label.text = "Table"
	table_label.position = TABLE_POSITION + Vector2(-30, -120)
	table_label.add_theme_font_size_override("font_size", 16)
	table_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	ui_container.add_child(table_label)

func _setup_game() -> void:
	# Create 2 players for demo
	players.clear()
	players.append({
		"name": "Player 1",
		"cards": [],
		"score": 0
	})
	players.append({
		"name": "Player 2",
		"cards": [],
		"score": 0
	})

func _start_new_round() -> void:
	print("Starting Round %d" % game_round)

	# Clear table
	table_problem = null
	if table_visual:
		table_visual.queue_free()
		table_visual = null

	# Deal cards to players
	for player in players:
		player.cards.clear()
		_deal_cards_to_player(player)

	# Start with first player
	current_player_index = 0
	current_phase = GamePhase.WAITING_FOR_PROBLEM

	_update_display()
	_show_message("Round %d Started! %s begins." % [game_round, players[current_player_index].name])

func _deal_cards_to_player(player: Dictionary) -> void:
	# Give each player 3 problem cards and 2 solution cards
	var cards = []

	# Problem cards
	var problem_letters = ["A", "B", "C", "D", "F", "G", "H", "I"]
	problem_letters.shuffle()

	for i in range(3):
		var letter = problem_letters[i]
		cards.append(ProblemCard.new(
			"p_%s" % letter.to_lower(),
			_get_problem_name(letter),
			"Environmental problem %s" % letter,
			"",
			letter,
			randi() % 5 + 5  # Severity 5-9
		))

	# Solution cards
	var solution_types = [
		{"name": "Clean Up", "solves": ["A", "B", "N", "O", "P", "Q"]},
		{"name": "Renewable Energy", "solves": ["D", "G", "H", "L"]},
		{"name": "Afforestation", "solves": ["C", "F", "G", "I", "K", "M"]},
		{"name": "Awareness Campaign", "solves": ["A", "C", "E", "J", "K"]},
		{"name": "Policy Change", "solves": ["B", "D", "E", "H", "M", "N"]}
	]
	solution_types.shuffle()

	for i in range(2):
		var sol = solution_types[i]
		var solves: Array[String] = []
		solves.assign(sol.solves)
		cards.append(SolutionCard.new(
			"s_%d" % i,
			sol.name,
			"Solution that addresses multiple problems",
			"",
			solves,
			false
		))

	player.cards = cards

func _get_problem_name(letter: String) -> String:
	var names = {
		"A": "Air Pollution",
		"B": "Oil Spill",
		"C": "Deforestation",
		"D": "Gas Flaring",
		"F": "Desertification",
		"G": "Drought",
		"H": "Flooding",
		"I": "Soil Erosion"
	}
	return names.get(letter, "Environmental Issue")

func _update_display() -> void:
	# Clear existing hand visuals
	for visual in player_hand_visuals:
		visual.queue_free()
	player_hand_visuals.clear()

	# Update table card
	if table_problem and not table_visual:
		table_visual = CardVisual.new()
		table_visual.initialize(table_problem)
		table_visual.position = TABLE_POSITION
		table_visual.scale = Vector2(CARD_SCALE, CARD_SCALE)
		table_visual.flip_to_front()
		add_child(table_visual)
	elif not table_problem and table_visual:
		table_visual.queue_free()
		table_visual = null

	# Show current player's hand
	var current_player = players[current_player_index]
	var card_count = current_player.cards.size()

	if card_count > 0:
		var total_width = (card_count - 1) * CARD_SPACING
		var start_x = 640 - total_width / 2

		for i in range(card_count):
			var card = current_player.cards[i]
			var visual = CardVisual.new()
			visual.initialize(card)
			visual.position = Vector2(start_x + i * CARD_SPACING, HAND_Y_POSITION)
			visual.scale = Vector2(CARD_SCALE, CARD_SCALE)
			visual.flip_to_front()

			# Make clickable
			visual.set_meta("hand_index", i)
			visual.gui_input.connect(_on_card_clicked.bind(visual))

			# Highlight playable cards
			if _can_play_card(card):
				visual.modulate = Color(1.2, 1.2, 1.2)
			else:
				visual.modulate = Color(0.7, 0.7, 0.7)

			add_child(visual)
			player_hand_visuals.append(visual)

	# Update UI
	_update_ui_labels()

func _can_play_card(card: Card) -> bool:
	if current_phase == GamePhase.WAITING_FOR_SOLUTION:
		if card is SolutionCard:
			var solution = card as SolutionCard
			return solution.can_solve_problem(table_problem.letter_code) if table_problem else false
		return false
	elif current_phase == GamePhase.WAITING_FOR_PROBLEM:
		return card is ProblemCard
	return false

func _update_ui_labels() -> void:
	# Phase label
	if current_phase == GamePhase.WAITING_FOR_SOLUTION:
		phase_label.text = "Play a Solution Card"
	elif current_phase == GamePhase.WAITING_FOR_PROBLEM:
		phase_label.text = "Play a Problem Card"
	else:
		phase_label.text = "Game Over!"

	# Player label
	var current_player = players[current_player_index]
	player_label.text = current_player.name + "'s Turn"

	# Info panel
	var info_text = "[b]PLAN Card Game[/b]\n"
	info_text += "Round: %d\n\n" % game_round

	if table_problem:
		info_text += "[color=red]Problem on Table:[/color]\n"
		info_text += "%s (%s)\n" % [table_problem.card_name, table_problem.letter_code]
		info_text += "Severity: %d\n\n" % table_problem.severity_index
	else:
		info_text += "[color=gray]Table is empty[/color]\n\n"

	info_text += "[b]Scores:[/b]\n"
	for player in players:
		info_text += "%s: %d points\n" % [player.name, player.score]

	info_text += "\n[b]%s's Hand:[/b]\n" % current_player.name
	var problem_count = 0
	var solution_count = 0
	for card in current_player.cards:
		if card is ProblemCard:
			problem_count += 1
		else:
			solution_count += 1
	info_text += "Problems: %d, Solutions: %d" % [problem_count, solution_count]

	info_label.bbcode_text = info_text

func _on_card_clicked(event: InputEvent, visual: CardVisual) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_phase != GamePhase.GAME_OVER:
			var index = visual.get_meta("hand_index")
			_try_play_card(index)

func _try_play_card(index: int) -> void:
	var current_player = players[current_player_index]
	if index < 0 or index >= current_player.cards.size():
		return

	var card = current_player.cards[index]

	# Validate the play
	if not _can_play_card(card):
		if current_phase == GamePhase.WAITING_FOR_SOLUTION:
			if card is ProblemCard:
				_show_message("You must play a solution first!")
			else:
				_show_message("This solution doesn't solve %s!" % table_problem.letter_code)
		else:
			_show_message("You must play a problem card!")
		return

	# Make the play
	if card is SolutionCard:
		_play_solution_card(index)
	else:
		_play_problem_card(index)

func _play_solution_card(index: int) -> void:
	var current_player = players[current_player_index]
	var card = current_player.cards[index]

	_show_message("Solution played! Now play a problem.")
	current_player.cards.remove_at(index)

	# Clear table
	if table_visual:
		table_visual.queue_free()
		table_visual = null
	table_problem = null

	# Change phase
	current_phase = GamePhase.WAITING_FOR_PROBLEM
	_update_display()

func _play_problem_card(index: int) -> void:
	var current_player = players[current_player_index]
	var card = current_player.cards[index] as ProblemCard

	# Play the problem
	table_problem = card
	current_player.cards.remove_at(index)

	# Check for CHECKMATE
	var problems_left = 0
	for c in current_player.cards:
		if c is ProblemCard:
			problems_left += 1

	if problems_left == 0:
		_show_message("%s achieved CHECKMATE!" % current_player.name)
		_end_round()
	else:
		_show_message("Problem played!")
		current_phase = GamePhase.WAITING_FOR_SOLUTION
		_next_turn()

func _next_turn() -> void:
	current_player_index = (current_player_index + 1) % players.size()
	_update_display()

func _end_round() -> void:
	current_phase = GamePhase.GAME_OVER

	# Calculate scores
	var winner_index = current_player_index
	players[winner_index].score += 5  # CHECKMATE bonus

	# Count remaining problems for other players
	var problem_counts = []
	for i in range(players.size()):
		if i != winner_index:
			var count = 0
			for card in players[i].cards:
				if card is ProblemCard:
					count += 1
			problem_counts.append({"index": i, "count": count})

	# Sort by problem count (ascending)
	problem_counts.sort_custom(func(a, b): return a.count < b.count)

	# Award points
	var points = [3, 2, 1]
	for i in range(min(problem_counts.size(), points.size())):
		var player_data = problem_counts[i]
		players[player_data.index].score += points[i]

	_update_display()
	_show_message("Round Over! Press R for next round.")

func _show_message(text: String) -> void:
	message_label.text = text
	message_label.modulate.a = 1.0
	message_timer.wait_time = 3.0
	message_timer.start()

func _hide_message() -> void:
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 0.0, 0.5)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				game_round += 1
				_start_new_round()
			KEY_N:
				if current_phase != GamePhase.GAME_OVER:
					_next_turn()
					_show_message("Skipped to next player")
			KEY_ESCAPE:
				get_tree().quit()
