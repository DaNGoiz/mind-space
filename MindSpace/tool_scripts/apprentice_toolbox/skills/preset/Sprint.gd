#==================================================
#	Sprint
#==================================================
#  冲刺
#==================================================
# @datetime: 2021-12-14 16:01:53
#==================================================
extends BaseDurationSkill


## 冲刺速度
export var speed : float = 1000
export var up_direction : Vector2 = Vector2.UP


# 移动向量（朝向的方向的运动速度）
var velocity : Vector2



#(override)
func is_enabled() -> bool:
	return .is_enabled() && not is_executing()


#(override)
## @pos  冲刺到的位置
func control(pos: Vector2):
	if .control(pos):
		velocity = get_host() \
				.global_position \
				.direction_to(pos) * speed
		return true
	return false


#(override)
func _process_duration(delta: float) -> void:
	get_host().move_and_slide(velocity, up_direction)


##  根据 Velocity 值操控技能 
## @_velocity  
func control_by_velocity(_velocity: Vector2):
	if .control(_velocity):
		velocity = _velocity



