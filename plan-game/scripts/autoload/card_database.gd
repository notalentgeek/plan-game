# scripts/autoload/card_database.gd
extends Node
class_name CardDatabase

"""
Singleton that manages the collection of all card definitions in the PLAN game.
Responsible for initializing, storing, and providing access to problem and solution cards.
"""

# Dictionary of all problem cards, indexed by ID
var _problem_cards: Dictionary = {}

# Dictionary of all solution cards, indexed by ID
var _solution_cards: Dictionary = {}

# List of problem letter codes (A-R)
const PROBLEM_CODES = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
						"L", "M", "N", "O", "P", "Q", "R"]

# Card initialization flags
var _cards_initialized: bool = false

func _ready() -> void:
	"""
	Initialize the card database when the singleton is loaded.
	"""
	initialize_cards()

func initialize_cards() -> void:
	"""
	Initialize all problem and solution cards.
	Only initializes once, even if called multiple times.
	"""
	if _cards_initialized:
		return

	_initialize_problem_cards()
	_initialize_solution_cards()

	_cards_initialized = true
	print("CardDatabase: Initialized %d problem cards and %d solution cards" % [
		_problem_cards.size(),
		_solution_cards.size()
	])

func _initialize_problem_cards() -> void:
	"""
	Initialize all 18 problem cards (A through R).
	Each problem has a unique letter code and severity index.
	"""
	# Clear existing data if any
	_problem_cards.clear()

	# Create all problem cards
	_add_problem_card(
		"p_a",
		"Air Pollution",
		"Contamination of air with harmful substances like smoke, dust, and gases.",
		"res://assets/cards/problem_cards/air_pollution.png",
		"A",
		7
	)

	_add_problem_card(
		"p_b",
		"Water Pollution",
		"Contamination of water bodies with chemicals, waste, and other pollutants.",
		"res://assets/cards/problem_cards/water_pollution.png",
		"B",
		8
	)

	_add_problem_card(
		"p_c",
		"Deforestation",
		"Removal of forests for agricultural, urban, or industrial use.",
		"res://assets/cards/problem_cards/deforestation.png",
		"C",
		8
	)

	_add_problem_card(
		"p_d",
		"Climate Change",
		"Long-term alteration of temperature and weather patterns.",
		"res://assets/cards/problem_cards/climate_change.png",
		"D",
		9
	)

	_add_problem_card(
		"p_e",
		"Soil Erosion",
		"Removal of topsoil faster than it can form, often due to poor farming practices.",
		"res://assets/cards/problem_cards/soil_erosion.png",
		"E",
		6
	)

	_add_problem_card(
		"p_f",
		"Waste Management",
		"Improper disposal and handling of waste materials.",
		"res://assets/cards/problem_cards/waste_management.png",
		"F",
		6
	)

	_add_problem_card(
		"p_g",
		"Loss of Biodiversity",
		"Decline in variety of plant and animal species on Earth.",
		"res://assets/cards/problem_cards/biodiversity_loss.png",
		"G",
		8
	)

	_add_problem_card(
		"p_h",
		"Ocean Acidification",
		"Decrease in pH of Earth's oceans caused by CO2 absorption.",
		"res://assets/cards/problem_cards/ocean_acidification.png",
		"H",
		7
	)

	_add_problem_card(
		"p_i",
		"Plastic Pollution",
		"Accumulation of plastic waste in the environment.",
		"res://assets/cards/problem_cards/plastic_pollution.png",
		"I",
		7
	)

	_add_problem_card(
		"p_j",
		"Overfishing",
		"Removal of fish species at a rate too high for reproduction.",
		"res://assets/cards/problem_cards/overfishing.png",
		"J",
		6
	)

	_add_problem_card(
		"p_k",
		"Ozone Depletion",
		"Thinning of the ozone layer caused by certain chemicals.",
		"res://assets/cards/problem_cards/ozone_depletion.png",
		"K",
		7
	)

	_add_problem_card(
		"p_l",
		"Resource Depletion",
		"Consumption of natural resources faster than they can be replenished.",
		"res://assets/cards/problem_cards/resource_depletion.png",
		"L",
		8
	)

	_add_problem_card(
		"p_m",
		"Land Degradation",
		"Reduction of land capacity to provide ecosystem services.",
		"res://assets/cards/problem_cards/land_degradation.png",
		"M",
		6
	)

	_add_problem_card(
		"p_n",
		"Desertification",
		"Land degradation in arid and semi-arid regions.",
		"res://assets/cards/problem_cards/desertification.png",
		"N",
		7
	)

	_add_problem_card(
		"p_o",
		"Urban Sprawl",
		"Unplanned expansion of urban areas into surrounding regions.",
		"res://assets/cards/problem_cards/urban_sprawl.png",
		"O",
		5
	)

	_add_problem_card(
		"p_p",
		"Energy Crisis",
		"Shortage or price rise of energy resources.",
		"res://assets/cards/problem_cards/energy_crisis.png",
		"P",
		7
	)

	_add_problem_card(
		"p_q",
		"Chemical Pollution",
		"Release of harmful chemicals into environment.",
		"res://assets/cards/problem_cards/chemical_pollution.png",
		"Q",
		7
	)

	_add_problem_card(
		"p_r",
		"Noise Pollution",
		"Excessive noise that disturbs the environment and human health.",
		"res://assets/cards/problem_cards/noise_pollution.png",
		"R",
		4
	)

