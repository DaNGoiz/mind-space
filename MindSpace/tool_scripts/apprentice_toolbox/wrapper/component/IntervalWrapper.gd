#============================================================
#	Interval Wrapper
#============================================================
#  间隔计时器
# * 调用 start 方法，传入 id 和倒计时时间，执行成功后返回 true
#============================================================
# @datetime: 2022-4-20 00:53:06
#============================================================
class_name IntervalWrapper
extends Wrapper


func _init(host).(host):
	pass


#============================================================
#   自定义
#============================================================
signal timeout(id)


var __id_map__ : Dictionary = {}


func get_timer(id) -> Timer:
	if __id_map__.has(id):
		return __id_map__[id] as Timer
	else:
		__id_map__[id] = create_timer(true)
		__id_map__[id].connect("timeout", self, "_timeout", [id])
		return __id_map__[id] as Timer

func is_enabled(id) -> bool:
	return get_time_left(id) <= 0

func has_timer(id) -> bool:
	return __id_map__.has(id)

func get_time_left(id) -> float:
	if has_timer(id):
		return get_timer(id).time_left
	return 0.0

##  开始计时间隔时间
## @return  
func start(id, time: float) -> IntervalWrapper:
	get_timer(id).start(time)
	return self


##  停止计时器 
func stop(id) -> IntervalWrapper:
	get_timer(id).stop()
	return self



#============================================================
#   连接信号
#============================================================
func _timeout(id):
	emit_signal("timeout", id)

