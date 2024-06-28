#============================================================
#	Equipment Wrapper
#============================================================
#  装备包装器
# * 当然他也可以作为技能，Buffer 之类的数据的包装器
#============================================================
# @datetime: 2022-4-20 02:45:53
#============================================================
class_name EquipmentWrapper
extends Wrapper


func _init(host).(host):
	pass


#============================================================
#   自定义
#============================================================
##  已装载
signal loaded(data)
##  已卸载
signal unloaded(data)
## 替换掉上个
signal replaced(last, new)
##  已被移除
signal removed(data)


# 默认的装备的数据列表
var _default_list : Array = []
# 不同 type 的数据列表
var _type_data : Dictionary = {}
# 对应 type 可装备的数据最大数量
var _max_count_data : Dictionary = {}

## 数量到达最大上限则替换上次的装备
var _replace_last : bool = true
## 装备类型的名称 key
var _type_key = "type"


##  设置是否会替换掉上次的装备
## @value  
## @return  
func set_replace_last(value: bool) -> EquipmentWrapper:
	_replace_last = value
	return self


##  设置装备类型在字典中的 Key
## @value  
## @return  
func set_type_key(value) -> EquipmentWrapper:
	_type_key = value
	return self


##  设置这个类型的最大可装备数量
## @type  类型
## @count  最大数量
func set_max_count(type: String, count: int) -> EquipmentWrapper:
	_max_count_data[type] = count
	return self


##  获取这个类型的有装备
## @type  
## @return  
func get_type_items(type: String) -> Array:
	if type == "":
		return _default_list
	
	var items : Array
	if _type_data.has(type):
		items = _type_data[type]
	else:
		items = []
		_type_data[type] = items
	return items


##  是否存在装备 
## @type  哪个类型的装备
## @return  
func get_type_count(type: String = "") -> int:
	return get_type_items(type).size()


##  是否已装备了这个
## @item  数据
## @exclude_key  排除的 Key，排除后进行比较
## @return  
func is_loaded(data: Dictionary, exclude_key: Array=[]) -> bool:
	# 没有装备则一定没有装备过这个物品
	var items : Array = get_type_items(data.get(_type_key, ""))
	if items.size() == 0:
		return false
	# 剔除排除的 key 后的数据
	var temp = {}
	for key in data:
		if not exclude_key.has(key):
			temp[key] = data[key]
	# 判断是否有存在一样的
	var keys = temp.keys()
	var t_item = {}
	for item in items:
		for key in keys:
			t_item[key] = item[key]
		if t_item.hash() == temp.hash():
			return true
	return false


##  这个装备类型的数量已到达最大数量
## @type  
## @return  
func type_is_max_count(type: String) -> bool:
	var items = get_type_items(type)
	# 物品最大数量
	var max_count = _max_count_data.get(type, INF)
	return items.size() < max_count


##  装载
## @data  物品
## @type  类型
func load_item(
	data: Dictionary
	, type: String = ""
) -> EquipmentWrapper:
	var items = get_type_items(type)
	# 可装备的最大数量
	var max_count = _max_count_data.get(type, INF)
	if not items.has(data):
		# 已装备的物品数量没有到达最大值，则直接装备
		if items.size() < max_count:
			items.append(data)
			emit_signal("loaded", data)
		else:
			# 达到最大数量，则判断是否替换以前装备的物品
			if _replace_last:
				items.append(data)
				if items.size() > 1:
					var last = items[0]
					unload_item(last, type)
					emit_signal("replaced", last, data)
				emit_signal("loaded", data)
	return self


##  卸载装备
## @data  数据
## @type  类型
## @return  
func unload_item(
	data: Dictionary
	, type: String=""
) -> EquipmentWrapper:
	if remove_item(data, type):
		emit_signal("unloaded", data)
	return self


##  移除装备
## @data  
## @type  
func remove_item(data: Dictionary, type: String = "") -> bool:
	var items : Array = get_type_items(type)
	# 如果没有传入 type 类型，且默认的列表里没有这个物品
	# 则会执行 else 中的语句块，进行遍历寻找所有物品
	if items.size() > 0 and type == "":
		if items.has(data):
			items.erase(data)
			emit_signal("removed", data)
			return true
	else:
		for key in _type_data:
			items = _type_data[key]
			if items.has(data):
				items.erase(data)
				emit_signal("removed", data)
				return true
	return false

