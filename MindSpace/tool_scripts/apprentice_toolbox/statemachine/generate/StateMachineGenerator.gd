#============================================================
#	State Machine Generator
#============================================================
#  状态机生成器
#============================================================
# @datetime: 2022-4-22 03:30:01
#============================================================

class_name StateMachineGenerator


var _editor_interface : EditorInterface



#============================================================
#   内置
#============================================================
##  初始化（new 的时候需要传入编辑器接口）
## @editor_interface  编辑器接口
func _init(editor_interface: EditorInterface):
	# 主要用于获取当前编辑器场景节点
	self._editor_interface = editor_interface



#============================================================
#   主要内容
#============================================================

var directory : Directory = Directory.new()
var scripts : Array = []

## 文件保存到的目录
var save_to_path : String = "res://"
## 替换旧的文件
var replace_old : bool = false

# 生成的 State 和 Blackboard 名称前缀
var prefix = ""

# [ Root ]
# 状态机根节点
var extend_statemachine_root_class : String = "BaseStateRoot"
# 根状态机节点的类名（会自动添加前缀）
var statemachine_root_class_name : String = "StateMachineRoot"

# [ Blackboard ]
# 生成的 Blackboard 继承的类（会自动添加前缀）
var extend_blackboard_class : String = "BaseStateBlackboard"

# [ Base State ]
# 继承的 State 类
var extend_state_class : String = "BaseExecuteState"
# 生成的基础 State 类名称（会自动添加前缀）
var base_state_class_name : String = "BaseState"

# [ Base State Machine ]
var base_statemachine_class_name : String = "BaseStateMachine"


# [ Sub State]
# 扩展基础类的子类（会自动添加前缀）
# * 不要有名字一样的状态名，那会造成名城相同的冲突
# * 这个结构项目中的数据必须是 String 类型
# * 或者带有 parent（String 类型数据）、sub（Array 类型的数据） 两个 key 的 Dictionary 类型的格式
# * 例如：
#	[
#		"Idle",
#		{"parent": "Move", "sub": ["Left", "Right"]},
#		{"parent": "Attack", "sub": ["A1", "A2"]},
#	]
var sub_states : Array = []


#============================================================
#   Set/Get
#============================================================
func get_editor_interface() -> EditorInterface:
	return _editor_interface

func get_scene() -> Node:
	return get_editor_interface().get_edited_scene_root()

func get_base_state_class_name() -> String:
	return prefix + base_state_class_name

func get_base_statemachine_class_name() -> String:
	return prefix + base_statemachine_class_name

## 获取一个正在选中的节点
var _select_node : Node
func get_selecting_node() -> Node:
	if _select_node == null:
		var selects = get_editor_interface().get_selection().get_selected_nodes()
		if selects.size() > 0:
			_select_node = selects[0]
	return _select_node

## 时间日期
func get_datatime() -> String:
	return get_data() + " " + get_time()

func get_data() -> String:
	return "{year}-{month}-{day}".format(OS.get_datetime())

func get_time() -> String:
	var data = OS.get_datetime()
	data['hour'] = "%02d" % int(data['hour'])
	data['minute'] = "%02d" % int(data['minute'])
	data['second'] = "%02d" % int(data['second'])
	return "{hour}:{minute}:{second}".format(data)

func get_state(state_name: String) -> String:
	return prefix + state_name

func get_statemachine(statemachine_name: String) -> String:
	return prefix + statemachine_name


