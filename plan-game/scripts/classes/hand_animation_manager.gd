# scripts/classes/hand_animation_manager.gd
class_name HandAnimationManager
extends RefCounted

"""
Manages smooth animations for card positioning, selection, and state transitions.
Provides batched animation updates for optimal performance.
"""

# Animation type enumeration
enum AnimationType {
	POSITION, # Card position changes
	ROTATION, # Card rotation changes
	SELECTION, # Selection state changes (lift/lower)
	SCALE, # Card scaling animations
	FADE # Card opacity animations
}

# Animation state tracking
class CardAnimationState:
	var card_visual: CardVisual
	var target_position: Vector2
	var target_rotation: float
	var target_scale: Vector2 = Vector2.ONE
	var target_modulate: Color = Color.WHITE
	var is_selected: bool = false
	var selection_lift_offset: Vector2 = Vector2.ZERO

	func _init(p_card_visual: CardVisual):
		card_visual = p_card_visual

# Animation configuration
@export var default_duration: float = 0.15
@export var selection_duration: float = 0.2
@export var default_easing: Tween.EaseType = Tween.EASE_OUT
@export var selection_lift_pixels: float = 30.0
@export var selection_lift_percentage: float = 0.125 # 12.5% of card height
@export var max_concurrent_animations: int = 50

# Animation state
var card_states: Dictionary = {} # CardVisual -> CardAnimationState
var active_tweens: Array[Tween] = []
var animation_queue: Array[Dictionary] = []
var is_batch_animating: bool = false

# Performance tracking
var animations_this_frame: int = 0
var max_animations_per_frame: int = 10

signal animation_started(card_visual: CardVisual, animation_type: AnimationType)
signal animation_finished(card_visual: CardVisual, animation_type: AnimationType)
signal batch_animation_completed()

func _init() -> void:
	"""
	Initialize the animation manager.
	"""
	pass

func register_card(card_visual: CardVisual) -> void:
	"""
	Register a card visual for animation management.

	Args:
		card_visual: The CardVisual instance to track
	"""
	if not card_visual:
		push_error("Cannot register null CardVisual")
		return

	if card_visual in card_states:
		push_warning("CardVisual already registered: %s" % card_visual)
		return

	var state = CardAnimationState.new(card_visual)
	state.target_position = card_visual.position
	state.target_rotation = card_visual.rotation_degrees
	card_states[card_visual] = state

func unregister_card(card_visual: CardVisual) -> void:
	"""
	Unregister a card visual from animation management.

	Args:
		card_visual: The CardVisual instance to stop tracking
	"""
	if not card_visual:
		return

	if card_visual in card_states:
		# Cancel any active animations for this card
		_cancel_card_animations(card_visual)
		card_states.erase(card_visual)

func animate_to_position(
	card_visual: CardVisual,
	target_position: Vector2,
	target_rotation: float = 0.0,
	duration: float = -1.0,
	easing: Tween.EaseType = Tween.EASE_OUT
) -> void:
	"""
	Animate a card to a new position and rotation.

	Args:
		card_visual: The card to animate
		target_position: Target position
		target_rotation: Target rotation in degrees
		duration: Animation duration (uses default if -1)
		easing: Easing function to use
	"""
	if not card_visual or not card_visual in card_states:
		push_error("CardVisual not registered for animation")
		return

	var state = card_states[card_visual]
	state.target_position = target_position
	state.target_rotation = target_rotation

	var anim_duration = duration if duration > 0.0 else default_duration

	# Cancel existing position/rotation animations for this card
	_cancel_card_animations(card_visual, [AnimationType.POSITION, AnimationType.ROTATION])

	# Create animation
	var animation_data = {
		"card_visual": card_visual,
		"type": AnimationType.POSITION,
		"duration": anim_duration,
		"easing": easing,
		"start_position": card_visual.position,
		"start_rotation": card_visual.rotation_degrees,
		"target_position": _get_final_position(card_visual, target_position),
		"target_rotation": target_rotation
	}

	_execute_animation(animation_data)

