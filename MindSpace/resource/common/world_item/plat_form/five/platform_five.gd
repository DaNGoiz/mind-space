extends StaticBody2D

export(NodePath) var collision_path
onready var collision = get_node("CollisionShape2D")

func down():
	collision.disabled = true
	yield(get_tree().create_timer(0.7),"timeout")
	collision.disabled = false
	pass
