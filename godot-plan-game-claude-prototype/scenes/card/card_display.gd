# Visual representation of a card in the Plan Card Game
extends Control

# Signals
signal card_clicked(card_display)
signal card_hovered(card_display)
signal card_unhovered(card_display)

# Card properties
var card_data: Card = null
var is_face_up: bool = true
var is_selectable: bool = true
var is_selected: bool = false
var original_position: Vector2
var hover_offset: Vector2 = Vector2(0, -20) # Move card up when hovered

# References to UI elements
@onready var card_container = $CardContainer
@onready var front_side = $CardContainer/FrontSide
@onready var back_side = $CardContainer/BackSide
@onready var title_label = $CardContainer/FrontSide/MarginContainer/VBoxContainer/TitleLabel
@onready var letter_label = $CardContainer/FrontSide/MarginContainer/VBoxContainer/LetterLabel
@onready var image_rect = $CardContainer/FrontSide/MarginContainer/VBoxContainer/ImageRect
@onready var description_label = $CardContainer/FrontSide/MarginContainer/VBoxContainer/DescriptionLabel
@onready var selection_indicator = $SelectionIndicator

## Built-in Methods

func _ready() -> void:
	selection_indicator.visible = false
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

	original_position = position

	# Initialize the card appearance if card_data already exists
	if card_data:
		update_appearance()

func _gui_input(event: InputEvent) -> void:
	if not is_selectable:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_click()

## Public Methods

func set_card(new_card: Card) -> void:
	"""
	Set the card data and update the appearance.
	"""
	card_data = new_card
	update_appearance()

func flip(face_up: bool) -> void:
	"""
	Flip the card to show either front or back.
	"""
	is_face_up = face_up
	front_side.visible = is_face_up
	back_side.visible = not is_face_up

func select(selected: bool = true) -> void:
	"""
	Mark the card as selected or unselected.
	"""
	is_selected = selected
	selection_indicator.visible = is_selected

	if is_selected:
		# Apply a visual effect for selected cards
		modulate = Color(1.2, 1.2, 1.2, 1.0)
	else:
		# Reset to normal
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func set_selectable(selectable: bool) -> void:
	"""
	Set whether the card can be selected by clicking.
	"""
	is_selectable = selectable

	# Visual indication of selectability
	if is_selectable:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW

func animate_to(target_position: Vector2, duration: float = 0.3) -> void:
	"""
	Animate the card moving to a new position.
	"""
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func update_appearance() -> void:
	"""
	Update the card's visual appearance based on its data.
	"""
	if not card_data:
		return

	# Set up the card appearance based on type
	var card_color = Utils.get_card_color(card_data)
	card_container.self_modulate = card_color

	# Update card content
	title_label.text = card_data.card_name
	description_label.text = card_data.description

	# Update letter code for problem cards
	if card_data.card_type == Card.CardType.PROBLEM:
		var problem_card = card_data as ProblemCard
		letter_label.text = problem_card.letter_code if problem_card else ""
		letter_label.visible = true
	else:
		letter_label.visible = false

	# Load card image if available
	if card_data.texture:
		image_rect.texture = card_data.texture
	elif not card_data.texture_path.is_empty():
		var texture = load(card_data.texture_path)
		if texture:
			image_rect.texture = texture

	# Make title bold for ultimate cards
	if card_data.card_type == Card.CardType.ULTIMATE:
		title_label.add_theme_font_override("font", preload("res://assets/fonts/bold_font.tres"))
	else:
		title_label.remove_theme_font_override("font")

## Event Handlers

func _on_click() -> void:
	"""
	Handle click on the card.
	"""
	emit_signal("card_clicked", self)

func _on_mouse_entered() -> void:
	"""
	Handle mouse hover over the card.
	"""
	if is_selectable:
		var tween = create_tween()
		tween.tween_property(self, "position", original_position + hover_offset, 0.1).set_ease(Tween.EASE_OUT)
		emit_signal("card_hovered", self)

func _on_mouse_exited() -> void:
	"""
	Handle mouse leaving the card.
	"""
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.1).set_ease(Tween.EASE_IN)
	emit_signal("card_unhovered", self)
