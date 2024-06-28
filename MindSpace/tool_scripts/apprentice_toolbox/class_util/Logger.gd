#============================================================
#	Logger
#============================================================
# @datetime: 2022-3-17 02:47:30
#============================================================
class_name Logger


# 开头字符串的长度
const AlignCount = 70


##  转换为字符串
## @h_name  头名称
## @object  输出来源对象
## @param  输出的数据
## @separa_char  param中间分隔的字符
## @align_count  对齐字符数 
## @print_path  输出文件路径 
static func _to_str(
	h_name: String,
	object: Object, 
	param, 
	separa_char : String = "",
	print_path : bool = false
):
	# 执行的方法信息
	var stack = get_stack()
	
	# 起始头文本
	var time = OS.get_time()
	var obj_name : String = ""
	var class_na : String = ""
	if object:
		class_na = (object.name if object is Node else object.get_class())
	if stack.size() >= 1:
		obj_name += "%-8s" % ("所在行：" + str(stack[2]['line']))
		obj_name += " | %s.%s()" % [class_na, stack[2]["function"]]
	
	var head = [
			h_name
			, "- %02d:%02d:%02d" % [time.hour, time.minute, time.second]
			, "|"
			, obj_name
		]
	
	# 设置头和对齐字符数
	var text = ""
	for i in head: 
		text += str(i) + ' '
	if text.length() < AlignCount:
		text += " ".repeat(AlignCount - text.length())
	text += ": "
	
	# 输出内容文本
	var string = ""
	if param is Array:
		if separa_char == "":
			for i in param: 
				string += str(i)
		else:
			for i in param: 
				string += (str(i) + separa_char)
	else:
		string = str(param)
	
	var p_text = text + string
	
	# 输出文件路径
	if print_path && stack.size() > 1:
		head.push_back("|")
		p_text += "\n\t"
		p_text += stack[2]['source']
	
	return p_text


##  打印详细信息
static func info(
	object: Object, 
	param, 
	separa_char : String = "",
	print_path : bool = false
):
	print(_to_str("- info", object, param, separa_char, print_path))


##  打印错误信息
static func error(
	object: Object, 
	param, 
	separa_char : String = "",
	print_path = false
):
	printerr(_to_str("error", object, param, separa_char, print_path))


##  格式化输出数据
## @text  
static func print_data(text, t='\t'):
	print(JSON.print(text, t))


