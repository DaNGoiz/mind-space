#============================================================
#	State Machine
#============================================================
#  状态机
#============================================================
# @datetime: 2022-3-15 17:02:55
#============================================================
class_name BaseStateMachine
extends BaseState


signal state_changed(state)


var last_state


#============================================================
#   Set/Get
#============================================================
func get_last_state():
	return last_state


#============================================================
#   自定义
#============================================================
## 切换到同级另一个状态
func switch_to(state) -> void:
	# 退出上一个状态
	if current_node:
		last_state = current_state
		current_node.exit()
	# 执行当前状态
	current_state = state
	current_node = parent_node.get_state_node(current_state)
	current_node.enter()
	emit_signal("state_changed", current_state)


## “子状态”已执行完成（退出这个“子状态机”，切换到另一个）
func parent_exit() -> void:
	# 在这里执行切换逻辑，例如
	#switch_to("State")
	# 否则继续向上退出
	#.parent_exit()
	var stack : Dictionary = get_stack()[0]
	printerr(
		"重写 ", stack['source'], " 脚本中的 "
		, stack['function'], "() 方法，"
		, "以执行当前子状态机的状态切换逻辑"
	)
	pass



