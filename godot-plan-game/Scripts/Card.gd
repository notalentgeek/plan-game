extends TextureRect

var card_value: int = 0  # Represents the card's value (e.g., 1 for Ace, 2 for 2, etc.)
var is_face_up: bool = false

func flip_card():
	is_face_up = !is_face_up
	texture = load("res://Assets/card_front.png" if is_face_up else "res://Assets/card_back.png")
