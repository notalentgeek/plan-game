# scripts/classes/card.gd
# Base class for all cards in the PLAN game
class_name Card
extends Resource

"""
Represents a base card in the PLAN card game.
Provides common functionality and properties for all card types.
"""

# Card type enumeration
enum CardType {
	PROBLEM, # Environmental problem cards
	SOLUTION, # Standard solution cards
	ULTIMATE # Ultimate solution cards that can solve any problem
}

# Card properties
var id: String # Unique identifier for the card
var card_name: String # Display name of the card
var description: String # Card description text
var card_type: int # Type from CardType enum
var texture_path: String # Path to the card's texture
var texture: Texture2D = null # Loaded texture resource

func _init(
		p_id: String = "",
		p_name: String = "",
		p_description: String = "",
		p_card_type: int = CardType.PROBLEM,
		p_texture_path: String = ""
) -> void:
	"""
	Initialize a new card with the specified properties.

	Args:
		p_id: Unique identifier for the card
		p_name: Display name of the card
		p_description: Card description text
		p_card_type: Type from CardType enum
		p_texture_path: Path to the card's texture
	"""
	id = p_id
	card_name = p_name
	description = p_description
	card_type = p_card_type
	texture_path = p_texture_path

	# Load texture if path is provided and exists
	if !texture_path.is_empty():
		if ResourceLoader.exists(texture_path):
			texture = load(texture_path)

func get_texture() -> Texture2D:
	"""
	Get the card's texture, loading it if necessary.

	Returns:
		The card's texture, or null if not available
	"""
	if texture == null and !texture_path.is_empty():
		print("Loading texture from path: ", texture_path)
		if ResourceLoader.exists(texture_path):
			texture = load(texture_path)
			if texture:
				print("Successfully loaded texture")
			else:
				print("Failed to load texture despite file existing")
		else:
			print("Texture file does not exist at path: ", texture_path)
	return texture

func _to_string() -> String:
	"""
	Convert the card to a string representation for debugging.

	Returns:
		A string representation of the card
	"""
	return "[Card: %s (%s)]" % [card_name, id]