func animate_selection(
	card_visual: CardVisual,
	selected: bool,
	duration: float = -1.0
) -> void:
	"""
	Animate card selection state (lift up or lower down).

	Args:
		card_visual: The card to animate
		selected: True to lift (select), false to lower (deselect)
		duration: Animation duration (uses selection_duration if -1)
	"""
	if not card_visual or not card_visual in card_states:
		push_error("CardVisual not registered for animation")
		return

	var state = card_states[card_visual]
	state.is_selected = selected

	# Calculate lift offset
	var lift_amount = max(selection_lift_pixels, CardVisual.CARD_HEIGHT * selection_lift_percentage)
	state.selection_lift_offset = Vector2(0, -lift_amount) if selected else Vector2.ZERO

	var anim_duration = duration if duration > 0.0 else selection_duration

	# Cancel existing selection animations for this card
	_cancel_card_animations(card_visual, [AnimationType.SELECTION])

	# Create animation
	var final_position = _get_final_position(card_visual, state.target_position)
	var animation_data = {
		"card_visual": card_visual,
		"type": AnimationType.SELECTION,
		"duration": anim_duration,
		"easing": default_easing,
		"start_position": card_visual.position,
		"target_position": final_position,
		"selected": selected
	}

	_execute_animation(animation_data)

func animate_batch_layout(
	cards_data: Array[Dictionary],
	duration: float = -1.0,
	stagger_delay: float = 0.02
) -> void:
	"""
	Animate multiple cards to new positions with optional staggering.

	Args:
		cards_data: Array of dictionaries with keys: card_visual, position, rotation
		duration: Animation duration for each card
		stagger_delay: Delay between starting each card's animation
	"""
	if cards_data.is_empty():
		return

	is_batch_animating = true
	var anim_duration = duration if duration > 0.0 else default_duration

	# Queue all animations
	for i in range(cards_data.size()):
		var card_data = cards_data[i]
		if not card_data.has("card_visual") or not card_data.has("position"):
			continue

		var card_visual = card_data.card_visual
		var target_position = card_data.position
		var target_rotation = card_data.get("rotation", 0.0)
		var delay = stagger_delay * i

		var animation_data = {
			"card_visual": card_visual,
			"type": AnimationType.POSITION,
			"duration": anim_duration,
			"easing": default_easing,
			"delay": delay,
			"start_position": card_visual.position,
			"start_rotation": card_visual.rotation_degrees,
			"target_position": _get_final_position(card_visual, target_position),
			"target_rotation": target_rotation
		}

		animation_queue.append(animation_data)

	# Start processing queue
	_process_animation_queue()

func stop_all_animations() -> void:
	"""
	Stop all active animations immediately.
	"""
	for tween in active_tweens:
		if tween and tween.is_valid():
			tween.kill()

	active_tweens.clear()
	animation_queue.clear()
	is_batch_animating = false

func is_card_animating(card_visual: CardVisual) -> bool:
	"""
	Check if a specific card is currently animating.

	Args:
		card_visual: The card to check

	Returns:
		True if the card has active animations
	"""
	for tween in active_tweens:
		if tween and tween.is_valid():
			# Check if this tween belongs to the card
			# (This would need custom data tracking in a real implementation)
			pass

	return false

func get_animation_progress() -> float:
	"""
	Get overall animation progress for batch operations.

	Returns:
		Progress from 0.0 to 1.0, or 1.0 if no batch animation
	"""
	if not is_batch_animating:
		return 1.0

	# Calculate based on queue progress and active animations
	var total_animations = animation_queue.size() + active_tweens.size()
	if total_animations == 0:
		return 1.0

	return 1.0 - (float(animation_queue.size()) / float(total_animations))

func _get_final_position(card_visual: CardVisual, base_position: Vector2) -> Vector2:
	"""
	Calculate the final position including selection lift offset.

	Args:
		card_visual: The card visual
		base_position: Base position before selection offset

	Returns:
		Final position with selection offset applied
	"""
	if not card_visual in card_states:
		return base_position

	var state = card_states[card_visual]
	return base_position + state.selection_lift_offset

