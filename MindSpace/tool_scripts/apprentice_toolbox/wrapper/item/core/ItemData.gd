#============================================================
#	Item Data
#============================================================
#  物品数据
# * 将需要保存的变量前添加 export，在保存资源时会自动保存这个变量值
# * 不要在重写 _init() 方法时添加参数，否则保存的资源在读取时会有问题，
#    加载后会无法转换成这个类
#============================================================
# @datetime: 2022-2-20 16:40
#============================================================

class_name __ItemData__ extends Resource


##  数据被新添加上去
signal data_new_added(data, id)
##  数据被改变
signal data_changed(data, id)
##  数据被移除
signal data_removed(data, id)


# 以这个 key 的数据的 value 作为 key 
export var __value_id_key__ : String = ""
# 分组 Key
export var __group_key__ : Array = []

# id 存储的数据：__data_by_id__[id] 返回对应数据
export var __data_by_id__ : Dictionary = {}
# key 值存储的数据列表： __data_by_value_key__[key] 返回 Array
export var __data_by_value_key__ : Dictionary = {}
# 根据数据中的对应 key 的 value 进行分组
export var __data_by_group__ : Dictionary = {}


# ===============================================================
#             【！！！重要！！！】
#  __data_handle__ 为数据回调处理对象，对添加的数据进行处理的方式
# ===============================================================
# * 这个对象必须实现以下名称的方法：
#  1. static func add_data(a: Dictionary, b: Dictionary) -> void: 
#    参数 a 为已存在的数据，参数 b 为新添加的数据
#  2. static func new_data(data: Dictionary, id: String) -> void:
#    参数 data 为这个新添加的数据，参数 id 为记录的 id名称
#  3. static func get_earse_key() -> Array:
#    返回一个字符串列表，添加数据时，会清除这些 key 再进行比较
# ===============================================================
var __data_handle__ : Object

# 比较两个数据是否相同
var __equal__ : __EqualsData__ =  __EqualsData__.new()


#============================================================
#   内置
#============================================================
func _init():
	# 防止重新加载的时候引用的数据是一样的
	__group_key__ = __group_key__.duplicate(true)
	__data_by_id__ = __data_by_id__.duplicate(true) 
	__data_by_value_key__ = __data_by_value_key__.duplicate(true)
	__data_by_group__ = __data_by_group__.duplicate(true)


#============================================================
#   Set/Get
#============================================================
func get_data() -> Dictionary:
	return __data_by_id__

##  根据分组 key 的 value 获取数据列表
## @group_key  进行分组的 key
## @type_key  这个组的类型
## @return  返回这个组的所有的类型的数据
func get_data_list_by_group_value(group_key: String, type_key) -> Array:
	return __data_by_group__.get(group_key, {}).get(type_key, [])

## 根据 ID名称 获取数据
func get_data_by_id_key(id_key) -> Dictionary:
	return __data_by_id__.get(id_key, {})

## 判断是否存在这个 id
func has_id_key(id_key) -> bool:
	return __data_by_id__.has(id_key)

## 根据数据的 id名称 的 value 获取对应数据列表
func get_data_by_key_value(value_key) -> Array:
	return __data_by_value_key__[value_key]


#============================================================
#   自定义
#============================================================
## 新的 id key
func __new_id_key__(id_value: String) -> String:
	var pos = id_value.find('&')
	if pos > -1:
		id_value = id_value.left(pos)
	for i in INF:
		var new_id_key = "%s&%d" % [id_value, i]
		if not __data_by_id__.has(new_id_key):
			return new_id_key
	return "%s&%d" % [id_value, 0]


##  初始化配置
## @id_key  将数据的对应 key 的 value 作为 id 进行记录
## @data_handle  添加数据时对数据进行操作的对象，这个对象实现了几个对添加的数据进行操作的方法
##    方法需要实现的方法见上方 __data_handle__ 上的注释
func init_config(
	id_key, 
	data_handle: Object
):
	__value_id_key__ = id_key
	__data_handle__ = data_handle
	for key in data_handle.get_earse_key():
		add_erase_key(key)
	return self

##  获取 数据比较时会清除的 key 列表
func get_erase_keys() -> Array:
	return __equal__.get_erase_keys()

## 两个数据对比
func compare(a: Dictionary, b: Dictionary):
	return __equal__.set_data(a).equal(b)


##  添加 数据比较时会清除的 key
func add_erase_key(key) -> __ItemData__:
	__equal__.add_erase_key(key)
	return self

##  添加 数据比较时会清除的 key 列表
func add_erase_keys(keys: Array) -> __ItemData__:
	for key in keys:
		add_erase_key(key)
	return self

