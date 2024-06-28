#============================================================
#	Damage Wrapper
#============================================================
#  伤害的包装器
#============================================================
# @datetime: 2022-4-17 10:55:49
#============================================================
class_name DamageWrapper
extends Wrapper


func _init(host).(host):
	pass


#============================================================
#   自定义
#============================================================
signal took_damage(data)
signal dead


##  对目标造成伤害
## @target  目标
## @damage  伤害值
## @extra  额外数据
func to_damage(target: Node, damage: float, extra = null) -> void:
	# 获取目标的 DamageWrapper
	var wrapper = WrapperInterface.get_wrapper(target, get_script())
	if wrapper:
		wrapper.take_damage(damage, {
			"source": get_host(),	# 伤害来源者
			"extra": extra,	# 额外数据
		})
	else:
		printerr("[ DamageWrapper ] : ", target, " 没有添加 DamageWrapper")


##  受到伤害
## @damage  伤害值
## @extra  额外数据
## @return  返回操作后的数据
func take_damage(damage: float, extra : Dictionary = {}) -> Dictionary:
	var data : Dictionary = {
		"target": get_host(),	# 受伤者对象
		"damage": damage,	# 造成的伤害
		"extra": extra,		# 附加数据
	}
	emit_signal("took_damage", data)
	return data


##  发出死亡信号 
## @return  
func emit_death_signal() -> DamageWrapper:
	emit_signal("dead")
	return self


