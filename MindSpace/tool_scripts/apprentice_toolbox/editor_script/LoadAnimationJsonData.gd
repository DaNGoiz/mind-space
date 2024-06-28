#============================================================
#	Load Animation Json Data
#============================================================
#  添加 JSON 数据的动画到 AnimationPlayer 上
#============================================================
# @datetime: 2022-4-22 00:33:25
#============================================================
tool
extends EditorScript



## 加载动画的 JSON 数据到 AnimationPlayer 上
func _run():
	var nodes = get_editor_interface().get_selection().get_selected_nodes()
	if nodes.size() == 0:
		printerr('没有选中节点！')
		return
	var player : AnimationPlayer = nodes[0] as AnimationPlayer
	if player == null:
		printerr("选中的节点不是 AnimationPlayer 类型的节点！")
		return
	
	# 读取 JSON 数据
	var data = load_data("res://src/assets/pixel/characters/all.json")
	data.erase("_meta")
	
	player.add_animation("none", Animation.new())
	
	# 删除所有动画
	for anim_name in player.get_animation_list():
		player.remove_animation(anim_name)
	
	# 加载动画数据
	var name_regex = RegEx.new()
	name_regex.compile("(idle|run)")
	
	var sprite_node_path : String = "."
	var anim_names = data.keys()
	for anim_name in anim_names:
		# 只添加开头是 xxx 的动画
		if not anim_name.begins_with("basic_"):
			continue
		
		var anim_data = data[anim_name]
		
		# 读取加载帧动画资源
		var animation = Animation.new()
		var speed_scale = 1000.0
		var time = 0.0
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		# 设置动画关键帧
		for i in anim_data['frames']:
			# 设置 region_rect 属性
			animation.track_set_path(track_index, sprite_node_path + ":region_rect")
			animation.track_insert_key(track_index, time, Rect2(i['x'], i['y'], i['w'], i['h']))
			time += i['duration'] / speed_scale
		animation.length = time
		animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)
		
		# 如果名称中带有这些词，则播放循环
		if name_regex.search(anim_name):
			animation.loop = true
		
		# 加载到动画播放器中
		print("添加 [%s] 动画到 AnimationPlayer 中" % anim_name)
		player.add_animation(anim_name, animation)
	
	print('[动画加载完成]')


func load_data(filepath: String) -> Dictionary:
	var file = File.new()
	file.open(filepath, File.READ)
	var text = file.get_as_text()
	var data = parse_json(text) as Dictionary
	return data
