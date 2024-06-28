#============================================================
#	Reg Ex Util
#============================================================
#  正则表达式工具类
#============================================================
# @datetime: 2022-4-25 21:42:43
#============================================================
class_name RegExUtil


static func search(
	pattern: String
	, subject: String
	, offset: int = 0, 
	end: int = -1
) -> RegExMatch:
	var regex := RegEx.new()
	regex.compile(pattern)
	return regex.search(subject, offset, end)


static func search_all(
	pattern: String
	, subject: String
	, offset: int = 0
	, end: int = -1
) -> Array:
	var regex := RegEx.new()
	regex.compile(pattern)
	return regex.search_all(subject, offset, end)


