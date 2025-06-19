# demos/hand/single_card_position_demo.gd
extends Node2D

"""
Visual demonstration of single card positioning in HandDisplay.

This demo creates a HandDisplay with a single card and shows the calculated
center position (400, 300) visually. Used to verify that the positioning
logic works correctly in practice.
"""

var hand_display: HandDisplay
var card_visual: CardVisual
var position_marker: Node2D

func _ready() -> void:
	"""
	Initialize the single card positioning demo.
	"""
	print("Starting single card positioning demo")

	# Set up the demo scene
	_create_demo_components()
	_setup_single_card()
	_show_position_calculation()
	_add_instructions()

	print("Single card positioning demo initialized")

func _create_demo_components() -> void:
	"""
	Create the core demo components.
	"""
	# Create HandDisplay instance
	hand_display = HandDisplay.new()
	hand_display.name = "HandDisplay"
	add_child(hand_display)

	# Create position marker for visualization
	position_marker = Node2D.new()
	position_marker.name = "PositionMarker"
	add_child(position_marker)

func _setup_single_card() -> void:
	"""
	Set up a single card in the hand display.
	"""
	# Create a test problem card
	var test_card = ProblemCard.new(
		"demo_air_pollution",
		"Air Pollution",
		"Contamination of air with harmful substances like smoke, dust, and gases from vehicles and factories.",
		"", # No texture path
		"A",
		7
	)

	# Add card to hand display
	var add_result = hand_display.add_card(test_card)
	if add_result:
		print("Card added successfully to hand display")
	else:
		print("Failed to add card to hand display")

func _show_position_calculation() -> void:
	"""
	Calculate and visualize the single card position.
	"""
	# Get calculated positions from HandDisplay
	var positions = hand_display._calculate_fan_positions()

	print("Calculated positions: ", positions)
	print("Number of positions: ", positions.size())

	if positions.size() == 1:
		var center_position = positions[0]
		print("Single card center position: ", center_position)

		# Create CardVisual at calculated position
		_create_card_visual(center_position)

		# Create visual marker at position
		_create_position_marker(center_position)
	else:
		print("Error: Expected 1 position, got ", positions.size())

func _create_card_visual(position: Vector2) -> void:
	"""
	Create and position CardVisual at the calculated position.

	Args:
		position: The Vector2 position where the card should be displayed
	"""
	# Create CardVisual
	card_visual = CardVisual.new()
	card_visual.name = "SingleCardVisual"
	card_visual.position = position
	add_child(card_visual)

	# Get the card from hand display for initialization
	if hand_display.cards.size() > 0:
		var card = hand_display.cards[0]
		card_visual.initialize(card)
		print("CardVisual created at position: ", position)
	else:
		print("No cards available for visual initialization")

func _create_position_marker(position: Vector2) -> void:
	"""
	Create visual marker showing the calculated center position.

	Args:
		position: The Vector2 position to mark
	"""
	position_marker.position = position

	# Add visual feedback in _draw (we'll override this)
	position_marker.queue_redraw()

func _draw() -> void:
	"""
	Draw visual markers and information on the demo scene.
	"""
	# Draw crosshair at center position if we have positions
	var positions = []
	if hand_display:
		positions = hand_display._calculate_fan_positions()

	if positions.size() == 1:
		var center_pos = positions[0]

		# Draw crosshair marker
		var crosshair_size = 20
		var color = Color.RED

		# Horizontal line
		draw_line(
			Vector2(center_pos.x - crosshair_size, center_pos.y),
			Vector2(center_pos.x + crosshair_size, center_pos.y),
			color, 2
		)

		# Vertical line
		draw_line(
			Vector2(center_pos.x, center_pos.y - crosshair_size),
			Vector2(center_pos.x, center_pos.y + crosshair_size),
			color, 2
		)

		# Draw position coordinates text
		var font = ThemeDB.fallback_font
		var text = "Center: (%d, %d)" % [center_pos.x, center_pos.y]
		draw_string(font, Vector2(center_pos.x + 30, center_pos.y - 10), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

func _add_instructions() -> void:
	"""
	Add instruction text to the demo.
	"""
	var instructions = Label.new()
	instructions.name = "Instructions"
	instructions.text = "Single Card Positioning Demo\n\nRed crosshair shows calculated center position (400, 300)\nCard should appear at the crosshair location"
	instructions.position = Vector2(20, 20)
	instructions.add_theme_font_size_override("font_size", 14)
	instructions.add_theme_color_override("font_color", Color.WHITE)
	add_child(instructions)

func _input(event: InputEvent) -> void:
	"""
	Handle input for demo interaction.
	"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				# Refresh demo
				print("Refreshing demo...")
				_refresh_demo()
			KEY_ESCAPE:
				print("Exiting demo...")
				get_tree().quit()

func _refresh_demo() -> void:
	"""
	Refresh the demo by recalculating positions.
	"""
	queue_redraw()
	print("Demo refreshed - Position: ", hand_display._calculate_fan_positions())
