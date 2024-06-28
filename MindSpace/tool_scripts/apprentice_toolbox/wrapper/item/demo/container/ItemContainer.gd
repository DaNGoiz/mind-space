#============================================================
#	Item Container
#============================================================
#  物品表格容器，管理物品的节点
#============================================================
# @datetime: 2022-3-3 16:44:40
#============================================================
extends MarginContainer


signal added_item(id, item_node)
signal removed_item(id, item_node)
signal selected_item(item)
signal unselect_item(item)


export var item_node : PackedScene
export var item_size := Vector2(64, 64)
export var separation := 4


var __data__ := {}
var __selected_item__ = null


onready var __n_grid__ = $ScrollContainer/GridContainer



#============================================================
#   Set/Get
#============================================================
##  获取物品节点列表
func get_item_node_list():
	return __data__.values()

##  获取物品节点 
## @id  节点id
## @return  
func get_item_node(id) -> Node:
	return __data__.get(id)

##  获取正在选中的 Item 节点
func get_selected_item():
	return __selected_item__


#============================================================
#   内置
#============================================================
func _ready():
	update_column_count()
	__n_grid__.set("custom_constants/vseparation", separation)
	__n_grid__.set("custom_constants/hseparation", separation)


#============================================================
#   自定义
#============================================================
##  添加物品
## @data  添加的数据
## @return  返回物品节点
func add_item(id) -> Node:
	var node = item_node.instance()
	node.connect("selected", self, "_on_Item_selected", [node])
	node.connect("deselected", self, "_on_Item_deselected", [node])
	# 设置节点大小
	if node is Control:
		node.rect_min_size = item_size
	__n_grid__.add_child(node)
	emit_signal("added_item", id, node)
	__data__[id] = node
	return node


##  移除物品 
## @id  
func remove_item(id):
	if __data__.has(id):
		var node = __data__[id] as Node
		emit_signal("removed_item", id, node)
		if node.is_selected():
			node.unselect()
		node.queue_free()
		__data__.erase(id)


##  更新列数量
func update_column_count():
	# 更新表格最大列数
	# 减 16 是节点边缘的距离
	var count = int(
		(rect_size.x - 8) / (item_size.x + separation)
	)
	__n_grid__.columns = max(1, count)


#============================================================
#   连接信号
#============================================================
func _on_Item_selected(item : Node):
	if is_instance_valid(__selected_item__):
		__selected_item__.unselect()
	__selected_item__ = item
	emit_signal("selected_item", __selected_item__)


func _on_Item_deselected(item : Node):
	if __selected_item__ == item:
		__selected_item__ = null
	emit_signal("unselect_item", item)


