# scripts/classes/hand_layout_manager.gd
class_name HandLayoutManager
extends Resource

"""
Manages card positioning and layout calculations for hand display.
Supports multiple fan styles with configurable parameters.
"""

# Fan style enumeration
enum FanStyle {
	SYMMETRIC_ARC, # Cards arranged in a perfect arc
	ASYMMETRIC_SPREAD # Natural hand-held appearance with dramatic edge tilting
}

# Layout configuration properties
@export var fan_style: FanStyle = FanStyle.SYMMETRIC_ARC
@export var spread_angle_degrees: float = 90.0 # Total spread in degrees
@export var overlap_ratio: float = 0.7 # 0.0 = no overlap, 1.0 = complete overlap
@export var arc_radius: float = 400.0 # Radius for symmetric arc
@export var asymmetric_curve_factor: float = 0.3 # How much the asymmetric spread curves

# Card dimensions (should match CardVisual constants)
const CARD_WIDTH = 160
const CARD_HEIGHT = 240

# Calculated layout data
var card_positions: Array[Vector2] = []
var card_rotations: Array[float] = []
var layout_center: Vector2 = Vector2.ZERO
var layout_bounds: Rect2 = Rect2()

func _init(
	p_fan_style: FanStyle = FanStyle.SYMMETRIC_ARC,
	p_spread_angle: float = 90.0,
	p_overlap_ratio: float = 0.7,
	p_arc_radius: float = 400.0
) -> void:
	"""
	Initialize the layout manager with specified parameters.

	Args:
		p_fan_style: The style of fan arrangement
		p_spread_angle: Total spread angle in degrees
		p_overlap_ratio: How much cards overlap (0.0-1.0)
		p_arc_radius: Radius for arc-based layouts
	"""
	fan_style = p_fan_style
	spread_angle_degrees = p_spread_angle
	overlap_ratio = p_overlap_ratio
	arc_radius = p_arc_radius

func calculate_layout(card_count: int, container_size: Vector2) -> void:
	"""
	Calculate positions and rotations for all cards in the hand.

	Args:
		card_count: Number of cards to arrange
		container_size: Size of the container holding the hand
	"""
	if card_count <= 0:
		card_positions.clear()
		card_rotations.clear()
		return

	# Set layout center (bottom-center of container)
	layout_center = Vector2(container_size.x * 0.5, container_size.y * 0.85)

	# Clear previous calculations
	card_positions.clear()
	card_rotations.clear()

	# Calculate based on fan style
	match fan_style:
		FanStyle.SYMMETRIC_ARC:
			_calculate_symmetric_arc(card_count)
		FanStyle.ASYMMETRIC_SPREAD:
			_calculate_asymmetric_spread(card_count)

	# Update layout bounds
	_calculate_bounds()

func _calculate_symmetric_arc(card_count: int) -> void:
	"""
	Calculate positions for a symmetric arc arrangement.

	Args:
		card_count: Number of cards to arrange
	"""
	var spread_radians = deg_to_rad(spread_angle_degrees)
	var start_angle = - spread_radians * 0.5

	for i in range(card_count):
		var progress = 0.0 if card_count == 1 else float(i) / float(card_count - 1)
		var angle = start_angle + (progress * spread_radians)

		# Calculate position on arc
		var pos = Vector2(
			layout_center.x + cos(angle + PI * 0.5) * arc_radius,
			layout_center.y + sin(angle + PI * 0.5) * arc_radius
		)

		# Apply overlap adjustment
		if card_count > 1:
			var overlap_offset = _calculate_overlap_offset(i, card_count, angle)
			pos += overlap_offset

		card_positions.append(pos)
		card_rotations.append(rad_to_deg(angle))

func _calculate_asymmetric_spread(card_count: int) -> void:
	"""
	Calculate positions for an asymmetric, natural hand-held arrangement.

	Args:
		card_count: Number of cards to arrange
	"""
	var spread_radians = deg_to_rad(spread_angle_degrees)
	var start_angle = - spread_radians * 0.5

	for i in range(card_count):
		var progress = 0.0 if card_count == 1 else float(i) / float(card_count - 1)

		# Create asymmetric curve - edges tilt more dramatically
		var curve_progress = _asymmetric_curve(progress)
		var angle = start_angle + (curve_progress * spread_radians)

		# Calculate base position
		var base_radius = arc_radius * (0.8 + 0.4 * abs(progress - 0.5))
		var pos = Vector2(
			layout_center.x + cos(angle + PI * 0.5) * base_radius,
			layout_center.y + sin(angle + PI * 0.5) * base_radius
		)

		# Add natural variation
		var edge_factor = abs(progress - 0.5) * 2.0 # 0 at center, 1 at edges
		pos.y += edge_factor * 20 # Edge cards slightly lower

		# Apply overlap adjustment
		if card_count > 1:
			var overlap_offset = _calculate_overlap_offset(i, card_count, angle)
			pos += overlap_offset

		card_positions.append(pos)

		# Dramatic edge tilting for asymmetric style
		var edge_tilt = edge_factor * 15.0 # Additional tilt for edge cards
		var total_rotation = rad_to_deg(angle) + (edge_tilt * sign(progress - 0.5))
		card_rotations.append(total_rotation)

