# demos/card/card_count_demo.gd
extends Node2D

"""
Simple visual demonstration of card counting functionality.
Shows console output of card count changes as cards are added to HandDisplay.
Task 4.2.2: Create basic visual demonstration of card counting.
"""

var hand_display: HandDisplay
var test_cards: Array[Card] = []

func _ready() -> void:
	"""
	Initialize the card count demonstration.
	"""
	print("=== CARD COUNT DEMO STARTING ===")

	# Create HandDisplay instance
	hand_display = HandDisplay.new()
	add_child(hand_display)

	# Create test cards for demonstration
	_create_test_cards()

	# Show initial state
	_display_current_count("Initial state")

	# Start the demonstration
	_start_demo()

func _create_test_cards() -> void:
	"""
	Create test cards for the demonstration.
	"""
	print("Creating test cards...")

	# Create problem cards
	var problem_card1 = ProblemCard.new(
		"demo_problem_1",
		"Air Pollution",
		"Contamination of air with harmful substances",
		"", # No texture path
		"A",
		8
	)

	var problem_card2 = ProblemCard.new(
		"demo_problem_2",
		"Water Pollution",
		"Contamination of water sources",
		"", # No texture path
		"W",
		7
	)

	# Create solution cards
	var solution_card1 = SolutionCard.new(
		"demo_solution_1",
		"Renewable Energy",
		"Clean energy solutions",
		"", # No texture path
		["A"], # Solves air pollution
		false # Not ultimate
	)

	var solution_card2 = SolutionCard.new(
		"demo_solution_2",
		"Water Treatment",
		"Water purification systems",
		"", # No texture path
		["W"], # Solves water pollution
		false # Not ultimate
	)

	# Create ultimate card
	var ultimate_card = SolutionCard.new(
		"demo_ultimate",
		"Environmental Education",
		"Ultimate solution for all problems",
		"", # No texture path
		[], # No specific problems (ultimate solves all)
		true # Is ultimate
	)

	# Add to test cards array
	test_cards.append(problem_card1)
	test_cards.append(problem_card2)
	test_cards.append(solution_card1)
	test_cards.append(solution_card2)
	test_cards.append(ultimate_card)

	print("Created ", test_cards.size(), " test cards")

func _start_demo() -> void:
	"""
	Start the card counting demonstration.
	"""
	print("Starting card counting demonstration...")
	print("Press SPACE to add next card, or ESC to exit")

	# Set up input handling
	set_process_input(true)

func _input(event: InputEvent) -> void:
	"""
	Handle input for the demonstration.
	"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				_add_next_card()
			KEY_ESCAPE:
				_end_demo()

func _add_next_card() -> void:
	"""
	Add the next card in the test cards array.
	"""
	var current_count = hand_display.get_card_count()

	if current_count >= test_cards.size():
		print("All cards have been added! Final count: ", current_count)
		print("Press ESC to exit or try duplicate addition...")
		return

	var card_to_add = test_cards[current_count]
	print("\n--- Adding Card ", current_count + 1, " ---")
	print("Card: ", card_to_add.card_name)
	print("Type: ", _get_card_type_name(card_to_add))

	# Add the card
	var success = hand_display.add_card(card_to_add)

	if success:
		print("✓ Card added successfully!")
		_display_current_count("After adding " + card_to_add.card_name)
	else:
		print("✗ Card addition failed!")
		_display_current_count("After failed addition")

	# Show next instruction
	if hand_display.get_card_count() < test_cards.size():
		print("Press SPACE to add next card...")
	else:
		print("Demo complete! Press ESC to exit")

func _get_card_type_name(card: Card) -> String:
	"""
	Get human-readable card type name.
	"""
	match card.card_type:
		Card.CardType.PROBLEM:
			return "Problem Card"
		Card.CardType.SOLUTION:
			if card is SolutionCard and (card as SolutionCard).is_ultimate:
				return "Ultimate Solution Card"
			else:
				return "Solution Card"
		Card.CardType.ULTIMATE:
			return "Ultimate Card"
		_:
			return "Unknown Card Type"

func _display_current_count(context: String) -> void:
	"""
	Display the current card count with context.
	"""
	var count = hand_display.get_card_count()
	var array_size = hand_display.cards.size()

	print("📊 ", context, ":")
	print("   get_card_count(): ", count)
	print("   cards.size(): ", array_size)
	print("   Match: ", "✓" if count == array_size else "✗")

func _end_demo() -> void:
	"""
	End the demonstration and clean up.
	"""
	print("\n=== CARD COUNT DEMO ENDING ===")
	print("Final Results:")
	_display_current_count("Final state")

	if hand_display.cards.size() > 0:
		print("Cards in hand:")
		for i in range(hand_display.cards.size()):
			var card = hand_display.cards[i]
			print("  ", i + 1, ". ", card.card_name, " (", _get_card_type_name(card), ")")

	print("Demo completed successfully!")

	# Clean up and exit
	if hand_display:
		hand_display.queue_free()

	get_tree().quit()
