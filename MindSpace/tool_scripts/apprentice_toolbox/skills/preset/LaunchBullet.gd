#==================================================
#	Launch Single
#==================================================
#  发射单个子弹
#==================================================
# @datetime: 2021-9-10 21:22:38
#==================================================
extends BaseSkill


signal launched(bullet)


## 发射出的节点
export var bullet : PackedScene
## 距离向前偏移多长距离
export var offset_distance : float = 50
## 角度偏移
export (float, -180, 180) var offset_degrees : float = 0.0


## 偏移弧度
onready var _offset_rot : float = deg2rad(offset_degrees)



#==================================================
#   自定义
#==================================================
#(override)
func _init_data():
	._init_data()
	if bullet == null:
		# 子弹类型不是 Node2D 类型或其子类型
		var temp = bullet.instance()
		if not temp is Node2D:
			assert(false, "bullet is not Node2D type.")
	


#(override)
func _cast():
	._cast()
	_launch()


## 发射子弹
func _launch(data=null) -> void:
	var b = bullet.instance() as Node2D
	# 面向角度
	var angle = PI + _offset_rot
	# 向前偏移
	var forward_offset_distance = Vector2.LEFT.rotated(angle) * offset_distance
	# 设置属性
	b.position = forward_offset_distance
	b.rotation = angle
	
	emit_signal("launched", b)

