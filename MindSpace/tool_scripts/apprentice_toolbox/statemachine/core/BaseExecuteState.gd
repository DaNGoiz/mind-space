#============================================================
#	Base Execute State
#============================================================
#  基础含执行器状态
#============================================================
# @datetime: 2022-5-01 21:18:05
#============================================================
class_name BaseExecuteState
extends BaseState


export (String, MULTILINE) var process_execute : String = ""


onready var _proxy_executer : StateExecuteParser.ProxyExecuter = get_blackboard().parse_code(process_execute, self)

func _ready():
	_proxy_executer.host = self
	connect("tree_exiting", self, "_exting")


#(override)
func state_process(_delta: float):
	if _proxy_executer.host:
		_proxy_executer.state_process(_delta)


func _exting():
	_proxy_executer.host = null
