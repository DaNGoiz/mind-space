#============================================================
#	Double Click Reload Game
#============================================================
#  双击重新加载游戏
#============================================================
# @datetime: 2022-3-13 22:41:41
#============================================================
class_name DoubleClickReloadGame
extends Node


export var enable = true


func _unhandled_input(event):
	# 双击重新加载游戏
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_LEFT 
			and event.doubleclick
		):
			if enable:
				clear_meta()
				get_tree().reload_current_scene()
				Logger.info(self, ["重新运行场景"], "", true)


##  清除根节点的元数据
func clear_meta():
	var scene = get_tree().current_scene
	for i in scene.get_meta_list():
		scene.remove_meta(i)
	
	var tree = get_tree()
	for i in tree.get_meta_list():
		tree.remove_meta(i)
	
	Logger.info(self, ['清除 meta 数据'])


