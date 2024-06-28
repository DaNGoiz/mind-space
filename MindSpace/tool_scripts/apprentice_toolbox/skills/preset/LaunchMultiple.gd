#==================================================
#	Launch Multiple
#==================================================
#  发射多个子弹
#==================================================
# @datetime: 2021-9-10 21:24:21
#==================================================

extends "LaunchBullet.gd"


enum LaunchType {
	Single,		# 逐个发射
	Multiple,	# 一起发射
}


## 发射数量
export (int, 1, 10000) var launch_count : int = 3
## 平行距离
export var parallel_distance : float = 30.0
## 发射角度范围
export (float, 0, 360.0) var launch_degrees : float = 180.0
## 发射方式
export (LaunchType) var launch_type : int = LaunchType.Single
## 延迟发射
export var delay : float = 0.0



#==================================================
#   自定义方法
#==================================================
#(override)
func _launch(angle : float = 0.0) -> void:
	if launch_type == LaunchType.Single:
		_launch_single(angle)
	elif launch_type == LaunchType.Multiple:
		_launch_multiple(angle)


## 逐个发射
func _launch_single(angle: float) -> void:
	# 计算均值 idx
	var h = int(launch_count / 2)
	var idx_list = []
	if launch_count % 2 == 1:
		idx_list = range(-h, h + 1)
	else:
		idx_list = range(-h, h)
		for idx in idx_list.size():
			idx_list[idx] += 0.5
	
	# 保持在 1 的范围内
	for idx in idx_list.size():
		idx_list[idx] /= max(1, float(launch_count/2))
	
	# 发射
	var face_angle = 0.0
	var face_dir = Vector2.ZERO
	var rot_90 = deg2rad(90)
	var forward_offset = Vector2.ZERO
	var parallel = Vector2.ZERO
	var launcn_rot = -deg2rad(launch_degrees)
	for idx in idx_list:
		if delay > 0:
			yield(get_tree().create_timer(delay), "timeout")
		
		# 面向角度
		face_angle += (
			angle
			+ PI + idx * launcn_rot + _offset_rot
		)
		
		# 面部朝向
		face_dir = Vector2.LEFT.rotated(face_angle)
		# 向前偏移
		forward_offset = face_dir * offset_distance
		# 平行偏移(旋转90度，变为左右偏移)
		parallel = face_dir.rotated(-rot_90) * parallel_distance * idx
		
		# 设置属性
		var b := bullet.instance() as Node2D
		b.position += get_host().global_position \
					+ forward_offset + parallel
		b.rotation += face_angle
		
		emit_signal("launched", b)


##  一起发射
func _launch_multiple(angle: float) -> void:
	if delay > 0:
		yield(get_tree().create_timer(delay), "timeout")
	
	var rot_90 = deg2rad(90)
	var forward_offset = Vector2.ZERO
	var parallel = Vector2.ZERO
	var face_dir = Vector2.ZERO
	var launcn_rot = -deg2rad(launch_degrees)
	var face_angle = 0.0
	
	# 计算均值 idx
	var h = int(launch_count / 2)
	var idx_list = []
	if launch_count % 2 == 1:
		idx_list = range(-h, h + 1)
	else:
		idx_list = range(-h, h)
		for idx in idx_list.size():
			idx_list[idx] += 0.5
	
	# 保持在 1 的范围内
	for idx in idx_list.size():
		idx_list[idx] /= max(1, float(launch_count/2))
	
	# 发射
	for idx in idx_list:
		# 面向角度
		face_angle = angle + PI + idx * launcn_rot + _offset_rot
		
		# 面部朝向
		face_dir = Vector2.LEFT.rotated(face_angle)
		# 向前偏移
		forward_offset = face_dir * offset_distance
		# 平行偏移(旋转90度，变为左右偏移)
		parallel = face_dir.rotated(-rot_90) * parallel_distance * idx
		
		# 设置属性
		var b := bullet.instance() as Node2D
		b.position = forward_offset + parallel
		b.rotation = face_angle
		
		emit_signal("launched", b)

