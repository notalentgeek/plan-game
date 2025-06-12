# demos/hand/hand_animation_demo.gd
extends Control

"""
HandDisplay Animation Demo for Ecocykle Presentation

This demo showcases the HandDisplay functionality with real card data
from the CardDatabase, demonstrating smooth animations and interactions
suitable for educational presentation to stakeholders.

Features:
- Real HandDisplay class integration
- CardDatabase integration for authentic card data
- Visual card animations and fan layout
- Interactive controls for all HandDisplay methods
- Method call logging for technical demonstration
- Professional UI suitable for stakeholder presentation
"""

# UI Components
@onready var hand_display: HandDisplay = $VBoxContainer/HandDisplay
@onready var method_log: RichTextLabel = $VBoxContainer/MethodPanel/MethodLog
@onready var stats_panel: Control = $VBoxContainer/StatsPanel
@onready var total_cards_label: Label = $VBoxContainer/StatsPanel/StatsGrid/TotalStat/Value
@onready var problem_cards_label: Label = $VBoxContainer/StatsPanel/StatsGrid/ProblemStat/Value
@onready var solution_cards_label: Label = $VBoxContainer/StatsPanel/StatsGrid/SolutionStat/Value
@onready var ultimate_cards_label: Label = $VBoxContainer/StatsPanel/StatsGrid/UltimateStat/Value

# Demo state
var card_visuals: Array[CardVisual] = []
var selected_card_index: int = -1
var max_log_entries: int = 15
var animation_stagger_delay: float = 0.1

func _ready() -> void:
	"""
	Initialize the demo scene with proper setup.
	"""
	print("=== PLAN Card Game - HandDisplay Animation Demo ===")

	# Verify CardDatabase is available
	if not CardDatabase:
		push_error("CardDatabase singleton not found!")
		return

	# Initialize HandDisplay
	_initialize_demo()

	# Connect button signals
	_connect_button_signals()

	# Update initial display
	_update_display()
	_update_statistics()

	# Log startup
	_log_method_call("Demo initialized", "Ready for interaction")

	print("Demo ready - HandDisplay with CardDatabase integration")

func _initialize_demo() -> void:
	"""
	Configure the HandDisplay component for the demo.
	"""
	# Ensure HandDisplay is properly sized and positioned
	hand_display.size = Vector2(800, 300)
	hand_display.position = Vector2(100, 200)

	# Set up visual styling
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.2, 0.3)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1.0, 1.0, 1.0, 0.5)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10

	hand_display.add_theme_stylebox_override("panel", panel_style)

func _connect_button_signals() -> void:
	"""
	Connect all demo button signals to their respective methods.
	"""
	# Get button references and connect signals
	var buttons = {
		"AddProblemBtn": _add_random_problem_card,
		"AddSolutionBtn": _add_random_solution_card,
		"AddUltimateBtn": _add_random_ultimate_card,
		"AddNullBtn": _test_null_card_addition,
		"AddDuplicateBtn": _test_duplicate_card_addition,
		"RemoveCardBtn": _remove_random_card,
		"RemoveInvalidBtn": _test_invalid_card_removal,
		"ClearHandBtn": _clear_all_cards
	}

	for button_name in buttons:
		var button = $VBoxContainer/ControlsPanel/ControlsGrid.get_node(button_name)
		button.pressed.connect(buttons[button_name])

# Button signal handlers matching your HandDisplay methods

func _add_random_problem_card() -> void:
	"""Test add_card() with a random ProblemCard from CardDatabase."""
	var problem_cards = CardDatabase.get_all_problem_cards()
	if problem_cards.size() == 0:
		_log_method_call("add_card(problem)", "No problem cards available", true)
		return

	var random_card = problem_cards[randi() % problem_cards.size()]
	var result = hand_display.add_card(random_card)

	_log_method_call("hand_display.add_card(ProblemCard: \"%s\")" % random_card.card_name, str(result))
	_update_display()
	_update_statistics()

