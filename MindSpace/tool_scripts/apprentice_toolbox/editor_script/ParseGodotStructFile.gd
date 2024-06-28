#============================================================
#	Parse Godot Struct File
#============================================================
#  解析文件，创建 Godot 场景
# * 自定义的一个字符解析
#============================================================
#  调用下面方法创建生成场景和文件
# * 调用 parse_file 解析对应的文件
# * 调用 parse_code 解析代码
#============================================================
# @datetime: 2022-4-19 04:19:28
#============================================================

tool
extends EditorScript


enum DataType {
	None,
	Resources,
	Scene,
	Code,
	Else,
}

var directory := Directory.new()
var create_to_path : String = "res://" setget set_create_to_path


func set_create_to_path(value: String):
	if value.replace(" ", "") == "":
		value = "res://"
	elif not directory.dir_exists(value):
		printerr("不存在 ", value, " 这个目录！")
		value = "res://"
	create_to_path = value
	return self


func _run():
	pass
	# 设置文件保存位置
	self.set_create_to_path("res://")
	# 测试解析文件并创建场景及文件（这个文件在当前脚本目录下）
	self.parse_file("res://addons/apprentice_toolbox/editor_script//Role.gdstruct")


#============================================================
#   解析执行
#============================================================
##  解析文件内容
## @path  文件路径
func parse_file(path: String):
	var file := File.new()
	file.open(path, File.READ)
	var text = file.get_as_text()
	file.close()
	# 解析代码
	parse_code(text)


##  解析代码内容
## @code  代码
func parse_code(code: String):
	# 解析块内容
	var block_list = parse_block(code)
	var list = parse_block_code(block_list)
#	Logger.print_data(list)
#	return
	
	# 先保存脚本代码文件
	for data in list:
		var filename : String = data['filename']
		if data['type'] == DataType.Code:
			var script = save_code(create_to_path.plus_file(filename), data['data'])
			resource_data["@" + data['filename']] = script
	
	# 解析创建资源
	for data in list:
		if data['type'] == DataType.Resources:
			parse_resource(data['data'])
	
	# 解析并保存场景
	for data in list:
		var filename : String = data['filename']
		if data['type'] == DataType.Scene:
			parse_and_save_scene(data['data'], create_to_path.plus_file(filename))


##  解析代码块
## @code  
## @return  
func parse_block(code: String) -> Array:
	var block_regex = RegEx.new()
	block_regex.compile("(={3,})\\s*(?<BlockType>\\S+)\\s*")
	
	var lines = code.split('\n')
	
	var count : int = 0
	var blocks : Array = []
	var block_type: String = ""
	var text : String = ""
	
	for line in lines:
		line = str(line)
		if line.begins_with("==="):
			count += 1
			# 新行
			if count % 2 == 1:
				var result = block_regex.search(line)
				if result:
					block_type = result.get_string("BlockType")
				text = ""
				continue
			else:
				if text != "":
					blocks.append({
						"blocktype": block_type,
						"context": text,
					})
		text += line + "\n"
	return blocks


##  解析代码块中的代码 
## @block_code_list  
## @return  
var block_type_regex := RegEx.new()
func parse_block_code(block_code_list: Array) -> Array:
	var pattern = "\\<\\s*(?<Type>\\S+)\\s*\\>"
	block_type_regex.compile(pattern)
	
	# 解析代码
	var list := []
	for code in block_code_list:
		var blocktype : String = code['blocktype']
		var context : String = code['context']
		
		# 文件名
		var filename : String = blocktype
		var extension : String = filename.get_extension()
		var data = {}
		data["filename"] = filename
		if extension in ["tscn", "scn"]:
			# 场景类型
			data['type'] = DataType.Scene
			data['data'] = context
		elif extension == "gd":
			# 代码类型
			data['type'] = DataType.Code
			data['data'] = context
		else:
			# 资源类型
			var result = block_type_regex.search(blocktype)
			if result:
				var type : String = result.get_string("Type")
				if type.replace(" ", "") == "Resource":
					data['type'] = DataType.Resources
					data['data'] = context
					
		# 没有设置，则默认为 none
		if not data.has('type'):
			data["type"] = DataType.None
			data['data'] = context
		list.append(data)
	return list



#============================================================
#   场景
#============================================================
##  解析场景 
## @context  
## @return  
var scene_regex := RegEx.new()
func parse_scene(context: String) -> Array:
	var pattern = ""
	# 匹配注释
	pattern += "\\s*-{2,}\\s*(?<Description>[^\\n]+)"
	pattern += "\\n|"
	
	# 匹配缩进
	pattern += "\\n?(?<Indent>\\s*)"	# 贪婪匹配空白字符，直到没有匹配到空白字符为止
	# 匹配节点
	pattern += "(?<NodeName>[^\\<]+?)\\s*"	# 匹配到非 < 之前为止
	# 匹配节点类型和继承类
	pattern += "\\<\\s*(((?<NodeType>\\S+?)(\\s*:\\s*(?<Extends>\\S+))?))\\s*\\>"
	# 匹配 {} 内容
	pattern += "(\\{(?<Content>.*)\\})?"	# 匹配 {} 内容
	pattern += "[^\\n]*"	# 匹配到非 \n 符号为止
	pattern += "\\n?"
	scene_regex.compile(pattern)
	
	# 开始匹配
	var results : Array = scene_regex.search_all(context)
	var list : Array = []
	for result in results:
		result = result as RegExMatch
		list.append({
			"node_name": result.get_string("NodeName"),
			"node_type": result.get_string("NodeType"),
			"extends": result.get_string("Extends"),	# 继承的脚本或类型，没有则自动创建
			"description": result.get_string("Description"),
			"indent": result.get_string("Indent").length(),
			"property_context": result.get_string("Content")
		})
	return list