##  添加分组的 key
## @key  这个 key 的 value 相同的为一组
## （用于对数据进行分类）
## * 比如物品数据 key 中的 “ItemType” 这个 key 有 Weapon, Armor 类型
##   则会对 Weapon, Armor 的不同的 value 进行一个分组
func add_group_key(key) -> __ItemData__:
	if key is Array:
		for _v in key:
			add_group_key(_v)
	else:
		if not __group_key__.has(key):
			__group_key__.push_back(key)
	return self

##  根据数据的 value 添加到组中
## @group_key: String  对它的这个 key 的值进行分组
## @data: Dictionary  要分组的数据
func add_data_to_group_by_value_key(
	group_key: String,
	data: Dictionary
) -> __ItemData__:
	# 获取这个 key 的分组数据分类
	var group_data : Dictionary
	if not __data_by_group__.has(group_key):
		__data_by_group__[group_key] = {}
	group_data = __data_by_group__[group_key] as Dictionary
	# 获取这个分组
	var value_key = data[group_key]
	if not group_data.has(value_key):
		group_data[value_key] = []
	# 这个分组的列表
	var group := group_data[value_key] as Array
	group.push_back(data)
	return self


## 添加这个数据到分组中
func add_data_to_group(data: Dictionary):
	for key in __group_key__:
		add_data_to_group_by_value_key(key, data)

##  添加数据
## @return  返回这个数据的 ID名称
func add_data(data: Dictionary) -> String:
	data = data.duplicate(true)
	
	# 作为 key 的 value
	var id_value = data[__value_id_key__]
	# 获取相同的 id key 的数据列表
	#（相同 id，但部分数据内容不同的列表）
	if not __data_by_value_key__.has(id_value):
		__data_by_value_key__[id_value] = []
	
	# 判断是否有相同数据
	for id_key in __data_by_id__.keys():
		var item = __data_by_id__[id_key]
		if item[__value_id_key__] == data[__value_id_key__]:
			if compare(data, item):
				# 添加叠加的数据
				__data_handle__.add_data(item, data)
				emit_signal("data_changed", data, id_key)
				return id_key
	
	# 没有相同数据，则添加
	var id_key = __new_id_key__(str(data[__value_id_key__]))
	__data_by_id__[id_key] = data
	__data_by_value_key__[data[__value_id_key__]].push_back(data)
	# 添加到分组中
	add_data_to_group(data)
	# 回调处理
	__data_handle__.new_data(data, id_key)
	emit_signal("data_new_added", data, id_key)
	return id_key

##  根据 id key 删除
## @return  返回移除的数量
func remove_by_id_key(id_key) -> int:
	if has_id_key(id_key):
		var data := __data_by_id__[id_key] as Dictionary
		var value_id_key : String = data.get(__value_id_key__)
		if value_id_key:
			emit_signal("data_removed", __data_by_id__.get(id_key), id_key)
			__data_by_value_key__[value_id_key].erase(data)
			__data_by_id__.erase(id_key)
			return 1
		else:
			printerr("这个 ", __value_id_key__, " 没有", id_key ,"值。"
				, "（是不是物品数据 ", __value_id_key__, ' 的值是空的，只剩 &数字？）'
			)
	else:
		printerr("[ __ItemData__ ] 没有这个 key: ", __value_id_key__)
	return 0

## 根据主键 id key 的 value 移除数据
## @value  移除 id_key 中包含的值
## @return  
func remove_by_value_key(value: String) -> int:
	var count : int = 0
	for id_key in __data_by_id__.keys():
		if __data_by_id__[id_key][__value_id_key__] == value:
			emit_signal("data_removed", __data_by_id__.get(id_key), id_key)
			if __data_by_id__.erase(id_key):
				count += 1
	__data_by_value_key__.erase(value)
	return count



#============================================================
#   比较两个数据
#============================================================
class __EqualsData__:

	var __last_data__ : Dictionary
	var __erase_key__ : Array
	var __hash__ : int	# 数据的哈希值

	# 设置要比较的数据
	func set_data(data: Dictionary) -> __EqualsData__:
		if __last_data__ != data:
			__last_data__ = data
			var __temp_data__ = data.duplicate(true)
			for key in __erase_key__:
				__temp_data__.erase(key)
			__hash__ = __temp_data__.hash()
		return self
	
	# 获取匹配时清除的key
	func get_erase_keys() -> Array:
		return __erase_key__

	## 设置比较时要清除的 key
	func add_erase_key(erase_key: String):
		if not __erase_key__.has(erase_key):
			__erase_key__.push_back(erase_key)

	## 比较两个字典是否相同
	var __temp_data__ : Dictionary
	func equal(data: Dictionary) -> bool:
		__temp_data__ = data.duplicate(true)
		for key in __erase_key__:
			__temp_data__.erase(key)
		return __hash__ == __temp_data__.hash()


