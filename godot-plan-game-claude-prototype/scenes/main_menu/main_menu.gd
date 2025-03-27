# Main menu for the Plan Card Game
extends Control

# References to UI elements
@onready var player_count_spinbox = $MarginContainer/VBoxContainer/SettingsContainer/PlayerCountContainer/PlayerCountSpinBox
@onready var start_button = $MarginContainer/VBoxContainer/ButtonsContainer/StartButton
@onready var rules_button = $MarginContainer/VBoxContainer/ButtonsContainer/RulesButton
@onready var exit_button = $MarginContainer/VBoxContainer/ButtonsContainer/ExitButton
@onready var version_label = $VersionLabel

# Game manager reference
@onready var game_manager = get_node("/root/GameManager")

func _ready() -> void:
	# Connect button signals
	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))
	rules_button.connect("pressed", Callable(self, "_on_rules_button_pressed"))
	exit_button.connect("pressed", Callable(self, "_on_exit_button_pressed"))

	# Set version label
	version_label.text = "Version 1.0"

	# Set player count limits
	player_count_spinbox.min_value = 2
	player_count_spinbox.max_value = 5
	player_count_spinbox.value = 2

func _on_start_button_pressed() -> void:
	"""
	Start the game with the selected player count.
	"""
	var player_count = int(player_count_spinbox.value)

	# Initialize game with selected player count
	if game_manager.initialize_game(player_count):
		# Change to game scene
		get_tree().change_scene_to_file("res://scenes/game/game.tscn")
	else:
		# Show error (in a real game, you'd have a proper error UI)
		print("Failed to initialize game with %d players" % player_count)

func _on_rules_button_pressed() -> void:
	"""
	Show the rules screen.
	"""
	get_tree().change_scene_to_file("res://scenes/rules/rules.tscn")

func _on_exit_button_pressed() -> void:
	"""
	Exit the game.
	"""
	get_tree().quit()
