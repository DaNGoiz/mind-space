extends Area2D

export var speed := 6.0
onready var smoketrail = $Smoketrail

var direction := Vector2.RIGHT
var is_dead := false

func _process(_delta):
	if !is_dead:
		position += direction * speed
		smoketrail.add_point(global_position)

func _on_Bullet_body_entered(_body):
	var sound = preload("res://resource/src/Scenes/bullet_hit_sound.tscn").instance()
	add_child(sound)
	if _body:
		if _body.has_method("be_hit"):
			_body.call("be_hit")
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
