class_name ProblemCard
extends Card

var letter_code: String
var severity_index: int

func _init(p_id: String = "", p_name: String = "", p_description: String = "",
		p_texture_path: String = "", p_letter_code: String = "", p_severity_index: int = 1):
	super._init(p_id, p_name, p_description, CardType.PROBLEM, p_texture_path)
	letter_code = p_letter_code
	severity_index = p_severity_index

func _to_string() -> String:
	return "[Problem Card: %s (%s) - Letter: %s, Index: %d]" % [card_name, id, letter_code, severity_index]