func _asymmetric_curve(progress: float) -> float:
	"""
	Apply asymmetric curve transformation to create natural spread.

	Args:
		progress: Linear progress from 0.0 to 1.0

	Returns:
		Curved progress value
	"""
	# Use power curve to make edges spread more dramatically
	var center_offset = progress - 0.5
	var sign_value = 1.0 if center_offset >= 0.0 else -1.0
	var curved = pow(abs(center_offset * 2.0), 1.0 + asymmetric_curve_factor) * 0.5
	return 0.5 + (curved * sign_value)

func _calculate_overlap_offset(card_index: int, card_count: int, angle: float) -> Vector2:
	"""
	Calculate position offset for card overlap.

	Args:
		card_index: Index of the current card
		card_count: Total number of cards
		angle: Card's rotation angle in radians

	Returns:
		Offset vector for overlap positioning
	"""
	if overlap_ratio <= 0.0:
		return Vector2.ZERO

	# Calculate overlap distance based on card width and overlap ratio
	var overlap_distance = CARD_WIDTH * overlap_ratio

	# For cards that aren't the first, offset towards the previous card
	if card_index > 0:
		var offset_direction = Vector2(-cos(angle), -sin(angle))
		return offset_direction * overlap_distance * card_index

	return Vector2.ZERO

func _calculate_bounds() -> void:
	"""
	Calculate the bounding rectangle containing all card positions.
	"""
	if card_positions.is_empty():
		layout_bounds = Rect2()
		return

	var min_x = card_positions[0].x
	var max_x = card_positions[0].x
	var min_y = card_positions[0].y
	var max_y = card_positions[0].y

	for pos in card_positions:
		min_x = min(min_x, pos.x - CARD_WIDTH * 0.5)
		max_x = max(max_x, pos.x + CARD_WIDTH * 0.5)
		min_y = min(min_y, pos.y - CARD_HEIGHT * 0.5)
		max_y = max(max_y, pos.y + CARD_HEIGHT * 0.5)

	layout_bounds = Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

func get_card_position(index: int) -> Vector2:
	"""
	Get the calculated position for a specific card.

	Args:
		index: Card index

	Returns:
		Position vector, or Vector2.ZERO if index is invalid
	"""
	if index >= 0 and index < card_positions.size():
		return card_positions[index]
	return Vector2.ZERO

func get_card_rotation(index: int) -> float:
	"""
	Get the calculated rotation for a specific card.

	Args:
		index: Card index

	Returns:
		Rotation in degrees, or 0.0 if index is invalid
	"""
	if index >= 0 and index < card_rotations.size():
		return card_rotations[index]
	return 0.0

func get_card_count() -> int:
	"""
	Get the number of cards in the current layout.

	Returns:
		Number of positioned cards
	"""
	return card_positions.size()

func is_layout_valid() -> bool:
	"""
	Check if the current layout has valid data.

	Returns:
		True if layout contains positioned cards
	"""
	return not card_positions.is_empty()

func get_layout_info() -> Dictionary:
	"""
	Get comprehensive layout information for debugging.

	Returns:
		Dictionary containing layout metrics and parameters
	"""
	return {
		"fan_style": FanStyle.keys()[fan_style],
		"spread_angle_degrees": spread_angle_degrees,
		"overlap_ratio": overlap_ratio,
		"arc_radius": arc_radius,
		"card_count": get_card_count(),
		"layout_center": layout_center,
		"layout_bounds": layout_bounds,
		"is_valid": is_layout_valid()
	}

func _to_string() -> String:
	"""
	Convert layout manager to string representation for debugging.

	Returns:
		String representation of the layout state
	"""
	return "[HandLayoutManager: %s, %d cards, %.1f° spread]" % [
		FanStyle.keys()[fan_style],
		get_card_count(),
		spread_angle_degrees
	]
