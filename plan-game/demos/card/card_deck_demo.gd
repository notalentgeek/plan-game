extends Node2D

"""
A demo scene for testing the card and deck systems in the PLAN card game.
Allows developers to create sample cards, build decks, and test interactions.
"""

# UI Components
var card_display_area: GridContainer
var deck_info_label: Label
var test_deck: Deck = null
var card_info_panel: PanelContainer
var card_info_name: Label
var card_info_type: Label
var card_info_description: Label
var card_info_details: Label

# Card display constants
const CARD_SPACING = 10
const MAX_CARDS_PER_ROW = 4

# Reference to selected card for drag operations
var selected_card_visual: CardVisual = null
var drag_start_position: Vector2 = Vector2.ZERO
var last_selected_card: Card = null

func _ready() -> void:
	"""
	Initialize the demo scene and set up the UI components.
	"""
	print("Starting card deck demo")

	# Ensure the card database is initialized
	var card_db = get_node_or_null("/root/CardDatabase")
	if card_db == null:
		print("CardDatabase singleton not found, attempting to create it")

		# Check if CardDatabase is already registered as an autoload
		if Engine.has_singleton("CardDatabase"):
			print("CardDatabase registered as singleton but not found in tree")
			# This shouldn't happen normally, but just in case
			await get_tree().process_frame
			card_db = get_node_or_null("/root/CardDatabase")
		else:
			# If not an autoload, we need to create it manually
			var card_db_script = load("res://scripts/autoload/card_database.gd")
			if card_db_script:
				card_db = card_db_script.new()
				card_db.name = "CardDatabase"
				# Use call_deferred to avoid "parent node is busy" error
				get_tree().root.call_deferred("add_child", card_db)
				print("CardDatabase singleton created manually")

				# Make sure cards are initialized
				if card_db.has_method("initialize_cards"):
					card_db.initialize_cards()
					print("CardDatabase cards initialized")
			else:
				push_error("Failed to create CardDatabase singleton")
	else:
		print("CardDatabase singleton found")

	# Make sure card database cards are initialized
	if card_db and card_db.has_method("initialize_cards"):
		if not card_db._cards_initialized:
			# We need to wait until CardDatabase is properly initialized
			# if we added it with call_deferred
			await get_tree().process_frame

			# Get the reference again in case it changed
			card_db = get_node_or_null("/root/CardDatabase")
			if card_db and card_db.has_method("initialize_cards"):
				if not card_db._cards_initialized:
					card_db.initialize_cards()
					print("CardDatabase cards initialized")

	_setup_ui()
	_connect_signals()

	# Start with an empty deck
	test_deck = Deck.new()
	_update_deck_info()
	_update_card_info(null) # No card selected initially

	# Seed the random number generator
	randomize()

	print("Card deck demo initialized")

