#============================================================
#	Simple Platform Controller
#============================================================
#  简单的平台角色控制器
# * 添加这个子节点到 KinematicBody2D 下即可使用
#============================================================
# @datetime: 2022-2-28 12:03:06
#============================================================
class_name SimplePlatformController
extends Node


signal move_changed(state)
signal face_direction_changed(direction)
signal jumped


## 在这个时间内按下跳跃，在落在地面上后自动进行跳跃（输入缓冲）
const BUFFER_TIME = 0.1
## 离开地面后，在这个时间内仍可以进行跳跃（土狼时间）
const GRACE_TIME = 0.2


export var host : NodePath
export var move_speed : float = 0
export var jump_height : float = 0
export var gravity : float = 0
export (float, 0, 1) var friction : float = 1.0


var move_enabled : bool = true
var jump_enabled : bool = true
var gravity_enabled : bool = true

## 移动向量（左右移动 重力 向量）
var motion_velocity : Vector2 = Vector2(0,0)


var __host__ : KinematicBody2D
# 缓冲跳跃计时器
var __buffer_jump_timer__ := Timer.new()
# 土狼时间计时器
var __grace_timer__ := Timer.new()

# 移动速度
var __move_speed__ : float = 0.0
# 跳跃高度
var __jump_height__ : float = 0.0

# 上次移动向量
var __last_velocity__ : Vector2 = Vector2(0,0)
# 面向方向（左/右）
var __direction__ : Vector2 = Vector2.RIGHT
# 是否正在移动
var __moving__ : bool = false setget __set_move__


#============================================================
#   Set/Get
#============================================================
func __set_move__(value: bool):
	if __moving__ != value:
		__moving__ = value
		emit_signal("move_changed", __moving__)

func get_direction() -> Vector2:
	return __direction__

func is_moving() -> bool:
	return __moving__

func get_last_velocity() -> Vector2:
	return __last_velocity__

func set_host(value: KinematicBody2D):
	__host__ = value

func set_property_data(data: Dictionary):
	for prop in data:
		if prop in self:
			set(prop, data[prop])

##  在土狼时间内可以跳跃
func is_can_jump():
	return __grace_timer__.time_left > 0


#============================================================
#   内置
#============================================================
func _ready():
	if __host__ == null and host:
		set_host(get_node_or_null(host))
	elif __host__ == null:
		assert(get_parent() is KinematicBody2D, "父节点必须是 KinematicBody2D 类型")
		__host__ = get_parent()
	
	__buffer_jump_timer__.wait_time = BUFFER_TIME
	__buffer_jump_timer__.one_shot = true
	__buffer_jump_timer__.connect("timeout", self, "set", ['__jump__', false])
	add_child(__buffer_jump_timer__)
	
	__grace_timer__.wait_time = GRACE_TIME
	__grace_timer__.one_shot = true
	add_child(__grace_timer__)


func _physics_process(delta):
#	if __host__.is_on_floor():
#		__last_velocity__.y = 0
	
	# 重力
	if gravity_enabled:
		motion_velocity.y += gravity * delta
	else:
		motion_velocity.y = 0
	
	# 碰到天花板
	if __host__.is_on_ceiling() and motion_velocity.y < 0:
		motion_velocity.y = 0
	
	# 开始跳跃
	if __buffer_jump_timer__.time_left > 0:
		if (__host__.is_on_floor() 
			or __grace_timer__.time_left > 0
		):
			__jump__()
	else:
		# 土狼时间
		if __host__.is_on_floor():
			__grace_timer__.start(GRACE_TIME)
	
	# 操控行动
	__move__()



#============================================================
#   自定义
#============================================================
##  控制移动
func __move__():
	__last_velocity__ = __host__.move_and_slide(motion_velocity, Vector2.UP)
	motion_velocity = __last_velocity__
	motion_velocity.x = 0


##  控制跳跃
func __jump__():
	motion_velocity.y = -__jump_height__
	__buffer_jump_timer__.stop()
	__grace_timer__.stop()
	emit_signal("jumped")


##  更新数据
## @dir  
func __update_state__(dir: float):
	if dir != 0:
		update_direction(dir)
		__move_speed__ = move_speed
		__moving__ = true
	else:
		__move_speed__ = lerp(__move_speed__, 0.0, friction)
		__moving__ = false


##  更改方向
func change_direction(dir: float):
	update_direction(dir)


##  更新方向
## @dir  
func update_direction(dir: float):
	if __direction__.x != dir:
		__direction__.x = dir 
		emit_signal("face_direction_changed", __direction__)


##  左右移动
## @left_right  
func move_left_right(left_right: float):
	if move_enabled:
		__update_state__(left_right)
		motion_velocity.x = left_right * __move_speed__


##  根据方向移动 
## @direction  
func move_direction(direction: Vector2):
	direction.x *= __move_speed__
	if direction.y < 0:
		direction.y *= __jump_height__
	move_vector(direction)


##  根据向量移动 
## @velocity  
func move_vector(velocity: Vector2):
	if move_enabled:
		__update_state__(sign(velocity.x))
		motion_velocity.x = velocity.x
	if velocity.y < 0:
		jump(velocity.y)


##  跳跃
## @height  跳跃高度
## @force  强制跳跃
func jump(height: float = INF, force: bool = false):
	# Jump
	if jump_enabled:
		__jump_height__ = (height if height != INF else jump_height)
		if force:
			__jump__()
		else:
			__buffer_jump_timer__.start()

