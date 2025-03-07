extends Node2D

# Preload the Card scene
const CardScene = preload("res://Scenes/Card.tscn")

# Deck and hands
var deck: Array = []
var player_hands: Array = [[], [], [], []]  # Hands for Player 1, 2, 3, and 4

# Screen dimensions
var screen_width: float
var screen_height: float

# Positions for the deck, hands, and button
var deck_position: Vector2
var hand_positions: Array = []
var draw_button_position: Vector2

# Tween for animations
var tween: Tween

func _ready():
	# Get screen dimensions
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y

	# Initialize the tween
	tween = create_tween()

	# Calculate positions
	calculate_positions()

	# Initialize the deck and distribute cards
	initialize_deck()
	distribute_cards()

	# Add the draw button
	add_draw_button()

func calculate_positions():
	# Deck position (center of the screen)
	deck_position = Vector2(screen_width / 2, screen_height / 2)

	# Player hand positions
	hand_positions = [
		Vector2(screen_width / 2, screen_height - 100),  # Player 1 (bottom)
		Vector2(screen_width - 100, screen_height / 2),  # Player 2 (right)
		Vector2(100, screen_height / 2),                 # Player 3 (left)
		Vector2(screen_width / 2, 100)                   # Player 4 (top)
	]

	# Draw button position (near the deck)
	draw_button_position = deck_position + Vector2(100, 0)

func initialize_deck():
	# Create a deck of 52 cards
	for value in range(1, 14):  # 1-13 for card values
		for _i in range(4):     # 4 suits
			var card = CardScene.instantiate()  # Fixed line
			card.card_value = value
			deck.append(card)
	deck.shuffle()  # Shuffle the deck

func distribute_cards():
	for player_index in range(4):
		for _i in range(5):
			draw_card(player_index)

func draw_card(player_index: int):
	if deck.size() == 0:
		return  # No more cards in the deck

	var card = deck.pop_back()
	player_hands[player_index].append(card)
	add_child(card)

	# Calculate target position and rotation
	var hand_position = hand_positions[player_index]
	var card_count = player_hands[player_index].size()
	var angle_offset = deg_to_rad(10)
	var radius = 100

	var angle = angle_offset * (card_count - 1 - (card_count - 1) / 2.0)
	var offset = Vector2(radius * sin(angle), -radius * cos(angle))
	var target_position = hand_position + offset
	var target_rotation = angle

	# Animate the card
	tween.tween_property(card, "position", target_position, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(card, "rotation", target_rotation, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	if player_index == 0:
		card.flip_card()

func add_draw_button():
	var draw_button = Button.new()
	draw_button.text = "Draw Card"
	draw_button.position = draw_button_position
	draw_button.connect("pressed", Callable(self, "_on_DrawButton_pressed"))  # Fixed line
	add_child(draw_button)

func _on_DrawButton_pressed():
	draw_card(0)  # Draw a card for the main player (Player 1)