func _add_random_solution_card() -> void:
	"""Test add_card() with a random SolutionCard from CardDatabase."""
	var solution_cards = CardDatabase.get_all_solution_cards()
	if solution_cards.size() == 0:
		_log_method_call("add_card(solution)", "No solution cards available", true)
		return

	var random_card = solution_cards[randi() % solution_cards.size()]
	var result = hand_display.add_card(random_card)

	_log_method_call("hand_display.add_card(SolutionCard: \"%s\")" % random_card.card_name, str(result))
	_update_display()
	_update_statistics()

func _add_random_ultimate_card() -> void:
	"""Test add_card() with an UltimateCard from CardDatabase."""
	var ultimate_cards = CardDatabase.get_all_ultimate_cards()
	if ultimate_cards.size() == 0:
		_log_method_call("add_card(ultimate)", "No ultimate cards available", true)
		return

	var random_card = ultimate_cards[randi() % ultimate_cards.size()]
	var result = hand_display.add_card(random_card)

	_log_method_call("hand_display.add_card(UltimateCard: \"%s\")" % random_card.card_name, str(result))
	_update_display()
	_update_statistics()

func _test_null_card_addition() -> void:
	"""Test add_card() with null parameter - should return false."""
	var result = hand_display.add_card(null)
	_log_method_call("hand_display.add_card(null)", str(result), true)
	_update_display()
	_update_statistics()

func _test_duplicate_card_addition() -> void:
	"""Test add_card() with duplicate card - should return false."""
	if hand_display.get_card_count() == 0:
		_log_method_call("add_card(duplicate)", "No cards to duplicate", true)
		return

	var existing_card = hand_display.cards[0]
	var result = hand_display.add_card(existing_card)
	_log_method_call("hand_display.add_card(duplicate: \"%s\")" % existing_card.card_name, str(result), true)
	_update_display()
	_update_statistics()

func _remove_random_card() -> void:
	"""Test remove_card() with valid or invalid index."""
	var card_count = hand_display.get_card_count()

	if card_count == 0:
		var result = hand_display.remove_card(0)
		_log_method_call("hand_display.remove_card(0) // empty hand", str(result), true)
		return

	var index = randi() % card_count
	var card_name = hand_display.cards[index].card_name
	var result = hand_display.remove_card(index)

	_log_method_call("hand_display.remove_card(%d) // \"%s\"" % [index, card_name], str(result))
	_update_display()
	_update_statistics()

func _test_invalid_card_removal() -> void:
	"""Test remove_card() with invalid index - should return false."""
	var result = hand_display.remove_card(-1)
	_log_method_call("hand_display.remove_card(-1)", str(result), true)
	_update_display()
	_update_statistics()

func _clear_all_cards() -> void:
	"""Test clear_hand() method."""
	hand_display.clear_hand()
	_log_method_call("hand_display.clear_hand()", "void")
	_update_display()
	_update_statistics()

# Visual display management

func _update_display() -> void:
	"""
	Update the visual representation of cards in the hand.
	Creates CardVisual instances and arranges them in a fan layout.
	"""
	# Clear existing card visuals
	_clear_existing_visuals()

	# Create new CardVisual instances for each card
	for i in range(hand_display.get_card_count()):
		var card = hand_display.cards[i]
		var card_visual = _create_single_card_visual(card, i)
		card_visuals.append(card_visual)
		hand_display.add_child(card_visual)

	# Arrange cards in fan layout
	_arrange_cards_in_fan()

func _clear_existing_visuals() -> void:
	"""
	Remove all existing CardVisual instances.
	"""
	for card_visual in card_visuals:
		if is_instance_valid(card_visual):
			card_visual.queue_free()
	card_visuals.clear()

func _create_single_card_visual(card: Card, index: int) -> CardVisual:
	"""
	Create a CardVisual instance for the given card.
	"""
	var card_visual = CardVisual.new()
	card_visual.initialize(card)

	# Connect signals for interaction
	card_visual.card_clicked.connect(_on_card_clicked)
	card_visual.card_hover_started.connect(_on_card_hover_started)
	card_visual.card_hover_ended.connect(_on_card_hover_ended)

	return card_visual

