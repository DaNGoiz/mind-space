#============================================================
#	Speed Curve
#============================================================
#  速度曲线
#============================================================
# @datetime: 2022-3-9 21:49:08
#============================================================
tool
class_name SpeedCurve
extends Parasitic


signal controlled(data)
signal moving(speed)
signal finished


## 速度
export (float, -1000000, 1000000) var speed : float = 100
## 速度曲线
export var curve : Curve setget , get_curve
## 持续时间
export var duration : float = 1.0


var __timer__ = Timer.new()
var __last_rot__ : float
var __sub_property__ : bool = false



#============================================================
#   Set/Get
#============================================================
func get_curve() -> Curve:
	if curve == null:
		curve = Curve.new()
		curve.add_point(Vector2(0,0))
		curve.add_point(Vector2(1,1))
	return curve


func get_speed(ratio: float = 1):
	return curve.interpolate(ratio) * speed



#============================================================
#   内置
#============================================================
func _enter_tree():
	set_physics_process(false)


func _ready():
	set_physics_process(false)
	__timer__.one_shot = true
	__timer__.connect("timeout", self, "__finish__")
	add_child(__timer__)


func _physics_process(delta):
	var ratio := (1.0 - __timer__.time_left / duration) as float
	emit_signal("moving", get_speed(ratio))



#============================================================
#  自定义
#============================================================
func __finish__() -> void:
	stop()
	emit_signal("finished")


##  控制
## @data={}  
func control(data = {}) -> void:
	var time := duration
	if not data.empty():
		for property in data:
			if property in self:
				self[property] = data[property]
	if time <= 0:
		time = 1
		printerr("时间小于 0，持续时间设置为默认时间 1 秒")
	set_physics_process(true)
	__timer__.start(time)
	emit_signal("controlled", data)


##  停止
func stop() -> void:
	__timer__.stop()
	set_physics_process(false)



