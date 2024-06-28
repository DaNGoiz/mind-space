extends Node
# MODE ： 被监控


## 跑步触发
signal run

## 空格触发
signal jump

## 键盘输入vector2
signal input_vector_signal(input)

## 左右键盘输入vector2
signal input_vector_signal_h(input)

# 更新
func _physics_process(delta):
	get_input()
	pass


## 常规输入
func _input(event):
	if Input.is_action_just_pressed("run"):
		emit_signal("run")
		pass
	if Input.is_action_just_pressed("jump"):
		emit_signal("jump")
		print("jump")
	pass

## 获取键盘输入
func get_input():
	# 键盘输入
	var input_vector
	var h_vector = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var v_vector = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	input_vector = Vector2(h_vector,v_vector).normalized()
	# 返信号
	emit_signal("input_vector_signal",input_vector)

## 获取左右键盘输入
func get_input_h():
	# 键盘输入
	var input_vector
	var h_vector = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input_vector = Vector2(h_vector,0)
	# 返信号
	emit_signal("input_vector_signal_h",input_vector)
