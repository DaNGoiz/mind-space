#============================================================
#	Json Converter
#============================================================
#  Json 数据转换器
#============================================================
# @datetime: 2022-4-20 01:50:24
#============================================================
class_name JsonConverter


##  根据字典数据设置对象所有属性
## @dict  
## @object  
static func set_property_by_dict(dict: Dictionary, object: Object) -> void:
	for property in dict:
		# 对象存在这个属性则设置
		if property in object:
			object.set(property, dict[property])


##  字典转换为 Object 对象
## @dict  字典数据
## @class_  Class类或脚本
## @return  返回生成的对象
static func dict2object(dict: Dictionary, class_) -> Object:
	var object = class_.new()
	set_property_by_dict(dict, object)
	return object


##  对象转换为字典
## @object  
## @return  
static func object2dict(object, all: bool = false) -> Dictionary:
	var data : Dictionary = {}
	var value
	var property_list : Array
	if not all:
		property_list = object.get_script().get_script_property_list()
	else:
		property_list = object.get_property_list()
	for prop in property_list:
		value = object.get(prop['name'])
		if value:
			data[prop['name']] = value
	return data


##  对象转为 JSON 数据
## @object  
## @return  
static func object2json(object: Object) -> String:
	return to_json(object2dict(object))


##  Json 转为对象 
## @json  
## @_class  转换成的对象类型
## @return  
static func json2object(json: String, _class) -> Object:
	return dict2object(parse_json(json), _class)




