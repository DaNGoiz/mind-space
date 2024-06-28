#============================================================
#	Item Panel
#============================================================
#  物品面板，对物品节点和物品数据的统一管理
#============================================================
# @datetime: 2022-3-3 21:28:09
#============================================================
extends PanelContainer


signal added_item(id)
signal removed_item(id)
signal selected_item(item)
signal unselected_item(item)


const Key_ItemNode = "item_node"


# 数据管理
onready var __item_data_manager__ : ItemManager = $ItemManager
# 节点容器
onready var __item_container__ = $ItemContainer



#============================================================
#   Set/Get
#============================================================
func get_all_items() -> Array:
	return __item_data_manager__.get_all_items()

##  获取物品数据
## @id  物品ID
## @return  
func get_item_data(id) -> Dictionary:
	return __item_data_manager__.get_item_by_id(id)

##  获取对应类型的物品
## @group  分组的 key
## @type  物品类型
func get_item_by_type(group: String, type: String) -> Array:
	return __item_data_manager__.get_item_by_type(group, type)



#============================================================
#   内置
#============================================================
func can_drop_data(position, data):
	return data is Dictionary

func drop_data(position, data):
	add_item(data)


#============================================================
#   自定义
#============================================================
##  添加物品
## @item  物品数据
## @return  返回物品ID
func add_item(item: Dictionary):
	if item.has("panel"):
		var panel : Control = item.get("panel")
		if panel:
			panel.remove_item(item.get('id'))
	item['panel'] = self	# 所在面板
	return __item_data_manager__.add_item(item)


##  获取物品
## @item_id  物品ID 
## @count  使用数量 
func take_item(item_id, count: int = 1) -> Dictionary:
	return __item_data_manager__.take_out(item_id, count)


##  取出对应ID物品全部数量
## @item_id  
func take_all_item(item_id) -> Dictionary:
	return __item_data_manager__.take_out(item_id, INF)


##  移除物品
## @item_id  物品ID
func remove_item(item_id):
	emit_signal("removed_item", item_id)
	__item_data_manager__.remove_item_by_id(item_id)
	__item_container__.remove_item(item_id)


#============================================================
#   连接信号
#============================================================
func _on_ItemDataManager_item_added(item, item_id):
	__item_container__.add_item(item_id)


func _on_ItemContainer_added_item(id, item_node: Control):
	var data : Dictionary = __item_data_manager__.get_item_by_id(id)
	item_node.set_data(data)
	if data.has("icon"):
		if data['icon'] is String:
			item_node.set_texture(load(data['icon']))
		elif data['icon'] is Texture:
			item_node.set_texture(data['icon'])
	item_node.hint_tooltip = JSON.print(data, '\t')
	__item_data_manager__.get_item_by_id(id)[Key_ItemNode] = item_node
	emit_signal("added_item", id)


func _on_ItemDataManager_item_changed(item, item_id):
	var node : Node = __item_container__.get_item_node(item_id)
	if node:
		var data = __item_data_manager__.get_item_by_id(item_id)
		node.set_data(item)
		node.hint_tooltip = JSON.print(data, '\t')

func _on_ItemDataManager_item_removed(item, item_id):
	__item_container__.remove_item(item_id)

func _on_ItemContainer_selected_item(item):
	emit_signal("selected_item", item)

func _on_ItemContainer_unselect_item(item):
	emit_signal("unselected_item", item)
