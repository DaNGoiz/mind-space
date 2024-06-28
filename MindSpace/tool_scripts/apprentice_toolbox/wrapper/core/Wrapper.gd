#============================================================
#	Wrapper 基础类
#============================================================
#  装饰器/包装器
#============================================================
# * 创建 Wrapper 的时候要在 new 里传入要装饰的节点。比如： 
# 
#		PropertyWrapper.new(self)
#
# * 扩展这个类主要在于能对节点实现类似接口的能力且增强基本功能，参看其他
#     扩展这个的脚本，创建 Wrapper 则传入的节点就拥有了对应 Wrapper 
#     的功能。
# * 扩展这个类的时候必须要写 _init 方法
#
#		func _init(host).(host):
#			pass
#
#   因为不写的话，Godot解释器就会报错，所以必须写。
# * 建议 new 的时候放在 _enter_tree() 方法中，需要用到那个类的子节点的 
#     地方在它的 _ready 方法中再进行设置。
# * 扩展的脚本对 get_host() 进行操作，或记录属于这个 host 的数据等
# * 扩展这个脚本，然后设置 host。通过 WrapperInterface.get_wrapper 
#    方法进行获取这个 host 的 Wrapper，调用获取到 Wrapper 执行功能或
#    获取数据等。
# * 这样只通过 Wrapper 进行操作 host 的行为，就有点了类似接口的感觉。
# 
# 例：
#	 Player.gd 脚本中，注册 Player 的属性
#
#	 func _enter_tree():
#	      PropertyWrapper.new().init_property({"health": 3, "move_speed": 100})
#
#	 在其他脚本里可通过当前 get_wrapper 方法获取到这个 Wrapper
#	 * 比如给他增加 1 点生命：
#
#	      # 获取 Player 的属性包装器
#	      var property_wrapper : PropertyWrapper = WrapperInterface \
#	          .get_wrapper(Global.player, PropertyWrapper)
#	      property_wrapper.add_property("health", 1)
#
#	 * 比如添加物品的 Dictionary 类型的数据
#	      property_wrapper.add_property_data({"health": 1, "move_speed": 10})
# 
#	 那么其他地方可以比较方便的获取这个 PropertyWrapper 并连接其信号，方便
#	 进行联动修改。
#============================================================
# @datetime: 2022-4-17 15:55:02
#============================================================
class_name Wrapper


var __host__ : Node


#============================================================
#   Set/Get
#============================================================
func get_host():
	return __host__


func set_host(value: Node):
	__host__ = value
	return self


#============================================================
#   内置
#============================================================
func _init(host: Node):
	__host__ = host
	# 自动注册数据
	WrapperInterface.register(get_script(), __host__, self)


#============================================================
#   自定义
#============================================================
##  Wrapper 中的连接（这个连接会返回 Wrapper 对象以方便进行链式调用方法）
func wrapper_connect(
	signal_: String, 
	target: Object, 
	method: String, 
	binds: Array = [  ], 
	flags: int = 0
) -> Wrapper:
	if connect(signal_, target, method, binds, flags) != OK:
		printerr("连接", signal_, "信号时出现错误")
	return self


##  连接 host 中的信号
func wrapper_conn_host(
	signal_: String, 
	method: String, 
	binds: Array = [  ], 
	flags: int = 0
):
	return wrapper_connect(signal_, get_host(), method, binds, flags)


##  创建计时器 
## @autostart  自动开始
## @return  
func create_timer(autostart: bool = true) -> Timer:
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = autostart
	get_host().add_child(timer)
	return timer



