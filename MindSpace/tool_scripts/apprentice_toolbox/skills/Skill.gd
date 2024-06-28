#==================================================
#	Skill
#==================================================
#  非持续性技能的基类
# * 扩展脚本时重写 _cast() 方法进行添加施放效果
# * 连接此节点的信号进行不同阶段功能的施放
#==================================================
# @path: res://addons/function_tree/src/base/function/skills/Skill.gd
# @datetime: 2021-12-12 11:52:07
#==================================================
class_name BaseSkill
extends Node


## 准备执行 （执行技能前摇）
signal ready_execute
## 执行了技能 （技能发出）
signal executed
## 技能执行完成 (后摇结束)
signal execute_finished
## 技能状态刷新了（冷却时间结束了）
signal status_refreshed
## 技能停止（调用 stop 方法时发出这个信号）
signal stopped
## 中断技能（调用 interrupt 方法中断成功时发出这个信号）
signal interrupted


const Signals = {
	ReadyExecute = 'ready_execute',			# 准备执行功能，开始执行前摇
	ExecuteDuration = 'execute_duration',	# 前摇执行结束，执行功能
	Executed = 'executed',					# 功能执行完成，开始执行后摇
	ExecuteFinished = 'execute_finished',	# 后摇执行结束，动作完全结束
	StatusRefreshed = 'status_refreshed',	# 功能冷却完成，可再次使用
	Stopped = 'stopped',					# 停止执行功能时发出
}

const Propertys = {
	BeforeShake = "before_shake",
	AfterShake = 'after_shake',
	Interval = 'interval',
	Duration = 'duration',
}

## 中断执行结果
enum InterruptResult {
	OK = OK,
	NO_CASTING,		# 技能没有在施放
	NO_EXECUTE,		# 还没有执行其中的中断功能
}


## 自动注册这个技能，默认按照节点名注册到 SkillInterface 中
export var auto_register : bool = true
## 技能前摇（准备技能的时间）
export var before_shake : float = 0.0 setget set_before_shake
## 技能后摇（结束技能的时间）
export var after_shake : float = 0.0 setget set_after_shake
## 施放间隔时间
export var interval : float = 1.0 setget set_interval


## 宿主节点
var __host__ : Node setget set_host, get_host
## 刷新间隔时间计时器
var __refresh_timer__ := Timer.new()
## 技能前后摇计时器
var __skill_timer__ := SkillTimer.new(self)
## 技能状态
var __state__ : SkillStatus = SkillStatus.new()
## 中断技能时的状态
var __interrupt_status__ = SkillStatus.Status.CAN_CAST



#==================================================
#   Set/Get
#==================================================
##  获取宿主节点 
func get_host():
	if __host__:
		return __host__
	return get_parent()

func set_host(value: Node) -> void:
	__host__ = value

##  获取注册的名称 
## @return  
func get_register_name() -> String:
	return name

##  技能是否可用 
## @return  
func is_enabled() -> bool:
	return (
		__state__.is_can_cast()
		&& __refresh_timer__.is_stopped()
	)

func set_interrupt_state(value):
	__interrupt_status__ = value

func get_interrupt_state():
	return __interrupt_status__

## 设置前摇
func set_before_shake(value: float) -> void:
	before_shake = value
	__skill_timer__.before_time = value

func set_after_shake(value: float) -> void:
	after_shake = value
	__skill_timer__.after_time = value

func set_interval(value: float) -> void:
	interval = value
	if __refresh_timer__ == null:
		yield(self, "tree_entered")
	__refresh_timer__.wait_time = max(0.005, value)

##  可攻击的剩余时间
## @return  
func attack_time_left() -> float:
	return __refresh_timer__.time_left



#============================================================
#   内置
#============================================================
func _ready():
	# 注册这个节点
	if auto_register:
		SkillInterface.register(get_host(), self, get_register_name())
	
	__skill_timer__.set_before(before_shake, "_execute")
	__skill_timer__.set_after(after_shake, "_execute_finish")
	
	# 间隔时间结束，则调用 refresh() 方法
	__refresh_timer__.one_shot = true
	__refresh_timer__.autostart = false
	__refresh_timer__.wait_time = max(0.02, interval)
	__refresh_timer__.connect("timeout", self, "refresh")
	self.add_child(__refresh_timer__)


#==================================================
#   Skill 方法
#==================================================
##  开始执行技能
func start(_data=null) -> bool:
	return control(_data)

##  开始执行技能
## @_data  技能数据
## @return  返回是否可以执行
func control(_data) -> bool:
	if is_enabled():
		emit_signal("ready_execute")
		__state__.ready()
		# 开始施法前摇
		__skill_timer__.start_before_shake()
		return true
	
	# 没有执行成功
	return false


