
extends Npc

@onready var collisionShape : CollisionShape3D = $CollisionShape3D

var once = true

func interact(body):
	if once:
		await DialogueManager.dialogue_ended
		collisionShape.disabled = true
		once = false
	else:
		await DialogueManager.dialogue_ended
		get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
