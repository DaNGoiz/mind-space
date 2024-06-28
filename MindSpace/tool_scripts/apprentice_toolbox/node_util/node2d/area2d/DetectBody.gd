#============================================================
#	Detect Body
#============================================================
#  检测 body
# * 需要调用设置 set_condition 方法，设置的方法需要有一个参数
#============================================================
# @datetime: 2022-3-16 16:25:37
#============================================================
class_name DetectBody
extends Area2D


## 扫描到 body
signal scanned_body(bodys)


## 扫描间隔时间
export var detect_time : float = 0.1 setget set_detect_time


var _bodys := []
var __bodys__ := {}

var _condition_host: Node
var _condition_method: String

onready var ray_cast : RayCast2D = $RayCast2D
onready var scan_timer : Timer = $ScanTimer


#============================================================
#   Set/Get
#============================================================
func get_bodys() -> Array:
	return _bodys

func has_bodys() -> bool:
	return _bodys.size() > 0

func set_detect_time(value: float) -> void:
	detect_time = value
	if not is_inside_tree():
		yield(self, "ready")
	$ScanTimer.wait_time = detect_time

## 这个方法需要有一个参数接收判断 body
func set_condition(host: Node, method: String) -> DetectBody:
	assert(host.has_method(method), "host 没有这个方法！")
	_condition_host = host
	_condition_method = method
	if ray_cast:
		ray_cast.add_exception(_condition_host)
	return self


#============================================================
#   内置
#============================================================
func _ready():
	scan_timer.wait_time = detect_time
#	assert(_condition_host != null, "没有设置判断条件！")
	connect("body_entered", self, "_body_entered")
	connect("body_exited", self, "_body_exited")
	if _condition_host:
		ray_cast.add_exception(_condition_host)
	yield(get_tree(), "physics_frame")
	assert(_condition_host != null, "没有设置判断条件，查看顶部描述设置条件！")


#============================================================
#   连接信号
#============================================================
func _body_entered(body: Node):
	__bodys__[body] = null


func _body_exited(body: Node):
	__bodys__.erase(body)


func _scan_body():
	_bodys.clear()
	# 检测 body 列表是否能被发现
	for body in __bodys__:
		if (_condition_host == null
			or _condition_host.call(_condition_method, body)
		):
			ray_cast.cast_to = to_local(body.global_position)
			# 射线检测到的节点是这个 body，则是没有被阻挡
			if ray_cast.get_collider() == body:
				_bodys.push_back(body)
	if _bodys.size() > 0:
		emit_signal("scanned_body", _bodys)

