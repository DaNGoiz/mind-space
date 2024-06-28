#============================================================
#	Wrapper Interface
#============================================================
#  所有装饰器数据都被存储在这里
# * 通过 WrapperInterface.get_wrapper(节点, 继承自Wrapper的类) 
#     方法获取对应的 host 所存在的 Wrapper
#============================================================
# @datetime: 2022-4-17 13:49:41
#============================================================

class_name WrapperInterface


const Meta_Interface = "WrapperInterfaceBlackboard"



#============================================================
#   自定义
#============================================================
##  获取所有数据
static func get_all_data(host: Node) -> Dictionary:
	return get_blackboard(host).data


##  获取黑板
static func get_blackboard(host: Node) -> Blackboard:
	var root = host.get_tree().current_scene
	var blackboard : Blackboard
	if not root.has_meta(Meta_Interface):
		blackboard = Blackboard.new()
		blackboard.root = root
		# 设置元数据，添加数据到场景根节点 root 的 meta 中，以达到单例模式的作用
		root.set_meta(Meta_Interface, blackboard)
	else:
		# 获取元数据
		blackboard = root.get_meta(Meta_Interface)
	return blackboard


##  注册 Wrapper
## @class_  这个 Wrapper 属于哪个类
## @host  这个 Wrapper 的 host
## @wrapper  Wrapper类实例对象
static func register(class_: Script, host: Node, wrapper):
	# 记录 host 的这个 Class 类型的 Wrapper
	get_blackboard(host).record(class_, host, wrapper)


##  这个类型的 Wrapper 中是否存在这个 host 
## （例如：WrapperInterface.has_host(AttackWrapper, $Player)）
static func has_host(class_: Script, host: Node) -> bool:
	return get_blackboard(host).has_host(host, class_)


##  获取 host 的 Wrapper
## @host  装饰器的宿主
## @class_  装饰器所在类，直接传入获取的对应类或脚本，比如直接传入 Wrapper
## 例，你创建了一个 MoveWrapper 类传入一个向量参数控制移动：
##    var move_wrapper : MoveWrapper = WrapperInterface.get_wrapper(节点, MoveWrapper)
##    move_wrapper.move(Vector2.RIGHT)
static func get_wrapper(host: Node, class_: Script):
	if host:
		var data : Dictionary = get_all_data(host)
		if data and data.has(class_):
			return data[class_].get(host)
	return null


##  获取 host 的所有的 Wrapper 
## @host  
static func get_host_all_wrapper(host: Node) -> Array:
	var data : Dictionary = get_all_data(host)
	var result : Array = []
	for c in data:
		if data[c].has(host):
			result.append(data[c][host])
	return result


#============================================================
#   数据黑板
#============================================================
class Blackboard:
	var data : Dictionary = {}
	var root 
	
	##  记录 Wrapper
	## @class_  记录的 Wrapper 的类
	## @host  宿主
	## @wrapper  记录的 Wrapper
	func record(
		class_: Script
		, host: Node
		, wrapper: Object
	) -> void:
		# 添加 class 组
		if not data.has(class_):
			data[class_] = {}
		if data[class_].has(host):
			printerr("已设置过 ", host, " 的 Wrapper: ", wrapper, '，此次将覆盖掉上次的 Wrapper.')
		# 添加数据，在这里可以看到一个对象不同的 class 中只能有一个 Wrapper
		data[class_][host] = wrapper
		# 连接信号,节点从场景中移除时对其数据进行擦除
		if not host.is_connected("tree_exited", self, "_erase_data"):
			if host.connect("tree_exited", self, "_erase_data", [class_, host]) != OK:
				printerr("[ Blackboard - record() ] 连接节点的 tree_exited 信号时出现错误")
	
	##  这个类型的包装器中是否有这个 host
	func has_host(host: Node, class_: Script) -> bool:
		return data.has(class_) and data[class_].has(host)
	
	##  获取 Wrapper
	func get_wrapper(host: Node, class_: Script) -> Object:
		if data.has(class_):
			return data[class_].get(host)
		return null
	
	# 擦除数据
	func _erase_data(class_: Script, host: Node):
		data[class_].erase(host)


