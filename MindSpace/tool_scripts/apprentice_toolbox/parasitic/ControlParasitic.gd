#============================================================
#	Press Key Control
#============================================================
#  按下按键调用父节点的 control() 方法
#============================================================
# @datetime: 2022-3-9 21:37:47
#============================================================
class_name ControlParasitic
extends Parasitic


export var press_key : String = ""



func _ready():
	set_physics_process(press_key != "")


func _physics_process(delta):
	if Input.is_action_pressed(press_key):
		control()


#(override)
func control(_arg0 = null):
	.control(_arg0)
	get_host().control()
