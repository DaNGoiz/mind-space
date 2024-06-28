#============================================================
#	Turn To Mouse
#============================================================
#  控制节点，旋转到鼠标位置
#============================================================
# @datetime: 2022-3-6 12:10:43
#============================================================
class_name TurnToMouse
extends Parasitic

const HALF_PI = PI / 2.0


export var speed : float = 1.0
## 角度范围
export (float, 0, 360) var angle_range_start : float = 0
export (float, 0, 360) var angle_range_end : float = 360
## 角度为角度范围的比值
export var angle_is_ratio : bool = false
## 面向的角度偏移
export (float, -180, 180) var offset_angle : float = 0


onready var __angle_start__ : float = deg2rad(angle_range_start)
onready var __angle_end__ : float = deg2rad(angle_range_end)
onready var __offset_rot__ = deg2rad(offset_angle)

onready var _delta : float = 1.0 / float(ProjectSettings.get("physics/common/physics_fps"))



func _physics_process(delta):
	turn()


#============================================================
#   自定义
#============================================================
func turn():
	var dir = get_host() \
		.global_position \
		.direction_to(__host__.get_global_mouse_position())
	var angle = dir.angle() + PI
	_set_host_rot(angle)


func _set_host_rot(angle: float):
	if angle_is_ratio:
		var ratio := inverse_lerp(0, PI, angle)
		angle = lerp(__angle_start__
			, __angle_end__
			, ratio * speed
		) * _delta
	get_host().global_rotation = angle + __offset_rot__

