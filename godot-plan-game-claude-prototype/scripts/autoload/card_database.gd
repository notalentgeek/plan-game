# card_database.gd
# A singleton that manages all cards in the Plan card game
extends Node

# Dictionary to store all problem cards by ID
var problem_cards: Dictionary = {}

# Dictionary to store all solution cards by ID
var solution_cards: Dictionary = {}

# Ready-to-use decks
var problem_deck: Deck = Deck.new()
var solution_deck: Deck = Deck.new()

## Built-in Methods

func _ready() -> void:
	# Initialize cards
	_initialize_problem_cards()
	_initialize_solution_cards()

## Card Initialization Methods

func _initialize_problem_cards() -> void:
	# According to the document, there are 18 problem cards with 3 copies each
	# These are example cards - in a real game, you'd have actual data
	# Problem card format: id, name, description, texture_path, letter_code, severity_index
	var problems = [
		["p1", "Climate Change", "Rising global temperatures leading to extreme weather events.", "res://assets/cards/problem_cards/climate_change.png", "A", 10],
		["p2", "Deforestation", "Destruction of forests for agricultural and urban expansion.", "res://assets/cards/problem_cards/deforestation.png", "B", 8],
		["p3", "Air Pollution", "Contamination of air with harmful substances.", "res://assets/cards/problem_cards/air_pollution.png", "C", 7],
		["p4", "Water Pollution", "Contamination of water bodies with harmful substances.", "res://assets/cards/problem_cards/water_pollution.png", "D", 7],
		["p5", "Land Pollution", "Contamination of land with harmful substances.", "res://assets/cards/problem_cards/land_pollution.png", "E", 6],
		["p6", "Biodiversity Loss", "Reduction in variety of life forms in particular habitats.", "res://assets/cards/problem_cards/biodiversity_loss.png", "F", 9],
		["p7", "Plastic Waste", "Accumulation of plastic waste in oceans and landfills.", "res://assets/cards/problem_cards/plastic_waste.png", "G", 8],
		["p8", "Food Waste", "Discarding of food fit for consumption.", "res://assets/cards/problem_cards/food_waste.png", "H", 5],
		["p9", "Energy Waste", "Inefficient use of energy resources.", "res://assets/cards/problem_cards/energy_waste.png", "I", 6],
		["p10", "Soil Degradation", "Declining soil quality due to improper management.", "res://assets/cards/problem_cards/soil_degradation.png", "J", 7],
		["p11", "Overfishing", "Excessive fishing leading to depletion of fish stocks.", "res://assets/cards/problem_cards/overfishing.png", "K", 7],
		["p12", "Ocean Acidification", "Decreasing pH of oceans due to CO2 absorption.", "res://assets/cards/problem_cards/ocean_acidification.png", "L", 8],
		["p13", "Waste Management", "Improper disposal and management of waste.", "res://assets/cards/problem_cards/waste_management.png", "M", 6],
		["p14", "Ozone Depletion", "Thinning of the ozone layer in the atmosphere.", "res://assets/cards/problem_cards/ozone_depletion.png", "N", 8],
		["p15", "Urban Sprawl", "Uncontrolled expansion of urban areas.", "res://assets/cards/problem_cards/urban_sprawl.png", "O", 5],
		["p16", "Desertification", "Land degradation in arid regions.", "res://assets/cards/problem_cards/desertification.png", "P", 7],
		["p17", "Habitat Destruction", "Destruction of natural habitats for human activities.", "res://assets/cards/problem_cards/habitat_destruction.png", "Q", 8],
		["p18", "Resource Depletion", "Exhaustion of natural resources due to overexploitation.", "res://assets/cards/problem_cards/resource_depletion.png", "R", 9]
	]

	for problem in problems:
		var card = ProblemCard.new(
			problem[0], # id
			problem[1], # name
			problem[2], # description
			problem[3], # texture_path
			problem[4], # letter_code
			problem[5] # severity_index
		)
		problem_cards[card.id] = card

		# According to the document, each problem card has 3 copies
		for i in range(3):
			problem_deck.add_card(card.duplicate())

