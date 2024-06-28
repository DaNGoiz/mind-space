#============================================================
#	Damage Area
#============================================================
# @datetime: 2022-3-8 23:53:45
#============================================================
tool
class_name DamageArea
extends Parasitic



## 造成伤害
export var damage : float = 1
## 影响到的角色的失控时间
export var unable_control_time : float = 0
## 离开范围时结束失控
export var end_of_when_leaving : bool = false


var __list__ : Array = []


#============================================================
#   Set/Get
#============================================================
#(override)
func get_host() -> Area2D:
	return .get_host() as Area2D


#============================================================
#   内置
#============================================================
func _ready():
	if not Engine.editor_hint:
		if get_host():
			get_host().connect("body_entered", self, "_take_damage")
			get_host().connect("body_exited", self, "_exit_area")


func _get_configuration_warning():
	if not get_parent() is Area2D:
		return "父节点必须是 Area2D 类型！"
	return ""


#============================================================
#   自定义
#============================================================
# 受到伤害
func _take_damage(body: Node):
	if body.is_in_group("Role"):
		if damage > 0:
			body.take_damage({
				"health": damage
			})
		if unable_control_time > 0:
			if __list__.has(body):
				return
			__list__.push_back(body)
			body.control_enabled += 1
			if not end_of_when_leaving:
				yield(get_tree().create_timer(unable_control_time), "timeout")
				body.control_enabled -= 1


## 离开区域
func _exit_area(body):
	if end_of_when_leaving:
		if (body in __list__ 
			and unable_control_time > 0
		):
			__list__.erase(body)
			yield(get_tree().create_timer(unable_control_time), "timeout")
			body.control_enabled -= 1

