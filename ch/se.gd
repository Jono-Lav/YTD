extends Node3D

func _process(delta: float) -> void:
	if Global.canDel:
		queue_free()
