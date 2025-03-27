# table.gd
# Table area for the Plan Card Game
extends Panel

# Visual properties
@export var table_color: Color = Color(0.2, 0.5, 0.3, 1.0) # Green felt

# References
@onready var discard_pile = $DiscardPile
@onready var discard_count_label = $DiscardPile/CountLabel

# Managers
@onready var game_manager = get_node("/root/GameManager")

func _ready() -> void:
	# Set table appearance
	self_modulate = table_color

	# Connect signals
	game_manager.connect("card_played", Callable(self, "_on_card_played"))

	# Initialize discard count
	_update_discard_count()

func _on_card_played(player_id: int, card: Card) -> void:
	"""
	Update discard pile when a card is played.
	"""
	_update_discard_count()

func _update_discard_count() -> void:
	"""
	Update the discard pile count label.
	"""
	var count = game_manager.discard_pile.size()
	discard_count_label.text = str(count)

	# Hide if empty
	discard_pile.visible = count > 0
