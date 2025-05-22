extends Control

# Reference to container for cards
var card_container: Control

# Card layout parameters
const CARD_WIDTH = 160 # Width of the card visual
const CARD_HEIGHT = 240 # Height of the card visual
const CARD_SPACING_X = 20 # Horizontal spacing between cards
const CARD_SPACING_Y = 20 # Vertical spacing between rows
const LEFT_MARGIN = 20 # Left margin for the first card

# Track the cards we've added
var cards = []

# Problem card data based on the images you provided
var problem_card_data = [
    {"letter": "A", "index": 24, "name": "Plastic Pollution",
     "description": "Accumulation of plastic waste in the environment that adversely affects wildlife, habitats, and humans.",
     "filename": "A_24_plastic_pollution.png"},
    {"letter": "B", "index": 90, "name": "Oil Spill",
     "description": "Release of crude oil into the environment, especially marine areas, causing ecological damage.",
     "filename": "B_90_oil_spill.png"},
    {"letter": "C", "index": 48, "name": "Deforestation",
     "description": "Large-scale removal of forests leading to habitat loss and increased carbon emissions.",
     "filename": "C_48_deforestation.png"},
    {"letter": "D", "index": 57, "name": "Gas Flaring",
     "description": "Burning of excess natural gas during oil production, contributing to air pollution and greenhouse gases.",
     "filename": "D_57_gas_flaring.png"},
    {"letter": "F", "index": 40, "name": "Desertification",
     "description": "Process by which fertile land becomes desert, typically due to drought, deforestation, or inappropriate agriculture.",
     "filename": "F_40_desertification.png"},
    {"letter": "G", "index": 39, "name": "Drought",
     "description": "Extended period of abnormally low rainfall, leading to water shortage and ecosystem stress.",
     "filename": "G_39_drought.png"}
]

# Track which card to show next
var current_card_index = 0

func _ready():
    print("Basic test scene initialized")

    # Create the "Add Problem Card" button programmatically
    var add_problem_btn = Button.new()
    add_problem_btn.text = "Add Problem Card"
    add_problem_btn.position = Vector2(0, 0) # Top-left corner
    add_problem_btn.size = Vector2(150, 40) # Set button size

    # Connect button signal
    add_problem_btn.pressed.connect(Callable(self, "_on_add_problem_pressed"))

    # Add the button to the scene
    add_child(add_problem_btn)

    # Create a container for cards with margin below the button
    card_container = Control.new()
    card_container.position = Vector2(0, 60) # 20px margin below the button
    card_container.size = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y - 60)
    add_child(card_container)

    print("Button added programmatically")

func _on_add_problem_pressed() -> void:
    print("Add Problem Card button pressed")

    # Get the data for the current card
    var card_data = problem_card_data[current_card_index % problem_card_data.size()]

    # Build the texture path using the filename from our data
    var texture_path = "res://assets/cards/problem_cards/" + card_data.filename

    # Debug: Print the path we're trying to load
    print("Trying to load texture: ", texture_path)
    print("File exists: ", ResourceLoader.exists(texture_path))

    # Create a problem card with the specific data
    var problem_card = ProblemCard.new(
        "p_" + card_data.letter.to_lower(),
        card_data.name,
        card_data.description,
        texture_path,  # Use the correct path
        card_data.letter,
        card_data.index
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

    print("Card added: " + card_data.name)

    # Move to next card for subsequent button presses
    current_card_index += 1

func _reposition_cards() -> void:
    # Get the available width for cards
    var available_width = get_viewport_rect().size.x

    # Calculate how many cards fit in a row
    var cards_per_row = int((available_width - LEFT_MARGIN) / (CARD_WIDTH + CARD_SPACING_X))
    if cards_per_row < 1:
        cards_per_row = 1 # Ensure at least one card per row

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
