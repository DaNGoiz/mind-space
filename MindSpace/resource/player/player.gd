extends KinematicBody2D

################# 索引设置 #################

# 获取角色sprite
export(NodePath) var player_sprite

# 动画树
onready var animation_tree = get_node(player_sprite).get_node("AnimationTree")

################# 速度设置 #################

# 加速度
var speed = 3000
# 摩擦力
var friction = 1500
# 最大速度
var max_speed = 500

# 当前速度倍率 编辑器里默认一定要1
var speed_scale = 0.7

# 二次记录速度倍率，副本
onready var speed_scale_dup = speed_scale

# 跑步最大速度倍率
var run_speed_scale = 1

# 总速率（速度属性调控）
var all_speed_scale = 1.5

# 翻滚速度
var roll_speed = 15

# 当前速度
var velocity : Vector2

# 键盘输入
var global_input_vector : Vector2

################# 属性 #################

# 空格开关
var force = false

# 跑步开关
var run = false

# 最后一次面朝的方向
var last_direction = Vector2(-1,0)


var gravity = 10

################# 模式 #################

export var act_mode = false

################# 动画设置 #################

func anim_move():
	var Vec = get_input_vector()
	if !force:
		if Vec != Vector2.ZERO and run == false:
			animation_tree.set("parameters/basic/MoveBlend/blend_amount",lerp(animation_tree.get("parameters/basic/MoveBlend/blend_amount"),0.5,0.25))
			pass
		elif Vec != Vector2.ZERO and run:
			animation_tree.set("parameters/basic/MoveBlend/blend_amount",lerp(animation_tree.get("parameters/basic/MoveBlend/blend_amount"),1,0.25))
			pass
		elif Vec == Vector2.ZERO:
			animation_tree.set("parameters/basic/MoveBlend/blend_amount",lerp(animation_tree.get("parameters/basic/MoveBlend/blend_amount"),0,0.25))
			pass

## 设置角色朝向
func set_h_vector(vector):
	if vector.x > 0:
		get_node(player_sprite).set("scale",Vector2(-abs(get_node(player_sprite).scale.x),get_node(player_sprite).scale.y))
		pass
	elif vector.x < 0:
		get_node(player_sprite).set("scale",Vector2(abs(get_node(player_sprite).scale.x),get_node(player_sprite).scale.y))
		pass
	pass

## 角色是否在移动
func is_player_move(vector) -> bool:
	if vector != Vector2.ZERO:
		return false
	else:
		return true

################# Script ##################
func _ready():
	### 连接信号
	# 角色朝向
	charactor_input_manager.connect("input_vector_signal",self,"set_h_vector")
	# 角色行走控制
	charactor_input_manager.connect("input_vector_signal",self,"get_input")
	pass

# 物理更新
func _physics_process(delta):
	# 获取键盘输入
	var input_vector = get_input_vector()
	# 计算速度并应用
	var velocity = get_velocity(input_vector,delta) * all_speed_scale
	if act_mode:
		velocity.y -= gravity * delta
		if force:
			velocity.y = -228 * 190 * delta
		move_and_slide(velocity,Vector2.UP)
	else:
		move_and_slide(velocity)
	# 设置最后一次面朝的方向
	set_last_direction()
	# 动画
	anim_move()
	pass



####################   输入   ######################

## 获取信号键盘输入
func get_input(input : Vector2) -> Vector2:
	
	# 返值判断
	if force == true:
		global_input_vector = Vector2.ZERO
		return Vector2.ZERO
	else:
		global_input_vector = input
		return input
	pass

## 获取键盘输入
func get_input_vector() -> Vector2:
	return global_input_vector
	pass

## 常规输入
func _input(event):
	# 跑步输入 切换式
	if Input.is_action_just_pressed("run"):
		if run == true:
			speed_scale = speed_scale_dup
			print("切换走路")
			run = false
		else:
			speed_scale = run_speed_scale
			print("切换跑步")
			run = true
		pass
	pass


## 获取速度
func get_velocity(input_vector : Vector2,delta) -> Vector2:
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed * speed_scale,speed * delta)
		pass
	else:
		velocity = velocity.move_toward(Vector2.ZERO,friction * delta)
		pass
	if !act_mode:
		return velocity
	else:
		return Vector2(velocity.x,gravity * 2000 * delta)
	pass

## 设置最后一次面朝的方向
func set_last_direction():
	if global_input_vector != Vector2.ZERO:
		last_direction = global_input_vector
		pass
	pass

func add_force():
	if is_on_floor():
		print("roll")
		animation_tree.set("parameters/basic/RollShot/active",true)
		force = true
		var timer = Timer.new()
		timer.autostart = true
		timer.wait_time = 0.7
		add_child(timer)
		timer.start()
		timer.connect("timeout",self,"force_timeout")
	pass
func force_timeout():
	force = false
	pass
