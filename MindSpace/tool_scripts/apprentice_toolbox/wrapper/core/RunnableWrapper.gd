#============================================================
#	Runnable Wrapper
#============================================================
#  执行功能包装器
# * 只有一个功能，重写 run 方法，直接调用 
#     WrapperHelper.run(节点, 继承自RunnableWrapper的类) 
#     进行调用执行功能
#============================================================
# @datetime: 2022-4-20 18:42:46
#============================================================
class_name RunnableWrapper
extends Wrapper


func _init(host).(host):
	pass


#============================================================
#   自定义
#============================================================
##  执行
func run(data):
	pass

