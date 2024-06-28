#============================================================
#	Camera
#============================================================
# 相机抖动
#============================================================
# @datetime: 2022-3-3 20:52:31
#============================================================
class_name CameraShake
extends Parasitic


const TRAUMA = 2


export (OpenSimplexNoise) var noise : OpenSimplexNoise
##  抖动幅度
export (float, 0, 2) var trauma : float = 0.0
##  抖动衰退
export (float, 0, 1) var decay : float = 0.6
##  时间缩放
export var time_scale : float = 100
export var max_x : int = 150
export var max_y : int = 150
export var max_r : int = 25


var __time__ = 0.0


#============================================================
#   自定义
#============================================================
func _process(delta):
	__time__ += delta
	
	var shake = pow(trauma, 2)
	get_host().offset.x = noise.get_noise_3d(__time__ * time_scale, 0, 0) * max_x * shake
	get_host().offset.y = noise.get_noise_3d(0, __time__ * time_scale, 0) * max_y * shake
	get_host().rotation_degrees = noise.get_noise_3d(0, 0, __time__ * time_scale) * max_r * shake
	
	if trauma > 0: 
		trauma = clamp(trauma - (delta * decay), 0, TRAUMA)

