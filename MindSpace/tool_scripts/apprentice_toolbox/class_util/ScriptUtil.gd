#============================================================
#	Script Util
#============================================================
#  脚本工具
#============================================================
# @datetime: 2022-3-6 11:17:24
#============================================================
class_name ScriptUtil


#============================================================
#   其他
#============================================================
##  对象转为脚本
##（用于一个参数有多种类型的直接获取其脚本）
## @object  
## @return  
static func __object2script__(object) -> Script:
	var script : Script = null
	if object is Script:
		script = object
	elif object is Object:
		script = object.get_script() as Script
	return script


#============================================================
#   自定义
#============================================================
##  获取扩展脚本链（扩展的所有脚本）
## @script  脚本对象
## @return  返回继承的脚本路径列表
static func get_extends_link(script: Script) -> Array:
	var list := []
	while script:
		list.push_back(script.resource_path)
		script = script.get_base_script()
	return list


##  获取对象的属性数据
## @object  获取的对象
## @return  返回检查器类似的分组后的数据
static func get_object_property_data(object: Object) -> Dictionary:
	var data = {}
	var curr_group := ""
	for i in object.get_property_list():
		# 分组
		if i['usage'] & PROPERTY_USAGE_CATEGORY:
			curr_group = i['name']
			data[curr_group] = []
		else:
			data[curr_group].push_back(i)
	return data


##  返回脚本属性数据 
## @object  对象或脚本
static func get_script_property_data(object) -> Array:
	var script : Script = __object2script__(object)
	var list := []
	if script:
		for i in script.get_script_property_list():
			# 如果是个脚本变量
			if i['usage'] & PROPERTY_USAGE_SCRIPT_VARIABLE:
				list.push_back(i)
	else:
		printerr("没有脚本")
	return list


##  获取导出的属性数据 
## @object  
## @return  
static func get_export_property_data(object) -> Array:
	var script : Script = __object2script__(object)
	var list := []
	if script:
		for i in script.get_script_property_list():
			# 如果是个脚本变量
			if (i['usage'] & PROPERTY_USAGE_SCRIPT_VARIABLE
				|| i['usage'] & PROPERTY_USAGE_DEFAULT
			):
				list.push_back(i)
	else:
		printerr("没有脚本")
	return list


##  获取虚方法数据
static func get_virtual_method_data(object) -> Array:
	var list := []
	for i in object.get_method_list():
		# 可重写的虚方法
		if i['flags'] & METHOD_FLAG_VIRTUAL:
			list.push_back(i)
	return list


##  获取脚本中写的方法
## @object  
## @group  是否分组显示
##    （分组返回 Dictionary 类型数据，不分组返回 Array 类型数据）
static func get_script_method_data(object, group: bool = false):
	if not group:
		var list : Array = []
		for i in object.get_method_list():
			# 脚本方法
			if i['flags'] & METHOD_FLAG_FROM_SCRIPT:
				list.push_back(i)
		return list
	else:
		var has : Dictionary = {}
		var data : Dictionary = {}
		var link : Array = get_extends_link(__object2script__(object))
		link.invert()
		for path in link:
			var script := load(path) as Script
			data[path] = []
			for method in script.get_script_method_list():
				if not has.has(method['name']):
					data[path].append(method)
					has[method['name']] = null
		return data