func _setup_ui() -> void:
	"""
	Create and organize the UI components for the demo scene.
	"""
	# Get viewport size for positioning
	var viewport_size = get_viewport_rect().size

	# Create main container that fills the viewport
	var ui_root = Control.new()
	ui_root.name = "UIRoot"
	ui_root.size = viewport_size
	add_child(ui_root)

	var main_vbox = VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.anchor_right = 1.0
	main_vbox.anchor_bottom = 1.0
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ui_root.add_child(main_vbox)

	# Title
	var title_label = Label.new()
	title_label.text = "PLAN Card Game - Deck Testing Demo"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	main_vbox.add_child(title_label)

	# Control Panel
	var control_panel = _create_control_panel()
	main_vbox.add_child(control_panel)

	# Deck Information
	deck_info_label = Label.new()
	deck_info_label.text = "No deck created yet"
	deck_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(deck_info_label)

	# Main content area: Split into display and info panel
	var content_hsplit = HSplitContainer.new()
	content_hsplit.name = "ContentSplit"
	content_hsplit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_hsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hsplit.split_offset = 200 # Adjust as needed
	main_vbox.add_child(content_hsplit)

	# Card Display Area
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hsplit.add_child(scroll_container)

	card_display_area = GridContainer.new()
	card_display_area.name = "CardDisplayArea"
	card_display_area.columns = MAX_CARDS_PER_ROW
	card_display_area.add_theme_constant_override("h_separation", CARD_SPACING)
	card_display_area.add_theme_constant_override("v_separation", CARD_SPACING)
	card_display_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(card_display_area)

	# Card Information Panel
	card_info_panel = PanelContainer.new()
	card_info_panel.name = "CardInfoPanel"
	card_info_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_info_panel.custom_minimum_size = Vector2(300, 0) # Minimum width
	var info_margin = MarginContainer.new()
	info_margin.add_theme_constant_override("margin_left", 10)
	info_margin.add_theme_constant_override("margin_right", 10)
	info_margin.add_theme_constant_override("margin_top", 10)
	info_margin.add_theme_constant_override("margin_bottom", 10)
	card_info_panel.add_child(info_margin)

	var info_vbox = VBoxContainer.new()
	info_margin.add_child(info_vbox)

	var info_title = Label.new()
	info_title.text = "Card Information"
	info_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_title.add_theme_font_size_override("font_size", 18)
	info_vbox.add_child(info_title)

	var separator = HSeparator.new()
	info_vbox.add_child(separator)

	card_info_name = Label.new()
	card_info_name.text = "No Card Selected"
	card_info_name.add_theme_font_size_override("font_size", 16)
	card_info_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(card_info_name)

	card_info_type = Label.new()
	card_info_type.text = ""
	info_vbox.add_child(card_info_type)

	var desc_label = Label.new()
	desc_label.text = "Description:"
	desc_label.add_theme_font_size_override("font_size", 14)
	info_vbox.add_child(desc_label)

	card_info_description = Label.new()
	card_info_description.text = ""
	card_info_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_info_description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info_vbox.add_child(card_info_description)

	card_info_details = Label.new()
	card_info_details.text = ""
	card_info_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(card_info_details)

	content_hsplit.add_child(card_info_panel)

	# Add instructions label
	var instructions = Label.new()
	instructions.text = "Click cards to select them, drag to move them. Use buttons above to create cards and decks."
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(instructions)

func _create_control_panel() -> Control:
	"""
	Create a panel with buttons to control the test functionality.
	"""
	var panel = PanelContainer.new()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var hbox = HBoxContainer.new()
	margin.add_child(hbox)

	# Card Creation Section
	var card_creation_vbox = VBoxContainer.new()
	var card_creation_label = Label.new()
	card_creation_label.text = "Card Creation"
	card_creation_vbox.add_child(card_creation_label)

	var add_problem_btn = Button.new()
	add_problem_btn.text = "Add Problem Card"
	add_problem_btn.name = "AddProblemBtn"
	card_creation_vbox.add_child(add_problem_btn)

	var add_solution_btn = Button.new()
	add_solution_btn.text = "Add Solution Card"
	add_solution_btn.name = "AddSolutionBtn"
	card_creation_vbox.add_child(add_solution_btn)

	var add_ultimate_btn = Button.new()
	add_ultimate_btn.text = "Add Ultimate Card"
	add_ultimate_btn.name = "AddUltimateBtn"
	card_creation_vbox.add_child(add_ultimate_btn)

	hbox.add_child(card_creation_vbox)

	# Separator
	var separator = VSeparator.new()
	hbox.add_child(separator)

	# Deck Operations Section
	var deck_operations_vbox = VBoxContainer.new()
	var deck_operations_label = Label.new()
	deck_operations_label.text = "Deck Operations"
	deck_operations_vbox.add_child(deck_operations_label)

	var create_deck_btn = Button.new()
	create_deck_btn.text = "Create Test Deck"
	create_deck_btn.name = "CreateDeckBtn"
	deck_operations_vbox.add_child(create_deck_btn)

	var problem_deck_btn = Button.new()
	problem_deck_btn.text = "Create Problem Deck"
	problem_deck_btn.name = "ProblemDeckBtn"
	deck_operations_vbox.add_child(problem_deck_btn)

	var solution_deck_btn = Button.new()
	solution_deck_btn.text = "Create Solution Deck"
	solution_deck_btn.name = "SolutionDeckBtn"
	deck_operations_vbox.add_child(solution_deck_btn)

	hbox.add_child(deck_operations_vbox)

	# Separator
	separator = VSeparator.new()
	hbox.add_child(separator)

	# Card Actions Section
	var card_actions_vbox = VBoxContainer.new()
	var card_actions_label = Label.new()
	card_actions_label.text = "Card Actions"
	card_actions_vbox.add_child(card_actions_label)

	var draw_card_btn = Button.new()
	draw_card_btn.text = "Draw Card"
	draw_card_btn.name = "DrawCardBtn"
	card_actions_vbox.add_child(draw_card_btn)

	var shuffle_deck_btn = Button.new()
	shuffle_deck_btn.text = "Shuffle Deck"
	shuffle_deck_btn.name = "ShuffleDeckBtn"
	card_actions_vbox.add_child(shuffle_deck_btn)

	var clear_display_btn = Button.new()
	clear_display_btn.text = "Clear Display"
	clear_display_btn.name = "ClearDisplayBtn"
	card_actions_vbox.add_child(clear_display_btn)

	hbox.add_child(card_actions_vbox)

	return panel

