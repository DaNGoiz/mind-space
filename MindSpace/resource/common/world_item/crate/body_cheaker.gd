extends Area2D

# 进入
signal on_body_entered(body)
# 退出
signal on_body_exited(body)

func _ready():
	self.connect("on_body_entered",self,"_body_entered")
	self.connect("on_body_exited",self,"_body_exited")

######## 信号函数 ########

func _body_entered(body : Node):
	emit_signal("on_body_entered",body)
	pass

func _body_exited(body : Node):
	emit_signal("on_body_exited",body)
	pass
