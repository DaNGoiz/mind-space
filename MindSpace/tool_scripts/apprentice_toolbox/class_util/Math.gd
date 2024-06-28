#============================================================
#	Math
#============================================================
# @datetime: 2022-3-15 08:34:56
#============================================================
class_name MathUtil


##  根据 probalility 中的概率列表，随机根据对应索引概率值返回 list 一个项
## @list  
## @probalility  
static func list_probability(list: Array, probalility: Array):
	# 根据每个数字的概率，求其总和
	# 让每个数字作为一个区间，数字
	# 越大区间就越大，概率也就越大
	
	if list.size() != probalility.size():
		print_debug("数量不一致")
		return null
	
	var sum = 0.0
	var p_list = [] # 概率列表
	for i in probalility:
		sum += i
		p_list.push_back(sum)
	
	var r = randf() * sum
	for i in p_list.size():
		# 当前概率超过或等于随机的概率，则返回
		if p_list[i] >= r:
			return list[i]
	return null

##  返回列表随机一项
static func rand_item(list: Array):
	return list[randi() % list.size()]

##  随机产生一个整数
static func rand_range_i(from: float, to: float) -> int:
	return int(rand_range(from, to))

##  节点面向方向
static func direction_to(a: Node2D, b: Node2D) -> Vector2:
	return a.global_position.direction_to(b.global_position)


static func angle_to(a: Node2D, b: Node2D) -> float:
	return a.global_position.angle_to(b.global_position)

##  返回一个范围的等差的数组
## @from  开始的值
## @to  结束的值
## @increment  增量值（等差是多少）
## @include_to  返回的值包括to
## @return  
static func range_plus(
	from: int, 
	to: int = INF, 
	increment: int = 1, 
	include_to: bool = false
) -> Array:
	if to == INF:
		to = from
		from = 0
	return range(from, to + increment if include_to else 0, increment)


##  这个节点到另一个节点之间的角度
## @a  
## @b  
## @return  
static func angle_to_point(a: Node2D, b: Node2D) -> float:
	return a.global_position.angle_to_point(b.global_position)

##  在两个数字之间
static func between(value: float, min_: float, max_: float) -> bool:
	return value >= min_ and value <= max_

