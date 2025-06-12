# demos/hand/hand_demo.gd
extends Control

"""
Polished hand management demo scene for the PLAN Card Game.
Showcases the complete hand management system with professional presentation.
Ready for Ecocykle meeting demonstration.
"""

# UI Components
@onready var hand_display: Control
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
var is_demo_active: bool = false
var cards_added_count: int = 0

# Card database reference
var card_database: Node

enum DistributionType {
	BALANCED = 1,
	PROBLEM_HEAVY = 2,
	SOLUTION_HEAVY = 3
}

func _ready() -> void:
	"""
	Initialize the demo scene.
	"""
	print("Hand Management Demo: Starting...")

	# Get card database reference
	card_database = get_node("/root/CardDatabase")
	if not card_database:
		push_error("CardDatabase not found! Make sure it's set as an autoload.")
		return

	# Set up the scene for 1280x720 resolution
	_setup_presentation_layout()
	_create_hand_display_component()
	_connect_control_signals()
	_initialize_demo_state()

	print("Hand Management Demo: Ready for presentation!")

func _setup_presentation_layout() -> void:
	"""
	Set up the main UI layout optimized for 1280x720 presentation.
	"""
	# Set window size for demo
	custom_minimum_size = Vector2(1280, 720)
	size = Vector2(1280, 720)

	# Create main layout
	var main_layout = VBoxContainer.new()
	main_layout.name = "MainLayout"
	main_layout.anchors_preset = Control.PRESET_FULL_RECT
	main_layout.add_theme_constant_override("separation", 10)
	add_child(main_layout)

	# Create title section
	_create_title_section(main_layout)

	# Create controls panel (top)
	_create_control_panel(main_layout)

	# Create main content area
	var content_layout = HBoxContainer.new()
	content_layout.name = "ContentArea"
	content_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_layout.add_theme_constant_override("separation", 20)
	main_layout.add_child(content_layout)

	# Create hand display area (center)
	_create_hand_display_area(content_layout)

	# Create info panel (right)
	_create_information_panel(content_layout)

func _create_title_section(parent: Control) -> void:
	"""
	Create the title section.
	"""
	var title_container = _create_styled_panel(Color(0.1, 0.1, 0.15))
	parent.add_child(title_container)

	var title_margin = _create_margin_container(20, 15)
	title_container.add_child(title_margin)

	var title_layout = HBoxContainer.new()
	title_margin.add_child(title_layout)

	title_label = Label.new()
	title_label.text = "PLAN Card Game - Hand Management System Demo"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_layout.add_child(title_label)

func _create_control_panel(parent: Control) -> void:
	"""
	Create the control buttons panel.
	"""
	controls_panel = _create_styled_panel(Color(0.15, 0.15, 0.2))
	parent.add_child(controls_panel)

	var controls_margin = _create_margin_container(15, 10)
	controls_panel.add_child(controls_margin)

	var controls_layout = HBoxContainer.new()
	controls_layout.add_theme_constant_override("separation", 15)
	controls_margin.add_child(controls_layout)

	_create_card_action_section(controls_layout)
	_add_separator(controls_layout)
	_create_fan_style_section(controls_layout)
	_add_separator(controls_layout)
	_create_spread_control_section(controls_layout)
	_add_separator(controls_layout)
	_create_distribution_section(controls_layout)

func _create_card_action_section(parent: Control) -> void:
	"""
	Create card action controls section.
	"""
	var section = _create_control_section("Card Actions")
	parent.add_child(section)

	var button_layout = HBoxContainer.new()
	button_layout.add_theme_constant_override("separation", 8)
	section.add_child(button_layout)

	add_card_btn = _create_action_button("Add Card", Vector2(100, 35))
	remove_selected_btn = _create_action_button("Remove Selected", Vector2(120, 35))
	shuffle_hand_btn = _create_action_button("Shuffle Hand", Vector2(100, 35))
	clear_hand_btn = _create_action_button("Clear Hand", Vector2(90, 35))

	remove_selected_btn.disabled = true
	shuffle_hand_btn.disabled = true
	clear_hand_btn.disabled = true

	button_layout.add_child(add_card_btn)
	button_layout.add_child(remove_selected_btn)
	button_layout.add_child(shuffle_hand_btn)
	button_layout.add_child(clear_hand_btn)

