extends KinematicBody2D

########### 节点获取 ##########
# 获取角色sprite
export(NodePath) var player_sprite_path
onready var player_sprite = get_node(player_sprite_path)
# 获取地板检查器
export(NodePath) var cheak_floor_path
onready var cheak_floor = get_node(cheak_floor_path)
# 获取交互器
export(NodePath) var interaction_path
onready var interaction = get_node(interaction_path)
# preload箭
var arrow_scene = preload("res://resource/src/Scenes/bullet_player.tscn")
# 箭发射位置
onready var arrow_shoot_point = get_node("Sprite/arrow_start")
########### 信号设置 ##########


########### 基本属性 ##########
# 重力
var gravity = 400
# 加速度
var speed = 8000
# 摩擦力
var friction = 1500
# 最大速度
var max_speed = 500

# 当前速度倍率 编辑器里默认一定要1
var speed_scale = 1

########### 公共属性 ##########
# 键盘输入（只左右有值
var input_vector : Vector2
# 最后计算
var velocity : Vector2
# 是否正在跳跃
var jumping = false
# 是否在地板上
var is_floor = false

# 地板的物体
var floor_body
########### 内置方法 ##########

func _ready():
	## 操作连接
	charactor_input_manager.connect("input_vector_signal",self,"_get_input")
	charactor_input_manager.connect("jump",self,"_jump")
	## 节点连接
	cheak_floor.connect("entered",self,"floor_entered")
	cheak_floor.connect("exited",self,"floor_exited")

## 物理更新
func _physics_process(delta):
	# 更新动画
	animation()
	# 获得速度
	velocity.x = get_velocity_x(input_vector,delta)
	# 不在地板上就施加重力
	if !is_floor:
		velocity.y += get_gravity().y * delta
	# 检测交互
	if Input.is_action_just_pressed("drag"):
		drag()
		pass
	# 检测交互
	if Input.is_action_just_pressed("push"):
		push()
		pass
	cheak_shoot()
	cheak_platform()
	# 开始移动
	velocity = move_and_slide(velocity,Vector2.UP)
	pass

########### 信号接收 ##########

# 返回input（只有x有值
func _get_input(input:Vector2):
	set_h_vector(input)
	input_vector = input
	pass

func _jump():
#	 and input_vector.y <= 0
	if is_floor:
		jumping = true
		velocity.y = -400
	pass

########### setget   ##########

## 地板进入
func floor_entered(body):
	is_floor = true
	if jumping:
		jumping = false
	floor_body = body
	print(body)
	pass

## 地板退出
func floor_exited(body):
	if floor_body == body:
		is_floor = false
		floor_body = null
	pass

########### 自定义方法 ##########

## 检测交互(物体在范围内且按下F时)
func drag():
	# 获得交互列表
	var target_list = interaction.target_list
	if len(target_list) != 0:
		target_list[0].drag(self.position)
		print("我拉")
	pass

## 检测交互(物体在范围内且按下F时)
func push():
	# 获得交互列表
	var target_list = interaction.target_list
	if len(target_list) != 0:
		target_list[0].push(self.position)
		print("我推")
	pass

## 设置动画
func animation():
	if input_vector == Vector2.ZERO:
		player_sprite.play("idle")
	else:
		player_sprite.play("walk")
		if !is_floor:
			player_sprite.play("jump")
			pass
	pass

## 通过输入获取速度
func get_velocity_x(input_vector : Vector2,delta) -> float:
	var velocity : Vector2
	if input_vector != Vector2.ZERO:
		velocity.x = velocity.move_toward(input_vector * max_speed * speed_scale,speed * delta).x
		pass
	else:
		velocity.x = velocity.move_toward(Vector2.ZERO,friction * delta).x
		pass
	return velocity.x
	pass

## 设置角色朝向
func set_h_vector(vector):
	if vector.x < 0:
		get_node(player_sprite_path).set("scale",Vector2(-abs(get_node(player_sprite_path).scale.x),get_node(player_sprite_path).scale.y))
		pass
	elif vector.x > 0:
		get_node(player_sprite_path).set("scale",Vector2(abs(get_node(player_sprite_path).scale.x),get_node(player_sprite_path).scale.y))
		pass
	pass

## 获取重力
func get_gravity() -> Vector2:
	return Vector2(0,gravity)
	pass

########### 自定义交互 ##########

# 检测platform
func cheak_platform():
	if Input.is_action_just_pressed("ui_down") and floor_body != null:
		if floor_body.get_collision_layer_bit(6):
			if floor_body.has_method("down"):
				floor_body.down()
				print("cheak_platform")
			pass

# 检测开火
func cheak_shoot():
	if Input.is_action_just_pressed("shoot"):
		var arrow = arrow_scene.instance()
		arrow.position = player_sprite.get_node("arrow_start").global_position
		if player_sprite.scale.x < 0:
			arrow.direction = Vector2.LEFT
		else:
			arrow.direction = Vector2.RIGHT
		get_parent().add_child(arrow)
		pass


## 玩家被击中
func player_be_hit():
	charactor_public.cut_health()
	pass
