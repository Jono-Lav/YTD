extends Interactable

@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var anim = $AnimationPlayer2
@onready var open : AudioStreamPlayer3D = $Open
@onready var close : AudioStreamPlayer3D = $Close
@onready var door = $"."

var opened = false

func interact(body):
	if anim.is_playing():
		return
	if !opened:
		open.play()
		opened = true
		anim.play("open")
		await anim.animation_finished
		door.prompt = "Close"
	else:
		close.play()
		opened = false
		anim.play("close")
		await anim.animation_finished
		door.prompt = "Open"
