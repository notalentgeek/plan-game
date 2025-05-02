extends Control

# Reference to container for cards
var card_container: Control

# Card layout parameters
const CARD_WIDTH = 160  # Width of the card visual
const CARD_HEIGHT = 240  # Height of the card visual
const CARD_SPACING_X = 20  # Horizontal spacing between cards
const CARD_SPACING_Y = 20  # Vertical spacing between rows
const LEFT_MARGIN = 20  # Left margin for the first card

# Track the cards we've added
var cards = []

func _ready():
	print("Basic test scene initialized")
	
	# Create the "Add Problem Card" button programmatically
	var add_problem_btn = Button.new()
	add_problem_btn.text = "Add Problem Card"
	add_problem_btn.position = Vector2(0, 0)  # Top-left corner
	add_problem_btn.size = Vector2(150, 40)   # Set button size
	
	# Connect button signal
	add_problem_btn.pressed.connect(Callable(self, "_on_add_problem_pressed"))
	
	# Add the button to the scene
	add_child(add_problem_btn)
	
	# Create a container for cards with margin below the button
	card_container = Control.new()
	card_container.position = Vector2(0, 60)  # 20px margin below the button
	card_container.size = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y - 60)
	add_child(card_container)
	
	print("Button added programmatically")

func _on_add_problem_pressed() -> void:
	print("Add Problem Card button pressed")
	
	# Create a problem card with a random problem name
	var problems = ["Air Pollution", "Water Pollution", "Deforestation", 
				   "Climate Change", "Soil Erosion", "Biodiversity Loss", 
				   "Waste Management", "Ozone Depletion"]
	var problem_index = randi() % problems.size()
	var problem_name = problems[problem_index]
	
	# Get a letter code A-Z based on current count
	var letter_code = String.chr(65 + (cards.size() % 26))
	
	var problem_card = ProblemCard.new(
		"p_" + str(cards.size()),
		problem_name,
		"Environmental issue affecting the planet.",
		"",  # No texture path for now
		letter_code,
		(cards.size() % 10) + 1  # Severity 1-10
	)
	
	# Create a card visual
	var card_visual = CardVisual.new()
	
	# Add the card visual to the container
	card_container.add_child(card_visual)
	
	# Add to our array of cards
	cards.append(card_visual)
	
	# Reposition all cards
	_reposition_cards()
	
	# Initialize with the problem card
	card_visual.initialize(problem_card)
	
	# Ensure card shows its front
	card_visual.flip_to_front()
	
	# Connect card signals for debugging
	card_visual.card_clicked.connect(Callable(self, "_on_card_clicked"))
	
	print("Card added: " + problem_name)

func _reposition_cards() -> void:
	# Get the available width for cards
	var available_width = get_viewport_rect().size.x
	
	# Calculate how many cards fit in a row
	var cards_per_row = int((available_width - LEFT_MARGIN) / (CARD_WIDTH + CARD_SPACING_X))
	if cards_per_row < 1:
		cards_per_row = 1  # Ensure at least one card per row
	
	# Position each card
	for i in range(cards.size()):
		var row = int(i / cards_per_row)
		var col = i % cards_per_row
		
		var x_pos = LEFT_MARGIN + col * (CARD_WIDTH + CARD_SPACING_X)
		var y_pos = row * (CARD_HEIGHT + CARD_SPACING_Y)
		
		cards[i].position = Vector2(x_pos, y_pos)

func _on_card_clicked(card: Card) -> void:
	print("Card clicked: ", card.card_name)
	
	# Find the card visual that was clicked
	for child in card_container.get_children():
		if child is CardVisual and child.card == card:
			child.toggle_flip()
			break
