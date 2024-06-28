extends Node

## 玩家血
var charactor_health = 5

func cut_health():
	if health_ui.has_method("cut_health"):
		if charactor_health != 0:
			health_ui.call_deferred("cut_health")
			charactor_health -= 1
		else:
			var gameover_panel = preload("res://resource/guis/gameover/gameover.tscn")
			var panel = gameover_panel.instance()
			add_child(panel)
			panel.panel_show()
		pass
	else:
		push_error("i don't have")
	pass