func _connect_signals() -> void:
	"""
	Connect UI signals to their respective handler functions.
	"""
	# Store references to buttons for easier access
	var add_problem_btn = find_child("AddProblemBtn", true, false)
	var add_solution_btn = find_child("AddSolutionBtn", true, false)
	var add_ultimate_btn = find_child("AddUltimateBtn", true, false)
	var create_deck_btn = find_child("CreateDeckBtn", true, false)
	var problem_deck_btn = find_child("ProblemDeckBtn", true, false)
	var solution_deck_btn = find_child("SolutionDeckBtn", true, false)
	var draw_card_btn = find_child("DrawCardBtn", true, false)
	var shuffle_deck_btn = find_child("ShuffleDeckBtn", true, false)
	var clear_display_btn = find_child("ClearDisplayBtn", true, false)

	# Card Creation
	if add_problem_btn:
		add_problem_btn.pressed.connect(Callable(self, "_on_add_problem_pressed"))
	if add_solution_btn:
		add_solution_btn.pressed.connect(Callable(self, "_on_add_solution_pressed"))
	if add_ultimate_btn:
		add_ultimate_btn.pressed.connect(Callable(self, "_on_add_ultimate_pressed"))

	# Deck Operations
	if create_deck_btn:
		create_deck_btn.pressed.connect(Callable(self, "_on_create_deck_pressed"))
	if problem_deck_btn:
		problem_deck_btn.pressed.connect(Callable(self, "_on_problem_deck_pressed"))
	if solution_deck_btn:
		solution_deck_btn.pressed.connect(Callable(self, "_on_solution_deck_pressed"))

	# Card Actions
	if draw_card_btn:
		draw_card_btn.pressed.connect(Callable(self, "_on_draw_card_pressed"))
	if shuffle_deck_btn:
		shuffle_deck_btn.pressed.connect(Callable(self, "_on_shuffle_deck_pressed"))
	if clear_display_btn:
		clear_display_btn.pressed.connect(Callable(self, "_on_clear_display_pressed"))

# ----- Card Creation Handlers -----
func _on_add_problem_pressed() -> void:
	"""
	Add a random problem card to the display area.
	"""
	# Get a reference to the CardDatabase singleton
	var card_db = get_node_or_null("/root/CardDatabase")
	if card_db == null:
		push_error("CardDatabase singleton not found. Cannot add problem card.")
		return

	# Get a random problem card from the database
	var problem_cards = card_db.get_all_problem_cards()
	if problem_cards == null or problem_cards.size() == 0:
		push_error("No problem cards found in the database")
		return

	var random_index = randi() % problem_cards.size()
	var problem_card = problem_cards[random_index]

	# Create a visual for the card and add it to the display
	_add_card_to_display(problem_card)

func _on_add_solution_pressed() -> void:
	"""
	Add a random solution card to the display area.
	"""
	# Get a reference to the CardDatabase singleton
	var card_db = get_node_or_null("/root/CardDatabase")
	if card_db == null:
		push_error("CardDatabase singleton not found. Cannot add solution card.")
		return

	# Get a random solution card from the database (non-ultimate)
	var solution_cards = card_db.get_all_solution_cards()
	if solution_cards == null or solution_cards.size() == 0:
		push_error("No solution cards found in the database")
		return

	var regular_solution_cards = []
	for card in solution_cards:
		if not card.is_ultimate:
			regular_solution_cards.append(card)

	if regular_solution_cards.size() == 0:
		push_error("No regular solution cards found in the database")
		return

	var random_index = randi() % regular_solution_cards.size()
	var solution_card = regular_solution_cards[random_index]

	# Create a visual for the card and add it to the display
	_add_card_to_display(solution_card)

