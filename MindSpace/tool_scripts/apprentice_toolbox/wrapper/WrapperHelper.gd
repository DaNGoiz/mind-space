#============================================================
#	Wrapper Helper
#============================================================
# * 对 WrapperInterface 进一步的封装，以便更方便使用功能
# * 方便获取 host 对应类型的 Wrapper
#============================================================
# @datetime: 2022-4-25 22:53:11
#============================================================

class_name WrapperHelper



#============================================================
#   获取
#============================================================
static func get_wrapper(host, _class: Script):
	if host:
		var wrapper = WrapperInterface.get_wrapper(host, _class)
		if wrapper == null:
			printerr("这个节点没有设置这个类型的 Wrapper")
		return wrapper 
	return null

static func get_attack(host: Node) -> AttackWrapper:
	return get_wrapper(host, AttackWrapper) as AttackWrapper

static func get_counter(host: Node) -> CounterWrapper:
	return get_wrapper(host, CounterWrapper) as CounterWrapper

static func get_damage(host: Node) -> DamageWrapper:
	return get_wrapper(host, DamageWrapper) as DamageWrapper

static func get_equipment(host: Node) -> EquipmentWrapper:
	return get_wrapper(host, EquipmentWrapper) as EquipmentWrapper

static func get_fall(host: Node) -> FallWrapper:
	return get_wrapper(host, FallWrapper) as FallWrapper

static func get_interval(host: Node) -> IntervalWrapper:
	return get_wrapper(host, IntervalWrapper) as IntervalWrapper

static func get_item(host: Node) -> ItemWrapper:
	return get_wrapper(host, ItemWrapper) as ItemWrapper

static func get_node_pool(host: Node) -> NodePoolWrapper:
	return get_wrapper(host, NodePoolWrapper) as NodePoolWrapper

static func get_property(host: Node) -> PropertyWrapper:
	return get_wrapper(host, PropertyWrapper) as PropertyWrapper



#============================================================
#   功能
#============================================================
##  创建池节点
## @host  对象节点，创建这个对象的节点池
## @_class  节点类型
## @return  返回创建的节点
static func create_pool_node(host: Node, _class = null) -> Node:
	return get_node_pool(host).create(_class)


##  执行对象的 Runnable 类的 run 方法
## @host  宿主对象
## @_class  Runnable其子类
## @data  传入参数
static func run(host: Node, _class: Script, data=null):
	var r = WrapperInterface.get_wrapper(host, _class)
	if r is RunnableWrapper:
		return r.run(data)
	return null


