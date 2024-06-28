#=======================================================
# 示例的解析代码
#input_move()
#
#input_jump() : <Jump>
#{Key}: <Idle>
#input_attack() : <Attack>
#input_move() : move()
#=======================================================
# 其中 
# * input_xxx(): 执行这个方法
# * {Key}: 获取黑板中的这个 Key 的值
# * <Jump>: 如果前面的方法执行结果成立，则跳转到这个状态中
#=======================================================

class_name StateExecuteParser


var executer_map : Dictionary = {}


## 代理执行器，代理执行状态的线程功能
class ProxyExecuter:
	
	var host: Node
	
	func state_process(_delta: float):
		pass


## 划分块
func _blocks(code: String):
	var list = [[]]
	for line in code.split("\n"):
		line = line.strip_edges()
		if line:
			list.back().append(line)
		else:
			if list.back().size() > 0:
				list.append([])
	if list.back().size() == 0:
		list.pop_back()
	return list


## 头部添加 if
func _add_if(lines: Array):
	var _h_if = "\tif "
	for i in lines.size():
		var line: String = lines[i]
		if line.find(":") == -1:
			line += ": pass"
		line = _h_if + line
		_h_if = "\telif "
		lines[i] = line


func _gene_script(data: Array):
	var code = """extends StateExecuteParser.ProxyExecuter

func state_process(_delta: float):
"""
	for lines in data:
		for line in lines:
			code += line + "\n"
		code += "\n"
	code += "\tpass\n"
	
	# 创建新的脚本
	var script = GDScript.new()
	script.source_code = code
	script.reload()
	return script


##  解析
## @return  返回生成一个代理执行功能的执行器
func parse(code: String, host: Node = null):
	if executer_map.has(code):
		return executer_map[code].new() as ProxyExecuter
	
	var regex = RegEx.new()
	var pattern = ""
	var result = code
	
	pattern = "(?!\\.)(?<Method>\\w+)\\b\\s*(?=\\()"
	regex.compile(pattern)
	result = regex.sub(result, "host.$Method", true)
	
	pattern = "\\{(?<Key>[^\\}]+)\\}"
	regex.compile(pattern)
	result = regex.sub(result, "host.get_data('$Key')", true)
	
	pattern = "\\<(?<State>[^>]+)\\>"
	regex.compile(pattern)
	result = regex.sub(result, "host.switch_to('$State')", true)
	
	# 代码转为块行
	var blocks = _blocks(result)
	for lines in blocks:
		_add_if(lines)
	
	# 生成脚本
	var script = _gene_script(blocks)
	executer_map[code] = script
	# 创建这个对象
	var proxy := script.new() as ProxyExecuter
	proxy.host = host
	return proxy