##  解析并保存场景
## @context  上下文代码
## @filename  保存文件名
func parse_and_save_scene(context: String, filename: String):
	# 解析
	var list : Array = parse_scene(context)
	# 记录缩进数据
	var indent_data : Dictionary = {}
	# 场景中的节点
	var root : Node = null
	for data in list:
		var node_type : String = data["node_type"]
		var node : Node = InstanceObject.instance(node_type)
		# 没有这个类，则创建一个
		if node == null:
			node = Node.new()
			var script = GDScript.new()
			var extend : String = data["extends"]
			if extend:
				node_type = extend
			script.source_code = "class_name %s\nextends Node\n " % node_type
			node.set_script(script)
		
		# 创建对应场景结构
		var node_name : String = data["node_name"]
		var indent : int = data["indent"]
		node.name = node_name
		if root == null:
			root = node
			indent_data[-1] = node
		else:
			var parent_node : Node = parent_node(indent_data, indent)
			parent_node.add_child(node, true)
			node.owner = root
			# 清除上一个相同缩进的节点，记录这个缩进
			# 这样这个数据就在最后一个位置了
			indent_data.erase(indent)
			indent_data[indent] = node
		
		# 设置属性
		var property_context : String = data['property_context']
		set_object_property(node, parse_property(property_context))
	
	# 保存场景包
	var pack = PackedScene.new()
	pack.pack(root)
	ResourceSaver.save(filename, pack)


##  上级缩进的节点
func parent_node(data: Dictionary, curr_indent: int) -> Node:
	var list = data.keys()
	list.invert()
	for key in list:
		if key < curr_indent:
			return data[key] as Node
	return null



#============================================================
#   代码
#============================================================
##  保存代码
func save_code(path: String, code: String) -> Script:
	assert(path.get_extension() == "gd", "文件名必须以 .gd 结尾！")
	var script = GDScript.new()
	script.source_code = code
	ResourceSaver.save(path, script)
	return script



#============================================================
#   资源
#============================================================
##  解析资源 
## @context  
## @return  
var resource_regex : RegEx
var resource_data : Dictionary = {}
func parse_resource(context: String):
	if resource_regex == null:
		resource_regex = RegEx.new()
		var pattern = ""
		# 匹配资源ID名称
		pattern += "\\[\\s*(?<IdName>\\S+)\\s*\\]\\s*"
		# 匹配资源类型
		pattern += "(?<ResType>\\S+)\\s*"
		# 匹配资源属性
		pattern += "\\{\\s*(?<PropertyContext>[^\\}]*)\\s*\\}"
		resource_regex.compile(pattern)
	
	# 开始匹配解析字符串
	var results = resource_regex.search_all(context)
	for result in results:
		result = result as RegExMatch
		var id : String = result.get_string("IdName")
		var res_type : String = result.get_string("ResType")
		var property_context : String = result.get_string("PropertyContext")
		
		# 创建资源
		var res : Resource = InstanceObject.custom_class(res_type)
		if res is Resource:
			set_object_property(res, parse_property(property_context))
			resource_data[id] = res



#============================================================
#   属性
#============================================================
##  解析属性
## @code  
var property_regex : RegEx
func parse_property(code: String) -> Array:
	if property_regex == null:
		property_regex = RegEx.new()
		# 匹配属性和值
		property_regex.compile(
			"(\\s*(?<Property>\\S+)\\s*:\\s*(?<Value>("
			+ "\\([^\\)]+\\)\\s*|\\S+"+
			")[^,]?)\\s*)"
		)
	
	var list := []
	var results = property_regex.search_all(code)
	for result in results:
		list.append({
			"property": result.get_string("Property"),
			"value": result.get_string("Value")
		})
	
	return list


##  设置对象属性
## @object  对象
## @property_data_list  属性数据列表
func set_object_property(object: Object, property_data_list: Array):
	if property_data_list.size() == 0:
		return
	
	for data in property_data_list:
		var property : String = data['property']
		var value = conver_property_value(object, property, data['value'])
		if value:
			object.set(property, value)


##  转换属性值 
## @object  
## @property  
## @value  
func conver_property_value(object: Object, property: String, value: String):
	value = value.strip_edges()
	if resource_data.has(value):
		# 引用
		if value.begins_with("@"):
			value = value.trim_prefix("@")
			if not directory.file_exists(value):
				value = create_to_path.plus_file(value)
			return load(value)
		return resource_data[value] as Resource
	
	else:
		# 有后缀名
		if value.get_extension() != "":
			if not value.begins_with("res://"):
				value = create_to_path.plus_file(value)
			if directory.file_exists(value):
				return load(value)
			return null
		
		# 绝对路径资源
		elif (value.begins_with("res://") 
			and directory.file_exists(value)
		):
			return load(value)
		else:
			# 其他
			if validate_json(value) == "":
				return parse_json(value)
	return value



#============================================================
#   实例化对象
#============================================================
class InstanceObject:
	
	static func instance(_name: String):
		if ClassDB.can_instance(_name):
			return ClassDB.instance(_name)
		return custom_class(_name)
	
	static func custom_class(_name: String):
		var script = GDScript.new()
		script.source_code = """
static func create():
	return %s.new()
		""" % _name
		# 脚本重新加载
		if script.reload() == OK:
			return script.new().create()
		else:
			print("对象创建错误，没有 ", _name, " 这个类")
		return null


