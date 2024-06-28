extends StaticBody2D

export(NodePath) var collision_path
onready var collision = get_node("CollisionShape2D")

func get_collision():
	return collision
	pass

func down():
	get_collision().disabled = true
	yield(get_tree().create_timer(0.7),"timeout")
	get_collision().disabled = false
	pass
