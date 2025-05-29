# demos/hand/hand_demo.gd
extends Control

"""
Polished hand management demo scene for the PLAN Card Game.
Showcases the complete hand management system with professional presentation.
Ready for Ecocykle meeting demonstration.
"""

# UI Components
@onready var hand_display: Control  # Changed from HandDisplay to Control
@onready var controls_panel: Control
@onready var info_panel: Control
@onready var title_label: Label
@onready var card_count_label: Label
@onready var selection_info_label: Label

# Control buttons
@onready var add_card_btn: Button
@onready var remove_selected_btn: Button
@onready var shuffle_hand_btn: Button
@onready var clear_hand_btn: Button

# Fan style controls
@onready var symmetric_btn: Button
@onready var asymmetric_btn: Button
@onready var spread_slider: HSlider
@onready var spread_value_label: Label

# Card type filter buttons
@onready var balanced_btn: Button
@onready var problem_heavy_btn: Button
@onready var solution_heavy_btn: Button

# Demo state
var demo_running: bool = false
var cards_added: int = 0

# Card database reference
var card_db: Node

func _ready() -> void:
	"""
	Initialize the demo scene.
	"""
	print("Hand Management Demo: Starting...")
	
	# Get card database reference
	card_db = get_node("/root/CardDatabase")
	if not card_db:
		push_error("CardDatabase not found! Make sure it's set as an autoload.")
		return
	
	# Set up the scene for 1280x720 resolution
	_setup_ui_layout()
	_create_hand_display()
	_connect_signals()
	_setup_demo_state()
	
	print("Hand Management Demo: Ready for presentation!")

func _setup_ui_layout() -> void:
	"""
	Set up the main UI layout optimized for 1280x720 presentation.
	"""
	# Set window size for demo
	custom_minimum_size = Vector2(1280, 720)
	size = Vector2(1280, 720)
	
	# Create main layout
	var main_vbox = VBoxContainer.new()
	main_vbox.name = "MainLayout"
	main_vbox.anchors_preset = Control.PRESET_FULL_RECT
	main_vbox.add_theme_constant_override("separation", 10)
	add_child(main_vbox)
	
	# Create title section
	_create_title_section(main_vbox)
	
	# Create controls panel (top)
	_create_controls_panel(main_vbox)
	
	# Create main content area
	var content_hbox = HBoxContainer.new()
	content_hbox.name = "ContentArea"
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 20)
	main_vbox.add_child(content_hbox)
	
	# Create hand display area (center)
	_create_hand_display_area(content_hbox)
	
	# Create info panel (right)
	_create_info_panel(content_hbox)

func _create_title_section(parent: Control) -> void:
	"""
	Create the title section.
	"""
	var title_panel = PanelContainer.new()
	title_panel.name = "TitlePanel"
	
	var title_style = StyleBoxFlat.new()
	title_style.bg_color = Color(0.1, 0.1, 0.15)
	title_style.corner_radius_top_left = 8
	title_style.corner_radius_top_right = 8
	title_style.corner_radius_bottom_left = 8
	title_style.corner_radius_bottom_right = 8
	title_panel.add_theme_stylebox_override("panel", title_style)
	
	parent.add_child(title_panel)
	
	var title_margin = MarginContainer.new()
	title_margin.add_theme_constant_override("margin_left", 20)
	title_margin.add_theme_constant_override("margin_right", 20)
	title_margin.add_theme_constant_override("margin_top", 15)
	title_margin.add_theme_constant_override("margin_bottom", 15)
	title_panel.add_child(title_margin)
	
	var title_hbox = HBoxContainer.new()
	title_margin.add_child(title_hbox)
	
	title_label = Label.new()
	title_label.text = "PLAN Card Game - Hand Management System Demo"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_hbox.add_child(title_label)

