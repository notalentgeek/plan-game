# demos/hand/hand_positioning_demo.gd
extends Node2D

"""
Visual demonstration of HandDisplay multiple card positioning algorithm.

This demo creates multiple cards and positions them according to the
_calculate_fan_positions algorithm, showing the basic line layout
with 50px horizontal spacing.
"""

# Demo components
var hand_display: HandDisplay
var card_visuals: Array[CardVisual] = []
var info_label: Label

# Demo configuration
const DEMO_CARD_COUNT = 5
const INFO_POSITION = Vector2(50, 50)

func _ready() -> void:
	"""
	Initialize the hand positioning demo scene.
	"""
	print("Starting Hand Positioning Demo")
	_setup_demo_scene()
	_create_test_cards()
	_create_card_visuals()
	_position_cards()
	_create_info_display()
	print("Hand Positioning Demo initialized successfully")

func _setup_demo_scene() -> void:
	"""
	Set up the basic demo scene structure.
	"""
	# Create HandDisplay instance
	hand_display = HandDisplay.new()
	hand_display.name = "HandDisplay"
	add_child(hand_display)

	# Set up scene background
	var viewport_size = get_viewport_rect().size
	print("Demo viewport size: ", viewport_size)

func _create_test_cards() -> void:
	"""
	Create test cards and add them to the hand display.
	"""
	print("Creating %d test cards" % DEMO_CARD_COUNT)

	# Create mix of problem and solution cards for visual variety
	for i in range(DEMO_CARD_COUNT):
		var card: Card

		if i % 2 == 0:
			# Create problem card
			card = ProblemCard.new(
				"demo_problem_%d" % i,
				"Problem Card %d" % (i + 1),
				"This is test problem card number %d for positioning demo." % (i + 1),
				"", # No texture path
				String.chr(65 + i), # A, B, C, D, E...
				i + 1 # Severity
			)
		else:
			# Create solution card
			card = SolutionCard.new(
				"demo_solution_%d" % i,
				"Solution Card %d" % (i + 1),
				"This is test solution card number %d for positioning demo." % (i + 1),
				"", # No texture path
				[String.chr(65 + i)], # Solves corresponding problem letter
				false # Not ultimate
			)

		# Add card to hand display
		var add_result = hand_display.add_card(card)
		if add_result:
			print("Added card %d: %s" % [i + 1, card.card_name])
		else:
			print("Failed to add card %d" % (i + 1))

func _create_card_visuals() -> void:
	"""
	Create CardVisual instances for each card in the hand.
	"""
	print("Creating card visuals")

	# Clear any existing visuals
	for visual in card_visuals:
		if visual and is_instance_valid(visual):
			visual.queue_free()
	card_visuals.clear()

	# Create visual for each card
	for i in range(hand_display.get_card_count()):
		var card = hand_display.cards[i]
		var card_visual = CardVisual.new()
		card_visual.name = "CardVisual_%d" % i

		# Initialize the card visual
		card_visual.initialize(card)

		# Add to scene and tracking array
		add_child(card_visual)
		card_visuals.append(card_visual)

		print("Created visual for card %d: %s" % [i, card.card_name])

func _position_cards() -> void:
	"""
	Position the card visuals according to the HandDisplay algorithm.
	"""
	print("Positioning cards using HandDisplay algorithm")

	# Get positions from HandDisplay algorithm
	var positions = hand_display._calculate_fan_positions()
	print("Algorithm returned %d positions" % positions.size())

	# Apply positions to card visuals
	for i in range(min(positions.size(), card_visuals.size())):
		var position = positions[i]
		var card_visual = card_visuals[i]

		# Set the card visual position
		card_visual.position = position

		print("Positioned card %d at %s" % [i, str(position)])

		# Show the front of the card for demo
		if card_visual.has_method("flip_to_front"):
			card_visual.flip_to_front()

func _create_info_display() -> void:
	"""
	Create information display showing demo details.
	"""
	# Create info label
	info_label = Label.new()
	info_label.name = "InfoLabel"
	info_label.position = INFO_POSITION
	add_child(info_label)

	# Set up label properties
	info_label.add_theme_font_size_override("font_size", 16)
	info_label.add_theme_color_override("font_color", Color.WHITE)

	# Generate info content
	var info_text = _generate_info_text()
	info_label.text = info_text

	print("Created info display")

func _generate_info_text() -> String:
	"""
	Generate informational text for the demo display.

	Returns:
		Formatted string with demo information
	"""
	var positions = hand_display._calculate_fan_positions()
	var lines = []

	lines.append("Hand Positioning Demo")
	lines.append("=".repeat(25))
	lines.append("Cards in hand: %d" % hand_display.get_card_count())
	lines.append("Algorithm: Basic Line (50px spacing)")
	lines.append("")
	lines.append("Calculated Positions:")

	for i in range(positions.size()):
		var pos = positions[i]
		lines.append("  Card %d: (%.0f, %.0f)" % [i + 1, pos.x, pos.y])

	lines.append("")
	lines.append("Expected Pattern:")
	lines.append("  Cards arranged horizontally")
	lines.append("  50 pixel spacing between cards")
	lines.append("  Starting at x=400, y=300")

	return "\n".join(lines)

func _input(event: InputEvent) -> void:
	"""
	Handle input events for demo interaction.
	"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				# Restart demo
				print("Restarting demo...")
				_restart_demo()
			KEY_ESCAPE:
				# Exit demo
				print("Exiting demo")
				get_tree().quit()

func _restart_demo() -> void:
	"""
	Restart the demo by recreating everything.
	"""
	# Clear existing card visuals
	for visual in card_visuals:
		if visual and is_instance_valid(visual):
			visual.queue_free()
	card_visuals.clear()

	# Clear hand display
	if hand_display:
		hand_display.clear_hand()

	# Remove info label
	if info_label and is_instance_valid(info_label):
		info_label.queue_free()

	# Recreate demo
	_create_test_cards()
	_create_card_visuals()
	_position_cards()
	_create_info_display()

	print("Demo restarted")

func _on_exit_demo() -> void:
	"""
	Clean up and exit the demo.
	"""
	print("Cleaning up Hand Positioning Demo")

	# Clean up card visuals
	for visual in card_visuals:
		if visual and is_instance_valid(visual):
			visual.queue_free()

	# Clean up hand display
	if hand_display and is_instance_valid(hand_display):
		hand_display.queue_free()
