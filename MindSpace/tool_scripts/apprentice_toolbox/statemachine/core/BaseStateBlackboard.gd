#============================================================
#	Base State Blackboard
#============================================================
# @datetime: 2022-3-17 22:46:39
#============================================================
class_name BaseStateBlackboard
extends Node


var data : Dictionary = {}
var host


func get_data(key):
	return data[key]

func set_data(key, value):
	data[key] = value

##  获取状态执行代码解析器
func get_parser() -> StateExecuteParser:
	var root = get_tree().root
	if not root.has_meta("StateParser"):
		root.set_meta("StateParser", StateExecuteParser.new())
	return root.get_meta("StateParser") as StateExecuteParser

##  解析状态代码
func parse_code(code: String, _host: Node) -> StateExecuteParser.ProxyExecuter:
	return get_parser().parse(code, _host) as StateExecuteParser.ProxyExecuter