func _create_controls_panel(parent: Control) -> void:
	"""
	Create the control buttons panel.
	"""
	controls_panel = PanelContainer.new()
	controls_panel.name = "ControlsPanel"
	
	var controls_style = StyleBoxFlat.new()
	controls_style.bg_color = Color(0.15, 0.15, 0.2)
	controls_style.corner_radius_top_left = 6
	controls_style.corner_radius_top_right = 6
	controls_style.corner_radius_bottom_left = 6
	controls_style.corner_radius_bottom_right = 6
	controls_panel.add_theme_stylebox_override("panel", controls_style)
	
	parent.add_child(controls_panel)
	
	var controls_margin = MarginContainer.new()
	controls_margin.add_theme_constant_override("margin_left", 15)
	controls_margin.add_theme_constant_override("margin_right", 15)
	controls_margin.add_theme_constant_override("margin_top", 10)
	controls_margin.add_theme_constant_override("margin_bottom", 10)
	controls_panel.add_child(controls_margin)
	
	var controls_hbox = HBoxContainer.new()
	controls_hbox.add_theme_constant_override("separation", 15)
	controls_margin.add_child(controls_hbox)
	
	# Card Actions Section
	var card_actions_vbox = VBoxContainer.new()
	var card_actions_label = Label.new()
	card_actions_label.text = "Card Actions"
	card_actions_label.add_theme_font_size_override("font_size", 14)
	card_actions_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	card_actions_vbox.add_child(card_actions_label)
	
	var card_actions_hbox = HBoxContainer.new()
	card_actions_hbox.add_theme_constant_override("separation", 8)
	card_actions_vbox.add_child(card_actions_hbox)
	
	add_card_btn = Button.new()
	add_card_btn.text = "Add Card"
	add_card_btn.custom_minimum_size = Vector2(100, 35)
	card_actions_hbox.add_child(add_card_btn)
	
	remove_selected_btn = Button.new()
	remove_selected_btn.text = "Remove Selected"
	remove_selected_btn.custom_minimum_size = Vector2(120, 35)
	remove_selected_btn.disabled = true
	card_actions_hbox.add_child(remove_selected_btn)
	
	shuffle_hand_btn = Button.new()
	shuffle_hand_btn.text = "Shuffle Hand"
	shuffle_hand_btn.custom_minimum_size = Vector2(100, 35)
	shuffle_hand_btn.disabled = true
	card_actions_hbox.add_child(shuffle_hand_btn)
	
	clear_hand_btn = Button.new()
	clear_hand_btn.text = "Clear Hand"
	clear_hand_btn.custom_minimum_size = Vector2(90, 35)
	clear_hand_btn.disabled = true
	card_actions_hbox.add_child(clear_hand_btn)
	
	controls_hbox.add_child(card_actions_vbox)
	
	# Separator
	var separator1 = VSeparator.new()
	controls_hbox.add_child(separator1)
	
	# Fan Style Section
	var fan_style_vbox = VBoxContainer.new()
	var fan_style_label = Label.new()
	fan_style_label.text = "Fan Style"
	fan_style_label.add_theme_font_size_override("font_size", 14)
	fan_style_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	fan_style_vbox.add_child(fan_style_label)
	
	var fan_style_hbox = HBoxContainer.new()
	fan_style_hbox.add_theme_constant_override("separation", 8)
	fan_style_vbox.add_child(fan_style_hbox)
	
	symmetric_btn = Button.new()
	symmetric_btn.text = "Symmetric"
	symmetric_btn.custom_minimum_size = Vector2(90, 35)
	symmetric_btn.toggle_mode = true
	symmetric_btn.button_pressed = true
	fan_style_hbox.add_child(symmetric_btn)
	
	asymmetric_btn = Button.new()
	asymmetric_btn.text = "Asymmetric"
	asymmetric_btn.custom_minimum_size = Vector2(90, 35)
	asymmetric_btn.toggle_mode = true
	fan_style_hbox.add_child(asymmetric_btn)
	
	controls_hbox.add_child(fan_style_vbox)
	
	# Separator
	var separator2 = VSeparator.new()
	controls_hbox.add_child(separator2)
	
	# Spread Control Section
	var spread_vbox = VBoxContainer.new()
	spread_value_label = Label.new()
	spread_value_label.text = "Spread: 90°"
	spread_value_label.add_theme_font_size_override("font_size", 14)
	spread_value_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	spread_vbox.add_child(spread_value_label)
	
	spread_slider = HSlider.new()
	spread_slider.min_value = 30
	spread_slider.max_value = 150
	spread_slider.step = 5
	spread_slider.value = 90
	spread_slider.custom_minimum_size = Vector2(120, 35)
	spread_vbox.add_child(spread_slider)
	
	controls_hbox.add_child(spread_vbox)
	
	# Separator
	var separator3 = VSeparator.new()
	controls_hbox.add_child(separator3)
	
	# Card Distribution Section
	var distribution_vbox = VBoxContainer.new()
	var distribution_label = Label.new()
	distribution_label.text = "Card Distribution"
	distribution_label.add_theme_font_size_override("font_size", 14)
	distribution_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	distribution_vbox.add_child(distribution_label)
	
	var distribution_hbox = HBoxContainer.new()
	distribution_hbox.add_theme_constant_override("separation", 6)
	distribution_vbox.add_child(distribution_hbox)
	
	balanced_btn = Button.new()
	balanced_btn.text = "Balanced"
	balanced_btn.custom_minimum_size = Vector2(70, 35)
	balanced_btn.toggle_mode = true
	balanced_btn.button_pressed = true
	distribution_hbox.add_child(balanced_btn)
	
	problem_heavy_btn = Button.new()
	problem_heavy_btn.text = "Problems"
	problem_heavy_btn.custom_minimum_size = Vector2(70, 35)
	problem_heavy_btn.toggle_mode = true
	distribution_hbox.add_child(problem_heavy_btn)
	
	solution_heavy_btn = Button.new()
	solution_heavy_btn.text = "Solutions"
	solution_heavy_btn.custom_minimum_size = Vector2(70, 35)
	solution_heavy_btn.toggle_mode = true
	distribution_hbox.add_child(solution_heavy_btn)
	
	controls_hbox.add_child(distribution_vbox)

