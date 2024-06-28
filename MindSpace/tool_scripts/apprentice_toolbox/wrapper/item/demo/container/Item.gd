#============================================================
#	Item
#============================================================
#  单个物品样式
#============================================================
# @datetime: 2022-3-3 19:49:35
#============================================================
extends Control


signal selected
signal deselected


onready var board = $Board


var __data__ setget set_data
var __select__ : bool = false setget set_select



#============================================================
#   Set/Get
#============================================================
func set_data(value) -> void:
	__data__ = value

func get_data():
	return __data__

func set_texture(value: Texture):
	if not self.is_inside_tree():
		yield(self, "ready")
	$TextureRect.texture = value

func set_select(value: bool) -> void:
	__select__ = value
	if __select__:
		emit_signal("selected")
	else:
		emit_signal("deselected")
	board.visible = value

func is_selected() -> bool:
	return __select__


#============================================================
#   内置
#============================================================
func _ready():
	board.visible = false
	# 设置子节点忽略全部鼠标
	__child_mouse_filter__(self)
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	emit_signal("mouse_exited")


func get_drag_data(position):
	unselect()
	# 设置拖拽的节点的样式和属性
	var temp = self.duplicate() as Control
	temp.get_node("Background").visible = false
	temp.connect("tree_exiting", self, '__drop_temp__')
	var rect = temp.get_node("TextureRect")
	rect.rect_position = -rect_size / 2
	temp.set_as_toplevel(true)
	set_drag_preview(temp)
	$TextureRect.modulate = Color(0.5, 0.5, 0.5)
	return __data__


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			set_select(not __select__)



#============================================================
#   自定义
#============================================================
##  取消子节点的鼠标事件
func __child_mouse_filter__(node: Node):
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		__child_mouse_filter__(child)

func __drop_temp__():
	$TextureRect.modulate = Color(1,1,1)


func select():
	set_select(true)

func unselect():
	set_select(false)



#============================================================
#   连接信号
#============================================================
func _on_Item_mouse_entered():
	self.self_modulate.a = 1


func _on_Item_mouse_exited():
	self.self_modulate.a = 0.5
