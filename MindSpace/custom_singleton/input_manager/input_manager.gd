extends Node

signal screen_touch

func _input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		emit_signal("screen_touch")
#		print(input_manager_tool.string_to_item(event.as_text()))
	pass

func _create_touch():
	var test_event = InputEventScreenTouch.new()
	test_event.pressed = true
	test_event.index = 0
	test_event.position = Vector2(5,5)
	Input.parse_input_event(test_event)
