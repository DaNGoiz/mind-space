#============================================================
#	Item Manager
#============================================================
#  物品数据管理
#============================================================
# * 可以直接添加节点到场景中设置他的属性。或者不添加节点，对节点变量调用
#    init_data 方法初始化属性，修改属性
# * 设置 id_key 物品的唯一识别的 id
# * 调用 add_item 方法传入 Dictionary 类型的数据进行添加物品数据
# * 调用 remove 开头的方法移除物品
# * 调用 take_out 方法取出物品，返回取出的物品数据
# * 调用 load_data/save_data 方法加载/保存数据
#============================================================
# * 需要注意 __Data_Handle__ 类，里面有对新增数据的管理的方法
#============================================================
# @datetime: 2022-2-18 21:45:00
#============================================================
class_name ItemManager extends Node


##  物品被新添加时
signal item_added(item, item_id)
##  物品发生改变时
signal item_changed(item, item_id)
##  物品被移除时
signal item_removed(item, item_id)


##  以这个名字作为 id，输入 id_key 的值返回对应的数据（不设置则不会进行叠加数量）
export var id_key : String = ""
##  对这个 key 的值进行分组
export (Array, String) var group_key : Array = []
##  不进行比较匹配的 key （分组时，比较两个数据的相同性时会去掉这些key再比较）
export (Array, String) var not_match_key : Array = []


## 物品数据核心记录和操作对象
var __item_data__ : __ItemData__



#============================================================
#   处理数据
#============================================================
class __Data_Handle__:
	# 两个数据比较时会清除这个 key
	# 如果除了这几个 key 之外的值都一样
	# 则调用 add_data 对数据进行追加
	# 否则调用 new_data 添加为新的数据
	static func get_earse_key() -> Array:
		return ['count', 'id']
	
	# 添加的数据时，对新添加的数据的操作
	# (可以根据需要自行修改追加时的操作)
	# @data  新增的数据
	# @id  生成的物品的ID
	static func new_data(data: Dictionary, id) -> void:
		if not data.has("count"):
			data['count'] = 1
		# 设置 id 为唯一值的 key
		# 通过 data.get(对应物品的id值) 可获得对应物品
		data['id'] = id
	
	# 对追加的数据的操作
	static func add_data(a: Dictionary, b: Dictionary) -> void:
		# 追加只对数量进行修改，其他不进行修改
		a['count'] += b['count'] if b.has('count') else 1


#============================================================
#   内置
#============================================================
func _enter_tree():
	__init_item_data__()


#============================================================
#   Set/Get
#============================================================
##  获取所有物品
## @return  
func get_all_items() -> Array:
	return __item_data__.get_data().values()

##  获取所有物品数据
func get_all_item_data() -> Dictionary:
	return __item_data__.get_data()

##  根据物品 Id名称 获取数据
## @item_id  物品的 ID名称
## @return  返回对应物品数据，如果没有，则返回空字典
func get_item_by_id(item_id) -> Dictionary:
	return __item_data__.get_data_by_id_key(item_id)

## 根据 id_key 的值获取物品数据
## @item_id_key_value  匹配这个值
##    （如果 id_key 设为 "name"，则意为根据 name 这个 key 进行查找
##    匹配 item_id_key_value 值的数据，等于说是查找和这个名称相同的数据）
## @return  数据中 “id_key 的 value” 等于 item_id_key_value 的数据
func get_item_by_id_key_value(item_id_key_value: String) -> Array:
	return __item_data__.get_data_by_key_value(item_id_key_value)

##  获取对应组别的类型的物品
## @group  分组的 key
## @type  这个 key 中的一个类型
func get_item_by_group(group: String, type) -> Array:
	return __item_data__.get_data_list_by_group_value(group, type)


##  获取物品的数量
## @item_id  物品ID
func get_item_count(item_id) -> int:
	return __item_data__.get_data_by_id_key(item_id)['count']



#============================================================
#   连接信号
#============================================================
func _data_new_added(data, item_id):
	emit_signal('item_added', data, item_id)

func _data_changed(data, item_id):
	emit_signal('item_changed', data, item_id)

func _data_removed(data, item_id):
	emit_signal("item_removed", data, item_id)


#============================================================
#   自定义
#============================================================
## 初始化 item_data
func __init_item_data__():
	# _init 下判断会因为属性没有初始化设置完成，而造成一直为空字符串而报错
	assert(id_key != "", "没有设置 ID Key，作为唯一标识的 key" + \
		"，一般为 id 或 name，代码中在 _enter_tree() 函数下进行设置"
	)
	
	__item_data__ = __ItemData__.new().init_config(
		# name 键的值作为主键（作为记录唯一的对象）（添加的数据要包含有 name 这个 key）
		id_key,
		
		# 对添加数据进行操作的对象，这个非常重要
		# （按 Ctrl 并点击这个类进行查看操作内容，查看 __ItemData__ 类的 _init 查看介绍）
		__Data_Handle__
		
		# 要分组的 key 列表，这里我我传入了 group_key 属性
		# 让其对里面的 key 的值进行分组
	).add_group_key(group_key) \
		.add_erase_keys(not_match_key)
	
	__item_data__.connect("data_new_added", self, "_data_new_added")
	__item_data__.connect("data_changed", self, "_data_changed")
	__item_data__.connect("data_removed", self, "_data_removed")


