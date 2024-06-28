extends KinematicBody2D

# 获得动画
export(NodePath) var animation_player_path
onready var animation_player = get_node(animation_player_path)

# 获取交互器
export(NodePath) var interaction_path
onready var interaction = get_node(interaction_path)

# sound
onready var sound = get_node("sound")

var in_cd = false

# 导出方向设定
enum toward_type{
	LEFT,
	RIGHT,
	UP,
	DOWN
}
export(toward_type) var toward = 0

# preload箭
var arrow_scene = preload("res://resource/src/Scenes/bullet_enemy.tscn")

func _physics_process(delta):
	if len(interaction.target_list) != 0 and !in_cd:
		animation_player.play("attack")
	else:
		animation_player.play("normal")

func animation_attack():
	if !in_cd:
		var new_sound = sound.duplicate()
		add_child(new_sound)
		new_sound.play()
		new_sound.connect("finished",new_sound,"queue_free")
		
		var arrow = arrow_scene.instance()
		arrow.position = get_node("arrow_start").global_position
		if toward == 0:
			arrow.direction = Vector2.LEFT
		elif toward == 1:
			arrow.direction = Vector2.RIGHT
		elif toward == 2:
			arrow.direction = Vector2.UP
		elif toward == 3:
			arrow.direction = Vector2.DOWN
		get_parent().add_child(arrow)
		
		in_cd = true
		var cd = Timer.new()
		cd.wait_time = 5
		add_child(cd)
		cd.start()
		cd.connect("timeout",self,"on_cd_timeout")
		cd.connect("timeout",cd,"queue_free")

func on_cd_timeout():
	in_cd = false
	print(5)
	pass

func _break():
	var break_anim = preload("res://resource/common/be_break.tscn").instance()
	break_anim.position = self.global_position
	get_parent().add_child(break_anim)
	pass

# 被攻击函数
func be_hit():
	_break()
	self.queue_free()
	pass
