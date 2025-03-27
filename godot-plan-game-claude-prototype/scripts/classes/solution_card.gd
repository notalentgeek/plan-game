class_name SolutionCard
extends Card

var solvable_problems: Array[String] = []
var is_ultimate: bool = false

func _init(p_id: String = "", p_name: String = "", p_description: String = "",
		p_texture_path: String = "", p_solvable_problems: Array[String] = [], p_is_ultimate: bool = false):
	var card_type = CardType.ULTIMATE if p_is_ultimate else CardType.SOLUTION
	super._init(p_id, p_name, p_description, card_type, p_texture_path)
	solvable_problems = p_solvable_problems
	is_ultimate = p_is_ultimate

func can_solve_problem(problem_letter: String) -> bool:
	return is_ultimate or problem_letter in solvable_problems

func _to_string() -> String:
	var prefix = "Ultimate" if is_ultimate else "Solution"
	return "[%s Card: %s (%s) - Solves: %s]" % [prefix, card_name, id, str(solvable_problems)]