func _create_hand_display_area(parent: Control) -> void:
	"""
	Create the main hand display area.
	"""
	var hand_container = PanelContainer.new()
	hand_container.name = "HandContainer"
	hand_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var hand_style = StyleBoxFlat.new()
	hand_style.bg_color = Color(0.05, 0.1, 0.05)
	hand_style.corner_radius_top_left = 8
	hand_style.corner_radius_top_right = 8
	hand_style.corner_radius_bottom_left = 8
	hand_style.corner_radius_bottom_right = 8
	hand_style.border_width_left = 2
	hand_style.border_width_right = 2
	hand_style.border_width_top = 2
	hand_style.border_width_bottom = 2
	hand_style.border_color = Color(0.2, 0.4, 0.2)
	hand_container.add_theme_stylebox_override("panel", hand_style)
	
	parent.add_child(hand_container)
	
	var hand_margin = MarginContainer.new()
	hand_margin.add_theme_constant_override("margin_left", 20)
	hand_margin.add_theme_constant_override("margin_right", 20)
	hand_margin.add_theme_constant_override("margin_top", 20)
	hand_margin.add_theme_constant_override("margin_bottom", 20)
	hand_container.add_child(hand_margin)
	
	# Create the HandDisplay component
	hand_display = preload("res://scripts/classes/hand_display.gd").new()
	hand_display.name = "HandDisplay"
	hand_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hand_margin.add_child(hand_display)

