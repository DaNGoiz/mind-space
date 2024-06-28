#==================================================
#	Teleporting
#==================================================
#  传送
#==================================================
# @datetime: 2021-12-15 17:43:18
#==================================================

extends BaseSkill


## 最大传送距离（如果小于 0，则没有距离限制）
export var max_distance : float = -1.0


var target_pos


#(override)
func control(pos: Vector2) -> bool:
	if .control(pos):
		if max_distance > 0:
			var v := (pos - get_host().global_position) as Vector2
			self.target_pos = get_host().global_position + v.clamped(max_distance)
			
		else:
			target_pos = pos
		print_debug(target_pos)
		return true
	return false


#(override)
func _cast():
	._cast()
	get_host().global_position = target_pos