##  手动调用这个 init_data 方法进行初始化
## @data  初始化的属性，比如传入： 
##    {"id_key": "name", "group_key": ["type"]}
func init_data(data: Dictionary = {}) -> ItemManager:
	for key in data:
		if key in self:
			self.set(key, data[key])
	__init_item_data__()
	return self


##  加载数据
## （get_data_resource() 获取保存的资源 ）
func load_data(path: String) -> void:
	var temp = load(path) as __ItemData__
	if temp:
		__item_data__ = temp
		__init_item_data__()
		_print_info("加载成功", "path = " + path)
		# 发出信号
		var data = __item_data__.get_data()
		for id_key in data:
			__item_data__.emit_signal("data_new_added", data[id_key], id_key)
	else:
		_print_info("加载失败", "path = " + path)


##  保存数据
func save_data(path: String):
	# 后缀名需要是 tres 
	if not path.get_extension() in ['tres', 'res']:
		path += ".tres"
	# 保存
	var err = ResourceSaver.save(path, __item_data__)
	if err == OK:
		_print_info("保存成功", "path = " + path)
	else:
		_print_info("保存失败", "error = " + err)


##  打印信息
## @type  
## @info  
func _print_info(type: String, info: String):
	print("[ ItemManager.%s() | %s] : %s " % [get_stack()[1]['function'], type, info])


##  添加物品 
## @item  物品数据
## @custom_attribute  对物品修改的属性
## @return  返回物品的 ID名称
func add_item(item: Dictionary, custom_attribute: Dictionary = {}) -> String:
	var temp = item
	if custom_attribute.size() > 0:
		temp = item.duplicate(true)
		for key in custom_attribute:
			temp[key] = custom_attribute[key]
	return __item_data__.add_data(temp)


##  添加多个物品
## @item_list  物品数据列表
## @return  返回添加的物品的 ID 列表
func add_items(item_list: Array) -> Array:
	var id_list := []
	var id 
	for item in item_list:
		id = add_item(item)
		if not id_list.has(id):
			id_list.push_back(id)
	return id_list


##  查找到第一个符合条件的 Item
## @condi  条件
func find_item_one(condi: Dictionary) -> Dictionary:
	var keys = condi.keys()
	var temp = {}
	for item in get_all_item_data():
		for key in keys:
			temp[key] = item[key]
		if temp.hash() == condi.hash():
			return item
	return {}


##  查找所有符合条件的 Item
## @condi  
## @return  
func find_item_all(condi: Dictionary) -> Array:
	var list : Array = []
	var keys = condi.keys()
	var temp = {}
	for item in get_all_item_data():
		for key in keys:
			temp[key] = item[key]
		if temp.hash() == condi.hash():
			list.append(item)
	return list


##  移除所有这个 id_key 的 value 的物品
## @item_value  数据㢟值
##（对物品中 id_key 这个 key 中包含这个 item_value 值的物品进行删除。
## 比如，你设置 id_key 为 name，则会寻找 name 这个 key 中包含 item_value
## 的值进行删除，也就是删除了所有包含这个名称的物品）
func remove_item_by_id_key(item_value: String) -> void:
	__item_data__.remove_by_value_key(item_value)


##  根据 Id名称 移除物品 
## @id  物品 id 名称
func remove_item_by_id(id) -> void:
	__item_data__.remove_by_id_key(id)


##  移除物品
## @data  
func remove_item(data: Dictionary):
	remove_item_by_id(data[id_key])


##  删除多个物品
## @id_list  物品的 ID 列表
func remove_items_by_id(id_list: Array) -> void:
	for id in id_list:
		remove_item_by_id(id)


##  取出物品
## @id  物品Id
## @count  取出数量 (如果数量为 INF，则全部取出)
## @return  返回取出的物品
func take_out(id, count: int = 1) -> Dictionary:
	assert(id != "", "ID 必须是非空字符串！")
	assert(count > 0, "取出数量必须超过 0！")
	
	# 获取这个物品的数据
	var item : Dictionary = get_item_by_id(id)
	if item.size() > 0:
		# 判断数量是否超过
		var temp_item = item.duplicate(true)
		if (count < temp_item['count'] 
			and count != int(INF)
		):
			# 不超过最大数量，则仅减去数量
			item['count'] -= count
			temp_item['count'] = count
			_data_changed(item, id)
		else:
			temp_item['count'] = item['count']
			item['count'] = 0
			# 全部取出了所以移除
			__item_data__.remove_by_id_key(id)
			
		# 返回数据
		return temp_item
	else:
		printerr("没有物品数据了，无法取出")
		return {}
