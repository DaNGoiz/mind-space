#============================================================
#	Object
#============================================================
#  对象工具类
#============================================================
# @datetime: 2022-2-8 13:38:02
#============================================================
class_name ObjectUtil


##  连接节点的信号
## @from  需要连接的节点
## @_signal  信号
## @target  连接到的节点
## @method  方法
## @binds  绑定的参数
static func connect_to(
	from: Object,
	_signal: String, 
	target: Object, 
	method: String, 
	binds: Array = [  ], 
	flags: int = 0
):
	if from.is_connected(_signal, target, method):
		prints(from, '的', _signal, "信号已经连接到", target, method, '方法')
		return from
	if from.connect(_signal, target, method, binds, flags) != OK:
		printerr(from, "连接 ", _signal, " 信号时出现错误")
		print_debug("连接 " , _signal, " 信号失败")
	return from


##  连接到列表中的多个同类型的节点
static func connect_to_by_list(
	object_list: Array,
	_signal: String, 
	target: Object, 
	method: String, 
	binds: Array = [  ], 
	flags: int = 0
) -> void:
	for object in object_list:
		connect_to(object, _signal, target, method, binds, flags)


##  获取对象的脚本的路径
## @object  
## @return  
static func get_object_script_path(object: Object) -> String:
	return (object.get_script() as Script).resource_path


##  创建一个计时器
##  (默认不添加到节点上，需要调用返回的 Timer 的 add_to 方法进行添加)
## @wait_time  等待时间
## @one_shot  执行一次
## @autostart  自动开始
## @return  
static func create_timer(
	wait_time: float,
	one_shot: bool = true,
	autostart: bool = false
) -> CusTimer:
	var timer = CusTimer.new()
	timer.wait_time = wait_time
	timer.one_shot = one_shot
	timer.autostart = autostart
	return timer


##  创建一个线程
##  (默认不添加到节点上，需要调用返回的 Timer 的 add_to 方法进行添加)
## @delta  固定帧速率
## @target  调用目标
## @method  目标方法，每次到达时间传入这个 delta 值
## @autostart  直接开始启动
## @return  返回一个 Timer
static func create_process(
	delta: float, 
	target: Object, 
	method: String,
	autostart : bool = true
) -> CusTimer:
	var timer = connect_to(
		create_timer(delta, false, autostart), 
		"timeout", target, method, [delta]
	)
	return timer


## 自定义的 Timer
class CusTimer extends Timer:
	
	# 添加到节点上
	func add_to(node: Node, legible_unique_name: bool = false) -> CusTimer:
		if self.is_inside_tree():
			var stack = get_stack()[1]
			printerr(stack['function'], ':', stack['line'], 
				" 已经添加到节点上了",
				'\n\t', stack['source']
			)
			return self
		node.call_deferred('add_child', self, legible_unique_name)
		return self


##  获取所有子节点
## @node  
## @return  
static func get_all_child(node: Node) -> Array:
	var list := []
	__all_child__(node, list)
	return list

static func __all_child__(node: Node, list: Array):
	list.append_array(node.get_children())
	for child in node.get_children():
		__all_child__(child, list)


##  鼠标在 Control 节点上 
## @node  Control类型的节点
## @return  返回鼠标是否停留在上边
static func mouse_on_control(node: Control) -> bool:
	return node.get_rect().has_point(node.get_global_mouse_position())

