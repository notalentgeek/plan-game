# scripts/classes/problem_card.gd
# Problem card class for environmental issues in the PLAN game
class_name ProblemCard
extends Card

"""
Represents a problem card in the PLAN card game.
Problem cards define environmental issues that need solutions.
Each problem has a letter code and severity index.
"""

# Problem-specific properties
var letter_code: String  # Alphabetical identifier (A-R)
var severity_index: int  # Numerical severity (1-10)

func _init(p_id: String = "", p_name: String = "", p_description: String = "",
		p_texture_path: String = "", p_letter_code: String = "", p_severity_index: int = 1) -> void:
	"""
	Initialize a new problem card with the specified properties.

	Args:
		p_id: Unique identifier for the card
		p_name: Display name of the card
		p_description: Card description text
		p_texture_path: Path to the card's texture
		p_letter_code: Alphabetical identifier for the problem (A-R)
		p_severity_index: Numerical severity rating (1-10)
	"""
	super._init(p_id, p_name, p_description, CardType.PROBLEM, p_texture_path)
	letter_code = p_letter_code
	severity_index = p_severity_index

func _to_string() -> String:
	"""
	Convert the problem card to a string representation for debugging.

	Returns:
		A string representation of the problem card
	"""
	return "[Problem Card: %s (%s) - Letter: %s, Index: %d]" % [card_name, id, letter_code, severity_index]
