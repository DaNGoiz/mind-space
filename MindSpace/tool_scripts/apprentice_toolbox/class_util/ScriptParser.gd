#============================================================
#	Script Parser
#============================================================
# 匹配代码中的方法名数据。方法名，参数，返回类型
#============================================================
# @datetime: 2022-4-29 19:50:22
#============================================================

class_name ScriptParser


var code_regex = RegEx.new()
var code_pattern = ""

var parameter_regex = RegEx.new()
var parameter_pattern = ""


func _init():
	# 方法头
	code_pattern += "(?<MethodType>(static\\s+func|func))\\s+"
	# 方法名
	code_pattern += "(?<MethodName>[^\\(]*)\\b\\s*"
	# 参数
	code_pattern += "\\((\\s*(?<Parameter>(\\s|.)*?[^:])\\s*)(?<=\\))"
	# 返回类型
	code_pattern += "(\\s*(->\\s*(?<ReturnType>\\S+))?\\s*:)\\s*"
	code_regex.compile(code_pattern)
	
	
	# 参数名
	parameter_pattern += "\\s*(?<ArgName>[^:=,]*)\\s*"
	parameter_pattern += "("
	# 参数冒号
	parameter_pattern += "\\s*(:)?\\s*"
	# 参数类型
	parameter_pattern += "(?<ArgType>\\w+)?"
	# 等号
	parameter_pattern += "\\s*(=?)\\s*"
	
	parameter_pattern += ")\\s*"
	
	# 匹配 Value
	parameter_pattern += "(?<Value>"
	# 匹配 Vector | Transform | Rect2 等类型的值
	parameter_pattern += "(Vector[2|3]|Transform(2D)?|Rect2)(\\([^\\)]*\\))"
	parameter_pattern += "|([^,]*)"
	parameter_pattern += ")?\\s*"
	
	# 逗号结尾
	parameter_pattern += ",?\\s*"
	
	parameter_regex.compile(parameter_pattern)


##  解析脚本
## @script  
## @return  
func parse_script(script: Script) -> Dictionary:
	return parse_code(script.source_code)


##  解析文件
## @path  
## @return  
func parse_file(path: String) -> Dictionary:
	var script = load(path)
	if script is Script:
		return parse_script(script)
	else:
		return {}


##  解析代码
## @code  
## @return  
func parse_code(code: String) -> Dictionary:
	if code.strip_edges() == "":
		return {}
	
	var results = code_regex.search_all(code)
	var data : Dictionary = {}
	for result in results:
		result = result as RegExMatch
		var method_name : String = result.get_string("MethodName").strip_edges()
		var method_type : String = result.get_string("MethodType")
		var paramter : String = result.get_string("Parameter")
		var return_type : String = result.get_string("ReturnType")
		
		data[method_name] = {
			"is_static": (method_type != "func"),	# 是否是静态函数
			"method_name": method_name.strip_edges(),
			"parameter": _parse_parameter(paramter),
			"return_type": return_type.strip_edges(),
		}
	
	return data


##  Parse Parameter 
## @part  参数代码片段
func _parse_parameter(part: String) -> Array:
	part = part.strip_edges()
	part = part.trim_prefix("(").trim_suffix(")")
	if part == "":
		return []
	var results = parameter_regex.search_all(part)
	var list : Array = []
	for result in results:
		result = result as RegExMatch
		var arg_name = result.get_string("ArgName").strip_edges()
		var arg_type = result.get_string("ArgType").strip_edges()
		var default_value = result.get_string("Value").strip_edges()
		if arg_name != "":
			list.append({
				"arg_name": arg_name,
				"arg_type": arg_type,
				"default_value": default_value,
			})
	return list


