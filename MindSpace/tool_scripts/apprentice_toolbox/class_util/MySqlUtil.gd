##================================================================
##    MySQL Uitl
##================================================================
## 需要预先安装 XAMPP，等带有 phpMyAdmin 的环境
## * 下载地址：https://www.apachefriends.org/index.html
## * 安装教程：https://blog.csdn.net/qq_37280924/article/details/122930627
##================================================================
## 1. 安装完成后打开安装到的文件夹里
## 2. 进入 phpMyAdmin 文件夹，创建一个 godot-net 文件夹
## 3. 创建一个名为 execute.php 的文本文件，里面写入当前脚本底部的代码，详见
##    这个脚本底部的代码.
##================================================================
## 【此脚本仅用于本地测试使用，切勿到线上正式使用！】
##================================================================
## @datetime: 2022-2-16 13:39:36
##================================================================
class_name MySQLUtil


const URL = "http://localhost/phpmyadmin/godot-net/execute.php"


## 创建一个查询
static func create_query(dbname: String, add_to: Node) -> __Query__:
	# 创建查询
	var query = __Query__.create(
		add_to, 	# 网络节点添加到这个节点上
		URL,	# 查询的主机
		dbname		# 数据库名
	)
	return query


##  sql 类型转换到 java
static func type_sql2java(sql_type: String) -> String:
	match sql_type:
		"tinyint", "smallint", "mediumint", "int", "bigint":
			return "Integer"
		"float", "double", "decimal":
			return "Double"
		"year", "date", "time", "datetime", "timestamp":
#			return "Date"
			return "String"
		"char", "varchar", "binary", "varbinary", "blob", "text", "enum", "set", "bit":
			return "String"
		_:
			return "Object"


class __Query__:
	
	# 连接这个信号接收执行结果
	# 或者使用 yield 对执行的方法的 'completed' 信号进行结果的延迟获取
	signal response(data)
	
	var __http__ := __HTTP__.new()
	var __url__ : String = ""
	var __db__ : String = ""
	
	static func create(add_to: Node, url: String, dbname: String) -> __Query__:
		var query = __Query__.new()
		query.__url__ = url
		query.__db__ = dbname
		add_to.add_child(query.__http__)
		return query
	
	# 切换数据库
	func change_db(dbname: String) -> void:
		__db__ = dbname
	
	# 如果想要按顺序执行，需要 yield 等待执行完成后继续向下执行，例：
	# yield(query.execute('select * from user'), "completed")
	func execute(sql: String):
		__http__.post(__url__, {
			"dbname": __db__, 
			"sql": sql
		})
		var data = yield(__http__, "response")
		emit_signal("response", data)
		return data
	
	##  查询数据库中所有的表
	## @dbname  数据库名
	## @return  返回查询到的表列表
	func tables(dbname: String) -> Array:
		if dbname.strip_edges().empty():
			return []
		__http__.post(__url__, {
			"dbname": "information_schema", 
			"sql": "select TABLE_NAME from TABLE_CONSTRAINTS where TABLE_SCHEMA='%s'" % dbname
		})
		var data = yield(__http__, "response")
		var list := []
		if validate_json(data['data']) == "":
			for i in parse_json(data['data']):
				list.push_back(i['TABLE_NAME'])
		emit_signal("response", list)
		return list
	
	##  查询数据表中的所有字段
	## @dbname  数据库名
	## @table_name  表名
	## @return  返回查询到的字段列表
	func fields(dbname: String, table_name: String) -> Array:
		if table_name.strip_edges().empty():
			printerr('table name is null.')
			return []
		__http__.post(__url__, {
			"dbname": "information_schema",
			"sql": """
					select COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, COLUMN_COMMENT
					from COLUMNS 
					where TABLE_SCHEMA='%s' and TABLE_NAME='%s'
				""" % [dbname, table_name]
		})	
		
		var data = yield(__http__, "response")
		var list := []
		var match_data_type_length := RegEx.new()
		match_data_type_length.compile("\\(\\d+\\)")
		if validate_json(data['data']) == "":
			for i in parse_json(data['data']):
				var length := 0
				var result := match_data_type_length.search(i['COLUMN_TYPE']) as RegExMatch
				if result:
					length = int(result.get_string())
				list.push_back({
					'field_name': i['COLUMN_NAME'],
					'data_type': i['DATA_TYPE'],
					'length': length,
					'comment': i['COLUMN_COMMENT'],
				})
		emit_signal("response", list)
		return list


## 执行网络请求，响应 response 信号
class __HTTP__ extends HTTPRequest:
	
	signal response(data)
	
	var __http_client__ := HTTPClient.new()
	
	func _ready():
		connect("request_completed", self, '_on_HTTPRequest_request_completed')
	
	## Post 请求
	func post(url: String, data: Dictionary = {}):
		var query_string := __http_client__.query_string_from_dict(data) as String
		# 需要带请求头才行
		var headers := [
			"Content-Type: application/x-www-form-urlencoded", 
			"Content-Length: " + str(query_string.length())
		]
		# 发送请求
		self.request(url, headers, true, HTTPClient.METHOD_POST, query_string)
	
	## Get 请求
	func get(url: String, data: Dictionary = {}):
		self.request(url)
	
	func _on_HTTPRequest_request_completed(result, response_code, headers, body):
		emit_signal("response", {
			"result": result,
			"code": response_code, 
			"head": headers,
			"data": body.get_string_from_utf8()
		})



#============================================================  
#  execute.php 文件代码内容
#============================================================

"""
<?php

$servername = "localhost";
$username = "root";
$password = "";			// 这个填入你的mysql的数据库密码

if (isset($_POST['dbname'])){
	$dbname = $_POST['dbname'];

	// 创建连接
	$conn = new mysqli($servername, $username, $password, $dbname);
	// 检查连接状态
	if ($conn->connect_error) {
		die("连接失败: " . $conn->connect_error);
	} 

	// 不提示下面没有 id 的错误
	// error_reporting(0);

	if (isset($_POST['sql'])){
		$sql = $_POST['sql'];
		$result = $conn->query($sql);
		
		if ($result->num_rows > 0) {
			// 转为 JSON 格式
			$jarr = array();
			while ($rows=mysqli_fetch_array($result)){
				$count=count($rows);//不能在循环语句中，由于每次删除 row数组长度都减小  
				for($i=0;$i<$count;$i++){  
				  unset($rows[$i]);//删除冗余数据
				}
				array_push($jarr,$rows);
			}
			  
			$json = JSON_encode($jarr,JSON_UNESCAPED_UNICODE);
			$arr = json_decode($json);
			echo $json;
		
		} else {
			// 没有 Item
			echo "0 item";
		}

	} else {
		// 没有 SQL
		echo "no sql";
	}

	$conn->close();
	
} else {
	// 没有数据库
	echo "no dbname";
}

?>
"""

