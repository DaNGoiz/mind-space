#============================================================
#	Attack Wrapper
#============================================================
#  攻击包装器
#============================================================
# * 主要在于基本的攻击逻辑无需编写
# * 连接 attacked 信号，然后调用 attack 方法传入任意类型数据执行功能
#============================================================
# @datetime: 2022-4-18 14:35:56
#============================================================
class_name AttackWrapper
extends RunnableWrapper


func _init(host).(host):
	pass


#============================================================
#   自定义
#============================================================
## 发出攻击
signal attacked(data)
## 攻击状态刷新
signal refreshed


var __attack_timer__ : Timer
var __interval__ : float = 1.0


##  获取攻击计时器 
## @return  
func get_attack_timer() -> Timer:
	if __attack_timer__ == null:
		__attack_timer__ = create_timer(true)
		__attack_timer__.connect("timeout", self, "refresh")
	return __attack_timer__

##  设置攻击间隔
func set_interval(value: float) -> AttackWrapper:
	__interval__ = max(value, 0.01)
	return self

##  返回能否攻击
func is_enabled() -> bool:
	return get_attack_timer().time_left <= 0

##  刷新
## @return  
func refresh() -> AttackWrapper:
	get_attack_timer().stop()
	emit_signal("refreshed")
	return self

##  攻击
## @data  
## @return  
func attack(data = null):
	get_attack_timer().start(__interval__)
	emit_signal("attacked", data)


#(override)
func run(data):
	attack(data)