func _create_fan_style_section(parent: Control) -> void:
	"""
	Create fan style controls section.
	"""
	var section = _create_control_section("Fan Style")
	parent.add_child(section)

	var button_layout = HBoxContainer.new()
	button_layout.add_theme_constant_override("separation", 8)
	section.add_child(button_layout)

	symmetric_btn = _create_toggle_button("Symmetric", Vector2(90, 35), true)
	asymmetric_btn = _create_toggle_button("Asymmetric", Vector2(90, 35), false)

	button_layout.add_child(symmetric_btn)
	button_layout.add_child(asymmetric_btn)

func _create_spread_control_section(parent: Control) -> void:
	"""
	Create spread control section.
	"""
	var section = VBoxContainer.new()
	parent.add_child(section)

	spread_value_label = Label.new()
	spread_value_label.text = "Spread: 90°"
	spread_value_label.add_theme_font_size_override("font_size", 14)
	spread_value_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	section.add_child(spread_value_label)

	spread_slider = HSlider.new()
	spread_slider.min_value = 30
	spread_slider.max_value = 150
	spread_slider.step = 5
	spread_slider.value = 90
	spread_slider.custom_minimum_size = Vector2(120, 35)
	section.add_child(spread_slider)

func _create_distribution_section(parent: Control) -> void:
	"""
	Create card distribution controls section.
	"""
	var section = _create_control_section("Card Distribution")
	parent.add_child(section)

	var button_layout = HBoxContainer.new()
	button_layout.add_theme_constant_override("separation", 6)
	section.add_child(button_layout)

	balanced_btn = _create_toggle_button("Balanced", Vector2(70, 35), true)
	problem_heavy_btn = _create_toggle_button("Problems", Vector2(70, 35), false)
	solution_heavy_btn = _create_toggle_button("Solutions", Vector2(70, 35), false)

	button_layout.add_child(balanced_btn)
	button_layout.add_child(problem_heavy_btn)
	button_layout.add_child(solution_heavy_btn)

func _create_hand_display_area(parent: Control) -> void:
	"""
	Create the main hand display area.
	"""
	var hand_container = _create_styled_panel(Color(0.05, 0.1, 0.05))
	hand_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var border_style = hand_container.get_theme_stylebox("panel")
	border_style.border_width_left = 2
	border_style.border_width_right = 2
	border_style.border_width_top = 2
	border_style.border_width_bottom = 2
	border_style.border_color = Color(0.2, 0.4, 0.2)

	parent.add_child(hand_container)

	var hand_margin = _create_margin_container(20, 20)
	hand_container.add_child(hand_margin)

	# Create the HandDisplay component
	hand_display = preload("res://scripts/classes/hand_display.gd").new()
	hand_display.name = "HandDisplay"
	hand_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hand_margin.add_child(hand_display)

func _create_information_panel(parent: Control) -> void:
	"""
	Create the information panel.
	"""
	info_panel = _create_styled_panel(Color(0.1, 0.1, 0.15))
	info_panel.custom_minimum_size = Vector2(250, 0)
	parent.add_child(info_panel)

	var info_margin = _create_margin_container(15, 15)
	info_panel.add_child(info_margin)

	var info_layout = VBoxContainer.new()
	info_layout.add_theme_constant_override("separation", 10)
	info_margin.add_child(info_layout)

	_create_info_header(info_layout)
	_create_status_labels(info_layout)
	_create_instructions_section(info_layout)

func _create_info_header(parent: Control) -> void:
	"""
	Create information panel header.
	"""
	var header = Label.new()
	header.text = "Hand Information"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", Color.WHITE)
	parent.add_child(header)

	parent.add_child(HSeparator.new())

func _create_status_labels(parent: Control) -> void:
	"""
	Create status display labels.
	"""
	card_count_label = Label.new()
	card_count_label.text = "Cards in Hand: 0"
	card_count_label.add_theme_font_size_override("font_size", 14)
	card_count_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	parent.add_child(card_count_label)

	selection_info_label = Label.new()
	selection_info_label.text = "Selected: None"
	selection_info_label.add_theme_font_size_override("font_size", 14)
	selection_info_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	selection_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(selection_info_label)

func _create_instructions_section(parent: Control) -> void:
	"""
	Create instructions display section.
	"""
	var instructions_header = Label.new()
	instructions_header.text = "Instructions"
	instructions_header.add_theme_font_size_override("font_size", 16)
	instructions_header.add_theme_color_override("font_color", Color.WHITE)
	parent.add_child(instructions_header)

	var instructions = Label.new()
	instructions.text = "• Click 'Add Card' to add random cards\n• Click cards to select them\n• Use 'Remove Selected' to remove cards\n• Try different fan styles and spreads\n• 'Shuffle Hand' rearranges cards"
	instructions.add_theme_font_size_override("font_size", 12)
	instructions.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(instructions)

