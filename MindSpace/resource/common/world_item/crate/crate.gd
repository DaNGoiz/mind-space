extends KinematicBody2D

export(NodePath) var crate_sprite_path
onready var crate_sprite = get_node(crate_sprite_path)
# 获取地板检查器
export(NodePath) var cheak_floor_path
onready var cheak_floor = get_node(cheak_floor_path)

# 冲
var force

var gravity = 300

var is_floor : bool

var velocity : Vector2

var player_position : Vector2

func _ready():
	## 节点连接
	cheak_floor.connect("entered",self,"floor_entered")
	cheak_floor.connect("exited",self,"floor_exited")
	pass

func be_hit():
	crate_break()
	pass

func crate_break():
	crate_sprite.play("break")
	yield(crate_sprite,"animation_finished")
	self.queue_free()
	pass

########################################
func _physics_process(delta):
	if !is_floor:
		velocity.y += gravity * delta
	
	move(delta)
	
	velocity = move_and_slide(velocity)

########################################
## 地板进入
func floor_entered(body):
	is_floor = true
	pass

## 地板退出
func floor_exited(body):
	is_floor = false
	pass

########################################
## 获取与目标的朝向
func direction_to_target(target : Vector2) -> Vector2:
	var direction = self.position.direction_to(target)
	return direction
	pass

## 移动
func move(delta):
	if force:
		velocity = velocity.move_toward(direction_to_target(player_position) * 3000,delta * 500)
	elif !force:
		velocity.x = velocity.move_toward(Vector2.ZERO,delta * 1200).x

func drag(target_position : Vector2):
	if !force:
		player_position.x = -1000
		force = true
		yield(get_tree().create_timer(0.2),"timeout")
		force = false
	pass

func push(target_position : Vector2):
	if !force:
#		player_position.x = -target_position.x
		player_position.x = 1000
		force = true
		yield(get_tree().create_timer(0.2),"timeout")
		force = false
	pass

## 不要删，用于区分
func crate():
	pass
