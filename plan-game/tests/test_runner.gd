# tests/test_runner.gd
extends Node

"""
Main test runner for the PLAN card game.
Discovers and runs all test scripts in the project.
"""

# Configuration
var test_directory: String = "res://tests/unit/"
var verbose_output: bool = true

# Test statistics
var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0

func _ready() -> void:
	"""
	Main entry point for the test runner.
	Finds and runs all test scripts, then outputs results.
	"""
	print("\n=== PLAN CARD GAME TEST RUNNER ===\n")

	# Discover and run tests
	discover_and_run_tests(test_directory)

	# Output test results
	print("\n=== TEST RESULTS ===")
	print("Tests run: %d" % tests_run)
	print("Tests passed: %d" % tests_passed)
	print("Tests failed: %d" % tests_failed)
	print("========================\n")

func discover_and_run_tests(path: String) -> void:
	"""
	Recursively find and run all test scripts in the given directory.

	Args:
		path: Directory path to search for test files
	"""
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				# Recursively search subdirectories
				discover_and_run_tests(path + file_name + "/")
			elif file_name.ends_with("_test.gd"):
				# Found a test file, run it
				run_test_file(path + file_name)

			file_name = dir.get_next()

		dir.list_dir_end()
	else:
		print("Error: Could not open directory: %s" % path)

func run_test_file(file_path: String) -> void:
	"""
	Run a single test file by creating an instance of the test class.

	Args:
		file_path: Path to the test script
	"""
	print("\nRunning tests from: %s" % file_path)

	var test_script = load(file_path)
	if test_script:
		var test_instance = test_script.new()
		add_child(test_instance)

		# Find and run all test methods
		var test_methods = find_test_methods(test_instance)

		for method in test_methods:
			# Count the test
			tests_run += 1

			# Run the test method
			if verbose_output:
				print("  - Running: %s" % method)

			# In Godot, we can't use try/except, so we use assert statements
			# within the test methods
			# The test methods themselves should handle their own assertions
			test_instance.call(method)

			# If we made it here without an assertion error, the test passed
			tests_passed += 1
			if verbose_output:
				print("    ✓ Passed")

		# Remove the test instance
		test_instance.queue_free()
	else:
		print("Error: Could not load test script: %s" % file_path)

func find_test_methods(test_instance: Object) -> Array:
	"""
	Find all test methods in a test instance.
	Test methods start with 'test_' prefix.

	Args:
		test_instance: The test object to inspect

	Returns:
		Array of test method names
	"""
	var test_methods = []
	var methods = test_instance.get_method_list()

	for method in methods:
		var method_name = method["name"]
		if method_name.begins_with("test_") and method["flags"] & METHOD_FLAG_NORMAL:
			test_methods.append(method_name)

	return test_methods
