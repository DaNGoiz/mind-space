#============================================================
#	Generate
#============================================================
#  生成状态机脚本及节点
# * 点击代码编辑器的“文件”菜单，点击“运行”进行执行
#============================================================
# @datetime: 2022-4-21 23:25:10
#============================================================
tool
extends EditorScript


func _run():
	# [ 生成示例 ]
	var generator = StateMachineGenerator.new(get_editor_interface())
	# 前缀
	generator.prefix = "Player"
	# 生成的节点结构
	generator.sub_states = [
		"Idle",
		"Move",
	]
	# 替换旧的
	generator.replace_old = true
	# 开始生成
	generator.generate()


