# UI control for the Plan Card Game
extends Control

# References to UI elements
@onready var play_button = $ActionButtons/PlayButton
@onready var skip_button = $ActionButtons/SkipButton
@onready var declare_button = $ActionButtons/DeclareButton
@onready var menu_button = $MenuButton
@onready var mode_label = $ModeLabel
@onready var message_popup = $MessagePopup
@onready var message_label = $MessagePopup/VBoxContainer/MessageLabel
@onready var message_timer = $MessagePopup/MessageTimer
@onready var message_ok_button = $MessagePopup/VBoxContainer/OkButton
@onready var confirm_popup = $ConfirmPopup
@onready var confirm_yes_button = $ConfirmPopup/VBoxContainer/ButtonsContainer/YesButton
@onready var confirm_no_button = $ConfirmPopup/VBoxContainer/ButtonsContainer/NoButton
@onready var scores_popup = $ScoresPopup
@onready var scores_label = $ScoresPopup/VBoxContainer/ScoresLabel
@onready var scores_continue_button = $ScoresPopup/VBoxContainer/ContinueButton
@onready var game_over_popup = $GameOverPopup
@onready var champion_label = $GameOverPopup/VBoxContainer/ChampionLabel
@onready var final_scores_label = $GameOverPopup/VBoxContainer/FinalScoresLabel
@onready var main_menu_button = $GameOverPopup/VBoxContainer/MainMenuButton

func _ready() -> void:
	# Connect signals
	message_ok_button.connect("pressed", Callable(self, "_on_message_ok_button_pressed"))
	message_timer.connect("timeout", Callable(self, "_on_message_timer_timeout"))
	confirm_yes_button.connect("pressed", Callable(self, "_on_confirm_yes_button_pressed"))
	confirm_no_button.connect("pressed", Callable(self, "_on_confirm_no_button_pressed"))
	scores_continue_button.connect("pressed", Callable(self, "_on_scores_continue_button_pressed"))
	main_menu_button.connect("pressed", Callable(self, "_on_main_menu_button_pressed"))

	# Initialize UI state
	play_button.disabled = true
	message_popup.visible = false
	confirm_popup.visible = false
	scores_popup.visible = false
	game_over_popup.visible = false

## UI Control Methods

func set_mode_text(text: String) -> void:
	"""
	Set the current mode text.
	"""
	mode_label.text = text

func show_message(message: String, auto_hide: bool = true) -> void:
	"""
	Show a message popup.
	"""
	message_label.text = message
	message_popup.visible = true

	if auto_hide:
		message_timer.start(2.0)  # Auto-hide after 2 seconds
	else:
		message_timer.stop()

func show_confirm_menu() -> void:
	"""
	Show the confirmation popup for returning to main menu.
	"""
	confirm_popup.visible = true

func show_round_scores(scores: Dictionary) -> void:
	"""
	Show the round scores popup.
	"""
	var scores_text = "Round Scores:\n\n"

	# Sort by score (highest first)
	var sorted_players = scores.keys()
	sorted_players.sort_custom(func(a, b): return scores[a] > scores[b])

	for player_id in sorted_players:
		scores_text += "Player %d: %d points\n" % [player_id + 1, scores[player_id]]

	scores_label.text = scores_text
	scores_popup.visible = true

func show_game_over(champion_id: int, final_scores: Dictionary) -> void:
	"""
	Show the game over popup with final results.
	"""
	champion_label.text = "Player %d is the CHAMPION!" % (champion_id + 1)

	var scores_text = "Final Scores:\n\n"

	# Sort by score (highest first)
	var sorted_players = final_scores.keys()
	sorted_players.sort_custom(func(a, b): return final_scores[a] > final_scores[b])

	for player_id in sorted_players:
		scores_text += "Player %d: %d points\n" % [player_id + 1, final_scores[player_id]]

	final_scores_label.text = scores_text
	game_over_popup.visible = true

## Event Handlers

func _on_message_ok_button_pressed() -> void:
	"""
	Handle message OK button pressed.
	"""
	message_popup.visible = false
	message_timer.stop()

func _on_message_timer_timeout() -> void:
	"""
	Handle message timer timeout.
	"""
	message_popup.visible = false

func _on_confirm_yes_button_pressed() -> void:
	"""
	Handle confirm YES button pressed.
	"""
	confirm_popup.visible = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _on_confirm_no_button_pressed() -> void:
	"""
	Handle confirm NO button pressed.
	"""
	confirm_popup.visible = false

func _on_scores_continue_button_pressed() -> void:
	"""
	Handle scores continue button pressed.
	"""
	scores_popup.visible = false

func _on_main_menu_button_pressed() -> void:
	"""
	Handle main menu button pressed.
	"""
	game_over_popup.visible = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
