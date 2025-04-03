class_name Card
extends Resource

enum CardType {
	PROBLEM,
	SOLUTION,
	ULTIMATE
}

var id: String
var card_name: String
var description: String
var card_type: int
var texture_path: String
var texture: Texture = null

func _init(p_id: String = "", p_name: String = "", p_description: String = "",
		p_card_type: int = CardType.PROBLEM, p_texture_path: String = ""):
	id = p_id
	card_name = p_name
	description = p_description
	card_type = p_card_type
	texture_path = p_texture_path

	if !texture_path.is_empty():
		# Try to load the texture, but don't crash if it doesn't exist
		if ResourceLoader.exists(texture_path):
			texture = load(texture_path)
		else:
			# Load a placeholder instead
			texture = null
			print("Warning: Missing texture for %s at path %s" % [card_name, texture_path])

func get_texture() -> Texture:
	if texture == null and !texture_path.is_empty():
		if ResourceLoader.exists(texture_path):
			texture = load(texture_path)
		else:
			# Return a default texture
			var placeholder_path = "res://assets/cards/placeholder.png"
			if ResourceLoader.exists(placeholder_path):
				texture = load(placeholder_path)
	return texture