func _arrange_cards_in_fan() -> void:
	"""
	Arrange card visuals in an elegant fan layout with animations.
	"""
	var card_count = card_visuals.size()
	if card_count == 0:
		return

	# Calculate fan layout parameters
	var hand_center = hand_display.size / 2
	var fan_width = min(600, card_count * 60)
	var fan_radius = 200

	for i in range(card_count):
		var card_visual = card_visuals[i]

		# Calculate position and rotation for fan effect
		var position_data = _calculate_fan_position(i, card_count, hand_center, fan_radius)
		_animate_card_to_position(card_visual, position_data.position, position_data.rotation, i * animation_stagger_delay)

func _calculate_fan_position(index: int, total: int, center: Vector2, radius: float) -> Dictionary:
	"""
	Calculate position and rotation for a card in the fan layout.
	"""
	var angle_step = PI / 6 # 30 degree fan
	var start_angle = -angle_step / 2
	var angle = start_angle + (angle_step / max(1, total - 1)) * index

	var fan_x = center.x + sin(angle) * radius * 0.3
	var fan_y = center.y - cos(angle) * radius * 0.1

	# Apply position and rotation with animation
	var target_position = Vector2(fan_x - 60, fan_y - 90) # Center card visual
	var target_rotation = angle * 0.5 # Subtle rotation

	return {
		"position": target_position,
		"rotation": target_rotation
	}

func _animate_card_to_position(card_visual: CardVisual, target_pos: Vector2, target_rot: float, delay: float) -> void:
	"""
	Animate a card to its target position with smooth easing.
	"""
	# Create tween for smooth animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# Add delay for staggered animation effect
	if delay > 0:
		tween.tween_delay(delay)

	# Animate position and rotation simultaneously
	tween.parallel().tween_property(card_visual, "position", target_pos, 0.6)
	tween.parallel().tween_property(card_visual, "rotation", target_rot, 0.6)

	# Add slight scale animation for polish
	card_visual.scale = Vector2(0.8, 0.8)
	tween.parallel().tween_property(card_visual, "scale", Vector2(1.0, 1.0), 0.4)

func _update_statistics() -> void:
	"""
	Update the statistics display with current hand information.
	"""
	var total = hand_display.get_card_count()
	var counts = _count_cards_by_type()

	total_cards_label.text = str(total)
	problem_cards_label.text = str(counts.problems)
	solution_cards_label.text = str(counts.solutions)
	ultimate_cards_label.text = str(counts.ultimates)

func _count_cards_by_type() -> Dictionary:
	"""
	Count cards by type for statistics display.
	"""
	var counts = {"problems": 0, "solutions": 0, "ultimates": 0}

	for card in hand_display.cards:
		match card.card_type:
			Card.CardType.PROBLEM:
				counts.problems += 1
			Card.CardType.SOLUTION:
				counts.solutions += 1
			Card.CardType.ULTIMATE:
				counts.ultimates += 1

	return counts

func _log_method_call(method_call: String, result: String, is_error: bool = false) -> void:
	"""
	Log method calls and results to the method log display.
	"""
	var color = "green" if not is_error else "red"
	var log_entry = "[color=%s]%s → %s[/color]\n" % [color, method_call, result]

	method_log.append_text(log_entry)

	# Keep log manageable - limit to last 15 entries
	_trim_log_entries()

func _trim_log_entries() -> void:
	"""
	Trim log entries to maintain manageable display size.
	"""
	var lines = method_log.get_parsed_text().split("\n")
	if lines.size() > max_log_entries:
		method_log.clear()
		for i in range(max(0, lines.size() - max_log_entries), lines.size()):
			if lines[i].strip_edges() != "":
				method_log.append_text(lines[i] + "\n")

# Card interaction handlers

func _on_card_clicked(card: Card) -> void:
	"""
	Handle card click events.
	"""
	print("Card clicked: %s" % card.card_name)

func _on_card_hover_started(card: Card) -> void:
	"""
	Handle card hover start events.
	"""
	pass # Visual feedback already handled by CardVisual

func _on_card_hover_ended(card: Card) -> void:
	"""
	Handle card hover end events.
	"""
	pass # Visual feedback already handled by CardVisual
