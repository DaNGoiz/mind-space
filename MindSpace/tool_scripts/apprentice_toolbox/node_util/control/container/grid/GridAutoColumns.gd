#============================================================
#	Grid Auto Columns
#============================================================
#  表格自动格数
#============================================================
# @datetime: 2022-5-3 01:10:36
#============================================================
class_name GridAutoColumns
extends Node


signal reset_columns(count)


export var cell_size : Vector2 = Vector2(4, 4)


var _grid : GridContainer


func _ready():
	_grid = get_parent()
	_grid.connect("resized", self, "_resized")


func _resized():
	# 间隔距离
	var v = _grid.get("custom_constants/vseparation")
	var h = _grid.get("custom_constants/hseparation")
	if h == null: h = 4
	if v == null: v = 4
	
	var temp_size = cell_size
	temp_size.x += h
	var count = int(_grid.rect_size.x / temp_size.x) 
	count = max(1, count)
	if _grid.columns != count:
		_grid.columns = count
		emit_signal("reset_columns", count)
		Logger.info(self, ["列数：", count])

