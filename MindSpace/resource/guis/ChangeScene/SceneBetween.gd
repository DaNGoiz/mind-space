extends Node2D

export var scene = 1 setget scene_changed
var sceneB = scene

onready var background = $Blank

onready var scene1 = $Button/Sprite4
onready var scene2 = $Button/Sprite
onready var scene3 = $Button/Sprite2
onready var scene4 = $Button/Sprite3

onready var line12 = $Line/Sprite
onready var line23 = $Line/Sprite4
onready var line34 = $Line/Sprite3
onready var line41 = $Line/Sprite2
onready var line13 = $Line/Sprite5
onready var line24 = $Line/Sprite6

#信号触发显示，代码
func _ready():
	background.visible = true
	scene1.visible = true

func scene_changed(scene):
	if scene == 1:
		scene1.visible = true
	elif scene == 2:
		scene2.visible = true
	elif scene == 3:
		scene3.visible = true
	elif scene == 4:
		scene4.visible = true
	
	if (scene == 1 && sceneB == 2) || (scene == 2 && sceneB == 1):
		line12.visible = true
	elif (scene == 2 && sceneB == 3) || (scene == 3 && sceneB == 2):
		line23.visible = true
	elif (scene == 3 && sceneB == 4) || (scene == 4 && sceneB == 3):
		line34.visible = true
	elif (scene == 4 && sceneB == 1) || (scene == 1 && sceneB == 4):
		line41.visible = true
	elif (scene == 1 && sceneB == 3) || (scene == 3 && sceneB == 1):
		line13.visible = true
	elif (scene == 2 && sceneB == 4) || (scene == 4 && sceneB == 2):
		line24.visible = true
		
	sceneB = scene