func _on_add_ultimate_pressed() -> void:
	"""
	Add a random ultimate solution card to the display area.
	"""
	# Get a reference to the CardDatabase singleton
	var card_db = get_node_or_null("/root/CardDatabase")
	if card_db == null:
		push_error("CardDatabase singleton not found. Cannot add ultimate card.")
		return

	# Get a random ultimate card from the database
	var ultimate_cards = card_db.get_ultimate_solution_cards()
	if ultimate_cards == null or ultimate_cards.size() == 0:
		push_error("No ultimate cards found in the database")
		return

	var random_index = randi() % ultimate_cards.size()
	var ultimate_card = ultimate_cards[random_index]

	# Create a visual for the card and add it to the display
	_add_card_to_display(ultimate_card)

# ----- Deck Operation Handlers -----
func _on_create_deck_pressed() -> void:
	"""
	Create a new test deck with a balanced mix of problem and solution cards.
	"""
	# Get a reference to the CardDatabase singleton
	var card_db = get_node_or_null("/root/CardDatabase")
	if card_db == null:
		push_error("CardDatabase singleton not found. Cannot create test deck.")
		return

	test_deck = Deck.new()

	# Add a balanced mix of problem and solution cards
	var problem_cards = card_db.get_all_problem_cards()
	var solution_cards = card_db.get_all_solution_cards()

	if problem_cards == null or problem_cards.size() == 0:
		push_error("No problem cards found in the database")
	else:
		# Add 5 random problem cards (or all if less than 5)
		var num_problems = min(5, problem_cards.size())
		problem_cards.shuffle()
		for i in range(num_problems):
			test_deck.add_card(problem_cards[i])

	if solution_cards == null or solution_cards.size() == 0:
		push_error("No solution cards found in the database")
	else:
		# Add 5 random solution cards (or all if less than 5)
		var num_solutions = min(5, solution_cards.size())
		solution_cards.shuffle()
		for i in range(num_solutions):
			test_deck.add_card(solution_cards[i])

		# Ensure we include at least one ultimate card if available
		var ultimate_cards = card_db.get_ultimate_solution_cards()
		if ultimate_cards != null and ultimate_cards.size() > 0:
			test_deck.add_card(ultimate_cards[0])

	# Shuffle the final deck
	test_deck.shuffle()
	_update_deck_info()
	print("Created a mixed test deck with ", test_deck.size(), " cards")

func _on_problem_deck_pressed() -> void:
	"""
	Create a new deck filled with all problem cards.
	"""
	# Get a reference to the CardDatabase singleton
	var card_db = get_node_or_null("/root/CardDatabase")
	if card_db == null:
		push_error("CardDatabase singleton not found. Cannot create problem deck.")
		return

	test_deck = card_db.create_problem_deck()
	if test_deck == null:
		push_error("Failed to create problem deck")
		return

	test_deck.shuffle()
	_update_deck_info()
	print("Created a problem deck with ", test_deck.size(), " cards")

func _on_solution_deck_pressed() -> void:
	"""
	Create a new deck filled with all solution cards.
	"""
	# Get a reference to the CardDatabase singleton
	var card_db = get_node_or_null("/root/CardDatabase")
	if card_db == null:
		push_error("CardDatabase singleton not found. Cannot create solution deck.")
		return

	test_deck = card_db.create_solution_deck()
	if test_deck == null:
		push_error("Failed to create solution deck")
		return

	test_deck.shuffle()
	_update_deck_info()
	print("Created a solution deck with ", test_deck.size(), " cards")

# ----- Card Action Handlers -----
func _on_draw_card_pressed() -> void:
	"""
	Draw a card from the test deck and add it to the display.
	"""
	if test_deck == null or test_deck.is_empty():
		print("Cannot draw from an empty deck")
		return

	var card = test_deck.draw_card()
	if card:
		_add_card_to_display(card)
		_update_deck_info()
		print("Drew a card: ", card.card_name)

func _on_shuffle_deck_pressed() -> void:
	"""
	Shuffle the test deck.
	"""
	if test_deck:
		test_deck.shuffle()
		print("Shuffled the deck")

func _on_clear_display_pressed() -> void:
	"""
	Clear all cards from the display area.
	"""
	for child in card_display_area.get_children():
		child.queue_free()
	print("Cleared the display area")
	_update_card_info(null)

