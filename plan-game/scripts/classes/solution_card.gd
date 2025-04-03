# scripts/classes/solution_card.gd
# Solution card class for environmental actions in the PLAN game
class_name SolutionCard
extends Card

"""
Represents a solution card in the PLAN card game.
Solution cards can solve specific problem cards, while
Ultimate solution cards can solve any problem.
"""

# Solution-specific properties
var solvable_problems: Array[String] = [] # Problem letter codes this solution can solve
var is_ultimate: bool = false # If true, can solve any problem

func _init(
		p_id: String = "",
		p_name: String = "",
		p_description: String = "",
		p_texture_path: String = "",
		p_solvable_problems: Array[String] = [],
		p_is_ultimate: bool = false
) -> void:
	"""
	Initialize a new solution card with the specified properties.

	Args:
		p_id: Unique identifier for the card
		p_name: Display name of the card
		p_description: Card description text
		p_texture_path: Path to the card's texture
		p_solvable_problems: Array of letter codes this solution can solve
		p_is_ultimate: Whether this is an ultimate card that can solve any problem
	"""
	var type_value = CardType.ULTIMATE if p_is_ultimate else CardType.SOLUTION
	super._init(p_id, p_name, p_description, type_value, p_texture_path)
	solvable_problems = p_solvable_problems
	is_ultimate = p_is_ultimate

func can_solve_problem(problem_letter: String) -> bool:
	"""
	Check if this solution can solve a problem with the given letter code.

	Args:
		problem_letter: The letter code of the problem to check

	Returns:
		True if this solution can solve the problem, false otherwise
	"""
	return is_ultimate or problem_letter in solvable_problems

func _to_string() -> String:
	"""
	Convert the solution card to a string representation for debugging.

	Returns:
		A string representation of the solution card
	"""
	var prefix = "Ultimate" if is_ultimate else "Solution"
	var problems_str = "["
	for i in range(solvable_problems.size()):
		problems_str += solvable_problems[i]
		if i < solvable_problems.size() - 1:
			problems_str += ", "
	problems_str += "]"

	return "[%s Card: %s (%s) - Solves: %s]" % [
		prefix,
		card_name,
		id,
		problems_str
	]
