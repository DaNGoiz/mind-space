extends Area2D

export var speed := 3.0
onready var smoketrail = $Smoketrail

var direction := Vector2.RIGHT
var is_dead := false

func _process(_delta):
	if !is_dead:
		position += direction * speed
		smoketrail.add_point(global_position)

func _on_Bullet_body_entered(_body):
	if _body != null:
		if _body.has_method("player_be_hit"):
			_body.call("player_be_hit")
			pass
	if !is_dead:
		is_dead = true
		smoketrail.stop()
		speed = 0.0
		$AnimationPlayer.play("explosion")
		yield($AnimationPlayer,"animation_finished")
		self.queue_free()


func _on_Timer_timeout():
	_on_Bullet_body_entered(null)
