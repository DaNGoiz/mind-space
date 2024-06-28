extends Area2D

var is_on_floor = false

# 地板进入
signal entered(body)
# 地板退出
signal exited(body)

func _ready():
	self.connect("body_entered",self,"_body_entered")
	self.connect("body_exited",self,"_body_exited")

######## 信号函数 ########

func _body_entered(body : Node):
	emit_signal("entered",body)
	is_on_floor = true
	pass

func _body_exited(body : Node):
	emit_signal("exited",body)
	is_on_floor = false
	pass

######## setget ########
func get_is_on_floor() -> bool:
	return is_on_floor
