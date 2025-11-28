extends Interactable

@onready var anim = $AnimationPlayer

var back = false

func interact(body):
	if !back and anim.animation_finished:
		anim.play("expand")
		back = true
	elif back and anim.animation_finished:
		back = false
		anim.play("returnback")
