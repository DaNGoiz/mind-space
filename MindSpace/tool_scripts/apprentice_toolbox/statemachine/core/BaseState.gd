#============================================================
#	Base State
#============================================================
#  子状态
#============================================================
# @datetime: 2022-3-15 17:03:14
#============================================================

class_name BaseState
extends Node


var host : Node
var blackboard : Node
var root_node : Node
var parent_node : Node

var current_node : Node
var current_state

var __states__ := {}


#============================================================
#   Set/Get
#============================================================
func get_host():
	return host

func get_blackboard():
	return root_node.blackboard

func get_data(key):
	return root_node.blackboard.get_data(key)

func has_data(key):
	return root_node.blackboard.data.has(key)

func set_data(key, value):
	root_node.blackboard.set_data(key, value)

func get_root_state():
	return root_node

func get_parent_state():
	return get_parent()

func get_current_state():
	return parent_node

func get_state_node(state):
	return __states__[state]

func get_state_count() -> int:
	return __states__.size()

func get_state_node_list() -> Array:
	return __states__.values()


#============================================================
#   内置
#============================================================
func _ready():
	pass


#============================================================
#   自定义
#============================================================
func create_timer(
	wait_time : float = 1.0, 
	one_shot : bool = true
) -> Timer:
	return create_timer_to(self, wait_time, one_shot)


static func create_timer_to(
	to : Node,
	wait_time : float = 1.0, 
	one_shot : bool = true
) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = one_shot
	to.add_child(timer)
	return timer


#============================================================
#   状态方法
#============================================================
func _init_state_data(_parent_node):
	root_node = _parent_node.root_node
	parent_node = _parent_node
	blackboard = _parent_node.blackboard
	host = _parent_node.host
	for child in get_children():
		if "current_state" in child:
			child._init_state_data(self)
			# 默认按照点的名称转换状态
			_parent_node.add_state(child.name, child)


func add_state(state, node: Node):
	__states__[state] = node


func enter():
	pass


func exit():
	pass


func state_process(delta):
	if current_node:
		current_node.state_process(delta)


##  切换状态
## @state  
func switch_to(state):
	parent_node.switch_to(state)


##  父级退出状态
func parent_exit():
	parent_node.parent_exit()

