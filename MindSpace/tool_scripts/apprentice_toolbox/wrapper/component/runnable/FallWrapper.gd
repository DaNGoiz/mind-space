#============================================================
#	Fall Wrapper
#============================================================
#  落下装饰器器
#============================================================
# * 调用个 Wrapper 的 fall 方法即可使添加的碰撞节点失效一段时间
#============================================================
# @datetime: 2022-4-17 14:43:04
#============================================================
class_name FallWrapper
extends RunnableWrapper


func _init(host).(host):
	pass


#============================================================
#   自定义
#============================================================
signal falled


# 碰撞节点列表
var __collisions__ : Array = []
# 使用间隔时间
var __interval_time__ : float = 0.2
# 间隔计时器
var __interval_timer__ : Timer
# 失效时间
var __disabled_time__ : float = 0.1
var __disabled_timer__ : Timer
# 节点所在层
var __layer__ : int
# 切换到的层
var __to_layer__ : int

# ========================= [ Set/Get ] 



func is_enabled() -> bool:
	return get_interval_timer().time_left <= 0

func get_interval_timer() -> Timer:
	if __interval_timer__ == null:
		__interval_timer__ = create_timer(true)
	return __interval_timer__

func get_disabled_timer() -> Timer:
	if __disabled_timer__ == null:
		__disabled_timer__ = create_timer(true)
		__disabled_timer__.connect("timeout", self, "__disabled_timeout")
	return __disabled_timer__

##  设置使用间隔间隔
func set_interval(value: float) -> FallWrapper:
	__interval_time__ = max(0.02, value)
	return self

##  设置碰撞不可用时间 
func set_disabled_time(value: float) -> FallWrapper:
	__disabled_time__ = max(0.02, value)
	return self


# ========================= [ 自定义 ] 

func __disabled_timeout() -> void:
	# 可用
	for collision in __collisions__:
		collision.set_deferred("disabled", false)


##  添加下落时失效的碰撞
## @collision  
func add_collision(collision: CollisionShape2D) -> FallWrapper:
	__collisions__.append(collision)
	return self


##  下落
func fall():
	get_interval_timer().start(__interval_time__)
	
	# 失效
	for collision in __collisions__:
		collision.set_deferred("disabled", true)
	emit_signal("falled")
	
	# 开始失效持续时间计时器
	get_disabled_timer().start(__disabled_time__)


#(override)
func run(data=null):
	fall()


