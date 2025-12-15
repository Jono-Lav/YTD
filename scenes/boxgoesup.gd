extends Interactable

@onready var anim = $AnimationPlayer

var back = false


func interact(body):
	if anim.is_playing():
		return  # Ignore interaction while animation is playing

	if !back:
		anim.play("up")
		back = true
	else:
		anim.play("return")
		back = false
