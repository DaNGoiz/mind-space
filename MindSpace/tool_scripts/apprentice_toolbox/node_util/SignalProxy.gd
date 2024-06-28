#============================================================
#	Signal Proxy
#============================================================
#  代理连接信号
# 连接相同参数数量的对象的信号
#============================================================
# @datetime: 2022-4-21 01:43:57
#============================================================

class_name SignalProxy



## 连接另一个信号
## @target  连接的目标
## @target_signal  信号
## @to  要连接的节点
## @to_signal  要连接到的信号
## @arg_count  信号中的参数数量
static func connect_signal(target: Object, target_signal: String, to: Object, to_signal: String):
	var proxy_object = create_proxy_node(to, to_signal)
	target.connect(target_signal, proxy_object, to_signal)


##  创建代理对象
## @to  连接到的对象
## @_signal  连接的信号名
## @return  
static func create_proxy_node(to: Object, _signal: String) -> Object:
	# 获取参数数量
	var arg_count : int = 0
	for data in to.get_signal_list():
		if data['name'] == _signal:
			arg_count = data['args'].size()
			break
			
	# 生成脚本对象
	var args = ""
	for i in arg_count:
		args += "arg%d," % i
	args = args.trim_suffix(",")
	var script = GDScript.new()
	script.source_code = """
extends Object

var host : Object

func {method}({args}):
	host.emit_signal("{signal}", {args})

""".format({
"method": _signal,
"args": args,
"signal": _signal,
})
	if script.reload() == OK:
		var proxy_object = script.new()
		proxy_object.host = to
		return proxy_object
	return null
