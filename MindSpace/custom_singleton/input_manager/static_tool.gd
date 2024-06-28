class_name input_manager_tool



## 将Input类下as_text()函数返回的字符串转为属性数组
static func string_to_item(string : String) -> Array:
	var output = []
	var regex = RegEx.new()
	regex.compile("\\w+=.+")
	var result = regex.search(string)
	if result:
		output = result.get_strings()
	else:
		push_error("match_faild")
		pass
	return output
	pass

