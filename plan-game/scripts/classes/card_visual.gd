# scripts/classes/card_visual.gd
class_name CardVisual
extends Control

"""
Visual representation of a card in the PLAN game.
Handles the display of card data and visual state management.
"""

# Signal emitted when card is interacted with
signal card_clicked(card)
signal card_hover_started(card)
signal card_hover_ended(card)

# Enums for card visual states
enum VisualState {
	DEFAULT, # Normal card appearance
	SELECTED, # Card is currently selected
	VALID_PLAY, # Card can be legally played
	INVALID_PLAY, # Card cannot be legally played
	DISABLED # Card is not interactive
}

# Card dimensions
const CARD_WIDTH = 160
const CARD_HEIGHT = 240
const CARD_CORNER_RADIUS = 10

# Card appearance constants
const PROBLEM_CARD_COLOR = Color(0.8, 0.2, 0.2) # Red
const SOLUTION_CARD_COLOR = Color(0.2, 0.7, 0.2) # Green
const ULTIMATE_CARD_COLOR = Color(0.2, 0.2, 0.8) # Blue
const CARD_BACK_COLOR = Color(0.15, 0.15, 0.2) # Dark blue-gray

# Card components
var card_front: PanelContainer
var card_back: PanelContainer
var card_name_label: Label
var card_description_label: Label
var card_details_label: Label
var card_icon: TextureRect
var animation_player: AnimationPlayer

# Card state
var card: Card = null
var current_state: int = VisualState.DEFAULT
var flipped: bool = true # true = back showing, false = front showing
var is_animating: bool = false

