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

# Track test files for summary
var test_files_count: int = 0

func _ready() -> void:
	"""
	Main entry point for the test runner.
	Finds and runs all test scripts, then outputs results.
	"""
	print("\n=== PLAN CARD GAME TEST RUNNER ===\n")

	# Discover and run tests
	await discover_and_run_tests(test_directory)

	# Output test results
	print("\n=== TEST RESULTS ===")
	print("Test files: %d" % test_files_count)
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

		var test_files = []

		# First, collect all test files
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				# Recursively search subdirectories
				await discover_and_run_tests(path + file_name + "/")
			elif file_name.begins_with("test_") and file_name.ends_with(".gd"):
				# Found a test file, add to the list
				test_files.append(path + file_name)

			file_name = dir.get_next()

		dir.list_dir_end()

		# Update the test file count
		test_files_count += test_files.size()

		# Run each test file one by one
		for test_file in test_files:
			await run_test_file(test_file)
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

		# Get the test class name for output
		var test_class_name = file_path.get_file().get_basename()
		print("Running " + test_class_name + " tests...")

		# Wait for setup to complete
		if test_instance is TestCase:
			while not test_instance._setup_completed:
				await get_tree().process_frame

		# Find all test methods
		var test_methods = find_test_methods(test_instance)

		# Run each test method
		for method in test_methods:
			# Count the test
			tests_run += 1

			# Run the test method
			if verbose_output:
				print("  - Running: %s" % method)

			# Call setup if it exists (for TestCase subclasses)
			if test_instance is TestCase:
				test_instance.setup()

			# Run the actual test
			test_instance.call(method)

			# If we made it here without an assertion error, the test passed
			tests_passed += 1
			if verbose_output:
				print("    ✓ Passed")

			# Call teardown if it exists (for TestCase subclasses)
			if test_instance is TestCase:
				test_instance.teardown()

		# Print completion message
		print(test_class_name + " tests completed")

		# Remove the test instance
		remove_child(test_instance)
		test_instance.queue_free()

		# Give a frame for cleanup
		await get_tree().process_frame
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

	# Sort methods for consistent ordering
	test_methods.sort()

	return test_methods
