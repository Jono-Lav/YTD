extends Interactable

@onready var paper : Node2D = $"../paper"
@onready var collision : CollisionShape3D = $CollisionShape3D
@onready var player  = get_node("/root/" + get_tree().current_scene.name + "/player/head")

func interact(body):
	paper.visible = true
	collision.disabled = true
	Global.playerStop = true
	player.toggle_mouse_capture()
	player.mouse_capturable = false
