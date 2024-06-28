#============================================================
#	Swing
#============================================================
#  左右摇摆
#============================================================
# @datetime: 2022-3-10 14:04:41
#============================================================
class_name Swing
extends Parasitic


## 自动开始
export var autostart : bool = false
## 速度
export var speed : float = 500.0
export (float, 0, 1, 0.01) var speed_random : float = 0
## 波动范围
export var fluctuation : float = 100.0
export (float,0,1) var fluctuation_random : float = 0
## 角度偏移
export (float, -360, 360) var offset_angle : float = 0


var __last_rot__ : float = 0
var __direction__ : int = 1
## 已移动范围
var __range__ : float = 0.0
## 移动范围
var __current_range__ : float = 0.0 
## 最大范围
var __range_max__ : float = 0.0


onready var __delta__ := 1.0 / ProjectSettings.get("physics/common/physics_fps") as float
onready var __offset_angle__ := deg2rad(offset_angle)
onready var __velocity__ := Vector2.LEFT.rotated(__offset_angle__)
onready var __speed__ : float = rand_range(speed * (1-speed_random), speed)


#============================================================
#   Set/Get
#============================================================
#(override)
func get_host() -> Node2D:
	return .get_host() as Node2D



#============================================================
#   内置
#============================================================
func _ready():
	set_physics_process(false)
	__direction__ = [-1, 1][randi() % 2]
	if autostart:
		start()


func _physics_process(delta):
	__update_velocity__()
	var v = __speed__ * __direction__ * delta
	__range__ += v
	if abs(__range__) >= __range_max__:
		__direction__ *= -1
		__next__()
	# 移动位置
	get_host().position += __velocity__ * v



#============================================================
#   自定义
#============================================================
# 波动范围
func __next__():
	var last_range = __current_range__
	__current_range__ = rand_range((1-fluctuation_random) * fluctuation, fluctuation)
	__range_max__ = abs(last_range) + __current_range__
	__range__ = 0

# 更新旋转向量
func __update_velocity__():
	if __last_rot__ != get_host().global_rotation:
		__last_rot__ = get_host().global_rotation
		__velocity__ = Vector2.LEFT.rotated(__offset_angle__ + __last_rot__)


##  开始执行
func start():
	__next__()
	set_physics_process(true)


##  停止
func stop():
	set_physics_process(false)

