extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var machine = get_parent()
	machine.muzzlePos = position