func _create_hand_display_component() -> void:
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
	var initial_cards = _generate_cards_for_distribution(6, DistributionType.BALANCED)

	# Check if hand_display has a load_cards method
	if hand_display.has_method("load_cards"):
		hand_display.load_cards(initial_cards)
	else:
		print("HandDisplay: No load_cards method found, attempting alternative setup")
		_add_cards_individually(initial_cards)

	print("Hand Management Demo: Initial cards loaded")

func _generate_cards_for_distribution(count: int, distribution: DistributionType) -> Array[Card]:
	"""
	Get random cards based on distribution type.

	Args:
		count: Number of cards to get
		distribution: Distribution type (BALANCED, PROBLEM_HEAVY, SOLUTION_HEAVY)

	Returns:
		Array of random cards
	"""
	var cards: Array[Card] = []

	match distribution:
		DistributionType.BALANCED:
			cards = _get_balanced_card_selection(count)
		DistributionType.PROBLEM_HEAVY:
			cards = _get_problem_heavy_selection(count)
		DistributionType.SOLUTION_HEAVY:
			cards = _get_solution_heavy_selection(count)

	cards.shuffle()
	return cards

func _get_balanced_card_selection(count: int) -> Array[Card]:
	"""
	Get balanced distribution of all card types.
	"""
	var all_cards: Array[Card] = []
	all_cards.append_array(card_database.get_cards_by_type(Card.CardType.PROBLEM))
	all_cards.append_array(card_database.get_cards_by_type(Card.CardType.SOLUTION))
	all_cards.append_array(card_database.get_cards_by_type(Card.CardType.ULTIMATE))

	all_cards.shuffle()
	return all_cards.slice(0, min(count, all_cards.size()))

func _get_problem_heavy_selection(count: int) -> Array[Card]:
	"""
	Get problem-heavy card distribution (70% problems).
	"""
	var cards: Array[Card] = []
	var problem_cards = card_database.get_cards_by_type(Card.CardType.PROBLEM)
	var solution_cards = card_database.get_cards_by_type(Card.CardType.SOLUTION)

	problem_cards.shuffle()
	solution_cards.shuffle()

	var problem_count = int(count * 0.7)
	var solution_count = count - problem_count

	cards.append_array(problem_cards.slice(0, min(problem_count, problem_cards.size())))
	cards.append_array(solution_cards.slice(0, min(solution_count, solution_cards.size())))

	return cards

func _get_solution_heavy_selection(count: int) -> Array[Card]:
	"""
	Get solution-heavy card distribution (60% solutions/ultimate).
	"""
	var cards: Array[Card] = []
	var problem_cards = card_database.get_cards_by_type(Card.CardType.PROBLEM)
	var solution_cards = card_database.get_cards_by_type(Card.CardType.SOLUTION)
	var ultimate_cards = card_database.get_cards_by_type(Card.CardType.ULTIMATE)

	problem_cards.shuffle()
	solution_cards.shuffle()
	ultimate_cards.shuffle()

	var solution_count = int(count * 0.6)
	var problem_count = count - solution_count

	cards.append_array(problem_cards.slice(0, min(problem_count, problem_cards.size())))
	cards.append_array(solution_cards.slice(0, min(solution_count - 1, solution_cards.size())))

	if ultimate_cards.size() > 0:
		cards.append(ultimate_cards[0])

	return cards

func _add_cards_individually(cards: Array[Card]) -> void:
	"""
	Add cards one by one if bulk loading is not available.
	"""
	for card in cards:
		if hand_display.has_method("add_card"):
			hand_display.add_card(card)
		else:
			print("HandDisplay: No add_card method found either")
			break

func _connect_control_signals() -> void:
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
		_connect_hand_display_signals()

func _connect_hand_display_signals() -> void:
	"""
	Connect hand display specific signals if available.
	"""
	var signals_to_connect = [
		["cards_changed", _on_cards_changed],
		["card_selected", _on_card_selected],
		["card_deselected", _on_card_deselected]
	]

	for signal_data in signals_to_connect:
		var signal_name = signal_data[0]
		var callback = signal_data[1]

		if hand_display.has_signal(signal_name):
			hand_display.connect(signal_name, callback)

func _initialize_demo_state() -> void:
	"""
	Set up initial demo state.
	"""
	is_demo_active = true
	_refresh_ui_state()

