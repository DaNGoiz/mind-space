#============================================================
#	Skill Interface
#============================================================
#  技能接口
#============================================================
# @datetime: 2022-4-21 19:00:55
#============================================================

class_name SkillInterface


const Meta_Interface = "MetaSkillInterface"


#============================================================
#   自定义
#============================================================
##  获取所有数据
static func get_all_data(host: Node) -> Dictionary:
	return get_blackboard(host).data


##  获取黑板
static func get_blackboard(host: Node) -> Blackboard:
	var root = host.get_tree().root
	var blackboard : Blackboard
	if not root.has_meta(Meta_Interface):
		blackboard = Blackboard.new()
		# 设置元数据，添加数据到场景根节点 root 的 meta 中，以达到单例模式的作用
		root.set_meta(Meta_Interface, blackboard)
	else:
		# 获取元数据
		blackboard = root.get_meta(Meta_Interface)
	return blackboard


##  注册 Skill 节点 
## @host  宿主
## @skill  技能节点
## @register_name  注册的名称
static func register(host: Node, skill: Node, register_name: String):
	get_blackboard(host).record(host, register_name, skill)


##  获取技能节点
## @host  
## @skill_name  
static func get_skill(host: Node, skill_name: String):
	var data : Dictionary = get_all_data(host)
	if data and data.has(skill_name):
		return data[skill_name].get(host)
	return null


##  施放 Skill
## @host  
## @skill_name  
## @data=null  
static func cast(host: Node, skill_name: String, data = null):
	var skill = get_skill(host, skill_name)
	if skill:
		skill.control(data)


#============================================================
#   数据黑板
#============================================================
class Blackboard:
	var data : Dictionary = {}
	
	##  记录 Skill
	func record(
		host: Node
		, skill_name : String
		, skill: Object
	) -> void:
		# 添加 class 组
		if not data.has(skill_name):
			data[skill_name] = {}
		# 添加数据，在这里可以看到一个对象不同的 class 中只能有一个 Skill
		data[skill_name][host] = skill
		# 连接信号,节点从场景中移除时对其数据进行擦除
		if not host.is_connected("tree_exited", self, "_erase_data"):
			if host.connect("tree_exited", self, "_erase_data", [skill_name, host]) != OK:
				printerr("[ Blackboard - record() ] 连接出现错误")
	
	##  这个类型的包装器中是否有这个 host
	func has_host(host: Node, skill_name: String) -> bool:
		return data.has(skill_name) and data[skill_name].has(host)
	
	##  获取 Skill
	func get_skill_name(host: Node, skill_name: String) -> Object:
		if data.has(skill_name):
			return data[skill_name].get(host)
		return null
	
	# 擦除数据
	func _erase_data(skill_name: String, host: Node):
		data[skill_name].erase(host)
