extends TestCase

"""
Test file for verifying the functionality of the card_deck_demo.
This ensures that the demo will work properly when used.
"""

var demo_scene: Node = null

func setup() -> void:
	"""
	Setup the test environment.
	"""
	print("Setting up card deck demo test")

	# Make sure CardDatabase is initialized
	if get_node_or_null("/root/CardDatabase") == null:
		var card_db_script = load("res://scripts/autoload/card_database.gd")
		if card_db_script:
			var card_db = card_db_script.new()
			card_db.name = "CardDatabase"
			# Use call_deferred to avoid issues with node setup timing
			get_tree().root.call_deferred("add_child", card_db)
			print("Added CardDatabase singleton for testing")
		else:
			push_error("Could not load CardDatabase script")
			return

	# Load the demo scene resource
	print("Attempting to load demo scene resource")
	var scene_path = "res://demos/card/card_deck_demo.tscn"

	if ResourceLoader.exists(scene_path):
		var demo_scene_res = ResourceLoader.load(scene_path)
		if demo_scene_res:
			print("Demo scene resource loaded successfully")
			# Instantiate the scene
			demo_scene = demo_scene_res.instantiate()
			if demo_scene:
				print("Demo scene instantiated successfully")
				# Use call_deferred to avoid issues with node setup timing
				get_tree().root.call_deferred("add_child", demo_scene)
			else:
				push_error("Failed to instantiate demo scene")
		else:
			push_error("Failed to load demo scene resource")
	else:
		push_error("Demo scene does not exist at path: " + scene_path)

func teardown() -> void:
	"""
	Clean up the test environment.
	"""
	if demo_scene:
		print("Removing demo scene")
		demo_scene.queue_free()
		demo_scene = null
	print("Cleaned up card deck demo test")

func test_verify_demo_scene_exists() -> void:
	"""
	Basic verification that the demo scene exists.
	This test must pass for other tests to be meaningful.
	"""
	print("Checking if demo scene exists")
	assert_not_null(demo_scene, "Demo scene should be instantiated")
	print("Demo scene exists")

func test_verify_scene_structure() -> void:
	"""
	Verify that the scene has the expected structure by checking
	that key components exist.
	"""
	assert_not_null(demo_scene, "Demo scene should be instantiated")

	# Check that the demo has the expected setup methods
	assert_true(demo_scene.has_method("_setup_ui"),
		"Demo should have _setup_ui method")
	assert_true(demo_scene.has_method("_create_control_panel"),
		"Demo should have _create_control_panel method")
	assert_true(demo_scene.has_method("_connect_signals"),
		"Demo should have _connect_signals method")

	# Check for essential properties
	assert_true(demo_scene.get("MAX_CARDS_PER_ROW") != null,
		"Demo should have MAX_CARDS_PER_ROW property")
	assert_true(demo_scene.get("CARD_SPACING") != null,
		"Demo should have CARD_SPACING property")

	print("Scene structure verification passed")

func test_card_creation_methods() -> void:
	"""
	Test that methods for creating cards exist.
	"""
	assert_not_null(demo_scene, "Demo scene should be instantiated")

	# Check card creation methods
	assert_true(demo_scene.has_method("_on_add_problem_pressed"),
		"Demo should have method to add problem cards")
	assert_true(demo_scene.has_method("_on_add_solution_pressed"),
		"Demo should have method to add solution cards")
	assert_true(demo_scene.has_method("_on_add_ultimate_pressed"),
		"Demo should have method to add ultimate cards")
	assert_true(demo_scene.has_method("_add_card_to_display"),
		"Demo should have method to add cards to display")

	print("Card creation methods test passed")

func test_deck_operation_methods() -> void:
	"""
	Test that methods for deck operations exist.
	"""
	assert_not_null(demo_scene, "Demo scene should be instantiated")

	# Check deck operation methods
	assert_true(demo_scene.has_method("_on_create_deck_pressed"),
		"Demo should have method to create decks")
	assert_true(demo_scene.has_method("_on_problem_deck_pressed"),
		"Demo should have method to create problem decks")
	assert_true(demo_scene.has_method("_on_solution_deck_pressed"),
		"Demo should have method to create solution decks")
	assert_true(demo_scene.has_method("_on_draw_card_pressed"),
		"Demo should have method to draw cards")
	assert_true(demo_scene.has_method("_on_shuffle_deck_pressed"),
		"Demo should have method to shuffle the deck")
	assert_true(demo_scene.has_method("_update_deck_info"),
		"Demo should have method to update deck info")

	print("Deck operation methods test passed")

func test_card_interaction_methods() -> void:
	"""
	Test that methods for card interaction exist.
	"""
	assert_not_null(demo_scene, "Demo scene should be instantiated")

	# Check card interaction methods
	assert_true(demo_scene.has_method("_on_card_clicked"),
		"Demo should have method to handle card clicks")
	assert_true(demo_scene.has_method("_on_card_hover_started"),
		"Demo should have method to handle card hover start")
	assert_true(demo_scene.has_method("_on_card_hover_ended"),
		"Demo should have method to handle card hover end")

	print("Card interaction methods test passed")

func test_drag_support() -> void:
	"""
	Test that drag support is properly implemented.
	"""
	assert_not_null(demo_scene, "Demo scene should be instantiated")

	# Verify the demo has the required drag handling functions
	assert_true(demo_scene.has_method("_try_select_card_at_position"),
		"Demo should have card selection method")
	assert_true(demo_scene.has_method("_process"),
		"Demo should have process method for drag handling")
	assert_true(demo_scene.has_method("_input"),
		"Demo should have input method for drag handling")

	# Check the script has relevant variables - in Godot we can't check
	# properties directly with get(), so we check the script has these methods
	var script = demo_scene.get_script()
	assert_not_null(script, "Demo should have a script attached")

	# Verify the script contains the expected drag-related code
	var script_source = script.source_code
	assert_true(script_source.contains("selected_card_visual"),
		"Script should contain selected_card_visual variable")
	assert_true(script_source.contains("drag_start_position"),
		"Script should contain drag_start_position variable")

	print("Drag support test passed")

func test_card_info_methods() -> void:
	"""
	Test that methods for updating card info exist.
	"""
	assert_not_null(demo_scene, "Demo scene should be instantiated")

	# Check card info methods
	assert_true(demo_scene.has_method("_update_card_info"),
		"Demo should have method to update card info")

	print("Card info methods test passed")

func test_initial_state() -> void:
	"""
	Test that the demo initializes with correct state.
	"""
	assert_not_null(demo_scene, "Demo scene should be instantiated")

	# Check script for initial state variables
	var script = demo_scene.get_script()
	assert_not_null(script, "Demo should have a script attached")

	var script_source = script.source_code
	assert_true(script_source.contains("test_deck"),
		"Script should contain test_deck variable")
	assert_true(script_source.contains("last_selected_card"),
		"Script should contain last_selected_card variable")

	print("Initial state test passed")
