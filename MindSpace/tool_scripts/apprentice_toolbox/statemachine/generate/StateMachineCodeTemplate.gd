##  状态机代码模板

class_name StateMachineCodeTemplate


## 黑板模板代码
const BlackboardTemplate : String = """
#============================================================
#	{BlackboardName}
#============================================================
# @datetime: {DateTime}
#============================================================
class_name {BlackboardName}
extends {ExtendBlackboardClass}


##  value 和状态节点的名称要保持一致
{ConstStateEnum}


"""


##  状态机根节点模板代码
const StateRootTemplate : String = """
#============================================================
#	{StateMachineRootClass}
#============================================================
# @datetime: {DateTime}
#============================================================
class_name {StateMachineRootClass}
extends {ExtendStateMachineRootClass}


"""

##  基础状态模板代码
const BaseStateTemplate : String = """
#============================================================
#	{BaseStateClass}
#============================================================
# * 这是这个状态机的基础状态类，默认添加到场景中，便于修改这个类型中的属性
#     和方法。你可以指定
#============================================================
# @datetime: {DateTime}
#============================================================
class_name {BaseStateClass}
extends {ExtendStateClass}


#(override)
func enter():
	printerr("进入到状态：", name)
	pass


#(override)
func exit():
	printerr("退出状态：", name)
	pass



"""


##  基础子状态机模板
const BaseStateMachineTemplate : String = """
#============================================================
#	{BaseStateMachineClass}
#============================================================
#  子状态机
#============================================================
# @datetime: {DateTime}
#============================================================
class_name {BaseStateMachineClass}
extends BaseStateMachine


""" 


##  状态机代码模板
const StateMachineTemplate : String = """
#============================================================
#	{StateMachineClass}
#============================================================
# @datetime: {DateTime}
#============================================================
class_name {StateMachineClass}
extends {BaseStateMachineClass}


#(override)
func enter():
	pass


#(override)
func state_process(_delta: float):
	pass


#(override)
func exit():
	pass


#(override)
func switch_to(state):
	.switch_to(state)
	pass


#(override)
func parent_exit():
	# 在这里写切换的逻辑：在什么情况下执行切换到同级的另一个状态或状态机
	# 例如：
	#switch_to("State")
	# 否则继续向上退出
	#.parent_exit()
	pass


"""


##  状态模板代码
const StateTemplate : String = """
#============================================================
#	{StateName}
#============================================================
# @datetime: {DateTime}
#============================================================
class_name {StateName}
extends {BaseStateClass}


#(override)
func enter():
	.enter()
	pass


#(override)
func exit():
	.exit()
	pass

"""
