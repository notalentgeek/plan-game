# hand_movement_demo.gd
extends Node2D
"""
Minimal hand movement demo for PLAN card game.
Shows 5 cards in a fan layout with debug visualization and basic interaction.
"""

# Configuration
const CARD_COUNT := 5
const FAN_CENTER := Vector2(640, 450)
const FAN_RADIUS := 200.0
const FAN_ANGLE_SPAN := deg_to_rad(108)  # 108 degrees total spread
const CARD_SCALE := 0.5

# Card data samples from PLAN game
const PROBLEM_CARDS := [
	{
		"id": "p_a",
		"name": "Plastic Pollution",
		"desc": "Accumulation of plastic waste in the environment",
		"code": "A",
		"severity": 6
	},
	{
		"id": "p_b", 
		"name": "Oil Spill",
		"desc": "Discharge of crude oil on the environment",
		"code": "B",
		"severity": 7
	}
]

const SOLUTION_CARDS := [
	{
		"id": "s_1",
		"name": "Clean Up",
		"desc": "Community waste collection initiatives",
		"solves": ["A","B","N","O","P","Q"],
		"ultimate": false
	},
	{
		"id": "s_2",
		"name": "Afforestation",
		"desc": "Planting trees to restore ecosystems",
		"solves": ["C","F","G","I","K","M","P","R"],
		"ultimate": false
	}
]

# Demo components
var card_scene = preload("res://demos/card/simple_card_demo.tscn")
var cards := []

func _ready() -> void:
	_setup_demo()
	_create_cards()
	_position_cards_in_fan()

func _setup_demo() -> void:
	# Set up any initial demo configuration
	pass

# Replace the card creation in _create_cards() with this:
func _create_cards() -> void:
	# Create mix of problem and solution cards
	for i in range(CARD_COUNT):
		var card_data
		if i % 2 == 0:  # Alternate between problem and solution cards
			card_data = PROBLEM_CARDS[i % PROBLEM_CARDS.size()]
			var card = ProblemCard.new(
				card_data.id,
				card_data.name,
				card_data.desc,
				"",
				card_data.code,
				card_data.severity
			)
			cards.append(card)
		else:
			card_data = SOLUTION_CARDS[i % SOLUTION_CARDS.size()]
			var solves: Array[String] = []
			solves.assign(card_data.solves)
			var card = SolutionCard.new(
				card_data.id,
				card_data.name,
				card_data.desc,
				"",
				solves,
				card_data.ultimate
			)
			cards.append(card)
		
		# Create and configure card visual
		var card_visual = CardVisual.new()
		card_visual.card = cards[i]  # Set the card data directly
		card_visual.scale = Vector2(CARD_SCALE, CARD_SCALE)
		add_child(card_visual)

func _position_cards_in_fan() -> void:
	if cards.is_empty():
		return
	
	# Calculate fan positions
	var angle_step := FAN_ANGLE_SPAN / (CARD_COUNT - 1)
	var start_angle := -FAN_ANGLE_SPAN / 2
	
	for i in range(CARD_COUNT):
		var angle := start_angle + (i * angle_step)
		var offset := Vector2(cos(angle), sin(angle)) * FAN_RADIUS
		var card_pos := FAN_CENTER + offset
		
		# Position and rotate card
		var card = get_child(i)
		card.position = card_pos
		card.rotation = angle * 0.5  # Gentle rotation
		
		# Bring middle card slightly forward
		if i == CARD_COUNT / 2:
			card.z_index = 1

func _draw() -> void:
	# 1. Red dot at screen center
	draw_circle(FAN_CENTER, 5, Color.RED)
	
	# 2. Green collision box around cards
	var rect = _calculate_cards_bounding_box()
	draw_rect(rect, Color.GREEN, false, 2.0)
	
	# 3. Green dot at box center
	var box_center = rect.position + (rect.size / 2)
	draw_circle(box_center, 5, Color.GREEN)

func _calculate_cards_bounding_box() -> Rect2:
	var min_pos := Vector2.INF
	var max_pos := -Vector2.INF
	
	for card in get_children():
		if not card is CardVisual:
			continue
			
		# Calculate card corners (accounting for rotation and scale)
		var card_size = card.texture.get_size() * CARD_SCALE
		var half_size = card_size / 2
		var corners = [
			Vector2(-half_size.x, -half_size.y),
			Vector2(half_size.x, -half_size.y),
			Vector2(half_size.x, half_size.y),
			Vector2(-half_size.x, half_size.y)
		]
		
		# Transform corners to global space
		for corner in corners:
			var global_corner = card.position + corner.rotated(card.rotation)
			min_pos = min_pos.min(global_corner)
			max_pos = max_pos.max(global_corner)
	
	# Add padding and return rect
	var padding := 10.0
	return Rect2(
		min_pos - Vector2(padding, padding),
		(max_pos - min_pos) + Vector2(padding * 2, padding * 2)
	)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var clicked_card = _get_card_at_position(event.position)
		if clicked_card:
			clicked_card.toggle_flip()

func _get_card_at_position(pos: Vector2) -> CardVisual:
	# Check cards in reverse order (top to bottom)
	for card in get_children():
		if not card is CardVisual:
			continue
			
		# Simple point-in-rectangle check (can be enhanced)
		var card_rect = Rect2(
			card.position - (card.texture.get_size() * CARD_SCALE / 2),
			card.texture.get_size() * CARD_SCALE
		)
		if card_rect.has_point(pos):
			return card
	return null
