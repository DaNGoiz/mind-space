extends ScrollContainer


export var offset : Vector2 = Vector2(100, 100)

onready var _node_container : Control = $NodeContainer


var last_count : int = 0


func _ready():
	if _node_container.get_child_count() == 0:
		return
	
	var min_pos = _node_container.get_child(0).rect_position
	var max_pos = _node_container.get_child(0).rect_position
	var max_size = _node_container.get_child(0).rect_size
	for child in _node_container.get_children():
		if child is Control:
			var pos = child.rect_position
			if min_pos.x > pos.x:
				min_pos.x = pos.x
			if min_pos.y > pos.y:
				min_pos.y = pos.y
			if max_pos.x < pos.x:
				max_pos.x = pos.x
				max_size.x = child.rect_size.x
			if max_pos.y < pos.y:
				max_pos.y = pos.y
				max_size.y = child.rect_size.y
	
	for child in _node_container.get_children():
		if child is Control:
			child.rect_position -= min_pos
			child.rect_position += offset
	
	_node_container.rect_min_size = max_pos - min_pos + max_size + Vector2(100, 100) + offset


func add_node(text: String = "") -> GraphButton:
	var button = GraphButton.new()
	button.text = text
	button.rect_position = rect_size / 2 + Vector2(scroll_horizontal, scroll_vertical)
	button.rect_position += last_count * Vector2(20, 20)
	button.rect_size = Vector2(100, 50)
	_node_container.add_child(button)
	button.connect('moved', self, '_button_moved')
	last_count += 1
	return button


func _button_moved():
	last_count = 0

