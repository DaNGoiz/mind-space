extends Area2D
## 用途：检测最近的目标

var target_list = []

export(NodePath) var player_path
onready var player = get_node(player_path)

# 地板进入
signal entered(body)
# 地板退出
signal exited(body)

func _ready():
	self.connect("body_entered",self,"_body_entered")
	self.connect("body_exited",self,"_body_exited")

func _physics_process(delta):
	sort()

######## 信号函数 ########

func _body_entered(body : Node):
	emit_signal("entered",body)
	target_list.append(body)
	visible_cheak()
	pass

func _body_exited(body : Node):
	emit_signal("exited",body)
	target_list.erase(body)
	visible_cheak()
	pass

######## 自定义排序 ########

func sort():
	target_list.sort_custom(self,"sort_ascending")
func sort_ascending(a : Node, b : Node):
#	print(a.position.distance_to(b.position)," + ",b.position.distance_to(a.position))
	if player.position.distance_to(b.position) > player.position.distance_to(a.position):
		return true
	return false

######## 自定义函数 ########
func visible_cheak():
	if len(target_list) != 0 and target_list[0].has_method("crate"):
		ui_press_f.show_button()
		pass
	else:
		ui_press_f.hide_button()
	pass