# Signal handlers
func _on_add_card_pressed() -> void:
	"""Handle add card button press."""
	if not hand_display:
		return

	# Determine distribution based on active button
	var distribution = _get_current_distribution_type()
	var new_cards = _generate_cards_for_distribution(1, distribution)

	if new_cards.size() > 0:
		if hand_display.has_method("add_card"):
			hand_display.add_card(new_cards[0])
			cards_added_count += 1
			print("Demo: Added card #%d - %s" % [cards_added_count, new_cards[0].card_name])
		else:
			print("Demo: HandDisplay does not have add_card method")

func _on_remove_selected_pressed() -> void:
	"""Handle remove selected button press."""
	if not hand_display:
		return

	if hand_display.has_method("remove_selected_cards"):
		var removed_count = hand_display.remove_selected_cards()
		print("Demo: Removed %d selected cards" % removed_count)
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
		cards_added_count = 0
		print("Demo: Hand cleared")
	else:
		print("Demo: HandDisplay does not have clear_hand method")

func _on_symmetric_toggled(pressed: bool) -> void:
	"""Handle symmetric fan style toggle."""
	if pressed and hand_display:
		asymmetric_btn.button_pressed = false
		if hand_display.has_method("set_fan_style"):
			hand_display.set_fan_style(0)
			print("Demo: Fan style set to symmetric")
		else:
			print("Demo: HandDisplay does not have set_fan_style method")

func _on_asymmetric_toggled(pressed: bool) -> void:
	"""Handle asymmetric fan style toggle."""
	if pressed and hand_display:
		symmetric_btn.button_pressed = false
		if hand_display.has_method("set_fan_style"):
			hand_display.set_fan_style(1)
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
	_refresh_ui_state()

func _on_card_selected(card: Card, card_visual: Control) -> void:
	"""Handle card selection event."""
	_refresh_selection_info()

func _on_card_deselected(card: Card, card_visual: Control) -> void:
	"""Handle card deselection event."""
	_refresh_selection_info()

# Utility functions
func _get_current_distribution_type() -> DistributionType:
	"""
	Get currently selected distribution type from UI buttons.
	"""
	if problem_heavy_btn.button_pressed:
		return DistributionType.PROBLEM_HEAVY
	elif solution_heavy_btn.button_pressed:
		return DistributionType.SOLUTION_HEAVY
	else:
		return DistributionType.BALANCED

func _refresh_ui_state() -> void:
	"""Update UI button states based on current hand state."""
	if not hand_display:
		return

	var card_count = _get_card_count()
	var has_selection = _has_selected_cards()
	var has_cards = card_count > 0

	# Update button states
	shuffle_hand_btn.disabled = not has_cards
	clear_hand_btn.disabled = not has_cards
	remove_selected_btn.disabled = not has_selection

	# Update card count
	card_count_label.text = "Cards in Hand: %d" % card_count

func _refresh_selection_info() -> void:
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

func _get_card_count() -> int:
	"""
	Get current card count safely.
	"""
	if hand_display and hand_display.has_method("get_card_count"):
		return hand_display.get_card_count()
	return 0

func _has_selected_cards() -> bool:
	"""
	Check if any cards are currently selected.
	"""
	if hand_display and hand_display.has_method("get_selected_cards"):
		return hand_display.get_selected_cards().size() > 0
	return false

# Helper functions for UI creation
func _create_styled_panel(bg_color: Color) -> PanelContainer:
	"""
	Create a panel with consistent styling.
	"""
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _create_margin_container(horizontal: int, vertical: int) -> MarginContainer:
	"""
	Create a margin container with consistent spacing.
	"""
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", horizontal)
	margin.add_theme_constant_override("margin_right", horizontal)
	margin.add_theme_constant_override("margin_top", vertical)
	margin.add_theme_constant_override("margin_bottom", vertical)
	return margin

func _create_control_section(title: String) -> VBoxContainer:
	"""
	Create a labeled control section.
	"""
	var section = VBoxContainer.new()
	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	section.add_child(label)
	return section

func _create_action_button(text: String, size: Vector2) -> Button:
	"""
	Create a consistently styled action button.
	"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = size
	return button

func _create_toggle_button(text: String, size: Vector2, pressed: bool) -> Button:
	"""
	Create a consistently styled toggle button.
	"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = size
	button.toggle_mode = true
	button.button_pressed = pressed
	return button

func _add_separator(parent: Control) -> void:
	"""
	Add a vertical separator to layout.
	"""
	parent.add_child(VSeparator.new())

func _to_string() -> String:
	"""Debug representation."""
	return "[HandDemo: %s, %d cards]" % ["Active" if is_demo_active else "Inactive", cards_added_count]