func _add_problem_card(
		id: String,
		card_name: String,
		description: String,
		texture_path: String,
		letter_code: String,
		severity_index: int
) -> void:
	"""
	Create and add a problem card to the database.

	Args:
		id: Unique identifier for the card
		card_name: Display name of the card
		description: Card description text
		texture_path: Path to the card's texture
		letter_code: Alphabetical identifier for the problem (A-R)
		severity_index: Numerical severity rating (1-10)
	"""
	var card = ProblemCard.new(
		id,
		card_name,
		description,
		texture_path,
		letter_code,
		severity_index
	)
	_problem_cards[id] = card

func _initialize_solution_cards() -> void:
	"""
	Initialize all 17 solution cards, including 15 standard solution cards
	and 2 ultimate solution cards.
	"""
	# Clear existing data if any
	_solution_cards.clear()

	# Add standard solution cards
	_add_solution_card(
		"s_01",
		"Renewable Energy",
		"Transitioning to clean, renewable energy sources like solar and wind.",
		"res://assets/cards/solution_cards/renewable_energy.png",
		["D", "P"],
		false
	)

	_add_solution_card(
		"s_02",
		"Reforestation",
		"Planting trees in areas that have been deforested.",
		"res://assets/cards/solution_cards/reforestation.png",
		["C", "D", "E", "N"],
		false
	)

	_add_solution_card(
		"s_03",
		"Waste Recycling",
		"Processing used materials into new products to prevent waste.",
		"res://assets/cards/solution_cards/waste_recycling.png",
		["F", "I", "L"],
		false
	)

	_add_solution_card(
		"s_04",
		"Water Conservation",
		"Efficient use and management of water resources.",
		"res://assets/cards/solution_cards/water_conservation.png",
		["B", "L"],
		false
	)

	_add_solution_card(
		"s_05",
		"Sustainable Farming",
		"Agricultural practices that protect soil, water, and biodiversity.",
		"res://assets/cards/solution_cards/sustainable_farming.png",
		["E", "M", "N"],
		false
	)

	_add_solution_card(
		"s_06",
		"Clean Transport",
		"Using electric vehicles, public transit, and cycling to reduce emissions.",
		"res://assets/cards/solution_cards/clean_transport.png",
		["A", "D", "R"],
		false
	)

	_add_solution_card(
		"s_07",
		"Ocean Protection",
		"Establishing marine reserves and reducing ocean pollution.",
		"res://assets/cards/solution_cards/ocean_protection.png",
		["H", "I", "J"],
		false
	)

	_add_solution_card(
		"s_08",
		"Air Quality Management",
		"Monitoring and reducing air pollutants through regulations.",
		"res://assets/cards/solution_cards/air_quality.png",
		["A", "K"],
		false
	)

	_add_solution_card(
		"s_09",
		"Conservation Programs",
		"Protecting natural habitats and endangered species.",
		"res://assets/cards/solution_cards/conservation.png",
		["G", "J"],
		false
	)

	_add_solution_card(
		"s_10",
		"Green Urban Planning",
		"Designing cities with environmental sustainability in mind.",
		"res://assets/cards/solution_cards/urban_planning.png",
		["O", "R"],
		false
	)

	_add_solution_card(
		"s_11",
		"Chemical Management",
		"Proper handling and disposal of hazardous chemicals.",
		"res://assets/cards/solution_cards/chemical_management.png",
		["B", "Q"],
		false
	)

	_add_solution_card(
		"s_12",
		"Energy Efficiency",
		"Using less energy to perform the same tasks.",
		"res://assets/cards/solution_cards/energy_efficiency.png",
		["D", "P"],
		false
	)

	_add_solution_card(
		"s_13",
		"Circular Economy",
		"Economic system aimed at eliminating waste through material reuse.",
		"res://assets/cards/solution_cards/circular_economy.png",
		["F", "L"],
		false
	)

	_add_solution_card(
		"s_14",
		"Soil Conservation",
		"Practices to prevent soil erosion and maintain fertility.",
		"res://assets/cards/solution_cards/soil_conservation.png",
		["E", "M"],
		false
	)

	_add_solution_card(
		"s_15",
		"Water Treatment",
		"Processes to remove contaminants from wastewater.",
		"res://assets/cards/solution_cards/water_treatment.png",
		["B", "Q"],
		false
	)

	# Add ultimate solution cards
	_add_solution_card(
		"s_u1",
		"Environmental Education",
		"Teaching about environmental issues and solutions to create awareness.",
		"res://assets/cards/solution_cards/environmental_education.png",
		[],
		true
	)

	_add_solution_card(
		"s_u2",
		"Sustainable Development",
		"Meeting present needs without compromising future generations.",
		"res://assets/cards/solution_cards/sustainable_development.png",
		[],
		true
	)

