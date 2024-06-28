#============================================================
#	Property Wrapper
#============================================================
#  属性包装器
#============================================================
# @datetime: 2022-4-17 11:33:35
#============================================================
class_name PropertyWrapper
extends Wrapper


func _init(host).(host):
	pass


#============================================================
#   自定义
#============================================================
##  属性发生改变（属性改变前进行发送信号）
signal property_changed(property, new_value)


var __propertys__ : Dictionary


##  获取所有属性数据 
## @return  
func get_property_data() -> Dictionary:
	return __propertys__

##  获取属性值 
## @property  
func get_property(property):
	return __propertys__.get(property)

##  是否存在属性 
func has_property(property) -> bool:
	return __propertys__.has(property)


##  设置属性
func set_property(property, value) -> PropertyWrapper:
	if __propertys__.has(property) and __propertys__[property] != value:
		emit_signal("property_changed", property, value)
		__propertys__[property] = value
	return self

##  添加属性
## @property  
## @value  
func add_property(property, value) -> PropertyWrapper:
	if has_property(property):
		set_property(property, get_property(property) + float(value))
	return self

##  减少属性
## @property  
## @value  
func sub_property(property, value) -> PropertyWrapper:
	if (has_property(property) 
		and typeof(value) in [TYPE_REAL, TYPE_INT]
	):
		set_property(property, get_property(property) - value)
	return self

##  添加属性数据
func add_property_data(data: Dictionary) -> PropertyWrapper:
	for property in data:
		add_property(property, data[property])
	return self

##  减少属性数据
func sub_property_data(data: Dictionary) -> PropertyWrapper:
	for property in data:
		sub_property(property, data[property])
	return self

##  初始化属性，host 的属性必须是 Dictionary 类型
func init_property(data: Dictionary) -> PropertyWrapper:
	__propertys__ = data
	emit_property_changed_signal()
	return self

##  发出属性改变信号
#（一般用来设置完属性后，对其他连接属性改变的信号的方法做更新操作
#改变 UI 上显示的属性等操作）
func emit_property_changed_signal() -> PropertyWrapper:
	for key in __propertys__:
		emit_signal("property_changed", key, __propertys__[key])
	return self

