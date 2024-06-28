extends Control


var count : int = 0


func _on_Button_pressed():
	count += 1
	$ScrollContainer.add_node("b_%d" % count)