func _create_info_panel(parent: Control) -> void:
	"""
	Create the information panel.
	"""
	info_panel = PanelContainer.new()
	info_panel.name = "InfoPanel"
	info_panel.custom_minimum_size = Vector2(250, 0)
	
	var info_style = StyleBoxFlat.new()
	info_style.bg_color = Color(0.1, 0.1, 0.15)
	info_style.corner_radius_top_left = 8
	info_style.corner_radius_top_right = 8
	info_style.corner_radius_bottom_left = 8
	info_style.corner_radius_bottom_right = 8
	info_panel.add_theme_stylebox_override("panel", info_style)
	
	parent.add_child(info_panel)
	
	var info_margin = MarginContainer.new()
	info_margin.add_theme_constant_override("margin_left", 15)
	info_margin.add_theme_constant_override("margin_right", 15)
	info_margin.add_theme_constant_override("margin_top", 15)
	info_margin.add_theme_constant_override("margin_bottom", 15)
	info_panel.add_child(info_margin)
	
	var info_vbox = VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 10)
	info_margin.add_child(info_vbox)
	
	# Info title
	var info_title = Label.new()
	info_title.text = "Hand Information"
	info_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_title.add_theme_font_size_override("font_size", 18)
	info_title.add_theme_color_override("font_color", Color.WHITE)
	info_vbox.add_child(info_title)
	
	var separator = HSeparator.new()
	info_vbox.add_child(separator)
	
	# Card count
	card_count_label = Label.new()
	card_count_label.text = "Cards in Hand: 0"
	card_count_label.add_theme_font_size_override("font_size", 14)
	card_count_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	info_vbox.add_child(card_count_label)
	
	# Selection info
	selection_info_label = Label.new()
	selection_info_label.text = "Selected: None"
	selection_info_label.add_theme_font_size_override("font_size", 14)
	selection_info_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	selection_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(selection_info_label)
	
	# Instructions
	var instructions_title = Label.new()
	instructions_title.text = "Instructions"
	instructions_title.add_theme_font_size_override("font_size", 16)
	instructions_title.add_theme_color_override("font_color", Color.WHITE)
	info_vbox.add_child(instructions_title)
	
	var instructions = Label.new()
	instructions.text = "• Click 'Add Card' to add random cards\n• Click cards to select them\n• Use 'Remove Selected' to remove cards\n• Try different fan styles and spreads\n• 'Shuffle Hand' rearranges cards"
	instructions.add_theme_font_size_override("font_size", 12)
	instructions.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(instructions)

func _create_hand_display() -> void:
	"""
	Initialize the hand display component.
	"""
	if not hand_display:
		push_error("HandDisplay not created")
		return
	
	# Check if hand_display has an initialize method
	if hand_display.has_method("initialize"):
		hand_display.initialize()
	else:
		print("HandDisplay: No initialize method found, using default setup")
	
	# Load initial cards for demo using the database helper method
	var initial_cards = _get_random_cards_for_distribution(6, 1)  # 6 cards, BALANCED distribution
	
	# Check if hand_display has a load_cards method
	if hand_display.has_method("load_cards"):
		hand_display.load_cards(initial_cards)
	else:
		print("HandDisplay: No load_cards method found, attempting alternative setup")
		# Try to add cards one by one if the method exists
		for card in initial_cards:
			if hand_display.has_method("add_card"):
				hand_display.add_card(card)
			else:
				print("HandDisplay: No add_card method found either")
				break
	
	print("Hand Management Demo: Initial cards loaded")

func _get_random_cards_for_distribution(count: int, distribution: int) -> Array[Card]:
	"""
	Get random cards based on distribution type.
	
	Args:
		count: Number of cards to get
		distribution: Distribution type (1=BALANCED, 2=PROBLEM_HEAVY, 3=SOLUTION_HEAVY)
	
	Returns:
		Array of random cards
	"""
	var cards: Array[Card] = []
	
	match distribution:
		1:  # BALANCED
			var problem_cards = card_db.get_cards_by_type(Card.CardType.PROBLEM)
			var solution_cards = card_db.get_cards_by_type(Card.CardType.SOLUTION)
			var ultimate_cards = card_db.get_cards_by_type(Card.CardType.ULTIMATE)
			
			var all_cards: Array[Card] = []
			all_cards.append_array(problem_cards)
			all_cards.append_array(solution_cards)
			all_cards.append_array(ultimate_cards)
			
			all_cards.shuffle()
			for i in range(min(count, all_cards.size())):
				cards.append(all_cards[i])
		
		2:  # PROBLEM_HEAVY
			var problem_cards = card_db.get_cards_by_type(Card.CardType.PROBLEM)
			var solution_cards = card_db.get_cards_by_type(Card.CardType.SOLUTION)
			
			problem_cards.shuffle()
			solution_cards.shuffle()
			
			var problem_count = int(count * 0.7)  # 70% problems
			var solution_count = count - problem_count
			
			for i in range(min(problem_count, problem_cards.size())):
				cards.append(problem_cards[i])
			for i in range(min(solution_count, solution_cards.size())):
				cards.append(solution_cards[i])
		
		3:  # SOLUTION_HEAVY
			var problem_cards = card_db.get_cards_by_type(Card.CardType.PROBLEM)
			var solution_cards = card_db.get_cards_by_type(Card.CardType.SOLUTION)
			var ultimate_cards = card_db.get_cards_by_type(Card.CardType.ULTIMATE)
			
			problem_cards.shuffle()
			solution_cards.shuffle()
			ultimate_cards.shuffle()
			
			var solution_count = int(count * 0.6)  # 60% solutions/ultimate
			var problem_count = count - solution_count
			
			for i in range(min(problem_count, problem_cards.size())):
				cards.append(problem_cards[i])
			
			var regular_solutions = min(solution_count - 1, solution_cards.size())
			for i in range(regular_solutions):
				cards.append(solution_cards[i])
			
			if ultimate_cards.size() > 0:
				cards.append(ultimate_cards[0])  # Add one ultimate card
	
	cards.shuffle()
	return cards

