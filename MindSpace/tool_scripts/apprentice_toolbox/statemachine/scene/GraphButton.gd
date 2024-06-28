class_name GraphButton
extends Button


signal moved

var grab = false
var mouse_pos = Vector2(0,0)
var button_pos = Vector2(0, 0)


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			grab = event.pressed
			mouse_pos = event.global_position
			button_pos = rect_position
	elif event is InputEventMouseMotion:
		if grab:
			rect_position = button_pos + (event.global_position - mouse_pos)
			emit_signal("moved")
