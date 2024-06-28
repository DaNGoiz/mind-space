#============================================================
#	Move To
#============================================================
#  移动到位置
# * 手动调用 stop
#============================================================
# @datetime: 2022-3-15 10:47:41
#============================================================
class_name MoveTo
extends Parasitic


signal moved(dir)
signal finished


var __target_pos__ : Vector2 = Vector2(0,0)

var __condition_host__ : Object = null
var __condition_method__ : String = ""


#============================================================
#   Set/Get
#============================================================
#(override)
func get_host() -> Node2D:
	return .get_host() as Node2D


func get_target_pos() -> Vector2:
	return __target_pos__


##  设置执行完成条件 
## 需要有两个 Vector2 类型的参数
## @host  
## @method  
func set_finish_condition(host: Object, method: String) -> MoveTo:
	__condition_host__ = host
	__condition_method__ = method
	return self



#============================================================
#   内置
#============================================================
func _ready():
	set_physics_process(false)


func _physics_process(delta):
	# 执行条件必须要接收两个 Vector2 类型的参数
	# 第一个是 host 位置，第二个是 target 位置
	if __condition_host__.call(
		__condition_method__, 
		__host__.global_position, 
		__target_pos__
	):
		emit_signal("moved",
			get_host() \
				.global_position \
				.direction_to(__target_pos__)
		)
	else:
		stop()
		emit_signal("finished")


#============================================================
#   自定义
#============================================================
func start(pos: Vector2):
	assert(__condition_host__ != null, "必须要设置条件调用对象！")
	assert(__condition_method__ != "", "必须要设置条件方法！")
	
	__target_pos__ = pos
	set_physics_process(true)


func stop():
	set_physics_process(false)

