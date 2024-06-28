#============================================================
#	Node 2D Util
#============================================================
# @datetime: 2022-4-21 22:17:44
#============================================================

class_name Node2DUtil



func direction_to(a: Node2D, b: Node2D) -> Vector2:
	return a.global_position.direction_to(b.global_position)

func angle_to(a: Node2D, b: Node2D) -> float:
	# 当前面向角度到目标位置之间的夹角
	return a.global_position.angle_to(b.global_position)

func angle_to_point(a: Node2D, b: Node2D) -> float:
	return a.global_position.angle_to_point(b.global_position)

func distance_to(a: Node2D, b: Node2D) -> float:
	return a.global_position.distance_to(b.global_position)

func distance_squared_to(a: Node2D, b: Node2D) -> float:
	return a.global_position.distance_squared_to(b.global_position)



