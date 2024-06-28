#============================================================
#	Camera Limit By Map
#============================================================
#  摄像机限制范围为 TileMap 大小
#============================================================
# @datetime: 2022-3-15 00:34:43
#============================================================
tool
class_name CameraLimitByMap
extends Parasitic


export var _tilemap : NodePath setget set_tile_map
export var yield_time : float = 0.0
## 额外设置的范围
export var margin : Rect2 = Rect2(0,0,0,0)


#============================================================
#   Set/Get
#============================================================
func set_tile_map(value: NodePath) -> void:
	_tilemap = value
	update_configuration_warning()


#============================================================
#   内置
#============================================================
func _ready():
	if Engine.editor_hint:
		return
	assert(_tilemap != "", "没有设置 _tilemap 属性")
	
	if yield_time > 0:
		yield(get_tree().create_timer(yield_time), "timeout")
	update_camera()
	get_viewport().connect("size_changed", self, "update_camera")


func _get_configuration_warning():
	if not get_parent() is Camera2D:
		return "父节点必须是 Camera2D 类型的节点！"
	if _tilemap == "":
		return "必须设置 _tilemap 属性！"
	if not get_node_or_null(_tilemap) is TileMap:
		return "必须设置 _tilemap 选中节点必须是 TileMap 类型！"
	return ""


#============================================================
#   自定义
#============================================================
func update_camera():
	var camera : Camera2D = get_parent()
	var tilemap : TileMap = get_node_or_null(_tilemap)
	var rect : Rect2 = tilemap.get_used_rect()
	rect.size *= tilemap.cell_size
	camera.limit_left = rect.position.x + margin.position.x
	camera.limit_right = rect.end.x + margin.size.x
	camera.limit_top = rect.position.y + margin.position.y
	camera.limit_bottom = rect.end.y + margin.size.y

