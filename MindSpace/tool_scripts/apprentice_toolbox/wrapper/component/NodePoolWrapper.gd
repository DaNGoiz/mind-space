#============================================================
#	Node Pool Wrapper
#============================================================
#  节点对象池包装器
# * 创建的对象移除时用 remove_child() 方法而不是 queue_free() 方法
# * 避免节点频繁的从内存中创建和删除，不必重复初始化新的对象
#============================================================
# @datetime: 2022-4-26 18:03:47
#============================================================
class_name NodePoolWrapper
extends Wrapper


func _init(host).(host):
	pass



#============================================================
#   自定义
#============================================================

# 默认创建类
var _default_class  # 类型为 Script 或 GDScriptNativeClass
# 对象池
var _object_pools : Dictionary = {}
# 池中节点最大的数量
var _max : float = INF


func set_max_count(value: float) -> NodePoolWrapper:
	_max = value
	return self

##  设置默认创建的节点的 Class 类 
## @_class  
## @return  
func set_default_class(_class) -> NodePoolWrapper:
	assert(_is_class(_class), "传入的参数必须是一个类！比如传入 Node")
	
	_default_class = _class
	return self


##  获取池中节点的数量
## @return  
func get_pool_node_count() -> int:
	return _object_pools.size()


##  释放池中所有的节点
## @return  
func release() -> NodePoolWrapper:
	_object_pools.clear()
	return self


##  参数是一个类
## @_class  
## @return  
func _is_class(_class) -> bool:
	return (
		_class is Script
		or _class.get_class() == 'GDScriptNativeClass'
	)

##  实例化一个节点
## @_class  
## @return  
func _instance(_class) -> Node:
	if not _object_pools.has(_class):
		_object_pools[_class] = []
	
	var node : Node = null
	if _class:
		if _object_pools[_class].size() < _max:
			# 创建一个新的，并添加到池中
			node = _class.new()
			node.connect("tree_exited", self, "_node_exit_tree", [_class, node])
			_object_pools[_class].push_back(node)
		else:
			printerr("池中的对象已达到最大数量！ <", _max, ">")
	elif _class is Object:
		node = _instance(_class.get_script())
	else:
		printerr("没有设置创建的对象类型！")
	return node


##  池中存在则获取，不存在则创建
## @_class  
## @return  
func create(_class = null) -> Node:
	if _class == null:
		_class = _default_class
	
	# 如果池中不存在此类型或此类型数量为 0，则实例化新的
	if (not _object_pools.has(_class) 
		or _object_pools[_class].size() == 0
	):
		return _instance(_class)
	else:
		# 从池中弹出对象
		return _object_pools[_class].pop_back()


##  节点退出场景树后，重新添加到池中 
## @_class  
## @node  
func _node_exit_tree(_class: Script, node: Node):
	if is_instance_valid(node):
		_object_pools[_class].push_back(node)

