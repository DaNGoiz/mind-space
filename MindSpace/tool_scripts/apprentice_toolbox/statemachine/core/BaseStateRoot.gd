#============================================================
#	Base State Root
#============================================================
# @datetime: 2022-3-17 22:46:48
#============================================================
class_name BaseStateRoot
extends BaseStateMachine


## 默认执行状态（如果不设置，默认执行第一个）
export var init_run_state : NodePath


#============================================================
#   内置
#============================================================
func _enter_tree():
	host = get_parent()
	root_node = self
	parent_node = self
	# 查找子节点中的黑板
	for child in get_children():
		if child is BaseStateBlackboard:
			blackboard = child
			blackboard.host = host
			break
	# 初始化所有子状态数据
	_init_state_data(self)


func _physics_process(delta):
	state_process(delta)



#============================================================
#   自定义
#============================================================
#(override)
func _init_state_data(parent_node):
	._init_state_data(parent_node)
	if init_run_state == "":
		if get_state_count() > 0:
			var first_state = __states__.keys()[0]
			switch_to(first_state)
	else:
		var node := get_node(init_run_state) as BaseState
		switch_to(node.name)


#(override)
func parent_exit():
	printerr("此为状态机根节点，不能退出！")