func _connect_signals() -> void:
	"""
	Connect UI signals and hand display events.
	"""
	# Card action buttons
	add_card_btn.pressed.connect(_on_add_card_pressed)
	remove_selected_btn.pressed.connect(_on_remove_selected_pressed)
	shuffle_hand_btn.pressed.connect(_on_shuffle_hand_pressed)
	clear_hand_btn.pressed.connect(_on_clear_hand_pressed)
	
	# Fan style buttons
	symmetric_btn.toggled.connect(_on_symmetric_toggled)
	asymmetric_btn.toggled.connect(_on_asymmetric_toggled)
	
	# Spread slider
	spread_slider.value_changed.connect(_on_spread_changed)
	
	# Distribution buttons
	balanced_btn.toggled.connect(_on_balanced_toggled)
	problem_heavy_btn.toggled.connect(_on_problem_heavy_toggled)
	solution_heavy_btn.toggled.connect(_on_solution_heavy_toggled)
	
	# Hand display signals - only connect if methods exist
	if hand_display:
		if hand_display.has_signal("cards_changed"):
			hand_display.cards_changed.connect(_on_cards_changed)
		if hand_display.has_signal("card_selected"):
			hand_display.card_selected.connect(_on_card_selected)
		if hand_display.has_signal("card_deselected"):
			hand_display.card_deselected.connect(_on_card_deselected)

func _setup_demo_state() -> void:
	"""
	Set up initial demo state.
	"""
	demo_running = true
	_update_ui_state()

# Signal handlers
func _on_add_card_pressed() -> void:
	"""Handle add card button press."""
	if not hand_display:
		return
	
	# Determine distribution based on active button
	var distribution = 1  # BALANCED
	if problem_heavy_btn.button_pressed:
		distribution = 2  # PROBLEM_HEAVY
	elif solution_heavy_btn.button_pressed:
		distribution = 3  # SOLUTION_HEAVY
	
	var new_cards = _get_random_cards_for_distribution(1, distribution)
	if new_cards.size() > 0:
		if hand_display.has_method("add_card"):
			hand_display.add_card(new_cards[0])
			cards_added += 1
			print("Demo: Added card #%d - %s" % [cards_added, new_cards[0].card_name])
		else:
			print("Demo: HandDisplay does not have add_card method")

func _on_remove_selected_pressed() -> void:
	"""Handle remove selected button press."""
	if not hand_display:
		return
	
	if hand_display.has_method("remove_selected_cards"):
		var removed = hand_display.remove_selected_cards()
		print("Demo: Removed %d selected cards" % removed)
	else:
		print("Demo: HandDisplay does not have remove_selected_cards method")

func _on_shuffle_hand_pressed() -> void:
	"""Handle shuffle hand button press."""
	if not hand_display:
		return
	
	if hand_display.has_method("shuffle_hand"):
		hand_display.shuffle_hand()
		print("Demo: Hand shuffled")
	else:
		print("Demo: HandDisplay does not have shuffle_hand method")