# ----- Helper Functions -----
func _add_card_to_display(card: Card) -> void:
	"""
	Create a visual representation of a card and add it to the display area.
	"""
	var card_visual = CardVisual.new()
	card_visual.initialize(card)
	card_visual.flip_to_front() # Show the front by default

	# Connect card signals
	card_visual.card_clicked.connect(Callable(self, "_on_card_clicked"))
	card_visual.card_hover_started.connect(Callable(self, "_on_card_hover_started"))
	card_visual.card_hover_ended.connect(Callable(self, "_on_card_hover_ended"))

	card_display_area.add_child(card_visual)

func _update_deck_info() -> void:
	"""
	Update the deck information display.
	"""
	if test_deck:
		deck_info_label.text = "Deck: " + str(test_deck.size()) + " cards"
	else:
		deck_info_label.text = "No deck available"

func _update_card_info(card: Card) -> void:
	"""
	Update the card information panel with details of the selected card.
	"""
	if card == null:
		card_info_name.text = "No Card Selected"
		card_info_type.text = ""
		card_info_description.text = ""
		card_info_details.text = ""
		return

	card_info_name.text = card.card_name
	card_info_description.text = card.description

	# Update type information
	match card.card_type:
		Card.CardType.PROBLEM:
			card_info_type.text = "Type: Problem Card"
			if card is ProblemCard:
				var problem_card = card as ProblemCard
				card_info_details.text = "Problem Code: " + problem_card.letter_code + "\nSeverity: " + str(problem_card.severity_index) + "/10"

		Card.CardType.SOLUTION:
			if card is SolutionCard and (card as SolutionCard).is_ultimate:
				card_info_type.text = "Type: Ultimate Solution Card"
				card_info_details.text = "This card can solve any problem!"
			else:
				card_info_type.text = "Type: Solution Card"
				if card is SolutionCard:
					var solution_card = card as SolutionCard
					var problems_text = "Solves Problems: "
					for i in range(solution_card.solvable_problems.size()):
						problems_text += solution_card.solvable_problems[i]
						if i < solution_card.solvable_problems.size() - 1:
							problems_text += ", "
					card_info_details.text = problems_text

		Card.CardType.ULTIMATE:
			card_info_type.text = "Type: Ultimate Solution Card"
			card_info_details.text = "This card can solve any problem!"

# ----- Card Interaction Handlers -----
func _on_card_clicked(card: Card) -> void:
	"""
	Handle card click events.
	"""
	print("Card clicked: ", card.card_name)

	# Update card info panel
	_update_card_info(card)
	last_selected_card = card

	# Find the CardVisual instance for this card
	for child in card_display_area.get_children():
		if child is CardVisual and child.card == card:
			# Toggle selection state
			if child.current_state == CardVisual.VisualState.SELECTED:
				child.set_visual_state(CardVisual.VisualState.DEFAULT)
			else:
				# Deselect all other cards first
				for other_child in card_display_area.get_children():
					if other_child is CardVisual and other_child != child:
						other_child.set_visual_state(CardVisual.VisualState.DEFAULT)
				child.set_visual_state(CardVisual.VisualState.SELECTED)
			break

func _on_card_hover_started(card: Card) -> void:
	"""
	Handle when mouse enters a card area.
	"""
	print("Card hover started: ", card.card_name)

func _on_card_hover_ended(card: Card) -> void:
	"""
	Handle when mouse exits a card area.
	"""
	print("Card hover ended: ", card.card_name)

func _process(_delta: float) -> void:
	"""
	Process function used for card dragging.
	"""
	if selected_card_visual and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		selected_card_visual.global_position = mouse_pos - drag_start_position

func _input(event: InputEvent) -> void:
	"""
	Handle input events for card dragging.
	"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Potential drag start - check if we clicked on a card
				_try_select_card_at_position(event.global_position)
			else:
				# Drag end
				if selected_card_visual:
					# Return card to grid or handle drop logic here
					selected_card_visual = null

func _try_select_card_at_position(global_pos: Vector2) -> void:
	"""
	Attempt to select a card at the given position.
	"""
	for child in card_display_area.get_children():
		if child is CardVisual:
			var card_global_pos = child.global_position
			var card_size = child.size
			var card_rect = Rect2(card_global_pos, card_size)

			if card_rect.has_point(global_pos):
				selected_card_visual = child
				# Calculate offset so card doesn't jump to cursor center
				drag_start_position = global_pos - card_global_pos
				# Bring selected card to front by moving it to the end of the children list
				card_display_area.move_child(child, card_display_area.get_child_count() - 1)
				return
