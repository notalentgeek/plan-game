# Rules screen for the Plan Card Game
extends Control

# References to UI elements
@onready var back_button = $MarginContainer/VBoxContainer/BackButton
@onready var rules_tabs = $MarginContainer/VBoxContainer/RulesTabs

func _ready() -> void:
	# Connect signals
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

	# Initialize rules content
	_init_rules_content()

func _init_rules_content() -> void:
	"""
	Initialize the content of the rules tabs.
	"""
	# The rules content is taken directly from the PDF

	# Basic Rules Tab
	var basic_rules = rules_tabs.get_node("BasicRules/ScrollContainer/RulesContainer/BasicRulesText")
	basic_rules.text = """HOW TO PLAY PLAN GAME

1. The game starts by shuffling the cards properly by one of the players.
2. Every player receives a minimum of 2 cards and a maximum of 5 cards depending on the number of players.
3. After all players receive an equal number of cards, start the game by dropping one card (problem card) on the table.
4. The first player is expected to drop a card (solution) that can solve the existing problem card on the table.
5. After a player plays the solution card, the player is expected to play another card (problem) to allow other players to continue playing in the same format.
6. The game continues that way for all players accordingly.
7. A player with identical problem cards can play them together at the same time after playing a solution card.
8. A player is considered to win the game (CHECKMATE) after playing the last problem card possessed by the player.
9. If a player has exhausted all problem cards and has only solution cards left, the player is expected to notify the other players before the player CHECKMATE in the next turn.
10. When there are more than 2 players and one person wins the game (CHECKMATE), all problem cards in the hands of the other players are calculated.
11. The player who achieves CHECKMATE gets 5 points in that round of the game while the problem cards of other players are counted and those with the lowest problems are graded 3, 2, and 1 points respectively.
12. Players can play as many rounds of the game as possible while recording their points and the cumulative highest point determines the CHAMPION."""

	# Additional Rules Tab
	var additional_rules = rules_tabs.get_node("AdditionalRules/ScrollContainer/RulesContainer/AdditionalRulesText")
	additional_rules.text = """ADDITIONAL RULES

1. The game allows a minimum of 2 players and a maximum of 5 players.
2. A player who possesses an ULTIMATE CARD is permitted to play two different problem cards simultaneously.
3. If a player hides cards, or peeps into other players hand deliberately, it is considered CHEATING and the player should be evicted.
4. Each player must explain how the solution card they are presenting directly addresses the problem card on the table at every turn."""

	# About Tab
	var about_text = rules_tabs.get_node("About/ScrollContainer/RulesContainer/AboutText")
	about_text.text = """WHY DID WE DEVELOP THIS GAME?

Since the industrial revolution, the earth has continued to face devastating environmental challenges such as climate change, deforestation, air pollution, water pollution, land pollution, and biodiversity loss, among others.

All of these have been significantly exacerbated by human activities and indiscriminate exploitation of earth's resources. Furthermore, the world has seen a significant increase in global average temperature, exacerbating climate change-induced floods, sea level rise, wildfires, and species extinction on the earth's surface. These situations are expected to worsen if immediate action is not taken to address them.

Achieving a sustainable environment and preventing further rises in global temperatures requires the active involvement of young people in taking climate action. However, young people can only be part of addressing the world's pressing environmental issues if they are adequately enlightened and empowered with the requisite skills.

If nothing is done to urgently address the current climate crisis and environmental degradation, the world will experience more extreme weather events which will result in increased poverty, decaying human health, lesser access to education, biodiversity loss and food insecurity, amongst others.

OUR SOLUTION

The 'Play Learn and Act Now' (PLAN), is an innovative environmental game that aims to bridge the environmental education gap and inspire climate action amongst young people towards promoting the achievement of a more sustainable future.

This innovative game is redefining environmental sustainability education and making learning very interesting for every young person, thereby fostering more involvement in climate action environmental sustainability practices."""

	# Cards Tab
	var cards_text = rules_tabs.get_node("Cards/ScrollContainer/RulesContainer/CardsText")
	cards_text.text = """THE GAME

Problem Cards
The game has 18 problem cards. All the problem cards on a game pack have 3 copies each. This makes a total of 54 problem cards in one game pack. These problem cards reflect some of the most pressing environmental issues affecting the world. They also have unique alphabetical identification that enables the player to find a solution to the problem from the solution cards. The problem card also possesses an index number that reflects the gravity of the environmental problem compared to the other problems. The higher the number on the problem card, the more dangerous that problem is to the environment.

Solution Cards
The game has 17 solution cards. Each solution card contains 2 copies each except for the 2 ULTIMATE CARDs which contain only 1 card each. This makes a total of 32 solution cards (including ultimate cards) in one game pack.

The ultimate cards are two unique solution cards (Environmental Education and Eco-friendly Practices) that can solve every problem in the game.

Generally, the solution cards usually identify the problems that they can solve by listing the alphabetical representation of those problems on the solution cards picture illustration. In most cases, one solution card can solve more than one problem, hence more than one alphabet will be highlighted on the solution cards."""

func _on_back_button_pressed() -> void:
	"""
	Return to the main menu.
	"""
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