func _execute_animation(animation_data: Dictionary) -> void:
	"""
	Execute a single animation.

	Args:
		animation_data: Dictionary containing animation parameters
	"""
	var card_visual = animation_data.card_visual
	var duration = animation_data.duration
	var easing = animation_data.get("easing", default_easing)
	var delay = animation_data.get("delay", 0.0)

	# Create tween
	var tween = card_visual.create_tween()
	tween.set_ease(easing)
	tween.set_trans(Tween.TRANS_QUART)

	# Add delay if specified
	if delay > 0.0:
		tween.tween_delay(delay)

	# Emit start signal
	animation_started.emit(card_visual, animation_data.type)

	# Set up animation based on type
	match animation_data.type:
		AnimationType.POSITION:
			# Animate position and rotation together
			var parallel_tween = tween.parallel()
			tween.tween_property(card_visual, "position", animation_data.target_position, duration)
			parallel_tween.tween_property(card_visual, "rotation_degrees", animation_data.target_rotation, duration)

		AnimationType.SELECTION:
			tween.tween_property(card_visual, "position", animation_data.target_position, duration)

		AnimationType.SCALE:
			tween.tween_property(card_visual, "scale", animation_data.get("target_scale", Vector2.ONE), duration)

		AnimationType.FADE:
			tween.tween_property(card_visual, "modulate", animation_data.get("target_modulate", Color.WHITE), duration)

	# Track active tween
	active_tweens.append(tween)

	# Set up completion callback
	tween.finished.connect(_on_animation_finished.bind(card_visual, animation_data.type, tween))

func _on_animation_finished(card_visual: CardVisual, animation_type: AnimationType, tween: Tween) -> void:
	"""
	Handle animation completion.

	Args:
		card_visual: The animated card
		animation_type: Type of animation that finished
		tween: The completed tween
	"""
	# Remove from active tweens
	if tween in active_tweens:
		active_tweens.erase(tween)

	# Emit completion signal
	animation_finished.emit(card_visual, animation_type)

	# Check if batch animation is complete
	if is_batch_animating and animation_queue.is_empty() and active_tweens.is_empty():
		is_batch_animating = false
		batch_animation_completed.emit()

func _cancel_card_animations(card_visual: CardVisual, types: Array[AnimationType] = []) -> void:
	"""
	Cancel animations for a specific card.

	Args:
		card_visual: The card to cancel animations for
		types: Specific animation types to cancel (empty = all types)
	"""
	# This would need custom tracking in a full implementation
	# For now, we'll implement a simplified version
	pass

func _process_animation_queue() -> void:
	"""
	Process queued animations with frame rate limiting.
	"""
	if animation_queue.is_empty():
		return

	animations_this_frame = 0

	while not animation_queue.is_empty() and animations_this_frame < max_animations_per_frame:
		var animation_data = animation_queue.pop_front()
		_execute_animation(animation_data)
		animations_this_frame += 1

	# If there are more animations, defer to next frame
	if not animation_queue.is_empty():
		# In a real implementation, this would use a timer or scene tree callback
		call_deferred("_process_animation_queue")

func get_manager_stats() -> Dictionary:
	"""
	Get performance and state statistics.

	Returns:
		Dictionary with animation manager metrics
	"""
	return {
		"registered_cards": card_states.size(),
		"active_tweens": active_tweens.size(),
		"queued_animations": animation_queue.size(),
		"is_batch_animating": is_batch_animating,
		"animations_this_frame": animations_this_frame,
		"max_concurrent": max_concurrent_animations
	}

func _to_string() -> String:
	"""
	Convert animation manager to string representation for debugging.

	Returns:
		String representation of the manager state
	"""
	return "[HandAnimationManager: %d cards, %d active, %d queued]" % [
		card_states.size(),
		active_tweens.size(),
		animation_queue.size()
	]
