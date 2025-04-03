# tests/unit/base/test_case.gd
extends Node
class_name TestCase

"""
Base class for all unit tests.
Provides standardized assertion methods and output formatting.
"""

# Class name for reporting
var _test_class_name: String = ""
var _setup_completed: bool = false

func _init() -> void:
	# Get the class name from the script path
	var script_path = get_script().resource_path
	_test_class_name = script_path.get_file().get_basename()

func _ready() -> void:
	"""
	Entry point - perform minimal initialization.
	Don't print anything here - leave that to the test runner.
	"""
	_setup_completed = true

# Custom assert functions to provide better error messages
func assert_true(condition: bool, message: String = "") -> void:
	"""
	Assert that a condition is true.

	Args:
		condition: The condition to check
		message: Error message to display if the assertion fails
	"""
	if not condition:
		push_error("Assertion failed: " + message)
		assert(false, message)

func assert_equal(actual, expected, message: String = "") -> void:
	"""
	Assert that two values are equal.

	Args:
		actual: The actual value
		expected: The expected value
		message: Error message to display if the assertion fails
	"""
	if actual != expected:
		var error_msg = message + " (Expected: " + str(expected) + ", Got: " + str(actual) + ")"
		push_error("Assertion failed: " + error_msg)
		assert(false, error_msg)

func assert_not_equal(actual, not_expected, message: String = "") -> void:
	"""
	Assert that two values are not equal.

	Args:
		actual: The actual value
		not_expected: The value that should not match actual
		message: Error message to display if the assertion fails
	"""
	if actual == not_expected:
		var error_msg = message + " (Got unexpected value: " + str(actual) + ")"
		push_error("Assertion failed: " + error_msg)
		assert(false, error_msg)

func assert_null(value, message: String = "") -> void:
	"""
	Assert that a value is null.

	Args:
		value: The value to check
		message: Error message to display if the assertion fails
	"""
	if value != null:
		var error_msg = message + " (Expected null, Got: " + str(value) + ")"
		push_error("Assertion failed: " + error_msg)
		assert(false, error_msg)

func assert_not_null(value, message: String = "") -> void:
	"""
	Assert that a value is not null.

	Args:
		value: The value to check
		message: Error message to display if the assertion fails
	"""
	if value == null:
		var error_msg = message + " (Got null when expecting non-null)"
		push_error("Assertion failed: " + error_msg)
		assert(false, error_msg)

# Optional hooks that subclasses can override
func setup() -> void:
	"""
	Optional setup method that subclasses can override.
	Called before each test method.
	"""
	pass

func teardown() -> void:
	"""
	Optional teardown method that subclasses can override.
	Called after each test method.
	"""
	pass
