extends Interactable

@onready var anim = $AnimationPlayer
@onready var open : AudioStreamPlayer3D = $open

var opened = false

func interact(body):
	if Global.score >= 1 and !opened:
		open.play()
		opened = true
		anim.play("open")
	elif !opened:
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/door.dialogue"))
		$AudioStreamPlayer3D.play()
	else:
		$byeee.play()
