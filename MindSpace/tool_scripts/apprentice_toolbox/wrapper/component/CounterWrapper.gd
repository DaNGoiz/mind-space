#============================================================
#	Counter Wrapper
#============================================================
#  计数器包装类
#============================================================
# @datetime: 2022-4-20 01:14:32
#============================================================
class_name CounterWrapper
extends Wrapper


func _init(host).(host):
	pass


#============================================================
#   自定义
#============================================================
var __data__ : Dictionary = {}


##  获取数量
## @id  对应 ID 的数量
## @return  
func get_count(id) -> int:
	return __data__.get(id, 0)

##  清零 
## @id  清除对应的 ID 为 0
func clear(id) -> CounterWrapper:
	__data__[id] = 0
	return self

##  比较这个 id 的数字
## @return  如果相同，则返回 0
##    小于 count 返回 -1
##    大于 count 则返回 1
func eq(id, count: int) -> int:
	if __data__[id] == count:
		return 0
	else:
		return -1 if __data__[id] < count else 1

##  增加数量
## @id  增加的对应 id 的数量
## @count  增加数量
## @return  
func add(id, count: int = 1) -> CounterWrapper:
	if __data__.has(id):
		__data__[id] += count
	else:
		__data__[id] = count
	return self

##  减少数量
## @id  增加的对应 id 的数量
## @count  增加数量
func sub(id, count: int = -1) -> CounterWrapper:
	if __data__.has(id):
		__data__[id] -= count
	else:
		__data__[id] = count
	return self



