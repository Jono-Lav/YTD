extends Area2D

@onready var root : Node2D = $".."

func _on_body_entered(body: Node2D) -> void:
	Global.score2d += 1
	Pickupsound.play()
	if Global.score2d == 5:
		Global.score2d = 0
		Global.missionCompleted = true
		get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
	queue_free()
	
