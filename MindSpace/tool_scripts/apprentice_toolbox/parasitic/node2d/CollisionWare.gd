#============================================================
#	Collision Ware
#============================================================
#  碰撞区域波
# * 添加到 CollisionShape2D 节点下
#============================================================
# @datetime: 2022-3-8 23:43:03
#============================================================
tool
class_name CollisionWare
extends Node


## 是否自动开始
export var autostart : bool = false
## 范围
export var radius : int = 200 setget set_radius
## 速度曲线
export var speed : Curve setget , get_speed
## 延迟开始
export var delay_start : float = 0.0
## 持续时间
export var time : float = 1
## 延迟删除
export var delay_free : float = 0.0


var __t__ := 0.0


onready var __collision__ : CollisionShape2D = get_parent()
onready var __collision_circle__ : CircleShape2D = get_parent().shape



#============================================================
#   Set/Get
#============================================================
func set_radius(value: int) -> void:
	radius = value
	if get_parent() and get_parent().shape:
		if not is_inside_tree():
			yield(self, "ready")
		get_parent().shape.radius = value


func get_speed() -> Curve:
	if speed == null:
		speed = Curve.new()
		speed.add_point(Vector2(0,0))
		speed.add_point(Vector2(1,1))
	return speed


func _set_disabled(value: bool):
	get_parent().set_deferred("disabled", value)



#============================================================
#   内置
#============================================================
func _ready():
	if not (__collision__ is CollisionShape2D
		and __collision__.shape
		and __collision__.shape is CircleShape2D
	):
		print("条件不符合，不生效")
		return
	
	set_process(false)
	__collision_circle__.resource_local_to_scene = true
	if not Engine.editor_hint:
		_set_disabled(true)
		__collision_circle__.radius = 1
		if autostart:
			start(time)


func _process(delta):
	if __collision_circle__:
		__t__ -= delta
		var _speed = speed.interpolate(1 - __t__ / time)
		__collision_circle__.radius = radius * _speed
		if __t__ <= 0:
			set_process(false)
			if delay_free > 0:
				yield(get_tree().create_timer(delay_free), "timeout")
			queue_free()


func _get_configuration_warning():
	var collision = get_parent()
	if not collision is CollisionShape2D:
		return "父节点类型必须是 CollisionShape2D类型！"
	if not collision.shape:
		return "CollisionShape2D 没有设置 shape 属性！"
	if not collision.shape is CircleShape2D:
		return "shape 属性必须是 CircleShape2D 类型！"
	return ""


#============================================================
#   自定义
#============================================================
func start(_time : float = 0):
	if not is_inside_tree():
		yield(self, "ready")
	if __collision_circle__:
		if _time > 0:
			__t__ = _time
		else:
			__t__ = time
		if delay_start > 0:
			yield(get_tree().create_timer(delay_start), "timeout")
		set_process(true)
		_set_disabled(false)

