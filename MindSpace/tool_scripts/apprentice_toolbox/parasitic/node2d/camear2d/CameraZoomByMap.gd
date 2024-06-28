#============================================================
#	Camera Zoom By Map
#============================================================
#  设置相机镜头为地图的大小范围的缩放
#============================================================
# @datetime: 2022-3-16 16:41:15
#============================================================
tool
class_name CameraZoomByMap
extends Parasitic


enum ScaleType {
	Normal,	# 按照常比例进行缩放
	Min,	# 按照最小的范围进行缩放
	Max,	# 按照最大的范围进行缩放
}

export var _tile_map : NodePath setget set_tile_map
export var yield_time : float = 0.0
export (ScaleType) var scale_type : int = ScaleType.Normal
export var min_zoom : Vector2 = Vector2(0, 0)
export var max_zoom : Vector2 = Vector2(100, 100)


#============================================================
#   Set/Get
#============================================================
func set_tile_map(value: NodePath) -> void:
	_tile_map = value
	update_configuration_warning()


#============================================================
#   内置
#============================================================
func _ready():
	if Engine.editor_hint:
		return
	assert(_tile_map != "", "没有设置 _tile_map 属性")
	
	if yield_time > 0:
		yield(get_tree().create_timer(yield_time), "timeout")
	update_camera()
	
	get_viewport().connect("size_changed", self, "update_camera")


func _get_configuration_warning():
	if not get_parent() is Camera2D:
		return "父节点必须是 Camera2D 类型的节点！"
	if _tile_map == "":
		return "必须设置 _tile_map 属性！"
	if not get_node_or_null(_tile_map) is TileMap:
		return "必须设置 _tile_map 选中节点必须是 TileMap 类型！"
	return ""



#============================================================
#   自定义
#============================================================
func update_camera():
	var camera : Camera2D = get_parent()
	var tilemap : TileMap = get_node_or_null(_tile_map)
	var rect : Rect2 = tilemap.get_used_rect()
	rect.size *= tilemap.cell_size
	var scale = rect.size / tilemap.get_viewport_rect().size
	match scale_type:
		ScaleType.Min:
			var z = min(scale.x, scale.y)
			camera.zoom = Vector2(z, z)
		ScaleType.Max:
			var z = max(scale.x, scale.y)
			camera.zoom = Vector2(z, z)
		ScaleType.Normal:
			camera.zoom = scale
	
	# 不能低于最小也不能超出最大
	camera.zoom.x = clamp(camera.zoom.x, min_zoom.x, max_zoom.x)
	camera.zoom.y = clamp(camera.zoom.y, min_zoom.y, max_zoom.y)
	