#============================================================
#   自定义
#============================================================
##  开始生成
## @require_prefix 需要设置前缀
func generate(require_prefix: bool = true):
	if sub_states.size() == 0:
		printerr("[ 警告 ] 没有设置 sub_states 属性！")
	
	if get_selecting_node() == null:
		printerr("需要选中一个节点进行执行")
		return
	
	if require_prefix and prefix == "":
		printerr("没有设置 prefix 属性，若想忽略，请执行 generate(false)，取消指定前缀")
		return
	
	# 如果当前有场景，则创建到这个场景的位置
	if get_scene().filename:
		var temp_prefix : String = prefix.replace(" ", "_").to_lower()
		temp_prefix = temp_prefix.trim_suffix("_") + "_"
		save_to_path = get_scene() \
			.filename \
			.get_base_dir() \
			.plus_file(temp_prefix + "statemachine")
	
	# 没有目录则创建
	if not directory.dir_exists(save_to_path):
		directory.make_dir_recursive(save_to_path)
		print("[ 创建目录 ]", save_to_path)
	
	# 开始执行生成步骤
	print("[ 开始准备生成到 ]", save_to_path)
	if not get_selecting_node() is BaseStateRoot:
		_select_node = generate_statemachine_root()
	
	generate_blackboard()
	generate_base_state()
	generate_base_state_machine()
	generate_state()
	
	update_resource()
	
	reload_all_script()
	
	print("[ 生成完成 ]")


##  生成黑板
func generate_blackboard():
	var blackboard_name : String = prefix + "StateBlackboard"
	print("[ 开始生成 ] ", blackboard_name)
	var path : String = save_to_path.plus_file(blackboard_name + ".gd")
	generate_and_add_node(
		blackboard_name
		, path
		, StateMachineCodeTemplate \
		.BlackboardTemplate \
		.trim_prefix("\n") \
		.format({
			"BlackboardName": blackboard_name,
			"ExtendBlackboardClass": extend_blackboard_class,
			"ConstStateEnum": generate_key(sub_states),
			"DateTime": get_datatime(),
		})
	)


##  生成黑板中的 key
func generate_key(list: Array):
	var r : String = _state_key(list, "")
	r = "const States = {\n" + r.trim_suffix(", \n")
	return r

func _state_key(
	list: Array
	, parent : String
	, indent : int = 1
	, all_text: String = ""
) -> String:
	all_text += ""
	
	if parent != "":
		all_text += "{IndentText}{State} = {\n".format({
			"State": parent,
			"IndentText": "\t".repeat(indent-1),
		})
	
	var t = "\t".repeat(indent) + "{State} = \"{StateName}\", \n"
	for state in list:
		if state is String:
			all_text += t.format({
				"State": state,
				"StateName": get_state(state),
			})
		elif state is Dictionary:
			all_text = _state_key(state['sub'], state['parent'], indent+1, all_text)
	all_text += "\t".repeat(indent-1) + "}, \n"
	return all_text


##  生成基础状态
func generate_base_state():
	var path = save_to_path.plus_file(get_base_state_class_name() + ".gd")
	generate_and_add_node(
		get_base_state_class_name()
		, path
		, StateMachineCodeTemplate \
			.BaseStateTemplate \
			.trim_prefix("\n") \
			.format({
				"BaseStateClass": get_base_state_class_name(),
				"ExtendStateClass": extend_state_class,
				"DateTime": get_datatime(),
			})
		, null
		, true
	)


##  生成基础状态机
func generate_base_state_machine():
	var path = save_to_path.plus_file(get_base_statemachine_class_name() + ".gd")
	generate_and_add_node(
		get_base_statemachine_class_name()
		, path
		, StateMachineCodeTemplate \
			.BaseStateMachineTemplate \
			.trim_prefix("\n") \
			.format({
				"BaseStateMachineClass": get_base_statemachine_class_name(),
				"BaseStateClass": get_base_state_class_name(),
				"DateTime": get_datatime(),
			})
	)


##  生成状态机根节点
func generate_statemachine_root():
	var statemachine_root : String = prefix + statemachine_root_class_name
	var path : String = save_to_path.plus_file(statemachine_root + ".gd")
	return generate_and_add_node(
		statemachine_root
		, path
		, StateMachineCodeTemplate \
			.StateRootTemplate \
			.trim_prefix("\n") \
			.format({
				"StateMachineRootClass": statemachine_root,
				"ExtendStateMachineRootClass": extend_statemachine_root_class,
				"DateTime": get_datatime(),
			})
	)


##  生成 State
func generate_state():
	# 开始生成脚本文件
	print("[ 开始生成状态 ]", sub_states)
	
	var add_to_stack : Array = []
	add_to_stack.push_back(get_selecting_node())
	
	# 递归生成节点
	_generate_state(sub_states, "", [get_selecting_node()])


