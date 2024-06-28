extends KinematicBody2D

var animSprite
var velocity = Vector2()
var hitScene
var isHitting

# Called when the node enters the scene tree for the first time.
func _ready():
	animSprite = get_node("AnimatedSprite")

func _process(delta):
	position += velocity * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		
		#被玩家子弹击中的应该有HitByPlayer()方法
		if collision.collider.has_method("HitByPlayer"):
			collision.collider.HitByPlayer()
		Hit()
	if isHitting:
		if animSprite.get_frame() == 2:
			queue_free()
	
func Hit():
	animSprite.play('Hit')
	isHitting = true