func _ready() -> void:
	"""
	Initialize the card visual components when added to the scene.
	"""
	# Set up the control node
	custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	pivot_offset = Vector2(CARD_WIDTH, CARD_HEIGHT) / 2.0
	mouse_filter = Control.MOUSE_FILTER_STOP

	_create_card_structure()
	_create_animations()

	# Connect input signals
	connect("gui_input", Callable(self, "_on_gui_input"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

	# Default to showing the back
	card_front.visible = false
	card_back.visible = true

	animation_player.animation_finished.connect(Callable(self, "_on_animation_finished"))

func _create_card_structure() -> void:
	"""
	Create the visual structure of the card.
	"""
	# Create a container to enforce consistent size
	var card_container = Control.new()
	card_container.name = "CardContainer"
	card_container.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card_container.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card_container.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(card_container)

	# Create front of card
	card_front = PanelContainer.new()
	card_front.name = "CardFront"
	card_front.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card_front.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card_front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_front.clip_contents = true

	# Set up front panel style - make it transparent
	var front_style = StyleBoxFlat.new()
	front_style.bg_color = Color.TRANSPARENT
	front_style.corner_radius_top_left = CARD_CORNER_RADIUS
	front_style.corner_radius_top_right = CARD_CORNER_RADIUS
	front_style.corner_radius_bottom_left = CARD_CORNER_RADIUS
	front_style.corner_radius_bottom_right = CARD_CORNER_RADIUS
	card_front.add_theme_stylebox_override("panel", front_style)
	card_container.add_child(card_front)

	# Just add the card icon directly to the front panel - no extra containers
	card_icon = TextureRect.new()
	card_icon.name = "CardIcon"
	card_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	card_icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_front.add_child(card_icon)

	# We still create the text labels but don't add them to the scene immediately
	# They'll be added later if needed
	card_name_label = Label.new()
	card_name_label.name = "CardName"

	card_description_label = Label.new()
	card_description_label.name = "CardDescription"

	card_details_label = Label.new()
	card_details_label.name = "CardDetails"

	# Create back of card (keep this unchanged)
	card_back = PanelContainer.new()
	card_back.name = "CardBack"
	card_back.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card_back.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card_back.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var back_style = StyleBoxFlat.new()
	back_style.bg_color = CARD_BACK_COLOR
	back_style.corner_radius_top_left = CARD_CORNER_RADIUS
	back_style.corner_radius_top_right = CARD_CORNER_RADIUS
	back_style.corner_radius_bottom_left = CARD_CORNER_RADIUS
	back_style.corner_radius_bottom_right = CARD_CORNER_RADIUS
	back_style.shadow_size = 2
	back_style.shadow_offset = Vector2(1, 1)
	card_back.add_theme_stylebox_override("panel", back_style)
	card_container.add_child(card_back)

	var back_margin = MarginContainer.new()
	back_margin.add_theme_constant_override("margin_left", 20)
	back_margin.add_theme_constant_override("margin_right", 20)
	back_margin.add_theme_constant_override("margin_top", 20)
	back_margin.add_theme_constant_override("margin_bottom", 20)
	card_back.add_child(back_margin)

	var back_label = Label.new()
	back_label.text = "PLAN"
	back_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	back_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	back_label.add_theme_font_size_override("font_size", 28)
	back_label.add_theme_color_override("font_color", Color.WHITE)
	back_margin.add_child(back_label)

	animation_player = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	add_child(animation_player)

func _create_animations() -> void:
	"""
	Create animations for the card visual effects.
	"""
	# Create animation library
	var library = AnimationLibrary.new()

	# Create a simple flip to front animation - just visibility toggle
	var flip_to_front_anim = Animation.new()
	flip_to_front_anim.length = 0.1 # Very short, just a quick transition

	# Track for front visibility
	var front_track = flip_to_front_anim.add_track(Animation.TYPE_VALUE)
	flip_to_front_anim.track_set_path(front_track, "CardContainer/CardFront:visible")
	flip_to_front_anim.track_insert_key(front_track, 0.0, false)
	flip_to_front_anim.track_insert_key(front_track, 0.1, true)

	# Track for back visibility
	var back_track = flip_to_front_anim.add_track(Animation.TYPE_VALUE)
	flip_to_front_anim.track_set_path(back_track, "CardContainer/CardBack:visible")
	flip_to_front_anim.track_insert_key(back_track, 0.0, true)
	flip_to_front_anim.track_insert_key(back_track, 0.1, false)

	library.add_animation("flip_to_front", flip_to_front_anim)

	# Create a simple flip to back animation - just visibility toggle
	var flip_to_back_anim = Animation.new()
	flip_to_back_anim.length = 0.1

	# Track for front visibility
	front_track = flip_to_back_anim.add_track(Animation.TYPE_VALUE)
	flip_to_back_anim.track_set_path(front_track, "CardContainer/CardFront:visible")
	flip_to_back_anim.track_insert_key(front_track, 0.0, true)
	flip_to_back_anim.track_insert_key(front_track, 0.1, false)

	# Track for back visibility
	back_track = flip_to_back_anim.add_track(Animation.TYPE_VALUE)
	flip_to_back_anim.track_set_path(back_track, "CardContainer/CardBack:visible")
	flip_to_back_anim.track_insert_key(back_track, 0.0, false)
	flip_to_back_anim.track_insert_key(back_track, 0.1, true)

	library.add_animation("flip_to_back", flip_to_back_anim)

	# Create hover animation
	var hover = Animation.new()
	hover.length = 0.2

	var scale_track = hover.add_track(Animation.TYPE_VALUE)
	hover.track_set_path(scale_track, ":scale")
	hover.track_insert_key(scale_track, 0.0, Vector2(1.0, 1.0))
	hover.track_insert_key(scale_track, 0.2, Vector2(1.05, 1.05))

	library.add_animation("hover", hover)

	# Create hover exit animation
	var hover_exit = Animation.new()
	hover_exit.length = 0.2

	scale_track = hover_exit.add_track(Animation.TYPE_VALUE)
	hover_exit.track_set_path(scale_track, ":scale")
	hover_exit.track_insert_key(scale_track, 0.0, Vector2(1.05, 1.05))
	hover_exit.track_insert_key(scale_track, 0.2, Vector2(1.0, 1.0))

	library.add_animation("hover_exit", hover_exit)

	# Add animations to the player
	animation_player.add_animation_library("", library)

func initialize(p_card: Card) -> void:
	"""
	Initialize the card visual with data from the provided card.
	"""
	card = p_card
	if card == null:
		push_error("Attempting to initialize CardVisual with null card")
		return

	# Make sure the card structure exists
	if card_front == null:
		_create_card_structure()
		_create_animations()

	# Update visual elements with card data
	card_name_label.text = card.card_name
	card_description_label.text = card.description

	# Get the texture
	var texture = card.get_texture()
	print("Initialize - card name: ", card.card_name)
	print("Initialize - texture: ", texture)
	print("Initialize - texture path: ", card.texture_path)

	if texture:
		# We have a texture, use it
		card_icon.texture = texture
		print("Texture set to card_icon")
	else:
		# No texture, show a placeholder or text
		print("No texture found, using placeholder")
		card_icon.texture = null

		# Optionally show text as fallback
		var label = Label.new()
		label.text = card.card_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", Color.WHITE)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card_front.add_child(label)

	# Configure based on card type
	match card.card_type:
		Card.CardType.PROBLEM:
			_set_problem_card_visuals()
		Card.CardType.SOLUTION:
			if card is SolutionCard and (card as SolutionCard).is_ultimate:
				_set_ultimate_card_visuals()
			else:
				_set_solution_card_visuals()
		Card.CardType.ULTIMATE:
			_set_ultimate_card_visuals()

func _set_problem_card_visuals() -> void:
	"""
	Set visuals specific to problem cards.
	"""
	var style = card_front.get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color = PROBLEM_CARD_COLOR

	# Add problem-specific details
	if card is ProblemCard:
		var problem_card = card as ProblemCard
		card_details_label.text = "Problem %s | Severity: %d" % [
			problem_card.letter_code,
			problem_card.severity_index
		]

func _set_solution_card_visuals() -> void:
	"""
	Set visuals specific to solution cards.
	"""
	var style = card_front.get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color = SOLUTION_CARD_COLOR

	# Add solution-specific details
	if card is SolutionCard:
		var solution_card = card as SolutionCard
		card_details_label.text = "Solves: " + str(solution_card.solvable_problems)

func _set_ultimate_card_visuals() -> void:
	"""
	Set visuals specific to ultimate solution cards.
	"""
	var style = card_front.get_theme_stylebox("panel") as StyleBoxFlat
	style.bg_color = ULTIMATE_CARD_COLOR

	# Add ultimate-specific details
	card_details_label.text = "ULTIMATE: Solves Any Problem"

func set_visual_state(state: int) -> void:
	"""
	Update the card's visual appearance based on its state.

	Args:
		state: The visual state to apply from VisualState enum
	"""
	current_state = state

	# Apply visual changes based on state
	match state:
		VisualState.DEFAULT:
			modulate = Color.WHITE
		VisualState.SELECTED:
			modulate = Color(1.2, 1.2, 0.9) # Yellowish highlight
		VisualState.VALID_PLAY:
			modulate = Color(0.9, 1.2, 0.9) # Green tint
		VisualState.INVALID_PLAY:
			modulate = Color(1.0, 1.0, 1.0, 0.7) # Faded
		VisualState.DISABLED:
			modulate = Color(0.6, 0.6, 0.6) # Grayed out

func flip_to_front() -> void:
	"""
	Flip the card to show its front side.
	"""
	if flipped and not is_animating:
		is_animating = true
		animation_player.play("flip_to_front")
		# We'll update flipped in the animation finished callback

func flip_to_back() -> void:
	"""
	Flip the card to show its back side.
	"""
	if not flipped and not is_animating:
		is_animating = true
		animation_player.play("flip_to_back")
		# We'll update flipped in the animation finished callback

func toggle_flip() -> void:
	"""
	Toggle the card between front and back sides.
	"""
	if flipped:
		flip_to_front()
	else:
		flip_to_back()

func _on_animation_finished(anim_name: String) -> void:
	"""
	Handle animation completion events.

	Args:
		anim_name: The name of the animation that finished
	"""
	is_animating = false

	if anim_name == "flip_to_front":
		flipped = false
	elif anim_name == "flip_to_back":
		flipped = true

func _on_gui_input(event: InputEvent) -> void:
	"""
	Handle input events on the card.

	Args:
		event: The input event
	"""
	if current_state != VisualState.DISABLED:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Card visual clicked: ", card.card_name if card else "Unknown")
			emit_signal("card_clicked", card)
			toggle_flip() # Automatically toggle flip on click

func _on_mouse_entered() -> void:
	"""
	Handle mouse entering the card area.
	"""
	if current_state != VisualState.DISABLED:
		animation_player.play("hover")
		emit_signal("card_hover_started", card)

func _on_mouse_exited() -> void:
	"""
	Handle mouse exiting the card area.
	"""
	if current_state != VisualState.DISABLED:
		animation_player.play("hover_exit")
		emit_signal("card_hover_ended", card)
