#============================================================
#	Item Wrapper
#============================================================
#  物品管理包装器
#============================================================
# @datetime: 2022-4-17 11:01:07
#============================================================
class_name ItemWrapper
extends Wrapper


func _init(host).(host):
	_item_manager = ItemManager.new()
	# 默认 id 为 name
	get_item_manager().init_data({ "id_key": "name", })
	# 为了方便而将三个信号合为一个
	get_item_manager().connect("item_added", self, "_item_event", [Add])
	get_item_manager().connect("item_removed", self, "_item_event", [Remove])
	get_item_manager().connect("item_changed", self, "_item_event", [Change])


#============================================================
#   自定义
#============================================================

signal item_event(item, id, event)

enum {
	Add,
	Remove,
	Change
}


var _item_manager : ItemManager


##  连接信号，物品操作事件
func _item_event(item: Dictionary, id, event):
	emit_signal("item_event", item, id, event)

##  获取物品管理器
## @return  
func get_item_manager() -> ItemManager:
	return _item_manager

##  设置标识物品数据的 ID key 
func set_id_key(id_key: String) -> ItemWrapper:
	_item_manager.id_key = id_key
	return self

##  设置分组 Key 
func set_group_key(group: Array) -> ItemWrapper:
	_item_manager.group_key = group
	return self

##  根据物品名称获取物品
## @item_name  物品名称
func get_item_by_name(item_name: String) -> Array:
	return _item_manager.get_item_by_id_key_value(item_name)

##  获取所有物品数据 
func get_all_items() -> Array:
	return _item_manager.get_all_items()

##  根据 Id 获取物品
func get_item_by_id(item_id: String) -> Dictionary:
	return _item_manager.get_item_by_id(item_id)

##  加载物品数据
## @path  保存的数据所在路径
func load_data(path: String) -> ItemWrapper:
	_item_manager.save_data(path)
	return self

##  保存物品数据
## @path  保存的物品数据所在路径
func save_data(path: String) -> ItemWrapper:
	_item_manager.save_data(path)
	return self

##  添加物品
## @data  物品数据
## @custom_attribute  修改物品属性
func add(data: Dictionary, custom_attribute: Dictionary = {}):
	return _item_manager.add_item(data, custom_attribute)

##  添加多个物品
## @item_list  物品列表
## @return  返回添加的物品的ID列表
func add_mul(item_list: Array) -> Array:
	return _item_manager.add_items(item_list)

##  移除物品
## @item_id  物品ID
func remove(item_id: String) -> void:
	_item_manager.remove_item_by_id(item_id)

##  移除多个物品
## @item_id_list  物品ID列表
func remove_mul(item_id_list: Array) -> void:
	_item_manager.remove_items_by_id(item_id_list)

##  取出物品
## @item_id  物品ID
## @count  取出数量
## @return  返回取出物品的数据
func take_out(item_id: String, count: int = 1) -> Dictionary:
	return _item_manager.take_out(item_id, count)

##  取出物品的全部
## @item_id  物品ID
## @return  返回取出物品的数据
func take_all(item_id: String) -> Dictionary:
	return _item_manager.take_out(item_id, int(INF))

##  过滤筛选出物品
## @condition  条件数据
## @return  返回所有和条件数据对应 key 的值一样物品
func fliter(condition: Dictionary) -> Array:
	return _item_manager.find_item_all(condition)

