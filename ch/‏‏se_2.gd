extends Node3D

func _ready() -> void:
	hide()
	
func _process(delta: float) -> void:
	if Global.canDel:
		show()