func _on_clear_hand_pressed() -> void:
	"""Handle clear hand button press."""
	if not hand_display:
		return
	
	if hand_display.has_method("clear_hand"):
		hand_display.clear_hand()
		cards_added = 0
		print("Demo: Hand cleared")
	else:
		print("Demo: HandDisplay does not have clear_hand method")

func _on_symmetric_toggled(pressed: bool) -> void:
	"""Handle symmetric fan style toggle."""
	if pressed and hand_display:
		asymmetric_btn.button_pressed = false
		if hand_display.has_method("set_fan_style"):
			hand_display.set_fan_style(0)  # SYMMETRIC_ARC
			print("Demo: Fan style set to symmetric")
		else:
			print("Demo: HandDisplay does not have set_fan_style method")

func _on_asymmetric_toggled(pressed: bool) -> void:
	"""Handle asymmetric fan style toggle."""
	if pressed and hand_display:
		symmetric_btn.button_pressed = false
		if hand_display.has_method("set_fan_style"):
			hand_display.set_fan_style(1)  # ASYMMETRIC_SPREAD
			print("Demo: Fan style set to asymmetric")
		else:
			print("Demo: HandDisplay does not have set_fan_style method")

func _on_spread_changed(value: float) -> void:
	"""Handle spread slider change."""
	if hand_display and hand_display.has_method("set_spread_angle"):
		hand_display.set_spread_angle(value)
		spread_value_label.text = "Spread: %d°" % int(value)
	else:
		spread_value_label.text = "Spread: %d°" % int(value)

func _on_balanced_toggled(pressed: bool) -> void:
	"""Handle balanced distribution toggle."""
	if pressed:
		problem_heavy_btn.button_pressed = false
		solution_heavy_btn.button_pressed = false

func _on_problem_heavy_toggled(pressed: bool) -> void:
	"""Handle problem-heavy distribution toggle."""
	if pressed:
		balanced_btn.button_pressed = false
		solution_heavy_btn.button_pressed = false

func _on_solution_heavy_toggled(pressed: bool) -> void:
	"""Handle solution-heavy distribution toggle."""
	if pressed:
		balanced_btn.button_pressed = false
		problem_heavy_btn.button_pressed = false

func _on_cards_changed(cards: Array[Card]) -> void:
	"""Handle cards changed event from hand display."""
	_update_ui_state()

func _on_card_selected(card: Card, card_visual: Control) -> void:
	"""Handle card selection event."""
	_update_selection_info()

func _on_card_deselected(card: Card, card_visual: Control) -> void:
	"""Handle card deselection event."""
	_update_selection_info()

func _update_ui_state() -> void:
	"""Update UI button states based on current hand state."""
	if not hand_display:
		return
	
	var card_count = 0
	var has_selection = false
	
	# Get card count safely
	if hand_display.has_method("get_card_count"):
		card_count = hand_display.get_card_count()
	
	# Get selection status safely
	if hand_display.has_method("get_selected_cards"):
		var selected_cards = hand_display.get_selected_cards()
		has_selection = selected_cards.size() > 0
	
	var has_cards = card_count > 0
	
	# Update button states
	shuffle_hand_btn.disabled = not has_cards
	clear_hand_btn.disabled = not has_cards
	remove_selected_btn.disabled = not has_selection
	
	# Update card count
	card_count_label.text = "Cards in Hand: %d" % card_count

func _update_selection_info() -> void:
	"""Update selection information display."""
	if not hand_display:
		return
	
	if hand_display.has_method("get_selected_cards"):
		var selected_cards = hand_display.get_selected_cards()
		if selected_cards.is_empty():
			selection_info_label.text = "Selected: None"
		else:
			var names: Array[String] = []
			for card in selected_cards:
				names.append(card.card_name)
			selection_info_label.text = "Selected: %s" % ", ".join(names)
	else:
		selection_info_label.text = "Selected: Unknown"

func _to_string() -> String:
	"""Debug representation."""
	return "[HandDemo: %s, %d cards]" % ["Running" if demo_running else "Stopped", cards_added]