##  开始递归生成状态节点
func _generate_state(
	state_list: Array
	, parent_state_name: String
	, add_to: Array
) -> void:
	# 父状态机
	if parent_state_name != "":
		parent_state_name = get_statemachine(parent_state_name)
		var parent_node = _add_state(
			parent_state_name
			, StateMachineCodeTemplate \
				.StateMachineTemplate \
				.trim_prefix("\n") \
				.format({
					"StateMachineClass": parent_state_name,
					"BaseStateMachineClass": get_base_statemachine_class_name(),
					"DateTime": get_datatime(),
				}) 
			, add_to.back()
		)
		# 入栈
		add_to.push_back(parent_node)
	
	# 子状态
	for sub_state in state_list:
		if sub_state is String:
			sub_state = get_state(sub_state)
			_add_state(
				sub_state
				, StateMachineCodeTemplate \
					.StateTemplate \
					.trim_prefix("\n") \
					.format({
						"BaseStateClass": get_base_state_class_name(),
						"StateName": sub_state,
						"DateTime": get_datatime(),
					}) 
				, add_to.back()
			)
		elif sub_state is Dictionary:
			var list : Array = sub_state['sub']
			_generate_state(list, sub_state['parent'], add_to)
	
	# 出栈
	add_to.pop_back()


func _add_state(state: String, code: String, parent: Node) -> Node:
	print("  > ", state)
	return generate_and_add_node(
		state
		, save_to_path.plus_file(state + ".gd")
		, code
		, parent
	)


##  重新加载所有脚本
func reload_all_script():
	print("[ reload 所有脚本 ]")
	for script in scripts:
		script = script as GDScript
		if script.reload() != OK:
			print("  > ", script, " 脚本加载失败")
	print("[ reload 完成 ]")


#============================================================
#   其他
#============================================================
##  生成并保存节点
## @return  返回生成的节点
func generate_and_add_node(
	node_name: String
	, path: String
	, code: String
	, add_to: Node = null
	, reload : bool = false
) -> Node:
	print("[ 开始生成 ] ", node_name, " | ", path)
	if not directory.file_exists(path):
		# 保存脚本
		var script = GDScript.new()
		script.source_code = code
		save_script(path, script, reload)
	else:
		print("[ 没有创建 ]", " 已存在:  ", path)
	# 添加节点
	return add_node(node_name, path, add_to)


##  更新资源
func update_resource():
	# 扫描更新的资源文件
	var rfs = get_editor_interface().get_resource_filesystem()
	rfs.scan()
	rfs.update_script_classes()


##  添加节点
func add_node(
	node_name: String
	, script_path: String
	, add_to : Node = null
) -> Node:
	if not directory.file_exists(script_path):
		print("  > 不存在这个文件 ", script_path)
		return null
	
	if add_to == null:
		add_to = get_selecting_node()
	
	if not add_to.has_node(node_name):
		# 节点添加到选中的节点上
		var node : Node = Node.new()
		node.set_script(load(script_path))
		node.name = node_name
		add_to.add_child(node)
		# 设置为当前场景
		node.owner = get_scene()
		print("  > 添加节点：", node_name, " ", node)
		return node
	
	else:
		# 设置脚本
		add_to \
			.get_node(node_name) \
			.set_script(load(script_path))
		print("  > 设置节点的脚本 ", node_name)
		return add_to.get_node(node_name)


##  保存脚本文件
## @path  
## @script  
func save_script(path: String, script: GDScript, reload : bool = false):
	if not directory.file_exists(path) or replace_old:
		ResourceSaver.save(path, script)
		print("  > 保存了脚本 ", path)
		if not reload:
			scripts.push_back(script)
		else:
			script.reload()
		return true
		
#		if script.reload() == OK:
#			ResourceSaver.save(path, script)
#			print("  > 保存了脚本 ", path)
#			return true
#		else:
#			printerr("   ", path, " 脚本有误")
	
	else:
		print("   ", path, " 已存在，则这个文件跳过创建")
	return false

