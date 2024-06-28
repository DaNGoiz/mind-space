extends RigidBody2D

# 获取碰撞节点
export(NodePath) var hit_range_path
onready var hit_range = get_node("arrow_hit_range")

func _on_arrow_body_entered(body):
	if body.has_method("hit_by_arrow"):
		body.call("hit_by_arrow")
	self.queue_free()

func _ready():
	hit_range.connect("body_entered",self,"_body_entered")
	pass

func _body_entered(body):
	self.queue_free()
