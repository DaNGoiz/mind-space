#============================================================
#	Input Controller
#============================================================
#  输出控制器
#============================================================
# @datetime: 2022-4-20 00:30:56
#============================================================
class_name InputController
extends Node


signal inputted(vector)


export var enabled_process : bool = true setget set_enabled_process
export var input_left : String = "ui_left"
export var input_right : String = "ui_right"
export var input_up : String = "ui_up"
export var input_down : String = "ui_down"


#============================================================
#   Set/Get
#============================================================
func set_enabled_process(value: bool) -> void:
	enabled_process = value
	set_physics_process(enabled_process)


#============================================================
#   内置
#============================================================
func _ready():
	set_physics_process(enabled_process)


func _physics_process(delta):
	emit_signal("inputted", Input.get_vector(
		input_left, input_right,
		input_up, input_down
	))


