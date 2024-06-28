class_name Gravity
extends Node


export var velocity : Vector2 = Vector2(0, 0) setget set_velocity


var p : Base


#============================================================
#   Set/Get
#============================================================
func set_velocity(value: Vector2) -> void:
	velocity = value
	if p:
		p.velocity = velocity


#============================================================
#   内置
#============================================================
func _ready():
	if get_parent() is KinematicBody2D:
		p = Kine_.new()
	elif get_parent() is Node2D:
		p = Node_.new()
	else:
		set_physics_process(false)
#		assert(false, "类型不匹配")
		return
	p.host = get_parent()


func _physics_process(delta):
	p.move(delta)




#============================================================
#   内部类
#============================================================

class Base:
	
	var host : Node
	var velocity : Vector2
	
	func move(delta):
		pass


class Node_:
	extends Base
	
	#(override)
	func move(delta):
		host.position += velocity * delta


class Kine_:
	extends Base
	
	#(override)
	func move(delta):
		(host as KinematicBody2D).move_and_slide(velocity)