func _add_solution_card(
		id: String,
		card_name: String,
		description: String,
		texture_path: String,
		solvable_problems: Array[String],
		is_ultimate: bool
) -> void:
	"""
	Create and add a solution card to the database.

	Args:
		id: Unique identifier for the card
		card_name: Display name of the card
		description: Card description text
		texture_path: Path to the card's texture
		solvable_problems: Array of problem letter codes this solution can solve
		is_ultimate: Whether this is an ultimate card that can solve any problem
	"""
	var card = SolutionCard.new(
		id,
		card_name,
		description,
		texture_path,
		solvable_problems,
		is_ultimate
	)
	_solution_cards[id] = card

func get_card_by_id(id: String) -> Card:
	"""
	Get a card by its unique identifier.

	Args:
		id: The unique identifier of the card

	Returns:
		The card with the specified ID, or null if not found
	"""
	if id.begins_with("p_"):
		return _problem_cards.get(id)
	elif id.begins_with("s_"):
		return _solution_cards.get(id)
	return null

func get_problem_card(id: String) -> ProblemCard:
	"""
	Get a problem card by its unique identifier.

	Args:
		id: The unique identifier of the problem card

	Returns:
		The problem card with the specified ID, or null if not found
	"""
	return _problem_cards.get(id) as ProblemCard

func get_solution_card(id: String) -> SolutionCard:
	"""
	Get a solution card by its unique identifier.

	Args:
		id: The unique identifier of the solution card

	Returns:
		The solution card with the specified ID, or null if not found
	"""
	return _solution_cards.get(id) as SolutionCard

func get_all_problem_cards() -> Array[ProblemCard]:
	"""
	Get all problem cards.

	Returns:
		An array of all problem cards
	"""
	var cards: Array[ProblemCard] = []
	for card in _problem_cards.values():
		cards.append(card)
	return cards

func get_all_solution_cards() -> Array[SolutionCard]:
	"""
	Get all solution cards.

	Returns:
		An array of all solution cards
	"""
	var cards: Array[SolutionCard] = []
	for card in _solution_cards.values():
		cards.append(card)
	return cards

func get_problem_cards_by_letter(letter_code: String) -> Array[ProblemCard]:
	"""
	Get all problem cards with the specified letter code.

	Args:
		letter_code: The letter code to search for

	Returns:
		An array of problem cards with the specified letter code
	"""
	var cards: Array[ProblemCard] = []
	for card in _problem_cards.values():
		if card.letter_code == letter_code:
			cards.append(card)
	return cards

func get_solution_cards_for_problem(problem_letter: String) -> Array[SolutionCard]:
	"""
	Get all solution cards that can solve a problem with the specified letter code.

	Args:
		problem_letter: The problem letter code

	Returns:
		An array of solution cards that can solve the specified problem
	"""
	var cards: Array[SolutionCard] = []
	for card in _solution_cards.values():
		if card.can_solve_problem(problem_letter):
			cards.append(card)
	return cards

func get_ultimate_solution_cards() -> Array[SolutionCard]:
	"""
	Get all ultimate solution cards.

	Returns:
		An array of all ultimate solution cards
	"""
	var cards: Array[SolutionCard] = []
	for card in _solution_cards.values():
		if card.is_ultimate:
			cards.append(card)
	return cards

func create_problem_deck() -> Deck:
	"""
	Create a new deck containing all problem cards.

	Returns:
		A deck containing all problem cards
	"""
	return Deck.new(get_all_problem_cards())

func create_solution_deck() -> Deck:
	"""
	Create a new deck containing all solution cards.

	Returns:
		A deck containing all solution cards
	"""
	return Deck.new(get_all_solution_cards())
