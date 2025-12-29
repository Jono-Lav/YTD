extends Interactable

@onready var anim: AnimationPlayer = $AnimationPlayer
var back: bool = false

func _ready() -> void:
	interact_ray.visible = false

func interact(body) -> void:
	if anim.is_playing():
		return
	if not back:
		anim.play("expand")
		back = true
	else:
		anim.play("returnback")
		back = false
	await anim.animation_finished