func _initialize_solution_cards() -> void:
	# According to the document, there are 17 solution cards with 2 copies each
	# except for the 2 ultimate cards with 1 copy each
	# Solution card format: id, name, description, texture_path, solvable_problems, is_ultimate
	var solutions = [
		["s1", "Renewable Energy", "Energy from renewable sources like solar, wind, etc.", "res://assets/cards/solution_cards/renewable_energy.png", ["A", "I"], false],
		["s2", "Recycling", "Converting waste materials into reusable objects.", "res://assets/cards/solution_cards/recycling.png", ["G", "M"], false],
		["s3", "Reforestation", "Planting trees in deforested areas.", "res://assets/cards/solution_cards/reforestation.png", ["B", "F", "P"], false],
		["s4", "Sustainable Agriculture", "Farming practices that preserve ecosystems.", "res://assets/cards/solution_cards/sustainable_agriculture.png", ["B", "E", "J"], false],
		["s5", "Water Conservation", "Reducing water usage and preventing waste.", "res://assets/cards/solution_cards/water_conservation.png", ["D", "H"], false],
		["s6", "Clean Energy", "Energy that doesn't produce pollution.", "res://assets/cards/solution_cards/clean_energy.png", ["A", "C", "I"], false],
		["s7", "Waste Reduction", "Minimizing waste production.", "res://assets/cards/solution_cards/waste_reduction.png", ["G", "H", "M"], false],
		["s8", "Green Transportation", "Using eco-friendly modes of transport.", "res://assets/cards/solution_cards/green_transportation.png", ["A", "C"], false],
		["s9", "Sustainable Fishing", "Fishing practices that maintain fish populations.", "res://assets/cards/solution_cards/sustainable_fishing.png", ["K", "F"], false],
		["s10", "Biodiversity Protection", "Preserving and protecting various species.", "res://assets/cards/solution_cards/biodiversity_protection.png", ["F", "Q"], false],
		["s11", "Reduced Consumption", "Consuming less to reduce resource depletion.", "res://assets/cards/solution_cards/reduced_consumption.png", ["H", "I", "R"], false],
		["s12", "Pollution Control", "Measures to reduce pollution emissions.", "res://assets/cards/solution_cards/pollution_control.png", ["C", "D", "E"], false],
		["s13", "Urban Planning", "Designing cities to be more sustainable.", "res://assets/cards/solution_cards/urban_planning.png", ["O", "E"], false],
		["s14", "Sustainable Technology", "Technology that minimizes environmental impact.", "res://assets/cards/solution_cards/sustainable_technology.png", ["A", "I", "R"], false],
		["s15", "Ocean Conservation", "Protecting and preserving ocean ecosystems.", "res://assets/cards/solution_cards/ocean_conservation.png", ["K", "L"], false],
		["su1", "Environmental Education", "Educating people about environmental issues.", "res://assets/cards/solution_cards/environmental_education.png", [], true],
		["su2", "Eco-friendly Practices", "Practices that minimize harm to the environment.", "res://assets/cards/solution_cards/eco_friendly_practices.png", [], true]
	]

	for solution in solutions:
		# Convert generic Array to Array[String]
		var solvable_problems: Array[String] = []
		for prob in solution[4]:
			solvable_problems.append(prob)

		var card = SolutionCard.new(
			solution[0], # id
			solution[1], # name
			solution[2], # description
			solution[3], # texture_path
			solvable_problems, # solvable_problems (now correctly typed)
			solution[5] # is_ultimate
		)
		solution_cards[card.id] = card

		# According to the rules, regular solution cards have 2 copies each,
		# ultimate cards have only 1 copy each
		var copies = 1 if card.is_ultimate else 2
		for i in range(copies):
			solution_deck.add_card(card.duplicate())

## Public Methods

func get_problem_card(id: String) -> ProblemCard:
	if problem_cards.has(id):
		return problem_cards[id]
	push_error("Problem card with ID '%s' not found" % id)
	return null

func get_solution_card(id: String) -> SolutionCard:
	if solution_cards.has(id):
		return solution_cards[id]
	push_error("Solution card with ID '%s' not found" % id)
	return null

func get_fresh_problem_deck() -> Deck:
	var deck = problem_deck.duplicate()
	deck.shuffle()
	return deck

func get_fresh_solution_deck() -> Deck:
	var deck = solution_deck.duplicate()
	deck.shuffle()
	return deck

func can_solution_solve_problem(solution_card: SolutionCard, problem_card: ProblemCard) -> bool:
	if solution_card.is_ultimate:
		return true
	return solution_card.can_solve_problem(problem_card.letter_code)

## Helper Methods

func _print_all_cards() -> void:
	print("Problem Cards:")
	for id in problem_cards:
		print("  ", problem_cards[id])

	print("Solution Cards:")
	for id in solution_cards:
		print("  ", solution_cards[id])