##  执行（开始准备执行）
func _execute() -> void:
	# 施放中时 return 
	if __state__.is_casting():
		return
	# 开始间隔倒计时
	__refresh_timer__.start(interval)
	
	# 施放
	__state__.cast()
	# 开始执行具体功能
	_cast()
	# 施放后
	_executed()


##  施放技能
## (重写这个方法)
func _cast():
	pass


##  功能施放后
## （这个是在技能发出瞬间之后进行处理的）
func _executed() -> void:
	__state__.casted()
	__skill_timer__.start_after_shake()
	emit_signal("executed")


##  执行完成
func _execute_finish() -> void:
	__state__.finish()
	emit_signal("execute_finished")


## 停止
func stop():
	_stop()


# (重写这个方法)
func _stop() -> bool:
	# 还没开始执行就停止时
	if __state__.is_ready():
		__state__.refresh()
	# 如果是在施放技能的状态
	if not __state__.is_no_cast():
		__state__.casted()
		__skill_timer__.stop()
		emit_signal("stopped")
		return true
	return false


##  中断，结束持续（提前结束持续技能）
#（不要重写这个！）
func interrupt():
	if _interrupt() == InterruptResult.OK:
		# 开始后摇
		__skill_timer__.start_after_shake()
		emit_signal("interrupted")


## （重写这个方法，对继承后的脚本功能进行扩展）
func _interrupt() -> int:
	if __state__.is_no_cast():
		if __state__.is_ready():
			__skill_timer__.stop_before_shake()
			set_interrupt_state(Signals.ReadyExecute)
			return InterruptResult.OK
		return InterruptResult.NO_EXECUTE
	return InterruptResult.NO_CASTING


##  技能刷新
func refresh() -> void:
	_refresh()


## (重写这个方法)
func _refresh():
	__refresh_timer__.stop()
	__state__.refresh()
	emit_signal("status_refreshed")



#==================================================
#   施放动作计时器
#==================================================
class SkillTimer:
	const MIN_TIME = 0.03
	
	var host : Node
	var before := Timer.new()
	var after := Timer.new()
	
	var before_time : float = 0.0 
	var after_time : float = 0.0 
	
	func _init(host: Node):
		self.host = host
	
	## 前摇动作
	func set_before(wait_time: float, method: String, binds: Array = []):
		before_time = wait_time
		before.wait_time =  max(MIN_TIME, wait_time)
		before.one_shot = true
		before.autostart = false
		before.connect("timeout", host, method, binds)
		if not host.is_inside_tree():
			yield(host, "tree_entered")
		host.add_child(before)
	
	# 后摇动作
	func set_after(wait_time: float, method: String, binds: Array = []):
		after_time = wait_time
		after.wait_time = max(MIN_TIME, wait_time)
		after.one_shot = true
		after.autostart = false
		after.connect("timeout", host, method, binds)
		if not host.is_inside_tree():
			yield(host, "tree_entered")
		host.add_child(after)
	
	# 前摇动作
	func start_before_shake():
		# （必须加计时器时间，因为在准备施放时要至少有一帧的等待时间
		# 没有这个时间则会有方法执行顺序的问题，所以设置 MIN_TIME）
		before.start(max(before_time, MIN_TIME))
	
	# 后摇动作
	func start_after_shake():
		after.start(max(after_time, MIN_TIME))
	
	func stop():
		before.stop()
		after.stop()
	
	func stop_before_shake():
		before.stop()
	
	func stop_after_shake():
		after.stop()



#==================================================
#   技能状态
#==================================================
class SkillStatus:
	
	enum Status {
		CAN_CAST,	# 可使用
		READY,		# 开始准备施放（前摇）
		CASTING,	# 施放中
		CASTED,		# 施放后（开始后摇）
		FINISHED,	# 施放结束（开始冷却）
	}
	
	var __state__ = Status.CAN_CAST
	
	func get_state():
		return __state__
	
	func set_state(value) -> void:
		# 防止中断、停止之类的功能造成状态切换错误
		if (__state__ == Status.CAN_CAST
			and value != Status.READY
		):
			# 如果可施放时不是切换到准备状态，则 return
			# 因为“可施放”状态只能切换到“准备”状态，否则逻辑错误
			# 总不能还没准备施放就到达其他状态了
			return
		__state__ = value
	
	func is_casting():
		return __state__ == Status.CASTING
	
	func is_ready():
		return __state__ == Status.READY
	
	# 是否可以施放
	func is_can_cast():
		return __state__ == Status.CAN_CAST
	
	func is_casted():
		return __state__ == Status.CASTED
	
	# 没有在施放技能
	func is_no_cast():
		return (
			__state__ == Status.CAN_CAST
			or __state__ == Status.FINISHED
		)
	
	func ready():
		set_state(Status.READY)
	
	func cast():
		set_state(Status.CASTING)
	
	func casted():
		set_state(Status.CASTED)
	
	func finish():
		set_state(Status.FINISHED)
	
	func refresh():
		set_state(Status.CAN_CAST)

