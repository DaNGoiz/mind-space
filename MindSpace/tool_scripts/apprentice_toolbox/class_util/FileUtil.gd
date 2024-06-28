#============================================================
#	File Util
#============================================================
# @datetime: 2021-11-20 16:09:26
#============================================================
class_name FileUtil

const Data = {}
const Logger = preload("Logger.gd")


#============================================================
#   单例对象
#============================================================
##  File 单例 
static func file_single() -> File:
	if not Data.has("File"):
		Data['File'] = File.new()
	return Data["File"] as File


##  Directory 单例 
static func directory_single() -> Directory:
	if not Data.has("Directory"):
		Data['Directory'] = Directory.new()
	return Data["Directory"] as Directory



#============================================================
#   扫描文件
#============================================================

##  扫描目录里的文件
## @path  
## @return  
static func scan_file(path: String) -> Array:
	var dir := directory_single()
	dir.open(path)
	dir.list_dir_begin()
	var files : Array = []
	var filename := dir.get_next()
	while filename:
		if not dir.current_is_dir():
			files.push_back(path.plus_file(filename))
		filename = dir.get_next()
	return files


##  扫描目录里的目录
## @path  
## @return  
static func scan_dir(path: String) -> Array:
	var dir := directory_single()
	dir.open(path)
	dir.list_dir_begin()
	var dirs : Array = []
	var filename := dir.get_next()
	while filename:
		if (dir.current_is_dir() 
			and not filename.begins_with('.')
		):
			dirs.push_back(path.plus_file(filename))
		filename = dir.get_next()
	return dirs


##  递归扫描目录
## @path  
## @return  
static func scan_dir_recursive(path: String) -> Array:
	var list : Array = []
	__scan_dir_recursive__(path, list)
	return list

static func __scan_dir_recursive__(
	path: String
	, append_list: Array 
) -> void:
	var temp_list = scan_dir(path)
	append_list.append(temp_list)
	for dir in temp_list:
		__scan_dir_recursive__(dir, append_list)

##  递归扫描文件 
## @path  
## @return  
static func scan_file_recursive(path: String) -> Array:
	var list : Array = []
	__scan_file_recursive__(path, list)
	return list

static func __scan_file_recursive__(path: String, list: Array) -> void:
	var dir := directory_single()
	dir.open(path)
	dir.list_dir_begin()
	var files : Array = []
	var dirs : Array = []
	
	var filename := dir.get_next()
	while filename:
		if not dir.current_is_dir():
			files.push_back(path.plus_file(filename))
		else:
			if not filename.begins_with('.'):
				dirs.push_back(path.plus_file(filename))
		filename = dir.get_next()
	list.append_array(files)
	
	for d in dirs:
		__scan_file_recursive__(d, list)


##  扫描目录和文件 
## @path  扫描的目录
## @return 返回文件和目录数据，返回的数据里 keys() 为目录列表，
##     每个目录是其对应扫描到的内容。
static func scan_dir_and_file(path: String) -> Dictionary:
	var data := {}
	__scan_dir_and_file__(path, data)
	return {
		'dirs': [],
		'files': [],
		'sub': data
	}

static func __scan_dir_and_file__(path: String, path_data : Dictionary) -> Dictionary:
	var directory := directory_single()
	directory.open(path)
	directory.list_dir_begin()
	var filename := directory.get_next()
	var dirs : Array = []
	var files : Array = []
	while filename:
		# 目录
		if directory.current_is_dir():
			if not filename.begins_with('.'):
				dirs.push_back(path.plus_file(filename))
		# 文件
		else:
			files.push_back(path.plus_file(filename))
		filename = directory.get_next()
	
	var data := {}
	path_data[path] = data
	# 目录及其文件
	data['dirs'] = dirs
	data['files'] = files
	# 目录列表
	data['sub'] = {}
	for dir in dirs:
		data['sub'][dir] = __scan_dir_and_file__(dir, path_data)
	return data



#============================================================
#   加载文本
#============================================================
##  打开文本文件
static func load_text(path: String) -> String:
	if file_single().file_exists(path):
		var err = file_single().open(path, File.READ)
		if err == OK:
			Logger.info(null, ["打开文本文件：", path])
			var text = file_single().get_as_text()
			file_single().close()
			return text
		else:
			Logger.error(null, ['打开', path, '文件失败'], ' ')
	else:
		Logger.error(null, ["没有 ", path, ' 这个文件'])
	return ''


##  保存文本
## @path  文件路径
## @text  文本内容
## @return  返回保存状态
static func save_text(path: String, text: String) -> int:
	# 判断是否有这个文件夹，没有则创建
	var dir_path = path.get_base_dir()
	if not directory_single().dir_exists(dir_path):
		directory_single().make_dir_recursive(dir_path)
		Logger.info(null, ['没有文件夹，创建了新的文件夹：', dir_path], "", true)
	# 开始保存文件
	var err = file_single().open(path, File.WRITE)
	if err == OK:
		file_single().store_string(text)
		file_single().close()
		Logger.info(null, ["保存成功：", path])
	else:
		Logger.error(null, ["保存失败：", err], '', true)
	return err


#============================================================
#   创建文件
#============================================================
##  复制文件到目录
## @files  文件列表
## @to_path  复制到这个文件
static func copy_files_to(files: Array, to_path: String) -> void:
	# 没有则创建
	if not directory_single().dir_exists(to_path):
		directory_single().make_dir_recursive(to_path)
	
	for file in files:
		var file_path := to_path.plus_file(file.get_file())
		# 复制
		directory_single().copy(file, file_path)



#============================================================
#   其他
#============================================================
## 路径是否有效
## @path  目录
## @auto_create  不存在则自动创建
## @return  返回是否存在
static func valid_dir(path: String, auto_create: bool = false) -> bool:
	if not directory_single().dir_exists(path):
		if auto_create:
			if directory_single().make_dir_recursive(path) == OK:
				return true
		return false
	else:
		return true


