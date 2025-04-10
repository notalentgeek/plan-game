# demos/card/simple_card_demo.gd
extends Node2D

"""
Simple demo scene that displays a card in the center of the screen.
This verifies that the basic card visualization works correctly.
"""

func _ready() -> void:
	"""
	Create and display a test card in the center of the screen.
	"""
	print("Starting simple card demo")

	# Create a test problem card
	var problem_card = ProblemCard.new(
		"p_a",
		"Air Pollution",
		"Contamination of air with harmful substances like smoke, dust, and gases.",
		"", # No texture path for now
		"A",
		7
	)

	# Create a card visual
	var card_visual = CardVisual.new()

	# Position the card in the center of the screen
	var viewport_size = get_viewport_rect().size
	var center_container = CenterContainer.new()
	center_container.size = viewport_size
	add_child(center_container)
	center_container.add_child(card_visual)

	# Initialize with the test card
	card_visual.initialize(problem_card)

	# Connect signals for debugging
	card_visual.connect("card_clicked", Callable(self, "_on_card_clicked"))
	card_visual.connect("card_hover_started", Callable(self, "_on_card_hover_started"))
	card_visual.connect("card_hover_ended", Callable(self, "_on_card_hover_ended"))

	# Add instructions label
	var instructions = Label.new()
	instructions.text = "Click on the card to flip it"
	instructions.position = Vector2(viewport_size.x / 2, 50)
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.position.x -= instructions.size.x / 2
	add_child(instructions)

	print("Simple card demo initialized")

func _on_card_clicked(card: Card) -> void:
	"""
	Handle card click event.
	"""
	print("Card clicked: ", card.card_name)

	# Find the card visual in our children
	for child in get_children():
		if child is CenterContainer:
			for container_child in child.get_children():
				if container_child is CardVisual:
					container_child.toggle_flip()
					break

func _on_card_hover_started(card: Card) -> void:
	"""
	Handle card hover start event.
	"""
	print("Hover started on: ", card.card_name)

func _on_card_hover_ended(card: Card) -> void:
	"""
	Handle card hover end event.
	"""
	print("Hover ended on: ", card.card_name)

# Helper function to get the source of a signal
func get_signal_source():
	"""
	Get the object that emitted the current signal.
	"""
	return get_meta("_signal_source") if has_meta("_signal_source") else null
