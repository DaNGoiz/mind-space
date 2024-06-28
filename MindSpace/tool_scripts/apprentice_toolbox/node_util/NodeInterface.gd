#============================================================
#	Node Interface
#============================================================
#  节点需要实现的功能
#============================================================
# @datetime: 2022-3-15 19:46:31
#============================================================
tool
class_name NodeInterface
extends Node


## 角色对应的接口节点
const ObjectNodeMap := {}


export(Array, String) var excluede_list : Array


onready var host = get_parent()



#============================================================
#   Set/Get
#============================================================
##  获取对象的节点接口
## (如果想要获取一个节点的这个接口则直接进行 NodeInterface.get_role_interface(节点对象)
##  进行获取这个节点的接口列表)
static func get_role_interface(object: Object) -> Array:
	if ObjectNodeMap.has(object):
		return ObjectNodeMap[object]
	return []


func __get_no_exists_method__() -> Array:
	# host 拥有的方法
	host = get_parent()
	var list = (get_script() as Script).get_script_method_list()
	var data = {}
	for method_data in list:
		var method = method_data['name']
		data[method] = null
	# 排除的方法
	var exclude_method := [
		"_ready", "_exit_tree", "get_role_interface", "_init",
		"__get_no_exists_method__", "_get_configuration_warning"
	]
	exclude_method.append_array(excluede_list)
	for method in exclude_method:
		data.erase(method)
	# 判断是否存在方法
	var no_exists := []
	for method in data:
		if not host.has_method(method):
			no_exists.append(method)
	return no_exists


#============================================================
#   内置
#============================================================
func _init():
	if not ObjectNodeMap.has(host):
		ObjectNodeMap[host] = []
	ObjectNodeMap[host].append(self)


func _ready():
	if not Engine.editor_hint:
		var list = __get_no_exists_method__()
		assert(list.size() == 0, "host 没有实现 %s 方法!" % str(list))


func _exit_tree():
	ObjectNodeMap.erase(host)


func _get_configuration_warning():
	var list = __get_no_exists_method__()
	if list.size() > 0:
		return "host 没有实现 %s 方法!" % str(list)
	return ""


