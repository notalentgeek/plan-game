# Quick PLAN Game Demo Scene
# File: demos/stakeholder/stakeholder_demo.gd
extends Node2D

"""
Stakeholder-ready demo showcasing PLAN Card Game core functionality.
Demonstrates card management, problem-solution matching, and educational content.
"""

# Demo state
var demo_hand: HandDisplay
var current_problem_card: Card = null
var demo_cards: Array[Card] = []

# UI Elements
var title_label: Label
var instruction_label: Label
var problem_area: PanelContainer
var problem_display: CardVisual
var hand_area: Control
var status_label: Label
var next_button: Button

func _ready() -> void:
	"""Initialize the stakeholder demo with sample cards and UI."""
	_create_demo_ui()
	_load_demo_cards()
	_setup_initial_state()

func _create_demo_ui() -> void:
	"""Create a clean, professional demo interface."""
	# Main layout
	var main_vbox = VBoxContainer.new()
	add_child(main_vbox)

	# Title
	title_label = Label.new()
	title_label.text = "PLAN: Play, Learn, and Act Now! - Digital Demo"
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title_label)

	# Instruction area
	instruction_label = Label.new()
	instruction_label.text = "Environmental Education Card Game - Select a solution card to solve the problem"
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
	main_vbox.add_child(instruction_label)

	# Problem display area
	var problem_section = VBoxContainer.new()
	main_vbox.add_child(problem_section)

	var problem_title = Label.new()
	problem_title.text = "Current Environmental Problem:"
	problem_title.add_theme_font_size_override("font_size", 18)
	problem_section.add_child(problem_title)

	problem_area = PanelContainer.new()
	problem_area.custom_minimum_size = Vector2(300, 200)
	problem_section.add_child(problem_area)

	# Hand display area
	var hand_section = VBoxContainer.new()
	main_vbox.add_child(hand_section)

	var hand_title = Label.new()
	hand_title.text = "Your Solution Cards (click to play):"
	hand_title.add_theme_font_size_override("font_size", 18)
	hand_section.add_child(hand_title)

	hand_area = Control.new()
	hand_area.custom_minimum_size = Vector2(800, 250)
	hand_section.add_child(hand_area)

	# Status and controls
	status_label = Label.new()
	status_label.text = "Ready to demonstrate environmental problem-solving!"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(status_label)

	next_button = Button.new()
	next_button.text = "Next Problem"
	next_button.pressed.connect(_next_problem)
	main_vbox.add_child(next_button)

func _load_demo_cards() -> void:
	"""Load sample cards for demonstration."""
	# Get sample cards from database
	var db = CardDatabase

	# Sample problem card (Climate Change)
	current_problem_card = db.get_problem_card_by_id("p_climate_change")
	if not current_problem_card:
		# Create fallback if database doesn't have it
		current_problem_card = ProblemCard.new(
			"p_climate_change",
			"Climate Change",
			"Rising global temperatures causing extreme weather, sea level rise, and ecosystem disruption.",
			"",
			"A",
			9
		)

	# Sample solution cards for hand
	demo_cards = [
		db.get_solution_card_by_id("s_renewable_energy"),
		db.get_solution_card_by_id("s_energy_efficiency"),
		db.get_solution_card_by_id("s_sustainable_transport"),
		db.get_ultimate_card_by_id("u_environmental_education")
	]

	# Create fallback cards if database doesn't have them
	for i in range(demo_cards.size()):
		if not demo_cards[i]:
			match i:
				0:
					demo_cards[i] = SolutionCard.new(
						"s_renewable_energy",
						"Renewable Energy",
						"Solar, wind, and hydroelectric power to reduce carbon emissions.",
						"",
						["A", "D"],
						false
					)
				1:
					demo_cards[i] = SolutionCard.new(
						"s_energy_efficiency",
						"Energy Efficiency",
						"Improving building insulation and efficient appliances.",
						"",
						["A", "F"],
						false
					)
				2:
					demo_cards[i] = SolutionCard.new(
						"s_sustainable_transport",
						"Sustainable Transport",
						"Electric vehicles and public transportation systems.",
						"",
						["A", "B"],
						false
					)
				3:
					demo_cards[i] = SolutionCard.new(
						"u_environmental_education",
						"Environmental Education",
						"Teaching people about environmental issues and solutions.",
						"",
						[],
						true
					)

func _setup_initial_state() -> void:
	"""Setup the initial demo state with problem and hand."""
	# Display current problem
	_display_problem_card()

	# Setup hand display
	demo_hand = HandDisplay.new()
	hand_area.add_child(demo_hand)

	# Add cards to hand
	for card in demo_cards:
		demo_hand.add_card(card)

	# Create visual display of hand
	_create_hand_visuals()

func _display_problem_card() -> void:
	"""Display the current problem card."""
	problem_display = CardVisual.new()
	problem_area.add_child(problem_display)
	problem_display.initialize(current_problem_card)
	problem_display.flip_to_front()

func _create_hand_visuals() -> void:
	"""Create visual representation of cards in hand."""
	var positions = demo_hand._calculate_fan_positions()

	for i in range(demo_cards.size()):
		var card_visual = CardVisual.new()
		hand_area.add_child(card_visual)
		card_visual.initialize(demo_cards[i])
		card_visual.flip_to_front()

		# Position according to fan layout
		if i < positions.size():
			card_visual.position = positions[i]

		# Connect click signal
		card_visual.card_clicked.connect(_on_card_played.bind(demo_cards[i]))

func _on_card_played(card: Card) -> void:
	"""Handle when a solution card is played."""
	if not card is SolutionCard:
		return

	var solution = card as SolutionCard
	var can_solve = false

	# Check if this solution can solve the current problem
	if current_problem_card is ProblemCard:
		var problem = current_problem_card as ProblemCard
		can_solve = solution.can_solve_problem(problem.letter_code)

	if can_solve:
		status_label.text = "✅ Excellent! '%s' is a valid solution for %s" % [solution.card_name, current_problem_card.card_name]
		status_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
		_show_educational_message(solution, current_problem_card)
	else:
		status_label.text = "❌ '%s' cannot solve this specific problem. Try another solution!" % solution.card_name
		status_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))

func _show_educational_message(solution: SolutionCard, problem: Card) -> void:
	"""Display educational information about the solution."""
	instruction_label.text = "Great choice! %s helps address %s by: %s" % [
		solution.card_name,
		problem.card_name,
		solution.description
	]

func _next_problem() -> void:
	"""Move to the next environmental problem for demonstration."""
	# Cycle through different problems
	var problems = [
		["p_deforestation", "Deforestation", "Clearing of forests for agriculture and development, reducing carbon absorption.", "C", 8],
		["p_plastic_pollution", "Plastic Pollution", "Accumulation of plastic waste in oceans and ecosystems.", "B", 7],
		["p_air_pollution", "Air Pollution", "Contamination of air with harmful substances affecting health.", "A", 8]
	]

	var problem_data = problems[randi() % problems.size()]
	current_problem_card = ProblemCard.new(
		problem_data[0],
		problem_data[1],
		problem_data[2],
		"",
		problem_data[3],
		problem_data[4]
	)

	# Clear and redisplay
	if problem_display:
		problem_display.queue_free()
	_display_problem_card()

	status_label.text = "New environmental challenge! Find the right solution."
	status_label.add_theme_color_override("font_color", Color.WHITE)
	instruction_label.text = "Environmental Education Card Game - Select a solution card to solve the problem"
