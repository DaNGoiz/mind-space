#============================================================
#	Toplevel
#============================================================
# 指定的节点 top_level 设为 true
#============================================================
# @datetime: 2022-3-7 15:06:53
#============================================================
class_name TopLevel
extends RemoteTransform2D


func _ready():
	var node = get_node(remote_path) as Node2D
	node.set_as_toplevel(true)

